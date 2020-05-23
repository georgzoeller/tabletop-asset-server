require('coffeescript/register');
require('debug').inspectOpts.getters = (process.env.DEBUG_GETTERS == 'true')
require(process.argv[2])
