local module = require("@game/ReplicatedStorage/Omni")
local v = nil
local modulesByName = {}
local Profession = {}

function Profession.Start(p: string)
	if v then
		if v == p then
			return
		else
			Profession.Stop()
		end
	end

	local v2 = module.Shared.Profession.List[p]

	if not v2 then
		return
	end

	local v3 = modulesByName[v2.Interface]

	if not v3 then
		return
	end

	v = p
	v3.Start(p)
end

function Profession.Stop()
	if not v then
		return
	end

	local v2 = module.Shared.Profession.List[v]
	local v3 = v2 and modulesByName[v2.Interface]

	if v3 then
		v3.Stop()
	end

	v = nil
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

return Profession