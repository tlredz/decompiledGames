local createVector = vector.create
local Spikes2 = {}
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

function Spikes2.Ground(p, p2, instance, instance2, p3, total, total2, p4, p5, p6, p7, total3, total4, p8)
	coroutine.resume(coroutine.create(function()
		for _ = 1, p2 do
			local v = math.random(total3, total4) / 100
			local cFrame = p3.CFrame * CFrame.new(v, -4, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(-360, 360))),
				(math.rad(math.random(-13, 13) / 10))
			)
			local v3 = p3.CFrame * CFrame.new(v, 0, -total)
			local ray = Util.Ray
			local position = v3.Position
			local v4 = { workspace.Characters, workspace.Enemies }

			if not (ray(position, createVector(-0, -5, -0), v4) or cFrame.Position.Y - 10 <= -4) then
				continue
			end

			local clone = instance:Clone()
			clone.CFrame = cFrame
			clone.Size *= total2
			clone.Transparency = 1
			local clone2 = instance2:Clone()
			clone2.CFrame = p3.CFrame * CFrame.new(v, -5, -total) * CFrame.Angles(
				math.rad(math.random(-5, 5) / 10),
				math.rad((math.random(160, 190))),
				(math.rad(math.random(-195, 195) / 10))
			)
			clone2.CFrame *= CFrame.Angles(0, 1.5707963267948966, 0)
			clone2.Size *= total2
			clone2.Transparency = 1

			if p8 == true then
				emitAll(clone.Attachment)
			end

			Util.SetParentOverrideWithColor(clone, p7, p, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, p7, p, "YetiFruitVFXColor")

			if p8 == true then
				emitAll(clone2.Attachment)
			end

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

				if p8 == true then
					emitAll(clone2.Emit)
				end
			end))
			total3 += -450
			total4 += 450
			total += p4
			total2 += p5
			task.wait()
		end
	end))
end

function Spikes2.Ring(p, p2, p3, p4, part, p5, p6, p7, p8, p9, p10)
	coroutine.resume(coroutine.create(function()
		for i = 1, p2 do
			local position = p4.Position
			local v2 = CFrame.new(position) * CFrame.Angles(0, math.rad(i * 45), 0)
			coroutine.resume(coroutine.create(function()
				local v3 = p5
				local v4 = p6

				for i2 = 1, p3 do
					local v5 = math.random(-360, 360) / 100
					local clone = part:Clone()
					clone.CFrame = v2 * CFrame.new(v5, -4, -v3) * CFrame.Angles(
						math.rad(math.random(-150, 150) / 10),
						math.rad((math.random(170, 190))),
						(math.rad(math.random(-150, 150) / 10))
					)
					clone.Size *= v4
					clone.Material = "Neon"
					clone.Color = Util.WrapColor3Constructor(Color3.new(1, 1, 1), p, "YetiFruitVFXColor")
					clone.Transparency = 0
					Util.SetParentOverrideWithColor(clone, p10, p, "YetiFruitVFXColor")
					local clone2 = part:Clone()
					clone2.Size += createVector(2.5, 2.5, 2.5)
					clone2.Anchored = false
					clone2.Transparency = 1
					clone2.Material = Enum.Material.Neon
					clone2.Name = "Shading"
					clone2:ClearAllChildren()
					Util.SetParentOverrideWithColor(clone2, p10, p, "YetiFruitVFXColor")
					local weld = Instance.new("Weld")
					weld.Part0 = clone2
					weld.Part1 = part
					Util.SetParentOverrideWithColor(weld, weld.Part0, p, "YetiFruitVFXColor")
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

						if p9 == "DefrostBear" then
							Util.Sound:Play(p9, part.Position, nil, 1 + math.random(-35, -15) / 100, 7)
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
					v3 += p7
					v4 += p8
				end
			end))
		end
	end))
end

return Spikes2