#!/bin/bash
# USDS 远程安装脚本 (macOS/Linux Bash 版)
# 仓库地址: https://github.com/wxxzy/Claude-Code-Software-Studios

REPO_URL="https://github.com/wxxzy/Claude-Code-Software-Studios"
ZIP_URL="$REPO_URL/archive/refs/heads/master.zip"
TEMP_ZIP="/tmp/usds-master.zip"
TEMP_DIR="/tmp/usds-extract"

echo -e "\033[0;36m🚀 正在从 GitHub 获取 Universal Software Studio (USDS)...\033[0m"

# 1. 下载 ZIP 包
echo -e "\033[0;90m📥 正在下载核心组件...\033[0m"
curl -L -s "$ZIP_URL" -o "$TEMP_ZIP"

# 2. 解压文件
echo -e "\033[0;90m📦 正在解压并注入项目...\033[0m"
mkdir -p "$TEMP_DIR"
unzip -q -o "$TEMP_ZIP" -d "$TEMP_DIR"

SOURCE_FOLDER="$TEMP_DIR/Claude-Code-Software-Studios-master"

# 3. 复制核心文件到当前目录
ITEMS_TO_COPY=(".claude" "docs" "production" "scripts" "CLAUDE.md" "UNIVERSAL-STUDIO.md" "README.md")
for ITEM in "${ITEMS_TO_COPY[@]}"; do
    if [ -e "$SOURCE_FOLDER/$ITEM" ]; then
        cp -R "$SOURCE_FOLDER/$ITEM" .
        echo -e "\033[0;32m✅ 已同步: $ITEM\033[0m"
    fi
done

# 4. 清理临时文件
rm -rf "$TEMP_ZIP" "$TEMP_DIR"

echo -e "\n\033[0;32m✨ USDS 工作室已成功注入当前项目！\033[0m"
echo -e "👉 现在运行 'claude' 后，输入 '/onboard' 开始您的旅程。"
