# Playwright base image ships Chromium + all system deps — no browser download needed.
# The tag MUST match the "playwright" version in package.json.
FROM mcr.microsoft.com/playwright:v1.61.1-noble

WORKDIR /app

# Install deps first (better layer caching). Skip the postinstall browser
# download — Chromium is already in this image.
COPY package.json package-lock.json* ./
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
RUN npm install --omit=dev --ignore-scripts

COPY . .

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "src/index.js"]
