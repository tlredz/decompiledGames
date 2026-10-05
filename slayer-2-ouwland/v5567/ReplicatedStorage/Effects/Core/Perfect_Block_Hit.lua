local createVector = vector.create
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, instance2)
	if instance ~= nil and instance2 ~= nil then
		local clone = script.ParryVFX:Clone()
		local cFrame, v

		if Utility.IsMeshRig(instance2.Parent) then
			cFrame = instance.CFrame * CFrame.new(0, 0, gameSettings.rigHitEffectOffset)
			v = instance
		else
			cFrame = instance2.CFrame
			v = instance2
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CFrame = cFrame * CFrame.Angles(0, -1.5707963267948966, 0)
		clone.Parent = workspace.Debree
		local dustRaycast = clone:FindFirstChild("DustRaycast")

		if dustRaycast ~= nil then
			local raycastResult = workspace:Raycast(
				v.Position + createVector(0, 3, 0),
				createVector(0, -15, 0),
				raycastParams
			)

			if raycastResult ~= nil then
				dustRaycast.WorldPosition = raycastResult.Position
			end

			local changeDustColor = vfxUtility.ChangeDustColor
			local v2

			if raycastResult ~= nil then
				v2 = raycastResult.Instance or nil
			end

			changeDustColor(v2, dustRaycast)
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))

		if game.Players.LocalPlayer.Character == instance.Parent or game.Players.LocalPlayer.Character == instance2.Parent then
			Cam_Shaker(instance.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.45,
				SustainTime = 0.05,
				FadeOutTime = 0.25,
				RotationInfluence = createVector(0.1, 0.1, 0.1),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			local clone2 = script.ColorCorrection:Clone()
			clone2.Parent = workspace.Camera
			DebrisModule:AddItem(clone2, 0.55)
			TweenService:Create(clone2, tweenInfo2, {
				Saturation = 0,
				Contrast = 0
			}):Play()
		end

		local sound = clone:FindFirstChild("Sound", true)

		if sound ~= nil then
			sound:Play()
		end

		local pointLight = clone:FindFirstChildWhichIsA("PointLight", true)

		if pointLight ~= nil then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 0,
				Range = 0
			}):Play()
		end

		DebrisModule:AddItem(clone, 2)
	end
end