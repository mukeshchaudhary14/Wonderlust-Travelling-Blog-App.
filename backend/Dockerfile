# =========================================================================
# Multi-Stage Dockerfile for Wonderlust Backend Service (Node.js/Express)
# =========================================================================

# Stage 1: Build & Compilation Stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency definition
COPY package.json ./

# Install all dependencies (including devDependencies needed for tsc)
RUN npm install

# Copy source code and build
COPY . .
RUN npm run build

# =========================================================================
# Stage 2: Hardened Production Runtime Stage
# =========================================================================
FROM node:20-alpine AS runner

WORKDIR /app

# Set production environment variables
ENV NODE_ENV=production \
    PORT=5000

# Install curl for healthcheck and dumb-init for proper signal forwarding
RUN apk add --no-cache curl dumb-init

# Copy package definitions and install production dependencies only
COPY package.json ./
RUN npm install --omit=dev && npm cache clean --force

# Copy compiled JavaScript output and static/seed data
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/data ./data

# Change ownership to non-root node user
RUN chown -R node:node /app

# Use non-root node user (UID: 1000)
USER node

# Expose backend port
EXPOSE 5000

# Health check probing root endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Launch server with dumb-init for graceful termination handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
