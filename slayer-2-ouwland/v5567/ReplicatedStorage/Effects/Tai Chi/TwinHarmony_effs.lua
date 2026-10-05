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
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(instance, p: string)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	if p == "Start" then
		local v = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "TeleportLines", humanoidRootPart.CFrame, 3)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
		end

		task.delay(0.2, function()
			if humanoidRootPart.Parent == nil then
				return
			end

			local asset2 = vfxUtility.cloneAsset(script2, workspace.Debree, "Spinthing", humanoidRootPart.CFrame, 5)

			if asset2 then
				Ouwmit.Emit(asset2, Ouwmit.Owned(instance, v))
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
		end)
		vfxUtility.PlaySound(script.Sounds, "PS2taichiTWINHARMONYstart", humanoidRootPart, true)
	elseif p == "BurstHit" then
		local asset = vfxUtility.cloneAsset(script2, workspace.Debree, "Cross", humanoidRootPart.CFrame, 3)

		if asset then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.3,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.3, 0.3, 0.3),
			PositionInfluence = createVector(4, 4, 4)
		})
		vfxUtility.PlaySound(script.Sounds, "PS2taichiTWINHARMONYlaunch", humanoidRootPart, true)
	end
end