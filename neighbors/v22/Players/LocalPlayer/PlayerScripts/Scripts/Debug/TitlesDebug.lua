local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
	return
end

local Iris = require(ReplicatedStorage.Modules.Iris)
local Title = require(ReplicatedStorage.Modules.Title)
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local Animations = require(ReplicatedStorage.Modules.Title.Animations)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}

for k in Titles do
	table.insert(v, k)
end

table.sort(v)

for k in Animations do
	table.insert(v2, k)
end

table.sort(v2)
table.insert(v2, 1, "None")

local function findLocalBillboard()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	for _, billboardGui in character:GetDescendants() do
		if billboardGui:IsA("BillboardGui") and billboardGui:FindFirstChild("Title", true) then
			return billboardGui
		end
	end

	for _, billboardGui in localPlayer.PlayerGui:GetDescendants() do
		if billboardGui:IsA("BillboardGui") and billboardGui.Adornee and billboardGui.Adornee:IsDescendantOf(character) and billboardGui:FindFirstChild(
			"Title",
			true
		) then
			return billboardGui
		end
	end

	return nil
end

Iris.Init(nil, nil, true)
local state = Iris.State(false)
local state2 = Iris.State(v[1])
local flag = false

local function applyTitle()
	local title = Titles[state2.value]
	local localBillboard = findLocalBillboard()

	if title and localBillboard then
		localBillboard:SetAttribute("InternalActiveTitle", nil)
		Title:ConstructWithInfo(localPlayer, localBillboard, title)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queueApply()
	if flag then
		return
	end

	flag = true
	task.delay(0.15, function()
		flag = false
		local title = Titles[state2.value]
		local localBillboard = findLocalBillboard()

		if title then
			if not localBillboard then
				return
			end

			localBillboard:SetAttribute("InternalActiveTitle", nil)
			Title:ConstructWithInfo(localPlayer, localBillboard, title)
		end
	end)
end

local function resolveFont(p: string)
	if p == "" then
		return nil
	end

	local success, result = pcall(function()
		return Enum.Font[p]
	end)

	if success then
		return result
	end

	return p
end

local function registerFieldState(value: string, p: string, object, callback)
	local v4 = v3[value]

	if not v4 then
		v4 = {}
		v3[value] = v4
	end

	if v4[p] then
		return
	end

	v4[p] = object
	object:onChange(function(p2)
		local title = Titles[value]

		if title then
			if callback then
				p2 = callback(p2)
			end

			title[p] = p2
		end

		queueApply() -- equivalent call inferred; original call site unknown
	end)
end

local function registerGradientStates(value: string, object, object2, object3, object4)
	local v4 = v3[value]

	if not v4 then
		v4 = {}
		v3[value] = v4
	end

	if v4.Gradient then
		return
	end

	v4.Gradient = true

	local function rebuild()
		local title = Titles[value]

		if not title then
			return
		end

		if object.value then
			title.Gradient = ColorSequence.new(object2.value, object3.value)
			title.GradientRotation = object4.value
		else
			title.Gradient = nil
			title.GradientRotation = nil
		end

		queueApply() -- equivalent call inferred; original call site unknown
	end

	object:onChange(rebuild)
	object2:onChange(rebuild)
	object3:onChange(rebuild)
	object4:onChange(rebuild)
end

state2:onChange(function()
	if flag then
		return
	end

	flag = true
	task.delay(0.15, function()
		flag = false
		local title = Titles[state2.value]
		local localBillboard = findLocalBillboard()

		if title then
			if not localBillboard then
				return
			end

			localBillboard:SetAttribute("InternalActiveTitle", nil)
			Title:ConstructWithInfo(localPlayer, localBillboard, title)
		end
	end)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.J then
		state:set(not state.value)
	end
end)
Iris:Connect(function()
	if not state.value then
		return
	end

	Iris.Window({ "Title Tuner" }, {
		isOpened = state
	})
	local state3 = Iris.State("")
	Iris.InputText({ "Search", "title name" }, {
		text = state3
	})
	local value = string.lower(state3.value)

	if value == "" then
		Iris.ComboArray({ "Title" }, {
			index = state2
		}, v)
	else
		local count = 0

		for _, v4 in v do
			if not string.find(string.lower(v4), value, 1, true) then
				continue
			end

			count += 1

			if count <= 10 then
				Iris.Selectable({ v4, v4 }, {
					index = state2
				})
			end
		end

		if count == 0 then
			Iris.Text({ "No titles match" })
		elseif count > 10 then
			Iris.Text({ (`{count - 10} more hidden, keep typing`) })
		end
	end

	local value2 = state2.value
	local v4 = value2 and Titles[value2]

	if v4 then
		Iris.PushId(value2)
		Iris.Text({ (`Category: {v4.Category}  Rarity: {tostring(v4.Rarity)}`) })
		local state4 = Iris.State(v4.Color or Color3.new(1, 1, 1))
		registerFieldState(value2, "Color", state4)
		Iris.InputColor3({ "Color" }, {
			color = state4
		})
		local state5 = Iris.State(v4.StrokeColor or Color3.new(0, 0, 0))
		registerFieldState(value2, "StrokeColor", state5)
		Iris.InputColor3({ "StrokeColor" }, {
			color = state5
		})
		local state6 = Iris.State(v4.StrokeTransparency or 0.25)
		registerFieldState(value2, "StrokeTransparency", state6)
		Iris.DragNum({
			"StrokeTransparency",
			0.01,
			0,
			1
		}, {
			number = state6
		})
		local state7 = Iris.State(v4.Size or 0)
		registerFieldState(value2, "Size", state7)
		Iris.DragNum({
			"Size",
			0.5,
			-10,
			20
		}, {
			number = state7
		})
		local state8 = Iris.State(v4.Bold == true)
		registerFieldState(value2, "Bold", state8)
		Iris.Checkbox({ "Bold" }, {
			isChecked = state8
		})
		local state9 = Iris.State(v4.Italic == true)
		registerFieldState(value2, "Italic", state9)
		Iris.Checkbox({ "Italic" }, {
			isChecked = state9
		})
		local state10 = Iris.State(v4.DontWrapInBrackets == true)
		registerFieldState(value2, "DontWrapInBrackets", state10)
		Iris.Checkbox({ "DontWrapInBrackets" }, {
			isChecked = state10
		})
		local state11 = Iris.State
		local v5

		if typeof(v4.Font) == "EnumItem" then
			v5 = v4.Font.Name
		else
			v5 = v4.Font or ""
		end

		local text = state11(v5)
		registerFieldState(value2, "Font", text, resolveFont)
		Iris.InputText({ "Font", "Enum name or rbxassetid://" }, {
			text = text
		})
		local state12 = Iris.State(v4.Animation or "None")
		registerFieldState(value2, "Animation", state12, function(p: string)
			if p == "None" then
				return nil
			end

			return p
		end)
		Iris.ComboArray({ "Animation" }, {
			index = state12
		}, v2)
		Iris.SeparatorText({ "Gradient" })
		local gradient = v4.Gradient
		local state13 = Iris.State(gradient ~= nil)
		local state14 = Iris.State
		local v7

		if gradient then
			v7 = gradient.Keypoints[1].Value
		else
			v7 = Color3.new(1, 1, 1)
		end

		local color = state14(v7)
		local state15 = Iris.State
		local v9

		if gradient then
			v9 = gradient.Keypoints[#gradient.Keypoints].Value
		else
			v9 = Color3.new(1, 1, 1)
		end

		local color2 = state15(v9)
		local state16 = Iris.State(v4.GradientRotation or 0)
		registerGradientStates(value2, state13, color, color2, state16)
		Iris.Checkbox({ "Gradient Enabled" }, {
			isChecked = state13
		})
		Iris.InputColor3({ "Gradient Start" }, {
			color = color
		})
		Iris.InputColor3({ "Gradient End" }, {
			color = color2
		})
		Iris.DragNum({
			"Gradient Rotation",
			1,
			0,
			360
		}, {
			number = state16
		})
		Iris.PopId()
	end

	if Iris.Button({ "Apply To Nametag" }).clicked() then
		task.spawn(applyTitle)
	end

	Iris.End()
end)