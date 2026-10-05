local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local bait = require(modules.library.bait)
local character = require(modules.character)
require(modules.library.fish)
local mutations = require(modules.fishing.mutations)
local fx = require(modules.fx)
local animatedgradient = require(modules.fx.animatedgradient)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local Net = require(packages.Net)
require(ReplicatedStorage.shared.utils.assets)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local remoteEvent = Net:RemoteEvent("Bait/Equip", -1)
local remoteFunction = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local bait2 = character.WaitDataFolder(localPlayer):WaitForChild("Stats"):WaitForChild("bait")
local baits = HudController:GetSafeZone().equipment.Right.Container.Baits
local sortSelection = baits.sortSelection
local sortOptions = baits.sortOptions
local v = "Name"
local v2 = {}
local v3 = nil
local v4 = {
	Name = "Name",
	Quantity = "Amount Owned",
	PreferredLuck = "Preferred Luck",
	Luck = "Universal Luck",
	Lure = "Lure Speed",
	Resilience = "Resilience",
	ProgressSpeed = "Progress Speed",
	Control = "Control",
	Disturbance = "Disturbance"
}
local v5 = {
	"Name",
	"Quantity",
	"PreferredLuck",
	"Luck",
	"Lure",
	"Resilience",
	"ProgressSpeed",
	"Control",
	"Disturbance"
}

local function updateEquippedBait()
	local value = bait2.Value

	if v3 and v3:IsDescendantOf(game) then
		v3.Equip.UIStroke.Color = Color3.fromRGB(162, 234, 166)
		v3.Equip.Label.TextColor3 = Color3.fromRGB(162, 234, 166)
		v3.Equip.Label.Text = "[Equip]"
	else
		v3 = nil
	end

	local child = baits.ScrollingFrame:FindFirstChild(value)

	if child then
		child.Equip.UIStroke.Color = Color3.fromRGB(255, 120, 122)
		child.Equip.Label.TextColor3 = Color3.fromRGB(255, 120, 122)
		child.Equip.Label.Text = "[Unequip]"
		v3 = child
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
		local v6 = {}
		local v7 = {}
		local v8 = {}

		for k, _ in v2 do
			table.insert(v6, k)

			if v == "Name" then
				v7[k] = k
			elseif v == "Quantity" then
				local child = bait2:FindFirstChild((`bait_{k}`))
				v7[k] = child and child.Value or 0
			else
				v7[k] = bait[k][v]
			end

			v8[k] = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Baits", k })
		end

		table.sort(v6, function(a, b)
			local v9 = v7[a]
			local v10 = v7[b]
			local v11 = v8[a]
			local v12 = v8[b]

			if v11 and not v12 then
				return true
			end

			if v12 and not v11 then
				return false
			end

			if v9 == v10 or v == "Name" then
				return a < b
			end

			return v9 ~= nil and (v10 == nil or v10 < v9)
		end)

		for k, v9 in v6 do
			if v2[v9] then
				v2[v9].LayoutOrder = k
			end
		end
	end)
end

local function createBaitFrame(joined: string)
	local v6 = bait[joined]

	if not v6 then
		return
	end

	local none = baits.ScrollingFrame:FindFirstChild("none")

	if none then
		none:Destroy()
	end

	local rarity = rarities.Rarities[v6.Rarity]
	local v7 = 4
	local clone = script.Template:Clone()
	clone.Name = joined
	clone.Info.title.Text = `[{joined}]`
	clone.Stats.preferredluck.Text = `Preferred Luck: {v6.PreferredLuck}`
	clone.Stats.generelluck.Text = `Universal Luck: {v6.Luck}`
	clone.Stats.lurespeed.Text = `Lure Speed: {v6.Lure}`
	clone.Stats.resilience.Text = `Resilience: {v6.Resilience}`
	clone.UIStroke.Color = rarity.Color
	clone.Gradient.BackgroundColor3 = rarity.Color

	if v6.ProgressSpeed and v6.ProgressSpeed ~= 0 then
		clone.Stats.progressSpeed.Text = string.format("Progress Speed: %+.0f%%", v6.ProgressSpeed)
		clone.Stats.progressSpeed.Visible = true
		v7 += 1
	end

	if v6.Control and v6.Control ~= 0 then
		clone.Stats.control.Text = `Control: {v6.Control}`
		clone.Stats.control.Visible = true
		v7 += 1
	end

	if v6.Disturbance and v6.Disturbance ~= 0 then
		clone.Stats.disturbance.Text = string.format("Disturbance: %+.0f", v6.Disturbance)
		clone.Stats.disturbance.Visible = true
		v7 += 1
	end

	if v6.Mutation then
		local v8 = not v6.MutationChance and 1 or v6.MutationChance[3] / v6.MutationChance[2]
		local v9 = mutations.Mutations[v6.Mutation] or {}

		if typeof(v9.Color) == "ColorSequence" then
			clone.Stats.mutation.Text = `Mutation: {FischUtils.GradientRichText(v9.Display or v6.Mutation, v9.Color)} ({math.round(v8 * 100)}%)`
		else
			clone.Stats.mutation.Text = `Mutation: <font color="#{(v9.Color or Color3.new(1, 1, 1)):ToHex()}">{v9.Display or v6.Mutation}</font> ({math.round(v8 * 100)}%)`
		end

		clone.Stats.mutation.Visible = true
		clone:SetAttribute("SearchName", (`{joined} {v6.Mutation}`))
		v7 += 1
	end

	if rarity.ColorGradient then
		clone.Gradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		local v8 = animatedgradient.new(rarity.ColorGradient)
		local v9 = animatedgradient.new(rarity.ColorGradient)
		v8.Parent = clone.Gradient
		v9.Parent = clone.UIStroke
	end

	if v6.Luck == 0 then
		clone.Stats.generelluck.Visible = false
		v7 -= 1
	end

	if v6.PreferredLuck == 0 then
		clone.Stats.preferredluck.Visible = false
		v7 -= 1
	end

	if v6.Lure == 0 then
		clone.Stats.lurespeed.Visible = false
		v7 -= 1
	end

	if v6.Resilience == 0 then
		clone.Stats.resilience.Visible = false
		v7 -= 1
	end

	if v7 > 5 then
		for _, label in clone.Stats:GetChildren() do
			if label:IsA("TextLabel") then
				label.Size = UDim2.fromScale(1, 0.2)
			end
		end
	end

	if v6.Icon then
		clone.ImageLabel.Visible = true
		clone.ImageLabel.Image = v6.Icon
		clone.MouseEnter:Connect(function()
			clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, baits.ScrollingFrame, true)
		end)
		clone.MouseLeave:Connect(function()
			clone.UIStroke.Color = rarity.Color
		end)
	end

	clone.Parent = baits.ScrollingFrame
	clone.Equip.Activated:Connect(function()
		if bait2.Value == joined then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, baits.ScrollingFrame, false)
			remoteEvent:FireServer("None")
		else
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, baits.ScrollingFrame, false)
			remoteEvent:FireServer(joined)
		end
	end)
	local v8 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Baits", joined })
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		local favorite = clone.favorite
		favorite.Image = v8 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
		favorite.ImageTransparency = v8 and 0.25 or 0.75
		local imageColor

		if v8 then
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
		v8 = not v8
		updateFavorited() -- equivalent call inferred; original call site unknown

		if not remoteFunction:InvokeServer("Baits", joined, v8) then
			v8 = not v8
			updateFavorited() -- equivalent call inferred; original call site unknown
		end

		flag2 = false
	end)
	updateFavorited() -- equivalent call inferred; original call site unknown
	return clone
end

return {
	Init = function(_)
		local function updateBaitFrame(p)
			local v6 = string.split(p.Name, "_")
			local joined = table.concat(table.move(v6, 2, #v6, 1, {}), " ")

			if v6[1] ~= "bait" or not bait[joined] then
				return
			end

			local value = p.Value
			local v7 = value > 0
			local v8 = v2[joined]
			resort() -- equivalent call inferred; original call site unknown

			if v7 then
				if not v8 then
					v8 = createBaitFrame(joined)
					v2[joined] = v8
				end

				assert(v8 ~= nil, "currentFrame is nil")
				v8.Info.amount.Text = `x{value}`
			elseif value <= 0 and v8 then
				if v8 == v3 then
					v3 = nil
				end

				v8:Destroy()
				v2[joined] = nil
				local flag2 = false

				for _, frame in script.Parent:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					flag2 = true
					break
				end

				if flag2 then
					return
				end

				if script.Parent:FindFirstChild("none") then
					return
				else
					local clone = script.none:Clone()
					clone.Parent = script.Parent
				end
			end
		end

		for _, numberValue in bait2:GetChildren() do
			if not numberValue:IsA("NumberValue") then
				continue
			end

			task.defer(updateBaitFrame, numberValue)
			local v6 = numberValue
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				task.spawn(updateBaitFrame, v6)
			end)
		end

		bait2.ChildAdded:Connect(function(numberValue)
			if not numberValue:IsA("NumberValue") then
				return
			end

			task.defer(updateBaitFrame, numberValue)
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				task.spawn(updateBaitFrame, numberValue)
			end)
		end)
		sortSelection.Activated:Connect(function()
			sortOptions.Visible = not sortOptions.Visible
		end)
		playerDataReplicator:Listen({ "FavoritedEquipment", "Baits" }, resort)
		bait2:GetPropertyChangedSignal("Value"):Connect(updateEquippedBait)
		task.defer(updateEquippedBait)

		for k, childName in v5 do
			if sortOptions:FindFirstChild(childName) then
				continue
			end

			local clone = script.optionTemplate:Clone()
			clone.Text = v4[childName]
			clone.Name = childName
			clone.LayoutOrder = k
			clone.Parent = sortOptions
			local v6 = childName
			clone.Activated:Connect(function()
				v = v6
				sortOptions.Visible = false
				sortSelection.label.Text = v4[v6]
				sortSelection.label.TextColor3 = Color3.fromRGB(238, 238, 238)
				sortSelection.ArrowDropDown.ImageColor3 = Color3.fromRGB(238, 238, 238)
				resort() -- equivalent call inferred; original call site unknown
			end)
		end
	end
}