local _ = game.Players.LocalPlayer
local parent = script.Parent.Parent
local parent2 = parent.Parent
local lobby = parent.Lobby
local dock = lobby.Dock
local game2 = parent.Game
local screens = lobby.Screens
local leaderBar = lobby.LeaderBar
local gameBar = lobby.GameBar
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local require3_2 = require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
require3_2.AnimationTargetLocation = dock:WaitForChild("Inventory")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local v = "Lobby"
game.ReplicatedStorage.Remotes.Gameplay.Fade.OnClientEvent:connect(function()
	v = "Game"
end)

function _G.ReturnGUI()
	if v == "Lobby" then
		for _, frame in pairs(screens:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == "Waiting"
			end
		end

		for _, frame in pairs(parent:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == "Lobby"
			end
		end

		dock.BG.Visible = false
		GuiService.TouchControlsEnabled = true
		leaderBar.Visible = true
	elseif v == "Game" then
		for _, frame in pairs(parent:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == "Game" or frame.Name == "Lobby"
			end
		end

		GuiService.TouchControlsEnabled = true
		parent2:SetTopbarTransparency(0.5)
		gameBar.Visible = true
	end
end

local v2 = true
local flag = false

function _G.SetDock(p)
	if flag then
		return
	end

	local v3

	if p == nil or not p then
		v3 = not v2
	else
		v3 = p
	end

	v2 = v3
	local v4 = p == nil and 0.2 or 0
	local v5 = p == nil and 0.2 or 0
	local tweenInfo = TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(dock, tweenInfo, {
		Position = UDim2.new(0, v2 and 0 or -100, 0, 0)
	}):Play()
	TweenService:Create(screens, tweenInfo, {
		Position = UDim2.new(0, v2 and 100 or 0, 0, 0),
		Size = UDim2.new(1, v2 and -100 or 0, 1, 0)
	}):Play()

	if v2 then
		WindowService:CloseAllFrames()
	end

	screens.Waiting.Hide.TextLabel.Text = v2 and "<" or ">"
	screens.Waiting.Hide.BackgroundTransparency = v2 and "0.3" or "0.75"
	wait(v4)
	flag = false
end

screens.Waiting.Hide.MouseButton1Click:connect(_G.SetDock)

function _G.ViewLobbyFrame(p)
	if p == "Spectate" then
		GuiService.TouchControlsEnabled = not GuiService.TouchControlsEnabled
	elseif p == "Shop" then
		WindowService:ToggleFrame("Shop")
		_G.CancelSpectate()
	else
		screens[p].Visible = not screens[p].Visible
		_G.CancelSpectate()
		WindowService:CloseAllFrames()
	end

	if p == "Christmas2018" then
		if game2.Emotes.Visible == false then
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end

		game2.Visible = false
		_G.SetDock(true)
	end

	for _, frame in pairs(screens:GetChildren()) do
		if frame:IsA("Frame") and frame.Name ~= p then
			frame.Visible = false
		end
	end

	local visible = screens[p].Visible

	if p == "Shop" then
		visible = WindowService:GetFrame("Shop").Visible
	end

	if visible then
		dock.BG.Visible = true
		return
	end

	(v == "Game" and gameBar or leaderBar).Visible = true
	screens.Waiting.Visible = true
	dock.BG.Visible = false
	GuiService.TouchControlsEnabled = true

	if game2.Emotes.Visible == false then
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	end

	game2.Visible = true
end

for _, button in pairs(dock:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local v3 = button
	button.MouseButton1Click:connect(function()
		if v2 and not flag then
			if game2.Emotes.Visible == false then
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end

			game2.Visible = false
			_G.ViewLobbyFrame(v3.Name)
		end
	end)
end

function _G.ResetMobileDock()
	_G.ReturnGUI()
	_G.ViewLobbyFrame("Waiting")
	_G.SetDock(false)
end

GuiService.TouchControlsEnabled = true
game.StarterGui:SetCore("ChatActive", false)
game.StarterGui:SetCore("ChatWindowPosition", UDim2.new(0, 100, 0, 100))