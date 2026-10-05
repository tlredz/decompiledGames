local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Types.AreaEggs)
local Audio = require(ReplicatedStorage.Shared.Audio)
local EggState = require(ReplicatedStorage.Client.EggState)
local ScreenEffects = require(script.ScreenEffects)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
local Player = require(ReplicatedStorage.Shared.Player)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local world = Workspace.World
assert(world:IsA("Folder"), "Workspace.World must be a Folder")
local areas = world.Areas
assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
local guardAreas = areas.GuardAreas
assert(guardAreas:IsA("Folder"), "Workspace.World.Areas.GuardAreas must be a Folder")
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGuardedMusic(p)
	if not p.GuardedMusicActive then
		return
	end

	p.GuardedMusicActive = false
	MusicDirector.SetGuardedGameplay(false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseUiHide(state)
	local releaseUiHide2 = state.ReleaseUiHide

	if releaseUiHide2 == nil then
		return
	end

	state.ReleaseUiHide = nil
	releaseUiHide2()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelGuardStateWait(state)
	local guardStateConnection = state.GuardStateConnection

	if guardStateConnection == nil then
		return
	end

	state.GuardStateConnection = nil
	guardStateConnection:Disconnect()
end

local function acquireUiHide()
	return HiddenUIHandler.Acquire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGuardedMusicForGeneration(p, p2: number)
	if p.GuardedMusicGeneration ~= p2 then
		return
	end

	stopGuardedMusic(p) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopRunBackState(state)
	cancelGuardStateWait(state) -- equivalent call inferred; original call site unknown

	if not state.Active then
		return
	end

	state.Active = false
	state.Effects:Stop()
	stopGuardedMusic(state) -- equivalent call inferred; original call site unknown
	MusicDirector.SetCarryingAreaEgg(false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCarryState(p)
	if p.ReleaseUiHide ~= nil then
		return
	end

	local humanoid = Player.FindHumanoid(localPlayer)

	if humanoid ~= nil then
		humanoid:UnequipTools()
	end

	p.ReleaseUiHide = HiddenUIHandler.Acquire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCarryState(state)
	state.CarryGeneration += 1
	stopRunBackState(state) -- equivalent call inferred; original call site unknown
	releaseUiHide(state) -- equivalent call inferred; original call site unknown
end

local function startRunBackState(state, flag: boolean)
	cancelGuardStateWait(state) -- equivalent call inferred; original call site unknown

	if state.Active then
		return
	end

	state.Active = true
	state.GuardedMusicGeneration += 1
	local guardedMusicGeneration = state.GuardedMusicGeneration
	MusicDirector.SetCarryingAreaEgg(true)
	state.GuardedMusicActive = true
	MusicDirector.SetGuardedGameplay(true)
	state.Effects:Start(flag)
	local v2 = Audio.Play("rbxassetid://113113198465358", script, {
		PlaybackSpeed = 1.07,
		Volume = 2
	})

	if v2 == nil or v2.SoundId == "" then
		stopGuardedMusicForGeneration(state, guardedMusicGeneration) -- equivalent call inferred; original call site unknown
	else
		state.Trove:Add(v2.Ended:Once(function()
			stopGuardedMusicForGeneration(state, guardedMusicGeneration) -- equivalent call inferred; original call site unknown
		end))
		state.Trove:Add(v2.Stopped:Once(function()
			stopGuardedMusicForGeneration(state, guardedMusicGeneration) -- equivalent call inferred; original call site unknown
		end))
	end
end

local function startWhenGuardWakeFinishes(state, data)
	state.CarryGeneration += 1
	local carryGeneration = state.CarryGeneration
	cancelGuardStateWait(state) -- equivalent call inferred; original call site unknown

	if state.Active then
		return
	end

	local guardDisabled = data.GuardDisabled == true

	if data.RunBackWakeDelayRequired ~= true then
		startRunBackState(state, guardDisabled)
		return
	end

	local areaId = data.AreaId
	assert(areaId ~= nil, "Carried area egg state must include AreaId")
	local model = guardAreas[areaId]
	assert(model ~= nil, (`Workspace.World.Areas.GuardAreas.{areaId} is required`))
	assert(model:IsA("Model"), (`Workspace.World.Areas.GuardAreas.{areaId} must be a Model`))
	local guard = model.Guard
	assert(guard ~= nil, (`{model:GetFullName()}.Guard is required`))
	assert(guard:IsA("Model"), (`{model:GetFullName()}.Guard must be a Model`))

	if guard:GetAttribute("GuardState") == "Chasing" then
		startRunBackState(state, guardDisabled)
	else
		state.GuardStateConnection = guard:GetAttributeChangedSignal("GuardState"):Connect(function()
			if not (state.CarryGeneration == carryGeneration and guard:GetAttribute("GuardState") == "Chasing") then
				return
			end

			startRunBackState(state, guardDisabled)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCarryState(p, p2)
	if p2.IsCarrying then
		startCarryState(p) -- equivalent call inferred; original call site unknown
		startWhenGuardWakeFinishes(p, p2)
	else
		stopCarryState(p) -- equivalent call inferred; original call site unknown
	end
end

local function resolveRuntime()
	local v2 = v

	if v2 ~= nil then
		return v2
	end

	local v3 = {
		Active = false,
		CarryGeneration = 0,
		Effects = ScreenEffects.new(),
		GuardStateConnection = nil,
		GuardedMusicActive = false,
		GuardedMusicGeneration = 0,
		ReleaseUiHide = nil,
		Started = false,
		Trove = Trove.new()
	}
	v = v3
	return v3
end

local CarryRunBackEffects = {}

function CarryRunBackEffects.Start()
	local runtime = resolveRuntime()

	if runtime.Started then
		return
	end

	runtime.Started = true
	runtime.Trove:Add(EggState.CarryChanged:Connect(function(p)
		applyCarryState(runtime, p) -- equivalent call inferred; original call site unknown
	end))
	runtime.Trove:Connect(localPlayer.CharacterRemoving, function()
		stopCarryState(runtime) -- equivalent call inferred; original call site unknown
	end)
	runtime.Trove:Add(function()
		stopCarryState(runtime) -- equivalent call inferred; original call site unknown
	end)
	local carryState = EggState.ReadCarryState()

	if carryState.IsCarrying then
		applyCarryState(runtime, carryState) -- equivalent call inferred; original call site unknown
	end
end

function CarryRunBackEffects.ForceStart(flag: boolean?)
	local runtime = resolveRuntime()
	runtime.CarryGeneration += 1
	startCarryState(runtime) -- equivalent call inferred; original call site unknown
	startRunBackState(runtime, flag == true)
end

function CarryRunBackEffects.ForceStop()
	stopCarryState(resolveRuntime()) -- equivalent call inferred; original call site unknown
end

return CarryRunBackEffects