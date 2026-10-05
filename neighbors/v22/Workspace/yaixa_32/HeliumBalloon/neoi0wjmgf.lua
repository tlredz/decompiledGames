local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local voiceGUI = Players.LocalPlayer.PlayerGui.VoiceGUI
local color = Color3.fromRGB(255, 78, 62)
local color2 = Color3.fromRGB(85, 255, 127)
parent.Equipped:Connect(function()
	voiceGUI.Enabled = true
end)
parent.Unequipped:Connect(function()
	voiceGUI.Enabled = false
end)
local v = false
local audioFader = Instance.new("AudioFader", parent.Handle)
audioFader.Name = "SelfListen"
audioFader.Volume = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateWire(sourceInstance, targetInstance)
	local wire = Instance.new("Wire", sourceInstance)
	wire.SourceInstance = sourceInstance
	wire.TargetInstance = targetInstance
end

CreateWire(parent.Handle.AudioPitchShifter, audioFader) -- equivalent call inferred; original call site unknown
CreateWire(audioFader, workspace.Camera:WaitForChild("AudioDeviceOutput")) -- equivalent call inferred; original call site unknown
voiceGUI.Button.Title.Text = `Hear Yourself: {v and "ON" or "OFF"}`
voiceGUI.Button.Button.MouseButton1Click:Connect(function()
	v = not v
	audioFader.Volume = v and 1 or 0
	TweenService:Create(voiceGUI.Button.Button, TweenInfo.new(0.5), {
		BackgroundColor3 = v and color2 or color
	}):Play()
	voiceGUI.Button.Title.Text = `Hear Yourself: {v and "ON" or "OFF"}`
end)
Players.LocalPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if Players.LocalPlayer:GetAttribute("State") == "Dead" then
		v = false
		voiceGUI.Enabled = false
		audioFader.Volume = v and 1 or 0
		TweenService:Create(voiceGUI.Button.Button, TweenInfo.new(0.5), {
			BackgroundColor3 = v and color2 or color
		}):Play()
		voiceGUI.Button.Title.Text = `Hear Yourself: {v and "ON" or "OFF"}`
	end
end)