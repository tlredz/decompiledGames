local HudNavigation = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("HudNavigation"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local playerPreferences = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game"):WaitForChild("PlayerPreferences")
local lobbyControls = script.Parent:WaitForChild("MainFrame"):WaitForChild("LobbyControls")
local AFKF = lobbyControls:WaitForChild("AFKF")
local aFKButton = AFKF:WaitForChild("AFKButton")
local muteIB = lobbyControls:WaitForChild("MusicControls"):WaitForChild("MuteF"):WaitForChild("MuteIB")
local feedback = lobbyControls:WaitForChild("Feedback")
local keyboardHint = lobbyControls:WaitForChild("KeyboardHint")
local connections = {}
local v = 0
local v2 = 0

local function canAFK()
	return localPlayer:GetAttribute("TutorialRouting") ~= true and localPlayer:GetAttribute("TutorialSession") ~= true and localPlayer:GetAttribute("InMatch") ~= true and (localPlayer:GetAttribute("GameRole") or "Lobby") == "Lobby"
end

local function update()
	local AFK = localPlayer:GetAttribute("AFK") == true
	local musicMuted = localPlayer:GetAttribute("MusicMuted") == true
	lobbyControls.Visible = false
	HudNavigation.setAvailable("AFK", (canAFK()))
	AFKF.Visible = canAFK()
	aFKButton.Active = canAFK()
	aFKButton.Selectable = canAFK()
	aFKButton.Text = AFK and "AFK: ON" or "AFK: OFF"
	aFKButton.TextColor3 = AFK and Color3.fromRGB(139, 227, 187) or Color3.fromRGB(255, 249, 221)
	muteIB.Image = muteIB[musicMuted and "Sound Off" or "Sound On"].Texture
	muteIB:SetAttribute("MusicMuted", musicMuted)
	keyboardHint.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	keyboardHint.Text = canAFK() and "Alt: cursor   K: AFK   M: music" or "Alt: cursor   M: music"

	if not canAFK() and GuiService.SelectedObject == aFKButton then
		GuiService.SelectedObject = muteIB
	end
end

local function say(text)
	HudNavigation.Notice:Fire(text)
	v2 = os.clock() + 2.5
	feedback.Text = text
	feedback.Visible = true
	local v3 = v2
	task.delay(2.5, function()
		if v2 == v3 then
			feedback.Visible = false
		end
	end)
end

local function toggleAFK()
	if not canAFK() or os.clock() < v then
		return
	end

	v = os.clock() + 0.5
	playerPreferences:FireServer("SetAFK", localPlayer:GetAttribute("AFK") ~= true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleMusic()
	localPlayer:SetAttribute("MusicMuted", localPlayer:GetAttribute("MusicMuted") ~= true)
end

HudNavigation.register("AFK", toggleAFK)
table.insert(connections, aFKButton.Activated:Connect(toggleAFK))
table.insert(connections, muteIB.Activated:Connect(toggleMusic))
table.insert(connections, playerPreferences.OnClientEvent:Connect(function(p, p2, p3, value)
	if p == "AFKResult" then
		update()
		local v4

		if p2 then
			v4 = p3 and "Sitting this match out." or "Ready for the next match."
		else
			v4 = value or "Try again in the lobby."
		end

		say(v4)
	end
end))

for _, v3 in {
	"AFK",
	"InMatch",
	"GameRole",
	"MusicMuted",
	"TutorialRouting",
	"TutorialSession"
} do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v3):Connect(update))
end

table.insert(connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update))
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen then
		return
	end

	if input.KeyCode == Enum.KeyCode.K then
		toggleAFK()
	elseif input.KeyCode == Enum.KeyCode.M then
		toggleMusic() -- equivalent call inferred; original call site unknown
	elseif input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
		localPlayer:SetAttribute("ReleaseCursorForControls", true)
	end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
		localPlayer:SetAttribute("ReleaseCursorForControls", nil)
	end
end))
table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
	localPlayer:SetAttribute("ReleaseCursorForControls", nil)
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	localPlayer:SetAttribute("ReleaseCursorForControls", nil)
end)
update()