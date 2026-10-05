local game2 = script.Parent:WaitForChild("Game")
local localPlayer = game.Players.LocalPlayer
local v = game.PlaceId == 5895823254 or game.PlaceId == 5928494131
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
ReplicatedStorage3:WaitForChild("Remotes")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("WindowService"))
local device = game.Players.LocalPlayer.PlayerGui:GetAttribute("Device")

if device ~= "Tablet" then
end

local tabletLevel = device == "Tablet" and game2:WaitForChild("TabletLevel") or game2:WaitForChild("Level")
local LevelModule = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("LevelModule"))
local FadeModule = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FadeModule"))
local earnedXP = game2:WaitForChild("EarnedXP")
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = true
local text = 900

function comma_value(value)
	repeat
		local v9
		value, v9 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v9
	until k == 0

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTimeText(p: number)
	local v9 = math.floor(p / 60)
	local v10 = p - v9 * 60
	return (v9 > 0 and v9 .. "m " or "") .. v10 .. "s"
end

function UpdateLevel()
	local newXP = ProfileData.NewXP
	local XP = tabletLevel:WaitForChild("XPBar").XP
	tabletLevel.LevelText.Text = LevelModule.GetLevel(newXP)
	local progressToNextLevel = LevelModule.GetProgressToNextLevel(newXP)
	XP.Size = UDim2.new(progressToNextLevel, XP.Size.X.Offset, XP.Size.Y.Scale, XP.Size.Y.Offset)

	if LevelModule.GetLevel(newXP) >= 100 then
		tabletLevel.Prestige.Visible = true
	else
		tabletLevel.Prestige.Visible = false
	end
end

game2:WaitForChild("Dock"):WaitForChild("Shop").Activated:Connect(function()
	WindowService:ToggleFrame("Shop")
end)

local function onPrestigeButtonClicked()
	local newXP = ProfileData.NewXP

	if LevelModule.GetLevel(newXP) < 100 then
		return
	end

	game2.Prestige.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPrestigeCancelled()
	game2.Prestige.Visible = false
end

local function onPrestigeAccepted()
	game.ReplicatedStorage.Remotes.Inventory.Prestige:FireServer()
	onPrestigeCancelled() -- equivalent call inferred; original call site unknown
	UpdateLevel()
	local prestige = localPlayer:GetAttribute("Prestige") or 0
	localPlayer:SetAttribute("Prestige", prestige + 1)
end

local function onBackpackChildAdded(instance)
	if not instance:FindFirstChild("IsGun") then
		return
	end

	local latestPlayerData = CurrentRoundClient.GetLatestPlayerData()

	if latestPlayerData[localPlayer.Name] ~= nil and latestPlayerData[localPlayer.Name].Role == "Hero" then
		v3 = "Hero"
		earnedXP.Visible = false
		game2.Timer.Visible = true
	end
end

local function onDataUpdated()
	UpdateCash()
	UpdateLevel()
end

local function onRoundStart(p: number, p2)
	if v then
		return
	end

	text = p * 5

	if p2[localPlayer.Name] ~= nil and p2[localPlayer.Name].Dead == false then
		v4 = time()
		v6 = p

		if p2[localPlayer.Name].Role == "Innocent" then
			v5 = 0
			v3 = "Innocent"
			v2 = true
			earnedXP.XPText.Text = 0
			earnedXP.Visible = true
		else
			v2 = true

			if not v then
				game2.Timer.Visible = true
				game2.RoleSelector.Visible = false
			end
		end
	end
end

local function onVictoryScreenShown()
	v3 = nil
	v4 = nil
end

local function onDockToggled()
	v7 = not v7
	game2.Dock.Touch.Title.Text = v7 and "<" or ">"
	game2.Dock:TweenPosition(UDim2.new(0, v7 and 0 or -135, 0.5, -150), "Out", "Quad", 0.2, true)
end

local function onDied()
	FadeModule.DeathFlash()
	earnedXP.XPText.TextColor3 = BrickColor.new("Medium stone grey").Color
	earnedXP.VictoryLabel.TextColor3 = BrickColor.new("Medium stone grey").Color
	v2 = false
end

local function onUpdate(_: number)
	if v4 == nil then
		game2.Timer.Visible = false
		return
	end

	if v then
		return
	end

	local v9 = math.floor(time() - v4)
	local v10 = v6 - v9

	if v3 == "Innocent" then
		local text2 = v9 * 5

		if not (text <= text2) then
			earnedXP.XPText.Text = text2
			return
		end

		earnedXP.XPText.Text = text
		earnedXP.VictoryLabel.Text = "Game Over!"
		earnedXP.XPText.TextColor3 = Color3.new(0, 1, 0)
	elseif v10 > 0 then
		local xPText = game2.Timer.XPText
		xPText.Text = GetTimeText(v10)

		if v10 <= 30 then
			game2.Timer.XPText.TextColor3 = Color3.new(255, 0, 0)
		end
	else
		game2.Timer.XPText.Text = "Game Over!"
		game2.Timer.XPText.TextColor3 = Color3.new(1, 1, 1)
	end
end

local function Initialize()
	_G.LockTarget = nil
	localPlayer.CameraMode = Enum.CameraMode.Classic
	UpdateLevel()
	game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("VictoryScreen").OnClientEvent:Connect(onVictoryScreenShown)
	game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("RoundStart").OnClientEvent:Connect(onRoundStart)
	game.ReplicatedStorage:WaitForChild("UpdateData2").OnClientEvent:Connect(onDataUpdated)
	localPlayer:WaitForChild("Backpack").ChildAdded:Connect(onBackpackChildAdded)
	local RunService = game:GetService("RunService")
	RunService.PreSimulation:Connect(onUpdate)
	game2.Leaderboard.Inspect.Container.Prestige.Activated:Connect(onPrestigeButtonClicked)
	game2.Prestige.Accept.Activated:Connect(onPrestigeAccepted)
	game2.Prestige.Decline.Activated:Connect(onPrestigeCancelled)
	local touch = game2.Dock.Touch
	local UserInputService = game:GetService("UserInputService")
	touch.Visible = UserInputService.TouchEnabled
	game2.Dock.Touch.Button.Activated:Connect(onDockToggled)

	repeat
		task.wait()
	until localPlayer.Character ~= nil

	task.wait()
	localPlayer.CameraMode = "Classic"
	localPlayer.CameraMinZoomDistance = 7
	task.wait(0.5)
	localPlayer.CameraMinZoomDistance = 0.5
	game.StarterGui:SetCoreGuiEnabled("Health", false)
	game.StarterGui:SetCoreGuiEnabled("PlayerList", false)
	local humanoid

	repeat
		task.wait()
		humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	until humanoid ~= nil

	humanoid.Died:Connect(onDied)
	local placeVersion = game.PlaceVersion
	game2.Dock.Version.Text = placeVersion
end

Initialize()