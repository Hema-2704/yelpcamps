# Dockerfile tailored for YelpCamp
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies (use legacy-peer-deps to avoid peer conflicts)
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# Copy source
COPY . .

# If you have a frontend build step, uncomment:
# RUN npm run build

# Runtime image
FROM node:18-alpine
WORKDIR /app

# Copy from builder stage
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3300

# Use npm start so package.json controls the entrypoint
CMD ["npm", "start"]
