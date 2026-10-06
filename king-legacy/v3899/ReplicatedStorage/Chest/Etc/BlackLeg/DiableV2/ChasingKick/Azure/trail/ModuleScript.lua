local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	local cFrame = script.Parent.CFrame
	local parent = script.Parent
	PeodizService.ForLoop({
		Step = 12,
		WaitTime = 0.05
	}, function(p)
		local v = math.floor(p * 12)
		local cFrame2 = cFrame * CFrame.new(
			math.sin(3.141592653589793 * v / 12 * 2.5) * 25,
			v * 6,
			math.cos(3.141592653589793 * v / 12 * 2.5) * 25
		)
		game.TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cFrame2
		}):Play()
	end)
end