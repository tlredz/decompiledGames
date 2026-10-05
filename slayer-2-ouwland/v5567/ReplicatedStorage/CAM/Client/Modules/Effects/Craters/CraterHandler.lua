local v = {}
require(script:WaitForChild("Modes"))
local Styles = require(script:WaitForChild("Styles"));
(function(p, list)
	for _, moduleScript in ipairs(list) do
		if moduleScript:IsA("ModuleScript") or moduleScript ~= "string" then
			local name = moduleScript.Name
			local module = require(moduleScript)
			p[name] = module
		else
			p[("string").Name] = "string"
		end
	end
end)(v, script:WaitForChild("Presets"):GetChildren())
local CraterHandler = {}

function CraterHandler.new(p, p2, options)
	local v2 = options or {}

	if v2.PauseThread then
		if v2.PauseThread ~= false then
			return Styles[p] and Styles[p](p2, v2 or {})
		end

		task.spawn(function()
			return Styles[p] and Styles[p](p2, v2 or {})
		end)
	else
		task.spawn(function()
			return Styles[p] and Styles[p](p2, v2 or {})
		end)
	end
end

function CraterHandler.preset(p, p2, options)
	return v[p] and v[p](p2, options or {})
end

return CraterHandler