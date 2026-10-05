local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)

local function folderName(p)
	return (`{p.Name}-ReaperSlash`)
end

local function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 8
	blurEffect.Parent = game.Lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detachRig(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local rigHumAttach = humanoidRootPart and humanoidRootPart:FindFirstChild("RigHumAttach")

	if rigHumAttach then
		rigHumAttach:Destroy()
	end
end

local function destroyFolder(instance)
	detachRig(instance) -- equivalent call inferred; original call site unknown
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-ReaperSlash`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false, nil, true)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

return function(instance, p, cframe: CFrame?)
	if instance == nil then
		return
	end

	if p == "End" or p == "Cancel" then
		destroyFolder(instance)
	end

	if p == "Cancel" then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	if p == "Start" then
		destroyFolder(instance)
		local folder = Instance.new("Folder")
		folder.Name = `{instance.Name}-ReaperSlash`
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 5)
		local v = vfxUtility.CheckForGround(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local clone = script.Jump:Clone()
		clone.Parent = folder
		clone:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(v)))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script.Sounds, "PS2scytheREAPERSLASHjump", humanoidRootPart, true)
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 8
		blurEffect.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect, 0.2)
		local clone2 = script.Loop:Clone()
		clone2.Parent = folder
		clone2:PivotTo(humanoidRootPart.CFrame)
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(v)))
		local v2 = vfxUtility.PlaySound(script.Sounds, "PS2scytheREAPERSLASHloop", clone2.HumanoidRootPart)

		if v2 then
			v2.Looped = true
		end

		local rigidConstraint = clone2.HumanoidRootPart.RootRigAttachment.RigidConstraint
		local rigHumAttach = clone2.HumanoidRootPart.RootRigAttachment.RigHumAttach
		rigHumAttach.Parent = humanoidRootPart
		rigidConstraint.Attachment1 = rigHumAttach
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "End" then
		local v = cframe or humanoidRootPart.CFrame
		local v2 = vfxUtility.CheckForGround(v.Position, createVector(0, -20, 0), vfxUtility.RayParams.Map)
		local clone = script.End:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(v)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(v2)))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script.Sounds, "PS2scytheREAPERSLASHslam", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.8,
			SustainTime = 0.4,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(4, 4, 4)
		})
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 8
		blurEffect.Parent = game.Lighting
		DebrisModule:AddItem(blurEffect, 0.3)
	end
end