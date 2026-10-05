local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local utils = ReplicatedStorage:WaitForChild("Utils")
local NumberUtils = require(utils.NumberUtils)
local Animals = require(ReplicatedStorage.Datas.Animals)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Animals2 = require(shared.Animals)
local fireServer = Instance.new("RemoteEvent").FireServer
local remoteEvent = Net:RemoteEvent("f1a4d3a5-b97a-4622-8fd6-232663ff697e")
local AnimalPrompt = {}
AnimalPrompt.__index = AnimalPrompt

function AnimalPrompt.GetState(p)
	return p.State
end

function AnimalPrompt:SetState(state2: string, targetCallback)
	self.State = state2
	local proximityPrompt = self.ProximityPrompt
	local animalIndex = self.AnimalIndex
	local v = animalIndex and Animals[animalIndex]
	local v2

	if v then
		v2 = v.DisplayName or animalIndex
	else
		v2 = animalIndex
	end

	proximityPrompt.ObjectText = (not animalIndex or string.find(animalIndex, "None") or state2 == "Sell") and "" or v2 or animalIndex
	proximityPrompt.Enabled = state2 ~= "None"
	proximityPrompt:SetAttribute("State", state2)

	if state2 == "Sell" then
		proximityPrompt.ActionText = not animalIndex and "" or `Sell: ${NumberUtils:ToString(Animals2:GetSellValue(animalIndex), 2)}`
	elseif state2 == "Open" then
		proximityPrompt.ActionText = "Open"
	elseif state2 == "Steal" then
		proximityPrompt.ActionText = "Steal"
	elseif state2 == "Grab" then
		proximityPrompt.ActionText = "Grab"
	elseif state2 == "Place" then
		proximityPrompt.ActionText = "Place"
	elseif state2 == "Return" then
		proximityPrompt.ActionText = "Return"
	end

	if targetCallback then
		self.TargetCallback = targetCallback
	end
end

function AnimalPrompt:SetCallback(targetCallback)
	self.TargetCallback = targetCallback
end

function AnimalPrompt.new(p: number, animalIndex: string, parent, items)
	local object = setmetatable({}, AnimalPrompt)
	object.Index = p
	object.AnimalIndex = animalIndex
	object.Collector = Trove.new()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.HoldDuration = 1.5
	proximityPrompt.RequiresLineOfSight = true
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

	if items then
		for k, item in items do
			proximityPrompt[k] = item
		end
	end

	object.ProximityPrompt = proximityPrompt
	proximityPrompt.Parent = parent
	object.Collector:Add(proximityPrompt)
	object.Collector:Add(proximityPrompt.Changed:Connect(function()
		proximityPrompt.HoldDuration = 1.5
		proximityPrompt.RequiresLineOfSight = true
		proximityPrompt.MaxActivationDistance = 10
	end))
	object.Collector:Add(proximityPrompt.PromptButtonHoldBegan:Connect(function()
		proximityPrompt.HoldDuration = 1.5
		proximityPrompt.RequiresLineOfSight = true
		proximityPrompt.MaxActivationDistance = 10
	end))
	object.Collector:Add(proximityPrompt.Triggered:Connect(function()
		if object.TargetCallback then
			object.TargetCallback()
		end
	end))
	object.Collector:Add(proximityPrompt.PromptButtonHoldBegan:Connect(function()
		if object.State == "Steal" then
			fireServer(remoteEvent, workspace:GetServerTimeNow() + 50, "ba10cc43-8b93-4b7d-93b8-e1935730ebe3")
			remoteEvent:FireServer(workspace:GetServerTimeNow() + 50, "ed327974-0c39-423a-b9c7-467b8fdac46d")
		end
	end))
	return object
end

function AnimalPrompt:Destroy()
	self.Collector:Destroy()
end

return AnimalPrompt