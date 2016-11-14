此替换功能使用了 Nginx 的 sub_filter_module 模块，用来替换返回的 html 中的相关
信息。

需要 Nginx 启用 http_sub_module 模块，启用方式见 init_nginx.sh 脚本。该脚本除
启用模块外，还修改 nginx.conf 主文件，增加对 enabled/*.conf 的引用。

生成代理配置的脚本为 new_proxy.sh，接收 4 个参数：
1. 要代理的源域名
2. 代理启用的镜像域名
3. 需要替换的文本内容的列表，用 : 组成对，用 ; 表示多组，用于替换 CDN 域名。
4. 需要删除的文本内容的列表，用 ; 表示多做，用来删除 google, facebook 等域名。

生成的配置文件直接在本地，以源域名+.conf 为名称。

将该文件拷贝到 nginx 的 enabled/ 目录下，重新加载 nginx，即可生效。

cemarose.com 这个网站启用了 https，所以代理也需要有 https（如果没有 https 需要修改 php 代码，去除 cookie 的 secure 限制）。
将新域名的 ssl 文件放在 ssl/ 目录下， 用目标域名命名 ssl 文件。

拿 cemarose.com 做例子：
shawn@EryueStudio:~/work/nginx_proxy$ ./new_proxy.sh "www.cemarose.com" "cs.erpboost.com" "" "google.com;facebook.com"
shawn@EryueStudio:~/work/nginx_proxy$ cat www.cemarose.com.conf 

server {
    listen 80;
    server_name cs.erpboost.com;

    location / {
        proxy_pass http://www.cemarose.com;
        proxy_set_header Host "www.cemarose.com";
        proxy_set_header X-Real-IP $remote_addr;
        # 为替换，需禁用后端的压缩
        proxy_set_header Accept-Encoding  "";
        # 替换跳转
        proxy_redirect default;
        proxy_redirect https://www.cemarose.com https://cs.erpboost.com;
        
        sub_filter_once off;
        # 替换逻辑


        # 禁用逻辑，只是把相关字串去掉，不能删除整行
    sub_filter '//google.com' '//';
    sub_filter '//facebook.com' '//';
    }
}


server {
    listen 443;
    server_name cs.erpboost.com;

    ssl on;
    ssl_certificate     ssl/cs.erpboost.com.crt;
    ssl_certificate_key ssl/cs.erpboost.com.key;

    location / {
        proxy_pass https://www.cemarose.com;
        proxy_set_header Host "www.cemarose.com";
        proxy_set_header X-Real-IP $remote_addr;
        # 为替换，需禁用后端的压缩
        proxy_set_header Accept-Encoding  "";
        # 替换跳转
        proxy_redirect default;
        proxy_redirect https://www.cemarose.com https://cs.erpboost.com;


        sub_filter_once off;
        # 替换逻辑
        sub_filter 'www.cemarose.com' 'cs.erpboost.com';


        # 禁用逻辑，只是把相关字串去掉，不能删除整行
    sub_filter '//google.com' '//';
    sub_filter '//facebook.com' '//';
    }
}

