local RunService = game:GetService("RunService")
local module = require("../../roblox_packages/vide")
local cleanup = module.cleanup
return function(p: number, callback)
	local source = module.source(callback(0))
	local total = 0
	cleanup(RunService.Heartbeat:Connect(function(dt)
		total += dt

		if p < total then
			source(callback(total))
			total = 0
		end
	end))
	return source
end