#!/usr/bin/env python3
"""Tests for claude_follow_record. Run: python3 ~/.claude/hooks/claude_follow_record_test.py"""
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("cfr", os.path.join(HERE, "claude_follow_record.py"))
cfr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cfr)

passed = failed = 0


def check(cond, msg):
    global passed, failed
    if cond:
        passed += 1
        print("PASS  " + msg)
    else:
        failed += 1
        print("FAIL  " + msg)


# ── find_root ────────────────────────────────────────────────────────────────
# git repo
with tempfile.TemporaryDirectory() as d:
    subprocess.run(["git", "init", "-q", d], check=True)
    sub = os.path.join(d, "a", "b")
    os.makedirs(sub)
    root = cfr.find_root(os.path.join(sub, "x.py"))
    check(os.path.realpath(root) == os.path.realpath(d), "find_root: git repo returns toplevel")

# marker dir, no git
with tempfile.TemporaryDirectory() as d:
    open(os.path.join(d, "package.json"), "w").close()
    sub = os.path.join(d, "src")
    os.makedirs(sub)
    check(cfr.find_root(os.path.join(sub, "x.ts")) == d, "find_root: package.json marker root")

# ── find_edit_range ──────────────────────────────────────────────────────────
with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False) as tf:
    tf.write("line one\nline two\nline three\nline four\n")
    tf_path = tf.name

r = cfr.find_edit_range(tf_path, "line two\nline three")
check(r == (2, 3), f"find_edit_range: 2-line edit returns (2,3), got {r}")

r = cfr.find_edit_range(tf_path, "line four")
check(r == (4, 4), f"find_edit_range: 1-line edit returns (4,4), got {r}")

r = cfr.find_edit_range(tf_path, "")
check(r is None, "find_edit_range: empty new_text returns None")

os.unlink(tf_path)

# ── record with line_end ──────────────────────────────────────────────────────
state_r = {}
cfr.record(state_r, "/tmp/proj/a.py", line=5, line_end=10)
root_r = next(iter(state_r))
check(state_r[root_r][0]["line"] == 5, "record: line stored")
check(state_r[root_r][0]["line_end"] == 10, "record: line_end stored")

# re-record with new range updates in place
cfr.record(state_r, "/tmp/proj/a.py", line=7, line_end=8)
check(state_r[root_r][0]["line"] == 7, "record: re-record updates line")
check(state_r[root_r][0]["line_end"] == 8, "record: re-record updates line_end")
check(len(state_r[root_r]) == 1, "record: re-record doesn't duplicate")

# record without line_end clears stale line_end
cfr.record(state_r, "/tmp/proj/a.py", line=3)
check("line_end" not in state_r[root_r][0], "record: missing line_end clears stale value")

# ── record ordering / dedup ───────────────────────────────────────────────────
state = {}
cfr.record(state, "/tmp/proj/old.py")
cfr.record(state, "/tmp/proj/new.py")
root = next(iter(state))
check(state[root][0]["file"] == "/tmp/proj/new.py", "record: most recent first")
check(len(state[root]) == 2, "record: two distinct files")

# re-record existing bumps it to top without duplicating
cfr.record(state, "/tmp/proj/old.py")
check(len(state[root]) == 2, "record: re-record dedups (no growth)")
check(state[root][0]["file"] == "/tmp/proj/old.py", "record: re-recorded file bubbles to top")

# ── end-to-end via stdin (the real hook entrypoint) ───────────────────────────
with tempfile.TemporaryDirectory() as d:
    statef = os.path.join(d, "state.json")
    cfr.STATE_PATH = statef
    payload = json.dumps({"tool_name": "Edit", "tool_input": {"file_path": "/tmp/zz/main.py"}})
    sys.stdin = type("S", (), {"read": staticmethod(lambda: payload)})()
    # json.load reads from the object's .read via json — emulate by monkeypatching stdin
    import io
    sys.stdin = io.StringIO(payload)
    rc = cfr.main()
    sys.stdin = sys.__stdin__
    check(rc == 0, "main: returns 0")
    saved = json.load(open(statef))
    files = [e["file"] for v in saved.values() for e in v]
    check("/tmp/zz/main.py" in files, "main: stdin payload recorded to state file")

# missing path → no-op, no crash
import io as _io
sys.stdin = _io.StringIO(json.dumps({"tool_name": "Bash", "tool_input": {"command": "ls"}}))
check(cfr.main() == 0, "main: non-file tool is a no-op")
sys.stdin = sys.__stdin__

print(f"\n{passed} passed, {failed} failed")
sys.exit(1 if failed else 0)
