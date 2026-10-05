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

local function splashFunction(p, p2, position, p3)
	for _ = 1, p do
		if math.random() > 0.4 then
			continue
		end

		local clone = script.Liquid:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Size = Vector3.new(p2, p2, p2)
		clone.Parent = _WorldOrigin
		clone.Dots:Emit(2)
		local velocity = Vector3.new(math.random(-p3, p3), math.random(p3, p3 * 1.33), math.random(-p3, p3)) / (0.6 + math.random() * 0.4)
		clone.Velocity = velocity
		clone:ApplyImpulse(velocity)
		local touchedConnection = nil
		task.delay(0.15, function()
			local v3 = false
			touchedConnection = clone.Touched:Connect(function(otherPart)
				if otherPart:isDescendantOf(workspace.Map) and not v3 then
					v3 = true
					touchedConnection:Disconnect()
					local v4 = clone.Position + createVector(0, 35, 0)
					local ray, position2, v6 = Util.Ray(
						v4,
						CFrame.new(v4).upVector.Unit * -50,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray then
						local clone2 = script.SplashGround:Clone()
						local hitbox = clone.Hitbox
						clone2.Position = position2
						clone2.Parent = _WorldOrigin
						local v7 = 1.5 + math.random() * 3
						local tween = TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
							Size = Vector3.new(clone.Size.X * v7, clone.Size.Y / 2, clone.Size.Z * v7),
							Transparency = 0.6
						})
						tween:Play()
						Util.Sound:Play("FishmanSplashGround", clone2.Position)
						coroutine.wrap(function()
							for i = 1, 2 do
								local clone3 = script.Liquid:Clone()
								clone3.Dots:Emit(2)
								clone3.CFrame = clone2.CFrame
								clone3.Massless = true
								clone3.Size = Vector3.new(p2 / 3, p2 / 3, p2 / 3)
								clone3.Parent = _WorldOrigin
								clone3.Velocity = Vector3.new(
									math.random(-35, 35),
									math.random(30, 35),
									math.random(-35, 35)
								)
								debris:AddItem(clone3, 2.5)
							end

							clone.Transparency = 1
							clone.Anchored = true
							tween.Completed:Wait()
							task.wait(1.5)
							local tween2 = TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
								Size = Vector3.new(),
								Transparency = 1
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone2:Destroy()

							if touchedConnection then
								touchedConnection:Disconnect()
								touchedConnection = nil
							end
						end)()
					end
				end
			end)
		end)
		local v3 = clone
		coroutine.wrap(function()
			task.wait(3)

			if touchedConnection then
				touchedConnection:Disconnect()
				touchedConnection = nil
			end

			if v3 then
				v3:Destroy()
			end
		end)()
	end
end

return function(player)
	local DELAY_DURATION = 0.7
	local subEffect = player.SubEffect or 1

	if subEffect == 1 then
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local boolean = player.Boolean
		local character = player.Character
		local leftHand = character:FindFirstChild("LeftHand")
		local rightHand = character:FindFirstChild("RightHand")

		if leftHand and rightHand then
			if boolean then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > 400 then
					return
				end

				coroutine.wrap(function()
					for i = 1, 2 do
						local clone = script.WaterBall:Clone()
						TweenService:Create(clone, tweenInfo, {
							Size = createVector(1.8, 1.698, 1.779)
						}):Play()
						local vector2 = Vector3.new(
							math.random(4, 6) * 60,
							math.random(4, 6) * 60,
							math.random(4, 6) * 60
						)
						local vector3 = Vector3.new(
							math.random(4, 6) * 60,
							math.random(4, 6) * 60,
							math.random(4, 6) * 60
						)
						clone.Orientation = vector2
						TweenService:Create(clone, tweenInfo2, {
							Orientation = vector3 * 0.5
						}):Play()

						if i == 1 then
							clone.CFrame = rightHand.CFrame
							clone.Parent = rightHand
							local weldConstraint = Instance.new("WeldConstraint")
							weldConstraint.Name = "watearball1weld"
							weldConstraint.Parent = rightHand
							weldConstraint.Part0 = rightHand
							weldConstraint.Part1 = clone
						end

						if i ~= 2 then
							continue
						end

						clone.CFrame = leftHand.CFrame
						clone.Parent = leftHand
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Name = "watearball2weld"
						weldConstraint.Parent = leftHand
						weldConstraint.Part0 = leftHand
						weldConstraint.Part1 = clone
					end
				end)()
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

					task.delay(DELAY_DURATION, function()
						if rightHand and rightHand:FindFirstChild("WaterBall") then
							rightHand.WaterBall:Destroy()
						end
					end)
				end

				if rightHand:FindFirstChild("watearball2weld") then
					task.delay(DELAY_DURATION, function()
						if rightHand and rightHand:FindFirstChild("watearball2weld") then
							rightHand.watearball2weld:Destroy()
						end
					end)
				end

				if leftHand:FindFirstChild("WaterBall") then
					TweenService:Create(leftHand.WaterBall, tweenInfo3, {
						Size = Vector3.new()
					}):Play()

					for _, emitter in pairs(leftHand.WaterBall:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(DELAY_DURATION, function()
						if leftHand and leftHand:FindFirstChild("WaterBall") then
							leftHand.WaterBall:Destroy()
						end
					end)
				end

				if leftHand:FindFirstChild("watearball1weld") then
					task.delay(DELAY_DURATION, function()
						if leftHand then
							leftHand.watearball1weld:Destroy()
							leftHand:FindFirstChild("watearball1weld")
						end
					end)
				end
			end
		end
	elseif subEffect == 2 then
		local mousePos = player.MousePos
		local cFrame = player.CFrame
		local char = player.Char

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
			return
		end

		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local v = cFrame * CFrame.new(0, 0, -2)
		local clone = script.waterbullet:Clone()
		clone.CFrame = CFrame.new(v.p, mousePos)
		clone.Orientation += createVector(0, 0, 0)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
		bodyVelocity.Parent = clone
		bodyVelocity.Velocity = (mousePos - v.p).Unit * 210
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 3)
		local v2 = false
		clone.Touched:Connect(function(otherPart)
			if otherPart:IsDescendantOf(_WorldOrigin) or otherPart:IsDescendantOf(char) then
				return
			end

			if v2 == false and otherPart ~= nil then
				v2 = true
				local position = clone.Position
				bodyVelocity:Destroy()
				clone.Anchored = true

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(0.6, function()
					clone:Destroy()
				end)
				local clone2 = script.waterExplosion:Clone()
				clone2.Position = position
				clone2.Parent = _WorldOrigin
				debris:AddItem(clone2, 3)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit((math.ceil(emitter:GetAttribute("EmitCount") / 6)))
					end
				end

				if (workspace.CurrentCamera.CFrame.Position - clone2.Position).Magnitude < 100 then
					cameraShaker:Shake(Util.CameraShaker.Presets.Bump)
				end

				v *= CFrame.new(0, -2.5, 0)
				resume(create(function()
					for _ = 1, 1 do
						local clone3 = script.Ring:Clone()
						clone3.Position = position
						clone3.Parent = _WorldOrigin
						TweenService:Create(clone3, tweenInfo2, {
							Size = createVector(45, 0.579, 45),
							Transparency = 1
						}):Play()
						wait(0.1)
					end
				end))
				coroutine.wrap(function()
					splashFunction(2, 2.5, clone2.Position, 55, 2)
				end)()
				local v3 = clone2.CFrame * CFrame.new(0, 0, 0).Position
				local ray, v4, _ = Util.Ray(
					v3,
					CFrame.new(v3).upVector.Unit * -15,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if ray then
					local clone3 = script.GroundBurnt:Clone()
					clone3.Parent = _WorldOrigin
					clone3.CFrame = CFrame.new(v4)
					clone3.Orientation += createVector(90, -90, 0)
					TweenService:Create(clone3, tweenInfo, {
						Size = createVector(35.473, 35.473, 0.002)
					}):Play()
					debris:AddItem(clone3, 3)
					task.delay(0.4, function()
						TweenService:Create(clone3.Decal, tweenInfo, {
							Transparency = 1
						}):Play()
					end)
				end
			end
		end)
	elseif subEffect == 3 then
		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local cFrame = player.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
			return
		end

		local position = cFrame.Position
		local clone = script.waterExplosion:Clone()
		clone.Position = position
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 3)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit((math.ceil(emitter:GetAttribute("EmitCount") / 6)))
			end
		end

		Util.Sound:Play("BubblePop", position)

		if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 80 then
			cameraShaker:Shake(Util.CameraShaker.Presets.Bump)
		end

		coroutine.wrap(function()
			splashFunction(2, 2.5, clone.Position, 55, 2)
		end)()
		local v = clone.CFrame * CFrame.new(0, 0, 0).Position
		local ray, v2, _ = Util.Ray(
			v,
			CFrame.new(v).upVector.Unit * -15,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			local clone2 = script.GroundBurnt:Clone()
			clone2.Parent = _WorldOrigin
			clone2.CFrame = CFrame.new(v2)
			clone2.Orientation += createVector(90, -90, 0)
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(35.473, 35.473, 0.002)
			}):Play()
			debris:AddItem(clone2, 3)
			task.delay(0.4, function()
				TweenService:Create(clone2.Decal, tweenInfo, {
					Transparency = 1
				}):Play()
			end)
		end
	end
end