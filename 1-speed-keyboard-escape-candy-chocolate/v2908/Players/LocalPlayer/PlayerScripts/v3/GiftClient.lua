local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local giftAction = nil

local function getGiftAction()
	if not giftAction then
		giftAction = remotes:FindFirstChild("GiftAction")
	end

	return giftAction
end

local function getGiftModalElement(p, p2)
	if p2 then
		local parent = p2.Parent

		while parent and parent ~= game do
			if CollectionService:HasTag(parent, "GiftToPlayerModal") then
				for _, descendant in ipairs(parent:GetDescendants()) do
					if CollectionService:HasTag(descendant, "GiftToPlayer") and descendant:GetAttribute("Type") == p then
						return descendant
					end
				end
			end

			parent = parent.Parent
		end
	end

	local v = nil

	for _, guiObject in ipairs(CollectionService:GetTagged("GiftToPlayer")) do
		if not (guiObject:IsDescendantOf(playerGui) and guiObject:GetAttribute("Type") == p) then
			continue
		end

		if guiObject:IsA("GuiObject") and guiObject.Visible then
			local layerCollector = guiObject:FindFirstAncestorWhichIsA("LayerCollector")

			if layerCollector and layerCollector.Enabled then
				return guiObject
			end
		end

		v = guiObject
	end

	return v
end

local function getGiftModal(p)
	if p then
		local parent = p.Parent

		while parent and parent ~= game do
			if CollectionService:HasTag(parent, "GiftToPlayerModal") then
				return parent
			else
				parent = parent.Parent
			end
		end
	end

	local v = nil

	for _, guiObject in ipairs(CollectionService:GetTagged("GiftToPlayerModal")) do
		if not guiObject:IsDescendantOf(playerGui) then
			continue
		end

		if guiObject:IsA("GuiObject") and guiObject.Visible then
			local layerCollector = guiObject:FindFirstAncestorWhichIsA("LayerCollector")

			if layerCollector and layerCollector.Enabled then
				return guiObject
			end
		end

		v = guiObject
	end

	return v
end

local targetUserId = nil
local targetName = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPlayerPreview(p)
	targetUserId = nil
	targetName = nil
	local giftModalElement = getGiftModalElement("AvatarImage", p)

	if giftModalElement then
		giftModalElement.Image = ""
	end

	local giftModalElement2 = getGiftModalElement("PlayerNameLabel", p)

	if giftModalElement2 then
		giftModalElement2.Text = ""
	end
end

local v3 = nil
local resolveUsername

resolveUsername = function(text, p)
	if flag then
		v3 = text
	elseif text and text ~= "" then
		flag = true
		v3 = nil
		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(text)
		end)

		if success and result then
			targetUserId = result
			targetName = text
			local giftModalElement = getGiftModalElement("AvatarImage", p)

			if giftModalElement then
				local success2, result2 = pcall(function()
					return Players:GetUserThumbnailAsync(
						result,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size150x150
					)
				end)

				if success2 and result2 then
					giftModalElement.Image = result2
				end
			end

			local giftModalElement2 = getGiftModalElement("PlayerNameLabel", p)

			if giftModalElement2 then
				giftModalElement2.Text = text
			end
		else
			clearPlayerPreview(p) -- equivalent call inferred; original call site unknown
			local giftModalElement = getGiftModalElement("PlayerNameLabel", p)

			if giftModalElement then
				giftModalElement.Text = "Player not found"
			end
		end

		flag = false

		if v3 and v3 ~= text then
			local v4 = v3
			v3 = nil
			task.defer(function()
				resolveUsername(v4, p)
			end)
		end
	else
		clearPlayerPreview(p) -- equivalent call inferred; original call site unknown
		v3 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openGiftModal(p)
	PlayerUpgradesInventoryUI.openGiftModal(p)
	targetUserId = nil
	targetName = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeGiftModal(button)
	local giftModal = getGiftModal(button)

	if giftModal then
		giftModal:SetAttribute("GiftType", nil)
	end

	targetUserId = nil
	targetName = nil

	if giftModal and ClientState.ActiveModal == giftModal then
		ClientState:CloseCurrentModal()
	end
end

local function setupBuyTreadmillButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	local action = button:GetAttribute("Action")
	local type = button:GetAttribute("Type")

	if action and type then
		button.Activated:Connect(function()
			if not button:IsDescendantOf(playerGui) then
				return
			end

			if action == "Buy" then
				local v4 = GiftConfig.TREADMILL_GIFTS[type]

				if v4 then
					MarketplaceService:PromptGamePassPurchase(localPlayer, v4.GamepassId)
				end
			elseif action == "Gift" then
				openGiftModal(type) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

local tagged = CollectionService:GetTagged("BuyTreadmill")

for _, v4 in ipairs(tagged) do
	local v5 = v4
	task.defer(function()
		setupBuyTreadmillButton(v5)
	end)
end

CollectionService:GetInstanceAddedSignal("BuyTreadmill"):Connect(function(p)
	task.defer(function()
		setupBuyTreadmillButton(p)
	end)
end)

local function setupBuyTrailButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	local action = button:GetAttribute("Action")
	local type = button:GetAttribute("Type")

	if action and type then
		button.Activated:Connect(function()
			if not button:IsDescendantOf(playerGui) then
				return
			end

			if action == "Buy" then
				local trailData = PlayerUpgradesCatalog.GetTrailData(type)

				if trailData and trailData.DevProduct and trailData.DevProduct > 0 then
					MarketplaceService:PromptProductPurchase(localPlayer, trailData.DevProduct)
				elseif trailData and trailData.Gamepass and trailData.Gamepass > 0 then
					MarketplaceService:PromptGamePassPurchase(localPlayer, trailData.Gamepass)
				end
			elseif action == "Gift" then
				openGiftModal(type) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

for _, v4 in ipairs(CollectionService:GetTagged("BuyTrail")) do
	local v5 = v4
	task.defer(function()
		setupBuyTrailButton(v5)
	end)
end

CollectionService:GetInstanceAddedSignal("BuyTrail"):Connect(function(p)
	task.defer(function()
		setupBuyTrailButton(p)
	end)
end)

local function setupBuyAuraButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	local action = button:GetAttribute("Action")
	local type = button:GetAttribute("Type")

	if action and type then
		button.Activated:Connect(function()
			if not button:IsDescendantOf(playerGui) then
				return
			end

			if action == "Buy" then
				local auraData = PlayerUpgradesCatalog.GetAuraData(type)

				if auraData and auraData.DevProduct and auraData.DevProduct > 0 then
					MarketplaceService:PromptProductPurchase(localPlayer, auraData.DevProduct)
				elseif auraData and auraData.gamepass then
					MarketplaceService:PromptGamePassPurchase(localPlayer, auraData.gamepass)
				end
			elseif action == "Gift" then
				openGiftModal(type) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

for _, v4 in ipairs(CollectionService:GetTagged("BuyAura")) do
	local v5 = v4
	task.defer(function()
		setupBuyAuraButton(v5)
	end)
end

CollectionService:GetInstanceAddedSignal("BuyAura"):Connect(function(p)
	task.defer(function()
		setupBuyAuraButton(p)
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupGiftItemButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	button.Activated:Connect(function()
		if not button:IsDescendantOf(playerGui) then
			return
		end

		local itemKey = button:GetAttribute("ItemKey")

		if not itemKey or itemKey == "" then
			return
		end

		openGiftModal(itemKey) -- equivalent call inferred; original call site unknown
	end)
end

for _, v4 in ipairs(CollectionService:GetTagged("GiftItem")) do
	local v5 = v4
	task.defer(function()
		setupGiftItemButton(v5) -- equivalent call inferred; original call site unknown
	end)
end

CollectionService:GetInstanceAddedSignal("GiftItem"):Connect(function(p)
	task.defer(function()
		setupGiftItemButton(p) -- equivalent call inferred; original call site unknown
	end)
end)

local function setupUsernameInput(textBox)
	if not (textBox:IsA("TextBox") and textBox:GetAttribute("Type") == "UsernameInput") then
		return
	end

	local thread = nil

	local function triggerResolve()
		if not textBox:IsDescendantOf(playerGui) then
			return
		end

		local text = textBox.Text

		if text and #text > 0 then
			task.spawn(function()
				resolveUsername(text, textBox)
			end)
			return
		end

		clearPlayerPreview(textBox) -- equivalent call inferred; original call site unknown
	end

	textBox.FocusLost:Connect(function(_)
		triggerResolve()
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not textBox:IsDescendantOf(playerGui) then
			return
		end

		local text = textBox.Text

		if thread then
			task.cancel(thread)
		end

		if text and #text > 1 then
			thread = task.delay(0.6, function()
				triggerResolve()
			end)
		elseif not text or text == "" then
			clearPlayerPreview(nil) -- equivalent call inferred; original call site unknown
		end
	end)
end

for _, v4 in ipairs(CollectionService:GetTagged("GiftToPlayer")) do
	local v5 = v4
	task.defer(function()
		setupUsernameInput(v5)
	end)
end

CollectionService:GetInstanceAddedSignal("GiftToPlayer"):Connect(function(p)
	task.defer(function()
		setupUsernameInput(p)
	end)
end)
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelPendingGift(devProductId)
	if not giftAction then
		giftAction = remotes:FindFirstChild("GiftAction")
	end

	local v4 = giftAction

	if not v4 then
		return
	end

	pcall(function()
		v4:InvokeServer("CancelGift", {
			DevProductId = devProductId
		})
	end)
end

local function setupSendGiftButton(button)
	if not (button:IsA("GuiButton") and button:GetAttribute("Type") == "SendGiftButton") then
		return
	end

	button.Activated:Connect(function()
		if not button:IsDescendantOf(playerGui) or flag2 then
			return
		end

		while flag do
			task.wait(0.1)
		end

		local giftModal = getGiftModal(button)
		local giftType = giftModal and giftModal:GetAttribute("GiftType")

		if not (giftType and (targetUserId and targetName)) then
			return
		end

		if targetUserId == localPlayer.UserId and not RunService:IsStudio() then
			local giftModalElement = getGiftModalElement("PlayerNameLabel", button)

			if giftModalElement then
				giftModalElement.Text = "Can't gift yourself!"
			end
		else
			flag2 = true

			if not giftAction then
				giftAction = remotes:FindFirstChild("GiftAction")
			end

			local v4 = giftAction

			if not v4 then
				flag2 = false
				return
			end

			local success, result = pcall(function()
				return v4:InvokeServer("RegisterGift", {
					TargetUserId = targetUserId,
					TargetName = targetName,
					GiftType = giftType,
					GiftSource = giftModal:GetAttribute("GiftSource"),
					GiftSourceSlotId = giftModal:GetAttribute("GiftSourceSlotId")
				})
			end)

			if success and result and result.Success then
				local v5 = targetName
				local devProductId = result.DevProductId
				local promptProductPurchaseFinishedConnection = nil
				local flag3 = false
				promptProductPurchaseFinishedConnection = MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
					if p ~= localPlayer.UserId or p2 ~= devProductId or flag3 then
						return
					end

					flag3 = true
					promptProductPurchaseFinishedConnection:Disconnect()

					if p3 then
						SoundManager:Play("BUY")
						NotificationSystem:ShowGeneralNotification(
							"Gift sent to " .. v5 .. "!",
							Color3.fromRGB(85, 255, 127)
						)
						closeGiftModal(button) -- equivalent call inferred; original call site unknown
					else
						cancelPendingGift(devProductId) -- equivalent call inferred; original call site unknown
						SoundManager:Play("ERROR")
						NotificationSystem:ShowGeneralNotification("Gift cancelled.", Color3.fromRGB(255, 85, 85))
					end

					flag2 = false
				end)
				task.delay(120, function()
					if not flag3 then
						flag3 = true
						promptProductPurchaseFinishedConnection:Disconnect()
						cancelPendingGift(devProductId) -- equivalent call inferred; original call site unknown
						flag2 = false
					end
				end)
				MarketplaceService:PromptProductPurchase(localPlayer, devProductId)
			else
				SoundManager:Play("ERROR")
				local error = result and result.Error or "Error"
				NotificationSystem:ShowGeneralNotification(error, Color3.fromRGB(255, 85, 85))
				flag2 = false
			end
		end
	end)
end

for _, v4 in ipairs(CollectionService:GetTagged("GiftToPlayer")) do
	local v5 = v4
	task.defer(function()
		setupSendGiftButton(v5)
	end)
end

CollectionService:GetInstanceAddedSignal("GiftToPlayer"):Connect(function(p)
	task.defer(function()
		setupSendGiftButton(p)
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCloseButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	button.Activated:Connect(function()
		if not button:IsDescendantOf(playerGui) then
			return
		end

		closeGiftModal(button) -- equivalent call inferred; original call site unknown
	end)
end

for _, v4 in ipairs(CollectionService:GetTagged("GiftToPlayerClose")) do
	local v5 = v4
	task.defer(function()
		setupCloseButton(v5) -- equivalent call inferred; original call site unknown
	end)
end

CollectionService:GetInstanceAddedSignal("GiftToPlayerClose"):Connect(function(p)
	task.defer(function()
		setupCloseButton(p) -- equivalent call inferred; original call site unknown
	end)
end)