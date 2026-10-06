local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local cf = p.cf

	if p.plr == game.Players.LocalPlayer then
		_G.shake("SmallerBump")
	end

	local function Lightning(data)
		local beginCF = data.BeginCF
		local endCF = data.EndCF
		local color = data.Color
		local _ = data.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = (endCF.p - beginCF.p).Magnitude / 8
		local v2 = math.random(1, 3)
		local v3 = {}

		for i = 0, 8 do
			local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))

			if i == 0 or i == 8 then
				vector2 = Vector3.new()
			end

			v3[#v3 + 1] = beginCF.p + unit * v * i + vector2
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
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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

	task.spawn(function()
		for i = 1, 3 do
			local clone = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_dash.wind_ring:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = cf * CFrame.new(0, 0, 20) * CFrame.new(0, 0, -i * 30) * CFrame.Angles(
				1.5707963267948966,
				6.283185307179586 * math.random(),
				0
			)
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript(11 - i * 2)
			_G.PU:Dust(clone, 1)
			wait()
		end
	end)
	task.spawn(function()
		Lightning({
			BeginCF = cf,
			EndCF = cf * CFrame.new(0, 0, -70)
		})
		wait()
		Lightning({
			BeginCF = cf,
			EndCF = cf * CFrame.new(0, 0, -70),
			Color = Color3.fromRGB(94, 167, 255)
		})
	end)
	local v = 1.5

	for i = 1, 2 do
		local v2 = i
		task.spawn(function()
			if v2 == 2 then
				v = -v
			end

			local v3 = cf * CFrame.new(v, 0, 0)
			local clone = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_dash.MeshPart:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = v3 * CFrame.new(0, 0, -10)
			clone.Size = createVector(5, 5, 1)
			local clone2 = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_dash.black:Clone()
			clone2.CFrame = v3 * CFrame.Angles(0, -1.5707963267948966, 0)
			clone2.Parent = workspace.Effects
			local clone3 = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_dash.blue:Clone()
			clone3.CFrame = v3 * CFrame.Angles(0, -1.5707963267948966, 0)
			clone2.Mesh.Scale = createVector(2.1585, 0.276, 0.2835)
			clone3.Mesh.Scale = createVector(0.96599996, 0.1485, 0.1635)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.5)
			_G.PU:Dust(clone3, 1)
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(1, 1, 25)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(-45, 0, 0)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(-37.5, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			task.spawn(function()
				TweenService:Create(
					clone2.Mesh,
					TweenInfo.new(0.175, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(1.839, 0.054, 0.044)
					}
				):Play()
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.644, 0.039, 0.048)
					}
				):Play()
				wait()
				TweenService:Create(
					clone3.Texture,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.new(0, 0, -30)
					}
				):Play()
				TweenService:Create(
					clone2.Texture,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			wait(0.1)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 70)
			}):Play()
		end)
	end

	local clone = ReplicatedStorage.Chest.Etc.Electro.ElectroV2.lightning_dash.Part2:Clone()
	clone.CFrame = cf * CFrame.new(0, 0, -35)
	clone.Parent = workspace.Effects
	clone.lightning1:Emit(12)
	clone.shards1:Emit(12)
	_G.PU:Dust(clone, 1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11244205626",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
end