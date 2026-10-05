local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
local DynamicFace = require(script.Parent.Parent.DynamicFace)
local Effect = require(ReplicatedStorage.Effect)
local Scene = require(script.Parent.Parent.Scene)
local Sound = require(ReplicatedStorage.Util.Sound)
local CutsceneDialogue = require(script.Parent.CutsceneDialogue)
local Deck = require(script.Parent.Deck)
local Props = require(script.Parent.Props)
local Timing = require(script.Parent.Timing)
require(script.Parent.Types)
local frozen = table.freeze({
	FishPickupDistance = 2.2,
	PainAuraStage = 2,
	PainAuraStopStage = 0,
	FishermanAngryFaceId = "48847223322759",
	BoxOpenerFaceId = "178138757474440",
	OtherMarineFaceId = "1211",
	SlapDistance = 3.5,
	SlapLaunchDistance = 900,
	SlapLaunchHeight = 8,
	SlapEffectTemplateName = "FishSlapEffect",
	ImpactSounds = {
		"FishFight_Power_Slap_Impact_01",
		"FishFight_Power_Slap_Impact_02",
		"FishFight_Power_Slap_Impact_03",
		"FishFight_Power_Slap_Impact_04",
		"FishFight_Power_Slap_Impact_05",
		"FishFight_Power_Slap_Impact_06"
	}
})
local v = {}
local v2 = {}

function v.getRoot(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart", true)

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

function v.getFocus(instance)
	local head = instance:FindFirstChild("Head", true)

	if head and head:IsA("BasePart") then
		return head.Position
	end

	return instance:GetPivot().Position + createVector(0, 2.5, 0)
end

function v.setFishermanPainAura(p, stage: number)
	local root = v.getRoot(p)

	if not root then
		return
	end

	pcall(function()
		Effect.new("Pain.Aura"):play({
			Stage = stage,
			Character = p,
			Origin = root.Position,
			Player = p
		})
	end)
end

function v.destroyFishermanPainAura(p)
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
	local child = _WorldOrigin and _WorldOrigin:FindFirstChild((`PainAura{p.Name}`))

	if child then
		child:Destroy()
	end
end

function v.startFishermanAnger(instance)
	CharacterPresentation.setFace(instance, frozen.FishermanAngryFaceId)
	v.setFishermanPainAura(instance, frozen.PainAuraStage)
	instance.Destroying:Once(function()
		v.destroyFishermanPainAura(instance)
	end)
	task.spawn(function()
		local v3 = os.clock() + Timing.Failure.Fisherman.PainAuraAnchorGuardTime

		while os.clock() < v3 and instance:IsDescendantOf(workspace) do
			local root = v.getRoot(instance)

			if not root then
				break
			end

			root.Anchored = true
			RunService.Heartbeat:Wait()
		end
	end)
end

function v.applyDynamicFace(p, p2: string)
	if not DynamicFace.applyHead(p, p2) then
		return false
	end

	DynamicFace.playExpression(p, p2)
	return true
end

function v.startMarineReactions(p, p2, instance, list)
	local follower = p2.Follower
	local v3 = list[2]

	if follower then
		task.spawn(function()
			if not p.wait(Timing.Failure.BoxOpenerReactionDelay) then
				return
			end

			local marine = follower.Marine
			local floorPos = marine:GetAttribute("FloorPos")

			if typeof(floorPos) ~= "Vector3" then
				floorPos = Deck.getSurfacePosition(p2.Ship, marine:GetPivot().Position)
			end

			local finalFacing = Scene.flattenedUnit(instance:GetPivot().Position - marine:GetPivot().Position) or follower.FinalFacing
			Deck.pivotMarineAtFeet(follower, floorPos, finalFacing)
			follower.FinalFacing = finalFacing

			if not CharacterPresentation.playScaredIdle(marine) then
				warn("[Lookout] The box-opening marine could not play its scared idle")
			end

			if not v.applyDynamicFace(marine, frozen.BoxOpenerFaceId) then
				warn("[Lookout] The box-opening marine could not apply its Awkward Grin dynamic face")
			end
		end)
	end

	if v3 then
		task.spawn(function()
			if not p.wait(Timing.Failure.OtherMarineReactionDelay) then
				return
			end

			if not v.applyDynamicFace(v3.Marine, frozen.OtherMarineFaceId) then
				warn("[Lookout] The second marine could not apply its Disbelief dynamic face")
			end
		end)
	end
end

function v.playSoru(character, cframe: CFrame)
	pcall(function()
		Effect.new("Shared.Soru"):play({
			CFrame = cframe,
			Character = character,
			Mode = 1
		})
	end)
end

function v.flashStepTo(instance, p, vector2: Vector3, vector3: Vector3)
	v.playSoru(instance, instance:GetPivot())
	local surfacePosition = Deck.getSurfacePosition(p, vector2)
	local standingCFrame = Deck.calculateStandingCFrame(instance, surfacePosition, vector3)
	instance:PivotTo(standingCFrame)
	instance:SetAttribute("FloorPos", surfacePosition)
	v.playSoru(instance, standingCFrame)
end

function v.resolveFishBone(instance)
	local bone = instance:FindFirstChild("Bone", true)
	local bone2

	if bone and bone:IsA("StringValue") then
		bone2 = instance:FindFirstChild(bone.Value, true)
	end

	if bone2 and bone2:IsA("Bone") then
		return bone2
	end

	return instance:FindFirstChildWhichIsA("Bone", true)
end

function v.cloneSlapEffect(instance, parent)
	local attachment = instance and instance:FindFirstChild(frozen.SlapEffectTemplateName)

	if not (attachment and attachment:IsA("Attachment")) then
		if attachment then
			attachment = attachment:FindFirstChildWhichIsA("Attachment", true)
		else
			attachment = nil
		end
	end

	if attachment and attachment:IsA("Attachment") then
		local clone = attachment:Clone()
		clone.Parent = parent
		return clone
	else
		return nil
	end
end

function v.emitSlapEffect(folder)
	if not folder then
		return
	end

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local v3 = typeof(emitCount) ~= "number" and 1 or math.max(math.floor(emitCount), 1)

		if typeof(emitDelay) == "number" and emitDelay > 0 then
			local v4 = emitter
			local v5 = v3
			task.delay(emitDelay, function()
				if v4.Parent then
					v4:Emit(v5)
				end
			end)
		else
			emitter:Emit(v3)
		end
	end
end

function v.attachFish(p, instance, p2, p3)
	local parent = p2.Root.Parent
	local rightHand = instance:FindFirstChild("RightHand", true) or instance:FindFirstChild("Right Arm", true)

	if not (parent and parent:IsA("Model") and rightHand and rightHand:IsA("BasePart")) then
		return nil
	end

	local fishBone = v.resolveFishBone(parent)

	if not fishBone then
		return nil
	end

	local v3 = rightHand:FindFirstChild("RightGripAttachment")

	if not (v3 and v3:IsA("Attachment")) then
		v3 = Instance.new("Attachment")
		v3.Name = "RightGripAttachment"
		v3.Parent = rightHand
	end

	p2.Grabbed = true
	p2.Root.CanCollide = false
	p2.Root.AssemblyLinearVelocity = createVector(0, 0, 0)
	p2.Root.AssemblyAngularVelocity = createVector(0, 0, 0)
	p2.Root.Anchored = true
	local slapEffect = v.cloneSlapEffect(p3, fishBone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if p.isLive() and parent:IsDescendantOf(workspace) then
			local v4 = fishBone.TransformedWorldCFrame:Inverse() * p2.Root.CFrame
			p2.Root.CFrame = v3.WorldCFrame * v4 * CFrame.Angles(3.141592653589793, 0, 0)
		end
	end)
	p.giveConnection(renderSteppedConnection)
	return slapEffect
end

function v.animateMarineLaunch(data, instance, vector2: Vector3, p: number, p2: number, p3: number)
	local pivot = instance:GetPivot()
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p3 and data.canContinue(currentDialogueBeat) and instance:IsDescendantOf(workspace) do
		total += RunService.Heartbeat:Wait()
		local v3 = math.clamp(total / p3, 0, 1)
		instance:PivotTo(pivot + (vector2 * (p * (1 - (1 - v3) * (1 - v3))) + createVector(0, 1, 0) * (p2 * 4 * v3 * (1 - v3))))
	end

	if data.isLive() and instance:IsDescendantOf(workspace) then
		instance:PivotTo(pivot + vector2 * p)
	end
end

function v.slapMarine(data, p, instance, char, p3)
	local root = v.getRoot(char)

	if not root then
		return data.isLive()
	end

	local v3 = Scene.flattenedUnit(root.Position - instance:GetPivot().Position) or Scene.flattenedUnit(root.CFrame.LookVector) or p.Forward
	local v4 = root.Position - v3 * frozen.SlapDistance
	v.flashStepTo(instance, p.Ship, v4, root.Position - v4)

	if not data.wait(Timing.Failure.Fisherman.PreSlapDelay) then
		return false
	end

	CharacterPresentation.playFishSlap(instance)

	if not data.wait(Timing.Failure.Fisherman.SlapImpactDelay) then
		return false
	end

	v.emitSlapEffect(p3)
	CharacterPresentation.playSlapVictim(char)
	data.giveSound(Sound:Play(frozen.ImpactSounds[math.random(1, #frozen.ImpactSounds)], root.Position))
	local v5 = Scene.flattenedUnit(root.Position - instance:GetPivot().Position) or v3
	pcall(function()
		Effect.new("SlapArenaLaunch"):play({
			char = char,
			hrp = root,
			launchTime = Timing.Failure.Fisherman.SlapLaunchTime * 1.2,
			velocity = v5 * (frozen.SlapLaunchDistance / Timing.Failure.Fisherman.SlapLaunchTime) + createVector(
				0,
				1,
				0
			) * (frozen.SlapLaunchHeight * 2 / Timing.Failure.Fisherman.SlapLaunchTime)
		})
	end)
	task.spawn(
		v.animateMarineLaunch,
		data,
		char,
		v5,
		frozen.SlapLaunchDistance,
		frozen.SlapLaunchHeight,
		Timing.Failure.Fisherman.SlapLaunchTime
	)
	return data.wait(Timing.Failure.Fisherman.SlapInterval)
end

function v.runFisherman(p, data, instance, items, object, p2)
	if not data.Follower then
		return false
	end

	object:SetTarget(v.getFocus(instance))
	CutsceneDialogue.showFishermanReaction(p)

	if not p.wait(Timing.Failure.Fisherman.LineHoldTime) then
		return false
	end

	if not CharacterPresentation.destroyFishingRod(instance) then
		warn("[Lookout] The Fisherman could not resume his idle after removing the fishing rod")
	end

	local v3 = Props.waitForGrabFruit(p, data, Timing.Failure.Fisherman.GrabFishTimeout, instance, false)

	if not v3 then
		warn("[Lookout] The failure Mossback was unavailable for the Fisherman's pickup")
		return false
	end

	local v4 = Scene.flattenedUnit(v3.Root.Position - instance:GetPivot().Position) or -data.Forward
	local v5 = v3.Root.Position - v4 * frozen.FishPickupDistance
	v.flashStepTo(instance, data.Ship, v5, v3.Root.Position - v5)
	object:SetTarget(v.getFocus(instance))
	local v6 = CharacterPresentation.playStunFlinch(instance)

	if not p.wait(Timing.Failure.Fisherman.FishPickupTime) then
		return false
	end

	local v7 = v.attachFish(p, instance, v3, p2)
	Deck.stopAnimationTrack(v6)

	if not v7 then
		warn("[Lookout] The Fisherman picked up the fish without its contact effect")
	end

	for _, item in items do
		object:SetTarget(v.getFocus(item.Marine))

		if not v.slapMarine(p, data, instance, item.Marine, v7) then
			return false
		end
	end

	v.setFishermanPainAura(instance, frozen.PainAuraStopStage)
	local parent = v3.Root.Parent

	if parent and parent:IsA("Model") then
		parent:Destroy()
	end

	object:SetTarget(v.getFocus(instance))
	return p.wait(Timing.Failure.Fisherman.FinalHoldTime)
end

function v.runDoghouse(p, instance, items, object)
	object:SetTarget(v.getFocus(instance))
	CutsceneDialogue.showDoghouseBanAll(p)

	if not p.wait(Timing.Failure.Doghouse.BanCommandHoldTime) then
		return false
	end

	CutsceneDialogue.showDoghouseBanCorrection(p)

	if not p.wait(Timing.Failure.Doghouse.BanCorrectionHoldTime) then
		return false
	end

	CutsceneDialogue.hide()

	for _, item in items do
		if item.Marine.Parent then
			item.Marine:Destroy()
		end
	end

	if instance.Parent then
		instance:Destroy()
	end

	return p.isLive()
end

function v2.startReaction(p, p2, p3, p4, p5)
	if p ~= "Fisherman" then
		return
	end

	v.startFishermanAnger(p4)
	v.startMarineReactions(p2, p3, p4, p5)
end

function v2.run(p, p2, p3, p4, p5, p6, p7)
	if p == "Doghouse" then
		return v.runDoghouse(p2, p4, p5, p6)
	end

	return v.runFisherman(p2, p3, p4, p5, p6, p7)
end

return table.freeze(v2)