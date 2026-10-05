local module = require("../../Ripple")
local module2 = require("../../Vide")
local module3 = require("../../../../tests/test")
local module4 = require("../useMotion")
module3("should update binding when goal is set", function()
	local v = nil
	local v2 = nil
	module2.root(function()
		v, v2 = module4(0)
		v2:setGoal(1, {
			tween = {
				duration = 0
			}
		})
	end)
	module.motionScheduler.step(1)
	assert(v() == 1, (`Expected motion to reach goal, got {v()}`))
end)
return {}