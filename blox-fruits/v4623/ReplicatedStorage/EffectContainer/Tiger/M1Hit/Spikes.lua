local createVector = vector.create
local Spikes = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
game:GetService("PhysicsService")
game:GetService("RunService")
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

function Spikes.Ground(p, instance, instance2, p2, total, total2, p3, p4, p5, parent, p6, p7)
	coroutine.resume(coroutine.create(function()
		for _ = 1, p do
			local v = math.random(p6, p7) / 100
			local clone = instance:Clone()
			clone.CFrame = p2.CFrame * CFrame.new(v, -5, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(-360, 360))),
				(math.rad(math.random(-95, 95) / 10))
			)
			clone.Size *= total2
			clone.Transparency = 1
			local clone2 = instance2:Clone()
			clone2.CFrame = p2.CFrame * CFrame.new(v, -5, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(160, 190))),
				(math.rad(math.random(-95, 95) / 10))
			)
			clone2.Size *= total2
			clone2.Transparency = 1
			emitAll(clone.Attachment)
			clone.Parent = parent
			clone2.Parent = parent
			emitAll(clone2.Attachment)
			Util.Sound:Play(p5, clone2, nil, 1 + math.random(-9, 3) / 100, 3)
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
				game.Debris:AddItem(clone, 1)
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
			total += p3
			total2 += p4
			task.wait()
		end
	end))
end

function Spikes.Ring(p, p2, p3, part, p4, p5, p6, p7, p8, parent)
	coroutine.resume(coroutine.create(function()
		for i = 1, p do
			print("done1/8")
			local position = p3.Position
			local v2 = CFrame.new(position) * CFrame.Angles(0, math.rad(i * 45), 0)
			coroutine.resume(coroutine.create(function()
				local v3 = p4
				local v4 = p5

				for i2 = 1, p2 do
					local v5 = math.random(-360, 360) / 100
					local clone = part:Clone()
					clone.CFrame = v2 * CFrame.new(v5, -4, -v3) * CFrame.Angles(
						math.rad(math.random(-150, 150) / 10),
						math.rad((math.random(170, 190))),
						(math.rad(math.random(-150, 150) / 10))
					)
					clone.Size *= v4
					clone.Material = "Neon"
					clone.Color = Color3.new(1, 1, 1)
					clone.Transparency = 0
					clone.Parent = parent
					local clone2 = part:Clone()
					clone2.Size += createVector(2.5, 2.5, 2.5)
					clone2.Anchored = false
					clone2.Transparency = 1
					clone2.Material = Enum.Material.Neon
					clone2.Name = "Shading"
					clone2:ClearAllChildren()
					clone2.Parent = parent
					local weld = Instance.new("Weld")
					weld.Part0 = clone2
					weld.Part1 = part
					weld.Parent = weld.Part0
					TweenService:Create(
						clone,
						TweenInfo.new(0.215, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut),
						{
							CFrame = clone.CFrame * CFrame.new(0, 6, 0),
							Size = clone.Size * math.random(1.15, 1.44)
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = clone2.Size * 1.15,
						Transparency = 0
					}):Play()
					coroutine.resume(coroutine.create(function()
						task.wait(0.775)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						Util.Debris:AddItem(clone2, 0.15)
					end))
					coroutine.resume(coroutine.create(function()
						task.wait(math.random(170, 259) / 100)

						if v4 >= 8.5 then
							emitAll(clone.Emit)
						end

						if v4 >= 3.1 then
							emitAll(clone.EmitSmaller)
						end

						if p8 == "DefrostBear" then
							Util.Sound:Play(p8, part.Position, nil, 1 + math.random(-35, -15) / 100, 7)
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
					v3 += p6
					v4 += p7
				end
			end))
		end
	end))
end

return Spikes