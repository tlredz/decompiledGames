local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3.Packages.Net)
local v2 = require3(ReplicatedStorage3.Packages.Replion)
local v3 = require3(ReplicatedStorage3.Common.SettingsInfo)
require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local SliderNode = {}
SliderNode.__index = SliderNode
local v4 = nil
local inputChangedConnection = nil
local inputEndedConnection = nil

local function stopDrag()
	local v5 = v4

	if not v5 then
		return
	end

	v4 = nil

	if inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end

	if inputEndedConnection then
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end

	if v5.buttonDown then
		v5.setValue(v5:DeformatValue(v5.textBox.Text))
	end

	v5.buttonDown = false
end

local function startDrag(object)
	stopDrag()
	v4 = object
	inputChangedConnection = v.InputChanged:Connect(function(input)
		local userInputType = input.UserInputType

		if (userInputType == Enum.UserInputType.MouseMovement or userInputType == Enum.UserInputType.Touch) and object.buttonDown then
			object:UpdateBarSize(object.settingInfo and object.settingInfo.TemplateType == "SubSlide")
		end
	end)
	inputEndedConnection = v.InputEnded:Connect(function(input)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch or userInputType == Enum.UserInputType.Gamepad1 then
			stopDrag()
		end
	end)
end

function SliderNode.new(frame, settingType: string, setValue, max: number, list)
	local object = setmetatable({}, SliderNode)
	object.dataReplion = v2.Client:WaitReplion("Data")
	object.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	object.setValue = setValue
	local settingInfo = nil

	for _, v7 in v3 do
		if v7[settingType] == nil then
			continue
		end

		settingInfo = v7[settingType]
		break
	end

	object.frame = frame
	object.barContainer = frame.SliderBarContainer
	object.bar = object.barContainer.Frame.Bar
	object.textBox = frame.TextBoxContainer.TextBox
	object.max = max
	object.settingType = settingType
	object.settingInfo = settingInfo
	object.mouse = Players.LocalPlayer:GetMouse()
	object.buttonDown = false
	object.isSelected = false
	object.barContainer.MouseButton1Down:Connect(function()
		object:UpdateBarSize(settingInfo and settingInfo.TemplateType == "SubSlide")
		startDrag(object)
	end)
	object.frame.QuickButton.Activated:Connect(function()
		object.setValue(settingInfo and settingInfo.Default or 0, true)

		if settingInfo and settingInfo.TemplateType == "SubSlide" or settingType == "Time Of Day" then
			object:Update(settingInfo.Default or 0)
		end
	end)

	if list then
		object.frame.QuickButton.Icon.Image = list[1]
		object.frame.QuickButton.SlashLine.Image = list[2]
		object.frame.QuickButton.BackgroundColor3 = Color3.fromRGB(24, 40, 91)
	end

	if settingInfo and settingInfo.Default > 0 then
		object.frame.QuickButton.Icon.Image = "rbxassetid://14986300321"
		object.frame.QuickButton.BackgroundColor3 = Color3.fromRGB(67, 139, 255)
		object.frame.QuickButton.SlashLine.Visible = false
	end

	object.selectionInputConn = nil
	object.barContainer.SelectionGained:Connect(function()
		object.isSelected = true

		if object.selectionInputConn then
			object.selectionInputConn:Disconnect()
		end

		object.selectionInputConn = v.InputBegan:Connect(function(input, gameProcessed)
			object:InputBegan(input, gameProcessed)
		end)
	end)
	object.barContainer.SelectionLost:Connect(function()
		object.isSelected = false

		if object.selectionInputConn then
			object.selectionInputConn:Disconnect()
			object.selectionInputConn = nil
		end
	end)
	object.textBox.FocusLost:Connect(function()
		object:OnTextFocusLost()
	end)
	object.textBox:GetPropertyChangedSignal("Text"):Connect(function()
		object.textBox.Text = object.textBox.Text:gsub("%s", "")
		local deformatValue = object:DeformatValue(object.textBox.Text)

		if deformatValue and object.max < deformatValue then
			object.textBox.Text = object:FormatValue(object.max)
		end
	end)
	return object
end

function SliderNode:FormatValue(p2: number)
	if self.settingType == "Time Of Day" then
		return string.format("%02i:%02i", p2 // 6, p2 % 6 * 10)
	end

	return (tostring(p2))
end

function SliderNode:DeformatValue(value: string)
	if self.settingType ~= "Time Of Day" then
		return tonumber(value) or 0
	end

	local match, v5 = value:match("(%d+):(%d+)")
	return tonumber(match) * 6 + tonumber(v5) / 10
end

function SliderNode:UpdateBarSize(p)
	local v5 = math.clamp(
		(self.mouse.X - self.barContainer.AbsolutePosition.X) / self.barContainer.AbsoluteSize.X,
		0,
		1
	)
	self.bar.Size = UDim2.new(v5, 0, 1, 0)
	self.buttonDown = v5 >= 0
	self.textBox.Text = self:FormatValue((math.floor(self.max * v5)))

	if p and (not self.settingInfo or self.settingInfo.Default == 0) then
		self.frame.QuickButton.SlashLine.Visible = v5 <= 0
	end
end

function SliderNode:OnTextFocusLost()
	local deformatValue = self:DeformatValue(self.textBox.Text)

	if deformatValue and deformatValue >= 0 and deformatValue <= self.max then
		self.bar.Size = UDim2.new(deformatValue / self.max, 0, 1, 0)
		self.setValue(deformatValue)
	end
end

function SliderNode:Update(p)
	local v5 = p / self.max
	self.bar.Size = UDim2.new(v5, 0, 1, 0)
	self.textBox.Text = self:FormatValue((math.floor(self.max * v5)))

	if not self.settingInfo or self.settingInfo.Default == 0 then
		self.frame.QuickButton.SlashLine.Visible = p <= 0
	end
end

function SliderNode:InputBegan(p, _)
	if not self.isSelected then
		return
	end

	local settings = self.dataReplion:Get("Settings")
	local v5 = nil

	for _, setting in settings do
		if setting[self.settingType] == nil then
			continue
		end

		v5 = setting
		break
	end

	local current = v5.Current

	if p.KeyCode == Enum.KeyCode.DPadRight then
		local v7 = current + 10
		local max = (v3.Volume[self.settingType] or v3.Misc[self.settingType]).Max

		if max < v7 then
			v7 = max
		end

		self.setValue(v7)
	elseif p.KeyCode == Enum.KeyCode.DPadLeft then
		local v7 = current - 10
		local v8 = v7 < 0 and 0 or v7
		self.setValue(v8)
	end
end

return SliderNode