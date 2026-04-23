# OpenIM Admin 部署检查清单

## 部署前检查

- [ ] 代码已通过测试
- [ ] 已在测试环境验证
- [ ] 已通知相关人员即将部署
- [ ] 已创建当前版本的备份

## 构建步骤

```bash
# 1. 安装依赖（如有更新）
npm install

# 2. 构建生产版本
npm run build

# 3. 检查构建产物
ls -lh dist/
```

## 部署步骤

### 方式一：使用自动部署脚本（推荐）

```bash
# 赋予执行权限
chmod +x scripts/deploy.sh

# 执行部署
./scripts/deploy.sh
```

### 方式二：手动部署

```bash
# 1. 备份当前版本
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /usr/share/nginx/html .

# 2. 部署新版本
rsync -av dist/ /usr/share/nginx/html/

# 3. 重新加载 Nginx
nginx -t && nginx -s reload

# 4. 10分钟后清理旧的 chunk 文件
# （可选，避免立即删除导致正在访问的用户出错）
```

## 部署后验证

- [ ] 访问主页，确认能正常加载
- [ ] 检查浏览器控制台，无错误信息
- [ ] 测试主要功能（登录、列表、详情等）
- [ ] 检查 Nginx 访问日志，确认无 404 错误
- [ ] 检查 Nginx 错误日志，确认无异常

```bash
# 查看最近的访问日志
tail -n 100 /var/log/nginx/access.log

# 查看最近的错误日志
tail -n 100 /var/log/nginx/error.log

# 检查是否有 404 的 JS 文件请求
grep "404" /var/log/nginx/access.log | grep "\.js"
```

## 缓存验证

### 检查 index.html 缓存策略
```bash
curl -I https://admin.local/index.html
```
预期响应头：
```
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
```

### 检查 chunk 文件缓存策略
```bash
curl -I https://admin.local/umi.xxxxxxxx.js
```
预期响应头：
```
Cache-Control: public, max-age=31536000, immutable
```

## 监控建议

### 1. 实时监控访问日志
```bash
tail -f /var/log/nginx/access.log | grep -E "(404|500)"
```

### 2. 监控错误日志
```bash
tail -f /var/log/nginx/error.log
```

### 3. 监控前端错误（如已接入 Sentry）
访问 Sentry Dashboard 查看错误率

## 回滚步骤

如果部署后发现问题：

```bash
# 1. 停止自动清理任务（如果使用了部署脚本）
ps aux | grep deploy.sh
kill <PID>

# 2. 恢复备份
tar -xzf /var/backups/openim-admin/backup-YYYYMMDD-HHMMSS.tar.gz -C /usr/share/nginx/html

# 3. 重新加载 Nginx
nginx -s reload

# 4. 验证回滚是否成功
curl https://admin.local
```

## 用户通知

如果需要，可以在部署前后通知用户：

**部署前：**
> "系统将在 XX:XX 进行更新维护，可能会有短暂的访问中断，请保存好您的工作。"

**部署后：**
> "系统更新完成，如遇到页面显示异常，请刷新页面（Ctrl+Shift+R）或清除浏览器缓存。"

## 常见问题处理

### 问题1：用户反馈页面加载失败
**原因：** 用户浏览器缓存了旧的 index.html  
**解决：** 让用户强制刷新（Ctrl+Shift+R）

### 问题2：某些用户能访问，某些不能
**原因：** CDN 或负载均衡器缓存了旧版本  
**解决：** 清除 CDN 缓存，或等待 CDN 缓存过期

### 问题3：Nginx 日志显示大量 404
**原因：** 旧的 chunk 文件被删除但用户还在尝试加载  
**解决：** 
1. 如果是部署后立即发生，可能是删除太早，恢复备份
2. 如果是部署后很久发生，让用户刷新页面

## 性能监控

### 关键指标
- 页面加载时间（FCP、LCP）
- 错误率
- chunk 加载成功率
- API 响应时间

### 监控工具推荐
- Google Analytics
- Sentry（错误监控）
- Lighthouse（性能评分）
- New Relic / DataDog（APM）

## 联系人

- 开发负责人：[姓名] - [联系方式]
- 运维负责人：[姓名] - [联系方式]
- 紧急联系人：[姓名] - [联系方式]
