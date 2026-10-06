local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Chest.Modules.PeodizService)
return function(data)
	local _ = data.cf
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local cf = data.cf
	local attack = data.attack
	local root = data.root
	local _ = data.char

	if attack == 3 then
		localshake({
			6.5,
			8.5,
			0,
			1
		}) -- equivalent call inferred; original call site unknown
		local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.head_butt:Clone()
		clone.CFrame = cf * CFrame.new(0, -25, -50)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Range = 60
		pointLight.Brightness = 1
		pointLight.Color = Color3.fromRGB(255, 0, 0)
		wait()
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()
	elseif attack == 2 then
		for i = 1, 3 do
			local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.claw:Clone()
			clone.Anchored = false
			clone.CFrame = cf
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local Animate = require(clone.Animate)
			Animate()
			local weld = Instance.new("Weld")
			weld.Part0 = root
			weld.Part1 = clone
			weld.C0 = CFrame.new(0, i * 8 + -24, -34) * CFrame.Angles(
				0.5585053606381855,
				2.2689280275926285,
				-0.5585053606381855
			)
			weld.Parent = clone
			_G.PU:Dust(weld, 1)
			clone.Mesh.Scale = clone.Mesh.Scale * 2
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.claw_line:Clone()
			clone2.Anchored = false
			clone2.CFrame = cf
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			local weld2 = Instance.new("Weld")
			weld2.Part0 = root
			weld2.Part1 = clone2
			weld2.C0 = CFrame.new(0, i * 8 + -19.5, -72) * CFrame.Angles(0, 0, 0.3490658503988659)
			weld2.Parent = clone2
			_G.PU:Dust(weld2, 1)
			task.delay(0.2, function()
				if weld then
					weld:Destroy()
				end

				if weld2 then
					weld2:Destroy()
				end

				if clone then
					clone.Anchored = true
				end

				if clone2 then
					clone2.Anchored = true
				end
			end)
			local folder = clone2
			local v5 = i
			task.spawn(function()
				wait()

				for i2, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Ring" then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				if v5 == 2 then
					local pointLight = Instance.new("PointLight")
					pointLight.Parent = folder
					pointLight.Range = 40
					pointLight.Brightness = 1
					pointLight.Color = Color3.fromRGB(255, 0, 0)
					folder.Attachment.Ring:Emit(1)
					wait()
					TweenService:Create(
						pointLight,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
				end
			end)
			TweenService:Create(weld, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C0 = weld.C0 * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
			local v6 = weld
			task.spawn(function()
				wait()
				TweenService:Create(v6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					C0 = v6.C0 * CFrame.Angles(0, 3.1101767270538954, 0)
				}):Play()
			end)
		end
	elseif attack == 1 then
		for i = 1, 3 do
			local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.claw:Clone()
			clone.Anchored = false
			clone.CFrame = cf
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local Animate = require(clone.Animate)
			Animate()
			local weld = Instance.new("Weld")
			weld.Part0 = root
			weld.Part1 = clone
			weld.C0 = CFrame.new(0, i * 8 + -26, -34) * CFrame.Angles(
				0.5585053606381855,
				0.6981317007977318,
				-0.5585053606381855
			)
			weld.Parent = clone
			_G.PU:Dust(weld, 1)
			clone.Mesh.Scale = clone.Mesh.Scale * 2
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.claw_line:Clone()
			clone2.Anchored = false
			clone2.CFrame = cf
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			local weld2 = Instance.new("Weld")
			weld2.Part0 = root
			weld2.Part1 = clone2
			weld2.C0 = CFrame.new(0, i * 8 + -19.5, -72) * CFrame.Angles(0, 0, -0.4363323129985824)
			weld2.Parent = clone2
			_G.PU:Dust(weld2, 1)
			task.delay(0.2, function()
				if weld then
					weld:Destroy()
				end

				if weld2 then
					weld2:Destroy()
				end

				if clone then
					clone.Anchored = true
				end

				if clone2 then
					clone2.Anchored = true
				end
			end)
			local folder = clone2
			local v5 = i
			task.spawn(function()
				wait()

				for i2, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Ring" then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				if v5 == 2 then
					local pointLight = Instance.new("PointLight")
					pointLight.Parent = folder
					pointLight.Range = 40
					pointLight.Brightness = 1
					pointLight.Color = Color3.fromRGB(255, 0, 0)
					folder.Attachment.Ring:Emit(1)
					wait()
					TweenService:Create(
						pointLight,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
				end
			end)
			TweenService:Create(weld, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C0 = weld.C0 * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
			local v6 = weld
			task.spawn(function()
				wait()
				TweenService:Create(v6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					C0 = v6.C0 * CFrame.Angles(0, -3.1101767270538954, 0)
				}):Play()
			end)
		end
	end
end