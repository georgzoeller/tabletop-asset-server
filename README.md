# tabletop-asset-server

# tabletop-asset-server

A support server for the tabletop-server project.


```
yarn install
cp .env .env.local
echo "TOKEN_SECRET=<SHARED SECRET>" >> .env.local
yarn start
```

This will create a content directory on disk with yaml files along with a indexdb backed pouchdb

