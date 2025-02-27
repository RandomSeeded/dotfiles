set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" VIM-PLUG
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Initialize plugin system
call plug#end()


" VUNDLE
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
" Plugin 'mileszs/ack.vim'
" Plugin 'leafgarland/typescript-vim'
Plugin 'tpope/vim-fugitive'
" Plugin 'itchyny/lightline.vim'
Plugin 'tpope/vim-surround'
" Plugin 'fatih/vim-go'
Plugin 'tpope/vim-unimpaired'
" Plugin 'mdempsky/gocode'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-commentary'
" Plugin 'MaxMEllon/vim-jsx-pretty'
" Plugin 'suy/vim-context-commentstring'
Bundle 'OmniSharp/omnisharp-vim'
" Plugin 'chiel92/vim-autoformat'
" Plugin 'dracula/vim', { 'name': 'dracula' }
" Plugin 'kaicataldo/material.vim'
" Plugin 'jonstoler/werewolf.vim'
" Plugin 'hzchirs/vim-material'
" Plugin 'neoclide/coc.nvim'
" Plugin 'shougo/echodoc.vim'
Plugin 'w0rp/ale'
" Bundle 'sainnhe/everforest'

" polyglot can cause issues if not plugged last
" Plugin 'sheerun/vim-polyglot'
" let g:polyglot_disabled = ['go']


" let g:lightline = {
" \ 'colorscheme': 'dracula',
" \ }

" you may want to set up youcompleteme instead of tsuquyomi (typescript
" version only)
Plugin 'quramy/tsuquyomi'

" disable indentation from typescript-vim
let g:typescript_indent_disable = 1

" Ack.vim
let g:ack_use_cword_for_empty_search = 1

" Ack.vim -> ripgrep
let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'

" Ack.vim -> silver searcher
" if executable('ag')
"   let g:ackprg = 'ag --vimgrep'
" endif

cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>

" Find file
nmap <C-p> :GFiles<CR>
" Find tag under cursor - aka find definition
" nmap ; :call fzf#vim#tags(expand('<cword>'), {'options': '--exact --select-1 --exit-0'})<CR>
" nmap ; :call fzf#vim#grep('git grep --line-number -- '.expand('<cword>'), {'options': '--exact --select-1 --exit-0'})<CR>
" nmap ; :call fzf#vim#tags(expand('<cword>'), {'options': '--exact --exit-0'})<CR>
map <C-k> :Ack "<cword>"<CR>
" nmap ; :call fzf#vim#grep('git grep --line-number -- '.expand('<cword>'), {'options': '--exact --select-1 --exit-0'})<CR>
nmap ; :Currwordsearch <c-r><c-w><CR>
" Ref: https://github.com/junegunn/fzf.vim/issues/346
" fzf ignores filenames when checking grep matches
command! -bang -nargs=* Currwordsearch call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --with-filename ".<q-args>, 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
" Ref: https://dev.to/iggredible/how-to-search-faster-in-vim-with-fzf-vim-36ko
" Set ripgrep as default vimgrep
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" command! -bang -nargs=* Rg call fzf#vim#with_preview("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
" command! -bang -nargs=* Rg call fzf#vim#grep(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

nmap \x :cclose<CR> :pclose<CR>
" TODO (nw): figure out a good way to do this
" nmap \r :!tmux send-keys -t 0:0.1 C-p C-j <CR><CR>

" Go-specific hotkeys
" autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>ta  <Plug>(go-test)
autocmd FileType go nmap <leader>tf  <Plug>(go-test-func)
" autocmd FileType go nmap <leader>tc  <Plug>(go-test-compile)
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

" some CoC settings
autocmd FileType typescript nmap <leader>i :CocCommand tsserver.organizeImports<cr>
autocmd FileType typescriptreact nmap <leader>i :CocCommand tsserver.organizeImports<cr>
command! -nargs=0 Prettier :CocCommand prettier.formatFile
autocmd FileType typescriptreact vmap <leader>f <Plug>(coc-format-selected)<CR>
autocmd FileType typescriptreact nmap <leader>f <Plug>(coc-format-selected)<CR>


let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 
autocmd BufNewFile,BufRead *.cs setlocal noexpandtab tabstop=4 shiftwidth=4 

" set completeopt-=preview

if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
    set t_ut=
endif

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" URL: http://vim.wikia.com/wiki/Example_vimrc
" Authors: http://vim.wikia.com/wiki/Vim_on_Freenode
" Description: A minimal, but feature rich, example .vimrc. If you are a
"              newbie, basing your first .vimrc on this file is a good choice.
"              If you're a more advanced user, building your own .vimrc based
"              on this file is still a good idea.
 
"------------------------------------------------------------
" Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.
 
" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible
 
" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on
 
" Enable syntax highlighting
syntax on
 
 
"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.
 
" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden
 
" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall
set autowrite
 
" Better command-line completion
set wildmenu
 
" Show partial commands in the last line of the screen
set showcmd
 
" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch
 
" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline
 
 
"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.
 
" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase
 
" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start
 
" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
 
" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline
 
" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler
 
" Always display the status line, even if only one window is displayed
set laststatus=2
 
" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm
 
" Use visual bell instead of beeping when doing something wrong
set visualbell
 
" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=
 
" Enable use of the mouse for all modes
set mouse=a
 
" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2
 
" Display line numbers on the left
set number
 
" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200
 
" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>
 
 
"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.
 
" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=2
set softtabstop=2
set expandtab
 
" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
" set shiftwidth=4
" set tabstop=4
 
 
"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings
 
" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$
 
nnoremap \q :nohl<CR><C-L>
 
"------------------------------------------------------------
" Custom below

" Badwolf color setup
" Get iTerm to play nicely with custom colorschemes
set t_Co=256
color badwolf

" Dracula color setup
" set termguicolors
" let g:dracula_colorterm = 0
" colorscheme dracula

" Material themes
set termguicolors
let g:material_theme_style = 'ocean'
" colorscheme material

let g:everforest_background = 'hard'

function Light()
  set background=light
  colorscheme everforest
endfunction
function Dark()
  set background=dark
  colorscheme material
endfunction
command Light :call Light()
command Dark :call Dark()


" Toggle color schemes based on time of day
" let g:werewolf_day_themes = ['badwolf']
" let g:werewolf_night_themes = ['material']
" let g:werewolf_day_start = 11
" let g:werewolf_day_end = 16


" set termguicolors
" let g:material_style='oceanic'
" set background=dark
" colorscheme vim-material

" set termguicolors
" let g:material_style='palenight'
" set background=dark
" colorscheme vim-material

" ctrlp
" set runtimepath^=~/.vim/bundle/ctrlp.vim
" let g:ctrlp_user_command = 'find %s -type f | grep -v "`cat .ctrlpignore`"'

" Get vim to play nicely with git (autoreload when git has changed files)
au FocusGained,BufEnter * :silent! !
au FocusLost,WinLeave * :silent! w

" Auto-fmt and save
function! s:CBCodeFormat() abort
  noautocmd write
  set nomodified
endfunction
autocmd BufWritePre *.cs call OmniSharp#actions#format#Format(function('s:CBCodeFormat'))

" Smarter way to move between panes
map <left> <C-w><left>
map <right> <C-w><right>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Prevent swap files from messing with linters
" set backupdir=~/.vim/backup//
" set directory=~/.vim/swap//
" set undodir=~/.vim/undo//

" Pathogen
" execute pathogen#infect()

" Syntastic settings
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_jshint_exec='usr/local/bin/jshint'

" set wildignore=*/venv/*,*/coverage/*,*/vendor/*,*/bower_components/*,*/dev/*,*/node_modules/*,*.o,*.xml,*.svg,*.yml,*.pyc,*.woff,*.woff2,*.ttf,*.jpeg,*.eot,*.dist,*~      " Ignore temp files in wildmenu
" included yml again
" set wildignore=*/venv/*,*/coverage/*,*/vendor/*,*/bower_components/*,*/dev/*,*/node_modules/*,*.o,*.xml,*.svg,*.pyc,*.woff,*.woff2,*.ttf,*.jpeg,*.eot,*.dist,*~      " Ignore temp files in wildmenu


" Omnisharp settings

" Tell ALE to use OmniSharp for linting C# files, and no other linters.
" let g:ale_linters = { 'cs': ['OmniSharp'] }

let g:OmniSharp_timeout=60
let g:OmniSharp_server_loading_timeout = 60

augroup omnisharp_commands
  autocmd!

  " Show type information automatically when the cursor stops moving.
  " Note that the type is echoed to the Vim command line, and will overwrite
  " any other messages in this space including e.g. ALE linting messages.
  autocmd CursorHold *.cs OmniSharpTypeLookup

  " The following commands are contextual, based on the cursor position.
  autocmd FileType cs nmap <silent> <buffer> gd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfu <Plug>(omnisharp_find_usages)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfi <Plug>(omnisharp_find_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospd <Plug>(omnisharp_preview_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospi <Plug>(omnisharp_preview_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ost <Plug>(omnisharp_type_lookup)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osd <Plug>(omnisharp_documentation)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfx <Plug>(omnisharp_fix_usings)
  autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
  autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)

  " Navigate up and down by method/property/field
  autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
  autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
  " Find all code errors/warnings for the current solution and populate the quickfix window
  autocmd FileType cs nmap <silent> <buffer> <Leader>osgcc <Plug>(omnisharp_global_code_check)
  " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  " Repeat the last code action performed (does not use a selector)
  autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
  autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)

  autocmd FileType cs nmap <silent> <buffer> <Leader>os= <Plug>(omnisharp_code_format)

  autocmd FileType cs nmap <silent> <buffer> <Leader>osnm <Plug>(omnisharp_rename)

  autocmd FileType cs nmap <silent> <buffer> <Leader>osre <Plug>(omnisharp_restart_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osst <Plug>(omnisharp_start_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ossp <Plug>(omnisharp_stop_server)

augroup END

" OmniSharp: {{{
let g:OmniSharp_popup_position = 'peek'
  let g:OmniSharp_popup_options = {
  \ 'winhl': 'Normal:NormalFloat'
  \}

" :let g:OmniSharp_server_use_mono = 1
let g:OmniSharp_server_use_net6 = 1

set cmdheight=2
let g:echodoc_enable_at_startup = 1

" ALE
nmap <silent> <Leader>aj <Plug>(ale_previous_wrap)
nmap <silent> <Leader>ak <Plug>(ale_next_wrap)

" Comment
let g:tcomment#filetype#guess_typescriptreact = 1

command CopyCWD let @+=expand('%:p:h')
