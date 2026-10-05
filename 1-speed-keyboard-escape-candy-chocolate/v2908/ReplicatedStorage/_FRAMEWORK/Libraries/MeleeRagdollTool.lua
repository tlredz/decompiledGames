local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local Ragdoll = require(script.Ragdoll)
local Reward = require(script.Reward)
require(script.Types)
local v = { "Handle" }
local v2 = {
	"HumanoidRootPart",
	"Head",
	"Torso",
	"UpperTorso"
}

local function checkGripped(parent, p)
	local rightArm = parent:FindFirstChild("Right Arm") or parent:FindFirstChild("RightHand")
	local rightGrip

	if rightArm then
		rightGrip = rightArm:FindFirstChild("RightGrip")
	end

	return rightArm ~= nil and rightGrip ~= nil and rightGrip:IsA("Motor6D") and (rightGrip.Part0 == p or rightGrip.Part1 == p)
end

local function checkMeleeHit(instance, handle, instance2, data, p: number, now: number)
	local parent = instance.Parent
	local model = instance2:FindFirstAncestorOfClass("Model")
	local playerFromCharacter

	if model then
		playerFromCharacter = Players:GetPlayerFromCharacter(model)
	end

	local playerFromCharacter2

	if parent then
		playerFromCharacter2 = Players:GetPlayerFromCharacter(parent)
	end

	if not parent or not parent:IsA("Model") or not playerFromCharacter or not playerFromCharacter2 or model == parent then
		return false, nil
	end

	if now - p < data.swingCooldownSeconds then
		return false, nil
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoid2 = model:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart2 = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or not humanoid2 or humanoid2.Health <= 0 or not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
		return false, nil
	end

	if not checkGripped(parent, handle) or data.preventFriendlyFire and not playerFromCharacter2.Neutral and not playerFromCharacter.Neutral and playerFromCharacter2.TeamColor == playerFromCharacter.TeamColor then
		return false, nil
	end

	return true, {
		attacker = playerFromCharacter2,
		target = playerFromCharacter,
		attackerRoot = humanoidRootPart,
		targetHumanoid = humanoid2,
		targetRoot = humanoidRootPart2
	}
end

local function bladeHitBox(handle)
	local size = handle.Size
	local vector2 = Vector3.new(math.max(size.X, 2), math.max(size.Y, 2), (math.max(size.Z, 2)))
	local vector3

	if size.X >= size.Y and size.X >= size.Z then
		vector3 = Vector3.new(math.max(size.X, 8), vector2.Y, vector2.Z)
	elseif size.Y >= size.X and size.Y >= size.Z then
		vector3 = Vector3.new(vector2.X, math.max(size.Y, 8), vector2.Z)
	else
		vector3 = Vector3.new(vector2.X, vector2.Y, (math.max(size.Z, 8)))
	end

	return handle.CFrame, vector3 + createVector(2, 2, 2)
end

local function pointInBox(vector2: Vector3, cframe: CFrame, vector3: Vector3)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector2)
	local v3 = vector3 * 0.5
	return math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Y) <= v3.Y and math.abs(pointToObjectSpace.Z) <= v3.Z
end

local function characterOverlapsBlade(character, cframe: CFrame, vector2: Vector3)
	for _, childName in v2 do
		local part = character:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local pointToObjectSpace = cframe:PointToObjectSpace(part.Position)
		local v3 = vector2 * 0.5
		local v4

		if math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Y) <= v3.Y then
			v4 = math.abs(pointToObjectSpace.Z) <= v3.Z
		else
			v4 = false
		end

		if v4 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(soundId: string, volume: number, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 4)
end

local function getAnimator(parent)
	local animator = parent:FindFirstChildOfClass("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = parent
	return animator2
end

local function loadTrack(animator, parent, name: string, animationId: string)
	local v3 = parent:FindFirstChild(name)

	if v3 and v3:IsA("Animation") then
		return animator:LoadAnimation(v3)
	end

	v3 = Instance.new("Animation")
	v3.Name = name
	v3.AnimationId = animationId
	v3.Parent = parent
	return animator:LoadAnimation(v3)
end

local MeleeRagdollTool = {}

function MeleeRagdollTool.createWinReward(p: string, p2: number?)
	return Reward.create(p, p2)
end

function MeleeRagdollTool.fling(p, p2, p3, p4, p5)
	assert(RunService:IsServer(), "MeleeRagdollTool.fling is server-only")
	Ragdoll.apply(p, p2, p3, p4, p5)
end

function MeleeRagdollTool.attach(instance, data)
	assert(RunService:IsServer(), "MeleeRagdollTool.attach is server-only")
	local handle = instance:WaitForChild("Handle")
	local grip = instance.Grip
	local create = Reward.create
	local rewardSource = data.rewardSource
	local v3

	if data.reward then
		v3 = data.reward.multiplier
	end

	local v4 = create(rewardSource, v3)
	local soundVolume = data.soundVolume or 1
	local bladePartNames = data.bladePartNames or v
	local maid = Janitor.new()
	local flag = false
	local flag2 = false
	local v5 = 0
	local v6 = 0
	local v7 = nil

	local function playSwingAnimation(flag3: boolean)
		local parent = instance.Parent
		local humanoid

		if parent then
			humanoid = parent:FindFirstChildOfClass("Humanoid")
		end

		local lungeAnimationId

		if flag3 then
			lungeAnimationId = data.lungeAnimationId
		else
			lungeAnimationId = data.slashAnimationId
		end

		if not humanoid or not lungeAnimationId or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
			return
		end

		if v7 then
			v7:Stop(0)
		end

		local v9 = humanoid:FindFirstChildOfClass("Animator")

		if not v9 then
			v9 = Instance.new("Animator")
			v9.Parent = humanoid
		end

		local v10 = loadTrack(v9, instance, flag3 and "MeleeRagdollLunge" or "MeleeRagdollSlash", lungeAnimationId)
		v10:Play(0)
		v7 = v10
	end

	local function playLunge()
		flag2 = true
		playSwingAnimation(true)

		if data.lungeSoundId then
			playSound(data.lungeSoundId, soundVolume, handle) -- equivalent call inferred; original call site unknown
		end

		if data.lungeGrip then
			instance.Grip = data.lungeGrip
		end

		task.delay(data.lungeDurationSeconds or 0.6, function()
			flag2 = false
			instance.Grip = grip
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playSlash()
		playSwingAnimation(false)

		if data.swingSoundId then
			playSound(data.swingSoundId, soundVolume, handle) -- equivalent call inferred; original call site unknown
		end
	end

	local function onActivated()
		if not flag then
			return
		end

		local now = os.clock()

		if data.lungeAnimationId and now - v5 < (data.lungeComboWindowSeconds or 0.2) then
			playLunge()
		else
			playSlash() -- equivalent call inferred; original call site unknown
		end

		v5 = now
	end

	local function onEquipped()
		flag = true

		if data.unsheathSoundId then
			playSound(data.unsheathSoundId, soundVolume, handle) -- equivalent call inferred; original call site unknown
		end
	end

	local function onUnequipped()
		flag = false
		flag2 = false
		instance.Grip = grip
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyBossDamage(parent, bossDamage)
		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			local v8

			if flag2 then
				v8 = bossDamage.lungeDamage
			else
				v8 = bossDamage.slashDamage
			end

			humanoid:TakeDamage(v8)
		end
	end

	local function onBladeTouched(humanoidRootPart)
		if flag then
			local bossDamage = data.bossDamage
			local parent = humanoidRootPart.Parent

			if bossDamage and parent and parent:HasTag(bossDamage.tag) then
				applyBossDamage(parent, bossDamage) -- equivalent call inferred; original call site unknown
			else
				local now = os.clock()
				local v8, v9 = checkMeleeHit(instance, handle, humanoidRootPart, data, v6, now)

				if v8 then
					v6 = now
					Ragdoll.apply(v9.target, v9.attackerRoot, v9.targetRoot, v9.targetHumanoid, data.fling)
					v4(v9.attacker)
				end
			end
		end
	end

	local function scanEquippedHits()
		if flag then
			local v8, v9 = bladeHitBox(handle)

			for _, v10 in Players:GetPlayers() do
				local character = v10.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart") and characterOverlapsBlade(
					character,
					v8,
					v9
				)) then
					continue
				end

				onBladeTouched(humanoidRootPart)
			end
		end
	end

	handle.CanTouch = true
	maid:Add(instance.Activated:Connect(onActivated))
	maid:Add(instance.Equipped:Connect(onEquipped))
	maid:Add(instance.Unequipped:Connect(onUnequipped))
	maid:Add(RunService.Heartbeat:Connect(scanEquippedHits))

	for _, childName in bladePartNames do
		local part = instance:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		part.CanTouch = true
		maid:Add(part.Touched:Connect(onBladeTouched))
	end

	return {
		destroy = function()
			maid:Cleanup()
		end
	}
end

return MeleeRagdollTool