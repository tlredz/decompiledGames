local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local character = require(modules.character)
local lanterns = require(modules.library.lanterns)
local fx = require(modules.fx)
local Net = require(packages.Net)
require(packages.Trove)
local remoteFunction = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local v = character.WaitDataFolder(localPlayer)
local stats = v:WaitForChild("Stats")
local lanterns2 = v:WaitForChild("Lanterns")
local lanterns3 = HudController:GetSafeZone().equipment.Right.Container.Lanterns
local v2 = {}

local function UpdateEquipped()
	local _ = stats.hasbodylantern.lanterntype.Value

	for _, child in lanterns2:GetChildren() do
		local child2 = lanterns3.ScrollingFrame:FindFirstChild(child.Name)

		if not child2 then
			continue
		end

		if stats.hasbodylantern.lanterntype.Value == child.Name then
			child2.Equip.UIStroke.Color = Color3.fromRGB(255, 120, 122)
			child2.Equip.Label.TextColor3 = Color3.fromRGB(255, 120, 122)
			child2.Equip.Label.Text = "[Unequip]"
		else
			child2.Equip.UIStroke.Color = Color3.fromRGB(162, 234, 166)
			child2.Equip.Label.TextColor3 = Color3.fromRGB(162, 234, 166)
			child2.Equip.Label.Text = "[Equip]"
		end
	end
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
		local v3 = {}

		for _, frame in lanterns3.ScrollingFrame:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			table.insert(names, frame.Name)
			framesByName[frame.Name] = frame
			v3[frame.Name] = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Lanterns", frame.Name })
		end

		table.sort(names, function(a, b)
			local v4 = v3[a]
			local v5 = v3[b]

			if v4 and not v5 then
				return true
			end

			if v5 and not v4 then
				return false
			end

			if a == "Random Lantern" == (b == "Random Lantern") then
				return a < b
			end

			return a == "Random Lantern"
		end)

		for k, v4 in names do
			if framesByName[v4] then
				framesByName[v4].LayoutOrder = k
			end
		end
	end)
end

local function CreateLanternButton(name)
	if lanterns3.ScrollingFrame:FindFirstChild(name) then
		return
	end

	local clone = script.Template:Clone()
	clone.Name = name
	clone.Info.title.Text = "[" .. name .. "]"
	local lantern = lanterns[name]

	if lantern.Icon then
		clone.ImageLabel.Visible = true
		clone.ImageLabel.Image = lantern.Icon
	end

	clone.Parent = lanterns3.ScrollingFrame
	clone.Equip.MouseButton1Click:Connect(function()
		if stats.hasbodylantern.lanterntype.Value == name then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, lanterns3.ScrollingFrame, false)
			Net:RemoteFunction("Lanterns/SetEquipped"):InvokeServer()
			UpdateEquipped()
		else
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, lanterns3.ScrollingFrame, false)

			if Net:RemoteFunction("Lanterns/SetEquipped"):InvokeServer(name) then
				UpdateEquipped()
			end
		end
	end)

	if stats.hasbodylantern.lanterntype.Value == name then
		clone.Equip.UIStroke.Color = Color3.fromRGB(81, 81, 81)
		clone.Equip.Label.TextColor3 = Color3.fromRGB(81, 81, 81)
		clone.Equip.Label.Text = "[Equipped]"
	else
		clone.Equip.UIStroke.Color = Color3.fromRGB(162, 234, 166)
		clone.Equip.Label.TextColor3 = Color3.fromRGB(162, 234, 166)
		clone.Equip.Label.Text = "[Equip]"
	end

	local v3 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Lanterns", name })
	local flag2 = false

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
		if flag2 then
			return
		end

		flag2 = true
		v3 = not v3
		updateFavorited() -- equivalent call inferred; original call site unknown

		if not remoteFunction:InvokeServer("Lanterns", name, v3) then
			v3 = not v3
			updateFavorited() -- equivalent call inferred; original call site unknown
		end

		flag2 = false
	end)
	updateFavorited() -- equivalent call inferred; original call site unknown
	resort() -- equivalent call inferred; original call site unknown
	v2[name] = clone
end

return {
	Init = function(_)
		for _, child in lanterns2:GetChildren() do
			CreateLanternButton(child.Name)
		end

		lanterns2.ChildAdded:Connect(function(child)
			CreateLanternButton(child.Name)
		end)
		lanterns2.ChildRemoved:Connect(function(child)
			if v2[child.Name] then
				v2[child.Name]:Destroy()
				v2[child.Name] = nil
			end
		end)
		UpdateEquipped()
		stats.hasbodylantern.lanterntype:GetPropertyChangedSignal("Value"):Connect(function()
			UpdateEquipped()
		end)
		playerDataReplicator:Listen({ "FavoritedEquipment", "Lanterns" }, resort)
	end
}