local Presets = require(script:WaitForChild("Presets"))
local Styles = require(script:WaitForChild("Styles"))

function callback(p, p2)
	return warn("CRATER MODULE ERROR:\n\t\t\t\t\t" .. p .. " does not exist as a " .. p2)
end

local CraterEffects = {}

function CraterEffects.new(p: string, cframe: CFrame, ...)
	if Styles[p] then
		Styles[p](cframe, ...)
	else
		callback(p, "type")
	end
end

function CraterEffects.presets(p: string, cframe: CFrame, ...)
	if not Presets[Presets] then
		callback(p, "preset")
		return
	end

	local v, v2 = Presets[p](...)
	Styles[v](cframe, v2)
end

function CraterEffects.endConnection(p, p2)
	Styles.endConnection(p, p2)
end

return CraterEffects