### Build stage
FROM node:18-alpine as build

WORKDIR /app

# Create a non-root user for the build and use it for npm operations
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY package*.json ./
# ensure correct ownership before running npm install
RUN chown -R appuser:appgroup /app
USER appuser
ENV HOME=/home/appuser

# Install dependencies
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

### Production stage
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html

# Ensure nginx user can read the static files
RUN chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
