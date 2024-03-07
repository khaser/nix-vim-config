{ pkgs, neovim, extraPlugins ? [], extraRC ? "", sway-vim-kbswitch }:
neovim.override {
  vimAlias = true;
  configure = {
    packages.myPlugins = with pkgs.vimPlugins; {
      start = extraPlugins ++ [
        vim-lastplace
        vim-nix
        nerdtree
        vim-commentary
        vim-surround
        auto-pairs
        rainbow # colored pairs
        vim-wayland-clipboard
        vim-airline
        gruvbox-nvim
        vim-markdown
      ];
      opt = [];
    };
    customRC =
      ''
        " Evade leaving insert mode on layout switching
        inoremap <D-Space> <nop>
        noremap! <D-Space> <nop>

        " LAYOUT

        " libswaykbswitch get socket name by SWAYSOCK env variable
        let g:XkbSwitch = {
        \ 'backend': '${sway-vim-kbswitch}/lib/libswaykbswitch.so',
        \ 'get':     'Xkb_Switch_getXkbLayout',
        \ 'set':     'Xkb_Switch_setXkbLayout',
        \ }

        let s:default_layout = "English (US)"
        let s:saved_layout = s:default_layout

        fun! s:set_layout(layout)
            if empty(a:layout)
                return
            endif
            call libcall(g:XkbSwitch['backend'], g:XkbSwitch['set'], a:layout)
        endfun

        fun! s:restore_cur_layout()
            call s:set_layout(s:saved_layout)
        endfun

        fun! s:store_cur_layout()
            let s:saved_layout = libcall(g:XkbSwitch['backend'], g:XkbSwitch['get'], "")
            sleep 500m
            call s:set_layout(s:default_layout)
        endfun

        au InsertLeave * call s:store_cur_layout()
        au InsertEnter * call s:restore_cur_layout()

        " APPEARANCE
        colorscheme gruvbox
        set bg=dark
        set listchars=tab:··
        set list
        set number
        set nowrap
        set colorcolumn=140
        highlight ColorColumn ctermbg=darkgray
        let g:airline#extensions#whitespace#checks = [ 'indent', 'long', 'mixed-indent-file', 'conflicts' ]
        let g:rainbow_active = 1

        " trailing spaces highlighting
        highlight ExtraWhitespace ctermbg=red guibg=red
        match ExtraWhitespace /\s\+$/
        autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
        autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
        autocmd InsertLeave * match ExtraWhitespace /\s\+$/
        autocmd BufWinLeave * call clearmatches()

        " by default remove trailing spaces, it can be redefined by dev-env
        augroup trailing | autocmd BufWritePre * :%s/\s\+$//e | augroup END

        " SEARCH
        set nohls
        set incsearch
        set ignorecase
        set showmatch

        " INDENT
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set smarttab
        set cindent
        set cino=g0,L0,N-s

        " AUTOSAVE
        set autowriteall
        autocmd FocusLost * silent! wa
        set noswapfile

        " MACRO
        map <silent> <C-n> :NERDTreeToggle<CR>
        nmap <silent> <C-l> :tabnext <CR>
        nmap <silent> <C-h> :tabprevious <CR>

        " PLUGINS
        let NERDTreeQuitOnOpen = 1
        let g:AutoPairsMultilineClose = 0
        let g:airline#extensions#ycm#enabled = 1

        " SPELLING
        hi clear SpellBad
        hi SpellBad cterm=underline ctermfg=red guifg=red gui=underline
        set spelllang=en_us,ru
        set spell
        let g:airline_detect_spelllang=0

        let g:netrw_browsex_viewer= "firefox"

        " Markdown
        au filetype markdown set wrap
        au filetype markdown set conceallevel=2
        let g:vim_markdown_conceal=1
        let g:vim_markdown_toc_autofit = 1

        ${extraRC}
    '';
  };
}
