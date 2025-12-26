# 进入easy-rsa目录
cd /home/openvpn/openvpn-ca

# 快速创建客户端配置
read -p "输入客户端名称: " CLIENT

# 创建新客户端证书
./easyrsa gen-req ${CLIENT} nopass
./easyrsa sign-req client ${CLIENT}


# 创建客户端配置文件
cat > ${CLIENT}.ovpn << EOF
# 指定这是一个客户端配置文件
client
# 使用 TUN 设备，创建一个基于 IP 的虚拟网络接口。
dev tun
proto udp
remote 129.28.44.109 1194
# 如果连接失败，无限次重试解析服务器地址。
resolv-retry infinite
# 客户端不会绑定到本地端口，这允许客户端在不同的网络接口上连接到服务器。
nobind
# 在连接中断后，保持密钥和 TUN 设备的状态，以便快速重新连接。
persist-key
persist-tun
# 要求远端证书必须带 "TLS Web Server Authentication" 扩展（EKU），防止有人用客户端证书冒充服务器。与服务端 remote-cert-tls client 成对出现，二者必须同时启用。
remote-cert-tls server
# 指定加密算法，这里使用 AES-256-CBC。
cipher AES-256-CBC
# 指定认证算法，这里使用 SHA256。
auth SHA256
# 仅在使用 tls-auth 或 tls-crypt 时出现。
# 服务端 tls-auth ta.key 0
# 客户端 tls-auth ta.key 1
# 方向参数必须互为 0/1，否则 TLS 握手第一层就会被丢弃，表现为 TLS key negotiation failed
key-direction 1
# 不使用默认网关
route-nopull
# 只走 VPN 的网段
route 10.9.0.0 255.255.255.0
verb 3

<ca>
$(cat pki/ca.crt)
</ca>
<cert>
$(cat pki/issued/${CLIENT}.crt)
</cert>
<key>
$(cat pki/private/${CLIENT}.key)
</key>
<tls-auth>
$(cat ta.key)
</tls-auth>
EOF