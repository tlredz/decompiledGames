local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local UI = require(modules.UI)
local _ = Players.LocalPlayer
local parent = script.Parent
local imageLabel = parent:WaitForChild("ImageLabel")
local edit = parent:WaitForChild("Edit")
local textBox = imageLabel:WaitForChild("TextBox")
local events = parent:WaitForChild("Events")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local color3Value = Instance.new("Color3Value")
local tween = TweenService:Create(color3Value, tweenInfo, {
	Value = Color3.fromRGB(0, 0, 0)
})
local v = false
local changedConnection = nil
local uDim = UDim2.new(0.5, 0, 0.5, 0)
local uDim2 = UDim2.new(0.5, 0, 1.5, 0)
UI:Bind(imageLabel.Confirm.Button)
UI:Bind(imageLabel.Close.Button)

local function colorAfterCharacterLimit(text)
	if tween.PlaybackState == Enum.PlaybackState.Playing then
		return
	end

	color3Value.Value = Color3.fromRGB(255, 0, 0)
	tween:Play()
	local v2 = string.sub(text, 1, 20)
	local v3 = string.sub(text, 21)

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	changedConnection = color3Value.Changed:Connect(function(p)
		if p == Color3.fromRGB(0, 0, 0) then
			textBox.Text = `{v2}{v3}`
			textBox.TextEditable = true
			changedConnection:Disconnect()
			changedConnection = nil
		else
			textBox.TextEditable = false
			textBox.Text = `{v2}<font color="#{p:ToHex()}">{v3}</font>`
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function validateText()
	local text = textBox.Text

	if #text > 20 then
		colorAfterCharacterLimit(text)
		_G.DisplayError("Sticky Note input cannot exceed 20 characters.", 5)
		return false
	else
		return true
	end
end

events.Visbility.Event:Connect(function(p)
	if p == nil then
		v = not v
	elseif v == p then
		return
	else
		v = p
	end

	edit.Visible = not v
	script.Toggle:Play()

	if v then
		imageLabel.Visible = true
		imageLabel.Position = uDim2
		TweenService:Create(imageLabel, tweenInfo, {
			Position = uDim
		}):Play()
	else
		TweenService:Create(imageLabel, tweenInfo, {
			Position = uDim2
		}):Play()
		task.delay(tweenInfo.Time, function()
			if imageLabel.Position == uDim2 then
				textBox.Text = ""
				imageLabel.Visible = false
			end
		end)
	end
end)
imageLabel:GetPropertyChangedSignal("Visible"):Connect(function()
	parent.Background.Visible = imageLabel.Visible
end)
imageLabel.Confirm.Button.Activated:Connect(function()
	if v then
		-- equivalent call inferred; original call site unknown
		if validateText() then
			script.Confirm:Play()
			events.TextUpdated:Fire(textBox.Text)
			events.Visbility:Fire(false)
		end
	end
end)
imageLabel.Close.Button.Activated:Connect(function()
	events.Visbility:Fire(false)
end)
edit.Button.Activated:Connect(function()
	events.Visbility:Fire(not v)
end)
UI:Bind(edit.Button)
UI:AddShadowOnHover(edit.Button)
UI:RegisterUIScale(imageLabel.UIScale, {
	PC = 1,
	Mobile = 1,
	Tablet = 1
})
UI:RegisterUIScale(edit.UIScale, {
	PC = 1,
	Mobile = 1.1,
	Tablet = 1
})