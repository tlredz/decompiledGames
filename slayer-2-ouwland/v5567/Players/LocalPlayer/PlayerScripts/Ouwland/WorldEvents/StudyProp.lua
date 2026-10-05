local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local inventory = Utility.GetData(Players.LocalPlayer, true):WaitForChild("Inventory"):WaitForChild("Inventory")

local function gate(instance)
	local item = instance:GetAttribute("Item")
	local proximityPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt", true)

	if type(item) ~= "string" or proximityPrompt == nil then
		return
	end

	proximityPrompt.Enabled = not instance:GetAttribute("Locked") and inventory:FindFirstChild(item .. " Schematic") == nil
end

local function refresh()
	for _, v in CollectionService:GetTagged("StudyProp") do
		gate(v)
	end
end

local function track(instance)
	gate(instance)
	instance.DescendantAdded:Connect(function(proximityPrompt)
		if proximityPrompt:IsA("ProximityPrompt") then
			gate(instance)
		end
	end)
	instance:GetAttributeChangedSignal("Locked"):Connect(function()
		gate(instance)
	end)
end

inventory.ChildAdded:Connect(refresh)
inventory.ChildRemoved:Connect(refresh)

for _, v in CollectionService:GetTagged("StudyProp") do
	track(v)
end

CollectionService:GetInstanceAddedSignal("StudyProp"):Connect(track)