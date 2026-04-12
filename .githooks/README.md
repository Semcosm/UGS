# Managed Hooks Directory

该目录是 UGS 仓库的受管理 hooks 目录。

推荐最小 hooks 集：

- `commit-msg`：校验 commit message 结构与 trailers
- `pre-push`：阻止不允许的目标分支推送或脏状态推送
- `pre-receive` 或 `update`：在服务端保护长期分支与发布标签

仓库应通过 `core.hooksPath` 指向该目录。
