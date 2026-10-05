local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local _ = {
	BASE_DETECTION_SIZE = createVector(2.5, 5, 2.5),
	LERP_SPEED_DOWN = 20,
	LERP_SPEED_UP = 8,
	HOLD_TIME = 0.15,
	VELOCITY_PADDING = 1.2,
	SOUND_COOLDOWN = 0.03
}
local v = {
	MusicalKey = {
		PRESS_DEPTH = 1.4
	},
	MusicalKey2 = {
		PRESS_DEPTH = 1
	},
	FlatKey = {
		PRESS_DEPTH = 0.15
	}
}
local v2 = {}
local v3 = {}
local v4 = 0
local SoundPacks = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("SoundPacks"))
local keyVolume = localPlayer:GetAttribute("KeyVolume") or 1
local attribute = localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME) or SoundPacks.DEFAULT_SOUND
local random = Random.new()
local v5 = table.create(40)
local v6 = 1

for i = 1, 40 do
	local sound = Instance.new("Sound")
	sound.RollOffMaxDistance = 100
	sound.RollOffMinDistance = 10
	v5[i] = sound
end

localPlayer:GetAttributeChangedSignal("KeyVolume"):Connect(function()
	keyVolume = localPlayer:GetAttribute("KeyVolume") or 1
end)
localPlayer:GetAttributeChangedSignal(SoundPacks.ATTRIBUTE_NAME):Connect(function()
	attribute = localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME) or SoundPacks.DEFAULT_SOUND
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function playKeySound(parent)
	if keyVolume <= 0 then
		return
	end

	local randomAsset = SoundPacks.PickRandomAsset(SoundPacks.ResolveSoundAssets(attribute), random)
	local v7 = v5[v6]
	v6 = v6 % 40 + 1
	v7.SoundId = randomAsset.assetId
	v7.Volume = keyVolume * randomAsset.volume
	v7.Parent = parent
	v7:Play()
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams:AddToFilter(workspace:WaitForChild("Keycaps"))

-- equivalent calls inferred from this helper; original call sites unknown
local function getMusicType(instance)
	return v[instance:GetAttribute("MusicType")] or v.MusicalKey
end

local KeycapStreamConfig = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("KeycapsRendering"):WaitForChild("KeycapStreamConfig"))
local KeycapPoolRenderer = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("KeycapsRendering"):WaitForChild("KeycapPoolRenderer"))
local positionAttributeName = KeycapStreamConfig.PositionAttributeName
local rotationAttributeName = KeycapStreamConfig.RotationAttributeName

local function clearReturnedKeyState(list)
	for _, v7 in ipairs(list) do
		v2[v7] = nil
		v3[v7] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restCFrameFromAttributes(instance)
	local attribute2 = instance:GetAttribute(positionAttributeName)
	local attribute3 = instance:GetAttribute(rotationAttributeName)

	if typeof(attribute2) == "Vector3" and typeof(attribute3) == "CFrame" then
		return attribute3 + attribute2
	end

	return instance.CFrame
end

KeycapPoolRenderer.ReturnedToPool:Connect(clearReturnedKeyState)
RunService.RenderStepped:Connect(function(dt: number)
	local now = os.clock()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local v7 = createVector(2.5, 5, 2.5) + Vector3.new(
			math.abs(assemblyLinearVelocity.X) * dt * 1.2,
			0,
			math.abs(assemblyLinearVelocity.Z) * dt * 1.2
		)
		local partBoundsInBox = workspace:GetPartBoundsInBox(
			humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
			v7,
			overlapParams
		)

		for _, v8 in ipairs(partBoundsInBox) do
			local musicType = getMusicType(v8) -- equivalent call inferred; original call site unknown
			local v9 = v3[v8]

			if not v9 then
				local originalCF = restCFrameFromAttributes(v8) -- equivalent call inferred; original call site unknown
				v9 = {
					originalCF = originalCF,
					currentAlpha = 0,
					targetAlpha = 0,
					lastHit = 0,
					pressDepth = musicType.PRESS_DEPTH
				}
				v3[v8] = v9
			end

			if v9.targetAlpha == 0 and now - v4 >= 0.03 then
				playKeySound(v8) -- equivalent call inferred; original call site unknown
				v4 = now
			end

			v9.targetAlpha = 1
			v9.lastHit = now
			v2[v8] = true
		end
	end

	local v7 = {}
	local originalCFs = {}

	for k, _ in pairs(v2) do
		local v8 = v3[k]

		if k.Parent and v8 then
			if now - v8.lastHit > 0.15 then
				v8.targetAlpha = 0
			end

			local v9 = v8.targetAlpha == 1 and 20 or 8
			v8.currentAlpha += (v8.targetAlpha - v8.currentAlpha) * math.clamp(dt * v9, 0, 1)
			local v10

			if v8.targetAlpha == 0 then
				v10 = v8.currentAlpha < 0.01
			else
				v10 = false
			end

			local originalCF = v10 and v8.originalCF or v8.originalCF * CFrame.new(
				0,
				-v8.currentAlpha * v8.pressDepth,
				0
			)

			if v10 then
				v8.currentAlpha = 0
				v2[k] = nil
				v3[k] = nil
			end

			table.insert(v7, k)
			table.insert(originalCFs, originalCF)
		else
			v2[k] = nil
			v3[k] = nil
		end
	end

	workspace:BulkMoveTo(v7, originalCFs)
end)