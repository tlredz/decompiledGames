local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
return function(instance, p: string, p2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	vfxUtility.PlaySound(script, "PS2warfansWARGALEWINDvar2RELEASE", humanoidRootPart, true)

	if p == "Swirl" then
		local v = typeof(p2) == "CFrame" and p2 or humanoidRootPart.CFrame
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "BuddhaComeUp", humanoidRootPart.CFrame, 5),
			Ouwmit.Owned(instance, v2)
		)
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "SwirlStartup", humanoidRootPart.CFrame, 5),
			Ouwmit.Owned(instance, v2)
		)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Swirl", v, 5), Ouwmit.Owned(instance, v2))
	end
end