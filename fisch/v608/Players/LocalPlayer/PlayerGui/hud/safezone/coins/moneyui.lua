local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage.shared.modules.fx.debris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local WorldController = require(legacyControllers.WorldController)
local CurrencyController = require(legacyControllers.CurrencyController)
local LocalCurrencies = require(ReplicatedStorage.shared.modules.LocalCurrencies)
local Trove = require(ReplicatedStorage.packages:WaitForChild("Trove"))
local dataName = WorldController:GetCurrencyData(WorldController:GetCurrentCurrency()).DataName
local _ = stats:WaitForChild(dataName).Value
script.Parent.Visible = false

function comma_value(p)
	local v = math.ceil(p)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local maid = Trove.new()
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent
local childrenByChildName = {}
local positionsByChildName = {}
local v = 0

local function setupUIReferences()
	for _, childName in ipairs({
		"worldstatuses",
		"StatChangeList",
		"coins",
		"lvl"
	}) do
		local child = parent:FindFirstChild(childName)

		if not child then
			continue
		end

		childrenByChildName[childName] = child
		positionsByChildName[childName] = child.Position
	end
end

local function moveUIElements(count: number)
	if v == count then
		return
	end

	v = count
	local v2 = count * -0.038

	for k, v3 in pairs(childrenByChildName) do
		local uDim

		if count then
			local v4 = positionsByChildName[k] or v3.Position
			uDim = UDim2.new(v4.X.Scale, v4.X.Offset, v4.Y.Scale + v2, v4.Y.Offset)
		else
			uDim = positionsByChildName[k] or v3.Position
		end

		TweenService:Create(v3, TweenInfo.new(0.3), {
			Position = uDim
		}):Play()
	end
end

local function setupDefaultCurrencyTracking()
	local child = stats:WaitForChild(dataName)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateText(value)
		script.Parent.Text = CurrencyController:GetFormatting():format(comma_value(value))
	end

	UpdateText(child.Value) -- equivalent call inferred; original call site unknown
	local value2 = child.Value
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = value2
	maid:Add(numberValue)
	local v2 = false
	maid:Add(numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateText(numberValue.Value) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			if v2 == false then
				v2 = true
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.currencygain, script.Parent, true)
				task.wait(0.08)
				v2 = false
			end
		end)
	end))
	maid:Add(child:GetPropertyChangedSignal("Value"):Connect(function()
		TweenService:Create(numberValue, TweenInfo.new(0.6), {
			Value = child.Value
		}):Play()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.currencygain, script.Parent, true)
		task.spawn(function()
			local WAIT_INTERVAL = 0.1
			local v3 = value2 > child.Value
			local color = v3 and Color3.fromRGB(212, 62, 62) or Color3.fromRGB(99, 203, 61)
			GeneralUIModule:ListOnBottomRight(
				(v3 and "-" or "+") .. comma_value((math.abs(value2 - child.Value))),
				color,
				0
			)
			value2 = child.Value
			script.Parent.TextColor3 = color
			task.wait(WAIT_INTERVAL)
			script.Parent.TextColor3 = Color3.fromRGB(255, 253, 228)
			task.wait(WAIT_INTERVAL)
			script.Parent.TextColor3 = color
			task.wait(WAIT_INTERVAL)
			script.Parent.TextColor3 = Color3.fromRGB(255, 253, 228)
		end)
	end))
	script.Parent.Visible = true
	local fishBG = script.Parent:FindFirstChild("fishBG")

	if fishBG then
		TweenService:Create(fishBG, TweenInfo.new(90, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {
			Rotation = -9
		}):Play()
	end
end

local function setupLocalCurrencyDisplay(part, p: number)
	local localCurrency = LocalCurrencies[part]

	if not localCurrency then
		return
	end

	local child = legacyLocalPlayerData.fetch().LocalCurrencies:WaitForChild(part)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "localCurrency"
	textLabel.Text = "0 " .. localCurrency.DisplayName
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Italic
	)
	textLabel.TextSize = script.Parent.TextSize
	textLabel.BackgroundTransparency = 1
	textLabel.Position = (positionsByChildName.coins or script.Parent.Position) + UDim2.fromScale(0, p * -0.038)
	textLabel.AnchorPoint = script.Parent.AnchorPoint
	textLabel.Size = script.Parent.Size
	textLabel.TextXAlignment = script.Parent.TextXAlignment
	textLabel.TextYAlignment = script.Parent.TextYAlignment
	textLabel.TextScaled = script.Parent.TextScaled
	local colorGradient = localCurrency.ColorGradient

	if not colorGradient then
		if typeof(localCurrency.Color) == "ColorSequence" then
			colorGradient = localCurrency.Color or nil
		else
			colorGradient = nil
		end
	end

	local uIGradient = nil

	if colorGradient then
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		uIGradient = Instance.new("UIGradient")
		uIGradient.Color = colorGradient
		uIGradient.Rotation = localCurrency.ColorRotation or 0
		uIGradient.Offset = Vector2.new(localCurrency.ColorOffsetX or 0, localCurrency.ColorOffsetY or 0)
		uIGradient.Parent = textLabel
	else
		textLabel.TextColor3 = localCurrency.Color or Color3.fromRGB(255, 255, 255)
	end

	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 1.4
	uIStroke.Transparency = 0.3
	uIStroke.LineJoinMode = Enum.LineJoinMode.Round
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	local strokeColorGradient = localCurrency.StrokeColorGradient

	if not strokeColorGradient then
		if typeof(localCurrency.StrokeColor) == "ColorSequence" then
			strokeColorGradient = localCurrency.StrokeColor or nil
		else
			strokeColorGradient = nil
		end
	end

	if strokeColorGradient then
		uIStroke.Color = Color3.fromRGB(255, 255, 255)
		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Color = strokeColorGradient
		uIGradient2.Rotation = localCurrency.StrokeColorRotation or 0
		uIGradient2.Offset = Vector2.new(localCurrency.StrokeColorOffsetX or 0, localCurrency.StrokeColorOffsetY or 0)
		uIGradient2.Parent = uIStroke
	else
		uIStroke.Color = localCurrency.StrokeColor or Color3.fromRGB(54, 45, 3)
	end

	uIStroke.Parent = textLabel
	textLabel.TextTruncate = Enum.TextTruncate.None
	textLabel.RichText = false
	textLabel.Parent = parent

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLocalText(p2)
		textLabel.Text = string.format("%s %s", comma_value(p2), localCurrency.DisplayName)
	end

	local value = child.Value
	updateLocalText(value) -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setDisplayColor(color)
		if uIGradient then
			uIGradient.Enabled = false
		end

		textLabel.TextColor3 = color
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreDisplayColor()
		if not uIGradient then
			textLabel.TextColor3 = localCurrency.Color or Color3.fromRGB(255, 255, 255)
			return
		end

		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		uIGradient.Enabled = true
	end

	maid:Add(child:GetPropertyChangedSignal("Value"):Connect(function()
		local WAIT_INTERVAL = 0.1
		local value2 = child.Value
		updateLocalText(value2) -- equivalent call inferred; original call site unknown
		local color = value2 < value and Color3.fromRGB(212, 62, 62) or Color3.fromRGB(99, 203, 61)
		setDisplayColor(color) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		restoreDisplayColor() -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		setDisplayColor(color) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		restoreDisplayColor() -- equivalent call inferred; original call site unknown
		value = value2
	end))
	maid:Add(textLabel)
end

local function updateCurrencyDisplay()
	maid:Clean()
	local parts = (localPlayer:GetAttribute("DisplayedCurrency") or ""):split(";;")

	if parts[1] == "" then
		table.clear(parts)
	else
		table.sort(parts)
	end

	local count = #parts
	moveUIElements(count)
	setupDefaultCurrencyTracking()

	for _, child in parent:GetChildren() do
		if child.Name == "localCurrency" then
			child:Destroy()
		end
	end

	if count > 0 then
		for k, part in parts do
			setupLocalCurrencyDisplay(part, k - 1)
		end
	end
end

setupUIReferences()
updateCurrencyDisplay()
localPlayer:GetAttributeChangedSignal("DisplayedCurrency"):Connect(function()
	updateCurrencyDisplay()
end)
script.Destroying:Connect(function()
	maid:Clean()
end)