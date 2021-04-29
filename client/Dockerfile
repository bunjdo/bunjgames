FROM node:alpine AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

ENV PATH="./node_modules/.bin:$PATH"

COPY . ./

RUN npm run build



FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build /app

CMD ["nginx", "-g", "'daemon off;'"]

