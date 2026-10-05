local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local parent2 = parent.Parent
local gamepasses = parent2:WaitForChild("Holder"):WaitForChild("Gamepasses")
local Monetization = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Monetization"))
local updatePlayerToGift = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("UpdatePlayerToGift")
local canGiftGamepass = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("CanGiftGamepass")
local SFX = game.SoundService:WaitForChild("SFX")
local UIController = require(ReplicatedStorage2:WaitForChild("UIController"))
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function GiftProductFor(name: string)
	return Monetization[name .. "Gift"]
end

local function BindCard(guiObject)
	local button = guiObject:FindFirstChild(guiObject.Name)

	if button and button:IsA("GuiButton") then
		button.Activated:Connect(function()
			if not parent.Visible then
				return
			end

			local giftProductFor = GiftProductFor(guiObject.Name) -- equivalent call inferred; original call site unknown

			if not giftProductFor then
				warn(string.format("Gifting: no %sGift product", guiObject.Name))
				return
			end

			local recipientUserId = parent:GetAttribute("RecipientUserId")

			if type(recipientUserId) ~= "number" or v then
				return
			end

			v = true
			local success, result = pcall(function()
				return canGiftGamepass:InvokeServer(recipientUserId, giftProductFor)
			end)
			v = false

			if not success then
				warn("Gifting: recipient pass check failed: " .. tostring(result))
				return
			end

			if not result or not parent.Visible or parent:GetAttribute("RecipientUserId") ~= recipientUserId then
				return
			end

			SFX.Click:Play()
			PurchaseCue.Play()
			MarketplaceService:PromptProductPurchase(localPlayer, giftProductFor)
		end)
	end
end

for _, guiObject in gamepasses:GetDescendants() do
	if guiObject:IsA("GuiObject") and guiObject:FindFirstChild("Owned") then
		BindCard(guiObject)
	end
end

local function RefreshOwnedBadges()
	local visible = parent.Visible

	for _, guiObject in gamepasses:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local owned = guiObject:FindFirstChild("Owned")
		local button = guiObject:FindFirstChild(guiObject.Name)

		if not (owned and button and button:IsA("GuiButton")) then
			continue
		end

		if visible then
			owned.Visible = false
			button.Visible = true
		else
			owned.Visible = owned:GetAttribute("OwnedByPlayer") == true
			button.Visible = owned:GetAttribute("OwnedByPlayer") ~= true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ExitGifting()
	updatePlayerToGift:FireServer(nil)
	parent:SetAttribute("RecipientUserId", nil)
	UIController.close(parent)
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	RefreshOwnedBadges()

	if not parent.Visible then
		updatePlayerToGift:FireServer(nil)
		parent:SetAttribute("RecipientUserId", nil)
	end
end)
parent2:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent2.Visible and parent.Visible then
		ExitGifting() -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	local noSaveData = localPlayer:WaitForChild("NoSaveData", 30)
	local playerToGift = noSaveData and noSaveData:WaitForChild("PlayerToGift", 30)

	if not playerToGift then
		return
	end

	playerToGift.Changed:Connect(function(p)
		if (tonumber(p) or 0) == 0 and parent.Visible then
			ExitGifting() -- equivalent call inferred; original call site unknown
		end
	end)
end)
RefreshOwnedBadges()