local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local emoting = ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs"):WaitForChild("Emoting")
local _ = Players.LocalPlayer
ReplicatedStorage.events.UICompatibility.OnClientEvent:Connect(function(p)
	if p == "emoteCancelShow" then
		script.Parent.Visible = true
		emoting.Enabled = true
	elseif p == "emoteCancelHide" then
		script.Parent.Visible = false
		emoting.Enabled = false
	end
end)
emoting.StopEmoting.Pressed:Connect(function()
	ReplicatedStorage.events.CancelEmote:FireServer()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Gamepad then
		script.Parent.Text = "[Button B] To Cancel Emote"
	elseif preferredInput == Enum.PreferredInput.Touch then
		script.Parent.Text = "[Tap] Here To Cancel Emote"
	else
		script.Parent.Text = "[Click] To Cancel Emote"
	end
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)
update() -- equivalent call inferred; original call site unknown