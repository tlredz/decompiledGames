local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminGiveAll = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminGiveAll)
require(ReplicatedStorage.CUI)
local KnownUsers = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.KnownUsers)
require(script.Parent.Parent.Types)
local maxAmount = AdminGiveAll.getMaxAmount()
local maxRecipientSetting = AdminGiveAll.getMaxRecipientSetting()
local v = {}
local values = {}
local v2 = {}

for _, v3 in AdminGiveAll.getItems() do
	local formatted = `{v3.displayName} [{v3.rarity}] - {v3.key}`
	v[formatted] = v3.key
	table.insert(values, formatted)
end

for i = 0, AdminGiveAll.getMaxTier() do
	table.insert(v2, (tostring(i)))
end

return {
	DisplayName = "Give All",
	Permission = "cui.liveops.giveAll",
	Order = 15,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local localPlayer = Players.LocalPlayer
		local clone = table.clone(KnownUsers)
		local v3 = values[1] or ""
		local tier = 0
		local amount = 1
		local randomRecipients = false
		local minimumPlayerCount = 1
		local recipientCount = 1
		local v9 = false
		local userId = tostring(localPlayer.UserId)
		local flag = false
		object:AddTitle(function(object2)
			object2:SetTitle("Give an item to every online player")
		end)
		object:AddDropdown(function(object2)
			object2:SetText("Item"):SetChoiceList(values):SetSelected(v3):SetOnChanged(function(p)
				v3 = p
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Tier"):SetChoiceList(v2):SetSelected("0"):SetOnChanged(function(p2)
					tier = tonumber(p2) or 0
				end)
			end)
			p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Amount"):SetValue(1):SetNumberFilter(1, maxAmount):SetOnChangedUnfocus(function(p2)
					amount = math.clamp(math.floor(p2), 1, maxAmount)
				end)
			end)
		end)
		local v10 = nil
		local v11 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(false):SetOnChanged(function(p)
					randomRecipients = p
					v10:SetEnabled(p)
					v11:SetEnabled(p)
				end)
			end)
			object2.RightComponents:AddTitle(function(object3)
				object3:SetTitle("Random recipients")
			end)
		end)
		v10 = object:AddNumberField(function(object2)
			object2:SetText("Min. server players"):SetValue(1):SetNumberFilter(1, maxRecipientSetting):SetEnabled(false):SetOnChangedUnfocus(function(p)
				minimumPlayerCount = math.clamp(math.floor(p), 1, maxRecipientSetting)
			end)
		end)
		v11 = object:AddNumberField(function(object2)
			object2:SetText("Players/Server"):SetValue(1):SetNumberFilter(1, maxRecipientSetting):SetEnabled(false):SetOnChangedUnfocus(function(p)
				recipientCount = math.clamp(math.floor(p), 1, maxRecipientSetting)
			end)
		end)
		object:AddText(function(object2)
			object2:SetAutoResize(true):SetText("Will give [Players/Server] players the item if the server has over [Min. server players] players.")
		end)
		local v12 = nil
		local v13 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(22)
			object2.LeftComponents:AddCheckbox(function(object3)
				object3:ShowCheckboxOnly():SetYSize(22):SetValue(false):SetOnChanged(function(p)
					v9 = p
					v12:SetEnabled(p)
					v13:SetEnabled(p)
				end)
			end)
			object2.RightComponents:AddTitle(function(object3)
				object3:SetTitle("Fake gifting")
			end)
		end)
		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.5)
			v12 = object2.LeftComponents:AddDropdown(function(object3)
				object3:SetTextVisible(false):SetChoiceList({ "Loading..." }):SetSelected("Loading..."):SetEnabled(false):SetOnChanged(function(p)
					local v14 = clone[p]

					if v14 == nil then
						return
					end

					userId = tostring(v14)
					v13:SetValue(userId)
				end)
			end)
			v13 = object2.RightComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("UserId..."):SetValue(userId):SetEnabled(false):SetOnChangedRaw(function(p)
					userId = p
				end)
			end)
		end)
		local v14 = {}

		for k in clone do
			table.insert(v14, k)
		end

		if clone[localPlayer.Name] == nil then
			table.insert(v14, localPlayer.Name)
		end

		clone[localPlayer.Name] = localPlayer.UserId
		table.sort(v14)
		v12:SetChoiceList(v14):SetSelected(localPlayer.Name)
		v13:SetValue(userId)
		object:AddButton(function(object2)
			object2:SetButtonText("Broadcast item to all players"):SetYSize(22):SetEnabled(#values > 0):SetEnabledPermission("cui.liveops.giveAll"):DoNeedConfirmation(true):SetButtonCallback(function()
				if flag then
					return
				end

				local itemKey = v[v3]

				if itemKey == nil then
					return
				end

				local v16 = tonumber(userId)

				if v9 and (v16 == nil or v16 <= 0 or v16 % 1 ~= 0) then
					NotificationSystem:ShowGeneralNotification(
						"Gift sender UserId is invalid",
						Color3.fromRGB(255, 100, 100),
						5
					)
					return
				end

				flag = true
				AdminGiveAll.requestBroadcast({
					itemKey = itemKey,
					tier = tier,
					amount = amount,
					deliveryMode = v9 and "fakeGift" or "direct",
					randomRecipients = randomRecipients,
					minimumPlayerCount = minimumPlayerCount,
					recipientCount = recipientCount,
					giftSenderUserId = v16 or localPlayer.UserId
				}):andThen(function(p)
					flag = false
					local message = p.message
					local v18

					if p.ok then
						v18 = Color3.fromRGB(100, 255, 100)
					else
						v18 = Color3.fromRGB(255, 100, 100)
					end

					NotificationSystem:ShowGeneralNotification(message, v18, 5)
				end):catch(function(p)
					flag = false
					NotificationSystem:ShowGeneralNotification(
						`Give All broadcast failed: {tostring(p)}`,
						Color3.fromRGB(255, 100, 100),
						5
					)
				end)
			end)
		end)
	end
}