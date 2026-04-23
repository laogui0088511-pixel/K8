#!/bin/bash

# OpenIM Admin 部署脚本
# 用于安全地部署新版本，避免 chunk 加载失败

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
DEPLOY_DIR="/usr/share/nginx/html"
BACKUP_DIR="/var/backups/openim-admin"
KEEP_OLD_FILES_SECONDS=600  # 保留旧文件10分钟

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OpenIM Admin 部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查是否有 dist 目录
if [ ! -d "dist" ]; then
    echo -e "${RED}错误: dist 目录不存在，请先运行 npm run build${NC}"
    exit 1
fi

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名（带时间戳）
BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"

# 备份当前部署
if [ -d "$DEPLOY_DIR" ]; then
    echo -e "${YELLOW}正在备份当前部署...${NC}"
    tar -czf "$BACKUP_FILE" -C "$DEPLOY_DIR" .
    echo -e "${GREEN}备份完成: $BACKUP_FILE${NC}"
fi

# 获取旧文件列表（用于后续清理）
if [ -d "$DEPLOY_DIR" ]; then
    OLD_FILES=$(find "$DEPLOY_DIR" -type f -name "*.js" -o -name "*.css")
fi

# 部署新版本
echo -e "${YELLOW}正在部署新版本...${NC}"
rsync -av --delete dist/ "$DEPLOY_DIR/"

# 获取新文件列表
NEW_FILES=$(find "$DEPLOY_DIR" -type f -name "*.js" -o -name "*.css")

# 找出需要删除的旧文件（在旧列表中但不在新列表中）
if [ ! -z "$OLD_FILES" ]; then
    TO_DELETE=$(comm -23 <(echo "$OLD_FILES" | sort) <(echo "$NEW_FILES" | sort))
fi

echo -e "${GREEN}部署完成！${NC}"

# 如果有需要删除的旧文件，延迟删除
if [ ! -z "$TO_DELETE" ]; then
    echo -e "${YELLOW}检测到 $(echo "$TO_DELETE" | wc -l) 个旧文件${NC}"
    echo -e "${YELLOW}这些文件将在 $KEEP_OLD_FILES_SECONDS 秒后删除，以确保正在访问的用户能正常加载${NC}"
    
    # 在后台延迟删除
    (
        sleep $KEEP_OLD_FILES_SECONDS
        echo "$TO_DELETE" | while read file; do
            if [ -f "$file" ]; then
                rm -f "$file"
                echo "已删除旧文件: $file"
            fi
        done
        echo -e "${GREEN}旧文件清理完成${NC}"
    ) &
    
    echo -e "${YELLOW}清理任务已在后台启动（PID: $!)${NC}"
fi

# 重新加载 Nginx
if command -v nginx &> /dev/null; then
    echo -e "${YELLOW}正在重新加载 Nginx...${NC}"
    nginx -t && nginx -s reload
    echo -e "${GREEN}Nginx 重新加载完成${NC}"
fi

# 清理旧备份（保留最近10个）
echo -e "${YELLOW}清理旧备份...${NC}"
cd "$BACKUP_DIR"
ls -t backup-*.tar.gz | tail -n +11 | xargs -r rm
echo -e "${GREEN}备份清理完成${NC}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}部署成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "部署目录: $DEPLOY_DIR"
echo -e "备份文件: $BACKUP_FILE"
echo -e ""
echo -e "${YELLOW}提示：${NC}"
echo -e "1. 旧的 chunk 文件将在 $KEEP_OLD_FILES_SECONDS 秒后自动清理"
echo -e "2. 如需回滚，请运行: tar -xzf $BACKUP_FILE -C $DEPLOY_DIR"
echo -e "3. 建议监控 Nginx 日志以确认部署成功"
