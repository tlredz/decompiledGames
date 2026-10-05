local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p: string, cframe)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 then
		return
	end

	if p == "Start" then
		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame.Position, "activate_shake")
		local upperTorso = instance:FindFirstChild("UpperTorso")

		if upperTorso ~= nil then
			local clone = script.SkillAssets.Init["Root/TorsoEnable"]:Clone()
			clone.Parent = upperTorso
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone, 2)
		end

		local clone = script.SkillAssets.Init.Startup:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -8, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		}))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.Sounds.PS2reaperSKILL1and2init:Clone()
		clone2.Parent = clone.Root
		clone2:Play()
		DebrisModule:AddItem(clone2, clone2.TimeLength)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Disappear" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Disappear"}`
		DebrisModule:AddItem(configuration, 3)
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone = script.SkillAssets.Intensitylines:Clone()
		clone.Parent = configuration
		local clone2 = script.Sounds.PS2reaperSKILL1disappear:Clone()
		clone2.Parent = clone
		clone2:Play()
		clone.CFrame = cframe * CFrame.new(0, -1.5, 0)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		local clone3 = script.SkillAssets.Vanish:Clone()
		clone3.Parent = configuration
		clone3.CFrame = cframe * CFrame.new(0, -1.5, 0)
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
	elseif p == "ReAppear" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"ReAppear"}`
		DebrisModule:AddItem(configuration, 3)
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone = script.SkillAssets.Intensitylines:Clone()
		clone.Parent = configuration
		clone.CFrame = cframe * CFrame.new(0, -1.5, 0)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		task.wait(0.1)
		local clone2 = script.SkillAssets.Vanish:Clone()
		clone2.Parent = configuration
		clone2.CFrame = cframe * CFrame.new(0, -1.5, 0)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
	elseif p == "Updraft" then
		local clone = script.SkillAssets.Uptilt1:Clone()
		clone:PivotTo(cframe)
		clone.Parent = workspace.Debree
		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		end

		DebrisModule:AddItem(clone, 3)
		local clone2 = script.Sounds.PS2reaperSKILL1updraft:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.4,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
	elseif p == "Air" then
		if cframe == nil or cframe.Parent == nil then
			return
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{p}`
		DebrisModule:AddItem(configuration, 4)
		local clone = script.SkillAssets.Hit2:Clone()
		clone:PivotTo(cframe.CFrame)
		clone.Parent = configuration
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		task.wait(0.375)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		local clone2 = script.SkillAssets.SpinAttack:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = configuration
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.185,
			Amplitude = 0.1,
			SustainTime = 0.7,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone3 = script.Sounds.PS2reaperSKILL1combo:Clone()
		clone3.Parent = humanoidRootPart
		clone3:Play()
		DebrisModule:AddItem(clone3, clone3.TimeLength)
		task.delay(0.2, function()
			vfxUtility.EnableAll(clone2, false)
		end)
		TweenService:Create(clone2.Slash, TweenInfo.new(0.3), {
			CFrame = clone2.Slash.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		}):Play()
		task.delay(0.05, function()
			for _, beam in clone2.Slash:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.1), {
					TextureLength = 0
				}):Play()
				local v = beam
				task.delay(0.05, function()
					TweenService:Create(v, TweenInfo.new(0.1), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
		task.delay(0.016666666666666666, function()
			if cframe == nil or cframe.Parent == nil then
				return
			end

			local clone4 = script.SkillAssets.Hit1:Clone()
			clone4:PivotTo(cframe.CFrame)
			clone4.Parent = configuration
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
			task.wait(0.05)
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		end)
		task.wait(0.6416666666666667)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		local clone4 = script.SkillAssets.FinalHit:Clone()
		clone4:PivotTo(humanoidRootPart.CFrame)
		clone4.Parent = configuration
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		end

		TweenService:Create(clone4.Slash, TweenInfo.new(0.3), {
			CFrame = clone4.Slash.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		local clone5 = script.Sounds.PS2reaperCOMBOENDSLAM2:Clone()
		clone5.Parent = clone4.HumanoidRootPart
		clone5:Play()
		task.delay(0.15, function()
			for _, beam in clone4.Slash:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.1), {
					TextureLength = 0
				}):Play()
				local v = beam
				task.delay(0.05, function()
					TweenService:Create(v, TweenInfo.new(0.1), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
	elseif p == "Slam" then
		if cframe == nil then
			return
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{p}`
		DebrisModule:AddItem(configuration, 5)
		local clone = script.SkillAssets.MaceHit:Clone()
		clone.Parent = configuration
		local clone2 = script.Sounds.Slam:Clone()
		clone2.Parent = clone
		clone2:Play()
		clone.CFrame = cframe * CFrame.new(-0.186, -1.536, -1.539) * CFrame.Angles(-0, -1.571, 0)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 3, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		end

		Cam_Shaker(clone.Position, "medium_shake_preset")
		OuwCraters.Scales({
			Center = clone.CFrame,
			ScaleMult = 0.8,
			Count = 6,
			Radius = 10,
			OffsetMargin = 6
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 10,
			OuterRadius = 20,
			Lifetime = 0.3,
			Velocity = {
				Min = 10,
				Max = 20
			},
			Size = {
				Min = 0.2,
				Max = 0.7
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "AirVariant1st" then
		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local clone = script.SkillAssets.InAir1:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		local clone2 = script.Sounds:FindFirstChild("PS2reaperSKILL1VAR2slash" .. cframe):Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end