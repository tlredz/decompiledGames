local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
local NPCManager = require(game.ReplicatedStorage.NPCManager)
local Config2 = require(script.Parent.Config)
local Presence = {}
local v = {}
local v2 = nil
local v3 = nil
local v4 = true
local v5 = false
local count = 0

function v.getQuestGiverModel()
	local v6 = v2

	if v6 then
		return v6
	end

	for _, v7 in NPCManager.getNPCsByName(Config2.QUEST_GIVER_NPC_NAME) do
		v2 = v7:getModel()
		return v2
	end

	local nPCs = workspace:FindFirstChild("NPCs")
	local model

	if nPCs then
		model = nPCs:FindFirstChild(Config2.QUEST_GIVER_NPC_NAME)
	end

	if model and model:IsA("Model") then
		v2 = model
	end

	return v2
end

function v.spawnChilling()
	local model = ReplicatedStorage.Assets.Models:FindFirstChild(Config2.CHILLING_MODEL_NAME)

	if not (model and model:IsA("Model")) then
		warn((`[{script.Parent.Name}] missing {Config2.CHILLING_MODEL_NAME} model`))
		return nil
	end

	local clone = model:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	local humanoid = clone:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayDistance = 0
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	end

	clone.Parent = workspace
	return clone
end

function v.apply()
	local questGiverModel = v.getQuestGiverModel()

	if questGiverModel then
		questGiverModel:SetAttribute(Config.HIDDEN_ATTRIBUTE, not v4 or nil)
	end

	if v4 then
		if v3 then
			v3:Destroy()
			v3 = nil
		end
	elseif not (v3 and v3.Parent) then
		v3 = v.spawnChilling()
	end
end

function v.resolveAsync()
	if v5 or v2 or v4 then
		return
	end

	count += 1
	local v6 = count
	v5 = true
	task.spawn(function()
		while v6 == count and not (v4 or v2) do
			local v7 = os.clock() + 15

			repeat
				task.wait(0.25)
			until v6 ~= count or v4 or v.getQuestGiverModel() ~= nil or v7 <= os.clock()
		end

		if v6 ~= count then
			return
		end

		v5 = false
		v.apply()
	end)
end

function Presence.setQuestGiverVisible(flag: boolean)
	v4 = flag
	v.apply()
	v.resolveAsync()
end

function Presence.getChillingModel()
	if v3 and v3.Parent then
		return v3
	end

	return nil
end

function Presence.reset()
	count += 1
	v5 = false
	v4 = true
	v.apply()
	v2 = nil
end

return Presence