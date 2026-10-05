local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GuiService = game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local v = require3(game.ReplicatedStorage.Packages.Replion)
local v2 = require3(game.ReplicatedStorage.Common.SettingsInfo)
local v3 = require3(game.ReplicatedStorage.ClientGameModules.GuiHandler)
local v4 = require3(localPlayer.PlayerScripts.Client.UIBindersLegacy.Draggable)
require3(game.ReplicatedStorage.Common.Utils)
local v5 = require3(game.ReplicatedStorage.Packages.Net)
require3(game.ReplicatedStorage.ServerInfo)
require3(game.ReplicatedStorage.Controllers.AnalyticsController)
local v6 = require3(game.ReplicatedStorage.ClientGameModules.DeviceListener)
local remoteEvent = v5:RemoteEvent("SetButtonScale")
local remoteEvent2 = v5:RemoteEvent("SetButtonPosition")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hotbar = playerGui:WaitForChild("Hotbar")
local editButtonLayout = playerGui:WaitForChild("EditButtonLayout")
local name = editButtonLayout.Name
local editScaleLabel = editButtonLayout.EditScaleLabel
local v7 = { hotbar.Ability, hotbar.Block }
local values = {}
local v8 = {}
local clones = {}
local v9 = nil

local function roundDecimals(p, value)
	local v10 = value or 2

	if v10 == 1 then
		return (tonumber(string.format("%.1f", p)))
	elseif v10 == 2 then
		return (tonumber(string.format("%.2f", p)))
	elseif v10 == 3 then
		return (tonumber(string.format("%.3f", p)))
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentScale(p)
	return v.Client:WaitReplion("Data"):Get({
		"Settings",
		"Misc",
		p .. "ButtonScale",
		"Current"
	})
end

local function editScale(p)
	if not v9 then
		return
	end

	local name2 = v9.Name

	if values[v9] then
		name2 = values[v9]
	end

	local currentScale = getCurrentScale(name2) -- equivalent call inferred; original call site unknown

	if p == 0.1 and currentScale == 2 or p == -0.1 and currentScale == 1 then
		return
	end

	local scale = roundDecimals(math.clamp(v9.UIScale.Scale + p, 1, 2), 1)
	v9.UIScale.Scale = scale
	editScaleLabel.Text = string.format("%s Button Size: %sx", name2, scale)
	remoteEvent:FireServer(name2, scale)
end

local function onOpen()
	local _ = v6.Device == "Phone"
	local _ = v6.Device == "Tablet"

	local function setupAbilityContainer(instance)
		local v10, _ = string.find(instance.Name, "Elemental")
		local v11

		if v10 then
			v11 = string.sub(instance.Name, 1, v10 - 1)

			if string.sub(v11, 1, 3) == "New" then
				v11 = string.sub(v11, 4)
			end
		else
			v11 = ""
		end

		for _, child in instance:GetChildren(), nil, nil do
			if child:GetAttribute("DONOTSHOW") then
				continue
			end

			local clone = child:Clone()
			clone:AddTag("UI_Draggable")
			clone.Position = child.Position
			local formatted = `Ability{clone.Name}{v11}`
			local uIScale = clone:FindFirstChildOfClass("UIScale")

			if uIScale then
				uIScale.Scale = v.Client:WaitReplion("Data"):Get({
					"Settings",
					"Misc",
					formatted .. "ButtonScale",
					"Current"
				})
			end

			values[clone] = formatted
			v8[clone] = `Ability {clone.Name}`
			clone.Visible = true
			clone.Parent = editButtonLayout
			table.insert(clones, clone)
		end
	end

	for _, v10 in v7 do
		local clone = v10:Clone()
		clone:AddTag("UI_Draggable")
		clone.Position = v10.Position
		local uIScale = clone.UIScale
		local name2 = clone.Name
		uIScale.Scale = v.Client:WaitReplion("Data"):Get({
			"Settings",
			"Misc",
			name2 .. "ButtonScale",
			"Current"
		})
		clone.Visible = true
		clone.Parent = editButtonLayout
		table.insert(clones, clone)
	end
end

local function onClose()
	for _, v10 in clones do
		v10:Destroy()
	end

	clones = {}
	v9 = nil
	editScaleLabel.Visible = false
end

local EditButtonLayoutController = {}

function EditButtonLayoutController.Start(_)
	editButtonLayout.Reset.Activated:Connect(function()
		for _, v10 in v7 do
			local name2 = v10.Name
			local child = editButtonLayout:FindFirstChild(name2)

			if not child then
				continue
			end

			local v11 = values[child] or name2
			child.UIScale.Scale = 1
			remoteEvent:FireServer(v11, 1)
			local default = v2.Misc[v11 .. "ButtonPosition"].Default
			child.Position = UDim2.fromScale(default.X, default.Y)
			local absolutePosition = child.AbsolutePosition
			local absoluteSize = editButtonLayout.AbsoluteSize
			local v12 = roundDecimals(absolutePosition.X / absoluteSize.X, 3)
			local v13 = roundDecimals(
				(absolutePosition.Y + GuiService.TopbarInset.Height * child.AnchorPoint.Y) / absoluteSize.Y,
				3
			)
			child.Position = UDim2.fromScale(v12, v13)
			remoteEvent2:FireServer(v11, {
				X = v12,
				Y = v13
			})
		end

		v9 = nil
		editScaleLabel.Visible = false
	end)
	editButtonLayout.Exit.Activated:Connect(function()
		v3:Close(name)
	end)
	v3:OnGuiOpen(name, onOpen)
	v3:OnGuiClose(name, onClose)
	v4.DragStarted:Connect(function(_, p)
		v9 = p
		local name2 = p.Name

		if v8[v9] then
			name2 = v8[v9]
		end

		local v10

		if values[v9] then
			v10 = values[v9]
		else
			v10 = name2
		end

		editScaleLabel.Text = string.format("%s Button Size: %sx", name2, getCurrentScale(v10))
		editScaleLabel.Visible = true
	end)

	local function roundDecimals2(p, p2)
		local v10 = 10 ^ p2
		return math.round(p * v10) / v10
	end

	roundDecimals = roundDecimals2

	local function convertToScale(p, state)
		local absolutePosition = state.AbsolutePosition
		local absoluteSize = editButtonLayout.AbsoluteSize
		local v10 = GuiService.TopbarInset.Height * state.AnchorPoint.Y
		local v11 = absolutePosition.X / absoluteSize.X
		local v12 = (absolutePosition.Y + v10) / absoluteSize.Y
		local v13 = roundDecimals(v11, 3)
		local v14 = roundDecimals(v12, 3)
		state.Position = UDim2.fromScale(v13, v14)
		remoteEvent2:FireServer(p, {
			X = v13,
			Y = v14
		})
	end

	v4.DragEnded:Connect(function(_, _)
		local _ = v9.Position
		local name2 = v9.Name

		if values[v9] then
			name2 = values[v9]
		end

		local absolutePosition = v9.AbsolutePosition
		local absoluteSize = editButtonLayout.AbsoluteSize
		local v10 = roundDecimals(absolutePosition.X / absoluteSize.X, 3)
		local v11 = roundDecimals(
			(absolutePosition.Y + GuiService.TopbarInset.Height * v9.AnchorPoint.Y) / absoluteSize.Y,
			3
		)
		v9.Position = UDim2.fromScale(v10, v11)
		remoteEvent2:FireServer(name2, {
			X = v10,
			Y = v11
		})
	end)
	editScaleLabel.Buttons.Increase.Activated:Connect(function()
		editScale(0.1)
	end)
	editScaleLabel.Buttons.Decrease.Activated:Connect(function()
		editScale(-0.1)
	end)
end

function EditButtonLayoutController.Init(_) end

return EditButtonLayoutController