local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(modules.Effects.Ouwmit)
local vfxUtility = require(modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local script2 = script
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(humanoidRootPart)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(instance, p: string)
	if not (instance ~= nil and p ~= "Cancel") then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Initial" then
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Initial", humanoidRootPart.CFrame, 5)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart)))
		end

		vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesCROSSREAVERinitiate", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Throw" then
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Dash", humanoidRootPart.CFrame, 5)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart)))
		end

		local asset2 = vfxUtility.cloneAsset(
			script2,
			workspace.Debree,
			"Skill",
			humanoidRootPart.CFrame * CFrame.new(0, 0, -8),
			5
		)

		if asset2 then
			Ouwmit.Emit(asset2, Ouwmit.Owned(instance, groundDust(humanoidRootPart)))
		end

		vfxUtility.PlaySound(script2.Sounds, "PS2reapingbladesCROSSREAVERlaunch", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 0.65,
			SustainTime = 0.3,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.5, 0.5, 0.5),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	end
end