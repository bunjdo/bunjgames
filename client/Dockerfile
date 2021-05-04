FROM node:alpine AS builder

ENV NODE_ENV production
RUN apk add --update --no-cache g++ make python2
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

ENV PATH="./node_modules/.bin:$PATH"

COPY . ./

RUN npm run build


FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/public /app

CMD ["nginx", "-g", "daemon off;"]
