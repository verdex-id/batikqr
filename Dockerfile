FROM oven/bun:latest AS builder

WORKDIR /app

# 1. Pastikan .dockerignore TIDAK mengecualikan folder ui/dist
COPY . .

# 2. Install dependencies untuk root (diperlukan untuk build server)
RUN bun install --frozen-lockfile

# 3. Run build
RUN bun run build

FROM oven/bun:latest

WORKDIR /app

# 4. Ambil executable server hasil compile
COPY --from=builder /app/server ./server 

# 5. Ambil hasil build UI dari local yang tadi di-copy ke /app/ui/dist
# Di sini saya arahkan ke folder 'asset' sesuai Dockerfile lama Anda
COPY --from=builder /app/ui/dist ./asset 

EXPOSE 3000

# Pastikan aplikasi Anda membaca file static dari folder /app/asset
CMD ["./server"]