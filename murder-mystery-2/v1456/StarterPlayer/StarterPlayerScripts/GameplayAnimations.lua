local TweenService = game:GetService("TweenService")
_G.LastRound = -1
_G.PlayerIcons = {}

local function UpdateIcons()
	for _, v in pairs(game.Players:GetPlayers()) do
		if _G.PlayerIcons[v.Name] ~= nil then
			continue
		end

		local v2 = v
		spawn(function()
			_G.PlayerIcons[v2.Name] = game.Players:GetUserThumbnailAsync(
				math.abs(v2.userId),
				Enum.ThumbnailType.AvatarBust,
				Enum.ThumbnailSize.Size352x352
			)
		end)
	end
end

UpdateIcons()
game.Players.PlayerAdded:connect(UpdateIcons)
game.Players.PlayerRemoving:connect(UpdateIcons)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
local FadeModule = require(game.ReplicatedStorage.Modules.FadeModule)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTweens(items)
	for _, item in pairs(items) do
		item:Play()
	end
end

local function PlayVictoryScreen(childName)
	local clone = script.Victory:Clone()
	local v = clone:FindFirstChild(childName .. "Victory") or clone:FindFirstChild(childName) or clone.MurdererVictory
	v.Visible = true
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	task.wait(0.05)
	PlayTweens({ TweenService:Create(v.Container, tweenInfo, {
			Size = UDim2.new(1, 0, 1, 0)
		}), TweenService:Create(v.KnifeRight, tweenInfo, {
			Position = UDim2.new(0.975, 0, 0.5, 0),
			Rotation = 0
		}), TweenService:Create(v.KnifeLeft, tweenInfo, {
			Position = UDim2.new(0.025, 0, 0.5, 0),
			Rotation = 0
		}) }) -- equivalent call inferred; original call site unknown
	task.wait(8)
	PlayTweens({ TweenService:Create(v, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0, -(v.Container.AbsoluteSize.Y * 2) - 10)
		}) }) -- equivalent call inferred; original call site unknown
	task.wait(tweenInfo.Time)
	clone:Destroy()
end

local v = {
	Innocent = {
		Time = true,
		MurdererDied = true,
		MurdererLeft = true,
		InnocentsEscaped = true
	},
	Hero = {
		Time = true,
		MurdererDied = true,
		MurdererLeft = true
	},
	Sheriff = {
		MurdererDied = true,
		MurdererLeft = true,
		SheriffWin = true
	},
	Murderer = {
		MurdererWin = true
	},
	Assassin = {
		PlayerWon = true
	},
	Zombie = {
		ZombiesWin = true
	},
	Survivor = {
		SurvivorsWin = true,
		Time = true
	},
	Freezer = {
		FreezersWin = true
	},
	Runner = {
		RunnersWin = true,
		Time = true
	},
	Team1 = {
		Team1Victory = true
	},
	Team2 = {
		Team2Victory = true
	},
	Vampire = {
		VampireWin = true
	},
	Hunter = {
		Time = true,
		InnocentWin = true
	},
	Villager = {
		Time = true,
		InnocentWin = true
	}
}

local function PlayFade()
	local clone = script.DeathFade:Clone()
	local fade = clone.Fade
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	PlayTweens({ TweenService:Create(fade, tweenInfo2, {
			BackgroundTransparency = 0
		}) }) -- equivalent call inferred; original call site unknown
end

local v2 = game.PlaceId == 5895823254 or game.PlaceId == 5928494131

local function PlayEndMusic(player, p)
	if player ~= nil and player.Character ~= nil and player.Character:FindFirstChild("Radio") and player.Character.Radio:FindFirstChild("Sound") and player.Character.Radio.Sound.IsPlaying == true then
		return
	end

	local v3

	if v2 then
		_G.HalloweenMusic("Murderer", "Stop")
		_G.HalloweenMusic("Escape", "Stop")
		_G.HalloweenMusic("Lobby", "Stop")
		v3 = { "rbxassetid://1836013831", "rbxassetid://1838605064", "rbxassetid://1841274964" }
	else
		v3 = {
			"rbxassetid://13934589675",
			"rbxassetid://139379638020186",
			"rbxassetid://320397765",
			"rbxassetid://320403652"
		}
	end

	local soundId = v3[p]
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.4
	sound.Looped = false
	sound.PlayOnRemove = false
	local SoundService = game:GetService("SoundService")
	sound.SoundGroup = SoundService:FindFirstChild("Music")
	local numberValue = Instance.new("NumberValue", sound)
	numberValue.Value = sound.Volume
	sound.Parent = game.Players.LocalPlayer.PlayerGui
	sound:Play()
	game.Debris:AddItem(sound)
end

game.ReplicatedStorage.Remotes.Gameplay.VictoryScreen.OnClientEvent:connect(function(p, p2, p3, p4, p5)
	local WAIT_INTERVAL = 0.5
	print(p, p2, p3, p4)

	if p4 == "Zombie" or p4 == "Survivor" then
		task.wait(WAIT_INTERVAL)
		PlayEndMusic(game.Players.LocalPlayer, p5)
		PlayVictoryScreen(p4)
	elseif p4 == "Freezer" or p4 == "Runner" then
		task.wait(WAIT_INTERVAL)
		PlayEndMusic(game.Players.LocalPlayer, p5)
		PlayVictoryScreen(p4)
	elseif p4 == "Red Team" or p4 == "Blue Team" then
		PlayEndMusic(game.Players.LocalPlayer, p5)
		PlayVictoryScreen(p4)
	elseif v[p2] then
		if v[p2][p3] and p then
			task.wait(WAIT_INTERVAL)
			PlayEndMusic(game.Players.LocalPlayer, p5)
			PlayVictoryScreen(p2)
		elseif p4 and p == false then
			local v3 = game.Players.LocalPlayer.Character ~= nil
			FadeModule.FadeToWinner(p4, v3)
			PlayEndMusic(p4, p5)
		elseif p then
			task.wait(WAIT_INTERVAL)
			PlayEndMusic(game.Players.LocalPlayer, p5)
			PlayVictoryScreen(v2 and "InnocentsEscaped" or "TimesUp")
		end
	else
		PlayEndMusic(game.Players.LocalPlayer, p5)
		PlayVictoryScreen("TimesUp")
	end
end)
game.ReplicatedStorage.Remotes.Gameplay.RoundEndFade.OnClientEvent:connect(function(p)
	FadeModule.PlayCameraFade("In")

	if not p then
		wait(0.4)
		FadeModule.CameraFadeToLocalPlayer("Out")
		_G.ShowResults()
	end
end)
local ScoreboardModule = require(game.ReplicatedStorage.Modules.ScoreboardModule)

function _G.ShowResults(_)
	local v3 = game.ReplicatedStorage.Remotes.Gameplay.GetLastRoundRewards:InvokeServer()

	if v3 == nil then
		return
	end

	if v3.RoundCount ~= _G.LastRound then
		local _ = game.Players.LocalPlayer.PlayerGui.Scoreboard
		ScoreboardModule.DisplayScoreboard(v3)
	end
end