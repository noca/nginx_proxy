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

我拿 stackoverflow.com 做了个例子，效果不错（我没替换 CDN，但隔离了 google 的
一些域名）:

# ./new_proxy.sh  stackoverflow.com local.stackoverflow.com '' 'ajax.googleapis.com;www.google-analytics.com'
# cat stackoverflow.com.conf
server {
    listen 80;
    server_name local.stackoverflow.com;

    location / {
        proxy_pass http://stackoverflow.com;
        proxy_set_header Host "stackoverflow.com";
        proxy_set_header X-Real-IP $remote_addr;
        # 为替换，需禁用后端的压缩
        proxy_set_header Accept-Encoding  "";
        
        sub_filter_once off;
        # 替换逻辑


        # 禁用逻辑，只是把相关字串去掉，不能删除整行
	sub_filter '//ajax.googleapis.com' '//';
	sub_filter '//www.google-analytics.com' '//';
    }
}

