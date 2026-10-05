local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local resume = coroutine.resume
local create = coroutine.create
local cameraShaker = Util.CameraShaker
return function(data)
	local subEffect = data.SubEffect or 1

	if subEffect == 1 then
		local boolean = data.Boolean
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local rightHand = data.RightHand

		if rightHand then
			if boolean then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > 600 then
					return
				end

				local clone = script.WaterBall:Clone()
				clone.CFrame = rightHand.CFrame
				clone.Parent = rightHand
				TweenService:Create(clone, tweenInfo, {
					Size = createVector(1.8, 1.698, 1.779)
				}):Play()
				local vector2 = Vector3.new(math.random(4, 6) * 60, math.random(4, 6) * 60, math.random(4, 6) * 60)
				local vector3 = Vector3.new(math.random(4, 6) * 60, math.random(4, 6) * 60, math.random(4, 6) * 60)
				clone.Orientation = vector2
				TweenService:Create(clone, tweenInfo2, {
					Orientation = vector3 * 0.5
				}):Play()
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Name = "watearball1weld"
				weldConstraint.Parent = rightHand
				weldConstraint.Part0 = rightHand
				weldConstraint.Part1 = clone
			else
				if rightHand:FindFirstChild("WaterBall") then
					TweenService:Create(rightHand.WaterBall, tweenInfo3, {
						Size = Vector3.new()
					}):Play()

					for _, emitter in pairs(rightHand.WaterBall:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(0.7, function()
						if rightHand:FindFirstChild("WaterBall") then
							rightHand.WaterBall:Destroy()
						end
					end)
				end

				if rightHand:FindFirstChild("watearball1weld") then
					task.delay(0.7, function()
						if rightHand:FindFirstChild("watearball1weld") then
							rightHand.watearball1weld:Destroy()
						end
					end)
				end
			end
		end
	elseif subEffect == 2 then
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo3 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local v = data.CFrame * CFrame.new(0, 0, 25)
		local root = data.Root

		if root then
			if (workspace.CurrentCamera.CFrame.Position - v.Position).Magnitude > 600 then
				return
			end

			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, 5)
			attachment.Position = Vector3.new(0, root.Size.Y / 2, 0)
			attachment.Parent = root
			local attachment2 = Instance.new("Attachment")
			Util.Debris:AddItem(attachment2, 5)
			attachment2.Position = Vector3.new(0, -root.Size.Y / 2, 0)
			attachment2.Parent = root
			local clone = script.DashTrail:Clone()
			Util.Debris:AddItem(clone, 5)
			clone.Attachment0 = attachment2
			clone.Attachment1 = attachment
			clone.Parent = root
			task.delay(0.6, function()
				if clone then
					clone.Enabled = false
				end

				task.wait(0.6)

				for _, v3 in pairs({ attachment, attachment2, clone }) do
					if v3 ~= nil then
						v3:Destroy()
					end
				end
			end)
			local clone2 = script.WindMesh:Clone()
			debris:AddItem(clone2, 2)
			clone2.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, tweenInfo2, {
				Size = createVector(0.001, 0.001, 42.719),
				Transparency = 1
			}):Play()
			local position = (root.CFrame * CFrame.new(0, 0, -10)).Position
			local ray, v2, _ = Util.Ray(
				position,
				CFrame.new(position).upVector.Unit * -7,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				local clone3 = script.Long_Smoke_Part:Clone()
				debris:AddItem(clone3, 2)
				clone3.CFrame = CFrame.new(v2)
				clone3.Parent = _WorldOrigin
				clone3.ParticleEmitter:Emit(11)
				clone3.ParticleEmitter.Color = ColorSequence.new(ray.Color)
				clone3.Rocks:Emit(8)
				clone3.Rocks.Color = ColorSequence.new(ray.Color)
			end

			task.wait(0.25)
			local clone3 = script.TongueStab:Clone()
			debris:AddItem(clone3, 3)
			clone3.CFrame = v * CFrame.new(0, -1, -26)
			clone3.Orientation += createVector(0, 0, 0)
			clone3.Parent = _WorldOrigin
			task.delay(0.4, function()
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			Util.Sound:Play("FishmanWaterBullet", clone3.Position, nil, 1 + math.random(-15, 15) / 100, 1)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if root and (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude < 100 then
				cameraShaker:Shake(Util.CameraShaker.Presets.Bump)
			end

			local clone4 = script["8smash"]:Clone()
			debris:AddItem(clone4, 0.9)
			clone4.CFrame = v * CFrame.new(0, 0, -27) * CFrame.Angles(1.5707963267948966, -0.004537856055185257, 0)
			clone4.Parent = _WorldOrigin
			TweenService:Create(clone4, tweenInfo, {
				Transparency = 1,
				CFrame = clone4.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
			resume(create(function()
				for _ = 1, 1 do
					local clone5 = script.Ring:Clone()
					debris:AddItem(clone5, 1)
					clone5.CFrame = v * CFrame.new(0, 0, -28) * CFrame.Angles(1.5707963267948966, 3.141592653589793, 0)
					clone5.Parent = _WorldOrigin
					TweenService:Create(clone5, tweenInfo3, {
						Size = createVector(25.522, 0.582, 25.916),
						Transparency = 1
					}):Play()
					task.wait(0.1)
				end
			end))
		end
	end
end