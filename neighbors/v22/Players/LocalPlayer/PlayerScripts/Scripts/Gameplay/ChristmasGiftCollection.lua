local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local collectGift = script.CollectGift
local clones = {}

local function createDailyHighlight(parent)
	if not parent:IsDescendantOf(workspace) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillTransparency = 0.5
	highlight.FillColor = Color3.fromRGB(134, 255, 115)
	highlight.OutlineColor = Color3.fromRGB(55, 255, 33)
	highlight.Name = "DailyHighlight"
	highlight.Parent = parent
	highlight.Enabled = true
	return highlight
end

local function registerCollectionPoint(instance)
	if not (instance:IsA("Model") or instance:IsA("BasePart")) then
		return
	end

	local lastChristmasPresent = localPlayer:GetAttribute("LastChristmasPresent") or 0
	local v

	if os.time() - lastChristmasPresent >= 86400 then
		v = createDailyHighlight(instance)
	else
		v = nil
	end

	local clone = collectGift:Clone()
	clone.Triggered:Connect(function()
		local newCaseSpin = localPlayer.PlayerGui:FindFirstChild("NewCaseSpin")

		if newCaseSpin then
			local background = newCaseSpin:FindFirstChild("Background")

			if background and background.Visible then
				return
			end
		end

		if v then
			v:Destroy()
		end

		Network:fire("GetChristmasPresent")
	end)
	clone.ActionText = "Collect Gift"
	clone.Parent = instance
	table.insert(clones, clone)
end

localPlayer:GetAttributeChangedSignal("LastChristmasPresent"):Connect(function()
	local lastChristmasPresent = localPlayer:GetAttribute("LastChristmasPresent") or 0
	local v = os.time() - lastChristmasPresent >= 86400

	for _, v2 in pairs(clones) do
		local dailyHighlight = v2.Parent:FindFirstChild("DailyHighlight")

		if v and not dailyHighlight then
			createDailyHighlight(v2.Parent)
			v2.Enabled = true
		elseif not v then
			if dailyHighlight then
				dailyHighlight:Destroy()
			end

			v2.Enabled = false
		end
	end
end)

for _, v in pairs(CollectionService:GetTagged("ChristmasGiftCollectionPoint")) do
	registerCollectionPoint(v)
end

CollectionService:GetInstanceAddedSignal("ChristmasGiftCollectionPoint"):Connect(registerCollectionPoint)
CollectionService:GetInstanceRemovedSignal("ChristmasGiftCollectionPoint"):Connect(function(instance)
	local child = instance:FindFirstChild(collectGift.Name)

	if child then
		local index = table.find(clones, child)

		if index then
			table.remove(clones, index)
		end

		child:Destroy()
	end
end)