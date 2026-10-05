local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local count = 0
local v = nil
return function(p)
	local text = p.Text

	if not text then
		return
	end

	local duration = p.Duration or 8
	count += 1
	local v2 = count

	if v then
		v:Destroy()
		v = nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DogHouseGlobalAlert"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 500000
	screenGui.Parent = playerGui
	v = screenGui
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.fromScale(0.5, 0.11)
	frame.Size = UDim2.fromScale(0.52, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = Color3.fromRGB(14, 10, 10)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(255, 205, 45)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.15
	uIStroke.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 12)
	uIPadding.PaddingBottom = UDim.new(0, 12)
	uIPadding.PaddingLeft = UDim.new(0, 18)
	uIPadding.PaddingRight = UDim.new(0, 18)
	uIPadding.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 6)
	uIListLayout.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 0)
	textLabel.AutomaticSize = Enum.AutomaticSize.Y
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Text = "⚠️ GLOBAL ANNOUNCEMENT FROM STAFF ⚠️"
	textLabel.TextColor3 = Color3.fromRGB(255, 210, 50)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextSize = 22
	textLabel.TextWrapped = true
	textLabel.LayoutOrder = 1
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.fromScale(1, 0)
	textLabel2.AutomaticSize = Enum.AutomaticSize.Y
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.Text = text
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel2.TextStrokeTransparency = 0.25
	textLabel2.TextSize = 26
	textLabel2.TextWrapped = true
	textLabel2.RichText = true
	textLabel2.LineHeight = 1.1
	textLabel2.LayoutOrder = 2
	textLabel2.Parent = frame
	frame.Position = UDim2.fromScale(0.5, 0.08)
	TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.11)
	}):Play()
	task.delay(duration, function()
		if count ~= v2 or not screenGui.Parent then
			return
		end

		TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(0.35), {
			Transparency = 1
		}):Play()
		TweenService:Create(textLabel, TweenInfo.new(0.35), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		local tween = TweenService:Create(textLabel2, TweenInfo.new(0.35), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		})
		tween:Play()
		tween.Completed:Once(function()
			if screenGui then
				screenGui:Destroy()
			end

			if v == screenGui then
				v = nil
			end
		end)
	end)
end