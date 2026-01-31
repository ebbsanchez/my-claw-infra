# 使用 OpenClaw 的 GitHub 倉庫作為基礎進行構建
# 如果你有特定版本需求，可以更換分支名
FROM node:22-bookworm AS builder

# 切換到 root 安裝必要工具
USER root
RUN apt-get update && apt-get install -y curl git && apt-get clean

# 下載最新的 OpenClaw 原始碼
WORKDIR /app
RUN git clone https://github.com/idootop/mi-gpt.git . && \
    npm install -g pnpm bun && \
    pnpm install --frozen-lockfile && \
    OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build && \
    pnpm ui:build

# --- 運行階段 ---
FROM node:22-bookworm

WORKDIR /app

# 安裝 Tailscale
RUN apt-get update && apt-get install -y curl iptables && \
    curl -fsSL https://tailscale.com/install.sh | sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 從 builder 階段複製編譯好的成品
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# 複製你的標準化腳本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
