local localPlayer = game.Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local Trove = require(game.ReplicatedStorage.Modules.Trove)
local TweenService = game:GetService("TweenService")
Trove.new()
local parent = script.Parent
local hint = parent.Button.Hint
local title = parent.Button.Title
local button = parent.Button.Button
local color = Color3.fromRGB(255, 78, 62)
local color2 = Color3.fromRGB(85, 255, 127)
local inputFader = localPlayer:WaitForChild("InputFader", 1e999)
inputFader.Volume = 0
local flag = false

local function DisableHearSelf()
	flag = false
	inputFader.Volume = 0
	TweenService:Create(button, TweenInfo.new(0.5), {
		BackgroundColor3 = color
	}):Play()
	title.Text = "Hear Yourself: OFF"
	hint.Text = "(CLICK SCREEN TO ACTIVATE)"
end

button.MouseButton1Click:Connect(function()
	if flag then
		return DisableHearSelf()
	end

	flag = true
	inputFader.Volume = 1
	TweenService:Create(button, TweenInfo.new(0.5), {
		BackgroundColor3 = color2
	}):Play()
	title.Text = "Hear Yourself: ON"
	hint.Text = "(CLICK SCREEN TO TURN OFF)"
end)
localPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if localPlayer:GetAttribute("State") == "Dead" then
		DisableHearSelf()
	end
end)
Network:listen("DisableHearSelf", DisableHearSelf)
Network:listen("SetVoiceGuiVisible", function(enabled: boolean)
	parent.Enabled = enabled
end)