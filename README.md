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


To run the webserver after the database has been created

```
yarn serve
```

## Routes

Currently the only functional route is:

```http://localhost:3009:/assets/:type/:module/:id```

where

```
  type: ['monsters','spells','items']
  module: Any of the ones configured in config.yaml, for example 'core'
  id: a mout/slugified name string such as 'aboleth' or 'lightning-bolt'
```
e.g.

```http://localhost:3009:/assets/monstes/core/aboleth```

## Task System

To modify or add the tasks that are run, have a look at `config.yaml`

### Adding new tasks

To add new tasks, add the definition in src/tasks (or use one of the existing definitions) and under config.yaml .tasks either into the 'full' task flow or into your own custom flow (which can by run with ```yarn start --type <flow>```).


## PouchDB frontend (optional)

To view / manipulate the pouchdb database one can use pouchdb-server if wanted

```
npm install pouchdb-server
yarn pouch
open http://localhost:5894/_utils/
```

for databases for the modules to show up in the Futon UI, just create them in the frontend once.



## Using a remote database

By default pouchdb uses leveldown as a storage adapter to persist the database on disk. To use a remote database (pouch/couchdb) instead,
modify `args.location` for the database tasks accordingly

```
  location: http://127.0.0.1:3010
```