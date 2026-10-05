local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CameraShakeController = require(ReplicatedStorage.Modules.Client.PlayerController.CameraShakeController)
local FreeCamController = require(ReplicatedStorage.Modules.Client.PlayerController.FreeCamController)
local v = {
	{
		Tag = "Brachiosaurus",
		WalkAnimationAssetId = "122741871158431",
		FullDistance = 40,
		StartDistance = 90,
		ShakeMagnitude = 1.1,
		ShakeRoughness = 3,
		ShakeFadeIn = 0.05,
		ShakeFadeOut = 0.45,
		ShakePositionInfluence = createVector(0.15, 0.5, 0.15),
		ShakeRotationInfluence = createVector(0.35, 0.1, 0.35)
	},
	{
		Tag = "Triceratops",
		WalkAnimationAssetId = "91734124147448",
		FullDistance = 25,
		StartDistance = 60,
		ShakeMagnitude = 0.6,
		ShakeRoughness = 3,
		ShakeFadeIn = 0.05,
		ShakeFadeOut = 0.4,
		ShakePositionInfluence = createVector(0.15, 0.5, 0.15),
		ShakeRotationInfluence = createVector(0.3, 0.1, 0.3)
	}
}
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function getModelPosition(instance)
	local primaryPart = instance.PrimaryPart

	if primaryPart == nil then
		return instance:GetPivot().Position
	end

	return primaryPart.Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function intensityFromDistanceSq(p: number, fullDistance: number, startDistance: number)
	if startDistance * startDistance <= p then
		return 0
	end

	local v2 = math.clamp(1 - (math.sqrt(p) - fullDistance) / (startDistance - fullDistance), 0, 1)
	return v2 * v2 * (3 - v2 * 2)
end

local function shakeFrom(instance, data)
	if FreeCamController.IsFreecamEnabled() then
		return
	end

	local character = localPlayer.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local modelPosition = getModelPosition(instance) -- equivalent call inferred; original call site unknown
	local v2 = humanoidRootPart.Position.X - modelPosition.X
	local v3 = humanoidRootPart.Position.Z - modelPosition.Z
	local v5 = intensityFromDistanceSq(v2 * v2 + v3 * v3, data.FullDistance, data.StartDistance) -- equivalent call inferred; original call site unknown

	if v5 <= 0 then
		return
	end

	CameraShakeController.CamShake:ShakeOnce(
		data.ShakeMagnitude * v5,
		data.ShakeRoughness,
		data.ShakeFadeIn,
		data.ShakeFadeOut,
		data.ShakePositionInfluence,
		data.ShakeRotationInfluence
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWalkTrack(object, p)
	local animation = object.Animation
	return animation ~= nil and string.find(animation.AnimationId, p.WalkAnimationAssetId, 1, true) ~= nil
end

local function bindAnimator(model, animator, p, maid)
	local v2 = {}

	local function bindTrack(object)
		if v2[object] == true then
			return
		end

		local walkTrack = isWalkTrack(object, p) -- equivalent call inferred; original call site unknown

		if walkTrack == false then
			return
		end

		v2[object] = true
		maid:Add(object:GetMarkerReachedSignal("Step"):Connect(function()
			shakeFrom(model, p)
		end))
	end

	maid:Add(animator.AnimationPlayed:Connect(bindTrack))

	for _, v3 in animator:GetPlayingAnimationTracks() do
		bindTrack(v3)
	end
end

local v2 = {}

local function addInstance(model, p)
	if not (model:IsA("Model") ~= false and v2[model] == nil) then
		return
	end

	local maid = Janitor.new()
	v2[model] = maid
	maid:Add(task.spawn(function()
		local animationController = model:WaitForChild("AnimationController")

		if animationController:IsA("AnimationController") == false then
			return
		end

		local animator = animationController:WaitForChild("Animator")

		if not (animator:IsA("Animator") ~= false and v2[model] == maid) then
			return
		end

		bindAnimator(model, animator, p, maid)
	end))
end

local function removeInstance(p)
	local v3 = v2[p]

	if v3 == nil then
		return
	end

	v3:Destroy()
	v2[p] = nil
end

local DinosaurStepShakeController = {}

function DinosaurStepShakeController.FrameworkInit() end

function DinosaurStepShakeController.FrameworkStart()
	for _, v3 in v do
		for _, v4 in CollectionService:GetTagged(v3.Tag) do
			addInstance(v4, v3)
		end

		local v4 = v3
		CollectionService:GetInstanceAddedSignal(v3.Tag):Connect(function(p)
			addInstance(p, v4)
		end)
		CollectionService:GetInstanceRemovedSignal(v3.Tag):Connect(removeInstance)
	end
end

return DinosaurStepShakeController