local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
return function(instance, p: string, cframe: CFrame?, cframe2: CFrame?)
	if not (instance ~= nil and p ~= "Cancel") then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Jump" then
		if assets then
			local v = cframe or humanoidRootPart.CFrame
			local raycastResult = workspace:Raycast(
				v.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Jump", v, 2), Ouwmit.Owned(instance, v2))
		end

		vfxUtility.PlaySound(sounds, "PS2bladedwagasaSHAEBREAKERjump", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Explosion" then
		local v = cframe2 or cframe or humanoidRootPart.CFrame

		if assets then
			local raycastResult = workspace:Raycast(
				v.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(
				vfxUtility.cloneAsset(assets, workspace.Debree, "Impact", v * CFrame.new(0, -5, 0), 4),
				Ouwmit.Owned(instance, v2)
			)
		end

		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -25, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			local cframe3 = CFrame.new(raycastResult.Position)
			OuwCraters.Scales({
				Center = cframe3,
				Radius = 7,
				Count = 4,
				ScaleMult = 0.7
			})
			OuwCraters.Scales({
				Center = cframe3,
				Radius = 12,
				Count = 6,
				ScaleMult = 0.9
			})
		end

		vfxUtility.PlaySound(sounds, "PS2bladedwagasaSHAEBREAKERslam", humanoidRootPart, true)
		Cam_Shaker(v.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 1.6,
			SustainTime = 0.12,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end