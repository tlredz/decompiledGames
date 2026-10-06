local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local target = p.Target

	if not target then
		return
	end

	local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = CFrame.new(humanoidRootPart.Position).Position
	local position2 = (CFrame.new(humanoidRootPart.Position) + Vector3.new(
		math.random(-6, 6),
		math.random(25, 40),
		math.random(-6, 6)
	)).Position

	local function lightning(position3, position4, p2, color)
		local v = {}
		v[#v + 1] = position3

		for i = 1, p2 do
			local v2 = math.random(-2, 2)
			local v3 = position3 + (position4 - position3).Unit * i * (position4 - position3).magnitude / p2
			local cframe = CFrame.new(v3) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				v2
			)

			if i == p2 then
				cframe = CFrame.new(v3)
			end

			v[#v + 1] = cframe.p
		end

		spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p3)
				local v2 = math.floor(p3 * #v)

				if v[v2 + 1] ~= nil then
					local v3 = 0.6 - (v2 / #v + 0.2) * 0.4
					local part = Instance.new("Part")
					part.Transparency = 0
					part.Anchored = true
					part.Color = color
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = createVector(0, 0, 0)
					part.CFrame = CFrame.new((v[v2] + v[v2 + 1]) / 2, v[v2]) * CFrame.new(
						0,
						0,
						-(v[v2] - v[v2 + 1]).magnitude / 2
					)
					part.Parent = workspace.Effects
					part.CFrame = CFrame.new((v[v2] + v[v2 + 1]) / 2, v[v2])
					part.Size = Vector3.new(v3, v3, (v[v2] - v[v2 + 1]).magnitude)
					local clone = game.ReplicatedStorage.Chest.Etc.shards1:Clone()
					clone.Parent = part
					clone:Emit(8)
					_G.PU:Dust(part, 0.5)
					spawn(function()
						wait(0.1)
						TweenService:Create(
							part,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(0, 0, (v[v2] - v[v2 + 1]).magnitude)
							}
						):Play()
					end)
				end
			end)
			task.delay(10, function()
				table.clear(v)
			end)
		end)
	end

	local function lightning2(position3, position4, p2, color)
		local v = {}
		v[#v + 1] = position3

		for i = 1, p2 do
			local v2 = math.random(-2, 2)
			local v3 = position3 + (position4 - position3).Unit * i * (position4 - position3).magnitude / p2
			local cframe = CFrame.new(v3) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				v2
			)

			if i == p2 then
				cframe = CFrame.new(v3)
			end

			v[#v + 1] = cframe.p
		end

		spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p3)
				local v2 = math.floor(p3 * #v)

				if v[v2 + 1] ~= nil then
					local v3 = 0.4 - (v2 / #v + 0.2) * 0.3
					local part = Instance.new("Part")
					part.Transparency = 0
					part.Anchored = true
					part.Color = color
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = createVector(0, 0, 0)
					part.CFrame = CFrame.new((v[v2] + v[v2 + 1]) / 2, v[v2]) * CFrame.new(
						0,
						0,
						-(v[v2] - v[v2 + 1]).magnitude / 2
					)
					part.Parent = workspace.Effects
					part.CFrame = CFrame.new((v[v2] + v[v2 + 1]) / 2, v[v2])
					part.Size = Vector3.new(v3, v3, (v[v2] - v[v2 + 1]).magnitude)
					_G.PU:Dust(part, 0.5)
					spawn(function()
						wait(0.05)
						TweenService:Create(
							part,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(0, 0, (v[v2] - v[v2 + 1]).magnitude)
							}
						):Play()
					end)
				end
			end)
			task.delay(10, function()
				table.clear(v)
			end)
		end)
	end

	lightning(position2, position, math.random(6, 7), Color3.fromRGB(117, 110, 255))
	lightning2(position2, position, math.random(4, 5), Color3.fromRGB(39, 36, 84))
	wait()
	local clone = game.ReplicatedStorage.Chest.Etc.LPOS:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13227831551",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()

	for _, emitter in pairs(clone.AT1:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end