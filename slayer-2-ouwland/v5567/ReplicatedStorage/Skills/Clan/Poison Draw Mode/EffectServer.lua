local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local StatTypes = require(CAM.Global.Types.StatTypes)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Config = require(script.Parent.Config)
local name = script.Parent.Name

local function option(folder, name2: string, items)
	local folder2 = Instance.new("Folder")
	folder2.Name = name2
	folder2.Parent = folder
	folder2:SetAttribute("Skill", name2)

	for k, item in items do
		folder2:SetAttribute(k, item)
	end

	return folder2
end

return {
	Activate = function(p, _, parent)
		if parent == nil then
			return
		end

		local child = parent:FindFirstChild(name)

		if child == nil then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "Options"
		folder.Parent = child
		local child2 = parent:FindFirstChild(Combat_Util.DEBUFF_POOL_VALUE)

		if child2 ~= nil then
			child2:Destroy()
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = Combat_Util.DEBUFF_POOL_VALUE
		objectValue.Value = child
		objectValue.Parent = parent
		child.Destroying:Once(function()
			objectValue:Destroy()
		end)
		option(folder, "Neurotoxin Slow", {
			[StatTypes.StatToAttribute("Movement Speed Factor")] = Config.NEUROTOXIN_MOVEMENT_FACTOR,
			[StatTypes.StatToAttribute("Attack Speed Factor")] = Config.NEUROTOXIN_ATTACK_SPEED_FACTOR,
			Duration = Config.NEUROTOXIN_DURATION
		})
		local v3 = p ~= nil and 1 or Config.BOSS_VIRAL_DECAY_SCALE
		option(folder, "Viral Decay", {
			OnHitTick = "Viral Decay Tick",
			Duration = Config.VIRAL_DECAY_DURATION,
			StartPercent = Config.VIRAL_DECAY_START_PERCENT * v3,
			GrowPercent = Config.VIRAL_DECAY_GROW_PERCENT * v3,
			MaxPercent = Config.VIRAL_DECAY_MAX_PERCENT * v3
		})
	end
}