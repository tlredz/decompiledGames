local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Skibidi = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Skibidi/SpawnSkibidi")
local remoteEvent2 = Net:RemoteEvent("EventService/Skibidi/Burst")
local maid = Trove.new()
local flag = false
local identity = CFrame.identity

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutSine(p: number)
	return (math.sin(p * 3.141592653589793 * 0.5))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInSine(p: number)
	return 1 - math.cos(p * 3.141592653589793 * 0.5)
end

local cframe = CFrame.new(0, -2.441, 0.21)
local v = {}

local function spawnSkibidi(cframe2: CFrame, _: string, flag2: boolean?)
	local maid2 = Trove.new()
	SoundController:PlaySound(ReplicatedStorage.Sounds.Events.Skibidi.Pop, cframe2.Position, false)
	local v2 = table.remove(v, 1) or script.Skibidi:Clone()
	local v3 = v2.Parent ~= nil
	local v4 = 0
	local v5 = -5.1
	local v6 = time()
	local primaryPart = v2.PrimaryPart
	local __skibidi_transform = primaryPart.__skibidi_transform
	primaryPart.Anchored = false

	if not v3 then
		__skibidi_transform.C1 = cframe
		__skibidi_transform.Part0 = workspace.Terrain
		__skibidi_transform.Part1 = primaryPart
		v2.Parent = workspace
	end

	maid2:Add(RunService.PostSimulation:Connect(function()
		debug.profilebegin("skibidi:update")
		local v7 = time() - v6

		if v7 <= 0.75 then
			local v8 = easeOutSine(v7 / 0.75) -- equivalent call inferred; original call site unknown
			v4 = math.lerp(0, 12.566370614359172, v8)
			v5 = math.lerp(-5.1, -0.5, v8)
		elseif v7 >= 1.25 then
			local v8 = easeInSine(math.clamp((v7 - 1.25) / 0.75, 0, 1)) -- equivalent call inferred; original call site unknown
			v4 = math.lerp(12.566370614359172, 25.132741228718345, v8)
			v5 = math.lerp(-0.5, -5.1, v8)
		end

		local v8 = cframe2 * CFrame.new(0, v5, 0)
		__skibidi_transform.Transform = CFrame.lookAt(v8.Position, (Vector3.new(identity.X, v8.Y, identity.Z))) * CFrame.Angles(
			0,
			v4,
			0
		)
		debug.profileend()
	end))
	maid2:Add(task.delay(flag2 and 0.5 or 2, function()
		if flag then
			__skibidi_transform.Transform = CFrame.identity
			table.insert(v, v2)
		else
			v2:Destroy()
		end

		maid2:Destroy()
	end))
end

function Skibidi.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	local skibidiEventSeed = ReplicatedStorage:GetAttribute("SkibidiEventSeed")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateCurrentSeed(serverTimeNow: number)
		return skibidiEventSeed + (serverTimeNow - activeEventData.startedAt) // 5
	end

	ReplicatedStorage:SetAttribute("SkibidiEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("SkibidiEvent", nil)
	end)
	flag = true
	maid:Add(function()
		flag = false
		task.defer(function()
			for _, v2 in v do
				v2:Destroy()
			end

			table.clear(v)
		end)
	end)
	EffectController:Activate("Blink")
	SoundController:UpdateOST()
	CycleController:Update()
	maid:Add(function()
		EffectController:Activate("Blink")
		SoundController:UpdateOST()
		CycleController:Update()
	end)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.Atmosphere)
	clone_2.Parent = Lighting

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.MapVFX))
	else
		local clone

		if ServerData.IsTsunamiServer() then
			clone = maid:Clone(script.MapVFXTsunami)
		else
			clone = maid:Clone(script.MapVFX)
		end

		clone.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone, 2)
		end
	end

	local currentSeed = calculateCurrentSeed(workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown
	local random = Random.new(currentSeed)
	local isJumpLTMServer = ServerData.IsJumpLTMServer()
	local groundTsunami

	if ServerData.IsTsunamiServer() then
		groundTsunami = workspace.Events.Skibidi.GroundTsunami
	elseif ServerData.IsBiggerServer() then
		groundTsunami = workspace.Events.Skibidi.GroundBigger
	else
		groundTsunami = workspace.Events.Skibidi.Ground
	end

	local children = groundTsunami:GetChildren()
	local wallTopTsunami

	if ServerData.IsTsunamiServer() then
		wallTopTsunami = workspace.Events.Skibidi.WallTopTsunami
	elseif ServerData.IsBiggerServer() then
		wallTopTsunami = workspace.Events.Skibidi.WallTopBigger
	else
		wallTopTsunami = workspace.Events.Skibidi.WallTop
	end

	local children2 = wallTopTsunami:GetChildren()
	local v3 = isJumpLTMServer and {} or children2
	local vector2 = Vector3.new(MapInformation.MapCenter.Position.X, 1.5, MapInformation.MapCenter.Position.Z)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.RespectCanCollide = true

	local function generateIslandToiletPosition()
		local track = workspace.Map:FindFirstChild("Track")
		local children3

		if track then
			children3 = track:GetChildren()
		end

		if not children3 or #children3 == 0 then
			return nil
		end

		local island = children3[random:NextInteger(1, #children3)]:FindFirstChild("Island")

		if not island then
			return nil
		end

		local terrain = island:FindFirstChild("Terrain") or island
		local descendants = terrain:QueryDescendants("BasePart")

		if #descendants == 0 then
			return nil
		end

		local descendant = descendants[random:NextInteger(1, #descendants)]
		local v4 = descendant.Position.X + random:NextNumber(-descendant.Size.X / 2, descendant.Size.X / 2)
		local v5 = descendant.Position.Z + random:NextNumber(-descendant.Size.Z / 2, descendant.Size.Z / 2)
		raycastParams.FilterDescendantsInstances = { terrain }
		local vector3 = Vector3.new(v4, descendant.Position.Y + descendant.Size.Y / 2 + 50, v5)
		local raycastResult = workspace:Raycast(vector3, createVector(0, -300, 0), raycastParams)

		if raycastResult then
			return CFrame.new(raycastResult.Position)
		end

		return nil
	end

	local function generateRandomTargetPosition(p)
		if isJumpLTMServer then
			local number = random:NextNumber(0, 6.283185307179586)
			local number2 = random:NextNumber(35, 70)
			return CFrame.new(vector2 + Vector3.new(math.cos(number) * number2, 0, math.sin(number) * number2))
		else
			local v4

			if p == "WallTop" then
				v4 = v3
			else
				v4 = children
			end

			local v5 = v4[random:NextInteger(1, #v4)]
			local cFrame = v5.CFrame
			local size = v5.Size
			return cFrame * CFrame.new(
				random:NextNumber(-size.X * 0.5, size.X * 0.5),
				size.Y * 0.5,
				random:NextNumber(-size.Z * 0.5, size.Z * 0.5)
			)
		end
	end

	maid:Add(Timer.Simple(isJumpLTMServer and 0.5 or 0.1, function()
		local currentSeed2 = calculateCurrentSeed(workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown

		if currentSeed ~= currentSeed2 then
			currentSeed = currentSeed2
			random = Random.new(currentSeed2)
		end

		spawnSkibidi(generateRandomTargetPosition("Ground"), "Ground")

		if isJumpLTMServer then
			local cframe3 = generateIslandToiletPosition()

			if cframe3 then
				spawnSkibidi(cframe3, "Ground")
			end

			local cframe4 = generateIslandToiletPosition()

			if cframe4 then
				spawnSkibidi(cframe4, "Ground")
			end
		end

		if #v3 > 0 then
			spawnSkibidi(generateRandomTargetPosition("WallTop"), "WallTop")
		end
	end))
	local character = localPlayer.Character
	maid:Add(localPlayer.CharacterAdded:Connect(function(character2)
		character = character2
	end))
	maid:Add(RunService.PostSimulation:Connect(function()
		identity = character:GetPivot()
	end))
end

function Skibidi.OnStop(_)
	maid:Destroy()
end

function Skibidi.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		if typeof(p) == "CFrame" then
			spawnSkibidi(p, "Ground")
			return
		end

		spawnSkibidi(ClientEventUtils.getAnimalCFrame(p, {
			bottom = true
		}), "Ground", true)
	end)
	remoteEvent2.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Skibidi.BrainrotHit })
	end)
end

return Skibidi