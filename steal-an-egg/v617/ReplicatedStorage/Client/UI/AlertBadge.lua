local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local Signal = require(ReplicatedStorage.Packages.Signal)
local uDim = UDim2.fromScale(0.994, 0.089)
local uDim2 = UDim2.fromScale(0.147, 0.501)
local color = Color3.fromRGB(255, 0, 0)
local color2 = Color3.fromRGB(56, 0, 14)
local color3 = Color3.fromRGB(255, 255, 255)
local rbxassetid12187365977 = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold)
local uDim3 = UDim2.fromScale(0.8, 0.8)
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, -1, true)
local AlertBadge = {}
AlertBadge.__index = AlertBadge

local function build(guiObject, data)
	local alertBadge = guiObject:FindFirstChild("AlertBadge")

	if alertBadge ~= nil and alertBadge:IsA("Frame") then
		return alertBadge
	end

	local frame = Instance.new("Frame")
	frame.Name = "AlertBadge"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.Position = data.Position or uDim
	frame.Size = data.Size or uDim2
	frame.Visible = false
	frame.ZIndex = data.ZIndex or 6
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = color2
	uIStroke.Thickness = 1.3
	uIStroke.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = rbxassetid12187365977
	textLabel.Name = "TextLabel"
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = uDim3
	textLabel.Text = data.Text or "!"
	textLabel.TextColor3 = color3
	textLabel.TextScaled = true
	textLabel.ZIndex = frame.ZIndex + 1
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Thickness = 1.1
	uIStroke2.Parent = textLabel
	textLabel.Parent = frame
	frame.Parent = guiObject
	return frame
end

function AlertBadge.new(items, options)
	local v = options or {}
	local object = setmetatable({
		Dismissed = Signal.new(),
		_badges = {},
		_connections = {},
		_tweens = {},
		_pulse = v.Pulse ~= false,
		_shown = false
	}, AlertBadge)

	for _, guiObject in items do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		table.insert(object._badges, (build(guiObject, v)))

		if v.DismissOnActivated ~= false and guiObject:IsA("GuiButton") then
			table.insert(object._connections, guiObject.Activated:Connect(function()
				object:Dismiss()
			end))
		end
	end

	return object
end

function AlertBadge.Attach(p, p2)
	return AlertBadge.new(p == nil and {} or { p }, p2)
end

function AlertBadge:IsShown()
	return self._shown
end

function AlertBadge:SetText(text: string)
	for _, folder in self._badges do
		for _, label in folder:GetDescendants() do
			if label:IsA("TextLabel") then
				label.Text = text
			end
		end
	end
end

function AlertBadge:Show()
	if self._shown then
		return
	end

	self._shown = true

	for _, _badge in self._badges do
		_badge.Visible = true
		local uIScale = EnsureUIScale(_badge)

		if self._pulse then
			uIScale.Scale = 0.8
			local tween = TweenService:Create(uIScale, tweenInfo, {
				Scale = 1.2
			})
			tween:Play()
			table.insert(self._tweens, tween)
		else
			uIScale.Scale = 1
		end
	end
end

function AlertBadge:Dismiss()
	if not self._shown then
		return
	end

	self._shown = false

	for _, _tween in self._tweens do
		_tween:Cancel()
		_tween:Destroy()
	end

	table.clear(self._tweens)

	for _, _badge in self._badges do
		local ensureUIScale = EnsureUIScale(_badge)
		ensureUIScale.Scale = 1
		_badge.Visible = false
	end

	self.Dismissed:Fire()
end

function AlertBadge:Destroy()
	self:Dismiss()

	for _, _connection in self._connections do
		_connection:Disconnect()
	end

	table.clear(self._connections)

	for _, _badge in self._badges do
		_badge:Destroy()
	end

	table.clear(self._badges)
	self.Dismissed:Destroy()
end

return AlertBadge