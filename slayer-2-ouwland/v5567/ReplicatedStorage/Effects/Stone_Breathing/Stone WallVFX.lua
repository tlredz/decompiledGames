local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
game:GetService("TweenService")
require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p: string)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil and p ~= "Cancel" or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 and p ~= "Cancel" then
		return
	end

	local formatted = `{instance.Name}-{script.Name}`
	local child = workspace.Debree:FindFirstChild(formatted)

	if p == "Wall" then
		if child ~= nil then
			child:Destroy()
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = formatted
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 10)
		local clone = script.Skill.Slash1:Clone()
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
		DebrisModule:AddItem(clone, 4.5)
		local clone2 = script.NoneHoldSounds.PS2stoneSERPENTINEBIPOLARvariant2SWING:Clone()
		clone2.Parent = clone.HumanoidRootPart1
		clone2:Play()
		task.wait(0.1)
		local clone3 = script.Skill.Rocks:Clone()
		clone3:PivotTo(humanoidRootPart.CFrame)
		clone3.Parent = configuration
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult2 = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v2 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil

		local function colorMeshPartsToGroundDust(folder, humanoidRootPart2)
			local cFrame3 = humanoidRootPart2.CFrame
			local raycastResult3 = workspace:Raycast(
				cFrame3.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)

			if not raycastResult3 then
				return
			end

			local dustColorSettings = vfxUtility.GetDustColorSettings(raycastResult3.Instance)

			if not dustColorSettings then
				return
			end

			for _, part in ipairs(folder:GetDescendants()) do
				if not part:IsA("MeshPart") then
					continue
				end

				part.Color = dustColorSettings.Color
				part.Material = raycastResult3.Instance.Material
			end
		end

		colorMeshPartsToGroundDust(clone3, humanoidRootPart)
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone3, 3.5)
		local clone4 = script.NoneHoldSounds.PS2stoneSERPENTINEBIPOLARvariant2SLAM:Clone()
		clone4.Parent = clone3.HumanoidRootPart
		clone4:Play()
		task.delay(0.4, function()
			local clone5 = script.Skill.Jump:Clone()
			clone5:PivotTo(humanoidRootPart.CFrame)
			clone5.Parent = configuration
			local cFrame3 = humanoidRootPart.CFrame
			local raycastResult3 = workspace:Raycast(
				cFrame3.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v3 = raycastResult3 and vfxUtility.GetDustColorSettings(raycastResult3.Instance) or nil
			Ouwmit.Emit(clone5, Ouwmit.Owned(instance, v3))
			DebrisModule:AddItem(clone5, 3.5)
		end)
	elseif p == "Break" then
		if child == nil then
			return
		end

		child.Name = "--"
		local clone = script.Skill.Throw:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = child
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

		local function colorParticleEmittersToGroundDust(folder, p2)
			if typeof(p2) ~= "table" or typeof(p2.Color) ~= "Color3" then
				warn("colorParticleEmittersToGroundDust: invalid dust settings, got:", p2)
				return
			end

			local colorSequence = ColorSequence.new(p2.Color)

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Color = colorSequence
				end
			end
		end

		colorParticleEmittersToGroundDust(clone.HitGround.DustRaycasts.Debris.Part, v)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone, 7)
		local clone2 = script.NoneHoldSounds.PS2stoneSERPENTINEBIPOLARvariant2EXPL:Clone()
		clone2.Parent = clone.Throw
		clone2:Play()
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end