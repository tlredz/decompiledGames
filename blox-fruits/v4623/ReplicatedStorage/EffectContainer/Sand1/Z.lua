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
local TweenService2 = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create

local function sandExplodeFunction(p, p2, position, p3)
	for _ = 1, p do
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
		return
	end

	if subID == 2 then
		local cFrame = data.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
			return
		end

		local cFrame2 = cFrame * CFrame.new(0, -2.5, 0)
		local v2 = cFrame2 - cFrame2.p
		local p = cFrame2.p
		local v3 = cFrame2.upVector * -10
		local ray, v4, _ = Util.Ray(p, v3, { workspace.Characters, workspace.Enemies }, false)

		if ray ~= nil and v4 ~= nil then
			cFrame2 = CFrame.new(v4 - createVector(0, 0.5, 0)) * v2
		end

		local clone = script.Part:Clone()
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 2)
		Util.Sound:Play("SandZ1", clone.Position)
		local clone2 = script.trail:Clone()
		clone2.CFrame = cFrame2 * CFrame.new(0, 0, -15)
		clone2.Parent = _WorldOrigin

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		debris:AddItem(clone2, 4)
		clone2.Orientation += createVector(90, -90, 0)
		sandExplodeFunction(3, 2.5, clone2.Position, 55)

		if (workspace.CurrentCamera.CFrame.Position - clone2.Position).Magnitude < 100 then
			Util.CameraShaker:Shake(Util.CameraShaker.Presets.Bump)
		end
	elseif subID == 3 then
		local cFrame = data.CFrame
		local _ = data.SegmentCount
		local yAddition = data.yAddition

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
			return
		end

		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local clone = script.SandSpikes:Clone()
		debris:AddItem(clone, 3)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		TweenService2:Create(clone, tweenInfo, {
			Size = Vector3.new(20 + yAddition, 16.05, 5.834)
		}):Play()
		task.delay(1.1, function()
			if clone then
				TweenService2:Create(clone, tweenInfo2, {
					Size = createVector(27.7, 0.001, 0.001),
					Transparency = 1
				}):Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
	end
end