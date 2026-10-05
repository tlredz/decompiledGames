local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local GuiService = game:GetService("GuiService")
game:GetService("RunService")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.ItemInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v5 = require3(ReplicatedStorage2.Shared.SecretAwakenData)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
require3(ReplicatedStorage2.Controllers.Trading.TradeController)
require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.Shared.RNG.Emotes)
local v9 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
require3(ReplicatedStorage2.Common.RewardInfo)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local adminPanel = playerGui.AdminPanel
local hoverInfo = playerGui.HoverInfo
local item = hoverInfo.Item
local list = item.List
local v10 = {
	playerGui.DeleteConfirmation,
	playerGui.TokensPromptConfirmation,
	playerGui.TradeSetPIN,
	playerGui.Prompts
}
local v11 = false
local visible = false
local v13 = {}
local v14 = nil
local v15 = nil
local _ = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function getFocusedObject()
	local v16 = v14

	if v14 then
		return v16, v13[v14]
	end

	return v16, nil
end

local function updateHoverPosition()
	if not v14 then
		return
	end

	local mouseLocation = v:GetMouseLocation()
	local v16 = mouseLocation.X + 2
	local v17 = mouseLocation.Y + 10
	local Y = GuiService:GetGuiInset().Y
	local absoluteSize = hoverInfo.AbsoluteSize
	local absoluteSize2 = item.AbsoluteSize
	local v18 = not (v16 + absoluteSize2.X > absoluteSize.X) and 0 or -absoluteSize2.X
	local v19 = not (v17 + absoluteSize2.Y > absoluteSize.Y) and 0 or -absoluteSize2.Y
	item.Position = UDim2.fromOffset(v16 + v18, (math.max(v17 + v19, Y)))
end

local function stepUpdateObject()
	local focusedObject, v16 = getFocusedObject() -- equivalent call inferred; original call site unknown

	if not (focusedObject and v16) then
		return
	end

	local item2 = v16.Item
	local tradeLock = item2.TradeLock

	if tradeLock ~= nil and list.Locked.Visible then
		if item2.IsCustom then
			if tradeLock.Type == "Permanent" then
				list.Locked.Text = "Untradable"
			elseif tradeLock.Type == "Trial" then
				list.Locked.Text = `Trial for {v3.ValueConvertor:FormatTimeWithDaysFull(list.Locked:GetAttribute("Timestamp"))}`
			end
		elseif tradeLock.Type == "Permanent" then
			list.Locked.Text = "Untradable"
		elseif tradeLock.Type == "Date" then
			list.Locked.Text = `Untradable ({v3.ValueConvertor:FormatTimeWithDaysFull((math.max(list.Locked:GetAttribute("Timestamp") - workspace:GetServerTimeNow(), 0)))})`
		elseif tradeLock.Type == "Trial" then
			list.Locked.Text = `Untradable (Trial for {v3.ValueConvertor:FormatTimeWithDaysFull((math.max(list.Locked:GetAttribute("Timestamp") - workspace:GetServerTimeNow(), 0)))})`
		elseif tradeLock.Type == "Listing" then
			list.Locked.Text = "Untradable (listed in Booth)"
		end
	end
end

local function cropDescription(value: string)
	if #value > 100 then
		local v16 = string.sub(value, 101)
		value = string.sub(value, 1, 100):gsub("(%W*)$", "") .. v16:sub(1, (v16:find("%W") or 1) - 1) .. "..."
	end

	return value
end

local v16 = nil

local function fullUpdateObject()
	local focusedObject, v17 = getFocusedObject() -- equivalent call inferred; original call site unknown

	if not (focusedObject and v17) then
		return
	end

	local itemType = v17.ItemType
	local item2 = v17.Item
	local hasInteractedWithTrading = v15 and v15:Get("HasInteractedWithTrading") or false
	local itemInfo = v6:GetItemInfo(itemType, item2.Name)
	list.Item.Text = itemInfo and (itemInfo.DisplayName or itemInfo.Name) or item2.Name
	local description = itemInfo and itemInfo.Description

	if not description then
		if item2.IsCustom == true then
			description = item2.Description
		else
			description = nil
		end
	end

	if description then
		local description2 = list.Description
		local text

		if #description > 100 then
			local v19 = string.sub(description, 101)
			text = string.sub(description, 1, 100):gsub("(%W*)$", "") .. v19:sub(1, (v19:find("%W") or 1) - 1) .. "..."
		else
			text = description
		end

		description2.Text = text
	end

	list.Description.Visible = description ~= nil
	local visible2

	if itemType == "Ability" then
		visible2 = not item2.IsCustom or item2.Upgrade ~= nil
	else
		visible2 = false
	end

	if visible2 then
		list.Upgrade.Text = item2.Upgrade == nil and "Not Upgraded" or `Upgrade {item2.Upgrade}`
	end

	list.Upgrade.Visible = visible2
	local visible3

	if itemType == "Sword" then
		visible3 = item2.Finisher ~= nil
	else
		visible3 = false
	end

	local child = visible3 and ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(item2.Name)

	if child then
		list.Finisher.Icon.Image = child:GetAttribute("Icon") or v3.Icons:GetIcon("DEFAULT_MISSING")
	end

	list.Finisher.Visible = visible3
	local visible4

	if itemType == "Sword" then
		visible4 = item2.Accessory == true
	else
		visible4 = false
	end

	if visible4 then
		local v21 = v9:GetCollection()[item2.Name]
		list.SwordAccessory.Icon.Image = v21 and v21.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
	end

	list.SwordAccessory.Visible = visible4
	local visible5 = not item2.IsCustom

	if visible5 then
		if itemType == "Sword" then
			visible5 = item2.Kills ~= nil
		else
			visible5 = false
		end
	end

	if visible5 then
		assert(not item2.IsCustom, "Luau")
		list.Kills.Label.Text = `{v3.ValueConvertor:AddCommas(item2.Kills)}/{v3.ValueConvertor:AddCommas(v5.Requirement)}`
	end

	list.Kills.Visible = visible5
	local visible6

	if itemType == "Sword" or itemType == "Explosion" or itemType == "Booth" or itemType == "Emote" then
		visible6 = itemInfo ~= nil
	else
		visible6 = false
	end

	local chance = nil

	if visible6 then
		local rarity = itemInfo.Rarity
		local v23

		if itemType == "Emote" and itemInfo.Chance then
			chance = itemInfo.Chance
			v23 = "RNG "
		else
			v23 = ""
		end

		visible6 = rarity ~= nil

		if visible6 then
			for _, child2 in list.Rarity:GetChildren() do
				local text = child2:GetAttribute("Text")

				if not text then
					text = child2.Text
					child2:SetAttribute("Text", text)
				end

				local text2

				if itemType == "Emote" and (rarity == "Normal" or rarity == "Duo") then
					text2 = rarity == "Normal" and "Emote" or text
				elseif text == string.upper(text) then
					text2 = `{text} {string.upper(v23)}{string.upper(itemType)}{string.upper("")}`
				else
					text2 = `{text} {v23}{itemType}`
				end

				child2.Text = text2
				child2.Visible = child2.Name == rarity
			end

			if chance then
				list.Chance.Text = `1 in {v3.ValueConvertor:AddCommas(chance)}`
			end
		end
	end

	list.Chance.Visible = visible6 and chance
	list.Rarity.Visible = visible6
	local visible7

	if itemType == "Sword" or itemType == "Explosion" or itemType == "Emote" then
		visible7 = v7:IsEnabled()

		if visible7 then
			if v7:ShouldShowRAP(itemType, item2.Name) then
				visible7 = hasInteractedWithTrading
			else
				visible7 = visible and hasInteractedWithTrading
			end
		end
	else
		visible7 = false
	end

	if visible7 and v16 ~= focusedObject then
		local RAP = v7:GetRAP(itemType, v17.Key)
		list.RAP.Label.Text = RAP and v3.ValueConvertor:ShrinkNumber(RAP) or "---"
		task.delay(0.1, function()
			local v24 = v14

			if v14 then
				local _ = v13[v14]
			end

			if v24 ~= focusedObject or not v16 then
				return
			end

			local rAPAsync = v7:GetRAPAsync(itemType, v17.Key)
			local v25 = v14

			if v14 then
				local _ = v13[v14]
			end

			if v25 ~= focusedObject or not v16 then
				return
			end

			list.RAP.Label.Text = rAPAsync and v3.ValueConvertor:ShrinkNumber(rAPAsync) or 0
		end)
	end

	list.RAP.Visible = visible7

	if item2.IsCustom or type(item2.Serial) ~= "number" then
		local v24 = v8:Get(itemType, v17.Key)

		if v24 then
			list.ExistCount.Label.Text = `{v3.ValueConvertor:ShrinkNumber(v24)} Exist{v24 == 1 and "s" or ""}`
		end

		list.ExistCount.Visible = v24 ~= nil
	else
		local v24 = v8:Get(itemType, v17.Key) or -1
		list.ExistCount.Label.Text = `#{v3.ValueConvertor:AddCommas(item2.Serial)} of {(not v24 or v24 == -1) and "???" or v3.ValueConvertor:AddCommas(v24)}`
		list.ExistCount.Visible = true
	end

	local tradeLock = item2.TradeLock

	if tradeLock ~= nil then
		if tradeLock.Type == "Date" or tradeLock.Type == "Trial" then
			list.Locked:SetAttribute("Timestamp", tradeLock.Value)
		else
			list.Locked:SetAttribute("Timestamp", nil)
		end

		local locked = list.Locked
		local textColor

		if tradeLock.Type == "Permanent" then
			textColor = Color3.fromRGB(255, 43, 43)
		else
			textColor = Color3.fromRGB(255, 255, 255)
		end

		locked.TextColor3 = textColor
	end

	if tradeLock == nil then
		list.Locked.Visible = false
	else
		list.Locked.Visible = hasInteractedWithTrading or tradeLock.Type == "Trial"
	end

	if visible then
		local items = client:FindItemsWithKey(itemType, v17.Key)
		list.Debug.Text = v17.Key .. (#items > 0 and [[


]] .. table.concat(items, "\n") or "")
	end

	list.Debug.Visible = visible
	list.CreatedAt.Label.Text = not item2.CreatedAt and "Unknown" or DateTime.fromUnixTimestamp(item2.CreatedAt):FormatLocalTime(
		"lll",
		localPlayer.LocaleId
	)
	list.CreatedAt.Visible = v17.ShowCreatedAt and item2.CreatedAt ~= nil
	v16 = focusedObject
	stepUpdateObject()
end

local function setHovering(p)
	if not v13[p] or v14 == p then
		return
	end

	v14 = p
	updateHoverPosition()
	fullUpdateObject()
	item.Visible = v14 ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeHovering(p)
	if v14 ~= p then
		return
	end

	v14 = nil
	v16 = nil
	item.Visible = v14 ~= nil

	if item.Visible then
		fullUpdateObject()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHovering()
	v14 = nil
	v16 = nil
	item.Visible = false
end

local function updateGuiObjects()
	local v17 = true

	for _, v19 in v10 do
		if not v19.Enabled then
			continue
		end

		v17 = false
		break
	end

	local mouseLocation = v:GetMouseLocation()
	updateHoverPosition()

	for _, v19 in not v17 and {} or playerGui:GetGuiObjectsAtPosition(
		mouseLocation.X,
		mouseLocation.Y - GuiService:GetGuiInset().Y
	) do
		if v19.Name == "SinkInput" then
			break
		end

		if not v13[v19] then
			continue
		end

		local surfaceGui = v19:FindFirstAncestorWhichIsA("SurfaceGui")

		if not (not surfaceGui or surfaceGui.AlwaysOnTop or surfaceGui:HasTag("LiveSaleSurfaceGui")) then
			continue
		end

		if not (v13[v19] and v14 ~= v19) then
			return
		end

		v14 = v19
		updateHoverPosition()
		fullUpdateObject()
		item.Visible = v14 ~= nil
		return
	end

	clearHovering() -- equivalent call inferred; original call site unknown
end

local HoverInfoController = {}

function HoverInfoController:Add(instance, itemType, p2, p3, p4)
	if not p2 then
		if p3 then
			p2 = client:KeyToItem(p3)
		else
			p2 = nil
		end
	end

	assert(p2, "You have to provide at least a item or itemKey for HoverInfoController:Add")
	local v17 = p3 or client:ItemToKey(itemType, p2, nil, p4 and p4.ShowCreatedAt)

	if itemType == "Ability" and not (p4 and p4.AllowAbilityInfo) and (not p2.TradeLock or p2.TradeLock.Type ~= "Trial") and not p2.IsCustom then
		removeHovering(instance) -- equivalent call inferred; original call site unknown
		v13[instance] = nil
	else
		local v18 = v13[instance]

		if v18 then
			v18.DestroyingConn:Disconnect()
		end

		v13[instance] = {
			Item = p2,
			Key = v17,
			ItemType = itemType,
			ShowCreatedAt = p4 and p4.ShowCreatedAt,
			DestroyingConn = instance.Destroying:Once(function()
				self:Remove(instance)
			end)
		}

		if v14 == instance then
			task.spawn(fullUpdateObject)
		end
	end
end

function HoverInfoController.CanShowRewardInfo(_, p)
	if string.find(p.DisplayName, "PLACEHOLDER") == 1 then
		return false
	end

	return table.find({
		"Emote",
		"Explosion",
		"Booth",
		"Sword",
		"Finisher",
		"SwordAccessory",
		"Ability",
		"AbilityUpgrade",
		"AbilityFreeTrial"
	}, p.Type) ~= nil
end

function HoverInfoController:AddFromRewardInfo(p, data, description)
	local type2 = data.Type
	local v17 = (type2 == "Finisher" or type2 == "SwordAccessory") and "Sword" or (type2 == "AbilityUpgrade" or type2 == "AbilityFreeTrial") and "Ability" or type2

	if not (v4[v17] and v4[v17][data.Value]) then
		warn((`Could not create HoverInfo for {data.Type} {data.Value}!`))
		return
	end

	local v18 = {
		IsCustom = true,
		Name = data.Value,
		Description = description,
		Finisher = data.Type == "Finisher" or nil,
		Accessory = data.Type == "SwordAccessory" or nil,
		Upgrade = 0,
		TradeLock = 0
	}
	local upgrade

	if data.Type == "AbilityUpgrade" then
		upgrade = data.Amount
	end

	v18.Upgrade = upgrade
	v18.TradeLock = data.Type == "AbilityFreeTrial" and {
		Type = "Trial",
		Value = data.Duration
	} or nil
	return self:Add(p, v17, v18)
end

function HoverInfoController:Remove(p)
	local v17 = v13[p]

	if v17 then
		v17.DestroyingConn:Disconnect()
		v13[p] = nil
	end

	removeHovering(p) -- equivalent call inferred; original call site unknown
end

function HoverInfoController.Start(_)
	v3.Thread.Every(0.05, updateGuiObjects)
	v3.Thread.Every(1, stepUpdateObject)
	v3.Thread.Every(60, fullUpdateObject)
	task.spawn(function()
		v15 = v2.Client:WaitReplion("Data")

		if not v15 then
			return
		end

		for _, inventoryType in client.InventoryTypes do
			client:OnChange(inventoryType, fullUpdateObject)
		end
	end)
	task.spawn(function()
		local v17 = v2.Client:WaitReplion("ItemRAP")

		if v17 then
			v17:OnChange("Items", fullUpdateObject)
		end
	end)
	local thread = nil
	v.InputChanged:Connect(function(input, _: boolean)
		if not item.Visible then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseWheel or input.KeyCode == Enum.KeyCode.Thumbstick1 or input.KeyCode == Enum.KeyCode.Thumbstick2 then
			updateHoverPosition()

			if thread then
				v3.Thread.SafeCancel(thread)
				thread = nil
			end

			thread = task.delay(0.5, function()
				fullUpdateObject()
				updateGuiObjects()
				thread = nil
			end)
		end
	end)
	v.InputEnded:Connect(function(input, _: boolean)
		if not item.Visible then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			fullUpdateObject()
			updateGuiObjects()
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateScaling()
		local absoluteSize = hoverInfo.AbsoluteSize
		local scale = math.max((absoluteSize.X + absoluteSize.Y) / 3000, 0.5)
		item.UIScale.Scale = scale
	end

	local thread2 = nil
	hoverInfo:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if thread2 then
			v3.Thread.SafeCancel(thread2)
			thread2 = nil
		end

		thread2 = task.delay(0.5, function()
			thread2 = nil
			updateScaling() -- equivalent call inferred; original call site unknown
		end)
	end)
	task.spawn(updateScaling)

	local function onPermissionsLoaded()
		v11 = localPlayer:GetAttribute("PermissionDataManipulation") == true

		if v11 then
			v.InputBegan:Connect(function(input, _: boolean)
				if input.KeyCode == Enum.KeyCode.F2 then
					visible = not visible
					localPlayer:SetAttribute("HoverInfoDebugEnabled", visible or nil)
					fullUpdateObject()
				end
			end)
		end
	end

	if localPlayer:GetAttribute("PermissionDataManipulation") == nil then
		localPlayer:GetAttributeChangedSignal("PermissionDataManipulation"):Once(onPermissionsLoaded)
	else
		task.spawn(onPermissionsLoaded)
	end

	local displayOrder = hoverInfo.DisplayOrder
	adminPanel:GetPropertyChangedSignal("Enabled"):Connect(function()
		local v17 = hoverInfo
		local displayOrder2

		if adminPanel.Enabled then
			displayOrder2 = adminPanel.DisplayOrder + 1
		else
			displayOrder2 = displayOrder
		end

		v17.DisplayOrder = displayOrder2
	end)
end

return HoverInfoController