#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: new_proxy.sh <ORIGIN DOMAIN> <NEW DOMAIN> <REPLACE LIST> <IGNORE LIST>"
    echo "       REPLACE LIST should be: origin1:new1;origin2:new2;......"
    echo "       IGNOE LIST should be: ignore1;ignore2;......"

    exit 1
fi

o_domain=$1
n_domain=$2
r_list=${3//;/ }
i_list=${4//;/ }

r_code=''
for r in $r_list;do
    origin=`echo $r|awk -F":" '{print $1}'`
    new=`echo $r|awk -F":" '{print $2}'`
    
    r_code=$r_code"\tsub_filter '//$origin' '//$new';\n"
done

i_code=''
for i in $i_list;do
    i_code=$i_code"\tsub_filter '//$i' '//';\n"
done

r_code=$(echo -e $r_code)
i_code=$(echo -e $i_code)

cat > ${o_domain}.conf<<EOF

server {
    listen 80;
    server_name ${n_domain};

    location / {
        proxy_pass http://${o_domain};
        proxy_set_header Host "${o_domain}";
        proxy_set_header X-Real-IP \$remote_addr;
        # 为替换，需禁用后端的压缩
        proxy_set_header Accept-Encoding  "";
        # 替换跳转
        proxy_redirect default;
        proxy_redirect https://${o_domain} https://${n_domain};
        
        sub_filter_once off;
        # 替换逻辑
$r_code

        # 禁用逻辑，只是把相关字串去掉，不能删除整行
$i_code
    }
}


server {
    listen 443;
    server_name ${n_domain};

    ssl on;
    ssl_certificate     ssl/${n_domain}.crt;
    ssl_certificate_key ssl/${n_domain}.key;

    location / {
        proxy_pass https://${o_domain};
        proxy_set_header Host "${o_domain}";
        proxy_set_header X-Real-IP \$remote_addr;
        # 为替换，需禁用后端的压缩
        proxy_set_header Accept-Encoding  "";
        # 替换跳转
        proxy_redirect default;
        proxy_redirect https://${o_domain} https://${n_domain};


        sub_filter_once off;
        # 替换逻辑
        sub_filter '${o_domain}' '${n_domain}';
$r_code

        # 禁用逻辑，只是把相关字串去掉，不能删除整行
$i_code
    }
}


EOF
