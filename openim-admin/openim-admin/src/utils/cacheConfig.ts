/**
 * 为 Nginx 配置文件生成建议的缓存策略
 * 将此配置添加到你的 Nginx 配置文件中
 */

/*
# Nginx 配置示例
# 在 server 块中添加以下配置

location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;
    
    # index.html 不缓存，确保用户总是获取最新版本
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
    
    # 静态资源长期缓存（JS、CSS、图片等）
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 对于带 hash 的文件，永久缓存
    location ~* \.[0-9a-f]{8,}\.(js|css)$ {
        expires max;
        add_header Cache-Control "public, immutable";
    }
}

# 启用 Gzip 压缩
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;

# 错误页面
error_page 404 /index.html;
*/

export const CACHE_CONTROL_CONFIG = {
  // 主文件：不缓存
  HTML: 'no-cache, no-store, must-revalidate',
  
  // 带 hash 的静态资源：永久缓存
  HASHED_ASSETS: 'public, max-age=31536000, immutable',
  
  // 不带 hash 的静态资源：短期缓存
  STATIC_ASSETS: 'public, max-age=3600',
  
  // API 请求：不缓存
  API: 'no-cache, no-store, must-revalidate',
};

export const getNginxConfig = (): string => {
  return `
# OpenIM Admin 管理后台 Nginx 配置
# 优化的缓存策略，避免 chunk 加载失败

server {
    listen 80;
    server_name admin.local;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip 压缩配置
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript 
               application/xml+rss application/rss+xml 
               font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;

    # 主页面：不缓存，确保用户总是获取最新版本
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
        try_files $uri =404;
    }

    # 带 hash 的 JS/CSS 文件：永久缓存
    location ~* \\.[0-9a-f]{8,}\\.(js|css)$ {
        expires max;
        add_header Cache-Control "public, max-age=31536000, immutable";
        try_files $uri =404;
    }

    # 其他静态资源：1年缓存
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|json)$ {
        expires 1y;
        add_header Cache-Control "public, max-age=31536000";
        try_files $uri =404;
    }

    # API 代理（如果需要）
    location /api/ {
        proxy_pass http://backend-server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # API 不缓存
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # SPA 路由：所有其他请求返回 index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 404 错误处理
    error_page 404 /index.html;
    
    # 50x 错误处理
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
`;
};
