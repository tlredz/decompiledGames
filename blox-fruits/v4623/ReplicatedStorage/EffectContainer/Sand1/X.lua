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
cr = resume
cc = create
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo4 = TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo5 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo6 = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo7 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local function sandExplodeFunction(p, p2, position, p3)
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
							Transparency = 0
						})
						tween:Play()
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

return function(data)
	local subID = data.SubID or 1

	if subID == 1 then
		local position = data.Position
		local hitPart = data.HitPart
		local surface = data.Surface
		local _ = data.Direction

		if hitPart then
			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 600 then
				return
			end

			if hitPart ~= nil then
				local cFrame = CFrame.new(position, position + surface) * CFrame.Angles(-1.5707963267948966, 0, 0)

				if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 150 then
					Util.CameraShaker:Shake(Util.CameraShaker.Presets.Bump)
				end

				Util.Sound:Play("SandCast2", position)
				cr(cc(function()
					for _ = 1, 3 do
						local clone = script.SandCircle:Clone()
						clone.CFrame = cFrame * CFrame.new(0, 0.5, 0)
						clone.Parent = _WorldOrigin
						TweenService:Create(clone, tweenInfo6, {
							Size = createVector(0, 0, 0),
							CFrame = clone.CFrame * CFrame.new(0, -1, 0)
						}):Play()

						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						task.wait(0.2)
					end
				end))
				cr(cc(function()
					for _ = 1, 3 do
						local clone = script.Ring1:Clone()
						clone.CFrame = cFrame
						clone.Parent = _WorldOrigin
						TweenService:Create(clone, tweenInfo7, {
							Size = createVector(45, 0.579, 45),
							Transparency = 1
						}):Play()
						task.wait(0.2)
					end
				end))
				local clone = script.dustparticle:Clone()
				clone.CFrame = cFrame * CFrame.new(0, -0.2, 0)
				clone.Parent = _WorldOrigin
				task.delay(0.5, function()
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				local clone2 = script.trail:Clone()
				clone2.CFrame = cFrame * CFrame.new(0, -0.2, 0)
				clone2.Parent = _WorldOrigin

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				clone2.Orientation += createVector(90, -90, 0)
				local v2 = Util.Sound:Play("SandFlightLoop2", position)
				task.wait(1)
				cr(cc(function()
					task.wait(0.5)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(0.5)
					TweenService:Create(v2, tweenInfo5, {
						Volume = 0
					}):Play()
				end))
			end
		end
	elseif subID == 2 then
		local position = data.Position
		local hitPart = data.HitPart
		local surface = data.Surface

		if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 600 then
			return
		end

		if hitPart ~= nil then
			local cFrame = CFrame.new(position, position + surface) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local clone = script.Sandball:Clone()
			clone.CFrame = cFrame
			clone.Parent = _WorldOrigin
			local position2 = cFrame * CFrame.new(0, 17, 0).Position
			local position3 = cFrame * CFrame.new(0, 20, 0).Position
			local position4 = cFrame * CFrame.new(0, 30, 0).Position
			local clone2 = script.Part:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			clone2.FFGrass.Color = ColorSequence.new(hitPart.Color)
			clone2.Rocks.Color = ColorSequence.new(hitPart.Color)
			clone2.FFGrass.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 34)
			})
			clone2.FFGrass:Emit(20)
			clone2.Rocks:Emit(20)
			Util.Sound:Play("SandXCrunch", clone2.Position)
			TweenService:Create(clone, tweenInfo2, {
				Position = position2
			}):Play()
			local vector2 = Vector3.new(math.random(4, 6) * 60, math.random(4, 6) * 60, math.random(4, 6) * 60)
			local vector3 = Vector3.new(math.random(4, 6) * 60, math.random(4, 6) * 60, math.random(4, 6) * 60)
			clone.Orientation = vector2
			TweenService:Create(clone, tweenInfo4, {
				Orientation = vector3 * 0.5
			}):Play()
			cr(cc(function()
				task.wait(0.5)
				TweenService:Create(clone, tweenInfo3, {
					Position = position3
				}):Play()
				task.wait(0.5)
				TweenService:Create(clone, tweenInfo, {
					Size = createVector(0, 0, 0)
				}):Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.7)
				local clone3 = script.Explosio:Clone()
				clone3.CFrame = cFrame * CFrame.new(0, 20, 0)
				clone3.Parent = _WorldOrigin
				Util.Sound:Play("SandVExplosion", clone3.Position)
				sandExplodeFunction(5, 2.5, clone3.Position, 55)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 150 then
					Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
				end

				task.wait(0.7)
				task.wait(3)
				clone:Destroy()
			end))
			cr(cc(function()
				for _ = 1, 4 do
					local clone3 = script.Ring:Clone()
					clone3.CFrame = cFrame
					clone3.Size = createVector(7, 15, 7)
					clone3.Color = Color3.fromRGB(222, 188, 153)
					clone3.Material = Enum.Material.Plastic
					clone3.Parent = _WorldOrigin
					TweenService:Create(clone3, tweenInfo5, {
						Position = position4,
						Size = createVector(40, 0, 40),
						Transparency = 1
					}):Play()
					task.wait(0.16)
				end
			end))
			TweenService:Create(clone, tweenInfo, {
				Size = createVector(21.42, 21.42, 21.42)
			}):Play()
		end
	end
end