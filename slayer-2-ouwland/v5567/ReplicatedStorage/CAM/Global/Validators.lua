local modulesByName = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local v = {}
return {
	Get = function(p: string)
		local v2 = modulesByName[p]

		if v2 == nil and v[p] == nil then
			v[p] = true
			warn((`[Validators] no validator named "{p}"`))
		end

		return v2
	end
}