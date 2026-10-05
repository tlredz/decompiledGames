task.wait()
local parent = script.Parent
game.Players.LocalPlayer.PlayerGui:WaitForChild("ShiftLock"):WaitForChild("SkipButton").MouseButton1Down:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://6895079853",
		Parent = workspace,
		Volume = 0.5
	}):Play()

	if game.Players.LocalPlayer.Character:GetAttribute("DiedEmote") then
		game.Players.LocalPlayer.Character:FindFirstChild("Communicate"):FireServer({
			Goal = "SkipEmote"
		})
	end
end)
local textLabel = parent:FindFirstChild("TextLabel") or parent:WaitForChild("TextLabel", 1)
parent:GetPropertyChangedSignal("Text"):Connect(function()
	textLabel.Text = parent.Text
end)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:wait()

local function fn()
	local ultimateName = character:GetAttribute("UltimateName")
	parent.Text = character:GetAttribute("IceBoss") and "SUB-ZERO SLASH STORM" or ultimateName

	if parent.Text == "SORCERER" then
		script.Parent.Parent.Visible = false
	end
end

character:GetAttributeChangedSignal("UltimateName"):Connect(fn)
character:GetAttributeChangedSignal("IceBoss"):Connect(fn)

if character:GetAttribute("UltimateName") then
	local ultimateName = character:GetAttribute("UltimateName")
	parent.Text = character:GetAttribute("IceBoss") and "SUB-ZERO SLASH STORM" or ultimateName

	if parent.Text == "SORCERER" then
		script.Parent.Parent.Visible = false
	end
else
	parent.Text = "SELECT CHARACTER"
end