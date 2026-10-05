local parent = script.Parent
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local one = parent.One
local two = parent.Two
local three = parent.Three
local videoFrame = parent.Parent.VideoFrame
local middle = parent.Middle
local value = parent.Parent.Origin.Value
local circle = parent.Parent.Circle

for _, v in pairs({ one, two, three }) do
	v.Position = UDim2.new(v.Position.X.Scale, v.Position.X.Offset, 1.1, 0)
end

local v = value.AbsolutePosition + value.AbsoluteSize / 2
local absolutePosition = circle.Parent.AbsolutePosition
local absoluteSize = circle.AbsoluteSize
local v2 = v.X - absolutePosition.X - absoluteSize.X / 2
local v3 = v.Y - absolutePosition.Y - absoluteSize.Y / 2
circle.Position = UDim2.fromOffset(v2, v3)
TweenService:Create(circle, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
	Size = UDim2.new(4, 0, 4, 0)
}):Play()
circle.Changed:Connect(function()
	local circle2 = circle
	local v5 = value
	local v6 = v5.AbsolutePosition + v5.AbsoluteSize / 2
	local absolutePosition2 = circle2.Parent.AbsolutePosition
	local absoluteSize2 = circle2.AbsoluteSize
	local v7 = v6.X - absolutePosition2.X - absoluteSize2.X / 2
	local v8 = v6.Y - absolutePosition2.Y - absoluteSize2.Y / 2
	circle2.Position = UDim2.fromOffset(v7, v8)
end)
parent.Parent.VideoFrame.Video = "rbxassetid://" .. parent.Parent:GetAttribute("ID")
TweenService:Create(parent.Background, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
	Position = UDim2.new(1.5, 0, 1.5, 0)
}):Play()
shared.sfx({
	SoundId = "rbxassetid://115029957019425",
	Parent = workspace,
	Volume = 0.4
}):Play()
local flag = false
task.delay(0.35, function()
	for _, v5 in pairs({ one, two, three }) do
		TweenService:Create(v5, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}):Play()
	end

	shared.sfx({
		SoundId = "rbxassetid://140293237528426",
		Parent = workspace,
		Volume = 0.75
	}):Play()

	for k, v6 in pairs({ one, two, three }) do
		TweenService:Create(v6, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(v6.Position.X.Scale, v6.Position.X.Offset, 0.5, 0)
		}):Play()
		local v7 = k
		task.delay(0.65, function()
			if flag then
				return
			end

			shared.sfx({
				SoundId = ({
					"rbxassetid://97631984908199",
					"rbxassetid://108687700865434",
					"rbxassetid://76172048519874"
				})[v7],
				Parent = workspace,
				Volume = 0.35
			}):Play()
		end)
		task.wait(0.125)
	end
end)
task.wait(0.5)
videoFrame.Visible = true
parent.Background.Visible = true
TweenService:Create(circle, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	BackgroundTransparency = 1
}):Play()
tick()

while true do
	task.wait(0.75)

	for k, v4 in pairs({ one, two, three }) do
		TweenService:Create(v4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
			Position = UDim2.new(v4.Position.X.Scale, v4.Position.X.Offset, 0.5, -10)
		}):Play()
		local v5 = k
		task.delay(0.25, function()
			if flag then
				return
			end

			shared.sfx({
				SoundId = ({
					"rbxassetid://97631984908199",
					"rbxassetid://108687700865434",
					"rbxassetid://76172048519874"
				})[v5],
				Parent = workspace,
				Volume = 0.35
			}):Play()
		end)
		task.wait(0.125)
	end

	if not videoFrame.IsLoaded then
		continue
	end

	flag = true
	local uIStroke = middle.UIStroke
	middle.Size = UDim2.new(0, 0, 0, 0)
	middle.UIStroke.Thickness = 0
	middle.BackgroundTransparency = 1
	middle.Visible = true
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		local value2 = numberValue.Value
		local uIStroke2 = uIStroke
		local viewportSize = currentCamera.ViewportSize
		local v7 = math.min(viewportSize.X, viewportSize.Y)
		local vector = Vector2.new(1920, 1080)
		uIStroke2.Thickness = value2 * (v7 / math.min(vector.X, vector.Y))
	end)
	middle.Position = two.Position
	TweenService:Create(numberValue, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Value = 4000
	}):Play()
	task.delay(0.075, function()
		shared.sfx({
			SoundId = "rbxassetid://99670670808304",
			Parent = workspace,
			Volume = 0.4
		}):Play()
	end)
	task.delay(0.6, function()
		videoFrame:Play()
		videoFrame.Ended:Once(function()
			shared.sfx({
				SoundId = "rbxassetid://122955908806308",
				Parent = workspace,
				Volume = 0.7
			}):Play()
			TweenService:Create(
				script.Parent.Parent,
				TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Position = UDim2.new(0.5, 0, 2.5, 0)
				}
			):Play()
			TweenService:Create(videoFrame.Frame, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 0
			}):Play()
			task.delay(0.75, function()
				script.Parent.Parent:Destroy()
			end)
		end)
		videoFrame.Pos.Visible = true

		while task.wait() and videoFrame.Parent and parent.Parent and parent.Parent.Parent do
			videoFrame.Pos.Size = UDim2.new(videoFrame.TimePosition / videoFrame.TimeLength, 0, 0.007, 0)
		end
	end)
	task.delay(0.5, function()
		parent.Background.Visible = false

		for _, v7 in pairs({ one, two, three }) do
			v7.Visible = false
		end

		TweenService:Create(middle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1.25, 0, 2.222, 0)
		}):Play()
	end)
	break
end