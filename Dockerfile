FROM oven/bun:latest AS builder
WORKDIR /app

# Copy semua file (Pastikan sudah ada .dockerignore kosong agar ui/dist ikut)
COPY . .
COPY ui_dist ./ui/dist

RUN bun install --frozen-lockfile
RUN bun run build

FROM oven/bun:latest
WORKDIR /app

# 1. Ambil binary server
COPY --from=builder /app/server ./server 

# 2. Ambil folder asset (untuk route /asset/*)
# Pastikan folder 'asset' ada di root project Anda saat build
COPY --from=builder /app/asset ./asset

# 3. Ambil folder ui/dist (untuk route /assets/* dan index.html)
# Kita taruh di path yang SAMA dengan di kode yaitu ./ui/dist
COPY --from=builder /app/ui/dist ./ui/dist

EXPOSE 3000

CMD ["./server"]