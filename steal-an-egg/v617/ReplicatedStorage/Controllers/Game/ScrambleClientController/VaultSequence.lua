local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local GearToolLookup = require(ReplicatedStorage.Shared.Util.GearToolLookup)
local Gears = require(ReplicatedStorage.Data.Gears)
local ScrambleVaultPresentation = require(ReplicatedStorage.Shared.Util.ScrambleVaultPresentation)
local localPlayer = Players.LocalPlayer
local VaultSequence = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function eased(value: number)
	return TweenService:GetValue(math.clamp(value, 0, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
end

local function closedDoor(instance)
	if not object[instance] then
		object[instance] = instance:GetPivot()
	end

	return object[instance]
end

function VaultSequence.IsPlaying()
	return v ~= nil
end

function VaultSequence.SetOpen(instance, flag: boolean)
	if v and v.Vault == instance then
		return
	end

	local assets = ScrambleVaultPresentation.Assets(instance)

	if assets then
		local doorPose = ScrambleVaultPresentation.DoorPose

		if not object[assets] then
			object[assets] = assets:GetPivot()
		end

		assets:PivotTo(doorPose(object[assets], flag and 1 or 0, instance:GetAttribute("DoorOpenAngleDegrees")))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function safely(callback)
	local success, result = pcall(callback)

	if not success then
		warn("[Scramble] Vault cleanup:", result)
	end
end

local function restoreCamera(player)
	if not player.OwnsCamera then
		return
	end

	player.OwnsCamera = false
	local camera = player.Camera

	if camera:GetAttribute("ScrambleVaultCameraOwner") ~= player.Id then
		return
	end

	camera:SetAttribute("ScrambleVaultCameraOwner", nil)

	if camera.CameraType ~= Enum.CameraType.Scriptable then
		return
	end

	camera.CameraType = player.CameraType
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if character ~= player.Character or not (camera.CameraSubject and camera.CameraSubject.Parent) then
		camera.CameraSubject = humanoid
	end

	if workspace.CurrentCamera == camera and character == player.Character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local v2 = not humanoidRootPart and createVector(0, 0, 0) or humanoidRootPart.Position - player.Origin
		camera.CFrame = player.CameraFrame + v2
		camera.Focus = player.Focus + v2
	end
end

local function releasePresentation(p)
	local function fn()
		ContextActionService:UnbindAction("ScrambleVaultMovement")
	end

	safely(fn) -- equivalent call inferred; original call site unknown

	local function fn2()
		ContextActionService:UnbindAction("ScrambleVaultSkip")
	end

	safely(fn2) -- equivalent call inferred; original call site unknown

	local function fn3()
		restoreCamera(p)
	end

	safely(fn3) -- equivalent call inferred; original call site unknown
	local releaseUI = p.ReleaseUI
	p.ReleaseUI = nil

	if releaseUI then
		safely(releaseUI) -- equivalent call inferred; original call site unknown
	end
end

function VaultSequence.Stop(flag: boolean?)
	local v2 = v

	if not v2 then
		return
	end

	v = nil

	local function fn()
		RunService:UnbindFromRenderStep("ScrambleVaultReward")
	end

	safely(fn) -- equivalent call inferred; original call site unknown
	releasePresentation(v2)

	if v2.Weapon then
		local success, result = pcall(function()
			v2.Weapon:Destroy()
		end)

		if not success then
			warn("[Scramble] Vault cleanup:", result)
		end
	end

	local function fn2()
		if v2.Door.Parent then
			v2.Door:PivotTo(ScrambleVaultPresentation.DoorPose(v2.Closed, flag and 1 or 0, v2.Angle))
		end
	end

	safely(fn2) -- equivalent call inferred; original call site unknown
end

function VaultSequence.Finish(p: string, flag: boolean)
	if v and v.Id == p then
		VaultSequence.Stop(flag)
	end
end

local function weaponModel(gear: string)
	local v2 = Gears.Directory[gear]
	local folder = v2 and GearToolLookup(v2.ToolModel or gear)

	if not folder then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = "ScramblerRewardVisual"
	local handle = folder:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		model:Destroy()
		return nil
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()

		for _, descendant in clone:GetDescendants() do
			if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("BasePart") or descendant:IsA("ProximityPrompt") or descendant:IsA("ClickDetector") or descendant:IsA("TouchTransmitter") or descendant:IsA("Tool")) then
				continue
			end

			descendant:Destroy()
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.LocalTransparencyModifier = 0
		clone.Parent = model
	end

	model.WorldPivot = handle.CFrame
	return model
end

function VaultSequence.Start(instance, data)
	if v or type(data) ~= "table" or type(data.Id) ~= "string" or type(data.Gear) ~= "string" or type(data.StartedAt) ~= "number" then
		return
	end

	local assets, _, v2 = ScrambleVaultPresentation.Assets(instance)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	if not assets or not v2 or not humanoidRootPart or not humanoid or humanoid.Health <= 0 or not currentCamera then
		return
	end

	local weapon = weaponModel(data.Gear)

	if not weapon then
		return
	end

	if not object[assets] then
		object[assets] = assets:GetPivot()
	end

	local closed = object[assets]
	local position = assets:GetBoundingBox().Position
	local vector2 = Vector3.new(position.X - v2.Position.X, 0, position.Z - v2.Position.Z)
	local outward = not (vector2.Magnitude > 0.1) and createVector(0, 0, -1) or vector2.Unit
	local v6 = position + createVector(0, 0.5, 0)
	local v9 = v6 + outward * 10 + (createVector(0, 1, 0)):Cross(outward) * 2.5 + createVector(0, 2, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character, assets }
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(v6, v9 - v6, raycastParams)

	if raycastResult then
		v9 = raycastResult.Position + raycastResult.Normal * 0.5
	end

	local ownsCamera

	if currentCamera.CameraType == Enum.CameraType.Custom then
		ownsCamera = not (HiddenUIHandler.IsHidden() or GuiService.ReducedMotionEnabled)
	else
		ownsCamera = false
	end

	local v11 = {
		Id = data.Id,
		Vault = instance,
		Door = assets,
		Closed = closed,
		Angle = instance:GetAttribute("DoorOpenAngleDegrees"),
		Weapon = weapon,
		Spawn = v2.CFrame,
		Outward = outward,
		StartedAt = data.StartedAt,
		Character = character,
		Humanoid = humanoid,
		Origin = humanoidRootPart.Position,
		Camera = currentCamera,
		CameraFrame = currentCamera.CFrame,
		CameraType = currentCamera.CameraType,
		FOV = currentCamera.FieldOfView,
		Focus = currentCamera.Focus,
		Subject = currentCamera.CameraSubject,
		OwnsCamera = ownsCamera,
		Shot = CFrame.lookAt(v9, v6)
	}
	v = v11
	task.delay(ScrambleVaultPresentation.Duration + 0.75, function()
		if v == v11 then
			releasePresentation(v11)
		end
	end)
	task.delay(ScrambleVaultPresentation.Duration + 8, function()
		if v == v11 then
			VaultSequence.Stop(false)
		end
	end)
	local v12, v13 = xpcall(function()
		assets:PivotTo(closed)
		weapon:ScaleTo(ScrambleVaultPresentation.DisplayScale)
		weapon:PivotTo(v11.Spawn)
		weapon.Parent = workspace

		if ownsCamera then
			currentCamera:SetAttribute("ScrambleVaultCameraOwner", v11.Id)
			v11.ReleaseUI = HiddenUIHandler.Acquire()
			currentCamera.CameraType = Enum.CameraType.Scriptable
			ContextActionService:BindActionAtPriority("ScrambleVaultMovement", function()
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.High.Value + 100, table.unpack(Enum.PlayerActions:GetEnumItems()))
			ContextActionService:BindActionAtPriority("ScrambleVaultSkip", function(_, p)
				if p == Enum.UserInputState.Begin and v == v11 then
					releasePresentation(v11)
				end

				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.High.Value + 101, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
		end

		RunService:BindToRenderStep("ScrambleVaultReward", Enum.RenderPriority.Camera.Value + 2, function()
			local v14, v15 = xpcall(function()
				if v ~= v11 then
					return
				end

				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if localPlayer.Character ~= character or humanoid.Health <= 0 or not humanoidRootPart2 or not instance:IsDescendantOf(workspace) or not assets.Parent or (humanoidRootPart2.Position - v11.Origin).Magnitude > 35 then
					VaultSequence.Stop(false)
					return
				end

				local v16 = math.max(0, workspace:GetServerTimeNow() - v11.StartedAt)
				local doorPose = ScrambleVaultPresentation.DoorPose
				local v19 = (v16 - ScrambleVaultPresentation.DoorStart) / ScrambleVaultPresentation.DoorSeconds
				assets:PivotTo(doorPose(
					closed,
					TweenService:GetValue(math.clamp(v19, 0, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
					v11.Angle
				))

				if v16 < ScrambleVaultPresentation.Duration then
					weapon.Parent = workspace
					local v20 = math.clamp(
						(v16 - ScrambleVaultPresentation.FlyAt) / (ScrambleVaultPresentation.Duration - ScrambleVaultPresentation.FlyAt),
						0,
						1
					)
					local position2 = v11.Spawn.Position
					local v21 = humanoidRootPart2.Position + createVector(0, 1, 0)
					local v22 = position2 + outward * 5 + createVector(0, 3, 0)
					local v23 = eased(v20) -- equivalent call inferred; original call site unknown
					weapon:ScaleTo(ScrambleVaultPresentation.DisplayScale + (1 - ScrambleVaultPresentation.DisplayScale) * v23)
					local v24 = (1 - v23) ^ 2 * position2 + (1 - v23) * 2 * v23 * v22 + v23 ^ 2 * v21
					weapon:PivotTo(CFrame.new(v24) * v11.Spawn.Rotation * CFrame.Angles(
						0,
						v20 * 3.141592653589793 * 2,
						0
					))
				elseif ScrambleVaultPresentation.Duration <= v16 then
					weapon.Parent = nil
				end

				if v11.OwnsCamera then
					if workspace.CurrentCamera == currentCamera and currentCamera.CameraType == Enum.CameraType.Scriptable and currentCamera.CameraSubject == v11.Subject and currentCamera:GetAttribute("ScrambleVaultCameraOwner") == v11.Id then
						humanoid:Move(createVector(0, 0, 0))
						local v21 = eased((v16 - ScrambleVaultPresentation.FlyAt) / (ScrambleVaultPresentation.Duration - ScrambleVaultPresentation.FlyAt)) -- equivalent call inferred; original call site unknown
						local v22 = v11.CameraFrame + (humanoidRootPart2.Position - v11.Origin)
						currentCamera.CFrame = v11.CameraFrame:Lerp(
							v11.Shot,
							eased(v16 / ScrambleVaultPresentation.CameraIn)
						):Lerp(
							v22,
							v21
						)
						currentCamera.Focus = CFrame.new(v6):Lerp(
							v11.Focus + (humanoidRootPart2.Position - v11.Origin),
							v21
						)

						if ScrambleVaultPresentation.Duration <= v16 then
							releasePresentation(v11)
						end
					else
						releasePresentation(v11)
					end
				end

				if ScrambleVaultPresentation.Duration + 8 < v16 then
					VaultSequence.Stop(false)
				end
			end, debug.traceback)

			if not v14 then
				VaultSequence.Stop(false)
				warn("[Scramble] Vault animation failed:", v15)
			end
		end)
	end, debug.traceback)

	if not v12 then
		VaultSequence.Stop(false)
		warn("[Scramble] Vault animation could not start:", v13)
	end
end

return VaultSequence