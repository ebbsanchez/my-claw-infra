#!/bin/bash

# 1. 啟動 Tailscale (Userspace 模式)
# 這樣不需要修改 Zeabur 的系統內核也能跑 VPN
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# 2. 等待並自動登入 Tailscale
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    echo "Connecting to Tailscale network..."
    # hostname 建議加上地區標記，方便你識別（例如 openclaw-valencia）
    tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=${TS_HOSTNAME:-openclaw-agent} --accept-routes
else
    echo "Warning: TAILSCALE_AUTHKEY not set. VPN will not be available."
fi

# 3. 啟動 OpenClaw
echo "Starting OpenClaw..."
exec node dist/index.js
