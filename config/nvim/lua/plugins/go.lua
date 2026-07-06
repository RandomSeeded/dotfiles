-- Let treesitter own Go syntax coloring instead of gopls semantic tokens.
-- LazyVim's lang.go extra sets `init_options.semanticTokens = true`, which
-- overlays treesitter and produces two-tone import strings (yellow quotes +
-- blue path). That same init_option also drives a workaround in the extra
-- that force-installs a semanticTokensProvider on the client, so this is the
-- one field that actually turns the behavior off. LazyVim deep-merges opts,
-- so `false` here overrides the extra's `true`.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          init_options = {
            semanticTokens = false,
          },
        },
      },
    },
  },
}
