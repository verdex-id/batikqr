FROM oven/bun:latest AS builder

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install --frozen-lockfile

COPY . .

RUN bun run build

FROM oven/bun:latest

WORKDIR /app

COPY --from=builder /app/server ./server 
COPY --from=builder /app/asset ./asset 

EXPOSE 3000

CMD ["./server"] 