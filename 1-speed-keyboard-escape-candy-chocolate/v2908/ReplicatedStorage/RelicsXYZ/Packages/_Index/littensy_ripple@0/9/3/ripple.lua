require(script.types)
return {
	createMotion = require(script.createMotion),
	config = require(script.config),
	immediate = require(script.solvers.immediate),
	linear = require(script.solvers.linear),
	spring = require(script.solvers.spring),
	tween = require(script.solvers.tween)
}