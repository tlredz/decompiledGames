local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local v = {
	"Yellow",
	"Green",
	"Red",
	"Blue"
}
local v2 = Component.new({
	Tag = "NorthFinalPuzzle"
})

function v2:UpdatePrompts()
	local windElementalWindElemental4MASTERY = self.questFolder:FindFirstChild("Wind Elemental/WindElemental4-MASTERY")
	local _1 = windElementalWindElemental4MASTERY and windElementalWindElemental4MASTERY:FindFirstChild("1")
	local v3

	if _1 == nil or typeof(_1.Value) ~= "number" or not (_1.Value >= 0) then
		v3 = false
	else
		v3 = _1.Value < 4
	end

	local v4 = DataController.PlayerDataReplicator:TryIndex({ "WindElementalSacrifices" }) or {}

	for _, v5 in v do
		local prompt = self.prompts[v5]

		if not prompt then
			continue
		end

		local puzzlePrompt = self.puzzlePrompts[v5]
		local v6

		if puzzlePrompt == nil then
			v6 = false
		else
			v6 = puzzlePrompt.Enabled
		end

		prompt.Enabled = (v3 and not (v4[v5] or v6)) == true
	end
end

function v2:WatchObjective(instance)
	task.spawn(function()
		local _1 = instance:WaitForChild("1", 10)

		if not _1 then
			return
		end

		self.trove:Connect(_1:GetPropertyChangedSignal("Value"), function()
			self:UpdatePrompts()
		end)
		self:UpdatePrompts()
	end)
end

function v2:Construct()
	self.trove = Trove.new()
	self.prompts = {}
	self.puzzlePrompts = {}
end

function v2:Start()
	local shards = self.Instance:WaitForChild("Shards")

	for _, childName in v do
		local handle = shards:WaitForChild(childName):WaitForChild("handle")
		self.prompts[childName] = handle:WaitForChild("SacrificePrompt")
		local prompt = handle:FindFirstChild("Prompt")
		self.puzzlePrompts[childName] = prompt

		if prompt then
			self.trove:Connect(prompt:GetPropertyChangedSignal("Enabled"), function()
				self:UpdatePrompts()
			end)
		end
	end

	self.questFolder = legacyLocalPlayerData.fetch():WaitForChild("QuestActive")
	self.trove:Connect(self.questFolder.ChildAdded, function(p)
		if p.Name == "Wind Elemental/WindElemental4-MASTERY" then
			self:WatchObjective(p)
		end
	end)
	self.trove:Connect(self.questFolder.ChildRemoved, function(p)
		if p.Name == "Wind Elemental/WindElemental4-MASTERY" then
			self:UpdatePrompts()
		end
	end)
	local windElementalWindElemental4MASTERY = self.questFolder:FindFirstChild("Wind Elemental/WindElemental4-MASTERY")

	if windElementalWindElemental4MASTERY then
		self:WatchObjective(windElementalWindElemental4MASTERY)
	end

	self:UpdatePrompts()
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2