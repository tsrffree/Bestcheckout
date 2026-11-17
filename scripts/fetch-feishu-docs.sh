#!/bin/bash
set -u
OUT_DIR="/Users/lidongjie/Desktop/BestCheckout/.feishu-docs"
mkdir -p "$OUT_DIR"
export PATH="$HOME/.local/node/bin:$HOME/.local/bin:$PATH"
cd "$OUT_DIR"

TC_URL="https://bestfulfill.feishu.cn/wiki/XQkKwr7OMiv8eck10bxc1l8Nnaf"
BUG_URL="https://bestfulfill.feishu.cn/wiki/P2jPwMkx6i8heYkNmp3cgO17nuf"
TC_TOKEN="CQMQsGDmih6a3XtKFSqcFqeen8d"

echo "=== [TC] 测试用例 全量表数据 ==="
lark-cli sheets +table-get --spreadsheet-token "$TC_TOKEN" --format json --output-path ./test-cases-table.json 2>./tc-table.err \
  && echo "TC table OK" || { echo "TC table FAILED"; cat ./tc-table.err; }

echo "=== [TC] 逐子表 csv ==="
for pair in "测试用例:tc-cases" "执行汇总:tc-exec" "按能力汇总:tc-capability" "缺陷与残留:tc-defects" "待确认问题:tc-open" "修订说明:tc-revision"; do
  name="${pair%%:*}"; out="${pair##*:}"
  lark-cli sheets +csv-get --spreadsheet-token "$TC_TOKEN" --sheet-name "$name" --format json --output-path "./${out}.json" 2>"./${out}.err" \
    && echo "TC '$name' OK" || { echo "TC '$name' FAILED"; cat "./${out}.err"; }
done

echo "=== [BUG] 探测文档类型 ==="
lark-cli sheets +workbook-info --url "$BUG_URL" --format json > bugs-workbook-info.json 2>bugs-wb.err \
  && echo "BUG is SHEET" || {
    echo "BUG sheet probe failed, trying docx:"
    cat bugs-wb.err 2>/dev/null
    lark-cli docs +fetch --as user --doc "$BUG_URL" --doc-format markdown > bugs-full.json 2>bugs-fetch.err \
      && echo "BUG docx OK" || { echo "BUG docx FAILED"; cat bugs-fetch.err; }
  }

if grep -q '"ok": *true' bugs-workbook-info.json 2>/dev/null; then
  echo "=== [BUG] 读取全量表 ==="
  lark-cli sheets +table-get --url "$BUG_URL" --format json --output-path ./bugs-table.json 2>./bugs-table.err \
    && echo "BUG table OK" || { echo "BUG table FAILED"; cat ./bugs-table.err; }
fi

date > DONE.txt
echo "ALL DONE"
ls -lh "$OUT_DIR"
