local localPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
return function(_)
	local main = localPlayer.PlayerGui:FindFirstChild("Main")

	if main then
		local v = math.max(main.AbsoluteSize.X, main.AbsoluteSize.Y) * 2
		local imageLabel = Instance.new("ImageLabel")
		Util.Debris:AddItem(imageLabel, 2)
		imageLabel.Image = "rbxassetid://989615068"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.new(0, 0, 0, 0)
		imageLabel.ImageColor3 = Color3.new(0, 0.85, 0)
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageLabel.ImageTransparency = 0.6
		imageLabel.BackgroundTransparency = 1
		imageLabel.ZIndex = -100
		imageLabel.Active = false
		imageLabel.Parent = main
		local tween = TweenService:Create(imageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, v, 0, v),
			ImageTransparency = 1
		})
		tween.Completed:Connect(function()
			tween:Destroy()
		end)
		tween:Play()
	end
end