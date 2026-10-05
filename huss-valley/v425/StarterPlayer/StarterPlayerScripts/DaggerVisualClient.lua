local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ParticipantDirectory = require(chickenOrHero.Presentation.ParticipantDirectory)
local DaggerConfig = require(chickenOrHero.Weapons.DaggerConfig)
local AnimationConfig = require(chickenOrHero.Animation.AnimationConfig)
local ScythePose = require(chickenOrHero.Weapons.ScythePose)
local v = {}

for k, v2 in {
	DaggerEquip = {
		looped = false,
		priority = Enum.AnimationPriority.Action2,
		grip = true,
		equip = true
	},
	DaggerHold = {
		looped = true,
		priority = Enum.AnimationPriority.Action
	},
	DaggerWindup = {
		looped = false,
		priority = Enum.AnimationPriority.Action2,
		grip = true
	},
	DaggerStab = {
		looped = false,
		priority = Enum.AnimationPriority.Action2,
		grip = true
	},
	DaggerDive = {
		looped = false,
		priority = Enum.AnimationPriority.Action3,
		grip = true,
		dive = true
	}
} do
	v[AnimationConfig.PublishedIds[k]] = v2
end

local function applyPolicy(state)
	local v2 = state.Animation and v[state.Animation.AnimationId]

	if not v2 then
		return v2
	end

	if state.Looped ~= v2.looped then
		state.Looped = v2.looped
	end

	if state.Priority ~= v2.priority then
		state.Priority = v2.priority
	end

	return v2
end

local v2 = {}
local v3 = {}
local connections = {}
local total = 1

local function restore(p)
	for _, joint in p.joints do
		if joint.motor.Parent and joint.applied and joint.motor.Transform == joint.applied then
			joint.motor.Transform = joint.base
		end

		joint.applied = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(k, p)
	restore(p)
	ScythePose.restore(p.scythe)

	if p.animationPlayed then
		p.animationPlayed:Disconnect()
	end

	v2[k] = nil
end

local function bindAnimator(state, animator)
	if state.animator == animator then
		return
	end

	if state.animationPlayed then
		state.animationPlayed:Disconnect()
	end

	state.animator = animator
	state.animationPlayed = animator.AnimationPlayed:Connect(applyPolicy)

	for _, v4 in animator:GetPlayingAnimationTracks() do
		local v5 = v4.Animation and v[v4.Animation.AnimationId]

		if not v5 then
			continue
		end

		if v4.Looped ~= v5.looped then
			v4.Looped = v5.looped
		end

		if v4.Priority ~= v5.priority then
			v4.Priority = v5.priority
		end
	end
end

table.insert(connections, RunService.PreAnimation:Connect(function()
	for _, v4 in v2 do
		restore(v4)
	end
end))
table.insert(connections, RunService.PreSimulation:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		table.clear(v3)

		for _, v4 in ParticipantDirectory.list() do
			v3[v4.UserId] = v4
			local character = v4.Character
			local equippedDagger = character and character:FindFirstChild("EquippedDagger")
			local rightArm = character and character:FindFirstChild("Right Arm")
			local torso = character and character:FindFirstChild("Torso")
			local handle = rightArm and rightArm:FindFirstChild("Handle")
			local rightShoulder = torso and torso:FindFirstChild("Right Shoulder")

			if not equippedDagger or not handle or not rightShoulder or v2[character] then
				continue
			end

			v2[character] = {
				model = equippedDagger,
				torso = torso,
				yaw = 0,
				scythe = ScythePose.new(equippedDagger),
				joints = {
					grip = {
						motor = handle
					},
					arm = {
						motor = rightShoulder
					}
				}
			}
		end
	end

	for k, v4 in v2 do
		restore(v4)

		if k.Parent and v4.model.Parent and v4.joints.grip.motor.Parent then
			local humanoid = k:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

			if humanoidRootPart and animator then
				bindAnimator(v4, animator)
				local total2 = 0
				local weightCurrent = 0
				local v5 = 0
				local daggerDrawStartedAt = k:GetAttribute("DaggerDrawStartedAt")
				local v6

				if type(daggerDrawStartedAt) == "number" then
					v6 = workspace:GetServerTimeNow() >= daggerDrawStartedAt + DaggerConfig.DrawDuration + DaggerConfig.FadeOut
				else
					v6 = false
				end

				for _, v7 in animator:GetPlayingAnimationTracks() do
					local v8 = v7.Animation and v[v7.Animation.AnimationId]

					if v8 then
						if v7.Looped ~= v8.looped then
							v7.Looped = v8.looped
						end

						if v7.Priority ~= v8.priority then
							v7.Priority = v8.priority
						end
					end

					if not v8 then
						continue
					end

					if v8.equip and k:GetAttribute("DaggerState") ~= "Drawing" and (k:GetAttribute("DaggerState") == "Stowed" or v6) and v7.WeightTarget > 0 then
						v7:Stop(DaggerConfig.FadeOut)
					end

					if v8.grip then
						total2 += v7.WeightCurrent
					end

					if not (v8.dive and v7.Length > 0) then
						continue
					end

					weightCurrent = v7.WeightCurrent
					v5 = v7.TimePosition / v7.Length
				end

				local grip = v4.joints.grip
				grip.base = grip.motor.Transform
				grip.applied = grip.base:Lerp(v4.model:GetAttribute("IdleGrip"), 1 - math.clamp(total2, 0, 1))
				grip.motor.Transform = grip.applied
				ScythePose.apply(v4.scythe, v5, weightCurrent)
				local v7

				if k == Players.LocalPlayer.Character then
					v7 = k:GetAttribute("LocalMeleeActive") == true
				else
					v7 = false
				end

				local localMeleePhase = v7 and k:GetAttribute("LocalMeleePhase") or k:GetAttribute("ReachPhase")
				local localMeleeDirection = v7 and k:GetAttribute("LocalMeleeDirection") or k:GetAttribute("ReachDirection")
				local v8 = v3[k:GetAttribute("ReachTargetUserId")]
				local humanoidRootPart2 = v8 and v8.Character and v8.Character:FindFirstChild("HumanoidRootPart")

				if localMeleePhase == "Tracking" and humanoidRootPart2 then
					localMeleeDirection = humanoidRootPart2.Position - humanoidRootPart.Position
				end

				local v9 = 0

				if k:GetAttribute("DaggerState") == "Held" and not k:GetAttribute("TackleActive") and not k:GetAttribute("MovementLocked") and (localMeleePhase == "Tracking" or localMeleePhase == "Windup" or localMeleePhase == "Active") and typeof(localMeleeDirection) == "Vector3" then
					local vector2 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
					local v10 = localMeleeDirection * createVector(1, 0, 1)

					if vector2.Magnitude > 0.01 and v10.Magnitude > 0.01 then
						v9 = math.clamp(
							math.atan2(vector2:Cross(v10).Y, (vector2:Dot(v10))),
							-math.rad(DaggerConfig.AimLimit),
							(math.rad(DaggerConfig.AimLimit))
						)
					end
				end

				v4.yaw += (v9 - v4.yaw) * (1 - math.exp(-DaggerConfig.AimRate * math.min(dt, 0.1)))

				if math.abs(v4.yaw) > 0.001 then
					local arm = v4.joints.arm
					arm.base = arm.motor.Transform
					local vectorToObjectSpace = v4.torso.CFrame:VectorToObjectSpace(createVector(0, 1, 0))
					local rotation = arm.motor.C0.Rotation
					arm.applied = rotation:Inverse() * CFrame.fromAxisAngle(vectorToObjectSpace, v4.yaw) * rotation * arm.base
					arm.motor.Transform = arm.applied
				end
			else
				ScythePose.restore(v4.scythe)
			end
		else
			remove(k, v4) -- equivalent call inferred; original call site unknown
		end
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	for k, v4 in v2 do
		remove(k, v4) -- equivalent call inferred; original call site unknown
	end
end)