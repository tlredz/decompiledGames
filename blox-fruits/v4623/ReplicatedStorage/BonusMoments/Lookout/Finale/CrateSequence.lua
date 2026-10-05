local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
local DynamicFace = require(script.Parent.Parent.DynamicFace)
local Effect = require(ReplicatedStorage.Effect)
local Scene = require(script.Parent.Parent.Scene)
local CutsceneDialogue = require(script.Parent.CutsceneDialogue)
local Deck = require(script.Parent.Deck)
local FailureSequence = require(script.Parent.FailureSequence)
local FailureTemplates = require(script.Parent.FailureTemplates)
local Props = require(script.Parent.Props)
local Timing = require(script.Parent.Timing)
require(script.Parent.Types)
local frozen = table.freeze({
	FollowerDragonSequenceEnabled = false,
	CrateDownShakeCount = 4,
	CrateDownShakeDistance = 0.3,
	CrateFruitReleaseAlpha = 0.9375,
	CrateTossArcHeight = 6,
	CrateTossBackDistance = 14,
	CrateTossFallSpeed = 6,
	CrateTossSpinSpeed = 3,
	CrateThrowHandReleaseAlpha = 0.34,
	CrateThrowHandFadeAlpha = 0.16,
	FollowerDragonHybridScale = 1.5,
	FollowerCameraTargetHeight = 2.8,
	FollowerCameraTrackingDamping = 0.85,
	FollowerCrateHoldHeight = 3,
	FollowerCrateCarryDistance = 5,
	FollowerCrateCarryLeftDistance = 2.5,
	FollowerShakeTurnTowardMarines = 0.25,
	SuccessCrateOpenerFaceId = "962",
	WorriedMarineFaceId = "240277183139860",
	WorriedFallbackFaceId = "48847223322759"
})
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}

function v.waitForFailureItemsLanding(data, p, p2: number)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p2 and data.canContinue(currentDialogueBeat) do
		local flag = true

		for _, fruitJump in p.FruitJumps do
			if not fruitJump.Released or (fruitJump.Grabbed or fruitJump.HasLanded) then
				continue
			end

			flag = false
			break
		end

		if flag then
			return true
		else
			total += RunService.Heartbeat:Wait()
		end
	end

	return data.isLive()
end

function v.waitForAnimationStopped(data, object)
	local v3 = not object.IsPlaying
	local currentDialogueBeat = data.currentDialogueBeat()
	local stoppedConnection = object.Stopped:Connect(function()
		v3 = true
	end)

	while not v3 and object.IsPlaying and data.canContinue(currentDialogueBeat) do
		RunService.Heartbeat:Wait()
	end

	stoppedConnection:Disconnect()

	if data.isLive() and object.IsPlaying then
		object:Stop(0)
	end

	return data.isLive()
end

function v.applyWorriedFace(p)
	if DynamicFace.playExpression(p, frozen.WorriedMarineFaceId) then
		return
	end

	if not (DynamicFace.applyHead(p, frozen.WorriedMarineFaceId) and DynamicFace.playExpression(
		p,
		frozen.WorriedMarineFaceId
	)) then
		CharacterPresentation.setFace(p, frozen.WorriedFallbackFaceId)
		warn("[Lookout] The crate-opening marine could not apply its worried dynamic face")
	end
end

function v.getHeldCrateCFrame(p, p2, vector2: Vector3, cframe: CFrame)
	local v3 = Scene.flattenedUnit(vector2) or createVector(0, 0, 1)
	local pivot = p2.Marine:GetPivot()
	local v4 = math.clamp(p.Size.Z * 0.5 + 0.65, 1.25, 2.4)
	local v5 = pivot.Position + v3 * v4 + createVector(0, 1, 0) * frozen.FollowerCrateHoldHeight
	return CFrame.lookAt(v5, v5 + v3) * cframe * p.CenterOffset:Inverse()
end

function v.createIKTarget(parent, name: string, position: Vector3)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Parent = parent
	return part
end

function v.createPositionIK(parent, name: string, chainRoot, endEffector, target, pole, priority: number, smoothTime: number)
	local iKControl = Instance.new("IKControl")
	iKControl.Name = name
	iKControl.Type = Enum.IKControlType.Position
	iKControl.ChainRoot = chainRoot
	iKControl.EndEffector = endEffector
	iKControl.Target = target
	iKControl.Pole = pole
	iKControl.Priority = priority
	iKControl.SmoothTime = smoothTime
	iKControl.Weight = 1
	iKControl.Parent = parent
	return iKControl
end

function v.createCrateHandIK(p, p2, vector2: Vector3)
	local humanoid = p.Marine:FindFirstChildWhichIsA("Humanoid")
	local leftHand = p.Marine:FindFirstChild("LeftHand", true) or p.Marine:FindFirstChild("Left Arm", true)
	local rightHand = p.Marine:FindFirstChild("RightHand", true) or p.Marine:FindFirstChild("Right Arm", true)
	local leftUpperArm = p.Marine:FindFirstChild("LeftUpperArm", true) or p.Marine:FindFirstChild("Left Arm", true)
	local rightUpperArm = p.Marine:FindFirstChild("RightUpperArm", true) or p.Marine:FindFirstChild("Right Arm", true)

	if not (humanoid and leftHand and leftHand:IsA("BasePart") and rightHand and rightHand:IsA("BasePart") and leftUpperArm and leftUpperArm:IsA("BasePart") and rightUpperArm and rightUpperArm:IsA("BasePart")) then
		return nil
	end

	local iKTarget = v.createIKTarget(p2, "LookoutCrateLeftHandTarget", leftHand.Position)
	local iKTarget2 = v.createIKTarget(p2, "LookoutCrateRightHandTarget", rightHand.Position)
	local gripRight = Scene.flattenedUnit(p.Marine:GetPivot().RightVector) or createVector(1, 0, 0)
	local facing = Scene.flattenedUnit(vector2) or createVector(0, 0, 1)
	local iKTarget3 = v.createIKTarget(p2, "LookoutCrateLeftElbowPole", leftHand.Position - gripRight * 2)
	local iKTarget4 = v.createIKTarget(p2, "LookoutCrateRightElbowPole", rightHand.Position + gripRight * 2)
	return {
		LeftTarget = iKTarget,
		RightTarget = iKTarget2,
		LeftPole = iKTarget3,
		RightPole = iKTarget4,
		LeftControl = v.createPositionIK(
			humanoid,
			"LookoutCrateLeftHandIK",
			leftUpperArm,
			leftHand,
			iKTarget,
			iKTarget3,
			200,
			Timing.Shared.CrateHandIKSmoothTime
		),
		RightControl = v.createPositionIK(
			humanoid,
			"LookoutCrateRightHandIK",
			rightUpperArm,
			rightHand,
			iKTarget2,
			iKTarget4,
			200,
			Timing.Shared.CrateHandIKSmoothTime
		),
		GripRight = gripRight,
		Facing = facing
	}
end

function v.updateCrateHandIK(data, p, cframe: CFrame)
	local v3 = cframe * p.CenterOffset
	local v4 = math.clamp(p.Size.X * 0.45, 0.7, 2.2)
	local v5 = math.clamp(p.Size.Z * 0.3, 0.25, 1)
	local v6 = v3.Position - data.Facing * v5
	data.LeftTarget.CFrame = CFrame.new(v6 - data.GripRight * v4)
	data.RightTarget.CFrame = CFrame.new(v6 + data.GripRight * v4)
	local v7 = v6 - data.Facing * 0.45 + createVector(0, 0.35, 0)
	local v8 = v4 + 1.75
	data.LeftPole.CFrame = CFrame.new(v7 - data.GripRight * v8)
	data.RightPole.CFrame = CFrame.new(v7 + data.GripRight * v8)
end

function v.destroyCrateHandIK(data)
	if not data then
		return
	end

	data.LeftControl:Destroy()
	data.RightControl:Destroy()
	data.LeftTarget:Destroy()
	data.RightTarget:Destroy()
	data.LeftPole:Destroy()
	data.RightPole:Destroy()
end

function v.animateFruitCrateCFrame(data, p, cframe: CFrame, cframe2: CFrame, p2: number)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p2 and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v3 = math.clamp(total / p2, 0, 1)
		local v4 = v3 * v3 * (3 - v3 * 2)
		Props.syncFruitCrate(p, cframe:Lerp(cframe2, v4))
	end

	if not data.isLive() then
		return false
	end

	Props.syncFruitCrate(p, cframe2)
	return true
end

function v.animateFruitCrateInversion(data, p, p2, vector2: Vector3, p3, p4: number)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p4 and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v3 = math.clamp(total / p4, 0, 1)
		local v4 = v3 * v3 * (3 - v3 * 2)
		local cframe = CFrame.Angles(3.141592653589793 * v4, 0, 0)
		local heldCrateCFrame = v.getHeldCrateCFrame(p, p2, vector2, cframe)
		Props.syncFruitCrate(p, heldCrateCFrame)

		if p3 then
			v.updateCrateHandIK(p3, p, heldCrateCFrame)
		end
	end

	if not data.isLive() then
		return false
	end

	local heldCrateCFrame = v.getHeldCrateCFrame(p, p2, vector2, CFrame.Angles(3.141592653589793, 0, 0))
	Props.syncFruitCrate(p, heldCrateCFrame)

	if p3 then
		v.updateCrateHandIK(p3, p, heldCrateCFrame)
	end

	return true
end

function v.tossEmptyCrate(data, p, cframe: CFrame, p2, p3: number)
	local pivot = p.Crate:GetPivot()
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p3 and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v3 = math.clamp(total / p3, 0, 1)
		local v4 = createVector(0, 1, 0) * (math.sin(v3 * 3.141592653589793) * frozen.CrateTossArcHeight)
		local cframe2 = CFrame.Angles(v3 * 3.141592653589793 * 2, v3 * 3.141592653589793 * 2, 0)
		local v5 = (pivot:Lerp(cframe, v3) + v4) * cframe2
		p.Crate:PivotTo(v5)

		if not p2 then
			continue
		end

		if v3 <= frozen.CrateThrowHandReleaseAlpha then
			v.updateCrateHandIK(p2, p, v5)
			p2.LeftControl.Weight = 1
			p2.RightControl.Weight = 1
		else
			local v6 = math.clamp((v3 - frozen.CrateThrowHandReleaseAlpha) / frozen.CrateThrowHandFadeAlpha, 0, 1)
			p2.LeftControl.Weight = 1 - v6
			p2.RightControl.Weight = 1 - v6
		end
	end

	if not data.isLive() then
		return false
	end

	p.Crate:PivotTo(cframe)
	local primaryPart = p.Crate.PrimaryPart or p.Crate:FindFirstChildWhichIsA("BasePart", true)

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		return true
	end

	for _, part in p.Crate:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false

		if part == primaryPart then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "LookoutThrownCrateWeld"
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
	end

	for _, part in p.Crate:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	local v3 = (cframe.Position - pivot.Position) * createVector(1, 0, 1)
	primaryPart.AssemblyLinearVelocity = (not (v3.Magnitude > 0.001) and createVector(0, 0, 0) or v3.Unit) * frozen.CrateTossFallSpeed - createVector(
		0,
		1,
		0
	) * frozen.CrateTossFallSpeed
	primaryPart.AssemblyAngularVelocity = Vector3.new(
		frozen.CrateTossSpinSpeed,
		frozen.CrateTossSpinSpeed * 0.65,
		frozen.CrateTossSpinSpeed * 0.4
	)
	return true
end

function v.pickUpFruitWithIK(p, p2, p3, p4)
	local humanoid = p3.Marine:FindFirstChildWhichIsA("Humanoid")
	local rightHand = p3.Marine:FindFirstChild("RightHand", true) or p3.Marine:FindFirstChild("Right Arm", true)
	local rightUpperArm = p3.Marine:FindFirstChild("RightUpperArm", true) or p3.Marine:FindFirstChild(
		"UpperTorso",
		true
	) or p3.Marine:FindFirstChild("Torso", true)

	if not (humanoid and rightHand and rightHand:IsA("BasePart") and rightUpperArm and rightUpperArm:IsA("BasePart")) then
		return nil
	end

	local parent = p2.Crate.Parent

	if not parent then
		return nil
	end

	local iKTarget = v.createIKTarget(parent, "LookoutFruitIKTarget", p4.Root.Position)
	local pivot = p3.Marine:GetPivot()
	local v3 = pivot.Position + pivot.RightVector * 2.5 + createVector(0, 1, 0) - pivot.LookVector * 0.5
	local iKTarget2 = v.createIKTarget(parent, "LookoutFruitElbowPole", v3)
	local positionIK = v.createPositionIK(
		humanoid,
		"LookoutFruitPickupIK",
		rightUpperArm,
		rightHand,
		iKTarget,
		iKTarget2,
		100,
		Timing.Success.FruitPickupIKSmoothTime
	)

	if p.wait(Timing.Success.FruitPickupReachTime) then
		local parent2 = p4.Root.Parent

		if parent2 and parent2:IsA("Model") then
			p4.Root.CanCollide = false
			p4.Root.CFrame = rightHand.CFrame
			p4.Root.Anchored = false
			p4.Grabbed = true
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "LookoutHeldFruitWeld"
			weldConstraint.Part0 = rightHand
			weldConstraint.Part1 = p4.Root
			weldConstraint.Parent = p4.Root
			positionIK.Weight = 0
			positionIK:Destroy()
			iKTarget:Destroy()
			iKTarget2:Destroy()
			return parent2
		end
	end

	positionIK:Destroy()
	iKTarget:Destroy()
	iKTarget2:Destroy()
	return nil
end

function v.eatFruit(p, p2, instance)
	local v3 = CharacterPresentation.playEat(p2)

	if not v3 then
		return false
	end

	local v4 = p.wait(Timing.Success.FollowerEatTime)

	if instance.Parent then
		instance:Destroy()
	end

	Deck.stopAnimationTrack(v3)
	return v4
end

function v.playDragonHybridV(p, p2, p3)
	local marine = p3.Marine
	local humanoidRootPart = marine:FindFirstChild("HumanoidRootPart", true)
	local humanoid = marine:FindFirstChildWhichIsA("Humanoid")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		return false
	end

	local v3 = marine:FindFirstChild("Rage")

	if not (v3 and v3:IsA("NumberValue")) then
		if v3 then
			v3:Destroy()
		end

		v3 = Instance.new("NumberValue")
		v3.Name = "Rage"
		v3.Parent = marine
	end

	v3.Value = 50

	if not (pcall(function()
		Effect.new("Dragon2.Hybrid.Transform"):play({
			ID = 1,
			Root = humanoidRootPart,
			player = localPlayer
		})
	end) and p.wait(Timing.Success.DragonTransformWaitTime)) then
		return false
	end

	local floorPos = marine:GetAttribute("FloorPos")

	if typeof(floorPos) ~= "Vector3" then
		floorPos = Deck.getSurfacePosition(p2.Ship, marine:GetPivot().Position)
	end

	local v4 = Scene.flattenedUnit(marine:GetPivot().LookVector) or -p2.Forward

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyScale(p4: number)
		marine:ScaleTo(1 + (frozen.FollowerDragonHybridScale - 1) * p4)
		local standingCFrame = Deck.calculateStandingCFrame(marine, floorPos, v4)
		marine:PivotTo(standingCFrame)
		p3.StandingHeight = standingCFrame.Position.Y - floorPos.Y
	end

	local total = 0

	while total < Timing.Success.DragonScaleTime and p.isLive() do
		total += RunService.Heartbeat:Wait()
		applyScale(math.clamp(total / Timing.Success.DragonScaleTime, 0, 1)) -- equivalent call inferred; original call site unknown
	end

	if not p.isLive() then
		return false
	end

	applyScale(1) -- equivalent call inferred; original call site unknown
	marine:SetAttribute("FloorPos", floorPos)

	if not pcall(function()
		Effect.new("Dragon2.Hybrid.State"):play({
			ID = 1,
			Character = marine,
			Scaler = frozen.FollowerDragonHybridScale,
			player = localPlayer
		})
	end) then
		return false
	end

	if not marine:FindFirstChild("DragonHybrid") then
		local folder = Instance.new("Folder")
		folder.Name = "DragonHybrid"
		folder.Parent = marine
	end

	if CharacterPresentation.playDragonHybridIdle(marine, 1) then
		return p.wait(Timing.Success.DragonPostTransformHoldTime)
	end

	return false
end

function v2.run(data, data2, object, vector2: Vector3, p, p2, p3, p4, p5)
	local v3

	if p == "Failure" then
		v3 = FailureTemplates.get(assert(p2))
	end

	local follower = data2.Follower
	local pickupFeet = data2.PickupFeet

	if not (follower and pickupFeet) then
		warn("[Lookout] The finale fruit crate has no assigned follower marine")
		return false
	end

	local v4 = follower.Path[#follower.Path]

	local function followerFocus()
		local head = follower.Marine:FindFirstChild("Head", true)

		if head and head:IsA("BasePart") then
			return head.Position + createVector(0, 0.1, 0)
		end

		return follower.Marine:GetPivot().Position + createVector(0, 1, 0) * frozen.FollowerCameraTargetHeight
	end

	local v5 = object:SetCameraTarget(followerFocus)
	v5:SetPositionLocked(true)
	v5:SetTrackingSpring(frozen.FollowerCameraTrackingDamping, Timing.Shared.FollowerCameraTrackingFrequency)
	local v6 = (v4 - pickupFeet):Dot(data2.Right) < 0 and -1 or 1
	local surfacePosition = Deck.getSurfacePosition(
		data2.Ship,
		pickupFeet + data2.Right * v6 * 1.6 + data2.Forward * 1.6
	)
	local v7 = data2.GroundCFrame.Position - pickupFeet
	local subpath = Deck.createSubpath(follower, { v4, surfacePosition, pickupFeet }, v7)
	local v8 = CharacterPresentation.playWalk(follower.Marine)

	if not Deck.animateSubpath(data, subpath, Timing.Shared.CrateApproachTime, v8) then
		return false
	end

	follower.Marine:SetAttribute("FloorPos", pickupFeet)
	Deck.stopAnimationTrack(follower.CombatIdleTrack)
	follower.CombatIdleTrack = nil
	CharacterPresentation.hideWeapon(follower.Marine)
	CharacterPresentation.playIdle(follower.Marine)
	CutsceneDialogue.showFollowerInspecting(data)

	if not data.wait(Timing.Shared.FollowerInspectDialogueHoldTime) then
		return false
	end

	local v9 = CharacterPresentation.playCrateHold(follower.Marine)

	if not v9 then
		warn("[Lookout] The follower marine could not play the two-handed treasure hold")
	end

	local heldCrateCFrame = v.getHeldCrateCFrame(data2, follower, v7, CFrame.identity)

	if not v.animateFruitCrateCFrame(
		data,
		data2,
		data2.Crate:GetPivot(),
		heldCrateCFrame,
		Timing.Shared.CratePickupTime
	) then
		return false
	end

	local pivot = follower.Marine:GetPivot()
	local v10 = Scene.flattenedUnit(pivot.LookVector) or Scene.flattenedUnit(v7) or -data2.Forward
	local parent = data2.Crate.Parent
	local v11

	if parent then
		v11 = v.createCrateHandIK(follower, parent, v10)
	end

	if v11 then
		v.updateCrateHandIK(v11, data2, data2.Crate:GetPivot())
	end

	local surfacePosition2 = Deck.getSurfacePosition(
		data2.Ship,
		pickupFeet + data2.Forward * frozen.FollowerCrateCarryDistance - data2.Right * frozen.FollowerCrateCarryLeftDistance
	)
	local v12 = Scene.flattenedUnit(surfacePosition2 - pickupFeet) or v10
	local facing = Scene.flattenedUnit(v12:Lerp(data2.Right, frozen.FollowerShakeTurnTowardMarines)) or v12
	local v14 = CharacterPresentation.playWalk(follower.Marine)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < Timing.Shared.FollowerCrateCarryTime and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v15 = math.clamp(total / Timing.Shared.FollowerCrateCarryTime, 0, 1)
		local v16 = v15 * v15 * (3 - v15 * 2)
		local facing2 = Scene.flattenedUnit(v10:Lerp(facing, v16)) or facing
		local lerped = pickupFeet:Lerp(surfacePosition2, v15)
		local surfacePosition3 = Deck.getSurfacePosition(data2.Ship, lerped)
		Deck.pivotMarineAtFeet(follower, surfacePosition3, facing2)
		local heldCrateCFrame2 = v.getHeldCrateCFrame(data2, follower, facing2, CFrame.identity)
		Props.syncFruitCrate(data2, heldCrateCFrame2)

		if not v11 then
			continue
		end

		v11.Facing = facing2
		v11.GripRight = CFrame.lookAt(createVector(0, 0, 0), facing2).RightVector
		v.updateCrateHandIK(v11, data2, heldCrateCFrame2)
	end

	Deck.stopAnimationTrack(v14)

	if not data.isLive() then
		return false
	end

	Deck.pivotMarineAtFeet(follower, surfacePosition2, facing)
	local heldCrateCFrame2 = v.getHeldCrateCFrame(data2, follower, facing, CFrame.identity)
	Props.syncFruitCrate(data2, heldCrateCFrame2)

	if v11 then
		v11.Facing = facing
		v11.GripRight = CFrame.lookAt(createVector(0, 0, 0), facing).RightVector
		v.updateCrateHandIK(v11, data2, heldCrateCFrame2)
	end

	follower.Marine:SetAttribute("FloorPos", surfacePosition2)

	if not v.animateFruitCrateInversion(data, data2, follower, facing, v11, Timing.Shared.CrateInvertTime) then
		return false
	end

	CutsceneDialogue.showFollowerShaking()
	local v15 = CharacterPresentation.playCrateShake(follower.Marine)

	if not v15 then
		warn("[Lookout] The follower marine could not play the treasure shake animation")
	end

	local total2 = 0
	local v16 = false
	local v17 = false
	local now = nil
	local currentDialogueBeat2 = data.currentDialogueBeat()

	local function startFailureReaction()
		if p ~= "Failure" or v17 then
			return
		end

		v17 = true
		task.spawn(function()
			local v18 = CharacterPresentation.playStunFlinch(follower.Marine)

			if v18 then
				if not v.waitForAnimationStopped(data, v18) then
					return
				end
			else
				warn("[Lookout] The crate-opening marine could not play its one-shot stun flinch")
			end

			if not data.wait(Timing.Failure.CrateDialogueDelay) then
				return
			end

			v.applyWorriedFace(follower.Marine)
			CutsceneDialogue.showFollowerFailureReaction(data, assert(p2))
			now = os.clock()
		end)
	end

	while total2 < Timing.Shared.CrateShakeTime and data.canContinue(currentDialogueBeat2) do
		total2 += RunService.Heartbeat:Wait()
		local v18 = math.clamp(total2 / Timing.Shared.CrateShakeTime, 0, 1)
		local v19 = math.sin(v18 * 3.141592653589793 * 2 * frozen.CrateDownShakeCount) * frozen.CrateDownShakeDistance
		local v20 = CFrame.new(0, v19, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		local heldCrateCFrame3 = v.getHeldCrateCFrame(data2, follower, facing, v20)
		Props.syncFruitCrate(data2, heldCrateCFrame3)

		if v11 then
			v.updateCrateHandIK(v11, data2, heldCrateCFrame3)
		end

		if v16 or not (frozen.CrateFruitReleaseAlpha <= v18) then
			continue
		end

		v16 = true
		Props.releaseFruitCrate(data2)

		if p ~= "Failure" or v17 then
			continue
		end

		v17 = true
		task.spawn(function()
			local v21 = CharacterPresentation.playStunFlinch(follower.Marine)

			if v21 then
				if not v.waitForAnimationStopped(data, v21) then
					return
				end
			else
				warn("[Lookout] The crate-opening marine could not play its one-shot stun flinch")
			end

			if not data.wait(Timing.Failure.CrateDialogueDelay) then
				return
			end

			v.applyWorriedFace(follower.Marine)
			CutsceneDialogue.showFollowerFailureReaction(data, assert(p2))
			now = os.clock()
		end)
	end

	if not data.isLive() then
		return false
	end

	Deck.stopAnimationTrack(v15)

	if not v16 then
		Props.releaseFruitCrate(data2)

		if p == "Failure" and not v17 then
			v17 = true
			task.spawn(function()
				local v18 = CharacterPresentation.playStunFlinch(follower.Marine)

				if v18 then
					if not v.waitForAnimationStopped(data, v18) then
						return
					end
				else
					warn("[Lookout] The crate-opening marine could not play its one-shot stun flinch")
				end

				if not data.wait(Timing.Failure.CrateDialogueDelay) then
					return
				end

				v.applyWorriedFace(follower.Marine)
				CutsceneDialogue.showFollowerFailureReaction(data, assert(p2))
				now = os.clock()
			end)
		end
	end

	if not v17 then
		CutsceneDialogue.showFollowerStoppedShaking()
	end

	Deck.stopAnimationTrack(v9)
	local surfacePosition3 = Deck.getSurfacePosition(
		data2.Ship,
		surfacePosition2 - facing * frozen.CrateTossBackDistance - data2.Right * 4
	)
	local groundedCrateCFrame = Props.getGroundedCrateCFrame(data2, surfacePosition3)

	if not v.tossEmptyCrate(data, data2, groundedCrateCFrame, v11, Timing.Shared.CrateTossTime) then
		return false
	end

	v.destroyCrateHandIK(v11)

	if p == "Failure" then
		if not v.waitForFailureItemsLanding(data, data2, Timing.Failure.CrateItemLandingWaitTime) then
			return false
		end

		if p == "Failure" and not v17 then
			v17 = true
			task.spawn(function()
				local v18 = CharacterPresentation.playStunFlinch(follower.Marine)

				if v18 then
					if not v.waitForAnimationStopped(data, v18) then
						return
					end
				else
					warn("[Lookout] The crate-opening marine could not play its one-shot stun flinch")
				end

				if not data.wait(Timing.Failure.CrateDialogueDelay) then
					return
				end

				v.applyWorriedFace(follower.Marine)
				CutsceneDialogue.showFollowerFailureReaction(data, assert(p2))
				now = os.clock()
			end)
		end

		while not now and data.isLive() do
			RunService.Heartbeat:Wait()
		end

		if not data.isLive() then
			return false
		end

		local v18 = os.clock() - assert(now)
		local v19 = math.max(assert(v3).ReactionDelay - v18, 0)

		if not data.wait(v19) then
			return false
		end

		FailureSequence.startReaction(assert(p2), data, data2, p3, p4)
		return FailureSequence.run(assert(p2), data, data2, p3, p4, v5, p5)
	else
		if not data.wait(Timing.Success.FollowerReactionPauseTime) then
			return false
		end

		local position = object:GetCFrame().Position
		CutsceneDialogue.showFollowerReaction(data)
		CharacterPresentation.setFace(follower.Marine, frozen.SuccessCrateOpenerFaceId)

		if not (Deck.animateHeadToward(data, follower.Marine, position, Timing.Success.FollowerHeadTurnTime) and data.wait(Timing.Success.FollowerExpressionChangeTime)) then
			return false
		end

		if not data.wait(Timing.Success.PirateReactionDelay) then
			return false
		end

		CutsceneDialogue.showPirateReaction(data)
		v5:SetTarget(vector2)

		if not frozen.FollowerDragonSequenceEnabled then
			return data.isLive()
		end

		local v18 = Props.waitForGrabFruit(data, data2, Timing.Success.GrabFruitTimeout)

		if not v18 then
			warn("[Lookout] The reserved finale fruit was unavailable for the IK pickup")
			return data.isLive()
		end

		local v19 = CharacterPresentation.playPickupBend(follower.Marine)

		if not v19 then
			warn("[Lookout] The follower marine could not play the partial StunKneel pickup bend")
		end

		local upFruitWithIK = v.pickUpFruitWithIK(data, data2, follower, v18)
		Deck.stopAnimationTrack(v19)

		if not upFruitWithIK then
			warn("[Lookout] The follower marine could not complete the IK fruit pickup")
			return data.isLive()
		end

		if not v.eatFruit(data, follower.Marine, upFruitWithIK) then
			warn("[Lookout] The follower marine could not finish the Dragon fruit eating animation")
			return data.isLive()
		end

		if v.playDragonHybridV(data, data2, follower) then
			return data.isLive()
		end

		warn("[Lookout] The follower marine could not enter Dragon hybrid form")
		return data.isLive()
	end
end

return table.freeze(v2)