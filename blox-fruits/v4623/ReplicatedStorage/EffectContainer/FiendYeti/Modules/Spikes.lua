local createVector = vector.create
local Spikes = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("PhysicsService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)
local spikes = FX:WaitForChild("YetiEffects").Spikes
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

function Spikes.Ground(instance, p, instance2, instance3, p2, total, p3, p4, p5, p6, p7, p8, p9)
	local children

	if instance:GetAttribute("RedYeti") then
		children = spikes.Parent.RedSpikes:GetChildren()
	else
		children = spikes:GetChildren()
	end

	local v = not instance:GetAttribute("RedYeti") and 1 or script:GetAttribute("RedSpikeScaleMult")
	local v2 = p3 * v
	coroutine.resume(coroutine.create(function()
		for _ = 1, p do
			local v3 = math.random(p8, p9) / 100
			instance3 = children[math.random(1, #children)]
			local clone = instance2:Clone()
			clone.CFrame = p2.CFrame * CFrame.new(v3, -5, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(-360, 360))),
				(math.rad(math.random(-95, 95) / 10))
			)
			clone.Size *= v2
			clone.Transparency = 1
			local clone2 = instance3:Clone()
			clone2.CFrame = p2.CFrame * CFrame.new(v3, -5, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(160, 190))),
				(math.rad(math.random(-95, 95) / 10))
			)
			clone2.Size *= v2
			clone2.Transparency = 1
			emitAll(clone.Attachment)
			Util.SetParentOverrideWithColor(clone, p7, instance, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, p7, instance, "YetiFruitVFXColor")
			emitAll(clone2.Attachment)
			Util.Sound:Play(p6, clone2, nil, 1 + math.random(-9, 3) / 100, 3)
			TweenService:Create(clone, TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 5, 0),
				Size = clone.Size * 1.15,
				Transparency = 0
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 5, 0),
				Size = clone2.Size * 1.15,
				Transparency = 0
			}):Play()
			coroutine.resume(coroutine.create(function()
				task.wait(math.random(150, 257) / 100)
				TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					CFrame = clone.CFrame * CFrame.new(0, -5, 0),
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				Util.Debris:AddItem(clone, 1)
				TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					CFrame = clone2.CFrame * CFrame.new(0, -5, 0),
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				Util.Debris:AddItem(clone2, 2.5)
				task.wait(0.5)
				emitAll(clone2.Emit)
			end))
			total += p4
			v2 += p5 * v
			task.wait()
		end
	end))
end

function Spikes.Ring(instance, p, p2, p3, instance2, p4, p5, p6, p7, p8, p9, p10)
	local v, span

	if p10 and p10.Facing then
		local lookVector = p10.Facing.LookVector
		v = math.deg((math.atan2(lookVector.X, lookVector.Z)))
		span = p10.Span or 180
	else
		v = nil
		span = nil
	end

	local v2 = instance:GetAttribute("RedYeti") and true or false
	local children

	if instance:GetAttribute("RedYeti") then
		children = spikes.Parent.RedSpikes:GetChildren()
	else
		children = spikes:GetChildren()
	end

	local v3 = not instance:GetAttribute("RedYeti") and 1 or script:GetAttribute("RedSpikeScaleMult")
	local v4 = p5 * v3
	coroutine.resume(coroutine.create(function()
		for i = 1, p do
			instance2 = children[math.random(1, #children)]
			local position = p3.Position
			local cframe = CFrame.new(position)
			local v5 = i * 45

			if v then
				v5 = v + (not (p > 1) and 0 or (i - 1) / (p - 1) - 0.5) * span
			end

			local v7 = cframe * CFrame.Angles(0, math.rad(v5), 0)
			coroutine.resume(coroutine.create(function()
				local v8 = p4
				local v9 = v4

				for i2 = 1, p2 do
					local v10 = math.random(-360, 360) / 100
					local clone = instance2:Clone()
					clone.CFrame = v7 * CFrame.new(v10, -4, -v8) * CFrame.Angles(
						math.rad(math.random(-150, 150) / 10),
						math.rad((math.random(170, 190))),
						(math.rad(math.random(-150, 150) / 10))
					)
					clone.CFrame *= CFrame.Angles(0, 1.5707963267948966, 0)
					clone.Size *= v9
					clone.Material = "Neon"
					clone.Color = Util.WrapColor3Constructor(Color3.new(1, 1, 1), instance, "YetiFruitVFXColor")
					clone.Transparency = 0

					if v2 then
						clone.Color = Color3.fromRGB(48, 48, 48)
						local v11 = clone
						task.spawn(function()
							task.wait(0.1)
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(v11, TweenInfo.new(0.2), {
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(255, 102, 204),
									instance,
									"YetiFruitVFXColor"
								)
							}):Play()
							task.wait(0.85)
							local TweenService3 = game:GetService("TweenService")
							TweenService3:Create(v11, TweenInfo.new(0.5), {
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(255, 93, 93),
									instance,
									"YetiFruitVFXColor"
								)
							}):Play()
						end)
					end

					Util.SetParentOverrideWithColor(clone, p9, instance, "YetiFruitVFXColor")
					TweenService:Create(
						clone,
						TweenInfo.new(0.215, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut),
						{
							CFrame = clone.CFrame * CFrame.new(0, 6, 0),
							Size = clone.Size * math.random(1.15, 1.44)
						}
					):Play()
					coroutine.resume(coroutine.create(function()
						task.wait(math.random(170, 259) / 100)

						if v9 >= 8.5 then
							emitAll(clone.Emit)
						end

						if v9 >= 3.1 then
							emitAll(clone.EmitSmaller)
						end

						if p8 == "DefrostBear" then
							Util.Sound:Play(p8, instance2.Position, nil, 1 + math.random(-35, -15) / 100, 7)
						end

						local tween = TweenService:Create(
							clone,
							TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								CFrame = clone.CFrame * CFrame.new(0, -15, 0),
								Size = createVector(0, 0, 0)
							}
						)
						tween.Completed:Connect(function()
							task.wait(3)
							clone:Destroy()
						end)
						tween:Play()
					end))
					v8 += p6
					v9 += p7 * v3
				end
			end))
		end
	end))
end

return Spikes