nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-b> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <C-S-f> :Telescope find_files<CR>
autocmd VimEnter * NERDTree
autocmd BufWinEnter * NERDTreeMirror
