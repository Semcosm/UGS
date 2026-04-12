# Managed Hooks Directory

该目录是本仓库的受管理 hooks 目录。

当前已实现：

- `commit-msg`：校验 UGS commit message 结构与 trailer block
- `pre-push`：校验仓库治理文件、校验 commit SSH 签名、校验等价 CR 记录、阻止脏工作区推送、阻止直接推送 `main`、校验新提交消息、校验正式 release tag 形态

推荐的本地启用方式：

```bash
git config core.hooksPath .githooks
```

`pre-push` 的默认规则：

- 正常情况下拒绝直接推送 `main`
- 所有待推送 commits 必须能通过 `keys/allowed_signers` / `keys/revoked_signers` 的信任校验
- 允许 `UGS_ALLOW_MAIN_PUSH=cr` 在 topic branch 已先行推送、`main` 为 fast-forward 集成、且存在匹配 `Head or Range` 的 `cr/CR-*.md` 记录时完成等价 CR 集成
- 允许 `UGS_ALLOW_MAIN_PUSH=bootstrap` 执行一次治理落地引导推送
- 允许 `UGS_ALLOW_MAIN_PUSH=emergency` 且设置 `UGS_EMERGENCY_REASON` 时执行紧急直推

GitHub 不支持自定义 `pre-receive`，因此本仓库同时使用
`.github/workflows/ugs-validate.yml` 作为远端映射层校验。
