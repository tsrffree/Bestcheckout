<title>数据上报支持 Trybe 渠道</title>

| 版本 | 修订时间 | 修订内容 | 修订人 |
|-|-|-|-|
| V1.0 | 2026.11.15 | 按原型整理 Trybe 渠道配置 PRD, 固化检测 / 手动双态、条数、删除和 Orders API 规则 | 李东杰 |
| V1.1 | 2026.11.16 | 按推荐商品 / PDP PRD 架构重排, 补充功能总览、需求正文表格、验收标准和待补充事项 | 李东杰 |
| V1.2 | 2026.11.16 | 列表移除 Status、Pages 两列, 与广告数据各渠道列表对齐 | 李东杰 |
| V1.3 | 2026.11.16 | 明确 Trybe 三事件: Product Viewed / Add to Cart / Checkout; Checkout 含服务端上报 | 李东杰 |
| V1.4 | 2026.11.16 | 按 Trybe 官方口径: 仅 purchase 映射 Checkout; begin_checkout 无对应 | 李东杰 |
| V1.5 | 2026.11.17 | Orders API 列按原型改为掩码展示, 不再直接展示 key 原文 | 李东杰 |
| V1.6 | 2026.11.18 | 凭证三处分开: 暗提示写完整说明, 输入框展示原文, 列表按支付方式掩码; 输入框常显且非必填 | 李东杰 |

# 1. 概述

## 1.1 背景说明

BestCheckout 广告数据页当前已支持 Meta / GA4 / GTM 的多 ID 列表配置. 本 PRD 在渠道列表下方新增 Trybe 渠道, 让商家能在 BestCheckout 配置结账路径上的 Trybe Pixel 与 Orders API.

Trybe 一般先在 Shopify 安装好, 再来 BestCheckout 配置. 业务流程上, 商家先去 Trybe 下单、关联 Shopify 才能把业务跑起来, 然后再来 BestCheckout.

检测到的 Pixel 是 Trybe 通过链接 Shopify 生成的, 未展示给商家用户, 但可以触发; BestCheckout 可能检测到, 也可能检测不到.

多 Pixel 列表、删除、Primary 等通用规则见: https://bestfulfill.feishu.cn/wiki/QfQhw3lqJiGeWokgRZMcfLiGn1d

### 1.1.1 需求目标

1. 在广告数据页新增 Trybe 渠道卡, 列表交互对齐现有渠道和员工列表.
2. 支持检测到 / 检测不到两种配置路径; 未检测到时用单独表单全部填写.
3. 检测到的 Pixel 保留不可删除; 手动添加后仍支持后续检测到时再展示.
4. Orders API key 只能手动填写, 与全渠道服务端凭证规则一致.
5. 事件表增加 Trybe 列; 结账原型本轮不做修改.

### 1.1.2 范围说明

| 范围 | 本期内容 | 本期不展开 |
|-|-|-|
| 商家后台 | 设置 → 广告数据中的 Trybe 渠道卡、列表、添加 / 编辑、删除边界、事件表 Trybe 列 | 广告效果分析、诊断 Test、批量勾选、把 Trybe 扩到 10 条 |
| 检测与凭证 | 检测 / 未检测双态; 最多 2 条; Orders API key 手动填写; 全渠道服务端凭证仅手动 | 生产检测信号实现细节、保存后一键测试上报 (P1, 可暂缓) |
| 结账 | 不改结账原型; 结账原型给技术和其他关联人了解业务 | 结账页 UI、visitorId / Orders API 字段联调定稿 |

# 2. 功能需求

## 2.1 功能需求总览

| 模块 | 功能 | 功能描述 | 备注 |
|-|-|-|-|
| 入口 | Trybe 渠道卡 | 位于 Meta / GA4 / GTM 下方; 卡片头展示检测状态和 Add Trybe Pixel |  |
| 列表管理 | Trybe 列表 | 展示 Pixel code、Source、Name、Orders API、Action; 对齐员工列表 | 无内容时不展示列表行; 不展示 Status、Pages |
| 条数 | 检测 + 手动 | 算上检测一共两条 (检测 1 + 手动 1); 未检测到则只有一条 | 已有手动行时不可再手动添加 |
| 配置 | 添加 / 编辑 | 未检测用手填 Name + Pixel snippet + Orders API; 检测行可编辑 Name 和 Orders API, Pixel code 只读 | 自定义弹窗见附录截图 |
| 删除 | 分级删除 | 手动行可整行删除; 检测行不可删除 | 检测行若要关服务端, 在编辑里把 Orders API 设为否 |
| 上报 | 事件表 | 增加 Trybe 列; 仅 purchase 映射 Checkout; Product Viewed / Add to Cart 仍归 Shopify | begin_checkout 为 —; 有 key 时 Orders API 补发成交 |

## 2.2 渠道内容和数据关系

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 检测到的 Pixel | 来自 Trybe 链接 Shopify 后的安装结果; BestCheckout 可能检测得到或检测不到; 检测行 Source 为 Shopify store |  | 未展示给商家用户, 但可以触发 |
| 2 | 手动 Pixel | 商家粘贴 Pixel snippet, 从中解析 px_… 作为 Pixel code; Source 为 Manual setup |  | 未检测到时用该路径 |
| 3 | Orders API key | 服务端成交上报凭证, 一律商家手动粘贴; 可挂在检测行或手动行上 |  | 不会被检测; 与 Meta Access Token / GA4 API Secret 同一硬规则 |
| 4 | Primary | 同渠道仅一组已保存的 Orders API key 生效, 该行排在列表前 |  | 冲突时只报错提示, 需先关掉现有 Primary 再保存 |
| 5 | 条数关系 | 检测最多 1 条 + 手动最多 1 条; 先手动后仍可再展示检测行 |  |  |

# 3. 需求正文

## 3.1 Trybe 渠道卡

### 3.1.1 入口和默认规则

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 入口 | 设置 → 广告数据; 在 Meta / GA4 / GTM 下方展示 Trybe Pixel & Orders API 渠道卡 |  |  |
| 2 | 卡片头 | 左侧为渠道说明, 右侧为检测状态 (Detected / Not detected) 和 Add Trybe Pixel |  | Detected 仅在存在检测来源 Pixel 时成立; 仅有手动行不算 Detected |
| 3 | 空态 | 无列表内容时不展示列表行, 仅保留卡头和添加入口 |  |  |
| 4 | 原型预览 | http://127.0.0.1:4200/app/?reload=20261118-multipixel47&store=Lavender+Labs#/settings/advertising-analytics |  | Lavender Labs 为检测态 mock; Plover Studio 为未检测空态 |

### 3.1.2 条数与检测

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 总条数 | 算上检测一共两条 (检测 1 + 手动 1) |  |  |
| 2 | 未检测到 | 只有一条, 用单独表单项全部填写 (Name + Pixel snippet + Orders API) |  |  |
| 3 | 检测到 | 展示检测行, 保留不可删除 |  |  |
| 4 | 先后顺序 | 手动添加一条后, 支持后续检测到时再展示出来 |  |  |
| 5 | 手动上限 | 已有手动行时, 不再允许继续手动添加; Add Trybe Pixel 禁用 |  |  |

## 3.2 列表

### 3.2.1 列表字段

| # | 字段 | 特性描述 | 备注 |
|-|-|-|-|
| 1 | Pixel code | 检测得到, 或从 snippet 解析的 px_… |  |
| 2 | Source | 检测到 → Shopify store; 手动添加 → Manual setup |  |
| 3 | Name | 可编辑名称 |  |
| 4 | Orders API | 有已保存 key → 按账单支付方式同一掩码展示: 前 4 位 + `····` + 后 4 位; key 不足 8 位时只显示 `····`; hover 提示 Credential saved, 不展示 key 原文; 无 → `—` | 中文 hover 为已保存凭证; 对齐系统 `.tbl` padding 12px 16px |
| 5 | Action | 编辑始终有; 删除仅手动行出现; 图标交互对齐员工列表 | 不展示 Status、Pages |

### 3.2.2 排序

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | Primary 排序 | 有已保存 Orders API key 的行排在前面 |  |  |

## 3.3 添加和编辑

### 3.3.1 未检测 / 手动添加

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 字段 | Name; Pixel snippet (必填); Orders API key 输入框常显, 非必填, 手动粘贴 | 见附录自定义弹窗截图 |  |
| 2 | 页脚 | 取消 / 保存 |  |  |
| 3 | 解析 | snippet 须能解析出 Pixel code (px_…) |  |  |
| 4 | 暗提示 | `Paste the Orders API key from Trybe Brand Portal` | 中文: 从 Trybe Brand Portal 粘贴 Orders API key. 不用 `sk_…` 或省略号代替 key 样例 |  |
| 5 | 输入内容 | 框内展示正在输入或已保存的原文 | 不用密码点, 也不用列表掩码 |  |
| 6 | 列表外显 | 保存后的列表仍按 3.2.1 掩码 | 与输入框原文分开 |  |

### 3.3.2 编辑检测行

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 字段 | Name; Pixel code (只读); Orders API key 输入框常显, 可手填或清空 |  |  |
| 2 | 页脚 | 取消 / 保存; 无删除 |  |  |

### 3.3.3 编辑手动行

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 字段 | 同 3.3.1, 可修改 Name、snippet、Orders API |  |  |
| 2 | 页脚 | 左侧删除 (红框 outline) + 取消 / 保存 |  |  |

### 3.3.4 保存校验

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 必填 | 手动添加时 snippet 必填; Orders API key 可留空. 留空则该行不启用服务端上报 |  |  |
| 2 | 唯一性 | 同渠道 Pixel code 不可重复 |  |  |
| 3 | Primary 冲突 | 有 key 值时才校验同渠道唯一; 冲突时只弹出报错 (标题 + 说明 + 关闭); Save 与凭证失焦均校验 |  |  |
| 4 | 凭证来源 | 凡保存的 Orders API key 均记为商家手动添加; 不存在「检测到的凭证」 |  |  |
| 5 | P1 测试 | 添加 / 保存成功后支持测试上报为期望能力; 若无可行方案或耗时过长, 本轮可不做 |  | 可暂缓 |

## 3.4 删除

### 3.4.1 删除入口

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 手动行 | 列表 Action 和编辑弹窗左侧展示删除 |  |  |
| 2 | 检测行 | 不展示删除入口 |  |  |

### 3.4.2 删除结果

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 手动添加 | 整行删除 (Pixel + key 如有) |  |  |
| 2 | 检测到 | 不可删; 若要关掉服务端, 在编辑里清空 Orders API key |  |  |

## 3.5 事件表与上报口径

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 事件表 | What BestCheckout sends 增加 Trybe 列 |  | 口径对齐 https://jointrybe.com/help/brand-guides/trybe-pixel-and-orders-api |
| 2 | Trybe 事件集 | Trybe Pixel 共 3 个业务事件: Product Viewed、Add to Cart、Checkout |  | `window.trybe.productViewed` / `addToCart` / `checkout` |
| 3 | 前台分工 | Product Viewed、Add to Cart 仍由 Shopify 店铺前台负责; BestCheckout 不在结账事件表里重复这两行 |  |  |
| 4 | Checkout | 仅 BestCheckout 的 `purchase` 映射到 Trybe `Checkout` (`window.trybe.checkout`, 在 thank-you / 订单确认页调用) |  | `begin_checkout` 与其余结账中间步均无 Trybe 对应, 列显示 `—` |
| 5 | 服务端 | 保存 Orders API key 后, 成交订单经 Orders API 服务端提交 |  | 服务端只提交 completed orders |
| 6 | 去重 | 同订单浏览器 Checkout + 服务端 Orders API 只计一次, 沿用现有基线 |  |  |

## 3.6 全渠道服务端凭证通则

| # | 特性 | 特性描述 | 配图 | 备注 |
|-|-|-|-|-|
| 1 | 仅手动 | Meta Access Token、GA4 API Secret、Trybe Orders API key 都只能商家手动填写 |  | 不会从店铺检测到凭证 |
| 2 | 检测范围 | 可检测的只有回传目标 ID (Pixel ID / Measurement ID / Container ID / Trybe Pixel code) |  |  |
| 3 | 挂载对象 | 凭证可挂在检测到的目标上, 也可挂在手动添加的目标上; 差别只在挂载对象 |  |  |
| 4 | 三处展示 | 暗提示写完整说明; 输入框展示原文; 列表外显按 3.2.1 掩码 |  | Meta / GA4 同一规则, 见多 Pixel PRD |

# 4. 逻辑边界

## 4.1 已确认规则

| # | 规则 | 说明 |
|-|-|-|
| 1 | 只做配置 | 本轮只改广告数据配置页 |
| 2 | 结账原型不改 | 结账原型给技术和其他关联人了解业务 |
| 3 | 检测双态 | 存在检测到和检测不到两种情况 |
| 4 | 检测不可删 | 检测到的要保留不可删除 |
| 5 | 条数 | 算上检测一共两条; 未检测到则只有一条; 手动后仍可再展示检测行 |
| 6 | 业务顺序 | 先 Shopify 安装 Trybe 并跑通关联, 再来 BestCheckout |
| 7 | 凭证仅手动 | 所有渠道服务端上报凭证只能手动添加 |
| 8 | 凭证三处 | 暗提示写完整说明; 输入框展示原文; 列表外显按支付方式掩码, hover 不展示原文 |

## 4.2 本轮不展开

| # | 事项 | 说明 |
|-|-|-|
| 1 | 结账页 UI | 不改结账原型交互 |
| 2 | 诊断 Test / 复选框 / 分页 | 与多 Pixel PRD 一致, 本轮不做 |
| 3 | Trybe 扩到 10 条 | 本期固定最多 2 条 |
| 4 | 单独必填 Store ID / 追踪域名 | 默认不单开表单项 |

# 5. 验收标准

| 编号 | 验收场景 | 预期结果 | 关联模块 |
|-|-|-|-|
| AC-001 | 打开广告数据页 | Meta / GA4 / GTM 下方出现 Trybe 渠道卡 | 3.1.1 |
| AC-002 | 未检测店铺 (如 Plover Studio) | 无列表行; 可 Add Trybe Pixel; 表单为 Name + snippet + Orders API | 3.1.2 / 3.3.1 |
| AC-003 | 检测店铺 (如 Lavender Labs) | 展示检测行; Source 为 Shopify store; 无删除入口 | 3.1.2 / 3.4.1 |
| AC-004 | 检测行上再手动添加 | 可添加 1 条手动行; 之后 Add 禁用; 列表最多 2 条 | 3.1.2 |
| AC-005 | 先手动后出现检测 | 手动行保留; 检测行可再展示 | 3.1.2 |
| AC-006 | 编辑检测行 | Pixel code 只读; 可手填或清空 Orders API key; 无删除 | 3.3.2 |
| AC-007 | 删除手动行 | 整行删除 Pixel 与 key | 3.4.2 |
| AC-008 | 尝试删除检测行 | 不展示删除; 无法整行删除 | 3.4.1 |
| AC-009 | Orders API Primary 冲突 | 保存第二组 key 时弹出报错提示 (仅标题 / 说明 / 关闭), 阻断保存 | 3.3.4 |
| AC-010 | 事件表 | 存在 Trybe 列; 仅 `purchase` 映射 `Checkout`; `begin_checkout` 为 `—`; 文案说明三事件与 Orders API | 3.5 |
| AC-011 | 服务端凭证通则文案 / 行为 | Token / Secret / Orders API key 均只能手填, 不会被检测 | 3.6 |
| AC-012 | Orders API 列展示 | 有 key 时为前 4 位 + `····` + 后 4 位; 不足 8 位为 `····`; 无 key 为 `—`; hover 为 Credential saved, 不出现 key 原文 | 3.2.1 |
| AC-013 | Orders API 输入 | 输入框常显且非必填; 暗提示为完整说明, 不含 `sk_…`; 框内为原文 | 3.3.1 |

# 6. 待补充事项

| # | 事项 | 影响 | 责任方 |
|-|-|-|-|
| 1 | 生产侧 Trybe Pixel 检测信号来源 | 影响 Detected / Not detected 判定和检测行同步 | 技术 |
| 2 | Orders API 请求字段与 vid 贯通 | 影响服务端成交归因是否完整 | 技术 |
| 3 | P1 保存后测试上报 | 影响配置完成后的自测路径; 本轮可暂缓 | 产品 / 技术 |
| 4 | 是否必须暴露 Store ID / 追踪域名 | 仅当联调证明必须暴露时再开增量 | 技术 / 产品 |
