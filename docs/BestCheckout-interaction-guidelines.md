# BestCheckout 原型交互通则

从 BestCheckout 原型抽象的可复用交互原则, **不含业务规则**.  
已按表面拆成两份, 避免后台与编辑器混写.

| 文档 | 覆盖 |
|---|---|
| [后台交互通则](./BestCheckout-interaction-guidelines-admin.md) | Shell、列表、表单、弹窗、Settings、订单 / 订阅等 Admin 页 |
| [编辑器交互通则](./BestCheckout-interaction-guidelines-editor.md) | Checkout / Thank you 装修、主题编辑器全屏工作台、Dirty / Publish / 预览分层 |

## 共用底线 (两篇都遵守)

1. 源文案英文; 中文靠 runtime i18n; 专有名 `i18n-skip`.
2. 商家语言, 不暴露 shop_id / schema / webhook / 队列等实现细节.
3. 色义一致: 绿成功、橙关注、红危险、灰中性、蓝信息.
4. 具体上限、互斥、检测与事件映射写在 PRD / 验收文档, 不写进交互通则.

## 怎么选

- 改 Overview、Orders、Ad data、员工列表、连接 Shopify → 只读 **后台** 篇.
- 改结账页三栏装修、Save / Discard / Publish、画布预览 → 只读 **编辑器** 篇.
- 从 Pages 点进装修再 Exit 回库 → 两篇衔接: 列表属后台, 工作台属编辑器.

## 修订

| 版本 | 日期 | 说明 |
|---|---|---|
| V1.0 | 2026-11-17 | 首版合并通则 |
| V1.1 | 2026-11-17 | 拆成后台 / 编辑器两篇; 本文件改为索引 |
