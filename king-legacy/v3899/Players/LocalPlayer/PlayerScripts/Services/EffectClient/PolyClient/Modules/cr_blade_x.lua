local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

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

	local cframe = CFrame.new(data.tocf.p + createVector(0, 3.5, 0))
	local p = data.fromcf.p
	local p2 = data.tocf.p
	local v = 35
	local p3 = cframe.p
	local v2 = "SmallerBump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.path:Clone()
	clone.Parent = workspace.Effects
	clone.Size = Vector3.new()
	clone.CFrame = CFrame.new(p, p2) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)
	_G.PU:Dust(clone, 2)
	clone.Attachment.sakura1:Emit(8)
	clone.Attachment.p1:Emit(4)
	clone.ParticleEmitter:Emit(6)
	clone.Attachment.ice:Emit(4)
	clone.shard:Emit(math.random(3, 4))
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13277173553",
		Volume = 1.2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	game.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(7, 0.863, 7)
	}):Play()
	task.spawn(function()
		wait(0.3)
		game.TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)

	local function lightning(p4, p5, p6, color)
		local v3 = {}
		v3[#v3 + 1] = p4
		local cframe2 = CFrame.new(p, p2)

		for i = 1, p6 do
			math.random(-2, 2)
			local v4 = p4 + (p5 - p4).Unit * i * (p5 - p4).magnitude / p6
			local cframe3 = CFrame.new(v4) * (cframe2 - cframe2.p) * CFrame.new(
				math.cos(9.42477796076938 * i / p6) * 2,
				math.sin(9.42477796076938 * i / p6) * 2,
				0
			)

			if i == p6 then
				cframe3 = CFrame.new(v4)
			end

			v3[#v3 + 1] = cframe3.p
		end

		PeodizService.ForceForLoop({
			Step = #v3
		}, function(p7)
			local v4 = math.floor(p7 * #v3)

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
		task.delay(10, function()
			table.clear(v3)
		end)
	end

	lightning(p, p2, 8, Color3.fromRGB(81, 108, 229))
	local clone2 = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.rose:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.Size = Vector3.new()
	clone2.CFrame = cframe * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	clone2.Parent = workspace.Effects
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13267965244",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 125,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11757081281",
		Volume = 1.1
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()
	local clone3 = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.path:Clone()
	clone3.Parent = workspace.Effects
	clone3.Size = Vector3.new()
	clone3.CFrame = cframe * CFrame.new(0, -3.25, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	_G.PU:Dust(clone3, 2)
	game.TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(19.114, 7.425, 18.027)
	}):Play()
	game.TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(22.742, 1.616, 22)
	}):Play()
	clone3.Smoke:Emit(10)
	clone3.p1:Emit(6)
	clone3.p2:Emit(6)
	clone3.sw1:Emit(2)
	clone3.sakura1:Emit(5)
	task.spawn(function()
		wait(1)
		game.TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		game.TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	for _ = 1, 3 do
		local clone4 = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.spike:Clone()
		clone4.Parent = workspace.Effects
		clone4.Size = createVector(1, 0, 1)
		clone4.CFrame = cframe * CFrame.new(0, 4, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
			0,
			0,
			math.random(6, 7)
		) * CFrame.Angles(0, 0, (math.rad((math.random(15, 25)))))
		_G.PU:Dust(clone4, 2)
		game.TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(2, 15, 2)
		}):Play()
		task.spawn(function()
			wait(1)
			game.TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end
end