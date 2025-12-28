FROM oven/bun:latest AS builder

WORKDIR /app

# 1. Copy lockfiles for both root and UI (if UI has its own)
COPY package.json bun.lock ./
COPY ui/package.json* ui/bun.lock* ./ui/

# 2. Install all dependencies
RUN bun install --frozen-lockfile
# If the UI has its own package.json, install those deps too
RUN cd ui && bun install

# 3. Copy the rest of the source code
COPY . .

# 4. Build the project
RUN bun run build

FROM oven/bun:latest

WORKDIR /app

# 5. Copy the compiled binary and assets
COPY --from=builder /app/server ./server 
# Note: Ensure 'asset' matches your Vite build output directory (usually 'dist' or 'public')
COPY --from=builder /app/asset ./asset 

EXPOSE 3000

CMD ["./server"]