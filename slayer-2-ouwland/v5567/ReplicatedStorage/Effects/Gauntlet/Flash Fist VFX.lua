local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
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

	local v = cframe or humanoidRootPart.CFrame
	local raycastResult = workspace:Raycast(
		v.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

	if p == "FlashFist" then
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletFLASHFISTswing", humanoidRootPart, true)
		Cam_Shaker(v.Position, "activate_shake")
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "FlashFist", v, 4), Ouwmit.Owned(instance, v2))
	elseif p == "Barrage" then
		Cam_Shaker(v.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.3,
			SustainTime = 0.4,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.5, 0.5, 0.5),
			PositionInfluence = createVector(0.75, 0.75, 0.75)
		})
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletFLASHFISTpunch", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Barrage", v, 4), Ouwmit.Owned(instance, v2))
	end
end