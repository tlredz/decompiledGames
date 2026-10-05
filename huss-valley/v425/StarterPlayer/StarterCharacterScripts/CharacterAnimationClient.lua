local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")

if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
	return
end

local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local animation = chickenOrHero:WaitForChild("Animation")
local AnimationConfig = require(animation.AnimationConfig)
local AnimationPolicy = require(animation.AnimationPolicy)
local StopAnimationPolicy = require(animation:WaitForChild("StopAnimationPolicy"))
local DashAnimation = require(animation:WaitForChild("DashAnimation"))
require(animation:WaitForChild("DashAnimationPolicy"))
local v = StopAnimationPolicy.new()
local MovementProfiles = require(chickenOrHero.Movement:WaitForChild("MovementProfiles"))
local AnimationLibrary = require(animation.AnimationLibrary)
local v2 = AnimationLibrary.prepare()

if not (v2.Idle and v2.Walk and v2.Run) then
	return
end

local animator = humanoid:FindFirstChildOfClass("Animator")

while not animator and parent.Parent and humanoid.Health > 0 do
	task.wait(0.1)
	animator = humanoid:FindFirstChildOfClass("Animator")
end

if not (animator and parent.Parent) then
	return
end

DashAnimation.prepare(parent)
local dashAnimationSequence = parent:GetAttribute("DashAnimationSequence") or 0
local LocomotionTracks = require(animation:WaitForChild("LocomotionTracks"))
local v3 = LocomotionTracks.new(animator, v2)
local tracks = v3.tracks
local connections = {}
local v4 = true
local v5 = {
	Stop = true,
	Land = true
}
v3:refresh(os.clock())
parent:SetAttribute("AnimationPackActive", nil)
parent:SetAttribute("AnimationPackLoading", true)
local v6 = 0
local v7 = {}
local v8 = true
local total = 0
local v9 = nil
local v10 = 0
local movementReset = parent:GetAttribute("MovementReset")

-- equivalent calls inferred from this helper; original call sites unknown
local function endAction()
	if v9 and tracks[v9] then
		tracks[v9]:Stop(v9 ~= "Stop" and 0.08 or AnimationConfig.Stop.FadeOut or 0.08)
	end

	v9 = nil
	parent:SetAttribute("AnimationAction", nil)
end

local function startAction(animationAction, p, p2, value)
	local track = tracks[animationAction]

	if not LocomotionTracks.ready(track) then
		return
	end

	endAction() -- equivalent call inferred; original call site unknown
	v9 = animationAction
	v10 = os.clock() + p
	parent:SetAttribute("AnimationAction", animationAction)
	track:Play(
		animationAction ~= "Stop" and 0.07 or AnimationConfig.Stop.FadeIn or 0.07,
		value or 1,
		(p2 or track.Length) / math.max(p, 0.05)
	)
	track.TimePosition = 0
end

local function cleanup()
	if not v4 then
		return
	end

	v4 = false
	DashAnimation.release(parent)

	for _, connection in connections do
		connection:Disconnect()
	end

	v3:destroy()
	parent:SetAttribute("AnimationPackActive", nil)
	parent:SetAttribute("AnimationPackLoading", nil)
	parent:SetAttribute("AnimationAction", nil)
end

table.insert(connections, humanoid.Died:Connect(cleanup))
table.insert(connections, script.Destroying:Connect(cleanup))
table.insert(connections, RunService.PreAnimation:Connect(function(dt)
	if not (v4 and humanoidRootPart.Parent) then
		return
	end

	local v11 = math.min(dt, 0.1)
	v3:refresh(os.clock())
	local coreReady = v3:coreReady()

	if parent:GetAttribute("AnimationPackActive") ~= coreReady then
		parent:SetAttribute("AnimationPackActive", coreReady)
	end

	if parent:GetAttribute("AnimationPackLoading") == coreReady then
		parent:SetAttribute("AnimationPackLoading", not coreReady)
	end

	local v12 = MovementProfiles.get(Players.LocalPlayer:GetAttribute("GameRole"), Players.LocalPlayer)
	local magnitude = (humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
	local v13 = humanoid.FloorMaterial ~= Enum.Material.Air
	local movementState = parent:GetAttribute("MovementState") or "Idle"
	local anchored = humanoidRootPart.Anchored or parent:GetAttribute("MovementLocked") == true
	local tackleActive = parent:GetAttribute("TackleActive") == true
	local v14

	if Players.LocalPlayer:GetAttribute("GameRole") == "Runner" then
		v14 = Players.LocalPlayer:GetAttribute("RunState") == "Caught"
	else
		v14 = false
	end

	local movementReset2 = parent:GetAttribute("MovementReset")

	if movementReset2 ~= movementReset then
		movementReset = movementReset2
		endAction() -- equivalent call inferred; original call site unknown
		DashAnimation.stop(parent)
		dashAnimationSequence = parent:GetAttribute("DashAnimationSequence") or 0
		v = StopAnimationPolicy.new()
		total = 0
		v8 = v13
	end

	local dashAnimationSequence2 = parent:GetAttribute("DashAnimationSequence") or 0
	local enabled = v13 and not (anchored or tackleActive) and not (v14 or humanoid.Sit) and not humanoid.PlatformStand and v12.Dash.Enabled

	if not enabled then
		DashAnimation.stop(parent)
	end

	if dashAnimationSequence2 ~= dashAnimationSequence then
		dashAnimationSequence = dashAnimationSequence2

		if enabled and (movementState == "Boosting" or movementState == "Dashing") then
			endAction() -- equivalent call inferred; original call site unknown
			DashAnimation.play(
				parent,
				parent:GetAttribute("DashFromDirection"),
				parent:GetAttribute("DashToDirection"),
				v12.Dash
			)
		end
	end

	local active = DashAnimation.isActive(parent)
	local angle = AnimationPolicy.angle(
		humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1),
		humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	)
	local v15 = StopAnimationPolicy.step(v, {
		mode = movementState,
		speed = magnitude,
		entrySpeed = parent:GetAttribute("MovementStopEntrySpeed"),
		angle = angle,
		allowed = coreReady and not active and v13 and not anchored and not (tackleActive or v14 or humanoid.Sit or humanoid.PlatformStand),
		clipLength = tracks.Stop and tracks.Stop.Length or 0,
		now = os.clock()
	}, v11, AnimationConfig.Stop, v12)
	local v16

	if parent:GetAttribute("Ragdolled") or not coreReady or humanoid.Sit or humanoid.PlatformStand then
		v16 = {}
		endAction() -- equivalent call inferred; original call site unknown
	elseif tackleActive then
		v16 = {
			Idle = 1
		}
		endAction() -- equivalent call inferred; original call site unknown
	elseif v14 then
		v16 = tracks.CaughtIdle and tracks.CaughtIdle.Length > 0 and {
			CaughtIdle = 1
		} or {
			Idle = 1
		}
		endAction() -- equivalent call inferred; original call site unknown
		total = 0
	elseif anchored then
		v16 = {
			Idle = 1
		}
		endAction() -- equivalent call inferred; original call site unknown
	elseif v13 then
		v16 = AnimationPolicy.weights(magnitude, angle, v12.MaxSpeed, AnimationConfig)

		if active then
			endAction() -- equivalent call inferred; original call site unknown
		elseif v8 or not (total > 0.15) or tackleActive then
			if v15 then
				startAction("Stop", v15.duration, v15.clipEnd, v15.weight)
			end
		else
			startAction("Land", 0.25)
		end

		total = 0
	else
		total += v11
		v16 = {
			Fall = 1
		}
		endAction() -- equivalent call inferred; original call site unknown
	end

	if v9 then
		local now = os.clock()

		if v10 <= now or tackleActive or v9 == "Stop" and movementState ~= "Braking" and movementState ~= "Idle" then
			endAction() -- equivalent call inferred; original call site unknown
		end
	end

	local weights = v3:weights(v16)
	local v17 = math.clamp(
		(magnitude / v12.MaxSpeed - AnimationConfig.RunBlendStart) / (AnimationConfig.RunBlendEnd - AnimationConfig.RunBlendStart),
		0,
		1
	)
	local v18 = math.clamp(
		magnitude / math.max(
			AnimationConfig.WalkReferenceSpeed * (1 - v17) + AnimationConfig.RunReferenceSpeed * v2.Run.length * v17,
			1
		),
		0.25,
		3
	)
	v6 = (v6 + v18 * v11) % 1

	for k, track in tracks do
		if v5[k] or not LocomotionTracks.ready(track) then
			continue
		end

		local v19 = weights[k] or 0
		local fadeTime = k == "CaughtIdle" and AnimationConfig.CaughtIdle.FadeTime or AnimationConfig.FadeTime

		if v19 > 0.001 then
			if track.IsPlaying and not (track.WeightTarget <= 0.001) then
				if math.abs(track.WeightTarget - v19) > 0.01 then
					track:AdjustWeight(v19, fadeTime)
				end
			else
				track:Play(fadeTime, v19, 1)

				if k ~= "Idle" and k ~= "Fall" and k ~= "CaughtIdle" then
					track.TimePosition = v6 * track.Length
				end
			end

			v7[k] = v19
		else
			if track.IsPlaying and track.WeightTarget > 0.001 then
				track:Stop(fadeTime)
			end

			v7[k] = 0
		end

		if k == "CaughtIdle" then
			track:AdjustSpeed(AnimationConfig.CaughtIdle.PlaybackRate)
		elseif k == "Idle" or k == "Fall" then
			track:AdjustSpeed(1)
		elseif k == "Walk" or k == "Run" then
			track:AdjustSpeed(v18 * math.max(track.Length, 0.1))
		else
			track:AdjustSpeed((math.clamp(magnitude / AnimationConfig.DirectionalReferenceSpeed, 0.5, 2.2)))
		end
	end

	v8 = v13
end))