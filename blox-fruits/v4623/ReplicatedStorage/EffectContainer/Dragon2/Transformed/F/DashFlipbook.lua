local createVector = vector.create
local RunService = game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)
local dashFlipbook = FX:WaitForChild("Dragon2").Transformed.F.DashFlipbook
local assets = script.Assets
local Util = require(game.ReplicatedStorage.Util)
local v = 0.1
return {
	Dash = function(part, p, instance, p2)
		local clone = dashFlipbook.Effect:Clone()
		clone.CFrame = part.CFrame
		clone.Weld.Part0 = part
		Util.SetParentOverrideWithColor(clone, p, p2, "DragonFruitVFXColor")
		local cFrame = clone.CFrame
		local random = Random.new()
		local model = Instance.new("Model")
		model.Name = "DragonXEffect"
		local clone2 = assets.Spike:Clone()
		clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		Util.SetParentOverrideWithColor(clone2, model, p2, "DragonFruitVFXColor")
		local v2 = {}

		for _, child in pairs(clone2:GetChildren()) do
			if child ~= clone2.PrimaryPart then
				v2[child] = {
					Offset = clone2.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
					Decal = {
						Transparency = child.Decal.Transparency
					},
					Mesh = {
						Scale = child.Mesh.Scale,
						Offset = child.Mesh.Offset
					}
				}
			end
		end

		local clone3 = dashFlipbook.Aura2:Clone()
		clone3.CFrame = clone2.PrimaryPart.CFrame
		Util.SetParentOverrideWithColor(clone3, model, p2, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v3 = {}
		CFrame.new(0, 0, 252)
		CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
		local v4 = {
			"rbxassetid://13117093477",
			"rbxassetid://13117093094",
			"rbxassetid://13117092741",
			"rbxassetid://13117092522",
			"rbxassetid://13117092280",
			"rbxassetid://13117092086",
			"rbxassetid://13117091790"
		}

		for k, v5 in pairs(v3) do
			k.Mesh.Scale = v5.Mesh.Scale * 7 * 14 * createVector(1.2, 1.125, 1.2)
		end

		CFrame.new(0, 0, 378)
		CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
		local v5 = {}

		for k, v6 in pairs(v5) do
			k.Mesh.Scale = v6.Mesh.Scale * 7 * 14 * createVector(0.65, 1.75, 0.65)
		end

		local v6 = 1e999
		local v7 = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v6 = math.min(v6, emitter.Lifetime.Min)
			emitter.Enabled = true
		end

		v = math.max(v, v6)
		Util.SetParentOverrideWithColor(model, p, p2, "DragonFruitVFXColor")
		local now = tick()
		local v8 = {
			RingFire = 0,
			SwirlFire = 0,
			SpikyShockwave = {
				UpdateRate = 0.016666666666666666,
				Index = 1,
				Last = 0
			}
		}

		while true do
			local lastTime = tick()
			local v9 = lastTime - now
			math.min(1, v9 / 0.25)
			local v10 = math.min(1, v9 / v)
			local v11 = math.sin(3.141592653589793 * v9 * 25)
			local v12 = math.cos(3.141592653589793 * v9 * 25)
			local quad = Util.Tween.ease.out.quad(v10, 0, 1, 1)
			local cFrame2 = clone.CFrame * CFrame.new(0, 0, -98)

			for k, v14 in pairs(v2) do
				k.CFrame = clone2.PrimaryPart.CFrame * Util.Misc.ScaleCFrame(v14.Offset, 14)
				k.Mesh.Scale = v14.Mesh.Scale * 14 * Vector3.new(v11 * 0.5 + 1, 1, v12 * 0.5 + 1)
				k.Decal.Transparency = 1 + (v14.Decal.Transparency - 1) * quad
			end

			clone2:SetPrimaryPartCFrame(cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0))
			clone3.CFrame = cFrame2

			if lastTime - v8.SpikyShockwave.Last > v8.SpikyShockwave.UpdateRate then
				v8.SpikyShockwave.Index = v8.SpikyShockwave.Index % #v4 + 1
				local v14 = v8.SpikyShockwave.Index / #v4
				local sine = Util.Tween.ease.out.sine(v14, 0, 1, 1)
				local sine2 = Util.Tween.ease["in"].sine(v14, 0, 1, 1)

				for k, v15 in pairs(v3) do
					k.Decal.Texture = v4[v8.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p2,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v15.Decal.Transparency + (1 - v15.Decal.Transparency) * sine2
				end

				for k, v15 in pairs(v5) do
					k.Decal.Texture = v4[v8.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p2,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v15.Decal.Transparency + (1 - v15.Decal.Transparency) * sine2
				end

				v8.SpikyShockwave.Last = lastTime
			end

			if lastTime - v8.RingFire > 0.13333333333333333 then
				task.spawn(function()
					CFrame.new(0, 0, 14)
					CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
					random:NextNumber(10, 15)
				end)
				v8.RingFire = lastTime
			end

			if lastTime - v8.SwirlFire > 0.11666666666666667 then
				task.spawn(function()
					local number = random:NextNumber(2.75, 5.5)
					local number2 = random:NextNumber(2, 6)
					local cframe = CFrame.new(0, 0, (12.5 + number2) * 14)
					local cframe2 = CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
					local clone4 = assets.AnimatedSwirl:Clone()
					clone4.Swirlwind:Destroy()
					clone4:SetPrimaryPartCFrame(cFrame2 * cframe * CFrame.Angles(1.5707963267948966, 0, 0) * cframe2)
					Util.SetParentOverrideWithColor(clone4, model, p2, "DragonFruitVFXColor")
					local v14 = {}
					local v15 = {
						"rbxassetid://13462839736",
						"rbxassetid://13462839627",
						"rbxassetid://13462839524",
						"rbxassetid://13462839340",
						"rbxassetid://13462839231",
						"rbxassetid://13462839111",
						"rbxassetid://13462839003",
						"rbxassetid://13462838898",
						"rbxassetid://13462838762",
						"rbxassetid://13462838655",
						"rbxassetid://13462838475",
						"rbxassetid://13462838281",
						""
					}

					for _, child in pairs(clone4:GetChildren()) do
						if child ~= clone4.PrimaryPart then
							v14[child] = {
								Offset = clone4.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
								Decal = {
									Color3 = child.Decal.Color3,
									Transparency = child.Decal.Transparency
								},
								Mesh = {
									Scale = child.Mesh.Scale,
									Offset = child.Mesh.Offset
								}
							}
						end
					end

					for k, v16 in pairs(v14) do
						k.Mesh.Scale = v16.Mesh.Scale * 14 * Vector3.new(number, number2, number)
					end

					for i = 1, #v15 do
						local v16 = i / #v15
						local quint = Util.Tween.ease.out.quint(v16, 0, 1, 1)

						for k, _ in pairs(v14) do
							k.Decal.Texture = v15[i]
							k.Decal.Color3 = Util.WrapColor3Constructor(
								Color3.fromRGB(1500 - 200 * quint, 800 - 550 * quint, 255 - 100 * quint),
								p2,
								"DragonFruitVFXColor"
							)
						end

						task.wait(0.016666666666666666)
					end

					for k, _ in pairs(v14) do
						v14[k] = nil
					end

					clone4:Destroy()
				end)
				v8.SwirlFire = lastTime
			end

			if instance.Value >= 2 or not instance:IsDescendantOf(workspace) then
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local v14 = 0

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						v14 = math.max(v14, effect.Lifetime.Max)
						effect.Enabled = false
					elseif effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local now2 = tick()

				while true do
					local now3 = tick()
					local v15 = math.min(1, (now3 - now2) / v)

					for k, v16 in pairs(v2) do
						k.Mesh.Scale = v16.Mesh.Scale * 14 * createVector(1.5, 1, 1.5) * Vector3.new(
							1 - v15,
							1,
							1 - v15
						)
						k.Decal.Transparency = v16.Decal.Transparency + (1 - v16.Decal.Transparency) * v15 * 1.25
					end

					for k, v16 in pairs(v7) do
						k.Mesh.Scale = v16.Mesh.Scale * 14 * createVector(1.25, 1.25, 2) * Vector3.new(
							1 - v15,
							1 - v15,
							1
						)
						k.Decal.Transparency = v16.Decal.Transparency + (1 - v16.Decal.Transparency) * v15
					end

					if v8.SpikyShockwave.Index ~= #v4 and now3 - v8.SpikyShockwave.Last > v8.SpikyShockwave.UpdateRate then
						v8.SpikyShockwave.Index = v8.SpikyShockwave.Index % #v4 + 1
						local v16 = v8.SpikyShockwave.Index / #v4
						local sine = Util.Tween.ease.out.sine(v16, 0, 1, 1)
						local sine2 = Util.Tween.ease["in"].sine(v16, 0, 1, 1)

						for k, v17 in pairs(v3) do
							k.Decal.Texture = v4[v8.SpikyShockwave.Index]
							k.Decal.Color3 = Util.WrapColor3Constructor(
								Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
								p2,
								"DragonFruitVFXColor"
							)
							k.Decal.Transparency = v17.Decal.Transparency + (1 - v17.Decal.Transparency) * sine2
						end

						for k, v17 in pairs(v5) do
							k.Decal.Texture = v4[v8.SpikyShockwave.Index]
							k.Decal.Color3 = Util.WrapColor3Constructor(
								Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
								p2,
								"DragonFruitVFXColor"
							)
							k.Decal.Transparency = v17.Decal.Transparency + (1 - v17.Decal.Transparency) * sine2
						end

						v8.SpikyShockwave.Last = now3
					end

					if v15 == 1 and v8.SpikyShockwave.Index == #v4 then
						task.wait(v14 - v)

						for k, _ in pairs(v2) do
							v2[k] = nil
						end

						for k, _ in pairs(v7) do
							v7[k] = nil
						end

						for k, _ in pairs(v3) do
							v3[k] = nil
						end

						for k, _ in pairs(v5) do
							v3[k] = nil
						end

						clone:Destroy()
						model:Destroy()
						return
					else
						RunService.RenderStepped:Wait()
					end
				end
			else
				RunService.RenderStepped:Wait()
				local _ = tick() - lastTime
			end
		end
	end
}