filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
" Automatically remove all trialing whitespace when saving
autocmd FileType c,cpp,py,C autocmd BufWritePre <buffer> %s/\s\+$//e
" Change comment color
" hi Comment ctermfg=6 "the light blue clashes with xml and python keywords
hi Comment ctermfg=3
" Highlight current line
hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
" Do not move through document while typing search string
set incsearch
