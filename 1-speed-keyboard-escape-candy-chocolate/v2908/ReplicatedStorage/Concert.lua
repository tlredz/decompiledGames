local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local script2 = script
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)
local ConcertPreloader = require(script.ConcertPreloader)
local ConcertUI = require(script.ConcertUI)
local ConcertCountdown = require(script.ConcertCountdown)
local ConcertEndScreen = require(script.ConcertEndScreen)
local SetUtils = require(ReplicatedStorage.Utilities.SetUtils)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local MicroProfiler = require(ReplicatedStorage.Utilities.MicroProfiler)
local ConcertUtils = require(script2.ConcertUtils)
local ConcertState = require(script2.ConcertState)
local ConcertRemotes = require(script2.ConcertRemotes)
local Concert = {}
local flag = false
local count = 0
local v = SetUtils.new({})
local v2 = nil
local v3 = nil
Concert.OnStageChanged = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function SetConcertActive(concertActive: boolean)
	if RunService:IsServer() then
		script:SetAttribute("ConcertActive", concertActive)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetConcertPremiere(premiere: boolean)
	if RunService:IsServer() then
		script:SetAttribute("ConcertPremiere", premiere)
	end
end

local function AdvanceClockTime(p: number, p2: number)
	local clockTime = Lighting.ClockTime
	local v4 = (p - clockTime) % 24

	if v4 == 0 then
		return
	end

	Lighting.ClockTime = (clockTime + math.min(v4, p2 * 4)) % 24
end

local function IsCutsceneModelPart(p, assetFolder)
	local parent = p.Parent

	while parent and parent ~= assetFolder do
		if parent:IsA("Model") then
			local camera = parent:FindFirstChild("Camera")

			if camera and camera:IsA("BasePart") and camera.Parent == parent then
				return true
			end
		end

		parent = parent.Parent
	end

	return false
end

function Concert.IsConcertActive()
	return ConcertState.PlayingStage ~= nil or script:GetAttribute("ConcertActive") == true
end

function Concert.IsPremiere()
	return script:GetAttribute("ConcertPremiere") == true
end

function Concert.SetConcertVolume(p: number)
	ConcertUtils.SetConcertVolume(p)
end

function Concert.Start()
	if flag then
		return
	end

	flag = true

	if not Concert.CanPlayInThisWorld() then
		return
	end

	ReplicatedStorage:SetAttribute("IsConcertWorld", true)

	if RunService:IsServer() and script:GetAttribute("ConcertActive") == nil and RunService:IsServer() then
		script:SetAttribute("ConcertActive", false)
	end

	if RunService:IsServer() and script:GetAttribute("ConcertPremiere") == nil and RunService:IsServer() then
		script:SetAttribute("ConcertPremiere", false)
	end

	if RunService:IsServer() then
		local ConcertTreadmill = require(script.ConcertTreadmill)
		ConcertTreadmill.Start()
	end

	ConcertCountdown.Start()
	ConcertUtils.SetupEmitter()

	if RunService:IsServer() then
		ConcertUtils.SetMusicEndedHandler(function(p)
			if ConcertState.PlayingStage == p then
				Concert.ChangeStage(nil, nil, count)
			end
		end)
	end

	ConcertPreloader.Preload()

	if RunService:IsServer() then
		MicroProfiler.Call("Concert.InitializeStageParts", function()
			for _, v4 in Concert.GetAllStageDefs() do
				if not v4.AssetFolder then
					continue
				end

				for _, v5 in v4.AssetFolder:QueryDescendants("BasePart") do
					v5.CanCollide = false
					v5.CanQuery = false
					v5.CanTouch = false

					if not IsCutsceneModelPart(v5, v4.AssetFolder) then
						v5.Anchored = true
					end
				end
			end
		end)
	end

	if RunService:IsServer() then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local concert = assets and assets:FindFirstChild("Concert")

		if concert then
			for _, v4 in concert:QueryDescendants("AudioPlayer") do
				v4.Volume = 1
			end
		end
	end

	if RunService:IsServer() then
		Players.PlayerRemoving:Connect(function(player)
			v:delete(player)
		end)
	else
		ConcertEndScreen.Start(script, "ConcertActive", "ConcertPremiere")
		ConcertRemotes.Ready:fire()
		MicroProfiler.Call("Concert.MountUI", ConcertUI.Mount)
	end

	if RunService:IsServer() then
		ConcertRemotes.Ready:connect(function(p)
			Concert.SyncPlayer(p)
		end)
	else
		ConcertRemotes.ChangeStage:connect(function(p: string?, p2: number?)
			Concert.ChangeStage(p, p2)
		end)
		ConcertRemotes.SetStageTimePosition:connect(function(musicStartTime: number)
			ConcertState.MusicStartTime = musicStartTime
			local audioPlayer = ConcertUtils.GetAudioPlayer()

			if audioPlayer then
				audioPlayer.TimePosition = ConcertUtils.GetCurrentStageElapsedTime()
			end
		end)
	end

	RunService.Heartbeat:Connect(function(deltatime)
		ConcertState.Deltatime = deltatime
		ConcertUtils.MakeSureIsPlayingMusic()
		local playingStage = ConcertState.PlayingStage

		if playingStage then
			playingStage:Update()
		end

		if RunService:IsClient() then
			local currentStageElapsedTime = ConcertUtils.GetCurrentStageElapsedTime()

			if playingStage then
				local lyricAtElapsedTime = playingStage:GetLyricAtElapsedTime(currentStageElapsedTime)

				if lyricAtElapsedTime then
					local v4 = 0

					for k, word in lyricAtElapsedTime.words do
						if currentStageElapsedTime < word.appearTime then
							break
						else
							v4 = k
						end
					end

					if v2 == lyricAtElapsedTime then
						if v3 ~= v4 then
							v3 = v4
							ConcertUI.CurrentWord(v4)
						end
					else
						v2 = lyricAtElapsedTime
						v3 = v4
						ConcertUI.SetLine(lyricAtElapsedTime.text, lyricAtElapsedTime.words, v4)
					end

					ConcertUI.CurrentTransparency(ConcertUI.GetLineFadeTransparency(
						lyricAtElapsedTime,
						currentStageElapsedTime
					))
				elseif v2 ~= nil or v3 ~= 0 then
					v2 = nil
					v3 = 0
					ConcertUI.SetLine("", nil, 0)
					ConcertUI.CurrentTransparency(0)
				end
			elseif v2 ~= nil or v3 ~= 0 then
				v2 = nil
				v3 = 0
				ConcertUI.SetLine("", nil, 0)
				ConcertUI.CurrentTransparency(0)
			end

			local isConcertActive = Concert.IsConcertActive()
			ConcertCountdown.Update(isConcertActive)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				if isConcertActive and currentCamera.CameraType ~= Enum.CameraType.Scriptable then
					currentCamera.CameraType = Enum.CameraType.Scriptable
				elseif not isConcertActive and currentCamera.CameraType == Enum.CameraType.Scriptable then
					currentCamera.CameraType = Enum.CameraType.Custom
				end
			end

			local clockTime = Lighting.ClockTime
			local v4 = ((isConcertActive and 0 or 14) - clockTime) % 24

			if v4 ~= 0 then
				Lighting.ClockTime = (clockTime + math.min(v4, deltatime * 4)) % 24
			end

			local v5 = CollectionService:GetTagged("Scene")[1]

			if not v5 then
				return
			end

			for _, pVInstance in CollectionService:GetTagged("Concert_Spinning") do
				if not (pVInstance:IsA("PVInstance") and pVInstance:IsDescendantOf(v5)) then
					continue
				end

				local originCF = pVInstance:GetAttribute("OriginCF")

				if not originCF then
					originCF = pVInstance:GetPivot()
					pVInstance:SetAttribute("OriginCF", originCF)
				end

				local rotationVec = pVInstance:GetAttribute("RotationVec") or createVector(0, 1, 0)
				pVInstance:PivotTo(originCF * CFrame.Angles(
					currentStageElapsedTime * rotationVec.X,
					currentStageElapsedTime * rotationVec.Y,
					currentStageElapsedTime * rotationVec.Z
				))
			end
		end
	end)
end

function Concert.ChangeStage(p: string?, p2: number?, p3: number?)
	if not Concert.CanPlayInThisWorld() then
		return warn("[CONCERT] ChangeStage is disabled outside World 4.")
	end

	if RunService:IsServer() and p3 == nil then
		count += 1
		SetConcertPremiere(false) -- equivalent call inferred; original call site unknown
	end

	local musicStartTime = p2 or Workspace:GetServerTimeNow()
	local playingStage2 = p and ConcertUtils.GetStage(p)
	local playingStage = ConcertState.PlayingStage

	if RunService:IsServer() and p3 == nil then
		SetConcertActive(playingStage2 ~= nil) -- equivalent call inferred; original call site unknown
	end

	if playingStage == playingStage2 then
		return ConcertUtils.Print((`Stage {p} is already playing, ignoring change stage request.`))
	end

	if RunService:IsServer() then
		ConcertRemotes.ChangeStage:fireAll(p, musicStartTime)
	end

	if playingStage2 then
		MicroProfiler.Call("Concert.InitializeStage", function()
			playingStage2:Init()
		end)
	end

	if playingStage then
		playingStage:TransitionOut()
		playingStage:StopMusic()
		ConcertState.PlayingStage = nil
		task.spawn(playingStage.Cleanup, playingStage)
	end

	if not playingStage2 then
		Concert.OnStageChanged:Fire(nil)
		return
	end

	ConcertState.MusicStartTime = musicStartTime
	ConcertState.PlayingStage = playingStage2
	Concert.OnStageChanged:Fire(playingStage2.Name)
	playingStage2:PlayMusic()
	playingStage2:TransitionIn()
end

function Concert.SyncPlayer(p)
	if not Concert.CanPlayInThisWorld() or v:has(p) then
		return
	end

	v:add(p)

	if not ConcertState.PlayingStage then
		return
	end

	local changeStage = ConcertRemotes.ChangeStage
	local v4

	if ConcertState.PlayingStage then
		v4 = ConcertState.PlayingStage.Name
	end

	changeStage:fire(p, v4, ConcertState.MusicStartTime)
end

function Concert.SetMusicTimePosition(p: number)
	if RunService:IsClient() then
		return
	end

	if not Concert.CanPlayInThisWorld() then
		return warn("[CONCERT] SetMusicTimePosition is disabled outside World 4.")
	end

	if not ConcertState.PlayingStage then
		return
	end

	local v4 = math.max(p, 0)
	local musicStartTime = Workspace:GetServerTimeNow() - v4
	ConcertState.MusicStartTime = musicStartTime
	ConcertRemotes.SetStageTimePosition:fireAll(musicStartTime)
end

function Concert.GetAllStageDefs()
	local modules = {}

	for _, moduleScript in script.Stages:QueryDescendants("ModuleScript") do
		local module = require(moduleScript)
		table.insert(modules, module)
	end

	return modules
end

function Concert.GetCurrentMusicPlayer()
	return ConcertUtils.GetAudioPlayer()
end

local function GetStageMusic(p)
	local music = p.AssetFolder:FindFirstChild("Music")

	if music and music:IsA("AudioPlayer") then
		return music
	end

	return p.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
end

local function WaitForMusicDuration(p, p2: number)
	local music = p.AssetFolder:FindFirstChild("Music")

	if not (music and music:IsA("AudioPlayer")) then
		music = p.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
	end

	if not music then
		warn((`[CONCERT] Skipping stage {p.Name}: no AudioPlayer was found.`))
		return nil
	end

	local v4 = os.clock() + 30

	while music.TimeLength <= 0 do
		if count ~= p2 then
			return nil
		end

		if v4 <= os.clock() then
			warn((`[CONCERT] Skipping stage {p.Name}: its music duration did not load within 30 seconds.`))
			return nil
		else
			RunService.Heartbeat:Wait()
		end
	end

	return music.TimeLength
end

local function WaitForStageToFinish(p, p2: number, p3: number)
	while ConcertUtils.GetCurrentStageElapsedTime() < p2 do
		if count ~= p3 or ConcertState.PlayingStage ~= p then
			return false
		end

		RunService.Heartbeat:Wait()
	end

	return count == p3 and ConcertState.PlayingStage == p
end

function Concert.LaunchConcert(value: number?, options)
	if not RunService:IsServer() then
		warn("[CONCERT] LaunchConcert can only be called on the server.")
		return false
	end

	if not Concert.CanPlayInThisWorld() then
		warn("[CONCERT] LaunchConcert is disabled outside World 4.")
		return false
	end

	local v4 = value or 0

	if type(v4) ~= "number" or v4 ~= v4 or math.abs(v4) == 1e999 or v4 < 0 then
		warn("[CONCERT] LaunchConcert TimeElapsed must be a finite, non-negative number.")
		return false
	end

	local v5 = options or {}

	if type(v5.Premiere) ~= "boolean" and v5.Premiere ~= nil then
		warn("[CONCERT] LaunchConcert Options.Premiere must be a boolean when provided.")
		return false
	end

	local premiere = v5.Premiere == true
	local v6 = {}

	for _, v7 in Concert.GetAllStageDefs() do
		if not v7.IsPremiereOnly or premiere then
			table.insert(v6, v7)
		end
	end

	table.sort(v6, function(a, b)
		if a.Order == b.Order then
			return a.Name < b.Name
		end

		return a.Order < b.Order
	end)

	if #v6 == 0 then
		warn("[CONCERT] LaunchConcert could not find any concert stages.")
		return false
	end

	count += 1
	local v7 = count
	SetConcertPremiere(premiere) -- equivalent call inferred; original call site unknown
	SetConcertActive(true) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		if count ~= v7 then
			return
		end

		if ConcertState.PlayingStage then
			Concert.ChangeStage(nil, nil, v7)
		end

		local v8 = v4

		for _, v9 in v6 do
			if count ~= v7 then
				return
			end

			local waitForMusicDuration = WaitForMusicDuration(v9, v7)

			if waitForMusicDuration then
				if waitForMusicDuration <= v8 then
					v8 -= waitForMusicDuration
				else
					local v11 = Workspace:GetServerTimeNow() - v8
					v8 = 0
					Concert.ChangeStage(v9.Name, v11, v7)

					if not WaitForStageToFinish(v9, waitForMusicDuration, v7) then
						if count ~= v7 then
							return
						end

						if ConcertState.PlayingStage ~= nil then
							SetConcertPremiere(false) -- equivalent call inferred; original call site unknown
							SetConcertActive(false) -- equivalent call inferred; original call site unknown
							return
						end
					end
				end
			elseif count ~= v7 then
				return
			end
		end

		if count == v7 then
			Concert.ChangeStage(nil, nil, v7)
			SetConcertActive(false) -- equivalent call inferred; original call site unknown
		end
	end)
	return true
end

function Concert.ForceStopConcert()
	if not RunService:IsServer() then
		warn("[CONCERT] ForceStopConcert can only be called on the server.")
		return false
	end

	if not Concert.CanPlayInThisWorld() then
		warn("[CONCERT] ForceStopConcert is disabled outside World 4.")
		return false
	end

	count += 1
	Concert.ChangeStage(nil, nil, count)
	SetConcertPremiere(false) -- equivalent call inferred; original call site unknown
	SetConcertActive(false) -- equivalent call inferred; original call site unknown
	return true
end

function Concert.CanPlayInThisWorld()
	local _, v4 = PlaceRegistry.locate()
	return v4 == 4
end

return Concert