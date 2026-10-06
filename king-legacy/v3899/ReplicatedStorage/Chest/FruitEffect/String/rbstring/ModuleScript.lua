local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local v = {
		Color3.fromRGB(255, 37, 37),
		Color3.fromRGB(255, 180, 50),
		Color3.fromRGB(130, 255, 84),
		Color3.fromRGB(30, 110, 255),
		Color3.fromRGB(255, 41, 238)
	}
	local v2 = {
		-2,
		-1,
		0,
		1,
		2
	}

	for i = 1, 5 do
		local v3 = math.sin((i - 1) * 44.75)
		local v4 = script.Parent["string" .. i]
		v4.Mesh.Scale = createVector(5.443, 0.376, 5.443) * (v3 * 0.25 + 1) * 1.5
		v4.CFrame = p * CFrame.new(v2[i] * 2, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
			math.rad(v2[i] * -7),
			0,
			0
		) * CFrame.Angles(0, -0.4363323129985824, 0)
		v4.Top.Transparency = -1
		local clone = script.Parent.stringshard:Clone()
		clone.CFrame = p * CFrame.new(v2[i] * 2, 0, 0) * CFrame.Angles(0, math.rad(v2[i] * -7), 0) * CFrame.new(
			0,
			-3,
			-10
		) * CFrame.new(0, 0, (math.abs(v2[i]))) * CFrame.Angles(1.3089969389957472, 0, 0)
		clone.Parent = workspace.Effects
		clone.shard.Color = ColorSequence.new(v[i])
		clone.Spark.Color = ColorSequence.new(v[i])
		task.spawn(function()
			task.wait()
			clone.shard:Emit(5)
			clone.Spark:Emit(2)
		end)
		_G.PU:Dust(clone, 1)
	end

	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9272572685",
		Volume = 1,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = script.Parent.string3
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9213520822",
		Volume = 0.5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = script.Parent.string3
	sound2:Play()

	for i = 1, 5 do
		local v4 = script.Parent["string" .. i]
		task.spawn(function()
			task.wait()
			game.TweenService:Create(v4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = v4.CFrame * CFrame.Angles(0, 2.356194490192345, 0)
			}):Play()
			wait(0.15)

			if v4:FindFirstChild("Top") then
				game.TweenService:Create(
					v4.Top,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end
		end)
		task.wait()
	end
end