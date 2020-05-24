FROM node:14.3
WORKDIR /usr/src/app



COPY package*.json ./
RUN ["yarn", "install"]

EXPOSE 3009/tcp

RUN ["yarn", "start"]
CMD ["yarn","serve"]
