local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local mainFrame = script.Parent:WaitForChild("MainFrame")
local scrollingFrame = mainFrame.Parent:WaitForChild("ScrollingFrame")
local commandBox = mainFrame:WaitForChild("CommandBox")
local textButton = mainFrame.Parent:WaitForChild("TextButton")
local localPlayer = game.Players.LocalPlayer
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
local CommandList = require(script.Parent:WaitForChild("CommandList"))
local CommandLevel = require(ReplicatedStorage.Chest.Modules.CommandLevel)

function UpdateCommandList(value)
	for _, button in pairs(scrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	if value then
		for k, text in pairs(CommandList) do
			local v2 = string.lower(value)
			local v3 = string.lower(k)

			if string.sub(v2, 1, #v2) ~= string.sub(v3, 1, #v2) then
				continue
			end

			local clone = script.CommandLabel:Clone()
			clone.Name = k
			clone.Text = text
			clone.Parent = scrollingFrame
			local text2 = k
			clone.MouseButton1Click:Connect(function()
				commandBox.Text = text2
			end)
		end
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

function ConvertTextToCommand()
	local parts = commandBox.Text:split(" ")
	local part = parts[1]
	local part2 = parts[2]
	local v = nil

	if #parts >= 3 then
		for i = 3, #parts do
			if not parts[i] then
				continue
			end

			if v then
				v ..= " " .. parts[i]
			else
				v = parts[i]
			end
		end
	end

	return part, part2, v
end

commandBox.FocusLost:Connect(function()
	local v, v2, v3 = ConvertTextToCommand()
	local v4, text = game.ReplicatedStorage.Chest.Remotes.Functions.UseCommand:InvokeServer(v, v2, v3)

	if v4 ~= nil then
		if v4 then
			commandBox.Text = text
			commandBox.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			commandBox.Text = text
			commandBox.TextColor3 = Color3.fromRGB(255, 0, 0)
		end

		wait(0.6)
		commandBox.Text = ""
		commandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)
commandBox:GetPropertyChangedSignal("Text"):Connect(function()
	local v, _, _ = ConvertTextToCommand()
	UpdateCommandList(v)
end)
UpdateCommandList("")

function Visible(visible)
	mainFrame.Visible = visible
	scrollingFrame.Visible = visible
	textButton.Visible = visible
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightAlt then
		if not CommandLevel[localPlayer.UserId] then
			return
		end

		Visible(not mainFrame.Visible)
	end
end)
local TextChatService = game:GetService("TextChatService")
TextChatService:WaitForChild("Cmds").Triggered:Connect(function()
	if not CommandLevel[localPlayer.UserId] then
		return
	end

	Visible(not mainFrame.Visible)
end)
textButton.MouseButton1Click:Connect(function()
	Visible(false)
end)