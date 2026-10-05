local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 3, true)
local RobloxPrompt = {
	getScreenGUI = function()
		if not RunService:IsClient() then
			return
		end

		local playerGui = Players.LocalPlayer.PlayerGui

		if playerGui:FindFirstChild("robloxPrompt") then
			return playerGui.robloxPrompt
		end

		local screenGui = Instance.new("ScreenGui", playerGui)
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 999
		screenGui.Name = "robloxPrompt"
		return screenGui
	end,
	isPromptActive = function()
		if not RunService:IsClient() then
			return
		end

		local playerGui = Players.LocalPlayer.PlayerGui

		if not playerGui:FindFirstChild("robloxPrompt") then
			return false
		end

		if playerGui.robloxPrompt:FindFirstChild("prompt") then
			return true
		end

		return false
	end
}

function RobloxPrompt.newConfirmationPrompt(data, callback)
	if not RunService:IsClient() or RobloxPrompt.isPromptActive() then
		return
	end

	assert(type(data) == "table", (`options must be a table, got {type(data)}`))
	local screenGUI = RobloxPrompt.getScreenGUI()

	if screenGUI:FindFirstChild("prompt") and not screenGUI.prompt:GetAttribute("canOverride") then
		pcall(function()
			screenGUI.prompt.ZIndex = 100000
			TweenService:Create(screenGUI.prompt, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(67, 69, 71)
			}):Play()
		end)
		return
	end

	local clone = script.confirm_template:Clone()
	clone.Name = "prompt"
	clone.Position = UDim2.new(0.5, 0, -1, 0)
	clone.Frame.TitleContainer.TitleArea.Title.Text = data.title or "Meme Sea"
	clone.Frame.Footer.FooterContent.Content.FooterText.Text = data.footer or ""
	clone.Frame.MiddleContent.Content.Message.Text = data.message or "None"
	clone.Frame.Footer.Buttons.confirm.ButtonContent.ButtonMiddleContent.Text.Text = data.confirmtext or "Confirm"
	clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.Text = data.canceltext or "Cancel"

	if localPlayer:GetAttribute("TH") then
		clone.Frame.TitleContainer.TitleArea.Title.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
		clone.Frame.MiddleContent.Content.Message.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
		clone.Frame.Footer.Buttons.confirm.ButtonContent.ButtonMiddleContent.Text.FontFace = Font.fromId(
			11598121416,
			Enum.FontWeight.Bold
		)
		clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.FontFace = Font.fromId(
			11598121416,
			Enum.FontWeight.Bold
		)
		clone.Frame.Footer.FooterContent.Content.FooterText.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
	end

	if data.image then
		clone.Frame.MiddleContent.Content.ItemIcon.Visible = true
		clone.Frame.MiddleContent.Content.ItemIcon.Image = data.image
	end

	clone:SetAttribute("canOverride", data.canOverride)
	local flag = false
	local v = false
	clone.Frame.Footer.Buttons.cancel.MouseEnter:Connect(function()
		clone.Frame.Footer.Buttons.cancel.ImageTransparency = 0
		clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
	end)
	clone.Frame.Footer.Buttons.cancel.MouseLeave:Connect(function()
		clone.Frame.Footer.Buttons.cancel.ImageTransparency = 0.3
		clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.3
	end)
	clone.Frame.Footer.Buttons.cancel.MouseButton1Down:Connect(function()
		clone.Frame.Footer.Buttons.cancel.ImageTransparency = 0.65
		clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.65
	end)
	clone.Frame.Footer.Buttons.cancel.MouseButton1Up:Connect(function()
		clone.Frame.Footer.Buttons.cancel.ImageTransparency = 0.3
		clone.Frame.Footer.Buttons.cancel.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.3
	end)
	clone.Frame.Footer.Buttons.confirm.MouseButton1Down:Connect(function()
		clone.Frame.Footer.Buttons.confirm.ImageTransparency = 0.5
		clone.Frame.Footer.Buttons.confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0.5
	end)
	clone.Frame.Footer.Buttons.confirm.MouseButton1Up:Connect(function()
		clone.Frame.Footer.Buttons.confirm.ImageTransparency = 0
		clone.Frame.Footer.Buttons.confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
	end)
	clone.Frame.Footer.Buttons.confirm.MouseLeave:Connect(function()
		clone.Frame.Footer.Buttons.confirm.ImageTransparency = 0
		clone.Frame.Footer.Buttons.confirm.ButtonContent.ButtonMiddleContent.Text.TextTransparency = 0
	end)
	clone.Frame.Footer.Buttons.confirm.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		v = true
	end)
	clone.Frame.Footer.Buttons.cancel.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
	end)
	clone.Parent = screenGUI
	clone:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 1)

	repeat
		task.wait(0.1)
	until flag

	clone:TweenPosition(UDim2.new(0.5, 0, -1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 1)

	if callback then
		task.delay(1, function()
			clone:Destroy()
			callback(v)
		end)
	else
		task.delay(1, function()
			clone:Destroy()
		end)
	end
end

function RobloxPrompt.newPrompt(data, callback)
	if not RunService:IsClient() or RobloxPrompt.isPromptActive() then
		return
	end

	assert(type(data) == "table", (`options must be a table, got {type(data)}`))
	local screenGUI = RobloxPrompt.getScreenGUI()

	if screenGUI:FindFirstChild("prompt") and not screenGUI.prompt:GetAttribute("canOverride") then
		pcall(function()
			screenGUI.prompt.ZIndex = 100000
			TweenService:Create(screenGUI.prompt, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(67, 69, 71)
			}):Play()
		end)
		return
	end

	local clone = script.okay_template:Clone()
	clone.Name = "prompt"
	clone.Position = UDim2.new(0.5, 0, -1, 0)
	clone.title.Text = data.title or "Roblox"
	clone.holder.message.Text = data.message or "None"

	if data.image then
		clone.holder.icon.Visible = true
		clone.holder.icon.Image = data.image
	end

	clone:SetAttribute("canOverride", data.canOverride)
	local flag = false
	clone.holder.buttonHolder.okay.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
	end)
	clone.Parent = screenGUI
	clone:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1)

	repeat
		task.wait(0.1)
	until flag

	clone:TweenPosition(UDim2.new(0.5, 0, -1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1)

	if callback then
		task.delay(1, function()
			clone:Destroy()
			callback(flag)
		end)
	else
		task.delay(1, function()
			clone:Destroy()
		end)
	end
end

function RobloxPrompt.newInputPrompt(data, callback)
	if not RunService:IsClient() or RobloxPrompt.isPromptActive() then
		return
	end

	assert(type(data) == "table", (`options must be a table, got {type(data)}`))
	local screenGUI = RobloxPrompt.getScreenGUI()

	if screenGUI:FindFirstChild("prompt") and not screenGUI.prompt:GetAttribute("canOverride") then
		pcall(function()
			screenGUI.prompt.ZIndex = 100000
			TweenService:Create(screenGUI.prompt, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(67, 69, 71)
			}):Play()
		end)
		return
	end

	local clone = script.input_template:Clone()
	clone.Name = "prompt"
	clone.Position = UDim2.new(0.5, 0, -1, 0)
	clone.title.Text = data.title or "Roblox"
	clone.holder.input.box.PlaceholderText = data.message or "Please type some message"

	if data.image then
		clone.holder.icon.Visible = true
		clone.holder.icon.Image = data.image
	end

	clone:SetAttribute("canOverride", data.canOverride)
	local flag = false
	local text = ""
	clone.holder.buttonHolder.submit.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		clone.holder.input.box.TextEditable = false
		text = clone.holder.input.box.Text
	end)
	clone.Parent = screenGUI
	clone:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1)

	repeat
		task.wait(0.1)
	until flag

	clone:TweenPosition(UDim2.new(0.5, 0, -1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1)

	if callback then
		task.delay(1, function()
			clone:Destroy()
			callback(text)
		end)
	else
		task.delay(1, function()
			clone:Destroy()
		end)
	end
end

return RobloxPrompt