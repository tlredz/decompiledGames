local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local TweenService = game:GetService("TweenService")
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p: string, instance2)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 and p ~= "Cancel" then
		return
	end

	local spiral = humanoidRootPart:FindFirstChild("Spiral")

	if spiral ~= nil then
		vfxUtility.EnableAll(spiral, false)
		spiral.Name = "--"
		DebrisModule:AddItem(spiral, 1.5)
	end

	if p == "Start" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Start"}`
		DebrisModule:AddItem(configuration, 3)
		local clone = script.Skill.Slash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARstart:Clone()
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		local clone3 = script.Attachments.Spiral:Clone()
		clone3.Parent = humanoidRootPart
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 6)
		local clone4 = nil
		local isAxeAndMaceWeapon = instance:FindFirstChild("IsAxeAndMaceWeapon", true)

		if isAxeAndMaceWeapon ~= nil then
			local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball

			if ball ~= nil then
				clone4 = script.Attachments.SpikeSpin:Clone()
				clone4.Parent = ball
				vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
				task.delay(0.15, function()
					for _, beam in clone4:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						TweenService:Create(beam, TweenInfo.new(0.3), {
							TextureLength = 0
						}):Play()
						local v2 = beam
						task.delay(0.05, function()
							TweenService:Create(v2, TweenInfo.new(0.3), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end)
					end
				end)
			end
		end

		local clone5 = script.RotatingThing:Clone()
		clone5.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
		clone5.Parent = configuration
		vfxUtility.EnableAll(clone5, vfxUtility.GetDustColorSettings(Col), vfxUtility.Owned(instance))
		task.spawn(function()
			local cam_Shaker = Cam_Shaker(clone3, {
				FadeInTime = 0.2,
				Frequency = 0.25,
				Amplitude = 0.15,
				SustainTime = 4,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.15, 0.15, 0.15),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			local clone6 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARloop:Clone()
			clone6.Parent = clone3
			clone6:Play()

			while clone3 ~= nil and clone3.Parent ~= nil and clone3.Name ~= "--" do
				TweenService:Create(clone5, TweenInfo.new(0.4), {
					CFrame = clone5.CFrame * CFrame.Angles(0, -3.839724354387525, 0)
				}):Play()
				task.wait(0.2)
			end

			TweenService:Create(clone6, TweenInfo.new(1), {
				Volume = 0
			}):Play()
			cam_Shaker:Destroy()

			if clone4 ~= nil then
				vfxUtility.EnableAll(clone4, false)
				DebrisModule:AddItem(clone4, 1.5)
			end

			DebrisModule:AddItem(clone5, 2)
			vfxUtility.EnableAll(clone5, false)
			TweenService:Create(clone5, TweenInfo.new(1), {
				CFrame = clone5.CFrame * CFrame.Angles(0, -3.839724354387525, 0)
			}):Play()
		end)
	elseif p == "Miss" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Miss"}`
		DebrisModule:AddItem(configuration, 3)
		local clone = script.Skill.Slash:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARswing:Clone()
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
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Hit" then
		if instance2 == nil then
			return
		end

		local humanoidRootPart2 = instance2:WaitForChild("HumanoidRootPart")

		if humanoidRootPart2 == nil then
			return
		end

		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{p}`
		DebrisModule:AddItem(configuration, 3)
		local clone = script.HitFx:Clone()
		clone.CFrame = humanoidRootPart2.CFrame
		clone.Parent = configuration
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		local clone2 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARgrab:Clone()
		clone2.Parent = clone
		clone2:Play()
		local clone3 = script.Skill.Slash:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame)
		clone3.Parent = configuration
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v))
		task.delay(0.4, function()
			local clone4 = script.Skill.Slash1:Clone()
			clone4:PivotTo(humanoidRootPart.CFrame)
			clone4.Parent = configuration
			local clone5 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARstart:Clone()
			clone5.Parent = clone4.PrimaryPart
			clone5:Play()
			local cFrame2 = humanoidRootPart.CFrame
			local raycastResult2 = workspace:Raycast(
				cFrame2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v2 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			Ouwmit.Emit(clone4, Ouwmit.Owned(instance, v2))
		end)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.25,
			Amplitude = 0.45,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local isAxeAndMaceWeapon = instance:FindFirstChild("IsAxeAndMaceWeapon", true)

		if isAxeAndMaceWeapon ~= nil then
			local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball

			if ball ~= nil then
				local clone4 = script.Attachments.balldustAttach:Clone()
				clone4.Parent = ball
				DebrisModule:AddItem(clone4, 2)
				local raycastResult2 = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)

				if raycastResult2 then
					vfxUtility.EmitAll(
						clone4,
						vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
					)
				else
					vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
				end

				vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
				task.wait(0.8)
				vfxUtility.EnableAll(clone4, false)
			end
		end
	elseif p == "Slam" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		configuration.Name = `{script.Name}-{"Slam"}`
		DebrisModule:AddItem(configuration, 5)
		local clone = script.Skill.Slash2:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = configuration
		local clone2 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARstart:Clone()
		clone2.Parent = clone.GroundImpact
		clone2:Play()
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		local clone3 = script.HoldVariantSounds.PS2stoneSERPENTINEBIPOLARslam:Clone()
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
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.7,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		OuwCraters.Scales({
			Center = clone.GroundImpact.CFrame
		})
	end
end