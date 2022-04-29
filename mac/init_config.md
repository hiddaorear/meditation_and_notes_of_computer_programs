[[toc]]

# 1. homebrew 安装443问题

通过配置.bash_profile文件：
1. 从终端进入当前用户目录
 `cd ~` 

2. 编辑： `vi .bash_profile` 
3. 更新刚配置的环境变量：
 `source .bash_profile`
 
# 2. 终端

## 2.1 iterm2

- 改终端左侧名：`sudo scutil --set HostName siegel`
- zsh：`brew install zsh`，`echo $SHELL`，`cat /etc/shells`，`chsh -s /bin/zsh`
- iterm2：`brew install --cask iterm2`

## 2.2 oh-my-zsh
- 主题：ys

插件：
`plugins=(git macos zsh-autosuggestions zsh-syntax-highlighting)`

```
# 自动提示插件
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
# 语法高亮插件
git clone git://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

## 2.3 git


### 2.3.1 配置git diff使用vimdiff

```
# 不进入vim
alias gdiff='git --no-pager diff'
# 使用 Beyond Compare 看diff
alias gbc='git difftool --tool=bc3'
# git branch 不进入vim
git config --global pager.branch false
```

```
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global alias.d difftool
```



# 3. 抓包

- whistle

# 4. 输入法

- rime


# 5. 开发工具

## 5.1 idea

- 主题：Solarized
- UI：Rainbow Brackets
- 编辑：IdeaVim
- 补全：Tabnine
- 拼写检查：Grazie
- 代码跳转：AceJump

常用IDE

- VSCode
- Sublime
- vim：`brew install macvim`，`alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'`

# 6. 办公

- 微软全家桶

# 7. iOS开发环境


# 8. 字体

Inconsolata：


```
$ brew tap homebrew/cask-fonts         # You only need to do this once!
$ brew install font-inconsolata
```



# 附录

## 1. 精简vim 配置

```
" base
set nocompatible
syntax on
set showmode
set showcmd
set mouse=a
set t_Co=256

" encoding
set encoding=utf-8
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1

" tab
set tabstop=2
set shiftwidth=4
set expandtab
set softtabstop=2
set autoindent
set smarttab

" UI
set number
set relativenumber
set cursorline
set linebreak
set wrapmargin=2
set scrolloff=5
set sidescrolloff=15
set ruler
autocmd InsertLeave * se nocul
autocmd InsertEnter * se cul
set fillchars=vert:/
set fillchars=stl:/
set fillchars=stlnc:/
set guifont=Fira\ Code:h18

" search
set autoindent
set hlsearch
set incsearch
set ignorecase
set smartcase

" editing
setlocal spell spelllang=en_us,cjk
set nobackup
set noswapfile
set undofile
set backupdir=~/.vim/.backup//
set directory=~/.vim/.swp//
set undodir=~/.vim/.undo//
set autochdir
set noerrorbells
set visualbell
set history=1000
set autoread
set list " 列表选项，显示行尾字符($)和未扩展标签(^I)，行尾空白
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·
set wildmenu
set wildmode=longest:list,full
set clipboard=unnamed

" leader
let mapleader = "\<space>"
nnoremap <leader>s :%s/\s\+$//<cr>:let @/=''<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

```

