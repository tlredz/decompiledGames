local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
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

	local positions = data.positions
	local v = 100
	local p = data.cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.FruitEffect.Gold.field:Clone()
	_G.PU:Dust(clone, 8)
	clone.Transparency = 1
	clone.Size = createVector(150, 0.2, 150)
	clone.CFrame = data.cf * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0.7853981633974483, 0)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12907385522",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0,
		Size = createVector(240, 0.2, 240)
	}):Play()
	clone.spec.Enabled = true
	task.spawn(function()
		wait(7)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		clone.spec.Enabled = false
	end)

	for i = 1, #positions do
		local clone2 = replicatedStorage.Chest.FruitEffect.Gold.gold_tower:Clone()
		clone2:SetPrimaryPartCFrame(CFrame.new(positions[i]))
		clone2.Circle.Size = Vector3.new()
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 8)
		TweenService:Create(clone2.Circle, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(42.5, 1.7, 42.5)
		}):Play()
		local folder = clone2
		task.spawn(function()
			folder.AnimationController:LoadAnimation(folder.spawn):Play()
			TweenService:Create(
				folder.Circle.AT2,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Position = createVector(0, 85, 0)
				}
			):Play()
			wait(0.1)

			if folder then
				for i2, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			wait(6.9)

			if folder then
				for i2, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if folder:FindFirstChild("Circle") and folder.Circle:FindFirstChild("BeamMain1") then
					TweenService:Create(
						folder.Circle.BeamMain1,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					):Play()
				end

				if folder:FindFirstChild("Circle") then
					TweenService:Create(
						folder.Circle,
						TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 1.7, 0)
						}
					):Play()
				end
			end
		end)
	end
end