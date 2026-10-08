# =========================================================================
# Multi-Stage Dockerfile for Wonderlust Frontend (React 18 + Vite + Tailwind)
# =========================================================================

# Stage 1: Build & Compilation Stage
FROM node:20-alpine AS builder

WORKDIR /app

# Accept API Path build argument (defaults to relative "" for Nginx proxying)
ARG VITE_API_PATH=""
ENV VITE_API_PATH=$VITE_API_PATH

# Install dependencies
COPY package.json ./
RUN npm install

# Copy source and build static bundle
COPY . .
RUN npm run build

# =========================================================================
# Stage 2: Hardened Nginx Production Runtime Stage
# =========================================================================
FROM nginx:alpine AS runner

# Install curl for container healthcheck
RUN apk add --no-cache curl

# Remove default static pages
RUN rm -rf /usr/share/nginx/html/*

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy production build assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Adjust ownership and permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Health check probing /healthz endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/healthz || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
