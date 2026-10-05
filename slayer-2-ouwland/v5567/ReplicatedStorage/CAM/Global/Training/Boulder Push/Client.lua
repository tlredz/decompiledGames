local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local BoulderPushUI = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Training.BoulderPushUI)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local maid = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	local v = maid
	maid = nil

	if v then
		v:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatten(vector2: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z))
end

local function openGates(maid2)
	for _, v in CollectionService:GetTagged("MazeGateTransparency") do
		for _, v2 in v:QueryDescendants("BasePart") do
			local transparency = v2.Transparency
			local canCollide = v2.CanCollide
			v2.Transparency = 0.6
			v2.CanCollide = false
			local v3 = v2
			maid2:Add(function()
				v3.Transparency = transparency
				v3.CanCollide = canCollide
			end)
		end
	end
end

local BoulderPush = {}

function BoulderPush.Do(p, instance, instance2, p2)
	teardown() -- equivalent call inferred; original call site unknown
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	maid:Add(Utility.AddValue(getvaluesfolder, "boulder_push"))

	if instance2:GetAttribute("WagasaRoute") then
		openGates(maid)
	end

	local parent

	if p2 and p2.Parent then
		parent = p2.Parent.Parent
	end

	local goalName = instance2:GetAttribute("GoalName")
	local child

	if not (parent == nil or goalName == nil) then
		child = parent:FindFirstChild(goalName)
	end

	local mainAt

	if child == nil then
		mainAt = nil
	else
		mainAt = child:FindFirstChild("MainAt", true)
	end

	if mainAt ~= nil then
		mainAt.Beam.Enabled = true
		mainAt.Beam1.Enabled = true
		maid:Add(function()
			mainAt.Beam.Enabled = false
			mainAt.Beam1.Enabled = false
		end)
	end

	local goalPosition = instance2:GetAttribute("GoalPosition")

	if goalPosition ~= nil then
		MarkerHandler.addMarker("boulder_push_goal", {
			markerType = MarkerHandler.markerType.Regular,
			style = "Simple",
			img = "rbxassetid://78675452486649",
			position = goalPosition + createVector(0, 3, 0),
			tag = "BoulderPushMarker"
		})
		maid:Add(function()
			MarkerHandler.removeMarker("boulder_push_goal")
		end)
	end

	maid:Add(BoulderPushUI(p.PlayerGui.ComponentsHolder, function()
		SignalEvent.ToServer("training_signaler", "Stop")
	end))
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local autoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	maid:Add(function()
		if humanoid ~= nil then
			humanoid.AutoRotate = autoRotate
		end
	end)
	local attachment = Instance.new("Attachment")
	attachment.Name = "BoulderPushMover"
	attachment.Parent = humanoidRootPart
	maid:Add(attachment)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = createVector(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = createVector(0, 0, 1)
	linearVelocity.PlaneVelocity = Vector2.zero
	linearVelocity.MaxForce = 10000
	linearVelocity.Parent = attachment
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.RigidityEnabled = false
	alignOrientation.Responsiveness = 200
	alignOrientation.MaxTorque = 10000
	alignOrientation.Parent = attachment
	local v = createVector(0, 0, 0)
	local v2 = flatten(humanoidRootPart.CFrame.LookVector) -- equivalent call inferred; original call site unknown
	local unit = not (v2.Magnitude > 0.001) and createVector(0, 0, -1) or v2.Unit
	alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), unit)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	local idle = script:FindFirstChild("Idle")
	local walk = script:FindFirstChild("Walk")
	local track

	if animator and idle then
		track = animator:LoadAnimation(idle) or nil
	else
		track = nil
	end

	local track2 = animator and walk and animator:LoadAnimation(walk) or nil

	if track then
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
	end

	if track2 then
		track2.Looped = true
		track2.Priority = Enum.AnimationPriority.Movement
	end

	maid:Add(function()
		if track then
			track:Stop(0.2)
		end

		if track2 then
			track2:Stop(0.2)
		end
	end)
	local v3 = nil
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		if humanoidRootPart.Parent == nil then
			return
		end

		local v4 = flatten(humanoid.MoveDirection) -- equivalent call inferred; original call site unknown
		local v5 = v4.Magnitude > 0.001
		local v6 = not v5 and createVector(0, 0, 0) or v4.Unit

		if v5 ~= v3 then
			v3 = v5
			SignalEvent.ToServer("training_signaler", "StateChanged", v5)

			if v5 then
				if track then
					track:Stop(0.2)
				end

				if track2 then
					track2:Play(0.2)
				end
			else
				if track2 then
					track2:Stop(0.2)
				end

				if track then
					track:Play(0.2)
				end
			end
		end

		if v5 then
			local v7 = 1 - math.exp(dt * -3)
			v = v:Lerp(v6 * 16, v7)
		else
			v = createVector(0, 0, 0)
		end

		linearVelocity.PlaneVelocity = Vector2.new(v.X, v.Z)

		if v5 then
			local v7 = 1 - math.exp(dt * -1.75)
			local lerped = unit:Lerp(v6, v7)

			if lerped.Magnitude > 0.001 then
				unit = lerped.Unit
				alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), unit)
			end
		end
	end))
end

function BoulderPush:Stop(_, _)
	teardown() -- equivalent call inferred; original call site unknown
end

return BoulderPush