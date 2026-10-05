local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local resume = coroutine.resume
local create = coroutine.create
local cameraShaker = Util.CameraShaker
TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
return function(data)
	local DISTANCE_THRESHOLD = 800
	local subEffect = data.SubEffect or 1

	if subEffect == 1 then
		local boolean = data.Boolean
		local rightHand = data.RightHand

		if rightHand then
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
			TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)

			if boolean == true then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > DISTANCE_THRESHOLD then
					return
				end

				local clone = script.ClawHold:Clone()
				clone.CFrame = rightHand.CFrame
				clone.Parent = rightHand
				local play = Util.Sound:Play("Mera_FireLoop", clone)
				play.Looped = true
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Name = "ClawHoldweldhold"
				weldConstraint.Parent = clone
				weldConstraint.Part0 = rightHand
				weldConstraint.Part1 = clone
			else
				local clawHold = rightHand:FindFirstChild("ClawHold")

				if clawHold then
					clawHold.Name = ""

					if clawHold:FindFirstChild("Mera_FireLoop") then
						sound:FadeOut(clawHold.Mera_FireLoop, 0.3)
					end

					for _, emitter in pairs(clawHold:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(1, function()
						clawHold:Destroy()
					end)
				end
			end
		end
	elseif subEffect == 2 then
		local cFrame = data.CFrame
		local rootPart = data.RootPart

		if rootPart then
			if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > DISTANCE_THRESHOLD then
				return
			end

			local clone = script.WindMesh:Clone()
			clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = _WorldOrigin
			TweenService:Create(clone, tweenInfo, {
				Size = createVector(0.001, 0.001, 32.719),
				Transparency = 1
			}):Play()
			debris:AddItem(clone, 2)
			local clone2 = script.Long_Smoke_Part1:Clone()
			clone2.Parent = _WorldOrigin
			clone2.CFrame = cFrame
			debris:AddItem(clone2, 4)
			local clone3 = script.Long_Smoke_Part2:Clone()
			clone3.CFrame = cFrame * CFrame.new(0, -1, -9)
			clone3.Parent = _WorldOrigin
			clone3.Rocks:Emit(9)
			clone3.ParticleEmitter:Emit(15)
			clone3.Partic2leEmitter:Emit(12)
			debris:AddItem(clone3, 4)
			local position = (rootPart.CFrame * CFrame.new(0, 0, -10)).Position
			local ray, v, _ = Util.Ray(
				position,
				CFrame.new(position).upVector.Unit * -15,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				local clone4 = script.Long_Smoke_Part:Clone()
				clone4.CFrame = CFrame.new(v)
				clone4.Parent = _WorldOrigin
				debris:AddItem(clone4, 4)
				clone4.ParticleEmitter:Emit(11)
				clone4.ParticleEmitter.Color = ColorSequence.new(ray.Color)
				clone4.Rocks:Emit(11)
				clone4.Rocks.Color = ColorSequence.new(ray.Color)
				clone2.ParticleEmitter:Emit(11)
				clone2.ParticleEmitter.Color = ColorSequence.new(ray.Color)
				clone2.Rocks:Emit(11)
				clone2.Rocks.Color = ColorSequence.new(ray.Color)
			end

			task.wait(0.05)
			local clone4 = script.FireExplosion:Clone()
			debris:AddItem(clone4, 4)
			clone4.CFrame = cFrame * CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966) * CFrame.new(0, 65, 0)
			clone4.Parent = _WorldOrigin
			Util.Sound:Play("Fire move", clone4)
			task.delay(0.4, function()
				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - clone4.Position).Magnitude < 150 then
				cameraShaker:Shake(Util.CameraShaker.Presets.Bump)
			end

			resume(create(function()
				for _ = 1, 1 do
					local clone5 = script.Ring:Clone()
					clone5.CFrame = cFrame * CFrame.new(0, 0, -58) * CFrame.Angles(
						1.5707963267948966,
						3.141592653589793,
						0
					)
					clone5.Parent = _WorldOrigin
					debris:AddItem(clone5, 4)
					TweenService:Create(clone5, tweenInfo2, {
						Size = createVector(25.522, 0.582, 25.916),
						Transparency = 1
					}):Play()
					task.wait(0.1)
				end
			end))
		end
	elseif subEffect == 3 then
		local cFrame = data.CFrame

		if data.RootPart then
			if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > DISTANCE_THRESHOLD then
				return
			end

			local clone = script.Shock:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 0, -(data.Offset + 10))
			clone.Orientation += createVector(90, 0, 0)
			clone.Parent = _WorldOrigin
			TweenService:Create(clone, tweenInfo3, {
				Size = createVector(0.001, 21.886, 0.001)
			}):Play()
			debris:AddItem(clone, 2)
			local clone2 = script.particles:Clone()
			clone2.CFrame = cFrame * CFrame.new(0, 0, -data.Offset)
			clone2.Parent = _WorldOrigin
			debris:AddItem(clone2, 4)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone3 = script.FireExplosion1:Clone()
			clone3.CFrame = cFrame * CFrame.new(0, -1, -(data.Offset + 10)) * CFrame.Angles(
				0,
				-1.5707963267948966,
				1.5707963267948966
			)
			clone3.Parent = _WorldOrigin
			local play_2 = Util.Sound:Play("Flame explosion", clone3)
			play_2.TimePosition = 1.411
			debris:AddItem(clone3, 4)
			task.delay(0.3, function()
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone4 = script.Long_Smoke_Part2:Clone()
			clone4.CFrame = cFrame * CFrame.new(0, -1, -data.Offset)
			clone4.Parent = _WorldOrigin
			clone4.Rocks:Emit(9)
			clone4.ParticleEmitter:Emit(15)
			clone4.Partic2leEmitter:Emit(12)
			debris:AddItem(clone4, 4)

			if (workspace.CurrentCamera.CFrame.Position - clone3.Position).Magnitude < 80 then
				cameraShaker:Shake(Util.CameraShaker.Presets.Bump)
			end
		end
	end
end