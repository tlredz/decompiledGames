local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local ScreenEffectsSetting = require(ReplicatedStorage.Modules.ClientUI.ScreenEffectsSetting)
local cframe = CFrame.new(0, 0, -12)
local numberRange = NumberRange.new(0.021, 6.5075)
local localPlayer = Players.LocalPlayer
local clone = nil
local renderSteppedConnection = nil
local connections = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function applyEffectsLevel(folder)
	local particles = ScreenEffectsSetting.profile().particles

	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local rate = object[emitter]

		if not rate then
			rate = emitter.Rate
			object[emitter] = rate
		end

		emitter.Rate = rate * particles
		emitter.Enabled = particles > 0

		if particles <= 0 then
			emitter:Clear()
		end
	end
end

local function findTemplate()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local hauntedGala = assets and assets:FindFirstChild("HauntedGala")
	local sugarRush = hauntedGala and hauntedGala:FindFirstChild("SugarRush")
	local cameraParticles = sugarRush and sugarRush:FindFirstChild("CameraParticles")

	if cameraParticles and cameraParticles:IsA("BasePart") then
		return cameraParticles
	end

	return nil
end

local function findSound(folder, value)
	local v = string.lower(value)

	for _, sound in ipairs(folder:GetDescendants()) do
		if sound:IsA("Sound") and string.lower(sound.Name) == v then
			return sound
		end
	end

	return nil
end

local function routeThroughMusicBus(p)
	if not SoundGroupManager.AssignMusicSound(p) then
		return
	end

	local group = SoundGroupManager.GetGroup("Music")

	if not group then
		return
	end

	group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
end

local function playSounds(clone2)
	local sound = findSound(clone2, "sprinkle")

	if sound then
		sound.Looped = false
		sound:Play()
	else
		warn("[SugarRushClient] No 'sprinkle' Sound in the CameraParticles template")
	end

	local sound2 = findSound(clone2, "disco")

	if not sound2 then
		warn("[SugarRushClient] No 'disco' Sound in the CameraParticles template")
		return
	end

	sound2.Looped = true

	if sound2.SoundId == "rbxassetid://115382194353447" then
		sound2.LoopRegion = numberRange
		sound2.PlaybackRegionsEnabled = true
		print("[SugarRushClient] Loop trimmed to", numberRange)
	end

	local v = SoundGroupManager.AssignMusicSound(sound2) and SoundGroupManager.GetGroup("Music")

	if v then
		v.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
	end

	sound2:Play()
end

local function windDown(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local sound = findSound(folder, "disco")

	if sound and sound.IsPlaying then
		TweenService:Create(sound, TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()
	end

	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		local currentCamera = workspace.CurrentCamera

		if folder.Parent and currentCamera then
			folder.CFrame = currentCamera.CFrame * cframe
		else
			renderSteppedConnection2:Disconnect()
		end
	end)
	folder.Destroying:Once(function()
		renderSteppedConnection2:Disconnect()
	end)
	Debris:AddItem(folder, 3.25)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopParticles()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if clone then
		windDown(clone)
		clone = nil
		print("[SugarRushClient] Camera particles winding down")
	end
end

local function startParticles()
	if clone then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local template = findTemplate()

	if not currentCamera then
		return
	end

	if not template then
		warn("[SugarRushClient] No BasePart at ReplicatedStorage.Assets.HauntedGala.SugarRush.CameraParticles")
		return
	end

	clone = template:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	applyEffectsLevel(clone)
	clone.CFrame = currentCamera.CFrame * cframe
	clone.Parent = currentCamera
	playSounds(clone)
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local currentCamera2 = workspace.CurrentCamera

		if clone and currentCamera2 then
			clone.CFrame = currentCamera2.CFrame * cframe
		end
	end)
	print("[SugarRushClient] Camera particles attached at effects level", ScreenEffectsSetting.level())
end

ScreenEffectsSetting.onChanged(function()
	if clone then
		applyEffectsLevel(clone)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function isBuffed(instance)
	if not (instance and instance:IsDescendantOf(game)) then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	return not (humanoid and humanoid.Health <= 0) and instance:FindFirstChild("SugarRush") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncToCharacter(p)
	task.defer(function()
		-- equivalent call inferred; original call site unknown
		if isBuffed(p) then
			startParticles()
			return
		end

		stopParticles() -- equivalent call inferred; original call site unknown
	end)
end

local function bindCharacter(character)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	stopParticles() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchHumanoid(humanoid)
		table.insert(connections, humanoid.HealthChanged:Connect(function(p)
			if p <= 0 then
				syncToCharacter(character) -- equivalent call inferred; original call site unknown
			end
		end))
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		table.insert(connections, humanoid.HealthChanged:Connect(function(p)
			if p <= 0 then
				syncToCharacter(character) -- equivalent call inferred; original call site unknown
			end
		end))
	end

	table.insert(connections, character.ChildAdded:Connect(function(humanoid2)
		if humanoid2.Name == "SugarRush" then
			syncToCharacter(character) -- equivalent call inferred; original call site unknown
		elseif humanoid2:IsA("Humanoid") then
			watchHumanoid(humanoid2) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, character.AncestryChanged:Connect(function()
		syncToCharacter(character) -- equivalent call inferred; original call site unknown
	end))
	table.insert(connections, character.ChildRemoved:Connect(function(child)
		if child.Name == "SugarRush" then
			syncToCharacter(character) -- equivalent call inferred; original call site unknown
		end
	end))
	syncToCharacter(character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(bindCharacter)

if localPlayer.Character then
	bindCharacter(localPlayer.Character)
end