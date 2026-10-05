local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(modules.Effects.Ouwmit)
local vfxUtility = require(modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local script2 = script
local currentCamera = workspace.CurrentCamera
local v = {
	FadeInTime = 0,
	Frequency = 0.15,
	Amplitude = 0.6,
	SustainTime = 0.2,
	FadeOutTime = 0.2,
	RotationInfluence = createVector(0.2, 0.2, 0.2),
	PositionInfluence = createVector(2.5, 2.5, 2.5)
}
local v2 = {
	FadeInTime = 0.1,
	Frequency = 0.3,
	Amplitude = 0.25,
	SustainTime = 360,
	FadeOutTime = 0.3,
	RotationInfluence = createVector(0.1, 0.1, 0.1),
	PositionInfluence = createVector(0.5, 0.5, 0.5)
}

local function blurEffect(value: number?)
	local blurEffect2 = Instance.new("BlurEffect")
	blurEffect2.Size = 5
	blurEffect2.Parent = game.Lighting
	DebrisModule:AddItem(blurEffect2, value or 0.08333333333333333)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -60, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function emitBurst(p, p2: string, cframe: CFrame, p3: number, p4, p5)
	local asset = vfxUtility.cloneAsset(script2, p, p2, cframe, p3)

	if not asset then
		return
	end

	Ouwmit.Emit(asset, Ouwmit.Owned(p5, p4))
	return asset
end

local function floorElement(instance, value: number?)
	local pivot

	if instance:IsA("Model") then
		pivot = instance:GetPivot()
	elseif instance:IsA("BasePart") then
		pivot = instance.CFrame
	end

	if not pivot then
		return
	end

	local position = pivot.Position
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -60, -0),
		RaycastHelper.Crater
	)

	if not raycastResult then
		return
	end

	local cFrame = CFrame.new(position.X, raycastResult.Position.Y + (value or 0), position.Z) * pivot.Rotation

	if instance:IsA("Model") then
		instance:PivotTo(cFrame)
	else
		instance.CFrame = cFrame
	end
end

local function emitGroundBurst(p, p2: string, cframe: CFrame, p3: number, p4, p5)
	local asset = vfxUtility.cloneAsset(script2, p, p2, cframe, p3)

	if asset then
		Ouwmit.Emit(asset, Ouwmit.Owned(p5, p4))
	else
		asset = nil
	end

	if not asset then
		return asset
	end

	local big_Slash = asset:FindFirstChild("Big_Slash", true)

	if big_Slash then
		floorElement(big_Slash)
	end

	local dustRaycast = asset:FindFirstChild("DustRaycast", true)

	if dustRaycast then
		floorElement(dustRaycast)
	end

	return asset
end

local function floorLoopGround(asset)
	local big_Slash = asset:FindFirstChild("Big_Slash", true)

	if big_Slash then
		floorElement(big_Slash)
	end

	for _, childName in { "Attachment1", "Attachment2" } do
		local child = asset:FindFirstChild(childName, true)
		local trail = child and child:FindFirstChild("Trail")

		if not (trail and trail:IsA("Attachment")) then
			continue
		end

		local worldPosition = trail.WorldPosition
		local raycastResult = workspace:Raycast(
			worldPosition + createVector(0, 5, 0),
			createVector(-0, -60, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			trail.WorldPosition = Vector3.new(worldPosition.X, raycastResult.Position.Y, worldPosition.Z)
		end
	end
end

local function emitLoop(debree, instance, instanceRoot, p: string, p2: number, p3)
	local asset = vfxUtility.cloneAsset(script2, debree, p, instanceRoot.CFrame, p2)

	if not asset then
		return
	end

	asset.Name = instance.Name .. "_ExecScyther" .. p
	Ouwmit.Emit(asset, Ouwmit.Owned(instance, p3))
	local root = asset:FindFirstChild("Root")
	local rootRigAttachment = root and root:FindFirstChild("RootRigAttachment")
	local rigidConstraint = rootRigAttachment and rootRigAttachment:FindFirstChild("RigidConstraint")
	local rigHumAttach = rootRigAttachment and rootRigAttachment:FindFirstChild("RigHumAttach")

	if rigidConstraint and rigHumAttach then
		rigHumAttach.Parent = instanceRoot
		rigidConstraint.Attachment1 = rigHumAttach
	end

	floorLoopGround(asset)

	if p == "Loop1" then
		local cam_Shaker = Cam_Shaker(instanceRoot, v2)
		task.spawn(function()
			local clone = script.Sounds.PS2sicklesSCYTHERVORTEXloopTRUE:Clone()
			clone.Parent = instanceRoot
			clone:Play()

			while asset ~= nil and asset.Parent ~= nil and asset.Name ~= "--" do
				task.wait(0.1)
				floorLoopGround(asset)
			end

			clone:Stop()
			clone:Destroy()

			if cam_Shaker then
				cam_Shaker:Destroy()
			end
		end)
	end
end

return function(instance, p: string)
	if instance == nil then
		return
	end

	local child = workspace.Debree:FindFirstChild(instance.Name .. "_ExecScytherLoop1")

	if child then
		vfxUtility.EnableAll(child, false, nil, true)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end

	local instanceRoot = instance:FindFirstChild("Root") or instance.PrimaryPart

	if instanceRoot == nil or (instanceRoot.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Startup" then
		emitGroundBurst(workspace.Debree, "Skill1", instanceRoot.CFrame, 5, groundDust(instanceRoot.Position), instance)
		Cam_Shaker(instanceRoot.Position, v)
		vfxUtility.PlaySound(script.Sounds, "PS2sicklesEXECUTIONERSCYTHERinitiate", instanceRoot, true)
		local blurEffect2 = Instance.new("BlurEffect")
		blurEffect2.Size = 5
		blurEffect2.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect2, 0.15)
		emitLoop(workspace.Debree, instance, instanceRoot, "Loop1", 7, groundDust(instanceRoot.Position))
	elseif p == "Hit" then
		emitGroundBurst(workspace.Debree, "Skill1", instanceRoot.CFrame, 5, groundDust(instanceRoot.Position), instance)
		Cam_Shaker(instanceRoot.Position, v)
		vfxUtility.PlaySound(script.Sounds, "PS2sicklesEXECUTIONERSCYTHERfinalwindup", instanceRoot, true)
		local blurEffect2 = Instance.new("BlurEffect")
		blurEffect2.Size = 5
		blurEffect2.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect2, 0.15)
		emitLoop(workspace.Debree, instance, instanceRoot, "Loop2", 7)
	elseif p == "Slam" then
		emitGroundBurst(
			workspace.Debree,
			"Skill2",
			instanceRoot.CFrame * CFrame.new(0, -5, 0),
			5,
			groundDust(instanceRoot.Position),
			instance
		)
		Cam_Shaker(instanceRoot.Position, v)
	elseif p == "Cross" then
		vfxUtility.PlaySound(script.Sounds, "PS2sicklesEXECUTIONERSCYTHERfinalhitslam", instanceRoot, true)
		local asset = vfxUtility.cloneAsset(
			script2,
			workspace.Debree,
			"Cross",
			instanceRoot.CFrame * CFrame.new(0, 7, 0),
			5
		)

		if asset then
			for _, childName in {
				"AngledSlashX",
				"AngledSlashX2",
				"Smash",
				"Big_Slash",
				"Big_Slash2",
				"GroundImpactEmit",
				"GroundImpactEmit2"
			} do
				local child2 = asset:FindFirstChild(childName, true)

				if child2 then
					floorElement(child2)
				end
			end

			for _, descendant in asset:GetDescendants() do
				if descendant.Name == "DustRaycast" then
					floorElement(descendant)
				end
			end

			for _, childName in { "Kick", "Kick2" } do
				local child2 = asset:FindFirstChild(childName, true)

				if child2 then
					floorElement(child2, 1)
				end
			end

			Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(instanceRoot.Position)))
		end

		Cam_Shaker(instanceRoot.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 1.25,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end