require(script.Promise)
require(script.types)
local createRemotes = require(script.createRemotes)
local builder = require(script.builder)
local getSender = require(script.getSender)
local loggerMiddleware = require(script.middleware.loggerMiddleware)
local throttleMiddleware = require(script.middleware.throttleMiddleware)
return {
	remote = builder.remote,
	namespace = builder.namespace,
	createRemotes = createRemotes,
	loggerMiddleware = loggerMiddleware,
	throttleMiddleware = throttleMiddleware,
	getSender = getSender
}