local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
game:GetService("TweenService")
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p: string)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 then
		return
	end

	if p == "Throw" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-{script.Name}-{"Throw"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 3.5)
		local clone = script.Skill.Throw:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		local clone2 = script.ThrowSound:Clone()
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		Cam_Shaker(clone.Jump.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.1,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local isAxeAndMaceWeapon = instance:FindFirstChild("IsAxeAndMaceWeapon", true)

		if isAxeAndMaceWeapon ~= nil then
			local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball
			local axe = isAxeAndMaceWeapon.Parent.RootPart.Axe

			if ball ~= nil and axe ~= nil then
				local clone3 = script.HandTrail:Clone()
				clone3.Parent = ball
				task.wait(1)
				vfxUtility.EnableAll(clone3, false)
				DebrisModule:AddItem(clone3, 0.35)
			end
		end
	elseif p == "Explode" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-{script.Name}-{"Explode"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 6)
		local clone = script.Skill.Slash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -4))
		clone.Parent = configuration
		local clone2 = script.FirstExplosion:Clone()
		clone2.Parent = clone.GroundImpact
		clone2:Play()
		Cam_Shaker(clone.GroundImpact.Position, "activate_shake")
		OuwCraters.Scales({
			Center = clone.GroundImpact.CFrame,
			Duration = 2.5,
			Radius = 10,
			ScaleMult = 0.8
		})
		local cFrame = clone.GroundImpact.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
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
		task.wait(0.5)
		local clone3 = script.Skill.Slash2:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -4))
		clone3.Parent = configuration
		local cFrame2 = clone3.w.CFrame
		local raycastResult2 = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v2))
		Cam_Shaker(clone3.GroundImpact.Position, "activate_shakelessaggresive")
		local clone4 = script.ChainHit:Clone()
		clone4.Parent = clone3.GroundImpact
		clone4:Play()
		task.wait(0.3)
		task.spawn(function()
			TokenKit.GroundRocks({
				CF = clone3.w.CFrame,
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
		OuwCraters.Scales({
			Center = clone3.w.CFrame,
			Duration = 2.5,
			Radius = 15,
			ScaleMult = 1.25
		})
		Cam_Shaker(clone3.w.Position, "medium_shake_preset")
		task.wait(0.1)
		local clone5 = script.FianlHit:Clone()
		clone5.Parent = clone3.w
		clone5:Play()
	end
end