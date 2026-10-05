local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local data = Utility.GetData(Players.LocalPlayer, true)
local inventory = data:WaitForChild("Inventory"):WaitForChild("Inventory")
local worldEvents = data:WaitForChild("WorldEvents")

local function gate(part)
	local v = inventory:FindFirstChild("Serpent Key") ~= nil
	local v2

	if part:IsA("BasePart") and part:HasTag("SerpentKey") then
		local key = part:GetAttribute("Key")
		local serpentKeyHeld = worldEvents:FindFirstChild("SerpentKeyHeld")
		local serpentKeysTried = worldEvents:FindFirstChild("SerpentKeysTried")

		if v and serpentKeyHeld ~= nil and serpentKeyHeld.Value == key then
			v2 = true
		elseif serpentKeysTried == nil then
			v2 = false
		else
			v2 = serpentKeysTried:FindFirstChild((tostring(key))) ~= nil
		end

		part.Transparency = v2 and 1 or 0
		part.CanCollide = not v2
	else
		v2 = false
	end

	local proximityPrompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)

	if proximityPrompt == nil then
		return
	end

	local enabled

	if part:HasTag("SerpentBox") then
		enabled = v and inventory:FindFirstChild("Nightfall Serpent Katana Schematic") == nil
	else
		enabled = not (v or v2)
	end

	proximityPrompt.Enabled = enabled
end

local function refresh()
	for _, tag in { "SerpentKey", "SerpentBox" } do
		for _, v in CollectionService:GetTagged(tag) do
			gate(v)
		end
	end
end

local function track(instance)
	gate(instance)
	instance.DescendantAdded:Connect(function(proximityPrompt)
		if proximityPrompt:IsA("ProximityPrompt") then
			gate(instance)
		end
	end)
end

inventory.ChildAdded:Connect(refresh)
inventory.ChildRemoved:Connect(refresh)
worldEvents.DescendantAdded:Connect(refresh)
worldEvents.ChildRemoved:Connect(refresh)

for _, tag in { "SerpentKey", "SerpentBox" } do
	for _, v in CollectionService:GetTagged(tag) do
		gate(v)
		local v2 = v
		v.DescendantAdded:Connect(function(proximityPrompt)
			if proximityPrompt:IsA("ProximityPrompt") then
				gate(v2)
			end
		end)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(track)
end