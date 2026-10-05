local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()
local color = Color3.fromRGB(88, 94, 180)
local color2 = Color3.fromRGB(255, 255, 255)
local v = nil

local function getCaveParts()
	local map = workspace:FindFirstChild("Map")
	local cave = map and map:FindFirstChild("Cave")
	local collisions = cave and cave:FindFirstChild("Collisions")

	if not collisions then
		return nil
	end

	local descendants = collisions:QueryDescendants("BasePart")

	if #descendants == 0 then
		return nil
	end

	return descendants
end

local Crystal = {}

function Crystal.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Clean()
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("CrystalEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("CrystalEvent", "GrassRecolor")
	end)
	EffectController:Run("CrystalEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("CrystalEvent", "WallRecolor")
	end)
	EffectController:Run("CrystalEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("CrystalEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("HideInCrystal", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	local crystalAtmosphere = script:FindFirstChild("CrystalAtmosphere")

	if crystalAtmosphere then
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(crystalAtmosphere)
		clone_2.Parent = Lighting
	end

	local crystalSky = script:FindFirstChild("CrystalSky")

	if crystalSky then
		local cartoon = Lighting:FindFirstChild("Cartoon") or Lighting:FindFirstChildOfClass("Sky")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_3 = maid:Clone(crystalSky)
		clone_3.Parent = Lighting
	end

	local clone = nil

	if not ServerData.IsTsunamiServer() then
		local biggerCrystalMap

		if ServerData.IsBiggerServer() then
			biggerCrystalMap = script:FindFirstChild("BiggerCrystalMap")
		else
			biggerCrystalMap = script:FindFirstChild("CrystalMap")
		end

		if biggerCrystalMap then
			clone = maid:Clone(biggerCrystalMap)
			clone.Parent = workspace
		end
	end

	local mutationSpawner = clone and clone:FindFirstChild("MutationSpawner")
	local crystalFlower = mutationSpawner and mutationSpawner:FindFirstChild("CrystalFlower")
	local animationController = crystalFlower and crystalFlower:FindFirstChild("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")
	local track

	if animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://138929278937388"
		track = animator:LoadAnimation(animation)
		animation:Destroy()
		maid:Add(function()
			assert(track)
			track:Stop(0)
			track:Destroy()
		end)
	else
		track = nil
	end

	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreCave()
		local v2 = v

		if not v2 then
			return
		end

		for k, color3 in v2 do
			if k.Parent then
				k.Color = color3
			end
		end
	end

	maid:Add(Net:RemoteEvent("GameService/CrystalSpawnAnimation").OnClientEvent:Connect(function()
		if mutationSpawner and mutationSpawner:IsA("Model") and mutationSpawner:IsDescendantOf(workspace) and animator and animator:IsDescendantOf(workspace) and track then
			track:Stop(0)
			track:Play()

			if FFlags:GetInstant("CrystalEvent/SpawnSFXEnabled", false) then
				local crystalSpawn = ReplicatedStorage.Sounds.Sfx:FindFirstChild("CrystalSpawn")

				if crystalSpawn and crystalSpawn:IsA("Sound") then
					SoundController:PlaySound(crystalSpawn, mutationSpawner:GetPivot().Position, false)
				end
			end

			VFX.emit(mutationSpawner)
		end

		count += 1
		local v2 = count
		task.spawn(function()
			local caveParts = getCaveParts()

			if not caveParts then
				return
			end

			if not v then
				local colorsByCavePart = {}

				for _, cavePart in caveParts do
					colorsByCavePart[cavePart] = cavePart.Color
				end

				v = colorsByCavePart
			end

			assert(v)
			local v3 = v

			local function stillActive()
				return v2 == count
			end

			local lastTime = os.clock()

			while v2 == count do
				local v4 = os.clock() - lastTime

				if v4 >= 2.5 then
					break
				end

				local v5 = math.clamp(v4 / 2.5, 0, 1)
				local v6 = v5 * v5

				for _, cavePart in caveParts do
					local v7 = v3[cavePart]

					if v7 then
						cavePart.Color = v7:Lerp(color, v6)
					end
				end

				RunService.Heartbeat:Wait()
			end

			if v2 == count then
				for _, cavePart in caveParts do
					cavePart.Color = color2
				end

				task.wait(0.1)
			end

			if v2 == count then
				restoreCave() -- equivalent call inferred; original call site unknown
			end
		end)
	end))
	maid:Add(function()
		count += 1
		restoreCave() -- equivalent call inferred; original call site unknown
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Crystal.OnStop(_)
	maid:Clean()
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Crystal.OnLoad(_) end

return Crystal