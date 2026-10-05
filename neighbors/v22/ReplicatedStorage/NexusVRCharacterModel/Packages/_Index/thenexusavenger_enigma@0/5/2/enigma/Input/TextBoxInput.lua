local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextBoxInput = {}
TextBoxInput.__index = TextBoxInput

function TextBoxInput.new(p)
	local object = setmetatable({
		WindowFocused = true,
		LastHeartbeatTime = 0,
		Events = {},
		TextBoxEvents = {}
	}, TextBoxInput)
	object:CreateTextBox(p or Players.LocalPlayer:WaitForChild("PlayerGui"))
	table.insert(object.Events, UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.F13 then
			return
		end

		object.LastHeartbeatTime = tick()
		object:TryCaptureFocus()
	end))
	table.insert(object.Events, UserInputService.WindowFocused:Connect(function()
		object.WindowFocused = true
		object:TryCaptureFocus()
	end))
	table.insert(object.Events, UserInputService.WindowFocusReleased:Connect(function()
		object.WindowFocused = false
		object:TryReleaseFocus()
	end))
	table.insert(object.Events, RunService.Stepped:Connect(function()
		object:TryCaptureFocus()
	end))
	return object
end

function TextBoxInput:CreateTextBox(parent)
	for _, textBoxEvent in self.TextBoxEvents do
		textBoxEvent:Disconnect()
	end

	self.TextBoxEvents = {}

	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end

	if self.TextBox then
		self.TextBox:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EnigmaTextBoxInput"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parent
	self.ScreenGui = screenGui
	local textBox = Instance.new("TextBox")
	textBox.Name = "EnigmaTextBox"
	textBox.BackgroundTransparency = 0.99
	textBox.BorderSizePixel = 0
	textBox.Size = UDim2.new(0, 1, 0, 1)
	textBox.Selectable = false
	textBox.ClipsDescendants = true
	textBox.ClearTextOnFocus = true
	textBox.TextTransparency = 0.99
	textBox.Parent = screenGui
	self.TextBox = textBox
	table.insert(self.TextBoxEvents, textBox.AncestryChanged:Connect(function()
		self:CreateTextBox(parent)
	end))

	for _, propertyName in { "Enabled" } do
		local v2 = propertyName
		local v3 = screenGui[propertyName]
		table.insert(self.TextBoxEvents, screenGui:GetPropertyChangedSignal(propertyName):Connect(function()
			screenGui[v2] = v3
		end))
	end

	for _, propertyName in {
		"BackgroundTransparency",
		"Size",
		"ClipsDescendants",
		"Visible",
		"TextTransparency"
	} do
		local v2 = propertyName
		local v3 = textBox[propertyName]
		table.insert(self.TextBoxEvents, textBox:GetPropertyChangedSignal(propertyName):Connect(function()
			textBox[v2] = v3
		end))
	end
end

function TextBoxInput.GetCurrentText(p)
	if p.TextBox then
		return p.TextBox.Text
	end

	return ""
end

function TextBoxInput:TryCaptureFocus()
	if not self.WindowFocused or tick() - self.LastHeartbeatTime > 0.5 then
		self:TryReleaseFocus()
		return
	end

	if not (self.TextBox and UserInputService:GetFocusedTextBox() ~= self.TextBox) then
		return
	end

	self.TextBox:CaptureFocus()
end

function TextBoxInput:TryReleaseFocus()
	if not (self.TextBox and UserInputService:GetFocusedTextBox() == self.TextBox) then
		return
	end

	self.TextBox:ReleaseFocus()
end

function TextBoxInput:Destroy()
	for _, event in self.Events do
		event:Disconnect()
	end

	self.Events = {}

	for _, textBoxEvent in self.TextBoxEvents do
		textBoxEvent:Disconnect()
	end

	self.TextBoxEvents = {}

	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end

	self.ScreenGui = nil

	if self.TextBox then
		self.TextBox:Destroy()
	end

	self.TextBox = nil
end

return TextBoxInput