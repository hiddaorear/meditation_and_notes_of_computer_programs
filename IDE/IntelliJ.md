# IntelliJ使用

## 常用快捷键

- 打开Terminal：`Alt+F12`

### refactor

- `shift-F6`rename

## 插件快捷键

### 搜索

- `按两次Shift` 搜索
- `Command-Shift-F` 全局搜索
- `Command-Shift-R` 全局替换

### 文件浏览

- `Command-E` 最近浏览的文件。类似于vim的缓冲区

### AceJump

- `Ctrl-;`

### 书签

- `F3` 加书签
- `Command-Shift-数字` 快速创建数字书签；再次在同一行使用，取消书签
- `Ctrl-数字` 快速跳转到数字书签
- `Command-F3` 显示书签

### 查看方法或函数信息

- `Command-p` Parameter info (within method call arguments)
- 'Command-F7' Find usages(在当前项目中的使用情况，会打开一个使用情况面板)
- `Command-Alt-F7` Show usages(打开使用情况列表)

### 复制、粘贴

- `Command-Shift-v` 剪切或拷贝的代码历史记录中，选择粘贴的内容

### 窗口控制

- `Commonad-1` 左侧project开关

## 自定义快捷键

``` vimscript

let mapleader = " "

map <leader>s :action SaveAll<CR>

" AceJump {{
" Press `j` to activate AceJump
 map <Leader>j :action AceAction<CR>
" Press `q` to activate Target Mode
 map <Leader>q :action AceTargetAction<CR>
" Press `g` to activate Line Mode
 map <Leader>g :action AceLineAction<CR>
" }}



```

## 插件

- acejump/AceJump

- IdeaVim(.ideavimrc 配置见vim项目)

- Material Theme UI

- Rainbow Brackets



### 参考链接：

[Spacemacs/Space-Vim Config for Jetbrain IDEs](https://ztlevi.github.io/posts/The-Minimal-Spacemacs-Tweaks-for-Jetbrain-IDES/)

[IntelliJ IDEA 简体中文专题教程](https://github.com/judasn/IntelliJ-IDEA-Tutorial)

[IntelliJ IDEA 使用教程(2019图文版) -- 从入门到上瘾](https://www.jianshu.com/p/9c65b7613c30)
