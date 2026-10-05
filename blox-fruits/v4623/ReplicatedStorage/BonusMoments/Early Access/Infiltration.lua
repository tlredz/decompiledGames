local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local AttributeCounter = require(ReplicatedStorage.Util.AttributeCounter)
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local CutsceneNpc = require(ReplicatedStorage.Modules.Cutscene.CutsceneNpc)
local DialogueController = require(ReplicatedStorage.DialogueController)
local Maid = require(ReplicatedStorage.Util.Maid)
local Sound = require(ReplicatedStorage.Util.Sound)
local NPCManager = require(ReplicatedStorage.NPCManager)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Config = require(script.Parent.Config)
local Dialogue = require(script.Parent.Dialogue)
local LocationUtil = require(script.Parent.LocationUtil)
local v = {}
local v2 = {}
local localPlayer = Players.LocalPlayer
local v3 = nil

function v.isActive(p)
	return v3 == p and not (p.Cancelled or p.Cleaned)
end

function v.wait(p, p2: number)
	local v4 = os.clock() + p2

	while os.clock() < v4 do
		if not v.isActive(p) then
			return false
		end

		RunService.Heartbeat:Wait()
	end

	return v.isActive(p)
end

function v.resolveAssetParts()
	local cutsceneAssets = LocationUtil.getCutsceneAssets()

	if not cutsceneAssets then
		return nil, (`missing workspace._WorldOrigin.{Config.CUTSCENE_ASSET_NAME}`)
	end

	local CUTSCENE_ASSET_PARTS = Config.CUTSCENE_ASSET_PARTS
	local part = cutsceneAssets:FindFirstChild(CUTSCENE_ASSET_PARTS.PLAYER_ENTRANCE, true)
	local part2 = cutsceneAssets:FindFirstChild(CUTSCENE_ASSET_PARTS.PLAYER_AT_LAPTOP, true)
	local model = cutsceneAssets:FindFirstChild(CUTSCENE_ASSET_PARTS.LAPTOP, true)

	if not (part and part:IsA("BasePart")) then
		return nil, (`missing cutscene part {CUTSCENE_ASSET_PARTS.PLAYER_ENTRANCE}`)
	end

	if not (part2 and part2:IsA("BasePart")) then
		return nil, (`missing cutscene part {CUTSCENE_ASSET_PARTS.PLAYER_AT_LAPTOP}`)
	end

	if not (model and model:IsA("Model")) then
		return nil, (`missing cutscene model {CUTSCENE_ASSET_PARTS.LAPTOP}`)
	end

	local part3 = model:FindFirstChild(CUTSCENE_ASSET_PARTS.LAPTOP_ROOT, true)
	local bone = model:FindFirstChild(CUTSCENE_ASSET_PARTS.LAPTOP_HINGE, true)

	if part3 and part3:IsA("BasePart") then
		if bone and bone:IsA("Bone") then
			return {
				PlayerEntrance = part,
				PlayerAtLaptop = part2,
				LaptopRoot = part3,
				LaptopHinge = bone
			}, nil
		end

		return nil, (`missing {CUTSCENE_ASSET_PARTS.LAPTOP}.{CUTSCENE_ASSET_PARTS.LAPTOP_HINGE}`)
	else
		return nil, (`missing {CUTSCENE_ASSET_PARTS.LAPTOP}.{CUTSCENE_ASSET_PARTS.LAPTOP_ROOT}`)
	end
end

function v.getBodyGroundOffset(folder, p)
	local v4 = p.Position.Y - p.Size.Y / 2

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or (part:FindFirstAncestorWhichIsA("Accessory") or part:FindFirstAncestorWhichIsA("Tool")) then
			continue
		end

		local halfSize = part.Size / 2
		local cFrame = part.CFrame
		local v6 = math.abs(cFrame.RightVector.Y) * halfSize.X + math.abs(cFrame.UpVector.Y) * halfSize.Y + math.abs(cFrame.LookVector.Y) * halfSize.Z
		v4 = math.min(v4, part.Position.Y - v6)
	end

	return (math.max(p.Position.Y - v4, p.Size.Y / 2))
end

function v.getClearCameraPosition(p, vector2: Vector3, vector3: Vector3)
	local v4 = vector2 - vector3

	if v4.Magnitude <= 0.0001 then
		return vector2
	end

	local cutsceneAssets = { p }
	local cutsceneAssets2 = LocationUtil.getCutsceneAssets()

	if cutsceneAssets2 then
		table.insert(cutsceneAssets, cutsceneAssets2)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = cutsceneAssets
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(vector3, v4, raycastParams)

	if not raycastResult then
		return vector2
	end

	local v5 = vector3 - raycastResult.Position

	if v5.Magnitude <= 0.0001 then
		return raycastResult.Position
	end

	return raycastResult.Position + v5.Unit * Config.CUTSCENE.CAMERA_WALL_PADDING
end

function v.createCameraFrame(p, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, vector6: Vector3)
	local v4 = vector2 + vector4 * vector5.X + createVector(0, 1, 0) * vector5.Y + vector3 * vector5.Z
	local v5 = vector2 + vector4 * vector6.X + createVector(0, 1, 0) * vector6.Y + vector3 * vector6.Z
	local clearCameraPosition = v.getClearCameraPosition(p, v4, v5)
	return CFrame.lookAt(clearCameraPosition, v5)
end

function v.createRoomCameras(p, cframe: CFrame, cframe2: CFrame)
	local v4 = cframe2.Position - cframe.Position
	local vector2 = Vector3.new(v4.X, 0, v4.Z)
	local v5 = cframe.LookVector * createVector(1, 0, 1)
	local unit

	if vector2.Magnitude > 0.0001 then
		unit = vector2.Unit
	else
		unit = not (v5.Magnitude > 0.0001) and createVector(1, 0, 0) or v5.Unit
	end

	local vector3 = Vector3.new(-unit.Z, 0, unit.X)
	local CUTSCENE = Config.CUTSCENE
	local midpoint = (cframe.Position + cframe2.Position) / 2
	return {
		Entrance = CUTSCENE.ENTRANCE_CAMERA_CFRAME,
		Path = v.createCameraFrame(
			p,
			midpoint,
			unit,
			vector3,
			CUTSCENE.PATH_CAMERA_POSITION_OFFSET,
			CUTSCENE.PATH_CAMERA_FOCUS_OFFSET
		),
		Exit = v.createCameraFrame(
			p,
			cframe2.Position,
			unit,
			vector3,
			CUTSCENE.EXIT_CAMERA_POSITION_OFFSET,
			CUTSCENE.EXIT_CAMERA_FOCUS_OFFSET
		),
		Run = v.createCameraFrame(
			p,
			midpoint,
			unit,
			vector3,
			CUTSCENE.RUN_CAMERA_POSITION_OFFSET,
			CUTSCENE.RUN_CAMERA_FOCUS_OFFSET
		)
	}
end

function v.createLaptopCamera(cframe: CFrame, p)
	local CUTSCENE = Config.CUTSCENE
	local pointToWorldSpace = cframe:PointToWorldSpace(CUTSCENE.LAPTOP_CAMERA_POSITION_OFFSET)
	local v4 = p.Position + createVector(0, 1, 0) * CUTSCENE.LAPTOP_CAMERA_FOCUS_HEIGHT
	return CFrame.lookAt(pointToWorldSpace, v4)
end

function v.resolveFrames(p, p2)
	local assetParts, v4 = v.resolveAssetParts()

	if not assetParts then
		return nil, v4
	end

	local bodyGroundOffset = v.getBodyGroundOffset(p, p2)
	local playerEntrance = assetParts.PlayerEntrance.CFrame + createVector(0, 1, 0) * bodyGroundOffset
	local playerAtLaptop = assetParts.PlayerAtLaptop.CFrame + createVector(0, 1, 0) * bodyGroundOffset
	local roomCameras = v.createRoomCameras(p, playerEntrance, playerAtLaptop)
	return {
		EntranceCamera = roomCameras.Entrance,
		PathCamera = roomCameras.Path,
		ExitCamera = roomCameras.Exit,
		RunCamera = roomCameras.Run,
		PlayerEntrance = playerEntrance,
		PlayerAtLaptop = playerAtLaptop,
		LaptopCamera = v.createLaptopCamera(assetParts.PlayerAtLaptop.CFrame, assetParts.LaptopRoot),
		LaptopHinge = assetParts.LaptopHinge
	}, nil
end

function v.playAnimation(p, p2: string, p3)
	local success, result = pcall(p.PlayAnimation, p, p2, p3)

	if success then
		return result
	end

	warn((`[Early Access] Animation {p2} is unavailable: {tostring(result)}`))
	return nil
end

function v.overrideNpcVisualProperty(p, instance, propertyName: string, p2)
	if p.HiddenNpcVisuals[instance] then
		return
	end

	p.HiddenNpcVisuals[instance] = true
	local v4 = instance[propertyName]
	instance[propertyName] = p2
	local connection = instance:GetPropertyChangedSignal(propertyName):Connect(function()
		pcall(function()
			if instance[propertyName] ~= p2 then
				instance[propertyName] = p2
			end
		end)
	end)
	p.NpcVisibilityMaid:GiveTask(function()
		connection:Disconnect()
		pcall(function()
			instance[propertyName] = v4
		end)
	end)
end

function v.hideNpcVisual(p, instance)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		v.overrideNpcVisualProperty(p, instance, "LocalTransparencyModifier", 1)
	elseif instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Light") or instance:IsA("Highlight") then
		v.overrideNpcVisualProperty(p, instance, "Enabled", false)
	end
end

function v.hideNpc(p, folder)
	for _, descendant in folder:GetDescendants() do
		v.hideNpcVisual(p, descendant)
	end

	p.NpcVisibilityMaid:GiveTask(folder.DescendantAdded:Connect(function(descendant)
		v.hideNpcVisual(p, descendant)
	end))
end

function v.hideCutsceneNPCs(p)
	for _, v4 in Config.CUTSCENE_HIDDEN_NPC_NAMES do
		for _, v5 in NPCManager.getNPCsByName(v4) do
			v.hideNpc(p, v5:getModel())
		end
	end
end

function v.tweenActor(p, cframe: CFrame, p2)
	assert(p.Actor):TweenTo(cframe, p2)
	return v.wait(p, p2.Time)
end

function v.lookAround(p, cframe: CFrame)
	local v4 = assert(p.Actor)
	local CUTSCENE = Config.CUTSCENE
	local LOOK = Config.CUTSCENE_ANIMATIONS.LOOK
	v.playAnimation(v4, LOOK, {
		Looped = true,
		Priority = Enum.AnimationPriority.Idle,
		FadeTime = 0.12,
		Speed = 0.85
	})

	for _, v5 in {
		{
			CFrame = cframe * CFrame.Angles(0, math.rad(-CUTSCENE.LOOK_YAW), 0),
			Duration = CUTSCENE.LOOK_TURN_TIME,
			Hold = CUTSCENE.LOOK_HOLD_TIME
		},
		{
			CFrame = cframe * CFrame.Angles(0, math.rad(CUTSCENE.LOOK_YAW), 0),
			Duration = CUTSCENE.LOOK_CROSS_TIME,
			Hold = CUTSCENE.LOOK_HOLD_TIME
		},
		{
			CFrame = cframe,
			Duration = CUTSCENE.LOOK_RETURN_TIME,
			Hold = 0
		}
	} do
		local tweenInfo = TweenInfo.new(v5.Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		if not v.tweenActor(p, v5.CFrame, tweenInfo) or v5.Hold > 0 and not v.wait(p, v5.Hold) then
			return false
		end
	end

	v4:StopAnimation(LOOK, 0.12)
	v4:PivotTo(cframe)
	return true
end

function v.moveActor(p, cframe: CFrame, duration: number, p2: string, speed: number)
	local v4 = assert(p.Actor)
	local position = v4:GetModel():GetPivot().Position
	local v5 = cframe.Position - position
	local vector2 = Vector3.new(v5.X, 0, v5.Z)

	if vector2.Magnitude <= 0.0001 then
		v4:PivotTo(cframe)
		return true
	end

	local unit = vector2.Unit
	v4:PivotTo(CFrame.lookAt(position, position + unit))
	v.playAnimation(v4, p2, {
		Looped = true,
		Priority = Enum.AnimationPriority.Movement,
		FadeTime = 0.12,
		Speed = speed
	})
	local cframe2 = CFrame.lookAt(cframe.Position, cframe.Position + unit)

	if not v.tweenActor(p, cframe2, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)) then
		return false
	end

	v4:StopAnimation(p2, 0.12)
	v4:PivotTo(cframe)
	return true
end

function v.tweenLaptopHinge(data, p: number, duration: number)
	local transform = data.ClosedHingeTransform * CFrame.Angles(math.rad(p), 0, 0)
	local tween = TweenService:Create(
		data.LaptopHinge,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Transform = transform
		}
	)
	data.Maid:GiveTask(tween)
	tween:Play()

	if not v.wait(data, duration) then
		return false
	end

	data.LaptopHinge.Transform = transform
	return true
end

function v:cleanup()
	if self.Cleaned then
		return
	end

	self.Cleaned = true

	if self.DialogueActive and DialogueController.Active then
		DialogueController.close()
	end

	self.DialogueActive = false
	self.Maid:DoCleaning()
	pcall(function()
		self.LaptopHinge.Transform = self.ClosedHingeTransform
	end)
	local camera = self.Camera
	self.Camera = nil

	if camera then
		local success, result = pcall(camera.TeleportBack, camera, self.ReturnCFrame)

		if not success then
			warn((`[Early Access] Camera restoration failed: {tostring(result)}`))
			pcall(camera.Destroy, camera)
		end
	end

	self.NpcVisibilityMaid:DoCleaning()

	if v3 == self then
		v3 = nil
	end
end

function v.createRuntime(moment, p2, p3, p4)
	local maid = Maid.new()
	local npcVisibilityMaid = Maid.new()
	local folder = Instance.new("Folder")
	folder.Name = `EarlyAccessInfiltration_{localPlayer.UserId}`
	folder.Parent = LocationUtil.getWorldOrigin() or workspace
	maid:GiveTask(folder)
	local v5 = {
		Moment = moment,
		Maid = maid,
		NpcVisibilityMaid = npcVisibilityMaid,
		HiddenNpcVisuals = {},
		Camera = nil,
		Actor = nil,
		ReturnCFrame = workspace.CurrentCamera.CFrame,
		LaptopHinge = p4.LaptopHinge,
		ClosedHingeTransform = p4.LaptopHinge.Transform,
		DialogueActive = false,
		Cancelled = false,
		Cleaned = false
	}
	v3 = v5
	local v6, v7 = xpcall(function()
		maid:GiveTask(AttributeCounter.destroyable(localPlayer, "NPC_INTERACTION_LOCK"))
		maid:GiveTask(AttributeCounter.destroyable(localPlayer, "MenuHidden"))
		v.hideCutsceneNPCs(v5)
		local actor = CutsceneNpc.new(p2, folder, {
			Name = "EarlyAccessPlayerDouble",
			Pivot = p4.PlayerEntrance,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false
		})
		v5.Actor = actor
		maid:GiveTask(actor)
		maid:GiveTask(AttributeCounter.destroyable(p2, "DisableMovement"))
		maid:GiveTask(p3.Died:Connect(function()
			v2.cancel(moment)
		end))
		maid:GiveTask(localPlayer.CharacterRemoving:Connect(function(character)
			if character == p2 then
				v2.cancel(moment)
			end
		end))
		maid:GiveTask(localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(function()
			if localPlayer:GetAttribute("CurrentLocation") ~= Config.ISLAND then
				v2.cancel(moment)
			end
		end))
		v5.Camera = CameraController.new()
	end, debug.traceback)

	if not v6 then
		v.cleanup(v5)
		error(v7, 0)
	end

	return v5
end

function v:run(data)
	local v4 = assert(self.Camera)
	local v5 = assert(self.Actor)
	local CUTSCENE = Config.CUTSCENE
	local CUTSCENE_ANIMATIONS = Config.CUTSCENE_ANIMATIONS
	v4:TeleportTo(data.EntranceCamera)
	v4.Animations:AnimateFieldOfView(CUTSCENE.FIELD_OF_VIEW, 1, 1.5)

	if not (v.wait(self, CUTSCENE.ENTRANCE_CAMERA_SETTLE_TIME) and v.lookAround(self, data.PlayerEntrance)) then
		return false, "the infiltration cutscene was cancelled"
	end

	v4.Animations:AnimateTo(data.PathCamera, 1, 2.2)

	if not v.moveActor(self, data.PlayerAtLaptop, CUTSCENE.WALK_DURATION, CUTSCENE_ANIMATIONS.WALK, CUTSCENE.WALK_SPEED) then
		return false, "the infiltration cutscene was cancelled"
	end

	v4.Animations:AnimateTo(data.LaptopCamera, 1, 1.5)

	if not (v.wait(self, CUTSCENE.LAPTOP_CAMERA_SETTLE_TIME) and v.tweenLaptopHinge(
		self,
		CUTSCENE.HINGE_OPEN_ANGLE,
		CUTSCENE.HINGE_OPEN_TIME
	)) then
		return false, "the infiltration cutscene was cancelled"
	end

	pcall(function()
		Sound:Play(Config.HACK_SOUND, data.PlayerAtLaptop.Position)
	end)
	v.playAnimation(v5, CUTSCENE_ANIMATIONS.KEYBOARD, {
		Looped = true,
		Priority = Enum.AnimationPriority.Action,
		FadeTime = 0.08,
		Speed = CUTSCENE.KEYBOARD_SPEED,
		Weight = CUTSCENE.KEYBOARD_WEIGHT
	})

	if not v.wait(self, CUTSCENE.KEYBOARD_TIME) then
		return false, "the infiltration cutscene was cancelled"
	end

	self.DialogueActive = true
	local success, result = pcall(DialogueController.start, Dialogue.uploaded(localPlayer.DisplayName))
	self.DialogueActive = false

	if not v.isActive(self) then
		return false, "the infiltration cutscene was cancelled"
	end

	v5:StopAnimation(CUTSCENE_ANIMATIONS.KEYBOARD, 0.1)

	if not success then
		return false, (`computer sequence failed: {tostring(result)}`)
	end

	if not result then
		return false, "the computer dialogue could not open"
	end

	if not v.tweenLaptopHinge(self, 0, CUTSCENE.HINGE_CLOSE_TIME) then
		return false, "the infiltration cutscene was cancelled"
	end

	v4:TeleportTo(data.ExitCamera)

	if not (v.wait(self, CUTSCENE.EXIT_CAMERA_SETTLE_TIME) and v.lookAround(self, data.PlayerAtLaptop)) then
		return false, "the infiltration cutscene was cancelled"
	end

	v4:TeleportTo(data.RunCamera)

	if not (v.wait(self, CUTSCENE.RUN_CAMERA_SETTLE_TIME) and v.moveActor(
		self,
		data.PlayerEntrance,
		CUTSCENE.RUN_DURATION,
		CUTSCENE_ANIMATIONS.RUN,
		CUTSCENE.RUN_SPEED
	)) then
		return false, "the infiltration cutscene was cancelled"
	end

	if v.wait(self, CUTSCENE.EXIT_HOLD_TIME) then
		return true, nil
	end

	return false, "the infiltration cutscene was cancelled"
end

function v2.cancel(p)
	local v4 = v3

	if not v4 or p and v4.Moment ~= p then
		return
	end

	v4.Cancelled = true
	v.cleanup(v4)
end

function v2.play(p)
	if v3 then
		return false, "an infiltration cutscene is already active"
	end

	if DialogueController.Active then
		return false, "another dialogue is active"
	end

	local liveCharacter, v4, v5 = BonusMomentInteraction.getLiveCharacter(localPlayer)

	if not (liveCharacter and v4 and v5) then
		return false, "the local character is unavailable"
	end

	local frames, v6 = v.resolveFrames(liveCharacter, v4)

	if not frames then
		return false, v6
	end

	local v7 = nil
	local v8 = false
	local v9 = nil
	local v10, v11 = xpcall(function()
		local runtime = v.createRuntime(p, liveCharacter, v5, frames)
		v7 = runtime
		v8, v9 = v.run(runtime, frames)
	end, debug.traceback)

	if v7 then
		v.cleanup(v7)
	end

	if v10 then
		return v8, v9
	end

	return false, (tostring(v11))
end

return table.freeze(v2)