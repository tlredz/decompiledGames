local replicatedStorage = game.ReplicatedStorage
local v = {
	"rbxassetid://7850072140",
	"rbxassetid://7850071666",
	"rbxassetid://7850071178",
	"rbxassetid://7850070711",
	"rbxassetid://7850070156",
	"rbxassetid://7850069707",
	"rbxassetid://7850069436",
	"rbxassetid://7850069207",
	"rbxassetid://7850068914",
	"rbxassetid://7850068711",
	"rbxassetid://7850068392",
	"rbxassetid://7850068069",
	"rbxassetid://7850067802",
	"rbxassetid://7850067227",
	"rbxassetid://7850066757",
	"rbxassetid://7850066121",
	"rbxassetid://7850065784"
}
local v2 = {
	"rbxassetid://7850028225",
	"rbxassetid://7850027391",
	"rbxassetid://7850026699",
	"rbxassetid://7850025913",
	"rbxassetid://7850025472",
	"rbxassetid://7850024936",
	"rbxassetid://7850024696",
	"rbxassetid://7850024253",
	"rbxassetid://7850023850",
	"rbxassetid://7850023614",
	"rbxassetid://7850023363",
	"rbxassetid://7850023080",
	"rbxassetid://7850022899",
	"rbxassetid://7850022657",
	"rbxassetid://7850022476",
	"rbxassetid://7850022243",
	"rbxassetid://7850022057",
	"rbxassetid://7850021851",
	"rbxassetid://7850021695",
	"rbxassetid://7850021440"
}
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local cFrame = script.Parent.CFrame
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cFrame
		clone.CFrame *= CFrame.Angles(0, 2.181661564992912, 0)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(255, 113, 66)
		pointLight.Brightness = 0
		pointLight.Range = 0
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1,
				Range = 30
			}
		):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v3 = math.floor(p * #v)

				if clone:FindFirstChild("Top") then
					clone.Top.Texture = v[v3]
				end
			end)
		end)
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if clone:FindFirstChild("Bottom") then
				clone.Bottom.Texture = v2[v3]
			end
		end)

		if clone:FindFirstChild("Bottom") then
			clone.Bottom.Texture = ""
		end

		if clone:FindFirstChild("Top") then
			clone.Top.Texture = ""
		end

		_G.PU:Dust(clone, 1)
	end)
end