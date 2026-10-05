local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script:FindFirstChild("Sounds")
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Soryu["Bone Breaker"].Config)
return function(instance, p: string, instance2, p2)
	if not (instance ~= nil and p ~= "Cancel") then
		return
	end

	if p == "Start" then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		local v = instance2 or humanoidRootPart.CFrame
		local rightHand = instance:FindFirstChild("RightHand")
		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		vfxUtility.PlaySound(sounds, "PS2soryuBONEBREAKERinit", humanoidRootPart, true)

		if rightHand then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, rightHand, "StanceHand", nil, 4), Ouwmit.Owned(instance, v2))
		end

		task.wait(0.5)
		local raycastResult2 = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3

		if raycastResult2 then
			v3 = vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
		end

		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "HitGround", v, 4), Ouwmit.Owned(instance, v3))
		Cam_Shaker(v.Position, "Medium_tiny_shake_preset")

		if raycastResult2 then
			OuwCraters.Scales({
				Center = CFrame.new(raycastResult2.Position),
				Radius = 6,
				Count = 4,
				ScaleMult = 0.75,
				OffsetMargin = 3
			})
		end

		task.wait(0.2)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "WindCharge", v, 4), Ouwmit.Owned(instance, v3))
	elseif p == "Grab" then
		if instance2 == nil or p2 == nil then
			return
		end

		local leftHand = instance2:FindFirstChild("LeftHand")
		local raycastResult = workspace:Raycast(
			p2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "Lines", p2 * CFrame.new(0, 0, -2), 4),
			Ouwmit.Owned(instance, v)
		)
		local part = leftHand or instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if part and part:IsA("BasePart") then
			vfxUtility.PlaySound(sounds, "PS2soryuBONEBREAKERconnect", part, true)
		end

		if leftHand then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, leftHand, "HandPressure", nil, 4), Ouwmit.Owned(instance, v))
		end

		task.wait(Config.SNAP_AT - 0.05)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Reach", p2, 4), Ouwmit.Owned(instance, v))
		task.wait(0.05)

		if leftHand and leftHand.Parent then
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, leftHand, "SnapImpact", nil, 4), Ouwmit.Owned(instance, v))
		end

		Cam_Shaker(p2.Position, "activate_shakelessaggresive")
		task.wait(Config.THROW_AT - Config.SNAP_AT - 0.2)
		local v2 = p2 * CFrame.new(0, -2.5, -5.5)
		local raycastResult2 = workspace:Raycast(
			v2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Dust", v2, 4), Ouwmit.Owned(instance, v3))
		task.wait(0.2)
		Ouwmit.Emit(
			vfxUtility.cloneAsset(assets, workspace.Debree, "Throw", p2 * CFrame.new(0, 0, 1.3), 4),
			Ouwmit.Owned(instance, v3)
		)
		Cam_Shaker(p2.Position, "medium_shake_preset")
	end
end