
pack = require '../package.json'
program = require('commander').version(pack.version)
Listr = require 'listr'

fs = require 'fs-extra'
yaml = require 'js-yaml'

context = program
context.config =  yaml.safeLoad fs.readFileSync 'config.yaml', 'utf8'
context.tasks = []
context.modules = {}


program
  .option  '-d, --debug', 'output extra debugging'
  .option "-t --type <type>", "the type of build (#{Object.keys(context.config.tasks).join(', ')})", Object.keys(context.config.tasks)[0]


program.parse process.argv

process.on 'unhandledRejection', (reason, p) ->
  console.log('Unhandled Rejection at: Promise', p, 'reason:', reason)
  process.exit()


context.createTask = (context, t) ->
  ctor = require "#{process.cwd()}/src/tasks/#{t.type}"
  {title: t.name + " #{(JSON.stringify t.args||{})}", task: -> ctor(context, t.args||{})}

context.tasks.push {
  title: 'Validating config'
  task: () =>
    throw new Error 'Error: .env.local PORT=number (Web server port) must be set.'  if not process.env.PORT?
    throw new Error 'Error: .env.local PORT=number (Web server port) must be a number.'  if isNaN parseInt process.env.PORT
    throw new Error 'Error: .env.local TOKEN_SECRET=string (Shared JWT Secret) must be set.' if not process.env.TOKEN_SECRET?
    throw new Error 'Error: config.yaml must exist in process root' if not fs.existsSync './config.yaml'
}

context.tasks.push configTask for configTask in context.config.tasks[program.type].map (t) -> context.createTask context, t


run = new Listr(context.tasks)

run.run()



