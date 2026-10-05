local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FusionCycle = require(game.ReplicatedStorage.GameServices:WaitForChild("FusionCycle"))
local Audio = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Audio"))
local Effects = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Effects"))
local fusion = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("Fusion")
local SoundService = game:GetService("SoundService")
local game2 = SoundService:WaitForChild("SFX"):WaitForChild("Game")
local localPlayer = Players.LocalPlayer
local PetRigService = require(ReplicatedStorage.GameServices:WaitForChild("PetRigService"))
local FusionRules = require(ReplicatedStorage.GameServices:WaitForChild("FusionRules"))
local FusionDisplay = require(ReplicatedStorage.GameServices:WaitForChild("FusionDisplay"))
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local fusionPetPlace = ReplicatedStorage.Remotes.Game:WaitForChild("FusionPetPlace")
local fusionSlots = localPlayer:WaitForChild("FusionSlots")
local fusionResult = localPlayer:WaitForChild("FusionResult")
local fusionAction = ReplicatedStorage.Remotes.Game:WaitForChild("FusionAction")
fusionAction.OnClientEvent:Connect(function(p, p2)
	local click = p == "Claim" and p2 and game2.Parent:FindFirstChild("Click")

	if click then
		Audio:PlayOnce(click, game:GetService("SoundService"))
	end
end)
local v = {}
localPlayer.CharacterRemoving:Connect(function()
	table.clear(v)
end)
fusionSlots.ChildRemoved:Connect(function(child)
	local v2 = v[child]
	v[child] = nil
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if v2 and os.clock() - v2 < 5 and humanoid and humanoid.Health > 0 then
		local click = game2.Parent:FindFirstChild("Click")

		if click and click:IsA("Sound") then
			Audio:PlayOnce(click, game:GetService("SoundService"))
		end
	end
end)
local v2 = nil
local v3 = {}
local v4 = nil
local parent = nil
local folder = Instance.new("Folder")
folder.Name = "LockedFusion"
folder.Parent = ReplicatedStorage

local function Unlocked()
	local savedData = localPlayer:FindFirstChild("SavedData")
	local rebirths = savedData and savedData:FindFirstChild("Rebirths")
	return rebirths ~= nil and rebirths.Value >= 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveView(p)
	local v6 = v3[p]

	if v6 then
		if v6.Track then
			v6.Track:Stop(0)
		end

		if v6.Effects then
			v6.Effects:Destroy()
		end

		v6.Rig:Destroy()
		v3[p] = nil
	end
end

local function HoldingPet()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and tool:HasTag("Pet")
end

local function CreatePlacementEffect(childName, p, folder2, enabled)
	local part = fusion:FindFirstChild(childName)

	if not (part and part:IsA("BasePart")) then
		return
	end

	local clone = part:Clone()
	local glass = v2.Model:FindFirstChild("Glass")
	local v6 = glass and glass.Position.Y - glass.Size.Y / 2 + 0.1 or p.WorldPosition.Y
	local v7 = CFrame.new(p.WorldPosition.X, v6, p.WorldPosition.Z) * p.WorldCFrame.Rotation
	local floor = clone:FindFirstChild("Floor")
	local v8 = v7 * (floor and floor:IsA("BasePart") and floor.CFrame or clone.CFrame):Inverse()
	local parts = { clone }

	for _, part2 in clone:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	for _, v9 in parts do
		v9.CFrame = v8 * v9.CFrame
		v9.Anchored = true
		v9.CanCollide = false
		v9.CanTouch = false
		v9.CanQuery = false
		v9.CastShadow = false
		v9.Transparency = 1
	end

	local v9 = 0

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = enabled
		v9 = math.max(
			v9,
			(emitter:GetAttribute("EmitDelay") or 0) + (emitter:GetAttribute("EmitDuration") or 0) + emitter.Lifetime.Max
		)
	end

	clone.Parent = folder2

	if not enabled then
		Effects:PlayVFX(clone)
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, v9 + 1)
	end

	return clone
end

local function PlayPlacementEffects(p, p2)
	local folder2 = Instance.new("Folder")
	folder2.Name = "FusionPlacementVFX_" .. p
	folder2.Parent = v2.Model
	CreatePlacementEffect("LoopOnPetPlace", p2, folder2, true)
	CreatePlacementEffect("PlaceEmit", p2, folder2, false)
	return folder2
end

local function FacePlayer(cframe, p)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return cframe
	end

	local pointToWorldSpace = cframe:PointToWorldSpace(p)
	local vector2 = Vector3.new(humanoidRootPart.Position.X, pointToWorldSpace.Y, humanoidRootPart.Position.Z)

	if (vector2 - pointToWorldSpace).Magnitude < 0.01 then
		return cframe
	end

	return CFrame.lookAt(pointToWorldSpace, vector2) * CFrame.new(-p)
end

local soundId = nil
local v6 = false
local random = Random.new()

local function PlayRevealSound(p, position)
	local fusionComplete = nil

	if p then
		fusionComplete = game2:FindFirstChild("FusionComplete")
	else
		local fusionGlitches = game2:FindFirstChild("FusionGlitches")
		local sounds = {}

		if fusionGlitches then
			for _, sound in fusionGlitches:GetChildren() do
				if sound:IsA("Sound") and sound.SoundId ~= "" and sound.SoundId ~= soundId then
					table.insert(sounds, sound)
				end
			end
		end

		if #sounds > 0 then
			fusionComplete = sounds[random:NextInteger(1, #sounds)]
			soundId = fusionComplete.SoundId
		end
	end

	if not fusionComplete or not fusionComplete:IsA("Sound") or fusionComplete.SoundId == "" then
		return
	end

	local part = Instance.new("Part")
	part.Name = "FusionRevealAudio"
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Position = position
	part.Parent = workspace
	local lifetime = math.max(6, fusionComplete.TimeLength / math.max(fusionComplete.PlaybackSpeed, 0.01) + 1)
	local v8 = Audio:PlayOn(fusionComplete, part, {
		MinDistance = 12,
		MaxDistance = 140,
		Lifetime = lifetime
	})

	if v8 then
		v8.Looped = false
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(part, lifetime)
end

local function BuildView(p, instance, attachment)
	local folder2 = PetRigService.Build(instance:GetAttribute("PetName"))

	if not folder2 then
		return
	end

	folder2.Name = "FusionDisplay_" .. p
	local petName = instance:GetAttribute("PetName")
	local mutation = instance:GetAttribute("Mutation")
	local spawnMutation = instance:GetAttribute("SpawnMutation")
	folder2:SetAttribute("PetName", petName)
	folder2:SetAttribute("Mutation", mutation)
	folder2:SetAttribute("SpawnMutation", spawnMutation)
	local v7 = PetRigService.MutationSkin(petName, mutation) and mutation or spawnMutation
	PetRigService.ApplyMutationSkin(folder2, v7)

	if not FusionDisplay.Fit(folder2, attachment, instance:GetAttribute("Weight"), p <= 0) then
		folder2:Destroy()
		return
	end

	if mutation then
		PetRigService.ApplyMutationAura(folder2, mutation, 1, "FusionTraitAura")
	end

	if spawnMutation then
		PetRigService.ApplyMutationAura(folder2, spawnMutation, 1, "FusionMutationAura")
	end

	for _, part in folder2:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	if p == -1 then
		local highlight = Instance.new("Highlight")
		highlight.Name = "FusionPreviewSilhouette"
		highlight.Adornee = folder2
		highlight.FillColor = Color3.new(0, 0, 0)
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = folder2
	end

	if p <= 0 then
		folder2:PivotTo((FacePlayer(folder2:GetPivot(), FusionDisplay.Bounds(folder2))))
	end

	folder2.Parent = v2.Model
	local part = Instance.new("Part")
	part.Name = "FusionPetAudio"
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	local bounds = FusionDisplay.Bounds(folder2)
	part.CFrame = CFrame.new(folder2:GetPivot():PointToWorldSpace(bounds))
	part.Parent = folder2

	for _, childName in { "Splash", "Bubbles" } do
		local sound = game2:FindFirstChild(childName)

		if p > 0 and sound and sound:IsA("Sound") then
			Audio:PlayOn(sound, part, {
				MinDistance = 8,
				MaxDistance = 70
			})
		end
	end

	v3[p] = {
		Rig = folder2,
		Record = instance,
		Track = PetRigService.PlayIdle(folder2),
		Center = FusionDisplay.Bounds(folder2),
		Attachment = attachment,
		Size = select(2, FusionDisplay.Bounds(folder2)),
		ActualSize = p <= 0
	}

	if p == 0 then
		local v9 = v3[p]
		v9.FullScale = folder2:GetScale()
		v9.FullCenter = v9.Center
		v9.FullSize = v9.Size
		v9.GrowElapsed = 0
		folder2:ScaleTo(v9.FullScale * 0.5)
		v9.Center = v9.FullCenter * 0.5
		v9.Size = v9.FullSize * 0.5
	end

	if p > 0 then
		local v9 = v3[p]
		local folder3 = Instance.new("Folder")
		folder3.Name = "FusionPlacementVFX_" .. p
		folder3.Parent = v2.Model
		CreatePlacementEffect("LoopOnPetPlace", attachment, folder3, true)
		CreatePlacementEffect("PlaceEmit", attachment, folder3, false)
		v9.Effects = folder3
	end

	if p == -1 then
		PlayRevealSound(false, part.Position)
	elseif p == 0 and v6 then
		v6 = false
		PlayRevealSound(true, part.Position)
	end
end

local function SetContainerGlow(p, p2)
	if not v2 then
		return
	end

	for _, part in v2.Model:GetChildren() do
		if not (part:IsA("BasePart") and part:GetAttribute("FusionSlot") == p) then
			continue
		end

		local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")

		if not surfaceAppearance then
			continue
		end

		local fusionEmissiveOn

		if p2 then
			fusionEmissiveOn = part:GetAttribute("FusionEmissiveOn") or 15
		else
			fusionEmissiveOn = part:GetAttribute("FusionEmissiveOff") or 0
		end

		if surfaceAppearance.EmissiveStrength ~= fusionEmissiveOn then
			surfaceAppearance.EmissiveStrength = fusionEmissiveOn
		end
	end
end

local v7 = nil
local v8 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function PresentationBusy()
	return v7 ~= nil or localPlayer:GetAttribute("FusionPresentationPending") == true
end

local function FinishSpin(p)
	local fusionFailed = fusionSlots:GetAttribute("FusionFailed") == true

	if not p then
		v8 = false
	end

	local v9 = v7
	local v10

	if p then
		if v9 == nil then
			v10 = false
		else
			v10 = not fusionFailed
		end
	else
		v10 = p
	end

	v6 = v10
	v7 = nil

	if v9 then
		RemoveView(-1) -- equivalent call inferred; original call site unknown

		if v9.PreviewRecord then
			v9.PreviewRecord:Destroy()
		end

		if v9.Smoke then
			for _, effect in v9.Smoke:GetDescendants() do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end

			local Debris = game:GetService("Debris")
			Debris:AddItem(v9.Smoke, 3)
		end
	end

	localPlayer:SetAttribute("FusionPresentationPending", false)

	if p and fusionFailed then
		v8 = false

		for i = 1, 4 do
			RemoveView(i) -- equivalent call inferred; original call site unknown
			SetContainerGlow(i, false)
		end

		local main = localPlayer.PlayerGui:FindFirstChild("Main")
		local fusion2 = main and main:FindFirstChild("Fusion")

		if fusion2 and v9 then
			UIController.open(fusion2)
		end
	end

	if p and v2 then
		local pet = fusionResult:FindFirstChild("Pet")

		if pet and not v3[0] then
			local success, result = pcall(BuildView, 0, pet, v2.Output)

			if not success then
				warn("Fusion result display: " .. tostring(result))
			end
		end

		if v3[0] then
			for i = 1, 4 do
				RemoveView(i) -- equivalent call inferred; original call site unknown
				SetContainerGlow(i, false)
			end

			v8 = false
		end
	end
end

local function StartSpin()
	if v7 then
		return
	end

	if not (v2 and v2.Model:IsDescendantOf(workspace)) then
		localPlayer:SetAttribute("FusionPresentationPending", false)
		return
	end

	localPlayer:SetAttribute("FusionPresentationPending", true)
	v8 = true
	RemoveView(0) -- equivalent call inferred; original call site unknown
	local model = v2.Model
	local attributes = {}

	for i = 1, 4 do
		local child = fusionSlots:FindFirstChild((tostring(i)))

		if child then
			table.insert(attributes, child:GetAttributes())
		end
	end

	v7 = {
		Model = model,
		Elapsed = 0,
		WaitElapsed = 0,
		NextPreview = 0,
		Preview = FusionRules.Preview(attributes),
		Rng = Random.new()
	}
	local smoke = fusion:FindFirstChild("Smoke")

	if smoke and smoke:IsA("BasePart") then
		local clone = smoke:Clone()
		local v9 = v2.Output.WorldCFrame * CFrame.new(v2.Output:GetAttribute("FusionFitOffset") or createVector(0, 0, 0)) * clone.CFrame:Inverse()
		local parts = { clone }

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end

		for _, v10 in parts do
			v10.CFrame = v9 * v10.CFrame
			v10.Anchored = true
			v10.CanCollide = false
			v10.CanTouch = false
			v10.CanQuery = false
			v10.Transparency = 1
		end

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		clone.Name = "FusionRollSmoke"
		clone.Parent = model
		v7.Smoke = clone
	end

	for _, prompt in v2.Prompts do
		prompt:SetAttribute("FusionPromptAvailable", false)
		prompt.Enabled = false
	end

	for _, v9 in { v2.ResultPrompt } do
		v9:SetAttribute("FusionPromptAvailable", false)
		v9.Enabled = false
	end
end

fusionAction.OnClientEvent:Connect(function(p, p2)
	if p == "PrepareFuse" then
		localPlayer:SetAttribute("FusionPresentationPending", true)
		return
	end

	if p ~= "Fuse" then
		return
	end

	if p2 then
		StartSpin()
	else
		FinishSpin(false)
	end
end)
localPlayer.CharacterRemoving:Connect(function()
	FinishSpin(false)
end)

local function Cleanup()
	FinishSpin(false)

	for k in v3 do
		RemoveView(k) -- equivalent call inferred; original call site unknown
	end

	if v2 then
		for k in v2.Prompts do
			SetContainerGlow(k, false)
		end

		for _, prompt in v2.Prompts do
			prompt:Destroy()
		end

		v2.Console:Destroy()
		v2.ResultPrompt:Destroy()
	end

	v2 = nil
end

local function OpenFusionConsole(playerGuiMain)
	if localPlayer:GetAttribute("FusionGuideLoaded") ~= true then
		return
	end

	local fusion2 = playerGuiMain and playerGuiMain:FindFirstChild("Fusion")

	if not fusion2 then
		return
	end

	local fusionGuide = playerGuiMain:FindFirstChild("FusionGuide")

	if fusionGuide and localPlayer:GetAttribute("FusionGuideSeen") ~= true then
		if UIController.open(fusionGuide) or fusionGuide.Visible then
			localPlayer:SetAttribute("FusionGuideSeen", true)
			fusionAction:FireServer("GuideSeen")
		end
	else
		UIController.open(fusion2)
	end
end

local function Bind(fusion2)
	local placePets = fusion2:FindFirstChild("PlacePets")
	local console = fusion2:FindFirstChild("Console")
	local openConsole = console and console:FindFirstChild("OpenConsole")
	local fusionOutput = fusion2:FindFirstChild("FusionOutput")

	if not (placePets and openConsole and fusionOutput) then
		return
	end

	local attachmentsByFusionSlot = {}
	local clonesByFusionSlot = {}

	for _, attachment in placePets:GetChildren() do
		local fusionSlot = attachment:GetAttribute("FusionSlot")
		local petPlace = attachment:FindFirstChild("PetPlace")

		if not (attachment:IsA("Attachment") and fusionSlot and petPlace) then
			continue
		end

		attachmentsByFusionSlot[fusionSlot] = attachment
		local clone = petPlace:Clone()
		clone.Name = "FusionPetPlace"
		clone:SetAttribute("FusionPromptAvailable", false)
		clone.Enabled = false
		clone.Parent = attachment
		local v9 = fusionSlot
		clone.Triggered:Connect(function()
			if PresentationBusy() or fusionSlots:GetAttribute("FusionStatus") then
				return
			end

			local child = fusionSlots:FindFirstChild((tostring(v9)))

			if child then
				v[child] = os.clock()
				task.delay(5, function()
					v[child] = nil
				end)
			end

			fusionPetPlace:FireServer(v9)
		end)
		clonesByFusionSlot[fusionSlot] = clone
	end

	if #clonesByFusionSlot == 4 then
		local clone = openConsole:Clone()
		clone.Name = "OpenConsole"
		clone:SetAttribute("FusionPromptAvailable", false)
		clone.Enabled = false
		clone.Parent = console
		clone.Triggered:Connect(function()
			local savedData = localPlayer:FindFirstChild("SavedData")
			local rebirths = savedData and savedData:FindFirstChild("Rebirths")
			local v9

			if rebirths == nil then
				v9 = false
			else
				v9 = rebirths.Value >= 1
			end

			if not v9 then
				return
			end

			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local playerGuiMain = playerGui and playerGui:FindFirstChild("Main")
			OpenFusionConsole(playerGuiMain)
		end)
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = "FusionResultTake"
		proximityPrompt.ActionText = "Take"
		proximityPrompt.ObjectText = "Pet"
		proximityPrompt.MaxActivationDistance = 30
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Style = openConsole.Style
		proximityPrompt:SetAttribute("FusionPromptAvailable", false)
		proximityPrompt.Enabled = false
		proximityPrompt.Parent = fusionOutput
		proximityPrompt.Triggered:Connect(function()
			if PresentationBusy() then
				return
			end

			local pet = fusionResult:FindFirstChild("Pet")

			if pet then
				fusionAction:FireServer("Claim", pet:GetAttribute("PetKey"))
			end
		end)
		v2 = {
			Model = fusion2,
			Attachments = attachmentsByFusionSlot,
			Prompts = clonesByFusionSlot,
			Console = clone,
			ResultPrompt = proximityPrompt,
			Output = fusionOutput
		}
	else
		for _, v9 in clonesByFusionSlot do
			v9:Destroy()
		end
	end
end

local function AnimateCollection(state, dt)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return state.Collecting == true
	end

	state.RevealElapsed = (state.RevealElapsed or 0) + dt

	if state.RevealElapsed < 2 then
		return false
	end

	if not state.Collecting then
		state.Collecting = true
		state.CollectElapsed = 0
		state.CollectScale = state.Rig:GetScale()
		state.CollectStart = state.Rig:GetPivot():PointToWorldSpace(state.Center)
		state.CollectRotation = state.Rig:GetPivot().Rotation
	end

	state.CollectElapsed += dt
	local v9 = math.clamp(state.CollectElapsed / 0.8, 0, 1)
	local v10 = humanoidRootPart.Position + createVector(0, 1, 0)
	local v11 = math.clamp((v10 - state.CollectStart).Magnitude * 0.25, 3, 10)
	local v12 = state.CollectStart:Lerp(v10, v9) + Vector3.new(0, v11 * 4 * v9 * (1 - v9), 0)
	local v13 = 1 - v9 * 0.97
	state.Rig:ScaleTo(state.CollectScale * v13)
	state.Rig:PivotTo(CFrame.new(v12) * state.CollectRotation * CFrame.new(-state.Center * v13))

	if not (v9 >= 1) then
		return true
	end

	if not state.CollectionHidden then
		state.CollectionHidden = true

		for _, descendant in state.Rig:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			end

			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam")) then
				continue
			end

			descendant.Enabled = false
		end
	end

	if not state.NextClaim or os.clock() >= state.NextClaim then
		state.NextClaim = os.clock() + 1
		fusionAction:FireServer("Claim", state.Record:GetAttribute("PetKey"))
	end

	return true
end

local total = 0
local total2 = 0
RunService.RenderStepped:Connect(function(dt)
	total += dt
	total2 += dt * (fusionSlots:GetAttribute("FusionStatus") == "Waiting" and workspace:GetServerTimeNow() < (fusionSlots:GetAttribute("EndsAt") or 0) and 10 or 1)

	if v7 then
		v7.WaitElapsed += dt
		local pet = fusionResult:FindFirstChild("Pet")

		if v7.Model:IsDescendantOf(workspace) then
			if v7.WaitElapsed > 13 then
				FinishSpin(true)
			elseif (pet or fusionSlots:GetAttribute("FusionFailed") == true) and v7.Preview then
				v7.Elapsed += dt
				local v12 = v3[-1] and v7.HidePreviewAt and v7.Elapsed >= v7.HidePreviewAt and v3[-1]

				if v12 then
					if v12.Track then
						v12.Track:Stop(0)
					end

					if v12.Effects then
						v12.Effects:Destroy()
					end

					v12.Rig:Destroy()
					v3[-1] = nil
				end

				if v7.Elapsed >= 5 then
					FinishSpin(true)
				elseif v7.Elapsed >= v7.NextPreview and v7.Elapsed + 0.12 <= 5 then
					local v13 = math.clamp(v7.Elapsed / 5, 0, 1) ^ 2
					local v14 = v13 * 0.58 + 0.07
					local v15 = v13 * 0.12 + 0.03
					v7.HidePreviewAt = math.min(v7.Elapsed + v14, 4.97)
					v7.NextPreview = v7.HidePreviewAt + v15
					RemoveView(-1) -- equivalent call inferred; original call site unknown

					if v7.PreviewRecord then
						v7.PreviewRecord:Destroy()
					end

					local rollPreview = FusionRules.RollPreview(v7.Preview, v7.Rng)
					local folder2 = Instance.new("Folder")

					for k, v16 in rollPreview do
						folder2:SetAttribute(k, v16)
					end

					folder2:SetAttribute("Weight", FusionRules.RollSize(v7.Preview.BaseSize) * 10 * 0.5)
					v7.PreviewRecord = folder2
					local success, result = pcall(BuildView, -1, folder2, v2.Output)

					if not success then
						warn("Fusion rolling preview: " .. tostring(result))
					end
				end
			elseif not v7.Preview then
				local attributes = {}

				for i = 1, 4 do
					local child = fusionSlots:FindFirstChild((tostring(i)))

					if child then
						table.insert(attributes, child:GetAttributes())
					end
				end

				v7.Preview = FusionRules.Preview(attributes)
			end
		else
			FinishSpin(false)
		end
	end

	for k, v10 in v3 do
		if not (v10.Rig.Parent and v10.Attachment:IsDescendantOf(workspace)) then
			continue
		end

		if k == 0 and v10.GrowElapsed ~= nil then
			v10.GrowElapsed += dt
			local v11 = math.clamp(v10.GrowElapsed / 0.5, 0, 1)
			local v12 = (1 - (1 - v11) ^ 3) * 0.5 + 0.5
			v10.Rig:ScaleTo(v10.FullScale * v12)
			v10.Center = v10.FullCenter * v12
			v10.Size = v10.FullSize * v12

			if v11 >= 1 then
				v10.GrowElapsed = nil
			end
		end

		if not (k ~= 0 or not AnimateCollection(v10, dt)) then
			continue
		end

		local floatPivot = FusionDisplay.FloatPivot
		local attachment = v10.Attachment
		local center = v10.Center
		local v11 = total
		local v12 = k > 0 and total2 or 0
		local v13

		if v10.ActualSize then
			v13 = v10.Size or nil
		end

		local v14 = floatPivot(attachment, center, v11, k, v12, v13)

		if k <= 0 then
			v14 = FacePlayer(v14, v10.Center)
		end

		v10.Rig:PivotTo(v14)
	end
end)

while true do
	local functionals = workspace:FindFirstChild("Functionals")
	local fusion2 = functionals and functionals:FindFirstChild("Fusion")
	local status, v9 = FusionCycle.Status()
	local savedData = localPlayer:FindFirstChild("SavedData")
	local rebirths = savedData and savedData:FindFirstChild("Rebirths")
	local v10

	if rebirths == nil then
		v10 = false
	else
		v10 = rebirths.Value >= 1
	end

	if v10 and status then
		if v4 then
			if v4.Parent == folder and parent and parent.Parent then
				v4.Parent = parent
				fusion2 = v4
			end

			v4 = nil
			parent = nil
		end

		if v2 and (v2.Model ~= fusion2 or not v2.Console:IsDescendantOf(workspace)) then
			Cleanup()
		end

		if not v2 and fusion2 then
			Bind(fusion2)
		end

		if v2 then
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local console = v2.Model:FindFirstChild("Console")
			local position = console and console:IsA("BasePart") and console.Position or v2.Model:GetPivot().Position

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") and (humanoidRootPart.Position - position).Magnitude > 50 then
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
				local playerGuiMain = playerGui and playerGui:FindFirstChild("Main")
				local fusion3 = playerGuiMain and playerGuiMain:FindFirstChild("Fusion")

				if fusion3 and UIController.isOpen(fusion3) then
					UIController.close(fusion3)
				end
			end

			for _, billboardGui in v2.Model:GetDescendants() do
				if not (billboardGui:IsA("BillboardGui") and billboardGui.Parent.Name == "Timer") then
					continue
				end

				billboardGui.Enabled = true
				local label = billboardGui:FindFirstChild("Label")

				if label then
					label.Text = FusionCycle.Label(v9)
				end
			end

			local character2 = localPlayer.Character
			local tool = character2 and character2:FindFirstChildOfClass("Tool")
			local v11

			if tool == nil then
				v11 = false
			else
				v11 = tool:HasTag("Pet")
			end

			local fusionStatus = fusionSlots:GetAttribute("FusionStatus")
			local endsAt = fusionSlots:GetAttribute("EndsAt") or 0
			local startedAt = fusionSlots:GetAttribute("StartedAt") or endsAt
			local serverTimeNow = workspace:GetServerTimeNow()

			if fusionStatus == "Waiting" then
				local _ = endsAt <= serverTimeNow
			end

			local consoleDisplay = v2.Model:FindFirstChild("ConsoleDisplay")
			local surfaceGui = consoleDisplay and consoleDisplay:FindFirstChildOfClass("SurfaceGui")
			local timer = surfaceGui and surfaceGui:FindFirstChild("Timer")
			local process = timer and timer:FindFirstChild("Process")
			local v12

			if fusionStatus == "Waiting" then
				v12 = serverTimeNow < endsAt
			else
				v12 = false
			end

			if surfaceGui then
				surfaceGui.Enabled = v12
			end

			if process then
				process.Visible = v12

				if v12 then
					local v13 = math.floor(math.max(0, serverTimeNow - startedAt) / 0.5) % 4
					process.Text = "Analyzing" .. string.rep(".", v13)
				end
			end

			local v13 = nil

			for _, part in v2.Model:GetChildren() do
				if not (part.Name == "Timer" and part:IsA("BasePart")) then
					continue
				end

				v13 = part
				break
			end

			local surfaceGui2 = v13 and v13:FindFirstChildOfClass("SurfaceGui")
			local enabled = fusionStatus == "Waiting"

			if v13 then
				local fusionTimerVisibleTransparency = v13:GetAttribute("FusionTimerVisibleTransparency")

				if fusionTimerVisibleTransparency == nil then
					fusionTimerVisibleTransparency = v13.Transparency
					v13:SetAttribute("FusionTimerVisibleTransparency", fusionTimerVisibleTransparency)
				end

				v13.Transparency = enabled and fusionTimerVisibleTransparency or 1
			end

			if surfaceGui2 then
				surfaceGui2.Enabled = enabled
			end

			local timer2 = surfaceGui2 and surfaceGui2:FindFirstChild("Timer")

			if timer2 then
				local current = timer2:FindFirstChild("Current")
				local timeLeft = timer2:FindFirstChild("TimeLeft")
				local v16 = not fusionStatus and 0 or endsAt <= startedAt and 1 or math.clamp(
					(serverTimeNow - startedAt) / (endsAt - startedAt),
					0,
					1
				) or 0

				if current then
					current.Size = UDim2.new(0.05 + 0.95 * v16, 0, current.Size.Y.Scale, current.Size.Y.Offset)
				end

				if timeLeft then
					local v17 = math.max(0, (math.ceil(endsAt - serverTimeNow)))
					timeLeft.Text = not fusionStatus and "Place pets" or v17 == 0 and "Ready" or string.format(
						"%dm, %ds",
						math.floor(v17 / 60),
						v17 % 60
					) or "Place pets"
				end
			end

			local count = 0

			for k, prompt in v2.Prompts do
				local child = fusionSlots:FindFirstChild((tostring(k)))

				if fusionStatus == "Result" and v7 == nil and localPlayer:GetAttribute("FusionPresentationPending") ~= true and not v8 then
					child = nil
				end

				if child then
					count += 1
				end

				local v16 = v3[k]
				local v17 = (PresentationBusy() or v8) and v16 ~= nil
				SetContainerGlow(k, child ~= nil or v17)

				if v16 and (not v16.Rig.Parent or v16.Record ~= child and not v17) then
					RemoveView(k) -- equivalent call inferred; original call site unknown
					v16 = nil
				end

				if child and not v16 then
					local success, result = pcall(BuildView, k, child, v2.Attachments[k])

					if not success then
						warn("Fusion display: " .. tostring(result))
					end
				end

				prompt.ObjectText = "Pet"
				prompt.ActionText = child and "Remove" or "Place"
				prompt:SetAttribute(
					"FusionPromptAvailable",
					not fusionStatus and v7 == nil and localPlayer:GetAttribute("FusionPresentationPending") ~= true and (child ~= nil or v11 and not fusionResult:FindFirstChild("Pet"))
				)
			end

			v2.Console.ActionText = "Open Fusion"
			v2.Console.ObjectText = string.format("%d/%d animals", count, 4)
			v2.Console:SetAttribute("FusionPromptAvailable", localPlayer:GetAttribute("FusionGuideLoaded") == true)
			local pet

			if not PresentationBusy() then
				pet = fusionResult:FindFirstChild("Pet") or nil
			end

			local v16 = v3[0]

			if v16 and (v16.Record ~= pet or not v16.Rig.Parent) then
				RemoveView(0) -- equivalent call inferred; original call site unknown
				v16 = nil
			end

			if pet and not v16 then
				local success, result = pcall(BuildView, 0, pet, v2.Output)

				if not success then
					warn("Fusion result display: " .. tostring(result))
				end
			end

			if pet and v3[0] and v8 then
				for i = 1, 4 do
					RemoveView(i) -- equivalent call inferred; original call site unknown
					SetContainerGlow(i, false)
				end

				v8 = false
			end

			v2.ResultPrompt:SetAttribute("FusionPromptAvailable", false)
			v2.ResultPrompt.Enabled = false
		end

		task.wait(0.15)
	else
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		local playerGuiMain = playerGui and playerGui:FindFirstChild("Main")
		local fusion3 = playerGuiMain and playerGuiMain:FindFirstChild("Fusion")

		if fusion3 then
			fusion3.Visible = false
		end

		local fusionGuide = playerGuiMain and playerGuiMain:FindFirstChild("FusionGuide")

		if fusionGuide then
			fusionGuide.Visible = false
		end

		Cleanup()

		if fusion2 then
			fusion2.Parent = folder
			parent = functionals
			v4 = fusion2
		end

		task.wait(0.15)
	end
end