local localPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local playerGui = localPlayer ~= nil and localPlayer:FindFirstChild("PlayerGui") ~= nil and localPlayer.PlayerGui or game.CoreGui
local parent2 = playerGui:FindFirstChild("ScreenEffects")

if parent2 == nil then
	parent2 = Instance.new("ScreenGui")
	parent2.Name = "ScreenEffects"
	parent2.ResetOnSpawn = false
	parent2.ScreenInsets = Enum.ScreenInsets.None
	parent2.Parent = playerGui
	parent2.DisplayOrder = 99999
end

local tweenInfo = TweenInfo.new(0.2)
local max = math.max
local ScreenEffects = {
	StrokeClick = function(parent, udim: UDim?, flag: boolean?)
		if parent == nil then
			return
		end

		local cornerRadius = udim or UDim.new(0.25)
		local absoluteSize = parent.AbsoluteSize
		local absolutePosition = parent.AbsolutePosition
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)

		if flag then
			frame.Position = UDim2.fromScale(0.5, 0.5)
			frame.Parent = parent
		else
			frame.Position = UDim2.fromOffset(
				absolutePosition.X + absoluteSize.X / 2,
				absolutePosition.Y + absoluteSize.Y / 2 + GuiService:GetGuiInset().Y
			)
			frame.Parent = parent2
		end

		frame.BackgroundTransparency = 1
		frame.ZIndex = 999
		local uICorner = Instance.new("UICorner", frame)
		uICorner.CornerRadius = cornerRadius
		uICorner.Parent = frame
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 4
		uIStroke.Color = Color3.new(1, 1, 1)
		uIStroke.Parent = frame
		local v4 = max((absoluteSize.Y + absoluteSize.X) / 2 * 0.05, 9)
		TweenService:Create(frame, tweenInfo, {
			Size = frame.Size + UDim2.fromOffset(v4, v4)
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Thickness = 0
		}):Play()
		script.Click_Select:Play()
		task.delay(0.25, function()
			frame:Destroy()
		end)
	end
}
local tweenInfo2 = TweenInfo.new(0.25)

function ScreenEffects.CircleClick(p)
	local mouseLocation = UserInputService:GetMouseLocation()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(25, 25)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "http://www.roblox.com/asset/?id=17359135613"
	imageLabel.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
	imageLabel.Parent = p or parent2
	imageLabel.ZIndex = 999
	TweenService:Create(imageLabel, tweenInfo2, {
		Size = UDim2.fromOffset(45, 45),
		ImageTransparency = 1
	}):Play()
	script.Click_Select:Play()
	task.delay(0.25, function()
		imageLabel:Destroy()
	end)
end

return ScreenEffects