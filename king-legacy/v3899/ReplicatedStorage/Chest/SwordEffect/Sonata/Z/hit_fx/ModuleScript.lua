local createVector = vector.create
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	local color = script.Parent.Color

	for _, emitter in pairs(script.Parent:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = ColorSequence.new(color)
		end
	end

	local cFrame = script.Parent.CFrame
	local clone = script.grid:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Color = color
	clone.Size = Vector3.new()
	_G.PU:Dust(clone, 2)
	local Utility = require(game.ReplicatedStorage.Chest.Modules.Utility)
	Utility.EmitParticles(script.Parent)
	game.TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(9, 0.5, 9),
		CFrame = cFrame
	}):Play()
	task.spawn(function()
		wait(0.35)
		game.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB()
		}):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
	wait()
	PeodizService.ForLoop({
		Step = 4,
		WaitTime = 0.03
	}, function(p)
		local v = math.floor(p * 4)
		local cFrame2 = cFrame * CFrame.Angles(0, 1.5707963267948966 * v, 0) * CFrame.new(0, 0, 10)
		local clone2 = script.grid:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Color = color
		clone2.Size = Vector3.new()
		_G.PU:Dust(clone2, 2)
		game.TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(8, 0.5, 8),
			CFrame = cFrame2
		}):Play()
		task.spawn(function()
			wait(0.35)
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Color = Color3.fromRGB()
				}
			):Play()
			game.TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
	end)
	PeodizService.ForLoop({
		Step = 4,
		WaitTime = 0.03
	}, function(p)
		local v = math.floor(p * 4)
		local cFrame2 = cFrame * CFrame.Angles(0, 0.7853981633974483, 0) * CFrame.Angles(0, 1.5707963267948966 * v, 0) * CFrame.new(
			0,
			0,
			12
		) * CFrame.Angles(0, 0.7853981633974483, 0)
		local clone2 = script.grid:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Color = color
		clone2.Size = Vector3.new()
		_G.PU:Dust(clone2, 2)
		game.TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(6, 0.5, 6),
			CFrame = cFrame2
		}):Play()
		task.spawn(function()
			wait(0.35)
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Color = Color3.fromRGB()
				}
			):Play()
			game.TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
	end)
end