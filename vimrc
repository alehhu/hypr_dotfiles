" Enable the syntax highlight mode if available
syntax sync fromstart
if has("syntax")
	syntax sync fromstart
	syntax on
        set background=dark
	let php_sync_method="0"
        highlight SpellBad ctermfg=red ctermbg=black term=Underline
endif


set softtabstop=4
set shiftwidth=4
set expandtab
set incsearch
set ignorecase
set smartcase
set ruler
set showmode
set viminfo=%,'50,\"100,:100,n~/.viminfo
set autoindent
set backspace=2

" When open a new file remember the cursor position of the last editing
if has("autocmd")
        " When editing a file, always jump to the last cursor position
        autocmd BufReadPost * if line("'\"") | exe "'\"" | endif
endif

let loaded_matchparen = 1   " Avoid the loading of match paren plugin

vmap q <gv
vmap <TAB> >gv

" Colors
" :hi Comment term=bold ctermfg=Cyan ctermfg=#80a0ff
