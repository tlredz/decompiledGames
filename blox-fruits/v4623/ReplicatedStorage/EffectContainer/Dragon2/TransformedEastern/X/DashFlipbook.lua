local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local RunService = game:GetService("RunService")
local assets = FX:WaitForChild("EasternDragon").X.Assets
local v = 0.3

-- equivalent calls inferred from this helper; original call sites unknown
local function ScaleCFrame(offset, p)
	local components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = offset:components()
	return CFrame.new(components * p, v2 * p, v3 * p, v4, v5, v6, v7, v8, v9, v10, v11, v12)
end

return {
	Dash = function(_, p, p2, folder, p3, p4, p5)
		local destroyAfter = Util.DestroyAfter

		local function Scale(instance, p6)
			local v2 = p3

			if instance.ClassName ~= "Model" then
				local model = Instance.new("Model")
				Util.SetParentOverrideWithColor(model, instance.Parent, p5, "DragonFruitVFXColor")
				Util.SetParentOverrideWithColor(instance, model, p5, "DragonFruitVFXColor")
				instance = model
			end

			instance:ScaleTo(p6)
			local v3 = v2 + (instance:GetPivot().Position - v2) * p6
			instance:PivotTo(instance:GetPivot().Rotation + v3)
		end

		local cFrame = folder.CFrame
		local random = Random.new()
		local model = Instance.new("Model")
		model.Name = "DragonXEffect"
		local clone = assets.Spike:Clone()
		clone:SetPrimaryPartCFrame(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		Util.SetParentOverrideWithColor(clone, model, p5, "DragonFruitVFXColor")
		destroyAfter(clone, 7)
		local v2 = {}

		for _, child in ipairs(clone:GetChildren()) do
			if child ~= clone.PrimaryPart then
				v2[child] = {
					Offset = clone.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

		local clone2 = assets.AnimatedRingAura:Clone()
		local v3 = {}
		local v4 = {
			"rbxassetid://13117093477",
			"rbxassetid://13117093094",
			"rbxassetid://13117092741",
			"rbxassetid://13117092522",
			"rbxassetid://13117092280",
			"rbxassetid://13117092086",
			"rbxassetid://13117091790"
		}

		for _, script in ipairs(clone2:GetDescendants()) do
			if script:IsA("Script") then
				script:Destroy()
			end
		end

		local cframe = CFrame.new(0, 0, 63)
		local cframe2 = CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)

		for _, child in ipairs(clone2:GetChildren()) do
			if child ~= clone2.PrimaryPart then
				v3[child] = {
					Offset = clone2.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

		for k, v5 in pairs(v3) do
			k.Mesh.Scale = v5.Mesh.Scale * 7 * 3.5 * createVector(1.2, 1.125, 1.2)
		end

		clone2:SetPrimaryPartCFrame(cFrame * cframe * CFrame.Angles(1.5707963267948966, 0, 0) * cframe2)
		Util.SetParentOverrideWithColor(clone2, model, p5, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)
		local cframe3 = CFrame.new(0, 0, 94.5)
		local cframe4 = CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
		local clone3 = assets.AnimatedRingAura:Clone()
		local v5 = {}

		for _, script in ipairs(clone3:GetDescendants()) do
			if script:IsA("Script") then
				script:Destroy()
			end
		end

		for _, child in ipairs(clone3:GetChildren()) do
			if child ~= clone3.PrimaryPart then
				v5[child] = {
					Offset = clone3.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

		for k, v6 in pairs(v5) do
			k.Mesh.Scale = v6.Mesh.Scale * 7 * 3.5 * createVector(0.65, 1.75, 0.65)
		end

		clone3:SetPrimaryPartCFrame(cFrame * cframe3 * CFrame.Angles(1.5707963267948966, 0, 0) * cframe4)
		Util.SetParentOverrideWithColor(clone3, model, p5, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)
		local clone4 = assets.ConeSwirl:Clone()
		clone4:SetPrimaryPartCFrame(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		Scale(clone4, p4)
		Util.SetParentOverrideWithColor(clone4, p, p5, "DragonFruitVFXColor")
		destroyAfter(clone4, 7)
		local v6 = {}

		for _, child in ipairs(clone4:GetChildren()) do
			if child ~= clone4.PrimaryPart then
				v6[child] = {
					Offset = clone4.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

		local v7 = 1e999

		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v7 = math.min(v7, emitter.Lifetime.Min)
			emitter.Enabled = true
		end

		v = math.max(v, v7)
		Scale(model, p4)
		Util.SetParentOverrideWithColor(model, p, p5, "DragonFruitVFXColor")
		destroyAfter(model, 7)
		local now = tick()
		local v8 = time()
		local v9 = {
			RingFire = 0,
			SwirlFire = 0,
			SpikyShockwave = {
				UpdateRate = 0.016666666666666666,
				Index = 1,
				Last = 0
			}
		}

		for _ = 1, 600 do
			if time() - v8 > 10 then
				break
			end

			local lastTime = tick()
			local v10 = lastTime - now
			local v11 = math.min(1, v10 / p2)
			local v12 = math.min(1, v10 / v)
			local v13 = math.sin(3.141592653589793 * v10 * 8)
			local v14 = math.cos(3.141592653589793 * v10 * 8)
			local quad = Util.Tween.ease.out.quad(v12, 0, 1, 1)
			local v15 = folder.CFrame * CFrame.new(0, 0, -17.5)

			for k, v16 in pairs(v2) do
				k.CFrame = clone.PrimaryPart.CFrame * ScaleCFrame(v16.Offset, 3.5)
				k.Mesh.Scale = v16.Mesh.Scale * 3.5 * Vector3.new(v13 * 0.5 + 1, 1, v14 * 0.5 + 1)
				k.Decal.Transparency = 1 + (v16.Decal.Transparency - 1) * quad
			end

			clone:SetPrimaryPartCFrame(v15 * CFrame.Angles(1.5707963267948966, 0, 0))

			for k, v16 in pairs(v6) do
				k.CFrame = clone4.PrimaryPart.CFrame * ScaleCFrame(v16.Offset, 3.5)
				k.Mesh.Scale = v16.Mesh.Scale * 3.5 * createVector(1.25, 1.25, 2)
				k.Decal.Transparency = 1 + (v16.Decal.Transparency - 1) * quad
			end

			clone4:SetPrimaryPartCFrame(v15 * CFrame.new(0, 0, 13.125) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				3.141592653589793 * v10 * 8,
				0
			))
			clone2:SetPrimaryPartCFrame(v15 * cframe * CFrame.Angles(1.5707963267948966, 0, 0) * cframe2)
			clone3:SetPrimaryPartCFrame(v15 * cframe3 * CFrame.Angles(1.5707963267948966, 0, 0) * cframe4)

			if lastTime - v9.SpikyShockwave.Last > v9.SpikyShockwave.UpdateRate then
				v9.SpikyShockwave.Index = v9.SpikyShockwave.Index % #v4 + 1
				local v19 = v9.SpikyShockwave.Index / #v4
				local sine = Util.Tween.ease.out.sine(v19, 0, 1, 1)
				local sine2 = Util.Tween.ease["in"].sine(v19, 0, 1, 1)

				for k, v20 in pairs(v3) do
					k.Decal.Texture = v4[v9.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p5,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v20.Decal.Transparency + (1 - v20.Decal.Transparency) * sine2
				end

				for k, v20 in pairs(v5) do
					k.Decal.Texture = v4[v9.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p5,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v20.Decal.Transparency + (1 - v20.Decal.Transparency) * sine2
				end

				v9.SpikyShockwave.Last = lastTime
			end

			if lastTime - v9.RingFire > 0.13333333333333333 then
				task.spawn(function()
					local cframe5 = CFrame.new(0, 0, 3.5)
					local cframe6 = CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
					local number = random:NextNumber(10, 15)
					local clone5 = assets.FireRing:Clone()
					clone5:SetPrimaryPartCFrame(v15 * cframe5 * CFrame.Angles(1.5707963267948966, 0, 0) * cframe6)
					Util.SetParentOverrideWithColor(clone5, model, p5, "DragonFruitVFXColor")
					destroyAfter(clone5, 7)
					local v19 = {}

					for _, child in ipairs(clone5:GetChildren()) do
						if child ~= clone5.PrimaryPart then
							v19[child] = {
								Offset = clone5.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

					local lastTime2 = tick()
					local v20 = time()

					for _ = 1, 600 do
						if time() - v20 > 10 then
							break
						end

						local v21 = tick() - lastTime2
						local v22 = math.min(1, v21 / 0.225)
						local sine = Util.Tween.ease.out.sine(v22, 0, 1, 1)
						local quint = Util.Tween.ease.out.quint(v22, 0, 1, 1)

						for k, v23 in pairs(v19) do
							k.CFrame = clone5.PrimaryPart.CFrame * ScaleCFrame(v23.Offset, 3.5)
							k.Mesh.Scale = v23.Mesh.Scale * 3.5 * 0.8 + v23.Mesh.Scale * 1.7 * 3.5 * Vector3.new(
								1.5 * sine,
								1.6 * number * sine,
								1.5 * sine
							)
							k.Decal.Color3 = Util.WrapColor3Constructor(
								Color3.fromRGB(2250 - 555 * quint, 1255 - 1000 * quint, 255 - 100 * quint),
								p5,
								"DragonFruitVFXColor"
							)
							k.Decal.Transparency = v23.Decal.Transparency + (1 - v23.Decal.Transparency) * sine
						end

						clone5:SetPrimaryPartCFrame(v15 * cframe5 * CFrame.new(0, 0, 3.5 * number * 1.125 * sine) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * cframe6 * CFrame.Angles(0, 3.141592653589793 * v21, 0))

						if v22 == 1 then
							break
						else
							RunService.RenderStepped:Wait()
						end
					end

					clone5:Destroy()
				end)
				v9.RingFire = lastTime
			end

			if lastTime - v9.SwirlFire > 0.06666666666666667 then
				task.spawn(function()
					local number = random:NextNumber(2.75, 5.5)
					local number2 = random:NextNumber(2, 6)
					local cframe5 = CFrame.new(0, 0, (12.5 + number2) * 3.5)
					local cframe6 = CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
					local clone5 = assets.AnimatedSwirl:Clone()
					clone5.Swirlwind:Destroy()
					clone5:SetPrimaryPartCFrame(v15 * cframe5 * CFrame.Angles(1.5707963267948966, 0, 0) * cframe6)
					Util.SetParentOverrideWithColor(clone5, model, p5, "DragonFruitVFXColor")
					destroyAfter(clone5, 7)
					local v19 = {}
					local v20 = {
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

					for _, child in ipairs(clone5:GetChildren()) do
						if child ~= clone5.PrimaryPart then
							v19[child] = {
								Offset = clone5.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
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

					for k, v21 in pairs(v19) do
						k.Mesh.Scale = v21.Mesh.Scale * 3.5 * Vector3.new(number, number2, number)
					end

					for i = 1, #v20 do
						local v21 = i / #v20
						local quint = Util.Tween.ease.out.quint(v21, 0, 1, 1)

						for k, _ in pairs(v19) do
							k.Decal.Texture = v20[i]
							k.Decal.Color3 = Util.WrapColor3Constructor(
								Color3.fromRGB(1500 - 200 * quint, 800 - 550 * quint, 255 - 100 * quint),
								p5,
								"DragonFruitVFXColor"
							)
						end

						task.wait(0.016666666666666666)
					end

					for k, _ in pairs(v19) do
						v19[k] = nil
					end

					clone5:Destroy()
				end)
				v9.SwirlFire = lastTime
			end

			if v11 == 1 then
				break
			end

			RunService.RenderStepped:Wait()
			local _ = tick() - lastTime
		end

		local v10 = 0

		for _, effect in ipairs(folder:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				v10 = math.max(v10, effect.Lifetime.Max)
				effect.Enabled = false
			elseif effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local now2 = tick()
		local v11 = time()

		for _ = 1, 600 do
			if time() - v11 > 10 then
				break
			end

			local now3 = tick()
			local v12 = math.min(1, (now3 - now2) / v)

			for k, v13 in pairs(v2) do
				k.Mesh.Scale = v13.Mesh.Scale * 3.5 * createVector(1.5, 1, 1.5) * Vector3.new(1 - v12, 1, 1 - v12)
				k.Decal.Transparency = v13.Decal.Transparency + (1 - v13.Decal.Transparency) * v12
			end

			for k, v13 in pairs(v6) do
				k.Mesh.Scale = v13.Mesh.Scale * 3.5 * createVector(1.25, 1.25, 2) * Vector3.new(1 - v12, 1 - v12, 1)
				k.Decal.Transparency = v13.Decal.Transparency + (1 - v13.Decal.Transparency) * v12
			end

			if v9.SpikyShockwave.Index ~= #v4 and now3 - v9.SpikyShockwave.Last > v9.SpikyShockwave.UpdateRate then
				v9.SpikyShockwave.Index = v9.SpikyShockwave.Index % #v4 + 1
				local v13 = v9.SpikyShockwave.Index / #v4
				local sine = Util.Tween.ease.out.sine(v13, 0, 1, 1)
				local sine2 = Util.Tween.ease["in"].sine(v13, 0, 1, 1)

				for k, v14 in pairs(v3) do
					k.Decal.Texture = v4[v9.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p5,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v14.Decal.Transparency + (1 - v14.Decal.Transparency) * sine2
				end

				for k, v14 in pairs(v5) do
					k.Decal.Texture = v4[v9.SpikyShockwave.Index]
					k.Decal.Color3 = Util.WrapColor3Constructor(
						Color3.fromRGB(1000 - 1000 * sine, 300 - 300 * sine, 100 - 100 * sine),
						p5,
						"DragonFruitVFXColor"
					)
					k.Decal.Transparency = v14.Decal.Transparency + (1 - v14.Decal.Transparency) * sine2
				end

				v9.SpikyShockwave.Last = now3
			end

			if v12 == 1 and v9.SpikyShockwave.Index == #v4 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end

		task.wait(v10 - v)

		for k, _ in pairs(v2) do
			v2[k] = nil
		end

		for k, _ in pairs(v6) do
			v6[k] = nil
		end

		for k, _ in pairs(v3) do
			v3[k] = nil
		end

		for k, _ in pairs(v5) do
			v3[k] = nil
		end

		folder:Destroy()
		model:Destroy()
	end
}