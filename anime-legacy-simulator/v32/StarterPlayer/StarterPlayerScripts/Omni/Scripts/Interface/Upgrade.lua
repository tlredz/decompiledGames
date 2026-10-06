local module = require("@game/ReplicatedStorage/Omni")
local upgrade = module.Interface:WaitForChild("Frames"):WaitForChild("Upgrade")
local v = nil
local modulesByName = {}
local Upgrade = {}

function Upgrade.Start(value: string?)
	local v2 = value or "Trial Upgrades"
	local v3 = module.Shared.Upgrade.List[v2]

	if not v3 then
		return
	end

	local v4 = modulesByName[v3.Interface]

	if not (v4 and module.Utils.PlayerStats.OwnsMap(v3.MapName, module.Data)) then
		return
	end

	if v then
		if v == v2 then
			return
		else
			Upgrade.Stop()
		end
	end

	v = v2
	v4.Start(v2)
end

function Upgrade.Stop()
	if not v then
		return
	end

	local v2 = module.Shared.Upgrade.List[v]
	local v3 = v2 and modulesByName[v2.Interface]
	v = nil

	if v3 then
		v3.Stop()
	end
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

module.Frame:OnFrameOpened(upgrade, function()
	if v then
		return
	end

	Upgrade.Start()
end)
module.Frame:OnFrameClosed(upgrade, Upgrade.Stop)
return Upgrade