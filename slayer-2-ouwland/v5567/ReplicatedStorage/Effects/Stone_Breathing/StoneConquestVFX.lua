local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
return function(instance, p: string)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 150 then
		return
	end

	if p == "Slice1" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Slice1"}`
		DebrisModule:AddItem(configuration, 2)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Skill.Slash1:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = configuration
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
	elseif p == "Slice2" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Slice2"}`
		DebrisModule:AddItem(configuration, 3)
		local cFrame = humanoidRootPart.CFrame
		local clone = script.Skill.Slash2:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = configuration
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -5, RaycastHelper.Crater)
		local v

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			v = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(v)))
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		task.wait(0.1)
		task.spawn(function()
			TokenKit.GroundRocks({
				CF = clone.GroundImpact.CFrame,
				InnerRadius = 5,
				OuterRadius = 10,
				Velocity = {
					Min = 5,
					Max = 20
				},
				Amount = 20,
				Size = {
					Min = 0.5,
					Max = 2
				}
			})
		end)
		Cam_Shaker(clone.GroundImpact.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.45,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		OuwCraters.Scales({
			Center = clone.GroundImpact.CFrame,
			ScaleMult = 0.75,
			OffsetMargin = 6,
			Count = 5
		})
		local raycastResult2 = workspace:Raycast(
			clone.GrabRock.FX.Position + createVector(0, 5, 0),
			createVector(-0, -5, -0),
			RaycastHelper.Crater
		)

		if raycastResult2 then
			clone.GrabRock.FX.CFrame = CFrame.new(
				raycastResult2.Position,
				raycastResult2.Position - raycastResult2.Normal
			) * CFrame.Angles(1.5707963267948966, 0, 0)
			local _ = raycastResult2.Instance.Color
		end
	elseif p == "Spin" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Spin"}`
		DebrisModule:AddItem(configuration, 2)
		local clone = script.Skill.Slash3:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.PS2stoneSTONECOMBOswing3:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -5, -0),
			RaycastHelper.Crater
		)
		local v

		if raycastResult and raycastResult.Instance.Color ~= nil then
			v = raycastResult.Instance.Color
		end

		Ouwmit.Emit(clone, Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(v)))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
	elseif p == "Slice3" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Slice3"}`
		DebrisModule:AddItem(configuration, 2.5)
		local clone = script.Skill.Slash4:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.PS2stoneSTONECOMBOswing4:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		task.wait(0.1)
		local clone3 = script.Hit2:Clone()
		clone3.Parent = clone.GroundImpact
		clone3:Play()
		task.spawn(function()
			TokenKit.GroundRocks({
				CF = clone.GroundImpact.CFrame,
				InnerRadius = 5,
				OuterRadius = 10,
				Velocity = {
					Min = 5,
					Max = 20
				},
				Amount = 20,
				Size = {
					Min = 0.5,
					Max = 2
				}
			})
		end)
		Cam_Shaker(clone.GroundImpact.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.45,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		OuwCraters.Scales({
			Center = clone.GroundImpact.CFrame,
			ScaleMult = 0.75,
			OffsetMargin = 6,
			Count = 5
		})
	end
end