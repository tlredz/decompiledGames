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

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyRig(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}-BuckShotWindBeams`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

return function(instance, p: string, cframe: CFrame?, cframe2: CFrame?)
	if instance == nil then
		return
	end

	destroyRig(instance) -- equivalent call inferred; original call site unknown

	if p == "Cancel" or p == "Start" then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local v = cframe or humanoidRootPart.CFrame
	local v2

	if p ~= "Kick" then
		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	end

	if p == "Shot" then
		vfxUtility.PlaySound(script.Sounds, "PS2shotgunBUCKSHOTshoot", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Shot", v, 4), Ouwmit.Owned(instance, v2))
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Dash", v, 4), Ouwmit.Owned(instance, v2))
		local asset = vfxUtility.cloneAsset(assets, workspace.Debree, "WindBeams", humanoidRootPart.CFrame, 8)

		if asset then
			asset.Name = `{instance.Name}-BuckShotWindBeams`
			asset.Anchored = false
			asset.Massless = true
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = humanoidRootPart
			weldConstraint.Part1 = asset
			weldConstraint.Parent = asset
			vfxUtility.EnableAll(asset, true, vfxUtility.Owned(instance))
		end

		Cam_Shaker(v.Position, "activate_shake")
	elseif p == "Kick" then
		vfxUtility.PlaySound(script.Sounds, "PS2shotgunBUCKSHOTspin", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Spin", v, 4), Ouwmit.Owned(instance, v2))
		Cam_Shaker(v.Position, "Medium_tiny_shake_preset")
	elseif p == "Slam" then
		vfxUtility.PlaySound(script.Sounds, "PS2shotgunBUCKSHOTslam", humanoidRootPart, true)
		Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, "Slam", v, 4), Ouwmit.Owned(instance, v2))
		local position

		if cframe2 then
			position = cframe2.Position
		else
			position = v.Position
		end

		local raycastResult = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			local cframe3 = CFrame.new(raycastResult.Position)
			OuwCraters.Scales({
				Center = cframe3,
				Radius = 4,
				Count = 7,
				ScaleMult = 0.4,
				OffsetMargin = 3
			})
			OuwCraters.Scales({
				Center = cframe3,
				Radius = 6,
				Count = 9,
				ScaleMult = 0.6,
				OffsetMargin = 4
			})
		end

		Cam_Shaker(position, "medium_shake_preset")
	end
end