local module = require("./PassiveHandler")
local Ragebait = {
	MorphHarpoon = function(_, _, object)
		task.spawn(function()
			object:WaitUntilReady()

			while object.active do
				local button = object.core.pullButtons:SpawnButton()
				button._originalTitle = "meow"
				button.buttonObject.title.Text = "meow"
				button.progressMultiplier = 0
				object:WaitLogic(0.1)
			end
		end)
	end,
	MorphSpear = function(_, _, object)
		object:AddModifier("trueprogressefficiency", "force_final", 0.0001)
		object.trueprogspeed_format = "%s%% True Progress Speed"
	end
}
setmetatable(Ragebait, module)
return Ragebait