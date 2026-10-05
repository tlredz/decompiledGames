local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local SettingsUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("SettingsUISystem"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local templates = ReplicatedStorage:WaitForChild("Templates")
local giftReceivedFrame = templates:WaitForChild("GiftReceivedFrame")
local giftTemplate = templates:WaitForChild("GiftTemplate")
local speedGameUI = playerGui:WaitForChild("SpeedGameUI", 60)

-- equivalent calls inferred from this helper; original call sites unknown
local function giftNotifsHidden()
	return SettingsUISystem:Get("HideGiftNotifications") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function waitForSettingsLoaded()
	if not SettingsUISystem:IsLoaded() then
		SettingsUISystem.DataLoaded:Wait()
	end
end

local function getElementInFrame(folder, p)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if CollectionService:HasTag(descendant, "GiftReceived") and descendant:GetAttribute("Type") == p then
			return descendant
		end
	end

	return nil
end

local function buildGiftReceivedFrame(senderName, senderUserId, list)
	local clone = giftReceivedFrame:Clone()
	clone.Parent = speedGameUI
	local elementInFrame = getElementInFrame(clone, "SenderName")

	if elementInFrame then
		elementInFrame.Text = senderName
	end

	local elementInFrame2 = getElementInFrame(clone, "SenderImage")

	if elementInFrame2 then
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(
					senderUserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)
			end)

			if success and result then
				elementInFrame2.Image = result
			end
		end)
	end

	local elementInFrame3 = getElementInFrame(clone, "FrameAllGift")

	if elementInFrame3 then
		for _, v in ipairs(list) do
			local clone2 = giftTemplate:Clone()
			local elementInFrame4 = getElementInFrame(clone2, "GiftName")

			if elementInFrame4 then
				elementInFrame4.Text = v.GiftName or v.Gift or "Gift"
			end

			local elementInFrame5 = getElementInFrame(clone2, "GiftImage")
			local v2 = elementInFrame5 and GiftConfig.ALL_GIFTS[v.Gift]

			if v2 then
				elementInFrame5.Image = v2.Image
			end

			clone2.Parent = elementInFrame3
		end
	end

	local elementInFrame4 = getElementInFrame(clone, "Close")

	if elementInFrame4 and elementInFrame4:IsA("GuiButton") then
		elementInFrame4.Activated:Connect(function()
			local timestamps = {}

			for _, v in ipairs(list) do
				if v.Timestamp then
					table.insert(timestamps, v.Timestamp)
				end
			end

			local giftAction = remotes:FindFirstChild("GiftAction")

			if giftAction and #timestamps > 0 then
				task.spawn(function()
					pcall(function()
						giftAction:InvokeServer("ClaimGifts", {
							Timestamps = timestamps
						})
					end)
				end)
			end

			clone:Destroy()
		end)
	end

	return clone
end

local function showUnclaimedGifts()
	waitForSettingsLoaded() -- equivalent call inferred; original call site unknown

	if giftNotifsHidden() then
		return
	end

	local giftAction = remotes:WaitForChild("GiftAction", 15)

	if not giftAction then
		return
	end

	local success, result = pcall(function()
		return giftAction:InvokeServer("GetUnclaimedGifts", {})
	end)

	if not (success and result and result.Success) then
		return
	end

	local gifts = result.Gifts

	if not gifts or #gifts == 0 then
		return
	end

	local v = {}
	local senderUserIds = {}

	for _, gift in ipairs(gifts) do
		local senderUserId = gift.SenderUserId

		if not senderUserId then
			continue
		end

		if not v[senderUserId] then
			v[senderUserId] = {
				senderName = gift.SenderName or "Unknown",
				senderUserId = senderUserId,
				gifts = {}
			}
			table.insert(senderUserIds, senderUserId)
		end

		table.insert(v[senderUserId].gifts, gift)
	end

	for _, v2 in ipairs(senderUserIds) do
		local v3 = v[v2]
		buildGiftReceivedFrame(v3.senderName, v3.senderUserId, v3.gifts)
	end

	if #senderUserIds > 0 then
		SoundManager:Play("SUCCESS")
	end
end

task.delay(3, showUnclaimedGifts)
local giftReceivedNotify = remotes:WaitForChild("GiftReceivedNotify", 15)

if giftReceivedNotify then
	giftReceivedNotify.OnClientEvent:Connect(function(p)
		if not p or typeof(p) ~= "table" or giftNotifsHidden() then
			return
		end

		local senderName = p.SenderName or "Unknown"
		buildGiftReceivedFrame(senderName, p.SenderUserId, { p })
		SoundManager:Play("SUCCESS")
	end)
end