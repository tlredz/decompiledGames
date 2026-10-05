local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local parent = script.Parent
local getMessageToPlayer = ReplicatedStorage:WaitForChild("GetMessageToPlayer")
local pushMessageToPlayer = ReplicatedStorage:WaitForChild("PushMessageToPlayer")
local clearMessageToPlayer = ReplicatedStorage:WaitForChild("ClearMessageToPlayer")
local replyMessageToAdmin = ReplicatedStorage:WaitForChild("ReplyMessageToAdmin")
local mainFrame = parent:WaitForChild("MainFrame")
local textLabel = mainFrame:WaitForChild("Frame"):WaitForChild("ListFrame"):WaitForChild("TextFrame"):WaitForChild("TextLabel")
textLabel.RichText = true
local frame = mainFrame:WaitForChild("FrameRepondre"):WaitForChild("Frame"):WaitForChild("Frame")
local textBox = frame:WaitForChild("TextBox")
local sendButton = frame:WaitForChild("SendButton")
parent.Enabled = false
mainFrame.Visible = false

local function showMessage(text)
	if typeof(text) ~= "string" or text == "" then
		return
	end

	textLabel.Text = text
	textBox.Text = ""
	parent.Enabled = true
	mainFrame.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeAndClear()
	clearMessageToPlayer:FireServer()
	parent.Enabled = false
end

local flag = false
sendButton.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	local text = textBox.Text

	if text:gsub(" ", "") == "" then
		textBox.PlaceholderText = "Écrivez un message..."
		return
	end

	flag = true
	sendButton.Text = "Envoi..."
	replyMessageToAdmin:FireServer(text)
	task.wait(0.5)
	closeAndClear() -- equivalent call inferred; original call site unknown
	sendButton.Text = "Send"
	textBox.Text = ""
	flag = false
end)
task.wait(5)
local success, result = pcall(function()
	return getMessageToPlayer:InvokeServer()
end)

if success and type(result) == "string" and result ~= "" and typeof(result) == "string" and result ~= "" then
	textLabel.Text = result
	textBox.Text = ""
	parent.Enabled = true
	mainFrame.Visible = true
end

pushMessageToPlayer.OnClientEvent:Connect(function(text)
	if typeof(text) == "string" then
		if text == "" then
			return
		end

		textLabel.Text = text
		textBox.Text = ""
		parent.Enabled = true
		mainFrame.Visible = true
	end
end)