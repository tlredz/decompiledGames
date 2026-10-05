local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local bobbers = require(modules.fishing.bobbers)
local character = require(modules.character)
local fx = require(modules.fx)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local animatedgradient = require(modules.fx.animatedgradient)
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("Bobber/Equip")
local remoteFunction = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local bobber = character.WaitDataFolder(localPlayer):WaitForChild("Stats"):WaitForChild("bobber")
local bobbers2 = HudController:GetSafeZone().equipment.Right.Container.Bobbers
local v = nil

local function updateEquippedBobber()
	local value = bobber.Value
	local child = bobbers2.ScrollingFrame:FindFirstChild(value)

	if v then
		v.Equip.UIStroke.Color = Color3.fromRGB(162, 234, 166)
		v.Equip.Label.TextColor3 = Color3.fromRGB(162, 234, 166)
		v.Equip.Label.Text = "[Equip]"
	end

	if child then
		child.Equip.UIStroke.Color = Color3.fromRGB(81, 81, 81)
		child.Equip.Label.TextColor3 = Color3.fromRGB(81, 81, 81)
		child.Equip.Label.Text = "[Equipped]"
		v = child
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
		local v2 = {}

		for _, frame in bobbers2.ScrollingFrame:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			table.insert(names, frame.Name)
			framesByName[frame.Name] = frame
			v2[frame.Name] = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Bobbers", frame.Name })
		end

		table.sort(names, function(a, b)
			local v3 = v2[a]
			local v4 = v2[b]

			if v3 and not v4 then
				return true
			end

			if v4 and not v3 then
				return false
			end

			if a == "Random Bobber" == (b == "Random Bobber") then
				return a < b
			end

			return a == "Random Bobber"
		end)

		for k, v3 in names do
			if framesByName[v3] then
				framesByName[v3].LayoutOrder = k
			end
		end
	end)
end

local function createBobber(name: string)
	local bobber2 = bobbers.Bobbers[name]

	if not bobber2 or bobbers2.ScrollingFrame:FindFirstChild(name) then
		return
	end

	local none = bobbers2.ScrollingFrame:FindFirstChild("none")

	if none then
		none:Destroy()
	end

	local rarity = rarities.Rarities[bobber2.Rarity]
	local color = rarity.Color
	local clone = script.Template:Clone()
	clone.Name = name
	clone.Info.title.Text = `[{name}]`
	clone.UIStroke.Color = color
	clone.Gradient.BackgroundColor3 = color

	if rarity.ColorGradient then
		clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		clone.Gradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		local v2 = animatedgradient.new(rarity.ColorGradient)
		local v3 = animatedgradient.new(rarity.ColorGradient)
		v2.Parent = clone.UIStroke
		v3.Parent = clone.Gradient
	end

	if bobber2.Icon then
		clone.ImageLabel.Visible = true
		clone.ImageLabel.Image = bobber2.Icon
		clone.MouseEnter:Connect(function()
			clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, bobbers2.ScrollingFrame, true)
		end)
		clone.MouseLeave:Connect(function()
			clone.UIStroke.Color = color
		end)
	end

	clone.Parent = bobbers2.ScrollingFrame
	clone.Equip.Activated:Connect(function()
		if bobber.Value == name then
			return
		end

		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, bobbers2.ScrollingFrame, false)
		remoteEvent:FireServer(name)
	end)
	local v2 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Bobbers", name })
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		local favorite = clone.favorite
		favorite.Image = v2 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
		favorite.ImageTransparency = v2 and 0.25 or 0.75
		local imageColor

		if v2 then
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
		v2 = not v2
		updateFavorited() -- equivalent call inferred; original call site unknown

		if not remoteFunction:InvokeServer("Bobbers", name, v2) then
			v2 = not v2
			updateFavorited() -- equivalent call inferred; original call site unknown
		end

		flag2 = false
	end)
	updateFavorited() -- equivalent call inferred; original call site unknown
	resort() -- equivalent call inferred; original call site unknown
end

return {
	Init = function(_)
		if bobber.Value ~= "Stock" and bobber.Value ~= "" and not bobbers.Bobbers[bobber.Value] then
			remoteEvent:FireServer("Stock")
		end

		for _, child in bobber:GetChildren() do
			if bobbers.Bobbers[child.Name] then
				task.spawn(createBobber, child.Name)
			end
		end

		bobber:GetPropertyChangedSignal("Value"):Connect(updateEquippedBobber)
		task.defer(updateEquippedBobber)
		playerDataReplicator:Listen({ "FavoritedEquipment", "Bobbers" }, resort)
		bobber.ChildAdded:Connect(function(child)
			createBobber(child.Name)
		end)
	end
}