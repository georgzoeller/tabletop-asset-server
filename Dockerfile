FROM node:14.3
WORKDIR /usr/src/app

ENV DEBUG=-
ENV PORT=3009
ENV NODE_ENV=development

COPY package*.json ./
COPY . .
COPY .env ./.env.local

RUN ["yarn", "install"]

EXPOSE 3009/tcp

RUN ["yarn", "start"]
CMD ["yarn","serve"]
