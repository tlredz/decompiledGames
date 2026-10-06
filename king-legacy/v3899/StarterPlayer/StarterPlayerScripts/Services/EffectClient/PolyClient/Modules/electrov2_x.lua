local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local cframe = CFrame.new(data.tocf.p)

	local function Lightning2(data2)
		local beginCF = data2.BeginCF
		local endCF = data2.EndCF
		local color = data2.Color
		local _ = data2.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = (endCF.p - beginCF.p).Magnitude / 8
		local v2 = math.random(15, 40) / 10
		local v3 = {}

		for i = 0, 8 do
			local vector2 = Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))

			if i == 0 or i == 8 then
				vector2 = Vector3.new()
			end

			v3[#v3 + 1] = beginCF.p + unit * v * i + vector2
		end

		task.spawn(function()
			PeodizService.ForceForLoop({
				Step = #v3
			}, function(p)
				local v4 = math.floor(p * #v3)
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
					TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.3)
				end
			end)
			task.delay(10, function()
				table.clear(v3)
			end)
		end)
	end

	local function Lightning(data2)
		local beginCF = data2.BeginCF
		local endCF = data2.EndCF
		local color = data2.Color
		local _ = data2.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = (endCF.p - beginCF.p).Magnitude / 8
		local v2 = math.random(15, 35) / 10
		local v3 = {}

		for i = 0, 8 do
			local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))

			if i == 0 or i == 8 then
				vector2 = Vector3.new()
			end

			v3[#v3 + 1] = beginCF.p + unit * v * i + vector2
		end

		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v3
			}, function(p)
				local v4 = math.floor(p * #v3)
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
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.35)
				end
			end)
			task.delay(10, function()
				table.clear(v3)
			end)
		end)
	end

	task.spawn(function()
		Lightning2({
			BeginCF = cf,
			EndCF = cframe
		})
	end)

	if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 70 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	local clone = replicatedStorage.Chest.Etc.Electro.ElectroV2.thunderclap.ball:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cframe
	_G.PU:Dust(clone, 1.5)
	local clone2 = replicatedStorage.Chest.Etc.Electro.ElectroV2.thunderclap.fx:Clone()
	_G.PU:Dust(clone2, 1)
	clone2.CFrame = cframe
	clone2.Parent = workspace.Effects
	clone2.Attachment.Spark:Emit(3)
	clone2.Attachment.big:Emit(1)
	clone2.Attachment.SparkB:Emit(3)
	clone2.shardl:Emit(20)
	clone2.smoke:Emit(25)
	clone2.Attachment2.ring1:Emit(1)
	clone2.Attachment2.ring2:Emit(1)
	clone2.Attachment2.Lightning:Emit(15)
	local crack = require(script.crack)
	crack(cframe * CFrame.new(0, 0.5, 0))
	task.spawn(function()
		local clone3 = replicatedStorage.Chest.Etc.Electro.ElectroV2.thunderclap.floor:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = cframe * CFrame.Angles(0, 0.7853981633974483, 0)
		clone3.Mesh.Scale = createVector(0, 0.039, 0.181)
		task.spawn(function()
			wait(0.1)

			if clone3:FindFirstChild("Animate") then
				local Animate = require(clone3.Animate)
				Animate()
			end
		end)
		clone3.Decal.Transparency = -0.5
		game.TweenService:Create(
			clone3.Decal,
			TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(clone3.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = createVector(2.546, 0.039, 0.181)
		}):Play()
		_G.PU:Dust(clone3, 1)
	end)
	task.spawn(function()
		local clone3 = replicatedStorage.Chest.Etc.Electro.ElectroV2.thunderclap.floor:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = cframe * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0, 0.7853981633974483, 0)
		clone3.Mesh.Scale = createVector(0, 0.039, 0.181)
		task.spawn(function()
			wait(0.1)
			local Animate = require(clone3.Animate)
			Animate()
		end)
		clone3.Decal.Transparency = -0.5
		game.TweenService:Create(
			clone3.Decal,
			TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(clone3.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = createVector(2.546, 0.039, 0.181)
		}):Play()
		_G.PU:Dust(clone3, 1)
	end)
	local clone3 = replicatedStorage.Chest.Etc.Electro.ElectroV2.thunderclap.wind_ring:Clone()
	clone3.Parent = workspace.Effects
	clone3.CFrame = cframe
	_G.PU:Dust(clone3, 1)
	local ModuleScript = require(clone3.ModuleScript)
	ModuleScript(50)
	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone2
	pointLight.Color = Color3.fromRGB(82, 122, 255)
	pointLight.Range = 60
	pointLight.Brightness = 2
	game.TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0.25,
		Range = 0
	}):Play()
	_G.PU:Dust(pointLight, 1)
	clone.Specs1:Emit(10)
	clone.Specs2:Emit(10)
	local clone4 = script.bw:Clone()
	clone4.Parent = game.Lighting
	_G.PU:Dust(clone4, 0.1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11283070964",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6814067199",
		PlaybackSpeed = 0.8,
		Volume = 3
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	PeodizService.ForLoop({
		Step = 10
	}, function(p)
		math.floor(p * 10)

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 70 or game.Players.LocalPlayer == data.plr then
			_G.shake("SmallerBump")
		end

		clone2.shard:Emit(5)
		clone2.lightning1:Emit(math.random(1, 2))
		clone2.shard2:Emit(5)
		clone2.Attachment.Specs1:Emit(3)
		clone.flare1:Emit(4)
		clone.flare2:Emit(4)
		local _ = cframe * CFrame.Angles(math.rad((math.random(-90, 90))), 0, (math.rad((math.random(-90, 90))))) * CFrame.new(
			0,
			50,
			0
		)
		local endCF = cframe * CFrame.Angles(math.rad((math.random(-90, 90))), 0, (math.rad((math.random(-90, 90))))) * CFrame.new(
			0,
			50,
			0
		)
		local color = Color3.fromRGB(102, 184, 255)
		local _ = math.random(1, 2) == 1
		task.spawn(function()
			Lightning({
				BeginCF = cframe,
				EndCF = endCF,
				Color = color
			})
		end)
	end)
end