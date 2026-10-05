local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local halos = require(modules.library.halos)
local fx = require(modules.fx)
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local Monetization = require(ReplicatedStorage.shared.Monetization)
local Net = require(packages.Net)
require(packages.patch)
local gamepassId = Monetization.gamepasses.Supporter.GamepassId
local remoteFunction = Net:RemoteFunction("Halos/SetEquipped")
local remoteFunction2 = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local right = HudController:GetSafeZone().equipment.Right
local legacyList = right.LegacyList
local defaultList = right.Top.DefaultList
local container = right.Container
local halos2 = defaultList.Halos
local halos3 = legacyList.Halos
local halos4 = container.Halos
local v = nil
local flag = false
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getEquippedHalo()
	if v2 then
		return v2.Equipped or ""
	end

	return ""
end

local function updateEquippedHalo()
	local equippedHalo = getEquippedHalo() -- equivalent call inferred; original call site unknown
	local child = halos4.ScrollingFrame:FindFirstChild(equippedHalo)

	if v then
		v.Equip.UIStroke.Color = Color3.fromRGB(162, 234, 166)
		v.Equip.Label.TextColor3 = Color3.fromRGB(162, 234, 166)
		v.Equip.Label.Text = "[Equip]"
	end

	if child then
		child.Equip.UIStroke.Color = Color3.fromRGB(255, 120, 122)
		child.Equip.Label.TextColor3 = Color3.fromRGB(255, 120, 122)
		child.Equip.Label.Text = "[Unequip]"
		v = child
	end
end

local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function resort()
	if flag2 then
		return
	end

	flag2 = true
	task.defer(function()
		flag2 = false
		local names = {}
		local framesByName = {}
		local v3 = {}

		for _, frame in halos4.ScrollingFrame:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			table.insert(names, frame.Name)
			framesByName[frame.Name] = frame
			v3[frame.Name] = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Halos", frame.Name })
		end

		table.sort(names, function(a, b)
			local v4 = v3[a]
			local v5 = v3[b]

			if v4 and not v5 then
				return true
			end

			return not (v5 and not v4) and a < b
		end)

		for k, v4 in names do
			if framesByName[v4] then
				framesByName[v4].LayoutOrder = k
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeHalo(name: string)
	local child = halos4.ScrollingFrame:FindFirstChild(name)

	if child then
		child:Destroy()
	end
end

local function createHalo(name: string)
	local halo = halos[name]

	if not halo or halos4.ScrollingFrame:FindFirstChild(name) then
		return
	end

	removeHalo("none") -- equivalent call inferred; original call site unknown
	local clone = script.Template:Clone()
	clone.Name = name
	clone.Info.title.Text = `[{halo.DisplayText or name}]`

	if halo.Icon then
		clone.ImageLabel.Image = halo.Icon
	end

	clone.Stats.color.Text = halo.AllowColorCustomization == false and "Color: Fixed" or "Color: Customizable"
	local color = halo.Exclusive and Color3.fromRGB(255, 215, 100) or Color3.fromRGB(255, 255, 255)
	clone.UIStroke.Color = color
	clone.Gradient.BackgroundColor3 = color
	clone.Parent = halos4.ScrollingFrame
	clone.Equip.Activated:Connect(function()
		if getEquippedHalo() == name then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, halos4.ScrollingFrame, false)
			remoteFunction:InvokeServer(nil)
		else
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, halos4.ScrollingFrame, false)
			remoteFunction:InvokeServer(name)
		end
	end)
	local v3 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Halos", name })
	local flag3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		local favorite = clone.favorite
		favorite.Image = v3 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
		favorite.ImageTransparency = v3 and 0.25 or 0.75
		local imageColor

		if v3 then
			imageColor = Color3.fromRGB(255, 162, 0)
		else
			imageColor = Color3.fromRGB(255, 255, 255)
		end

		favorite.ImageColor3 = imageColor
	end

	clone.favorite.Activated:Connect(function()
		if flag3 then
			return
		end

		flag3 = true
		v3 = not v3
		updateFavorited() -- equivalent call inferred; original call site unknown

		if not remoteFunction2:InvokeServer("Halos", name, v3) then
			v3 = not v3
			updateFavorited() -- equivalent call inferred; original call site unknown
		end

		flag3 = false
	end)
	updateFavorited() -- equivalent call inferred; original call site unknown
	resort() -- equivalent call inferred; original call site unknown
	updateEquippedHalo()
end

local function handleHaloDataChange(p)
	if not p then
		return
	end

	v2 = p
end

local function handleOwnedHaloDataChange(items)
	if not items then
		return
	end

	for _, frame in halos4.ScrollingFrame:GetChildren() do
		if not frame:IsA("Frame") or items[frame.Name] then
			continue
		end

		removeHalo(frame.Name) -- equivalent call inferred; original call site unknown
	end

	for k, item in items do
		if typeof(item) ~= "table" or not item.stack or item.stack <= 0 then
			continue
		end

		createHalo(k)
	end
end

local function initializeHalosUI()
	if flag then
		return
	end

	playerDataReplicator:WaitForLoaded()
	flag = true
	halos2.Visible = true
	halos3.Visible = true
	v2 = playerDataReplicator:Index({ "Halos" })

	for k, v3 in v2.Owned do
		if typeof(v3) ~= "table" or not v3.stack or v3.stack <= 0 then
			continue
		end

		createHalo(k)
	end

	playerDataReplicator:Listen({ "Halos" }, handleHaloDataChange)
	playerDataReplicator:Observe({ "Halos", "Owned" }, handleOwnedHaloDataChange)
	playerDataReplicator:Listen({ "Halos", "Equipped" }, updateEquippedHalo)
	updateEquippedHalo()
	playerDataReplicator:Listen({ "FavoritedEquipment", "Halos" }, resort)
end

return {
	Init = function(_)
		if marketplace.userHasGamepassAsync(localPlayer, gamepassId) then
			initializeHalosUI()
		else
			halos2.Visible = false
			halos3.Visible = false
		end

		legacyLocalPlayerData.fetch():WaitForChild("Gamepasses").ChildAdded:Connect(function(child)
			if child.Name == tostring(gamepassId) then
				initializeHalosUI()
			end
		end)
	end
}