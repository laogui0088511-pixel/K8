# 快速参考指南

## 🚀 快速开始

### 开发
```bash
npm install
npm run start:dev
```

### 构建
```bash
npm run build
```

### 部署
```bash
npm run deploy
```

## 📋 常用命令

| 命令 | 说明 |
|------|------|
| `npm run start:dev` | 启动开发环境 |
| `npm run build` | 构建生产版本 |
| `npm run build:analyze` | 构建并分析打包大小 |
| `npm run deploy` | 自动部署（需配置服务器） |
| `npm run preview` | 预览构建结果 |
| `npm run lint` | 代码检查 |
| `npm run lint:fix` | 自动修复代码问题 |

## 🔧 配置文件

| 文件 | 说明 |
|------|------|
| `config/config.ts` | Umi 框架配置 |
| `nginx.conf` | Nginx 部署配置 |
| `src/app.tsx` | 应用入口和全局配置 |
| `.env` | 环境变量 |

## 🐛 问题排查

### Chunk 加载失败
1. **用户端解决**：按 `Ctrl + Shift + R` 强制刷新
2. **服务端解决**：按照 `DEPLOYMENT.md` 重新部署

### 页面白屏
1. 打开浏览器控制台查看错误
2. 检查网络请求是否正常
3. 检查 Nginx 配置是否正确

### 构建失败
```bash
# 清理缓存
rm -rf node_modules .umi
npm install
npm run build
```

## 📝 重要文件说明

### 新增的优化文件

#### 错误处理
- `src/components/ErrorBoundary/index.tsx` - 全局错误边界
- `src/components/ErrorBoundary/ChunkLoadError.tsx` - Chunk 错误页面
- `src/utils/chunkErrorHandler.ts` - Chunk 错误处理工具

#### 版本管理
- `src/utils/versionCheck.ts` - 版本更新检测

#### 部署相关
- `scripts/deploy.sh` - 自动部署脚本
- `nginx.conf` - Nginx 配置文件
- `DEPLOYMENT.md` - 详细部署文档
- `DEPLOYMENT_CHECKLIST.md` - 部署检查清单

## 🔍 日志查看

### Nginx 日志
```bash
# 访问日志
tail -f /var/log/nginx/access.log

# 错误日志
tail -f /var/log/nginx/error.log

# 查找 404 错误
grep "404" /var/log/nginx/access.log | grep "\.js"
```

### 浏览器控制台
打开 Chrome DevTools（F12）→ Console

## 🚨 紧急情况处理

### 回滚部署
```bash
# 查看可用的备份
ls -lh /var/backups/openim-admin/

# 恢复备份（替换时间戳）
tar -xzf /var/backups/openim-admin/backup-YYYYMMDD-HHMMSS.tar.gz -C /usr/share/nginx/html

# 重新加载 Nginx
nginx -s reload
```

### 清除所有缓存
```bash
# 清除浏览器缓存
Ctrl + Shift + Delete

# 清除 CDN 缓存（如使用）
# 访问 CDN 控制台手动清除
```

## 📱 联系方式

- **技术支持**：[技术团队联系方式]
- **紧急联系**：[24小时紧急联系人]
- **文档反馈**：提交 Issue 或 PR

## 📚 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 完整部署文档
- [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) - 部署检查清单
- [CHUNK_LOADING_FIX.md](./CHUNK_LOADING_FIX.md) - Chunk 加载优化说明

## ✅ 健康检查

访问以下 URL 确认服务正常：

- 主页：https://admin.local
- API 健康检查：https://admin.local/api/health（如有）

## 🔐 安全提醒

1. 不要提交敏感信息到代码仓库
2. 定期更新依赖包
3. 定期备份数据
4. 使用 HTTPS
5. 配置适当的 CORS 策略
