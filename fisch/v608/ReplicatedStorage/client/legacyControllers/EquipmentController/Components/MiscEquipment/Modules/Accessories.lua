local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local items = require(modules.library.items)
local accessorydata = require(modules.library.items.accessorydata)
local accessoryupgrades = require(modules.library.items.accessorydata.accessoryupgrades)
require(ReplicatedStorage.shared.utils.FischUtils.Shared.GradientRichText)
local Net = require(packages.Net)
local remoteFunction = Net:RemoteFunction("AccessoryService/ToggleAccessory")
local remoteEvent = Net:RemoteEvent("AccessoryService/ToggleShowOrHideAccessoryRender")
local remoteFunction2 = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local accessories = HudController:GetSafeZone().equipment.Right.Container.Accessories
local color = Color3.fromRGB(212, 212, 212)
local v = {}
local v2 = {}
local v3 = {}
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupCharacterAttributeConnections()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAccessoryFrame(p: string, instance)
	v3[p] = nil
	instance:Destroy()
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function resort()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local names = {}
		local framesByName = {}
		local v4 = {}

		for _, frame in accessories.ScrollingFrame:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			table.insert(names, frame.Name)
			framesByName[frame.Name] = frame
			v4[frame.Name] = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Accessories", frame.Name })
		end

		table.sort(names, function(a, b)
			local v5 = v4[a]
			local v6 = v4[b]

			if v5 and not v6 then
				return true
			end

			return not (v6 and not v5) and a < b
		end)

		for k, v5 in names do
			if framesByName[v5] then
				framesByName[v5].LayoutOrder = k
			end
		end
	end)
end

local function createAccessoryFrame(name, data)
	local item = items.Items[name]

	if not item then
		return
	end

	local clone = script.Template:Clone()
	v3[name] = clone

	if item and item.Icon then
		clone.ImageLabel.Image = item.Icon
	end

	clone.Info.title.Text = name
	clone.Info.type.Text = data.AccessoryType
	clone.Name = name
	clone.Equip.Activated:Connect(function()
		if data.ReplaceEquipButtonCallbackClient and not data.ReplaceEquipButtonCallbackClient(name) then
			return
		end

		remoteFunction:InvokeServer(name)
	end)

	local function updateVisible(flag2: boolean?)
		clone.showorhide.Visible = flag2 ~= nil
		clone.showorhide.Image = flag2 and "rbxassetid://126510618992393" or "rbxassetid://134551897938098"
		clone.showorhide.ImageTransparency = flag2 and 0.25 or 0.75
	end

	clone.showorhide.Activated:Connect(function()
		remoteEvent:FireServer(name)
	end)
	local v4 = playerDataReplicator:Observe({ "EquippedAccessories", name }, updateVisible)
	clone.Destroying:Once(v4)

	if data.Upgrades then
		local visible = false
		local clonesByUpgrade = {}

		for k, upgrade in data.Upgrades do
			local accessoryupgrade = accessoryupgrades[upgrade]

			if accessoryupgrade then
				local clone2 = script.UpgradeIconTemplate:Clone()
				clone2.Image = accessoryupgrade.Icon or ""
				clone2.ImageRectOffset = accessoryupgrade.IconRectOffset or Vector2.zero
				clone2.ImageRectSize = accessoryupgrade.IconRectSize or Vector2.zero
				clone2.ImageColor3 = accessoryupgrade.IconColor or color
				clone2.LayoutOrder = k
				clone2:SetAttribute(
					"TooltipText",
					(`<b><font color="#{(accessoryupgrade.IconColor or color):ToHex()}" size="20">{accessoryupgrade.DisplayName}</font></b>\n{accessoryupgrade.Description or ""}`)
				)
				clone2:SetAttribute("TooltipColor", accessoryupgrade.IconColor or color)
				clone2:AddTag("HoverTooltip")
				local visible2 = playerDataReplicator:TryIndex({ "AccessoryUpgrades", upgrade }) ~= nil
				clone2.Visible = visible2
				clone2.Parent = clone.Info.upgrades
				clonesByUpgrade[upgrade] = clone2
				visible = visible or visible2
			else
				warn((`Accessory upgrade "{upgrade}" is not defined in module!`))
			end
		end

		clone.Info.type.Visible = not visible
		clone.Info.upgrades.Visible = visible

		local function updateUpgrades()
			local visible2 = false

			for _, upgrade in data.Upgrades do
				local v7 = clonesByUpgrade[upgrade]

				if not v7 then
					continue
				end

				local visible3 = playerDataReplicator:TryIndex({ "AccessoryUpgrades", upgrade }) ~= nil
				v7.Visible = visible3
				visible2 = visible2 or visible3
			end

			clone.Info.type.Visible = not visible2
			clone.Info.upgrades.Visible = visible2
		end

		local v6 = playerDataReplicator:Observe({ "AccessoryUpgrades" }, updateUpgrades)
		clone.Destroying:Once(v6)
	end

	clone:SetAttribute("SearchName", (`{name} ({data.AccessoryType})`))
	local v5 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Accessories", name })
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		local favorite = clone.favorite
		favorite.Image = v5 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
		favorite.ImageTransparency = v5 and 0.25 or 0.75
		local imageColor

		if v5 then
			imageColor = Color3.fromRGB(255, 162, 0)
		else
			imageColor = Color3.fromRGB(255, 255, 255)
		end

		favorite.ImageColor3 = imageColor
	end

	clone.favorite.Activated:Connect(function()
		if flag2 then
			return
		end

		flag2 = true
		v5 = not v5
		updateFavorited() -- equivalent call inferred; original call site unknown

		if not remoteFunction2:InvokeServer("Accessories", name, v5) then
			v5 = not v5
			updateFavorited() -- equivalent call inferred; original call site unknown
		end

		flag2 = false
	end)
	updateFavorited() -- equivalent call inferred; original call site unknown
	resort() -- equivalent call inferred; original call site unknown
	clone.Parent = accessories.ScrollingFrame
end

local function characterAdded(k, data)
	local character = localPlayer.Character

	if not character then
		return
	end

	local definitiveAttribute = data.DefinitiveAttribute

	if not definitiveAttribute then
		return
	end

	local function attributeStep()
		local v4 = v3[k]

		if not v4 then
			return
		end

		if data.ReplaceEquipButtonText then
			v4.Equip.Label.Text = `[{data.ReplaceEquipButtonText}]`
			local replaceEquipButtonColor = data.ReplaceEquipButtonColor or Color3.fromRGB(161, 255, 192)
			v4.Equip.Label.TextColor3 = replaceEquipButtonColor
			v4.Equip.UIStroke.Color = replaceEquipButtonColor
		elseif (localPlayer.Character and localPlayer.Character:GetAttribute(definitiveAttribute)) == true then
			v4.Equip.Label.Text = "[Unequip]"
			v4.Equip.Label.TextColor3 = Color3.fromRGB(255, 120, 122)
			v4.Equip.UIStroke.Color = Color3.fromRGB(255, 120, 122)
		else
			v4.Equip.Label.Text = "[Equip]"
			v4.Equip.Label.TextColor3 = Color3.fromRGB(161, 255, 192)
			v4.Equip.UIStroke.Color = Color3.fromRGB(161, 255, 192)
		end
	end

	attributeStep()
	table.insert(connections, character:GetAttributeChangedSignal(definitiveAttribute):Connect(attributeStep))
end

return {
	Init = function(_)
		DataController.InventoryReplicator:WaitForLoaded()
		DataController.InventoryReplicator:Observe({ "Inventory" }, function(items2)
			if not items2 then
				return
			end

			for k, _ in v do
				if not items2[k] then
					v[k] = nil
				end
			end

			for k, item in items2 do
				if v[k] then
					continue
				end

				local name = item.name
				local v4 = accessorydata[name]

				if v4 then
					if v4 and not v3[name] then
						v2[k] = name
						createAccessoryFrame(name, accessorydata[name])
					end
				else
					v[k] = true
				end
			end

			for k, v4 in v2 do
				if items2[k] then
					v3[v4].Visible = true
				else
					destroyAccessoryFrame(v4, v3[v4]) -- equivalent call inferred; original call site unknown
					v2[k] = nil
				end
			end
		end)

		for k, v4 in accessorydata do
			characterAdded(k, v4)
		end

		localPlayer.CharacterAdded:Connect(function(_)
			cleanupCharacterAttributeConnections() -- equivalent call inferred; original call site unknown

			for k, v4 in accessorydata do
				characterAdded(k, v4)
			end
		end)
		playerDataReplicator:Listen({ "FavoritedEquipment", "Accessories" }, resort)
	end
}