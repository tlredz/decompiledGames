local RunService = game:GetService("RunService")
require("../util/interval")
local module = require("../../roblox_packages/vide")
local count = 0
local v = {
	"-",
	"/",
	"|",
	"\\"
}
local source = module.source(v[1])
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total > 0.25 then
		count += 1
		source(v[count % 4 + 1])
		total = 0
	end
end)
return source