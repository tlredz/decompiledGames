local createVector = vector.create
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
return function(instance, instance2)
	if instance ~= nil and instance2 ~= nil then
		if (instance.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 350 then
			return
		end

		local clone = script.bhit:Clone()
		local cFrame, v

		if Utility.IsMeshRig(instance2.Parent) then
			cFrame = instance.CFrame * CFrame.new(0, 0, gameSettings.rigHitEffectOffset)
			v = instance
		else
			cFrame = instance2.CFrame
			v = instance2
		end

		local weldConstraint = clone:FindFirstChildWhichIsA("WeldConstraint") or clone:FindFirstChildWhichIsA("Weld")

		if weldConstraint ~= nil then
			weldConstraint:Destroy()
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CFrame = cFrame
		clone.Parent = workspace.Debree
		local dustRaycast = clone:FindFirstChild("DustRaycast", true)

		if dustRaycast ~= nil and dustRaycast:IsA("Attachment") then
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
		local sound = clone:FindFirstChild("Sound", true)

		if sound ~= nil then
			sound:Play()
		end

		local pointLight = clone:FindFirstChildWhichIsA("PointLight", true)

		if pointLight ~= nil then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 0
			}):Play()
		end

		DebrisModule:AddItem(clone, 2.4)

		if game.Players.LocalPlayer.Character == instance.Parent or game.Players.LocalPlayer.Character == instance2.Parent then
			Cam_Shaker(instance.Position, "tinyshake_preset")
		end
	end
end