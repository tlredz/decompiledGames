local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local function KAT(localPlayer, value, p)
	for _, parent in { localPlayer.PlayerGui } do
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "KAT"
		screenGui.IgnoreGuiInset = true
		screenGui.ClipToDeviceSafeArea = false
		screenGui.DisplayOrder = #parent:GetChildren() + 50000
		screenGui.Parent = parent
		local imageLabel = Instance.new("ImageLabel", screenGui)
		imageLabel.Image = "rbxassetid://71982941818880"
		imageLabel.Size = UDim2.new(0, 1, 0, 1)
		imageLabel.ResampleMode = Enum.ResamplerMode.Default
		imageLabel.Position = UDim2.new(0, 0, 1, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageRectSize = Vector2.new(68.26, 53.1538)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ContentProvider:PreloadAsync({ imageLabel })
		local v2 = screenGui.AbsoluteSize.X / 68.26
		local v3 = screenGui.AbsoluteSize.Y / 53.1538
		local TweenService = game:GetService("TweenService")
		TweenService:Create(
			imageLabel,
			TweenInfo.new(2.5 * (value or 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, v2 * 2, 1, v3 * 2),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}
		):Play()
		task.wait(0.1 * (value or 1))

		for i = 0, 12 do
			for i2 = 0, 14 do
				imageLabel.ImageRectOffset = Vector2.new(i2 * 68.26, i * 53.1538)
				task.wait(0.03 * (value or 1))
			end
		end

		if p then
			break
		end

		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(
			imageLabel,
			TweenInfo.new(0.1 * (value or 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		):Play()
		task.wait(0.1 * (value or 1))
		screenGui:Destroy()
	end
end

return {
	Start = function(_)
		local Net = require(ReplicatedStorage.packages.Net)
		Net:Connect("KATCommand", function(p, p2)
			KAT(Players.LocalPlayer, p, p2)
		end)
	end
}