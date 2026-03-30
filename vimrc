" --- Basic Display Settings ---
syntax on            " Enable syntax highlighting
filetype plugin indent on " Enable language-specific plugins and indentation
set number           " Show line numbers
set relativenumber   " Show relative line numbers for easier jumping
set background=dark  " Use dark background
set ruler            " Show cursor position
set showmode         " Show current mode
set shortmess+=I     " Quiet start (hide intro message)
set mouse=a          " Enable mouse support in all modes

" --- Indentation (4 spaces) ---
set tabstop=4        " Number of visual spaces per TAB
set softtabstop=4    " Number of spaces in tab when editing
set shiftwidth=4     " Number of spaces to use for autoindent
set expandtab        " Use spaces instead of tabs
set autoindent       " Copy indent from current line when starting a new line
set smartindent      " Do smart autoindenting when starting a new line
set cindent          " Enable specific indentation for C-style languages

" --- Coding & Comments ---
set formatoptions+=r " Auto-insert comment leader after hitting <Enter>
set formatoptions+=o " Auto-insert comment leader after hitting 'o' or 'O'
set formatoptions+=j " Delete comment leader when joining lines (J)

" --- Search Settings ---
set hlsearch         " Highlight all search matches
set incsearch        " Show matches incrementally as you type
set ignorecase       " Ignore case in search patterns
set smartcase        " Override ignorecase if search contains uppercase

" --- Modern Features ---
set clipboard=unnamedplus " Use system clipboard
set undofile              " Enable persistent undo
set backspace=indent,eol,start " Make backspace work as expected

" --- Custom Logic & Keybindings ---
" Remember cursor position of the last editing
if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Custom mappings
vmap q <gv
vmap <TAB> >gv

" Disable matching parentheses plugin (per existing config)
let loaded_matchparen = 1

" PHP-specific sync (per existing config)
let php_sync_method="0"
syntax sync fromstart

" Spell check highlighting
highlight SpellBad ctermfg=red ctermbg=black term=Underline

" --- History & Info ---
set viminfo=%,'50,\"100,:100,n~/.viminfo
