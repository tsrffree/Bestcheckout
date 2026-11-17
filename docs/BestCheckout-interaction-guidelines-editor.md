# BestCheckout 编辑器交互通则

全屏 / 工作台式装修与预览的交互原则. 不含业务规则 (如某区块字段、互斥逻辑).  
商家后台列表、设置、弹窗见 [后台交互通则](./BestCheckout-interaction-guidelines-admin.md).  
总入口见 [交互通则索引](./BestCheckout-interaction-guidelines.md).

适用面: Checkout / Thank you 装修 (`bestcheckout/js/design.js`)、Online Store / Checkout 主题编辑器 (`online-store/js/app.js`)、从 Pages / Flows 进入的全屏编辑工作台.  
Purchase flow 画布若以全屏工作台承载, 顶栏 Dirty / Exit 约定与本篇对齐; 画布节点业务规则仍写在 PRD.

---

## 1. 总则

1. **编辑器是独立工作台.** 进入后覆盖或离开常规 Admin 内容区; 不在编辑器内再嵌一套侧栏业务导航.
2. **退出有去处.** Exit / Back 回到页面库、Flow 或进入时的 `return` / `from` 来源.
3. **工作副本与已保存态分离.** 画布可反映未保存编辑; 对外「已保存 / 已发布预览」不掺未保存草稿 (主题编辑器约定).
4. **文案与色义跟后台一致.** 英文源文案、i18n-skip、pill / 按钮层级沿用 [后台通则](./BestCheckout-interaction-guidelines-admin.md) 第 4–5、11、13 节.
5. **不把 BestShopio 控件细则默认为本仓规范.** 色板 T、富文本工具栏等以 `bestshopio-merchant` rules 为准; 本仓只要求工作台骨架与保存门禁对齐.

---

## 2. 工作台骨架

| 区域 | 约定 |
|---|---|
| 顶栏 | 退出、标题 / 上下文、设备切换、Discard / Save; 需上线时再加 Publish |
| 左栏 | 页面结构树 / section·block 列表 |
| 中栏 | 买家向实时预览画布 |
| 右栏 | 当前选中块的 Component Settings |

三栏同时存在; 选中左树节点后右栏展示对应设置, 中栏高亮或即时反映.

窄屏优先保证中栏预览可完成结账向编辑, 左右栏可折叠或保持可滚动, 不另做第三套信息架构.

---

## 3. 顶栏操作

| 操作 | 约定 |
|---|---|
| Exit / Back | 离开工作台; 有未保存变更时先走未保存门禁 (见第 5 节) |
| Discard | 仅 dirty 可点; 放弃工作副本, 回到上次保存 |
| Save | 仅 dirty 可点; 写入草稿 / 已保存态; 忙碌显示 Saving… |
| Publish | 有草稿或 dirty 且校验通过时可点; 有校验问题时可警示 (如 Publish · N) |
| Save as template | 可选; 把当前布局存进页面库, 不替代 Save / Publish |
| 设备切换 | Desktop / Mobile 只改画布视口, 不丢选中与 dirty |

一屏主行动在 Save / Publish 之间按场景取舍: 纯装修草稿以 Save 为主; 需上线时 Publish 为最强 Primary, Save 为次主.

---

## 4. Dirty 与预览

| 状态 | 表现 |
|---|---|
| clean | Discard / Save disabled (或等价不可用) |
| dirty / unsaved | Discard / Save 可点; 可显示 Unsaved changes |
| draft (已保存未发布) | 与 published 区分文案; Publish 可点 |
| busy | 相关按钮 disabled, Saving… / Publishing… |

**预览分层:**

1. **编辑中画布:** 反映当前工作副本 (含未保存).
2. **商家 / 已保存预览:** 只读最近 Save 或已发布快照, 不带未保存改动.
3. **全宽预览:** 可收起编辑铬, 画布仍可按产品约定显示工作副本或已保存态; Esc 退出全宽.

---

## 5. 未保存门禁

切换模板、退出、或会丢掉工作副本的导航时:

- 三键: **Cancel** (留下继续编) / **Discard** / **Save**
- 文案说明须保存或放弃后才能继续
- Cancel 不改数据、不切换目标

后台 Settings 的深色 unsaved bar (Discard + Update) 属后台通则, 不用本三键替代, 也不在普通 Admin 表单滥用三键.

---

## 6. 结构树与设置栏

1. 左树分组清晰 (Header / Body / Sidebar / Footer 等), 与画布区块一一对应.
2. 未选中块时, 右栏给一句引导 (如 Select a block on the left to edit it.).
3. 删除区块: 先确认; 确认后可仍留在会话内, Save 前可用 Discard 撤回, 文案写清.
4. 添加区块: 即时进树与画布, 并选中新块便于接着改设置.
5. 相同控件在不同 block 出现时, 字段能力与交互方式保持一致; 默认值可以不同.

---

## 7. 画布 (买家向预览)

1. 画布看起来像真实站外结账 / Thank you, 而不是 Admin 表格密度.
2. 预览内交互以「可感知真实结账」为度; 不在画布里做后台管理操作.
3. 设备切换不重置商家已填的设置.
4. Flow 画布: 商家先看清业务步骤, 再看图细节; 状态语言与后台 pill 色义一致.

---

## 8. Toast 与确认

- Save / Discard / 删块成功: 短 toast 即可.
- 删块、覆盖模板等: 用 Confirm; Danger 键语义明确 (Delete 等).
- 校验失败: 优先标在右栏字段或 Publish 警示, 必要时再弹窗; 不静默失败.

---

## 9. 与后台的衔接

| 从后台 | 进入编辑器 | 退出回 |
|---|---|---|
| Pages 库 | 某页装修 | Pages 或明确 return |
| Purchase flow | 节点绑定的 Checkout 页编辑 | Flow 画布 / 列表 |
| 其他带 `from=bestcheckout` 的入口 | 全屏编辑 | 解析 query 后的来源 |

链接带 `from` / `return` 时, Exit 必须尊重这些参数, 避免掉回无关首页.

---

## 10. 编辑器自检

- [ ] 三栏骨架完整 (树 / 画布 / 设置)
- [ ] Exit 回到正确来源
- [ ] dirty 时 Discard / Save 可用; clean 时不可用
- [ ] 切模板或退出有未保存门禁
- [ ] 已保存预览不含未保存草稿
- [ ] Desktop / Mobile 不丢编辑态
- [ ] 删块有确认; 文案说明 Discard 可撤
- [ ] 英文源文案; 专有名 skip
- [ ] 未把内部 schema / 实现字段暴露给商家

---

## 11. 不在本篇

- Admin 列表、Settings 渠道卡、普通 Modal → [后台通则](./BestCheckout-interaction-guidelines-admin.md)
- 业务字段、默认值、互斥 → PRD / 验收文档
- BestShopio 色板 / 富文本 / 图片控件像素级规则 → `bestshopio-merchant/.cursor/rules`

---

## 修订

| 版本 | 日期 | 说明 |
|---|---|---|
| V1.0 | 2026-11-17 | 从合并通则拆出编辑器篇 |
