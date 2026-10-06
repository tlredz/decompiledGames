local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local function local_rangeshake(p2, value, p3)
		task.spawn(function()
			value = value or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
				_G.shake(p2)
			end
		end)
	end

	local cf = p.cf
	local v = 35
	local p2 = cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
			_G.shake(v2)
		end
	end)

	local function lightning(p3, p4, p5, color)
		local v3 = {}
		v3[#v3 + 1] = p3
		local cframe = CFrame.new(p3, p4)

		for i = 1, p5 do
			math.random(-2, 2)
			local v4 = p3 + (p4 - p3).Unit * i * (p4 - p3).magnitude / p5
			local cframe2 = CFrame.new(v4) * (cframe - cframe.p) * CFrame.new(
				math.cos(9.42477796076938 * i / p5) * 12,
				math.sin(9.42477796076938 * i / p5) * 12,
				0
			)

			if i == p5 then
				cframe2 = CFrame.new(v4)
			end

			v3[#v3 + 1] = cframe2.p
		end

		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v3
			}, function(p6)
				local v4 = math.floor(p6 * #v3)

				if v3[v4 + 1] ~= nil then
					local part = Instance.new("Part")
					part.Transparency = 0
					part.Anchored = true
					part.Color = color
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = createVector(0, 0, 0)
					part.CFrame = CFrame.new((v3[v4] + v3[v4 + 1]) / 2, v3[v4]) * CFrame.new(
						0,
						0,
						-(v3[v4] - v3[v4 + 1]).magnitude / 2
					)
					part.Parent = workspace.Effects
					part.CFrame = CFrame.new((v3[v4] + v3[v4 + 1]) / 2, v3[v4])
					part.Size = Vector3.new(1, 1, (v3[v4] - v3[v4 + 1]).magnitude)
					_G.PU:Dust(part, 0.5)
					spawn(function()
						wait(0.1)
						TweenService:Create(
							part,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(0, 0, (v3[v4] - v3[v4 + 1]).magnitude)
							}
						):Play()
					end)
				end
			end)
		end)
		task.delay(10, function()
			table.clear(v3)
		end)
	end

	lightning(cf.p, (cf * CFrame.new(0, 0, -80)).p, 14, Color3.fromRGB(81, 108, 229))
	PeodizService.ForLoop({
		Step = 8
	}, function(p3)
		local v3 = math.floor(p3 * 8)
		local v4 = v3 % 2 == 0 and -1 or 1
		local clone = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.path:Clone()
		clone.Parent = workspace.Effects
		clone.Size = Vector3.new()
		clone.CFrame = cf * CFrame.new(0, -3.25, v3 * -10) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		_G.PU:Dust(clone, 2)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(22.742, 1.616, 22)
		}):Play()
		clone.Smoke:Emit(10)
		clone.p1:Emit(6)
		clone.p2:Emit(6)
		clone.sw1:Emit(2)
		clone.sakura1:Emit(5)
		local clone2 = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.rose:Clone()
		_G.PU:Dust(clone2, 2)
		clone2.Size = Vector3.new()
		clone2.CFrame = cf * CFrame.new(math.random(3, 5) * v4, -1, v3 * -10) * CFrame.Angles(
			0,
			6.283185307179586 * math.random(),
			(math.rad((math.random(0, 20))))
		)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(19.114, 7.425, 18.027)
		}):Play()
		local clone3 = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.spike:Clone()
		clone3.Parent = workspace.Effects
		clone3.Size = createVector(1, 0, 1)
		clone3.CFrame = cf * CFrame.new(math.random(4, 5) * -v4, 5, v3 * -10) * CFrame.new(
			math.random(-2, 2),
			0,
			math.random(-2, 2)
		) * CFrame.Angles(0, 0, (math.rad((math.random(-15, 15)))))
		_G.PU:Dust(clone3, 2)
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(2.705, 19.838, 2.705)
		}):Play()
		task.spawn(function()
			wait(1)
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end)
end