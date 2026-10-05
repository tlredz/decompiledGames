local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {
	{ 1e63, "Vg" },
	{ 1e60, "Nd" },
	{ 1e57, "Od" },
	{ 1e54, "Spd" },
	{ 1e51, "Sxd" },
	{ 1e48, "Qid" },
	{ 1e45, "Qad" },
	{ 1e42, "Td" },
	{ 1e39, "Dd" },
	{ 1e36, "Ud" },
	{ 1e33, "Dc" },
	{ 1e30, "No" },
	{ 1e27, "Oc" },
	{ 1e24, "Sp" },
	{ 1e21, "Sx" },
	{ 1e18, "Qi" },
	{ 1000000000000000, "Qa" },
	{ 1000000000000, "T" },
	{ 1000000000, "B" },
	{ 1000000, "M" },
	{ 1000, "K" }
}

local function formatNumber(p)
	local v2 = tonumber(p) or 0

	for _, v3 in ipairs(v) do
		local v4 = v3[1]
		local v5 = v3[2]

		if v4 <= v2 then
			return string.format("%.2f", v2 / v4):gsub("%.?0+$", "") .. v5
		end
	end

	return (tostring((math.floor(v2))))
end

local function showRefundPopup(value)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RefundPopupOverlay"
	screenGui.DisplayOrder = 200
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Overlay"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 1
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "PopupFrame"
	frame2.Size = UDim2.new(0, 420, 0, 320)
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 2
	frame2.Parent = screenGui
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0, 16)
	local uIStroke = Instance.new("UIStroke", frame2)
	uIStroke.Color = Color3.fromRGB(255, 200, 60)
	uIStroke.Thickness = 2.5
	uIStroke.Transparency = 0.2
	local uIScale = Instance.new("UIScale", frame2)
	uIScale.Scale = 0
	local uIGradient = Instance.new("UIGradient", frame2)
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
	})
	uIGradient.Rotation = 135
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "TrophyIcon"
	imageLabel.Size = UDim2.new(0, 64, 0, 64)
	imageLabel.Position = UDim2.new(0.5, 0, 0, 24)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = Config.GetWinsIcon() or "rbxassetid://15540211845"
	imageLabel.ZIndex = 3
	imageLabel.Parent = frame2
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", imageLabel)
	uIAspectRatioConstraint.AspectRatio = 1
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.Size = UDim2.new(0.85, 0, 0, 36)
	textLabel.Position = UDim2.new(0.5, 0, 0, 98)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "🎁 REFUND"
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.ZIndex = 3
	textLabel.Parent = frame2
	local uIStroke2 = Instance.new("UIStroke", textLabel)
	uIStroke2.Color = Color3.fromRGB(120, 80, 0)
	uIStroke2.Thickness = 2
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
	uITextSizeConstraint.MaxTextSize = 32
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Message"
	textLabel2.Size = UDim2.new(0.85, 0, 0, 30)
	textLabel2.Position = UDim2.new(0.5, 0, 0, 142)
	textLabel2.AnchorPoint = Vector2.new(0.5, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "You have been refunded for the purchase of the items!"
	textLabel2.TextColor3 = Color3.fromRGB(200, 200, 220)
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.ZIndex = 3
	textLabel2.Parent = frame2
	local uITextSizeConstraint_2 = Instance.new("UITextSizeConstraint", textLabel2)
	uITextSizeConstraint_2.MaxTextSize = 20
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Amount"
	textLabel3.Size = UDim2.new(0.85, 0, 0, 50)
	textLabel3.Position = UDim2.new(0.5, 0, 0, 178)
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Text = "+" .. formatNumber(value) .. " 🏆"
	textLabel3.TextColor3 = Color3.fromRGB(80, 255, 120)
	textLabel3.TextScaled = true
	textLabel3.Font = Enum.Font.GothamBlack
	textLabel3.ZIndex = 3
	textLabel3.Parent = frame2
	local uIStroke3 = Instance.new("UIStroke", textLabel3)
	uIStroke3.Color = Color3.fromRGB(0, 60, 20)
	uIStroke3.Thickness = 2.5
	local uITextSizeConstraint_3 = Instance.new("UITextSizeConstraint", textLabel3)
	uITextSizeConstraint_3.MaxTextSize = 42
	local textButton = Instance.new("TextButton")
	textButton.Name = "OKButton"
	textButton.Size = UDim2.new(0.5, 0, 0, 46)
	textButton.Position = UDim2.new(0.5, 0, 1, -36)
	textButton.AnchorPoint = Vector2.new(0.5, 1)
	textButton.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	textButton.Text = "OK"
	textButton.TextColor3 = Color3.fromRGB(20, 15, 5)
	textButton.TextScaled = true
	textButton.Font = Enum.Font.GothamBlack
	textButton.ZIndex = 3
	textButton.AutoButtonColor = true
	textButton.Parent = frame2
	local uICorner_2 = Instance.new("UICorner", textButton)
	uICorner_2.CornerRadius = UDim.new(0, 10)
	local uIStroke4 = Instance.new("UIStroke", textButton)
	uIStroke4.Color = Color3.fromRGB(200, 150, 0)
	uIStroke4.Thickness = 1.5
	local uITextSizeConstraint_4 = Instance.new("UITextSizeConstraint", textButton)
	uITextSizeConstraint_4.MaxTextSize = 28
	local uIPadding = Instance.new("UIPadding", textButton)
	uIPadding.PaddingBottom = UDim.new(0, 4)
	uIPadding.PaddingTop = UDim.new(0, 4)
	TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.55
	}):Play()
	TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	imageLabel.Rotation = -15
	TweenService:Create(imageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0
	}):Play()
	task.spawn(function()
		while frame2 and frame2.Parent do
			TweenService:Create(uIStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Color = Color3.fromRGB(255, 240, 130),
				Transparency = 0
			}):Play()
			task.wait(1)

			if frame2 and frame2.Parent then
				TweenService:Create(uIStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Color = Color3.fromRGB(255, 180, 40),
					Transparency = 0.3
				}):Play()
				task.wait(1)
			else
				break
			end
		end
	end)
	textButton.MouseEnter:Connect(function()
		TweenService:Create(textButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 225, 100),
			Size = UDim2.new(0.53, 0, 0, 50)
		}):Play()
	end)
	textButton.MouseLeave:Connect(function()
		TweenService:Create(textButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 200, 60),
			Size = UDim2.new(0.5, 0, 0, 46)
		}):Play()
	end)
	textButton.MouseButton1Click:Connect(function()
		textButton.Active = false
		TweenService:Create(uIScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.4, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RefundNotification").OnClientEvent:Connect(function(value)
	if type(value) ~= "number" or value <= 0 then
		return
	end

	showRefundPopup(value)
end)