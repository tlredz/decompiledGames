local BaseGeneratorFramework = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local GeneratorTrinketHandler = require(script.Parent.GeneratorTrinketHandler)
BaseGeneratorFramework.Config = {
	DefaultCompleteAmount = 20,
	DefaultSkillCheckBonus = 5,
	DefaultSkillCheckPenalty = -3,
	ProgressUpdateRate = 0.1
}

function BaseGeneratorFramework.CreateGeneratorState(instance)
	return {
		Generator = instance,
		Stats = instance:WaitForChild("Stats"),
		CurrentAmount = instance.Stats:WaitForChild("CurrentAmount"),
		RequiredAmount = instance.Stats:WaitForChild("RequiredAmount"),
		Completed = instance.Stats:WaitForChild("Completed"),
		PlayerCompletion = instance:WaitForChild("PlayerCompletion"),
		ActivePlayer = nil,
		Character = nil,
		IsRunning = false,
		StartTime = 0,
		LastUpdateTime = 0
	}
end

function BaseGeneratorFramework:InitializeGenerator(activePlayer, character)
	self.ActivePlayer = activePlayer
	self.Character = character
	self.IsRunning = true
	self.StartTime = tick()
	self.LastUpdateTime = tick()

	if self.PlayerCompletion:FindFirstChild(activePlayer.Name) then
		return self
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Name = activePlayer.Name
	numberValue.Value = 0
	numberValue.Parent = self.PlayerCompletion
	return self
end

function BaseGeneratorFramework:UpdateProgress(p)
	if not self.IsRunning or self.Completed.Value then
		return false
	end

	local value = self.CurrentAmount.Value
	local v = math.min(value + p, self.RequiredAmount.Value)
	self.CurrentAmount.Value = v
	local child = self.ActivePlayer and self.PlayerCompletion:FindFirstChild(self.ActivePlayer.Name)

	if child then
		child.Value += v - value
	end

	if self.RequiredAmount.Value <= v then
		self.Completed.Value = true
		self.IsRunning = false
		return true
	else
		return false
	end
end

function BaseGeneratorFramework:ProcessMachineEvents()
	if not (self.IsRunning and self.Character) then
		return
	end

	local now = tick()

	if now - self.LastUpdateTime >= BaseGeneratorFramework.Config.ProgressUpdateRate then
		self.LastUpdateTime = now
		GeneratorTrinketHandler.HandleMachineEvent(self.Character, self.Generator, {
			Value = self.ActivePlayer
		})
	end
end

function BaseGeneratorFramework.OnSkillCheckSuccess(player, value)
	if not player.IsRunning then
		return
	end

	local v = BaseGeneratorFramework.Config.DefaultSkillCheckBonus * (value or 1)
	BaseGeneratorFramework.UpdateProgress(player, v)

	if player.Character and player.ActivePlayer then
		GeneratorTrinketHandler.HandleSkillCheckComplete(player.Character, player.Generator, {
			Value = player.ActivePlayer
		})
	end
end

function BaseGeneratorFramework.OnSkillCheckFail(player, value)
	if not player.IsRunning then
		return
	end

	local v = BaseGeneratorFramework.Config.DefaultSkillCheckPenalty * (value or 1)
	BaseGeneratorFramework.UpdateProgress(player, v)
	local v2 = not (player.Character and player.ActivePlayer) or GeneratorTrinketHandler.HandleSkillCheckFail(
		player.Character,
		player.Generator,
		{
			Value = player.ActivePlayer
		}
	)
	local machineEvent = v2 and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("MachineEvent")

	if machineEvent then
		machineEvent:Fire(player.ActivePlayer, player.Generator)
	end

	return v2
end

function BaseGeneratorFramework:CleanupGenerator()
	self.IsRunning = false
	self.ActivePlayer = nil
	self.Character = nil
end

BaseGeneratorFramework.MinigameTemplate = {
	Name = "ExampleMinigame",
	Initialize = function(_, _) end,
	Start = function(_) end,
	Update = function(_, _) end,
	HandleInput = function(_, _, _) end,
	Cleanup = function(p)
		BaseGeneratorFramework.CleanupGenerator(p)
	end
}
return BaseGeneratorFramework