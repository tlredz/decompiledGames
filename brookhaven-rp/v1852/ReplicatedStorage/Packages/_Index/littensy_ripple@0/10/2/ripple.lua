local module = require("@self/config")
local module2 = require("@self/easing")
local module3 = require("@self/motion")
local module4 = require("@self/spring")
local module5 = require("@self/tween")
require("@self/types")
return {
	config = module,
	easing = module2,
	createMotion = module3.createMotion,
	motionScheduler = module3.scheduler,
	createSpring = module4.createSpring,
	springScheduler = module4.scheduler,
	createTween = module5.createTween,
	tweenScheduler = module5.scheduler
}