local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local audio = chickenOrHero:WaitForChild("Audio")
local gameAudio = SoundService:WaitForChild("GameAudio")
local DefaultCharacterAudio = require(audio:WaitForChild("DefaultCharacterAudio"))
local v = DefaultCharacterAudio.start(localPlayer)
local AudioConfig = require(audio:WaitForChild("AudioConfig"))
local AudioCatalog = require(audio:WaitForChild("AudioCatalog"))
local AudioPlayback = require(audio:WaitForChild("AudioPlayback"))
local v2 = AudioPlayback.new(gameAudio, AudioCatalog, AudioConfig)
local DaggerAudio = require(audio:WaitForChild("DaggerAudio"))
local v3 = DaggerAudio.new(v2, AudioConfig)
local MovementAudio = require(audio:WaitForChild("MovementAudio"))
local v4 = MovementAudio.new(v2, AudioConfig)
local InterfaceAudio = require(audio:WaitForChild("InterfaceAudio"))
local v5 = InterfaceAudio.new(v2, localPlayer:WaitForChild("PlayerGui"))
local session = chickenOrHero:WaitForChild("Game"):WaitForChild("Session")
local ThreatAudio = require(audio:WaitForChild("ThreatAudio"))
local v6 = ThreatAudio.new(v2, localPlayer, session, AudioConfig.Danger)
local v7 = {
	RecapOpen = true,
	RecapTick = true,
	RecapComplete = true,
	RecapLevelUp = true
}
local eventConnection = audio:WaitForChild("PresentationCues").Event:Connect(function(p, value, p2)
	if p == "KnifePreview" then
		v3:preview(value, p2)
	elseif p == "ArmoryOpen" or p == "ArmoryClose" then
		v2:one(p == "ArmoryOpen" and "PanelOpen" or "PanelClose")
	elseif p == "ChoiceFocus" and localPlayer:GetAttribute("ChoiceSpotlightActive") == true then
		v2:one("ChoiceFocus")
		task.delay(type(value) ~= "number" and 0.3 or math.clamp(value, 0.1, 0.6) or 0.3, function()
			if v2.alive and localPlayer:GetAttribute("ChoiceSpotlightActive") == true then
				v2:one("ChoiceFocusResolve")
			end
		end)
	elseif p == "GemCollect" then
		v2:one("GemCollect", nil, 1, type(value) ~= "number" and 1 or math.clamp(value, 1, 1.3) or 1)
	elseif p == "RecapStop" then
		for k in v2.voices do
			if v7[k.key] then
				v2:remove(k)
			end
		end
	elseif v7[p] and localPlayer:GetAttribute("MatchSummaryVisible") == true then
		v2:one(p, nil, 1, type(value) ~= "number" and 1 or math.clamp(value, 0.8, 1.4) or 1)
	end
end)
local phase = session:GetAttribute("Phase") or "Lobby"
local gameRole = localPlayer:GetAttribute("GameRole") or "Lobby"
local selectedUserId = session:GetAttribute("SelectedUserId") or 0
local noticeUntil = session:GetAttribute("NoticeUntil") or 0
local v8 = ""
local total = 0
local total2 = 0
local v9 = {
	Caught = true,
	ReachedSafety = true,
	CatchSuccess = true,
	Victory = true,
	Defeat = true,
	SpawnRefresh = true,
	LobbyReturn = true,
	HeroChosen = true,
	ChickenChosen = true,
	RunEnd = true
}
local onClientEventConnection = audio:WaitForChild("Events").OnClientEvent:Connect(function(p, value)
	if p == "DaggerHit" then
		v3:hit(value)
	elseif p == "CatchImpact" and type(value) == "number" then
		local playerByUserId = Players:GetPlayerByUserId(value)
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local currentCamera = workspace.CurrentCamera

		if humanoidRootPart and currentCamera and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= AudioConfig.RemoteActionDistance then
			if playerByUserId == localPlayer or not humanoidRootPart then
				humanoidRootPart = nil
			end

			v2:one("CatchImpact", humanoidRootPart, playerByUserId == localPlayer and 1 or 0.65)
		end
	elseif v9[p] then
		v2:one(p)
	end
end)

local function updateState()
	local phase2 = session:GetAttribute("Phase") or "Lobby"
	local gameRole2 = localPlayer:GetAttribute("GameRole") or "Lobby"
	local v10

	if phase2 == "Countdown" and localPlayer:GetAttribute("AFK") ~= true then
		v10 = localPlayer:GetAttribute("ClientReady") == true
	else
		v10 = false
	end

	if phase2 ~= phase then
		local phaseCue = AudioConfig.PhaseCues[phase2]

		if phaseCue and (gameRole2 ~= "Lobby" or v10) then
			v2:one(phaseCue)
		end

		phase = phase2
		v8 = ""
	end

	if gameRole2 ~= gameRole then
		if gameRole2 == "Runner" then
			v2:one("RoleRunner")
		elseif gameRole2 == "Catcher" then
			v2:one("RoleCatcher")
		end

		gameRole = gameRole2
	end

	local selectedUserId2 = session:GetAttribute("SelectedUserId") or 0

	if selectedUserId2 ~= selectedUserId then
		if selectedUserId2 == localPlayer.UserId then
			v2:one("SelectedHero")
		end

		selectedUserId = selectedUserId2
	end

	local noticeUntil2 = session:GetAttribute("NoticeUntil") or 0

	if noticeUntil2 ~= noticeUntil then
		if workspace:GetServerTimeNow() < noticeUntil2 and session:GetAttribute("NoticeSound") ~= false then
			v2:one("Notice")
		end

		noticeUntil = noticeUntil2
	end

	local endsAt = session:GetAttribute("EndsAt") or 0
	local v11 = math.ceil(endsAt - workspace:GetServerTimeNow())
	local countdownPhas = AudioConfig.CountdownPhases[phase2]

	if countdownPhas then
		if v11 >= 1 then
			countdownPhas = v11 <= 3
		else
			countdownPhas = false
		end
	end

	local crossingPhas = AudioConfig.CrossingPhases[phase2]

	if crossingPhas then
		if v11 >= 1 and v11 <= 5 then
			crossingPhas = localPlayer:GetAttribute("RunState") == "Active"
		else
			crossingPhas = false
		end
	end

	if endsAt > 0 and (countdownPhas or crossingPhas) and (gameRole2 ~= "Lobby" or v10) then
		local v12 = phase2 .. ":" .. tostring(endsAt) .. ":" .. v11

		if v12 ~= v8 then
			v8 = v12
			v2:one(crossingPhas and "TimeWarning" or v11 == 1 and v2:template("CountdownFinal") and "CountdownFinal" or "CountdownTick")
		end
	end
end

local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt
	total2 += dt

	if total >= AudioConfig.UpdateInterval then
		local v10 = math.min(total, 0.1)
		total = 0
		v2:update()
		v4:update(v10)
		v3:update()
		v6:update(v10, workspace:GetServerTimeNow())
	end

	if total2 >= 0.1 then
		total2 = 0
		updateState()
	end
end)
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()
	onClientEventConnection:Disconnect()
	eventConnection:Disconnect()
	v3:destroy()
	v6:destroy()
	v5:destroy()
	v4:destroy()
	v2:destroy()
	v()
end)
updateState()