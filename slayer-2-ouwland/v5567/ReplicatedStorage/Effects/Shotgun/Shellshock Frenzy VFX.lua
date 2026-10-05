local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Shotgun_Swings = require(ReplicatedStorage.Effects.Swings.Shotgun_Swings)

local function destroyRig(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-ShellshockBarrageGround`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false, nil, true)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

return function(instance, p: string, cframe: CFrame?, value)
	if instance == nil then
		return
	end

	if p == "Cancel" or p == "Start" then
		destroyRig(instance)
		local humanoidRootPart = p == "Start" and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)

		if humanoidRootPart then
			vfxUtility.PlaySound(script.Sounds, "PS2shotgunSHELLSHOCKFRENZYstart", humanoidRootPart, true)
		end
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local v = cframe or humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

		if p == "Burst" then
			local v3 = typeof(value) == "number" and value % 2 == 0 and "PS2shotgunSHELLSHOCKFRENZYshot2" or "PS2shotgunSHELLSHOCKFRENZYshot1"
			vfxUtility.PlaySound(script.Sounds, v3, humanoidRootPart, true)
			Shotgun_Swings.Flash(instance)
			local rightFoot = instance:FindFirstChild("RightFoot")

			if rightFoot then
				local child = workspace.Debree:FindFirstChild((`{instance.Name}-ShellshockBarrageGround`))

				if child == nil then
					child = vfxUtility.cloneAsset(assets, workspace.Debree, "BarrageGround", rightFoot.CFrame, 9)
					child.Name = `{instance.Name}-ShellshockBarrageGround`
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = rightFoot
					motor6D.Part1 = child
					motor6D.Parent = child
					vfxUtility.PlaySound(script.Sounds, "PS2shotgunSHELLSHOCKFRENZYloop", child, false)
				end

				Ouwmit.Emit(child, Ouwmit.Owned(instance, v2))
			end

			Cam_Shaker(v.Position, "punch_shake")
		elseif p == "Jump" then
			destroyRig(instance)
			vfxUtility.PlaySound(script.Sounds, "PS2shotgunSHELLSHOCKFRENZYstop", humanoidRootPart, true)
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Jump", v, 4), Ouwmit.Owned(instance, v2))
			Cam_Shaker(v.Position, "activate_shake")
		elseif p == "Shell" then
			vfxUtility.PlaySound(script.Sounds, "PS2shotgunSHELLSHOCKFRENZYfinalshoot", humanoidRootPart, true)
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Shot", v, 4), Ouwmit.Owned(instance, v2))
			Ouwmit.Emit(
				vfxUtility.cloneAsset(assets, workspace.Debree, "ExplosiveShell", v, 4),
				Ouwmit.Owned(instance, v2)
			)
		elseif p == "Explosion" then
			if typeof(value) == "CFrame" then
				v = value
			end

			local raycastResult2 = workspace:Raycast(
				v.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v3

			if raycastResult2 then
				v3 = vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			end

			vfxUtility.PlaySound(script.Sounds, "PS2shotgunSHELLSHOCKFRENZYexplode", humanoidRootPart, true)
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Explosion", v, 4), Ouwmit.Owned(instance, v3))

			if raycastResult2 then
				local cframe2 = CFrame.new(raycastResult2.Position)
				OuwCraters.Scales({
					Center = cframe2,
					Radius = 6,
					Count = 8,
					ScaleMult = 0.9,
					OffsetMargin = 3
				})
				OuwCraters.Scales({
					Center = cframe2,
					Radius = 10,
					Count = 10,
					ScaleMult = 1.1,
					OffsetMargin = 4
				})
			end

			Cam_Shaker(v.Position, {
				FadeInTime = 0,
				Frequency = 0.12,
				Amplitude = 1.1,
				SustainTime = 0.14,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		end
	end
end