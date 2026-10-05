local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local PartyEvent = require(adminAbuse:WaitForChild("PartyEvent"))
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local TeamScoreboardUI = require(adminAbuse:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("TeamScoreboardUI"))
local TeamBattleCountdownUI = require(script:WaitForChild("TeamBattleCountdownUI"))
local TeamBattleConfig = require(script:WaitForChild("TeamBattleConfig"))
local color = Color3.fromRGB(120, 200, 255)
local uDim = UDim2.fromScale(0, 0.18)
local v = TeamBattleConfig.CountdownSeconds + TeamBattleConfig.CombatSeconds + TeamBattleConfig.ResultsSeconds
local v2 = PartyEvent.new({
	DisplayName = "Team Battle",
	NeedsDuration = true,
	MaxDurationSeconds = v,
	DefaultDurationSeconds = v,
	RequiresRespawnRefire = false,
	SkipDoorTransition = true,
	IsAdminAbuse = false,
	Sounds = TeamBattleConfig.Sounds
})

-- equivalent calls inferred from this helper; original call sites unknown
local function fmtClock(p: number)
	local v3 = math.max(0, (math.floor(p)))
	return string.format("%d:%02d", math.floor(v3 / 60), v3 % 60)
end

local function serverNow()
	return workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNotifier()
	return require(ReplicatedStorage:WaitForChild("NotificationSystem"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playCountdownSound(soundId: string, volume: number)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.RollOffMaxDistance = 0
	sound:SetAttribute("IsEventSound", true)
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 8)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function countdownDisplaySec(p: number)
	if p <= 0 then
		return 0
	end

	return (math.ceil(p))
end

function v2:_playCountdownAudio(p: number)
	if p >= 4 then
		playCountdownSound(TeamBattleConfig.CountdownTickSound, 0.8) -- equivalent call inferred; original call site unknown
	elseif p == 3 then
		playCountdownSound(TeamBattleConfig.CountdownFinalSound, 3.5) -- equivalent call inferred; original call site unknown
	end
end

function v2:_revealScoreboard()
	if self._boardRevealed or not self._board then
		return
	end

	self._boardRevealed = true
	self._board:DropIn()
	self:_applyNotificationLayout()
end

function v2:_onCountdownFinished()
	if self._goShown then
		return
	end

	self._goShown = true

	if self._countdownUI then
		self._countdownUI:ShowGo(TeamBattleConfig.GoMessage)
	end

	task.delay(TeamBattleConfig.GoHoldSeconds, function()
		if self._activeSession ~= self._countdownSession then
			return
		end

		if self._countdownUI then
			self._countdownUI:Hide()
		end

		self:_revealScoreboard()
	end)
end

function v2:_updateCountdown()
	if self._phase ~= "countdown" or not self._countdownEndsAt then
		return
	end

	local lastCountdownDisplay = countdownDisplaySec(self._countdownEndsAt - workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown

	if lastCountdownDisplay > 0 then
		if self._countdownUI then
			self._countdownUI:SetSeconds(lastCountdownDisplay)
		end

		if self._lastCountdownDisplay == nil or lastCountdownDisplay < self._lastCountdownDisplay then
			self:_playCountdownAudio(lastCountdownDisplay)
			self._lastCountdownDisplay = lastCountdownDisplay
		end
	elseif not self._goShown then
		self:_onCountdownFinished()
	end
end

function v2:_onPhaseChanged(p)
	if p == "running" then
		if not self._goShown then
			if self._countdownUI then
				self._countdownUI:Hide()
			end

			self:_revealScoreboard()
		end
	elseif p == "ended" then
		if self._countdownUI then
			self._countdownUI:Hide()
		end

		if not self._boardRevealed then
			self:_revealScoreboard()
		end
	end
end

local function playWinPayoutFx(color2: Color3?, multiplier: number?)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v3 = color2 or Color3.fromRGB(255, 215, 0)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Brightness = 0.18
	colorCorrectionEffect.Contrast = 0.08
	colorCorrectionEffect.Saturation = 0.25
	colorCorrectionEffect.TintColor = v3
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0,
		Saturation = 0
	}):Play()
	Debris:AddItem(colorCorrectionEffect, 0.7)

	if humanoidRootPart then
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(2, 2, 2)
		part.CFrame = humanoidRootPart.CFrame
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Material = Enum.Material.Neon
		part.Color = v3
		part.Transparency = 0.2
		part.Parent = workspace
		TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(16, 16, 16),
			Transparency = 1
		}):Play()
		Debris:AddItem(part, 0.55)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 140, 0, 52)
		billboardGui.StudsOffset = createVector(0, 3.5, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = humanoidRootPart
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.TextScaled = true
		textLabel.TextColor3 = v3
		textLabel.Text = string.format("x%d WINS!", multiplier or TeamBattleConfig.WinPayoutMultiplier)
		local uIStroke = Instance.new("UIStroke", textLabel)
		uIStroke.Thickness = 2.5
		uIStroke.Color = Color3.fromRGB(255, 255, 255)
		textLabel.Parent = billboardGui
		TweenService:Create(textLabel, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		Debris:AddItem(billboardGui, 0.95)
	end
end

function v2:_myTeamId()
	local localPlayer = Players.LocalPlayer
	local team = localPlayer and localPlayer.Team
	return team and team:GetAttribute("TeamId")
end

function v2:_winnerText()
	local _winnerTeamIds = self._winnerTeamIds

	if type(_winnerTeamIds) ~= "table" or #_winnerTeamIds == 0 or type(self._teams) ~= "table" then
		return "Results"
	end

	if #_winnerTeamIds >= #self._teams then
		return "It's a tie!"
	end

	for _, _team in ipairs(self._teams) do
		if _team.id == _winnerTeamIds[1] then
			return (_team.displayName or "Team") .. " wins!"
		end
	end

	return "Results"
end

function v2:_render()
	if self._board and type(self._teams) == "table" then
		self._board:Update(self._teams, self:_myTeamId())
	end
end

function v2:_updateTimer()
	if not self._board then
		return
	end

	if self._phase == "countdown" then
		self:_updateCountdown()
	elseif self._phase == "running" and self._combatEndsAt then
		self._board:SetPhaseText("Time left  " .. fmtClock(self._combatEndsAt - workspace:GetServerTimeNow()))
	elseif self._phase == "ended" then
		self._board:SetPhaseText(self:_winnerText())
	end
end

function v2:_maybeAnnounceTeam()
	local _myTeamId = self:_myTeamId()

	if _myTeamId and self._announcedTeam ~= _myTeamId and type(self._teams) == "table" then
		for _, _team in ipairs(self._teams) do
			if _team.id ~= _myTeamId then
				continue
			end

			self._announcedTeam = _myTeamId
			local notifier = getNotifier() -- equivalent call inferred; original call site unknown
			notifier:ShowGeneralNotification(
				"You are on " .. (_team.displayName or "a team") .. "!",
				_team.color or color
			)
			return
		end
	end
end

function v2:_applyNotificationLayout()
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	local generalNotificationGui = playerGui and playerGui:FindFirstChild("GeneralNotificationGui")

	if generalNotificationGui then
		if not self._notifGui then
			self._notifGuiOrder = generalNotificationGui.DisplayOrder
		end

		self._notifGui = generalNotificationGui
		generalNotificationGui.DisplayOrder = 50
	end

	local mainFrame = generalNotificationGui and generalNotificationGui:FindFirstChild("MainFrame")

	if mainFrame then
		if not self._notifMainFramePos then
			self._notifMainFramePos = mainFrame.Position
		end

		self._notifMainFrame = mainFrame
		local _notifMainFramePos = self._notifMainFramePos
		mainFrame.Position = UDim2.new(
			_notifMainFramePos.X.Scale,
			_notifMainFramePos.X.Offset,
			_notifMainFramePos.Y.Scale + uDim.Y.Scale,
			_notifMainFramePos.Y.Offset + uDim.Y.Offset
		)
	end
end

function v2:_restoreNotificationLayout()
	if self._notifMainFrame and self._notifMainFramePos then
		self._notifMainFrame.Position = self._notifMainFramePos
	end

	if self._notifGui and self._notifGuiOrder ~= nil then
		self._notifGui.DisplayOrder = self._notifGuiOrder
	end

	self._notifGui = nil
	self._notifGuiOrder = nil
	self._notifMainFrame = nil
	self._notifMainFramePos = nil
end

function v2:OnStart(countdownSession, _, _, _)
	self._announcedTeam = nil
	self._goShown = false
	self._boardRevealed = false
	self._lastCountdownDisplay = nil
	self._countdownSession = countdownSession
	self._countdownUI = TeamBattleCountdownUI.new({
		displayOrder = 11
	})
	self._board = TeamScoreboardUI.new({
		title = "TEAM BATTLE",
		displayOrder = 10
	})
	self._board:HideAbove()
	local v3 = SharedSyncedEvent.new(TeamBattleConfig.SyncChannelName)
	v3:onChange("Teams", function(teams)
		self._teams = teams
		self:_render()
		self:_maybeAnnounceTeam()
	end)
	v3:onChange("Phase", function(phase)
		self._phase = phase
		self:_onPhaseChanged(phase)
	end)
	v3:onChange("CountdownEndsAt", function(countdownEndsAt)
		self._countdownEndsAt = countdownEndsAt
	end)
	v3:onChange("CombatEndsAt", function(combatEndsAt)
		self._combatEndsAt = combatEndsAt
	end)
	v3:onChange("WinnerTeamIds", function(winnerTeamIds)
		self._winnerTeamIds = winnerTeamIds
	end)
	v3:onFire("Notify", function(p)
		if type(p) == "table" and type(p.text) == "string" then
			local notifier = getNotifier() -- equivalent call inferred; original call site unknown
			notifier:ShowGeneralNotification(p.text, p.color or color)
		end
	end)
	v3:onFire("WinPayout", function(data)
		if type(data) ~= "table" or data.userId ~= Players.LocalPlayer.UserId then
			return
		end

		if (tonumber(data.amount) or 0) > 0 then
			playWinPayoutFx(data.color, tonumber(data.multiplier))
		end
	end)
	local localPlayer = Players.LocalPlayer
	countdownSession.janitor:Add(self._countdownUI, "Destroy")
	countdownSession.janitor:Add(self._board, "Destroy")
	countdownSession.janitor:Add(v3, "destroy")
	countdownSession.janitor:Add(localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		self:_render()
		self:_maybeAnnounceTeam()
	end))
	countdownSession.janitor:Add(function()
		self:_restoreNotificationLayout()
	end)
	self:_applyNotificationLayout()
	task.defer(function()
		if self._activeSession == countdownSession then
			self:_applyNotificationLayout()
		end
	end)
	self:_render()
	self:_maybeAnnounceTeam()
	self:_updateCountdown()
end

function v2:OnRender(_, _, _, _, _)
	self:_updateTimer()
end

function v2:OnStop(_)
	self._countdownUI = nil
	self._board = nil
	self._teams = nil
	self._phase = nil
	self._countdownEndsAt = nil
	self._combatEndsAt = nil
	self._winnerTeamIds = nil
	self._announcedTeam = nil
	self._goShown = nil
	self._boardRevealed = nil
	self._lastCountdownDisplay = nil
	self._countdownSession = nil
end

function v2:Fire(...)
	PartyEvent.Fire(self, ...)
	local _activeSession = self._activeSession

	if not _activeSession then
		return
	end

	if _activeSession.connection then
		_activeSession.connection:Disconnect()
	end

	_activeSession.connection = RunService.RenderStepped:Connect(function()
		if self._activeSession == _activeSession then
			local localPlayer = Players.LocalPlayer

			if not localPlayer then
				return
			end

			if self.OnRender then
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local currentCamera = workspace.CurrentCamera
				self:OnRender(_activeSession, os.clock(), character, humanoidRootPart, currentCamera)
			end
		elseif _activeSession.connection then
			_activeSession.connection:Disconnect()
		end
	end)
end

return v2