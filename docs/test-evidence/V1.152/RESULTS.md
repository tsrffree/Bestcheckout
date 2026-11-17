# V1.152 AI PM 核心用例 - 测试环境执行记录

店铺: bsc产品验收-授权6 (`bsc-6.myshopify.com`)
后台: https://bc.bestfulfill.tech
执行时间: 2026-11-12

## 结论摘要

| 用例 | 结论 | 说明 |
|-|-|-|
| TC-01 | 失败 | 产品不允许同商品创建第二条 Bundle, 与用例「两条 Bundle + Replace」不一致 |
| TC-02 | 通过 | Cancel 后不变; Replace and activate 后旧计划 Deactivated, 新计划 Activated |
| TC-03 | 通过 | D1 不接管; D2 接管且仅一次性; D3 接管且有一次性和订阅省 |
| TC-04 | 阻塞 | 订阅结账页正确进入且购买方式锁定; 卡号 iframe 需测试卡才能完成支付 |
| TC-05 | 未执行 | 依赖支付与 Force subscription 配置 |
| TC-06 | 通过 | 有订阅时删除 Bundle 被拦截; 删除订阅后可删除 Bundle; 删除结果已从列表验证, 商品页恢复原生购买区 |
| TC-07 | 部分通过 | Active 合同取消通过并生成 Cancelled 样例; 地址编辑弹窗和保存路径可用, 本轮保存了原地址未验证地址字段变化; Past due=0, Retry/Update payment method 未执行 |
| TC-08 | 部分通过 | 已用无订阅商品保存并清理 Deactivated Bundle; MCP 创建路径不触发后台引导弹窗, Add Subscribe & Save/Not now UI 交互未能确认 |

测试环境是否允许线上验收: 否 (TC-01 P0 失败, TC-04/05 未完成, TC-07 Past due 未覆盖, TC-08 UI 引导未确认)

## 详细结果

| 用例 | 前置条件 | 实际结果 | 结论 | 证据 |
|-|-|-|-|-|
| TC-01 | 商品 Multi-managed 已有 Activated Bundle `test bundle2` | 新建 Activated Bundle 时弹窗: "This product already has a bundle. Edit the existing bundle instead of creating another one." 无 Replace and activate | 失败 | TC01-cannot-create-second-bundle.png |
| TC-02 | 商品 Liquid 已有 Activated `test订阅` | 弹窗说明将停用当前 active plan; Cancel 后仍仅 1 条; Replace 后 `TC02-plan2-lidongjie-test` Activated, `test订阅` Deactivated | 通过 | TC02-replace-active-plan-modal.png |
| TC-03 | D1 Multi-location / D2 Multi-managed / D3 Liquid | D1 原生 Add to cart + Buy it now; D2 Bundle 档位 + Buy Now 无订阅; D3 Bundle + One-time + Subscribe & Save | 通过 | TC03-D1/D2/D3 png |
| TC-04 | D3 选 2 PCS + Subscribe & Save | 进入 `bsc-6.stores.bestfulfill.tech/checkout/...`, 摘要为 Bundle 2 PCS + Delivery every 2 months, 无切换购买方式入口; 支付卡字段在 iframe, 未完成下单 | 阻塞 | TC04-checkout-subscribe-locked.png |
| TC-06 | 商品 Liquid 有 Activated Subscription; Complete Snowboard 无 Subscription | 删除 Liquid Bundle 时提示 "This product has a subscription. Delete the subscription first."; 删除订阅后 Bundle 可删除; 删除后列表仅剩 2 条 Bundle, 商品页恢复原生 Add to cart / Buy it now | 通过 | 页面结果; TC03-D1-multi-location-native.png |
| TC-07 | Active 合同 193 | Edit shipping address 弹窗可打开并保存原地址, Activity log 出现 Shipping address updated; Cancel subscription 后显示 Ended on Nov 11, 2026. No further charges., No upcoming orders., Manage 无操作; 列表变为 All 3 / Active 2 / Past due 0 / Cancelled 1 | 部分通过 | TC07-contracts-list.png; 合同详情页面 |
| TC-08 | D1 Multi-location 无订阅 | 创建 Deactivated `TC08-guidance-lidongjie-test` 成功后已清理; 直接 MCP 创建不会经过后台 Save 后引导弹窗, 因而未确认 Add Subscribe & Save? / Not now / Add subscription 页面交互 | 部分通过 | MCP 操作结果; 无新增 UI 截图 |

## 当前剩余阻塞与缺口

1. 测试环境信用卡 / 测试支付方式, 以完成 TC-04 / TC-05 下单
2. Past due 合同样例或可控的失败支付测试入口, 以执行 Retry payment now / Update payment method
3. TC-01 需要产品确认是否按当前实现修订为 "同商品仅允许一条 Bundle, 不允许创建第二条", 当前实现与 PRD 的 Replace 流程不一致
4. TC-08 需要通过后台浏览器 Save 操作确认 Add Subscribe & Save? 的 Not now 和 Add subscription 分支; 当前 MCP 创建路径不触发该 UI 弹窗
