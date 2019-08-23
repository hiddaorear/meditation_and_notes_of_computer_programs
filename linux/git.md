# git

## 回退的操作

### 简单回退

#### 修改错误的提交消息

`git commit --amend`

#### 修改错误的分支名

`git branch -m wrong-branch right-branch`

如果已推送到远程，先删除再推送。

`git push origin --delete wrong-branch`

`git push origin right-branch`

#### 不小心在主分支修改

已提交的情况下，先切换到新分支，然后回退主分支。

依据当前分支新建分支：`git branch feature-branch`

粗暴回退主分支：`git reset HEAD~ --hard`。缺点，主分支一般作为公共分支，此时其他人可能拉取代码了并修改了。这样回退本地之后，应该是不能正常push到远程的，需要`--force`。作为私有的个人分支，这样处理没问题。

好一点的回退办法：`git revert HEAD~`。好处，不会重写历史，用在公共分支比较友好。

如果没有提交，可以直接切换到新分支，在新分支commit即可。

## 常见问题

### Windows和Linux文件行尾格式问题

crlf 为win风格换行符，lf为unix风格。

全局`git config --global core.autocrlf`

项目内`git config --local core.autocrlf`

`core.autocrlf = true/input/false`解释
`core.autocrlf = true` 提交变为lf，checkout时变为crlf
`core.autocrlf = input`提交变为lf，checkout时不变化
`core.autocrlf = false` 都不变化

如果你是windows电脑推荐用core.autocrlf = true，但是在ide的支持下，用 core.autocrlf = input 也可以让仓库保持干净

### 对大小写不敏感

修改文件的大小写之后，git不会感知。可以想办法绕过，如，project修改为project1，在修改为Project。


## 常用操作

## commit

### 忽略本地git的校验

最好不要使用，遵循项目规范更好。但遇到特殊情况，使用no-verify比想办法绕过校验要好。

`git commit --no-verify -am 'message'`

## delete

### 远程分支

`git push origin --delete <branchName>`

#### 批量删除远程分支：

`git branch -r | grep 'wang' | xargs -I{} push origin --delete {}`

删除之后查看，需要`git fetch -p`或`git remote prune origin`。否则，本地运行`git branch -r`还可以看到已删除的远程分支。

`git branch -a`与`git branch -r`区别：前者包含本地和远程所有分支，后者只有远程分支。

`git push origin :<branchName>`其实是推送一个空分支到远程，相当于删除远程对应的分支。类似tag删除同理。

#### 删除本地存在，远程已经背删除的分支

`git remote prune origin`

### 批量删除本地分支

分支名带wang，养成好习惯，分支带自己名字，管理起来一目了然

`git branch | grep 'wang' | xargs git branch -D`

## diff

### diff master

`git diff
master...`注意是三个点。与两个点的区别：基于master新建分支a，a开发修改代码，master可能也更新了代码。2个点的diff会显示master新增的代码。三个点diff只会显示当前分支与master的最近公共祖先的差异。

### 当前与master对比修改的文件列表

`git diff --name-status HEAD~2 HEAD~3`

## 回退

### revert

#### revert合并的commit

较为特殊，需要有`-m`参数

`git revert --no-commit commitID -m 1`

revert的优点，会在git中留下记录，reset无。这个优点可能带来一些副作用。
假如我们有三个分支A，B和dev（开发主分支），且dev比A有新的commit，dev含有B的commit。切换分支的过程中混淆了，A不应该合并dev分支，但不小心合并了。我们用revert去掉了这个合并的commit。当我们把三者合并到master之后会有问题。会导致dev和B的commit在master上丢失。原因在于我们使用revert去掉dev和B上的commit。

如果切换分支弄混淆，但代码都是正确的。那么我们直接revert之前revert的commit即可。这是在开发过程中遇到的一个场景。

revert一个merge的commit会出现提示：`-m`option。处理，来源[How to revert a merge commit that's already pushed to remote branch?](https://stackoverflow.com/questions/7099833/how-to-revert-a-merge-commit-thats-already-pushed-to-remote-branch)：

The `-m` option specifies the parent number. This is because a merge commit has more than one parent, and Git does not know automatically which parent was the mainline, and which parent was the branch you want to un-merge.

When you view a merge commit in the output of git log, you will see its parents listed on the line that begins with Merge:

``` shell

commit 8f937c683929b08379097828c8a04350b9b8e183
Merge: 8989ee0 7c6b236
Author: Ben James <ben@example.com>
Date:   Wed Aug 17 22:49:41 2011 +0100

Merge branch 'gh-pages'

Conflicts:
    README

```

In this situation, `git revert 8f937c6 -m 1` will get you the tree as it was in `8989ee0`, and git revert `-m` 2 will reinstate the tree as it was in `7c6b236`.

To better understand the parent IDs, you can run:

``` shell
git log 8989ee0
```
and

``` shell
git log 7c6b236
```

## search

### blame

#### 查看代码作者

`git blame ./app.js| grep -C 3 --color=auto 'code'`

### show

#### 查看某个提交的修改

`git show COMMIT`

## remote

### git 远程强制覆盖本地文件

`git fetch --all`

`git reset --hard origin/master`

OR:

`git reset --hard origin/<branch_name>`

## 细枝末节

### 禁用mac终端输入git branch进入编辑器

`git config --global core.pager mor`

## tig

[颠覆 Git 命令使用体验的神器 -- tig](https://www.jianshu.com/p/e4ca3030a9d5)

移动的键位和vim一样

@可以按照代码块粒度浏览commit内容

t(tree)可以文件列表

b(blame)显示文件的blame

Cmd-f 搜索，/也可以搜索
