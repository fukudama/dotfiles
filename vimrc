" release autogroup in MyAutoCmd
augroup MyAutoCmd
  autocmd!
augroup END

set ignorecase          " 大文字小文字を区別しない
set smartcase           " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索マッチテキストをハイライト

set expandtab
set tabstop=2
"set softtabstop=2

set smartindent
set shiftwidth=2

" バックスラッシュやクエスチョンを状況に合わせ自動的にエスケープ
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

set shiftround          " '<'や'>'でインデントする際に'shiftwidth'の倍数に丸める
set infercase           " 補完時に大文字小文字を区別しない
"set virtualedit=all     " カーソルを文字が存在しない部分でも動けるようにする
set hidden              " バッファを閉じる代わりに隠す（Undo履歴を残すため）
set switchbuf=useopen   " 新しく開く代わりにすでに開いてあるバッファを開く
set showmatch           " 対応する括弧などをハイライト表示する
set matchtime=3         " 対応括弧のハイライト表示を3秒にする

" 対応括弧に'<'と'>'のペアを追加
set matchpairs& matchpairs+=<:>

" バックスペースでなんでも消せるようにする
set backspace=indent,eol,start

" クリップボードをデフォルトのレジスタとして指定。後にYankRingを使うので
" 'unnamedplus'が存在しているかどうかで設定を分ける必要がある
if has('unnamedplus')
    " set clipboard& clipboard+=unnamedplus " 2013-07-03 14:30 unnamed 追加
    set clipboard& clipboard+=unnamedplus,unnamed 
else
    set clipboard& clipboard+=unnamed
endif

" Swapファイル？Backupファイル？前時代的すぎ
" なので全て無効化する
set nowritebackup
set nobackup
set noswapfile

"set list                " 不可視文字の可視化
set number              " 行番号の表示
set wrap                " 長いテキストの折り返し
set textwidth=0         " 自動的に改行が入るのを無効化
set colorcolumn=80      " その代わり80文字目にラインを入れる

" 前時代的スクリーンベルを無効化
set t_vb=
set novisualbell

" デフォルト不可視文字は美しくないのでUnicodeで綺麗に
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲

" 入力モード中に素早くjjと入力した場合はESCとみなす
inoremap jj <Esc>

" ESCを二回押すことでハイライトを消す
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" カーソル下の単語を * で検索
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v, '\/'), "\n", '\\n', 'g')<CR><CR>

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" j, k による移動を折り返されたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk

" vを二回で行末まで選択
vnoremap v $h

" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" Ctrl + hjkl でウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" T + ? で各種設定をトグル
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :setl spell!<CR>:setl spell?<CR>
nnoremap <silent> [toggle]l :setl list!<CR>:setl list?<CR>
nnoremap <silent> [toggle]t :setl expandtab!<CR>:setl expandtab?<CR>
nnoremap <silent> [toggle]w :setl wrap!<CR>:setl wrap?<CR>

" make, grep などのコマンド後に自動的にQuickFixを開く
autocmd MyAutoCmd QuickfixCmdPost make,grep,grepadd,vimgrep copen

" QuickFixおよびHelpでは q でバッファを閉じる
autocmd MyAutoCmd FileType help,qf nnoremap <buffer> q <C-w>c

" w!! でスーパーユーザーとして保存（sudoが使える環境限定）
cmap w!! w !sudo tee > /dev/null %

" :e などでファイルを開く際にフォルダが存在しない場合は自動作成
function! s:mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" vim 起動時のみカレントディレクトリを開いたファイルの親ディレクトリに指定
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction

" ~/.vimrc.localが存在する場合のみ設定を読み込む
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
    execute 'source ' . s:local_vimrc
endif


" NeoBundleの設定
let s:noplugin = 0
let s:bundle_root = expand('~/.vim/bundle')
let s:neobundle_root = s:bundle_root . '/neobundle.vim'
if !isdirectory(s:neobundle_root) || v:version < 702
    " NeoBundleが存在しない、もしくはVimのバージョンが古い場合はプラグインを
    " 読み込まない
    let s:noplugin = 1
else
    " NeoBundleを'runtimepath'に追加し初期化を行う
    if has('vim_starting')
        execute "set runtimepath+=" . s:neobundle_root
    endif

    " Required:
    call neobundle#begin(expand(s:bundle_root))

    " NeoBundle自身をNeoBundleで管理させる
    NeoBundleFetch 'Shougo/neobundle.vim'

    " 非同期通信を可能にする
    " 'build'が指定されているのでインストール時に自動的に
    " 指定されたコマンドが実行され vimproc がコンパイルされる
    NeoBundle "Shougo/vimproc", {
        \ "build": {
        \   "windows"   : "make -f make_mingw32.mak",
        \   "cygwin"    : "make -f make_cygwin.mak",
        \   "mac"       : "make -f make_mac.mak",
        \   "unix"      : "make -f make_unix.mak",
        \ }}

    " neocomplete設定
    " 次に説明するがInsertモードに入るまではneocompleteはロードされない
    NeoBundleLazy 'Shougo/neocomplete.vim', {
        \ "autoload": {"insert": 1}}
    " neocompleteのhooksを取得
    let s:hooks = neobundle#get_hooks(s:bundle_root . "neocomplete.vim")
    " neocomplete用の設定関数を定義。下記関数はneocompleteロード時に実行される
    function! s:hooks.on_source(bundle)
        let g:acp_enableAtStartup = 0
        let g:neocomplete#enable_smart_case = 1
        " NeoCompleteを有効化
        NeoCompleteEnable
    endfunction 

    NeoBundle "thinca/vim-template"
    " テンプレート中に含まれる特定文字列を置き換える
    autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
    function! s:template_keywords()
        silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
        silent! %s/<+FILENAME+>/\=expand('%:r')/g
    endfunction
    " テンプレート中に含まれる'<+CURSOR+>'にカーソルを移動
    autocmd MyAutoCmd User plugin-template-loaded
        \   if search('<+CURSOR+>')
        \ |   silent! execute 'normal! "_da>'
        \ | endif

    NeoBundleLazy "Shougo/unite.vim", {
          \ "autoload": {
          \   "commands": ["Unite", "UniteWithBufferDir"]
          \ }}
    NeoBundleLazy 'h1mesuke/unite-outline', {
          \ "autoload": {
          \   "unite_sources": ["outline"],
          \ }}
    nnoremap [unite] <Nop>
    nmap U [unite]
    nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
    nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
    nnoremap <silent> [unite]r :<C-u>Unite register<CR>
    nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
    nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
    nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
    nnoremap <silent> [unite]t :<C-u>Unite tab<CR>
    nnoremap <silent> [unite]w :<C-u>Unite window<CR>
    let s:hooks = neobundle#get_hooks(s:bundle_root . "unite.vim")
    function! s:hooks.on_source(bundle)
      " start unite in insert mode
      let g:unite_enable_start_insert = 1
      " use vimfiler to open directory
      call unite#custom_default_action("source/bookmark/directory", "vimfiler")
      call unite#custom_default_action("directory", "vimfiler")
      call unite#custom_default_action("directory_mru", "vimfiler")
      autocmd MyAutoCmd FileType unite call s:unite_settings()
      function! s:unite_settings()
        imap <buffer> <Esc><Esc> <Plug>(unite_exit)
        nmap <buffer> <Esc> <Plug>(unite_exit)
        nmap <buffer> <C-n> <Plug>(unite_select_next_line)
        nmap <buffer> <C-p> <Plug>(unite_select_previous_line)
      endfunction
    endfunction

    NeoBundleLazy "davidhalter/jedi-vim", {
          \ "autoload": {
          \   "filetypes": ["python", "python3", "djangohtml"],
          \ },
          \ "build": {
          \   "mac": "pip install jedi",
          \   "unix": "pip install jedi",
          \ }}
    let s:hooks = neobundle#get_hooks(s:bundle_root . "jedi-vim")
    function! s:hooks.on_source(bundle)
      " jediにvimの設定を任せると'completeopt+=preview'するので
      " 自動設定機能をOFFにし手動で設定を行う
      let g:jedi#auto_vim_configuration = 0
      " 補完の最初の項目が選択された状態だと使いにくいためオフにする
      let g:jedi#popup_select_first = 0
      " quickrunと被るため大文字に変更
      let g:jedi#rename_command = '<Leader>R'
      " gundoと被るため大文字に変更 (2013-06-24 10:00 追記）
      " let g:jedi#goto_command = '<Leader>G'
      let g:jedi#goto_assignments_command = '<Leader>G'
    endfunction

    call neobundle#end()

    " インストールされていないプラグインのチェックおよびダウンロード
    NeoBundleCheck
endif

" ファイルタイププラグインおよびインデントを有効化
" これはNeoBundleによる処理が終了したあとに呼ばなければならない
filetype plugin indent on


autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0

if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
endif

" let g:neocomplete#force_omni_input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
let g:neocomplete#force_omni_input_patterns.python = '\h\w*\|[^. \t]\.\w*'

syntax on

"行末のスペースを削除する
autocmd BufWritePre *.py,*.cpp,*.hpp,*.c,*.h,*.php,*.tpl,*.sh,*.html :%s/\s\+$//ge
""行末のスペースをハイライトする
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/
autocmd WinEnter * match WhitespaceEOL /\s\+$/
