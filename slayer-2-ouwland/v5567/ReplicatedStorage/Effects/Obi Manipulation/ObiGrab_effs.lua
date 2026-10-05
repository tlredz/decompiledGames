local createVector = vector.create
game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
script:FindFirstChild("Rigs")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local token = modules.Effects.Token
local TokenKit = require(token.TokenKit)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
return function(instance, p: string, instance2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Miss" then
		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIGRABgrabSTART", humanoidRootPart, true)
		local clone = assets.Sweep:Clone()
		clone.Parent = debree
		clone:PivotTo(humanoidRootPart.CFrame)
		DebrisModule:AddItem(clone, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	elseif p == "Grabbed" then
		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIGRABgrabSTART", humanoidRootPart, true)

		if instance:FindFirstChild("RightFoot") == nil then
			return
		end

		vfxUtility.PlaySound(sounds, "PS2FleshManiOBIGRABslam", humanoidRootPart, true)
		local clone = assets.Grabbed:Clone()
		clone.Parent = debree
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.0373, -0.36, -7.508) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.57,
			0
		)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.delay(0.4, function() end)
		task.delay(0.6, function()
			local clone2 = assets.Jump:Clone()
			clone2.Parent = debree
			clone2:PivotTo(humanoidRootPart.CFrame)
			local cFrame2 = humanoidRootPart.CFrame
			local raycastResult2 = workspace:Raycast(
				cFrame2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v2))
			DebrisModule:AddItem(clone2, 4)
			Cam_Shaker(clone2.PrimaryPart.Position, {
				FadeInTime = 0.05,
				Frequency = 0.05,
				Amplitude = 0.05,
				SustainTime = 0.5,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			local leftFoot = instance2:FindFirstChild("LeftFoot") or instance2:FindFirstChild("Left Leg") or instance2:FindFirstChild("HumanoidRootPart")

			if leftFoot ~= nil then
				TokenKit.ParticlePull(assets.Footfx:Clone(), leftFoot, 1, 0.5)
			end

			local clone3 = assets.SpinFX.Slash1:Clone()
			clone3.Parent = humanoidRootPart
			vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone3, 3)
			Cam_Shaker(clone.Position, {
				FadeInTime = 0.05,
				Frequency = 0.05,
				Amplitude = 0.05,
				SustainTime = 0.5,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end)
		task.delay(1.5, function()
			local clone2 = assets.Hit:Clone()
			clone2.Parent = debree
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.8037, -2.47614, -7.95) * CFrame.fromEulerAnglesYXZ(
				-0,
				-1.57079,
				0
			))
			local cFrame2 = humanoidRootPart.CFrame
			local raycastResult2 = workspace:Raycast(
				cFrame2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v2))
			DebrisModule:AddItem(clone2, 6)
			Cam_Shaker(clone.Position, {
				FadeInTime = 0.1,
				Frequency = 0.5,
				Amplitude = 0.5,
				SustainTime = 0.1,
				FadeOutTime = 0.7,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			OuwCraters.Scales({
				Center = clone2.Hit.CFrame,
				Duration = 2.5,
				Radius = 9,
				ScaleMult = 0.75
			})
			task.spawn(function()
				TokenKit.GroundRocks({
					CF = clone2.PrimaryPart.CFrame,
					InnerRadius = 5,
					OuterRadius = 10,
					Velocity = {
						Min = 10,
						Max = 30
					},
					Size = {
						Min = 1,
						Max = 3
					}
				})
			end)
		end)
	end
end