local _ = game.ReplicatedStorage
local _ = {
	"rbxassetid://9051285479",
	"rbxassetid://9051285231",
	"rbxassetid://9051285043",
	"rbxassetid://9051284824",
	"rbxassetid://9051284673",
	"rbxassetid://9051284519",
	"rbxassetid://9051284319",
	"rbxassetid://9051284195",
	"rbxassetid://9051284067",
	"rbxassetid://9051283931",
	"rbxassetid://9051283730",
	"rbxassetid://9051283505"
}
return function()
	task.spawn(function()
		local cFrame = script.Parent.CFrame
		local clone = script.Parent:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = cFrame
		clone.CFrame = clone.CFrame
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(255, 113, 66)
		pointLight.Brightness = 0
		pointLight.Range = 0
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 1,
				Range = 20
			}
		):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -3.141592653589793, 0) * CFrame.new(0, 0, -2.5)
		}):Play()
		task.spawn(function()
			wait()

			if clone:FindFirstChild("Top") then
				game.TweenService:Create(
					clone.Top,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end
		end)

		if clone:FindFirstChild("Top") then
			clone.Top.Texture = "rbxassetid://9051285043"
		end

		_G.PU:Dust(clone, 1)
	end)
end