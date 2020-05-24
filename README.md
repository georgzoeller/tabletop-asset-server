# tabletop-asset-server

# tabletop-asset-server

A support server for the tabletop-server project.


```
yarn install
```

## Configuration

```
yarn install
```

This will create a content directory on disk with yaml files along with a indexdb backed pouchdb


## Running


To build the initial database of assets:

```
yarn start
```


To run the webserver after the dtabase has been created
```
yarn serve
```


## Task System

To modify or add the tasks that are run, have a look at `config.yaml`



## PouchDB frontend

To view / manipulate the pouchdb database one can use pouchdb-server if wanted

```
npm install -g pouchdb-server
pouchdb-server -d /var -p 3010
open http://localhost:5894/_utils/
```

for databases for the modules to show up in the Futon UI, just create them in the frontend once.


## Using a remote database

By default pouchdb uses leveldown as a storage adapter to persist the database on disk. To use a remote database (pouch/couchdb) instead,
modify `args.location` for the database tasks accordingly

```
  location: http://127.0.0.1:3010
``


