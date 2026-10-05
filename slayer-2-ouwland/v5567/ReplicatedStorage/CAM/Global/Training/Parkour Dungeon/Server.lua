local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local DungeonQuestCredit = require(ServerStorage.SAM.Utility.DungeonQuestCredit)
local v = { "Double Jump", "Wall Climb" }

local function getSwitchsFolder()
	local parkourTraining = workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining")
	local switchs = parkourTraining and parkourTraining:FindFirstChild("Switchs")

	if switchs and switchs:IsA("Folder") then
		return switchs
	end

	return nil
end

local ParkourDungeon = {}
ParkourDungeon.PromptsEnabled = false

function ParkourDungeon.Do(p, _, _, instance)
	local hasUnlockedSkills, _ = Character_info_provider.HasUnlockedSkills(p, v)

	if not hasUnlockedSkills then
		return
	end

	local parkourTraining = workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining")

	if parkourTraining == nil then
		return
	end

	local v2 = createVector(1, 1, 1) * 1e999
	local v3 = createVector(1, 1, 1) * -1e999

	for _, v4 in parkourTraining:QueryDescendants("BasePart") do
		v2 = v2:Min(v4.Position)
		v3 = v3:Max(v4.Position)
	end

	instance:SetAttribute("LeashCenter", (v2 + v3) / 2)
	instance:SetAttribute("LeashRadius", (v3 - v2).Magnitude / 2 + 100)
	return true
end

function ParkourDungeon.StateChanged(_, instance, p, model)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return
	end

	local parkourTraining = workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining")
	local switchs = parkourTraining and parkourTraining:FindFirstChild("Switchs")

	if not (switchs and switchs:IsA("Folder")) then
		switchs = nil
	end

	if switchs == nil or not model:IsDescendantOf(switchs) then
		return
	end

	local primaryPart = instance and instance.PrimaryPart

	if primaryPart == nil or (primaryPart.Position - model:GetPivot().Position).Magnitude > 20 then
		return
	end

	p.PulledSwitches = p.PulledSwitches or {}
	p.PulledSwitches[model] = true
end

function ParkourDungeon.Stop(instance, instance2, p)
	local v2 = false

	if instance2 ~= nil then
		local primaryPart = instance2.PrimaryPart

		if primaryPart ~= nil then
			local final = workspace.Map.DetachedMaps.ParkourTraining:FindFirstChild("Final")
			v2 = final ~= nil and vector.magnitude(primaryPart.Position - final.Position) <= 75 or false
		end
	end

	local v3 = false
	local parkourTraining = workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining")
	local switchs = parkourTraining and parkourTraining:FindFirstChild("Switchs")

	if not (switchs and switchs:IsA("Folder")) then
		switchs = nil
	end

	if switchs ~= nil then
		local count = #switchs:GetChildren()
		local count2 = 0

		if p.PulledSwitches then
			for _ in p.PulledSwitches do
				count2 += 1
			end
		end

		if count > 0 then
			v3 = count <= count2
		else
			v3 = false
		end
	end

	if v2 and v3 then
		DungeonQuestCredit(instance, "Parkour Dungeon", "Complete")
		local hearts = tonumber(instance:GetAttribute("Hearts")) or 0
		local maxHearts = tonumber(instance:GetAttribute("MaxHearts")) or 0

		if hearts > 0 and hearts < maxHearts then
			instance:SetAttribute("Hearts", hearts + 1)
		end
	end

	return true, v2 and v3
end

return ParkourDungeon