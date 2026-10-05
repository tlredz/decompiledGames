local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
require(ReplicatedStorage.Shared.Types.AssetItem)
local Audio = require(ReplicatedStorage.Shared.Audio)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local CollisionGroups = require(ReplicatedStorage.Shared.Types.CollisionGroups)
local EggActionMovement = require(script.Parent.EggActionMovement)
local EggRenderer = require(script.Parent.EggRenderer)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local emitTree = VFX.EmitTree
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local Player = require(ReplicatedStorage.Shared.Player)
local SfxRework = require(ReplicatedStorage.Data.SfxRework)
local VisualTransform = require(ReplicatedStorage.Shared.Utils.VisualTransform)
local t = require(ReplicatedStorage.Packages.t)
local color = Color3.fromRGB(248, 248, 248)
local assets = ReplicatedStorage.Assets
local transient = Workspace.Transient
local placedEggOpen = assets.Particles["Egg Open"].PlacedEggOpen
local eggExplode = placedEggOpen.EggExplode
local trail = placedEggOpen.Trail
local eggPoof = assets.EggPoof
assert(transient:IsA("Folder"), "Workspace.Transient must be a Folder")
assert(eggExplode:IsA("Model"), "PlacedEggOpen.EggExplode must be a Model")
assert(trail:IsA("Trail"), "PlacedEggOpen.Trail must be a Trail")
assert(eggPoof:IsA("BasePart"), "Assets.EggPoof must be a BasePart")

for _, part in eggExplode:GetDescendants() do
	if part:IsA("BasePart") then
		part.CollisionGroup = CollisionGroups.PLAYER_COLLISION_GROUP
	end
end

local function buildAssetItemData(data, p: number?)
	return {
		Category = data.AssetCategory,
		Scale = p or data.AssetScale,
		EyeColor = data.AssetEyeColor,
		ColorSeed = data.AssetColorSeed,
		ColorIndex = data.AssetColorIndex,
		Mutations = data.Mutations or {},
		BaseMutation = data.BaseMutation,
		HasBeenFirstPlaced = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playPoofSound()
	Audio.Play("rbxassetid://102267539121951", script)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAssetRevealSound(p, bottomCFrameFacingPlayer: CFrame)
	local resolved = SfxRework.Resolve(p.AssetCategory, "Idle", Assets.Directory[p.AssetCategory].RandomIdleSound)

	if resolved == nil then
		return nil
	end

	return Audio.PlayFile(resolved, bottomCFrameFacingPlayer)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function arcApex(vector2: Vector3, vector3: Vector3)
	local v = math.clamp((vector3 - vector2).Magnitude * 0.6, 2, 36)
	return vector2:Lerp(vector3, 0.5) + createVector(0, 1, 0) * v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function arcPosition(position: Vector3, position2: Vector3, p: number)
	local v = arcApex(position, position2) -- equivalent call inferred; original call site unknown
	return position:Lerp(v, p):Lerp(v:Lerp(position2, p), p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerBodyPosition(playerByUserId, position: Vector3)
	local primaryPart = Player.FindPrimaryPart(playerByUserId)

	if primaryPart then
		return primaryPart:GetPivot().Position
	end

	return position
end

local function getBottomCFrameFacingPlayer(p: number, position: Vector3, cframe: CFrame)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		return CFrame.new(position) * cframe
	end

	local playerBodyPosition = getPlayerBodyPosition(playerByUserId, position) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(playerBodyPosition.X, position.Y, playerBodyPosition.Z)

	if (position - vector2).Magnitude < 0.001 then
		return CFrame.new(position) * cframe
	end

	return CFrame.lookAt(position, vector2)
end

local function shakeEggPass(p, cframe: CFrame, p2: number)
	local total = 0

	while total < 0.5 do
		total += RunService.Heartbeat:Wait()
		local v = (1 - total / 0.5) * math.sin(tick() * 90) * p2
		EggActionMovement.SetPivot(p, cframe * CFrame.Angles(0, 0, (math.rad(v))))
	end
end

local function shakeEgg(folder, pivot: CFrame)
	shakeEggPass(folder, pivot, 7)
	task.wait(0.3)
	shakeEggPass(folder, pivot, 9)
	task.wait(0.3)
	shakeEggPass(folder, pivot, 13)
end

local function pivotAssetToEggBottom(instance, cframe: CFrame)
	local pivot = instance:GetPivot()
	local v, v2 = ModelBounds(instance)
	local v3 = v.Position - createVector(0, 1, 0) * (v2.Y * 0.5) - pivot.Position
	local v4 = cframe.Position - v3
	local v5 = cframe - cframe.Position
	instance:PivotTo(CFrame.new(v4) * v5)
end

local count = 0

local function runHatchMotion(p: number, fn)
	count += 1
	local formatted = `EggHatchAnimation.{count}`
	local v = 0
	local flag = false
	RunService:BindToRenderStep(formatted, Enum.RenderPriority.Last.Value, function(p2: number)
		if flag then
			return
		end

		v = math.min(v + p2, p)
		local success, result = pcall(fn, v / p)

		if not success then
			warn((`EggHatchAnimation motion step failed: {result}`))
		end

		if not success or result or p <= v then
			flag = true
		end
	end)

	while not flag do
		task.wait()
	end

	RunService:UnbindFromRenderStep(formatted)
end

local function growAsset(folder, cframe: CFrame, assetScale: number)
	local v = assetScale * 0.5
	runHatchMotion(1.3, function(p: number)
		if folder.Parent == nil then
			return true
		end

		local value = TweenService:GetValue(p, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		folder:ScaleTo(v + (assetScale - v) * value)
		pivotAssetToEggBottom(folder, cframe)
		return nil
	end)

	if folder.Parent ~= nil then
		folder:ScaleTo(assetScale)
		pivotAssetToEggBottom(folder, cframe)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookAtPlayer(instance, playerByUserId)
	local pivot = instance:GetPivot()
	runHatchMotion(3, function(p: number)
		if instance.Parent == nil then
			return true
		end

		local v = pivot + Vector3.new(0, math.sin(6.283185307179586 * p * 0.5) * 1, 0)
		local position = pivot.Position
		local primaryPart = Player.FindPrimaryPart(playerByUserId)

		if primaryPart then
			position = primaryPart:GetPivot().Position
		end

		local vector2 = Vector3.new(position.X, v.Y, position.Z)
		local cframe

		if (v.Position - vector2).Magnitude < 0.001 then
			cframe = v
		else
			cframe = CFrame.lookAt(v.Position, vector2)
		end

		instance:PivotTo(v:Lerp(cframe, (TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))))
		return nil
	end)
end

local function flyAssetIntoPlayer(instance, playerByUserId)
	local scale = instance:GetScale()
	local pivot = instance:GetPivot()
	local fader = VisualTransform.Fader()
	task.spawn(function()
		runHatchMotion(0.7, function(p: number)
			if instance.Parent == nil then
				return true
			end

			local position = pivot.Position
			local primaryPart = Player.FindPrimaryPart(playerByUserId)

			if primaryPart then
				position = primaryPart:GetPivot().Position
			end

			local v2 = arcPosition(pivot.Position, position, p) -- equivalent call inferred; original call site unknown
			local cframe = CFrame.new(v2) * pivot.Rotation
			local vector2 = Vector3.new(position.X, cframe.Y, position.Z)

			if not ((cframe.Position - vector2).Magnitude < 0.001) then
				cframe = CFrame.lookAt(cframe.Position, vector2)
			end

			local value = TweenService:GetValue(
				math.clamp((p - 0.6) / 0.4, 0, 1),
				Enum.EasingStyle.Exponential,
				Enum.EasingDirection.In
			)
			fader:Hide(instance, value)
			instance:ScaleTo((math.max(0.001, scale * (1 - value))))
			instance:PivotTo(cframe)
			return nil
		end)

		if instance.Parent ~= nil then
			fader:Hide(instance, 1)
			instance:ScaleTo(0.001)
			instance:Destroy()
		end
	end)
	task.wait(0.3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAssetClaimSequence(p: number, instance)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		instance:Destroy()
		return
	end

	lookAtPlayer(instance, playerByUserId) -- equivalent call inferred; original call site unknown
	flyAssetIntoPlayer(instance, playerByUserId)
end

local function revealAsset(p: number, p2: string, p3, bottomCFrameFacingPlayer: CFrame)
	local folder = ItemDisplay.CreateActiveModel(p2, buildAssetItemData(p3, 1), true, true)
	folder.Name = `{p}_{p2}`
	folder.Parent = transient
	local primaryPart = folder.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	primaryPart.Anchored = true
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.Adornee = folder
	highlight.Parent = folder
	folder:ScaleTo(p3.AssetScale * 0.5)
	local v, v2 = ModelBounds(folder)
	local v3 = v.Position.Y - v2.Y * 0.5
	local Y = primaryPart.CFrame.Position.Y
	primaryPart.PivotOffset = CFrame.new(0, v3 - Y, 0)
	pivotAssetToEggBottom(folder, bottomCFrameFacingPlayer)
	task.spawn(function()
		growAsset(folder, bottomCFrameFacingPlayer, p3.AssetScale)
	end)

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
	end

	TweenService:Create(highlight, TweenInfo.new(0.5), {
		FillTransparency = 1
	}):Play()
	return folder
end

local EggHatchAnimation = {}

function EggHatchAnimation.Play(p: number, p2: string, p3, folder, flag: boolean?)
	t.strict(t.number)(p)
	t.strict(t.string)(p2)
	assert(Eggs.SchemaValidation.SavedEgg(p3), "Invalid saved egg record")
	t.strict(t.instanceIsA("Model"))(folder)
	t.strict(t.optional(t.boolean))(flag)
	EggRenderer.DisableCollisions(folder)
	local clone = eggExplode:Clone()
	clone:ScaleTo(folder:GetScale() / 3)
	clone:PivotTo(folder:GetPivot())
	local core = clone.Core
	assert(core:IsA("BasePart"), "Egg explosion Core must be a BasePart")
	core.Parent = transient
	Debris:AddItem(core, 60)
	clone.Parent = ReplicatedStorage

	if not flag then
		task.wait(0.4)
		Audio.Play("rbxassetid://125937767292519", script, {
			Volume = 2.8
		})
	end

	local pivot = folder:GetPivot()
	local v, v2 = ModelBounds(folder)
	local bottomCFrameFacingPlayer = getBottomCFrameFacingPlayer(
		p,
		v.Position - createVector(0, 1, 0) * (v2.Y * 0.5) + createVector(0, 0.2, 0),
		pivot - pivot.Position
	)

	if not flag then
		shakeEgg(folder, pivot)
	end

	local total = 0
	local total2 = 0
	local total3 = 0
	local count2 = 0
	local transparency = 0

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local color2 = part.Color
		total += color2.R
		total2 += color2.G
		total3 += color2.B
		count2 += 1

		if part.Transparency > 0.3 then
			transparency = part.Transparency
		end
	end

	local color2

	if count2 > 0 then
		color2 = Color3.new(total / count2, total2 / count2, total3 / count2)
	else
		color2 = color
	end

	local primaryPart = folder.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	local v4 = {
		Color = color2,
		Material = primaryPart.Material,
		MaterialVariant = primaryPart.MaterialVariant,
		Transparency = primaryPart.Transparency
	}
	folder:Destroy()
	clone.Parent = transient

	for _, part in ipairs(clone:GetDescendants()) do
		if part ~= core and part.Name ~= "RootPart" and part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	local v5 = revealAsset(p, p2, p3, bottomCFrameFacingPlayer)
	local v6 = playAssetRevealSound(p3, bottomCFrameFacingPlayer) -- equivalent call inferred; original call site unknown

	for _, child in ipairs(clone:GetChildren()) do
		if child:IsA("BasePart") then
			continue
		end

		assert(child:IsA("Model"), (`Explosion child {child:GetFullName()} must be a Model`))
		local primaryPart2 = child.PrimaryPart
		t.strict(t.instanceIsA("BasePart"))(primaryPart2)
		local boundingBox, size = child:GetBoundingBox()
		local part = Instance.new("Part")
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CFrame = boundingBox
		part.Size = size
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = primaryPart2
		weldConstraint.Parent = part
		part.Parent = child
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		attachment.Parent = part
		attachment2.Parent = part
		attachment.Position = Vector3.new(0, size.Y / 2, 0)
		attachment2.Position = Vector3.new(0, -size.Y / 2, 0)
		local clone2 = trail:Clone()
		clone2.Attachment0 = attachment
		clone2.Attachment1 = attachment2
		clone2.Color = ColorSequence.new(v4.Color)
		clone2.Parent = attachment
		clone2.Enabled = true
	end

	if not flag then
		playPoofSound() -- equivalent call inferred; original call site unknown
	end

	for _, part in ipairs(clone:GetDescendants()) do
		if not (part ~= core and part.Name ~= "RootPart" and part:IsA("BasePart")) then
			continue
		end

		local position = part.Position
		local v7 = CFrame.new(core.Position, position).LookVector * 16 + createVector(0, 24, 0)
		part.Transparency = transparency
		part.Color = color2
		part.Material = v4.Material
		part.MaterialVariant = v4.MaterialVariant
		part:ApplyImpulse(v7 * part.AssemblyMass)
	end

	task.delay(3, function()
		for _, folder2 in ipairs(clone:GetChildren()) do
			for _, part in ipairs(folder2:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(1), {
						Transparency = 1
					}):Play()
				end
			end
		end

		Debris:AddItem(clone, 1)
	end)
	local attachment = core.Attachment
	assert(attachment:IsA("Attachment"), "Egg explosion core Attachment must be an Attachment")

	for _, emitter in ipairs(attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "ColorMe" then
			emitter.Color = ColorSequence.new(v4.Color)
		end
	end

	emitTree(attachment)
	local rare = core.Rare
	assert(rare:IsA("Attachment"), "Egg explosion core Rare must be an Attachment")

	for _, emitter in ipairs(rare:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = ColorSequence.new(v4.Color)
		end
	end

	emitTree(rare)
	local clone2 = eggPoof:Clone()
	clone2.CFrame = pivot
	clone2.Parent = transient
	emitTree(clone2)
	Debris:AddItem(clone2, 6)
	playAssetClaimSequence(p, v5) -- equivalent call inferred; original call site unknown
	return v6
end

function EggHatchAnimation.FadeSoundWhenGrantedToolUnequips(instance, p: string)
	t.strict(t.instanceIsA("Sound"))(instance)
	t.strict(t.string)(p)

	if not instance:IsDescendantOf(game) then
		return
	end

	local localPlayer = Players.LocalPlayer
	local descendantAddedConnection = nil
	local endedConnection = nil
	local stoppedConnection = nil
	local unequippedConnection = nil
	local flag = false

	local function disconnectLifecycle()
		if descendantAddedConnection ~= nil then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		if endedConnection ~= nil then
			endedConnection:Disconnect()
			endedConnection = nil
		end

		if stoppedConnection ~= nil then
			stoppedConnection:Disconnect()
			stoppedConnection = nil
		end

		if unequippedConnection ~= nil then
			unequippedConnection:Disconnect()
			unequippedConnection = nil
		end
	end

	local function fadeAndStop()
		disconnectLifecycle()

		if not instance:IsDescendantOf(game) then
			return
		end

		Audio.FadeTo(instance, {
			Volume = 0,
			Seconds = 0.35
		}).Completed:Once(function()
			if instance:IsDescendantOf(game) then
				instance:Stop()
			end
		end)
	end

	local function tryBindTool(tool)
		if flag or not tool:IsA("Tool") or tool:GetAttribute("UID") ~= p then
			return
		end

		flag = true

		if descendantAddedConnection ~= nil then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		unequippedConnection = tool.Unequipped:Once(fadeAndStop)
	end

	endedConnection = instance.Ended:Once(disconnectLifecycle)
	stoppedConnection = instance.Stopped:Once(disconnectLifecycle)
	descendantAddedConnection = localPlayer.DescendantAdded:Connect(tryBindTool)

	for _, descendant in localPlayer:GetDescendants() do
		tryBindTool(descendant)

		if flag then
			break
		end
	end
end

return EggHatchAnimation