local MobileTextbox = {}
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TextService")
local Players = game:GetService("Players")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local UI = require(ReplicatedStorage.Modules.UI)
local mobileTextbox = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileTextbox")
local _ = mobileTextbox.Background
local box = mobileTextbox.Box
local input = box.Input
local touchEnabled = UserInputService.TouchEnabled
local v = nil

if UI:GetDeviceType() == "Tablet" then
	input.TextSize *= 1.3
end

local function getTextBoxHeight()
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = input.Text
	getTextBoundsParams.RichText = input.RichText
	getTextBoundsParams.Font = input.FontFace
	getTextBoundsParams.Size = input.TextSize
	getTextBoundsParams.Width = input.AbsoluteSize.X
	local textBounds = UI:GetTextBounds(getTextBoundsParams)
	getTextBoundsParams:Destroy()
	return textBounds.Y + 25
end

local function updateBoxSize()
	local v2 = UI:GetDeviceType() == "Tablet" and 0.4 or 0.55
	local textBoxHeight = getTextBoxHeight()
	local v3 = box.UIPadding.PaddingTop.Offset + box.UIPadding.PaddingBottom.Offset
	local v4 = mobileTextbox.AbsoluteSize.Y - UserInputService.OnScreenKeyboardSize.Y
	box.Size = UDim2.new(v2, 0, 0, (math.min(v4, textBoxHeight + v3)))
end

function MobileTextbox.new(textBox)
	local object = setmetatable({}, {
		__index = MobileTextbox
	})
	object.TextBox = textBox
	object.TextChanged = FastSignal.new()
	object.Focused = FastSignal.new()
	object.FocusLost = FastSignal.new()

	if touchEnabled then
		object.TextBox.Focused:Connect(function()
			v = nil
			mobileTextbox.Enabled = true
			input.Text = object.TextBox.Text
			v = object
			task.wait()
			input:CaptureFocus()
		end)
		return object
	end

	object.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		return object.TextChanged:Fire(object.TextBox.Text)
	end)
	object.TextBox.Focused:Connect(function()
		return object.Focused:Fire()
	end)
	object.TextBox.FocusLost:Connect(function(flag: boolean)
		return object.FocusLost:Fire(flag)
	end)
	return object
end

function MobileTextbox.GetText(p)
	return p.TextBox.Text
end

function MobileTextbox.SetText(p, text: string)
	if not touchEnabled then
		p.TextBox.Text = text
	elseif v == p then
		input.Text = text
	end
end

input:GetPropertyChangedSignal("Text"):Connect(function()
	if v then
		v.TextBox.Text = input.Text
		v.TextChanged:Fire(input.Text)
	end

	updateBoxSize()
end)
input.Focused:Connect(function()
	local v2 = v

	if v then
		v.Focused:Fire()
	end

	task.defer(function()
		if v == v2 then
			local text = v.TextBox.Text
			v.TextBox.Text = ""
			task.wait()
			v.TextBox.Text = text
		end
	end)
	updateBoxSize()
end)
input.FocusLost:Connect(function(flag: boolean)
	if v then
		v.FocusLost:Fire(flag)
		v = nil
	end

	task.wait()
	mobileTextbox.Enabled = false
end)
UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible"):Connect(updateBoxSize)
return MobileTextbox