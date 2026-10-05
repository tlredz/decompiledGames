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

	if p == "Punch" then
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHATTERSTEPpunch", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Startup", v, 4), Ouwmit.Owned(instance, v2))
		Cam_Shaker(v.Position, "activate_shake")
	elseif p == "Jump" then
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHATTERSTEPjump", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Jump", v, 4), Ouwmit.Owned(instance, v2))
		local upperTorso = instance:FindFirstChild("UpperTorso")

		if upperTorso then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, upperTorso, "CenterWinds", nil, 4), Ouwmit.Owned(instance))
		end

		Cam_Shaker(v.Position, "activate_shakelessaggresive")
	elseif p == "Air" then
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHATTERSTEPswing", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "AirEmit", v, 4), Ouwmit.Owned(instance, v2))
		Cam_Shaker(v.Position, "activate_shakelessaggresive")
	elseif p == "End" then
		Cam_Shaker(v.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 1,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.5, 0.5, 0.5),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		vfxUtility.PlaySound(script.Sounds, "PS2gauntletSHATTERSTEPslam", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "End", v, 4), Ouwmit.Owned(instance, v2))
	end
end