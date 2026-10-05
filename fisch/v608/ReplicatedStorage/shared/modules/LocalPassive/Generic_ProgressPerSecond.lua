local module = require("./PassiveHandler")
local GenericProgressPerSecond = {
	MorphSpear = true,
	Morph = function(p, p2, object)
		if (p.config.ProgressPerSecond or 0) <= 0 then
			return
		end

		task.spawn(function()
			object:WaitUntilReady()
			local interval = p.config.Interval or 1

			while p2.Parent and p.current == object do
				object:WaitLogic(interval)

				if not p2.Parent or p.current ~= object then
					break
				end

				object:AddProgress(p.config.ProgressPerSecond)
			end
		end)
	end
}
setmetatable(GenericProgressPerSecond, module)
return GenericProgressPerSecond