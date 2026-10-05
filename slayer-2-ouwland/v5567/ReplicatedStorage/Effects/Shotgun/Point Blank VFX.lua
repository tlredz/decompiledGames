local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Shotgun_Swings = require(ReplicatedStorage.Effects.Swings.Shotgun_Swings)
return function(instance, p: string, cframe: CFrame?, cframe2: CFrame?)
	if instance == nil or (p == "Cancel" or p == "Start") then
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

	if p == "Grab" then
		vfxUtility.PlaySound(script.Sounds, "PS2shotgunPOINTBLANKattempt", humanoidRootPart, true)
		Cam_Shaker(v.Position, "activate_shakelessaggresive")
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Grab", v, 4), Ouwmit.Owned(instance, v2))
	elseif p == "Slam" then
		vfxUtility.PlaySound(script.Sounds, "PS2shotgunPOINTBLANKconnect", humanoidRootPart, true)
		local position

		if cframe2 then
			position = cframe2.Position
		else
			position = v.Position
		end

		local raycastResult2 = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		task.wait(0.6)

		if humanoidRootPart.Parent == nil then
			return
		end

		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Slam", v, 4), Ouwmit.Owned(instance, v2))
		Cam_Shaker(v.Position, "Medium_tiny_shake_preset")

		if raycastResult2 then
			OuwCraters.Scales({
				Center = raycastResult2.Position,
				Radius = 5.5,
				Count = 4,
				ScaleMult = 1,
				OffsetMargin = 2
			})
		end

		task.wait(1.7333333333333334)

		if humanoidRootPart.Parent == nil then
			return
		end

		Shotgun_Swings.Flash(instance)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Shot", v, 4), Ouwmit.Owned(instance, v2))

		if raycastResult2 then
			OuwCraters.Scales({
				Center = raycastResult2.Position,
				Radius = 5,
				Count = 3,
				ScaleMult = 0.4,
				OffsetMargin = 3
			})
			OuwCraters.Scales({
				Center = raycastResult2.Position,
				Radius = 8,
				Count = 5,
				ScaleMult = 0.6,
				OffsetMargin = 4
			})
		end

		Cam_Shaker(position, "medium_shake_preset")
	end
end