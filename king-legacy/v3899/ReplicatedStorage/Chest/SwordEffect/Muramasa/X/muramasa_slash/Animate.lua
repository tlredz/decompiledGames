local _ = game.ReplicatedStorage
local v = {
	"rbxassetid://9051223604",
	"rbxassetid://9051223476",
	"rbxassetid://9051223326",
	"rbxassetid://9051223208",
	"rbxassetid://9051222945",
	"rbxassetid://9051222757",
	"rbxassetid://9051222558",
	"rbxassetid://9051222394",
	"rbxassetid://9051222103",
	"rbxassetid://9051221805",
	"rbxassetid://9051221567",
	"rbxassetid://9051221422",
	"rbxassetid://9051221206",
	"rbxassetid://9051221004",
	"rbxassetid://9051220825",
	"rbxassetid://9051220588",
	"rbxassetid://9051220357",
	"rbxassetid://9051220100",
	"rbxassetid://9051219952",
	"rbxassetid://9051219699"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local cFrame = script.Parent.CFrame
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cFrame
		clone.CFrame = clone.CFrame
		game.TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v2 = math.floor(p * #v)

				if clone:FindFirstChild("Top") then
					clone.Top.Texture = v[v2]
				end
			end)
		end)

		if clone:FindFirstChild("Top") then
			clone.Top.Texture = ""
		end

		_G.PU:Dust(clone, 1)
	end)
end