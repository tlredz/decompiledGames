local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local children = script.Explosion:GetChildren()
local tweenInfo = TweenInfo.new(1.2)
return function(instance, p: string, _, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p == "Start" and vector.magnitude(humanoidRootPart.Position - currentCamera.CFrame.Position) >= 200 then
		return
	end

	if p == "Start" then
		local formatted = `{instance.Name}-{script.Name}`
		local clone = script.RunFX:Clone()
		clone.Name = formatted
		local weld = Instance.new("Weld", clone.Root)
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone.Root
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 10)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart.CFrame.upVector * -8,
			RaycastHelper.Crater
		)
		Ouwmit.Enable(
			clone,
			true,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.13,
			Amplitude = 0.5,
			SustainTime = 6,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.4, 0.4, 0.4)
		})
		local v2 = vfxUtility.PlaySound(script.Sounds, "PS2soundSTRINGPERFORMANCElooprun", humanoidRootPart, false)

		while clone ~= nil and clone.Name == formatted and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil do
			local clone2 = children[math.random(1, 2)]:Clone()
			clone2.Parent = clone.Root
			clone2.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(
				math.random(-12, 12),
				math.random(1, 5),
				math.random(-18, 4)
			)
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			task.wait(0.05)
		end

		cam_Shaker:Destroy()

		if v2 then
			TweenService:Create(v2, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(v2, 0.35)
		end
	else
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-{script.Name}`))

		if child ~= nil then
			child.Name = "--"
			DebrisModule:AddItem(child, 3)
			Ouwmit.Enable(child, false)
		end

		if p == "Grab" then
			vfxUtility.PlaySound(script.Sounds, "PS2soundSTRINGPERFORMANCEcombo", humanoidRootPart, true)
			local configuration = Instance.new("Configuration", workspace.Debree)
			configuration.Name = "StringPerformanceGrab"
			DebrisModule:AddItem(configuration, 6.5)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.upVector * -8,
				RaycastHelper.Crater
			)
			local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			task.wait(0.16)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			local clone = script.Cutscene.UserFX:Clone()
			clone.Parent = configuration
			clone:PivotTo(humanoidRootPart.CFrame)
			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
			task.wait(0.5)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			Ouwmit.Enable(clone, false)
			local clone2 = script.Cutscene.Dash:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			Ouwmit.Emit(clone2.Emit, Ouwmit.Owned(instance, v))
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.25,
				Amplitude = 1.15,
				SustainTime = 0.2,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})

			for _, beam in {
				clone2.WindBeams.Attachment.FrontSet.Back.BigRightBeam,
				clone2.WindBeams.Attachment.FrontSet.Back.Right,
				clone2.WindBeams.Attachment.FrontSet.Back2.BigRightBeam,
				clone2.WindBeams.Attachment.FrontSet.Back2.Right
			} do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				TweenService:Create(beam, TweenInfo.new(0.755, Enum.EasingStyle.Sine), {
					LightEmission = 1,
					Brightness = 0
				}):Play()
				TweenService:Create(beam, TweenInfo.new(0.755, Enum.EasingStyle.Quint), {
					TextureLength = 0.3,
					TextureSpeed = 0.2
				}):Play()
			end

			task.wait(0.9099999999999999)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			Ouwmit.Enable(clone2["Mutli-Slash"], true, Ouwmit.Owned(instance))
			local clone3 = script.Cutscene.SpinFX:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart.Parent:FindFirstChild("LowerTorso")
			weld.Part1 = clone3.SpinFX
			weld.Parent = clone3.SpinFX
			clone3.Parent = configuration
			Ouwmit.Enable(clone3, true, Ouwmit.Owned(instance))
			local v2 = true
			task.spawn(function()
				local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0.1,
					Frequency = 0.15,
					Amplitude = 0.45,
					SustainTime = 4,
					FadeOutTime = 0.2,
					RotationInfluence = createVector(0.15, 0.15, 0.15),
					PositionInfluence = createVector(0.6, 0.6, 0.6)
				})

				while v2 and configuration ~= nil and configuration.Parent ~= nil and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil do
					local clone4 = children[math.random(1, 2)]:Clone()
					clone4.Parent = humanoidRootPart
					clone4.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(
						math.random(-12, 12),
						math.random(1, 5),
						math.random(-18, 4)
					)
					Ouwmit.Emit(clone4, Ouwmit.Owned(instance))
					DebrisModule:AddItem(clone4, 2.8)
					task.wait(0.05)
				end

				cam_Shaker:Destroy()
				Ouwmit.Enable(clone3, false)
				Ouwmit.Enable(clone2["Mutli-Slash"], false)
			end)
			task.wait(0.72)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			v2 = false
			task.wait(0.2400000000000002)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			local clone4 = script.Cutscene.Impact:Clone()
			clone4.Parent = configuration
			clone4:PivotTo(humanoidRootPart.CFrame)
			local landFX = clone4.LandFX
			landFX.Parent = configuration
			Ouwmit.Emit(landFX, Ouwmit.Owned(instance, v))
			task.wait(0.565)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				configuration:Destroy()
				return
			end

			Ouwmit.Emit(clone4, Ouwmit.Owned(instance, v))
			clone4.AfterExplosion.GroundExplosion.PointLight.Enabled = true
			TweenService:Create(clone4.AfterExplosion.GroundExplosion.PointLight, tweenInfo, {
				Brightness = 0
			}):Play()
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.2,
				Amplitude = 0.9,
				SustainTime = 0.15,
				FadeOutTime = 0.55,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end
	end
end