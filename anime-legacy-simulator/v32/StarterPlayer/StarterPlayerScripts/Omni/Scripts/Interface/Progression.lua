local module = require("@game/ReplicatedStorage/Omni")
local State = require(script.State)
local v = nil
local v2 = nil
local modulesByName = {}
local v3 = nil
local Progression = {}

function Progression.Start(p: string)
	if v then
		if v == p then
			return
		else
			Progression.Stop()
		end
	end

	local v4 = module.Shared.Progression.List[p]

	if not v4 then
		return
	end

	local v5 = modulesByName[v4.Interface]

	if not v5 then
		return
	end

	if not module.Utils.PlayerStats.OwnsMap(v4.MapName, module.Data) then
		module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
			Message = "You don't have access to this progression.",
			Color = Color3.new(1, 0, 0)
		})
		return
	end

	v = p
	v5.Start(p)
end

function Progression.Stop()
	if not v then
		return
	end

	local v4 = module.Shared.Progression.List[v]
	local v5 = v4 and modulesByName[v4.Interface]

	if v5 then
		v5.Stop()
	end

	v = nil
end

local function GetNextEligibleAutoUpgrade()
	local v4 = {}
	local progression = module.Data.Progression
	local auto

	if typeof(progression) == "table" then
		auto = progression.Auto
	else
		auto = false
	end

	if typeof(auto) ~= "table" then
		return nil
	end

	for k, v5 in auto do
		if typeof(k) == "string" and v5 == true then
			table.insert(v4, k)
		end
	end

	if #v4 == 0 then
		v3 = nil
		return nil
	end

	table.sort(v4)
	local v5 = 1

	if v3 then
		local index = table.find(v4, v3)

		if index then
			v5 = index % #v4 + 1
		end
	end

	for i = 0, #v4 - 1 do
		local v6 = v4[(v5 - 1 + i) % #v4 + 1]

		if State.Get(v6).CanUpgrade then
			return v6
		end
	end

	return nil
end

local loopConnection = module.Utils.Loop:Connect({
	Time = 0.3,
	Identifier = "ProgressionAutoUpgradeLoop",
	Callback = function()
		if not module.Loaded then
			return
		end

		local nextEligibleAutoUpgrade = GetNextEligibleAutoUpgrade()

		if not nextEligibleAutoUpgrade then
			return
		end

		v3 = nextEligibleAutoUpgrade
		module.Signal:Fire("General", "Progression", "Upgrade", nextEligibleAutoUpgrade)
	end
})

for _, moduleScript in script:GetChildren() do
	if not (moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "State") then
		continue
	end

	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

script.Destroying:Connect(function()
	Progression.Stop()

	if loopConnection then
		loopConnection:Disconnect()
	end

	table.clear(modulesByName)
end)
module.Button:Create(module.Interface.Frames.Progression.Currency.More, "Small"):BindFunction("Commerce", function()
	if v and module.Shared.Progression.List[v] then
		v2 = v
		module.Signal:FireSelf("Interface", "GemProducts", "Open", "Progression", v, "Progression")
	end
end)
module.Frame:OnFrameOpened("Progression", function()
	local v4 = v2
	v2 = nil

	if v4 and not v then
		Progression.Start(v4)
	end
end)
return Progression