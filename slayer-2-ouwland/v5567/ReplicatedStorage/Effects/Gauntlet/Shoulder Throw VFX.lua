local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
return function(instance, p: string, cframe: CFrame?)
	if not (instance ~= nil and p ~= "Cancel") then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local center = cframe or humanoidRootPart.CFrame
	local raycastResult = workspace:Raycast(
		center.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

	if p == "Grab" then
		Cam_Shaker(center.Position, "activate_shake")
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHOULDERTHROWgrab", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Grab", center, 4), Ouwmit.Owned(instance, v2))
	elseif p == "Throw" then
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHOULDERTHROWslam", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Throw", center, 4), Ouwmit.Owned(instance, v2))
		OuwCraters.Scales({
			Center = center,
			Count = 9,
			ScaleMult = 0.5,
			Radius = 7
		})
		Cam_Shaker(center.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 1,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.5, 0.5, 0.5),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
	end
end