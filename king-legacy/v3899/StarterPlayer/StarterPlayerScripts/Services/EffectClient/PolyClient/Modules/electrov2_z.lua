local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local cf = p.cf
	local _ = p.plr
	local localPlayer = game.Players.LocalPlayer

	local function Lightning(data)
		local beginCF = data.BeginCF
		local endCF = data.EndCF
		local color = data.Color
		local _ = data.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = (endCF.p - beginCF.p).Magnitude / 7
		local v2 = math.random(5, 35) / 10
		local v3 = {}

		for i = 0, 7 do
			local vector = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))

			if i == 0 or i == 7 then
				vector = Vector3.new()
			end

			v3[#v3 + 1] = beginCF.p + unit * v * i + vector
		end

		task.spawn(function()
			PeodizService.ForceForLoop({
				Step = #v3
			}, function(p2)
				local v4 = math.floor(p2 * #v3)
				local v5 = v3[v4]
				local v6 = v3[v4 + 1]

				if v6 then
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.Anchored = true
					part.Color = color or Color3.fromRGB(43, 117, 255)
					part.Material = "Neon"
					part.Size = Vector3.new(v2, v2, (v5 - v6).Magnitude)
					part.CFrame = CFrame.new(v5, v6) * CFrame.new(0, 0, -(v5 - v6).Magnitude / 2)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.2)
				end
			end)
			task.delay(10, function()
				table.clear(v3)
			end)
		end)
	end

	local clone = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_overload.fx:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	_G.PU:Dust(clone, 2)
	tick()
	local v = 1
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11271018931",
		Volume = 2,
		PlaybackSpeed = 1.1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	PeodizService.HeartbeatWait({
		Time = 0.75
	}, function()
		v += 1

		if v % 2 == 1 then
			if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 60 or game.Players.LocalPlayer == p.plr then
				_G.shake("SmallerBump")
			end

			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone
			pointLight.Color = Color3.fromRGB(82, 122, 255)
			pointLight.Range = 55
			pointLight.Brightness = 1
			game.TweenService:Create(
				pointLight,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0.25,
					Range = 0
				}
			):Play()
			_G.PU:Dust(pointLight, 0.25)
		end

		if v % 5 == 1 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11268065511",
				Volume = 0.25,
				PlaybackSpeed = 1.4
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6402471929",
				Volume = 2,
				PlaybackSpeed = 1.75
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone
			sound3:Play()
		end

		if clone then
			if clone:FindFirstChild("shard") then
				clone.shard:Emit(5)
			end

			if clone:FindFirstChild("lightning1") then
				clone.lightning1:Emit(math.random(1, 2))
			end
		end

		local v2 = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -50)
		local _ = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -50)
		task.spawn(function()
			Lightning({
				BeginCF = cf,
				EndCF = v2 * CFrame.new(0, 0, 100),
				Color = Color3.fromRGB(102, 184, 255)
			})
		end)
	end)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11268133433",
		Volume = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 60 or game.Players.LocalPlayer == p.plr then
		_G.shake("Bump")
	end

	if clone then
		if clone:FindFirstChild("shard2") then
			clone.shard2:Emit(15)
		end

		if clone:FindFirstChild("flare2") then
			clone.flare2:Emit(10)
		end
	end

	local clone2 = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_overload.wind_ring:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = cf
	_G.PU:Dust(clone2, 1)
	local ModuleScript = require(clone2.ModuleScript)
	ModuleScript(55)
end