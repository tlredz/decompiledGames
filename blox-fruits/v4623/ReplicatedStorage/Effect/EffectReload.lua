local RunService = game:GetService("RunService")
local Rewire = require(script:WaitForChild("Rewire"))
local hotReloader = Rewire.HotReloader
local v

if RunService:IsStudio() then
	v = hotReloader.new()
else
	v = nil
end

local v2 = {}

local function setupHotReload(moduleScript)
	if v then
		if v2[moduleScript] ~= nil then
			return
		end

		v:listen(moduleScript, function(moduleScript2, p)
			local v3 = v2
			local module = require(moduleScript2)
			v3[moduleScript] = module

			if p.isReloading then
				warn("Hot-reloaded effect module:", moduleScript:GetFullName())
			end
		end, function() end)
	else
		local v3 = v2
		local module = require(moduleScript)
		v3[moduleScript] = module
	end
end

return {
	getEffectImpl = function(moduleScript)
		if not RunService:IsStudio() then
			return require(moduleScript)
		end

		setupHotReload(moduleScript)
		return v2[moduleScript]
	end
}