game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.75, Enum.EasingStyle.Linear)
local random = Random.new()
local v = {
	{
		Size = 1,
		Color = Color3.new(1, 1, 1)
	},
	{
		Size = 0.5,
		Color = Color3.new(0.866667, 0.513725, 0.905882)
	},
	{
		Size = 0.75,
		Color = Color3.new(0.607843, 0.490196, 0.905882)
	}
}
local v2 = { "rbxassetid://9126076151", "rbxassetid://9126072436" }

local function fastTween(p, p2, p3, flag: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()

	if not flag then
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end

	return tween
end

local function fastAudio(soundId, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = parent
	sound.Volume = random:NextNumber(0.025, 0.05)
	sound.PlaybackSpeed = random:NextNumber(0.8, 1.5) * 0.5
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

local imageLabel = Instance.new("ImageLabel")
imageLabel.Active = false
imageLabel.BackgroundTransparency = 1
imageLabel.BorderSizePixel = 0
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Image = "rbxassetid://15897574705"
imageLabel.ImageTransparency = 0
local v3 = {}

local function createStar(point: Vector2, parent, value: number?, flag: boolean?)
	local v4 = v[math.random(#v)]
	local v5 = (value or 1) * 2 * v4.Size * random:NextNumber(0.1, 1.1)
	local rotation = math.random(0, 360)
	local v7 = table.remove(v3)
	local label, angularTween, fadeTween, sizeTween

	if v7 then
		label = v7.Label
		angularTween = v7.AngularTween
		fadeTween = v7.FadeTween
		sizeTween = v7.SizeTween
		label.ImageTransparency = 0
	else
		label = imageLabel:Clone()
		label.Parent = parent
		label.ImageColor3 = v4.Color
		angularTween = TweenService:Create(label, tweenInfo, {
			Rotation = rotation + math.random(-90, 90)
		})
		fadeTween = TweenService:Create(label, tweenInfo2, {
			ImageTransparency = 1
		}, flag)
		sizeTween = TweenService:Create(
			label,
			TweenInfo.new(
				tweenInfo.Time / random:NextNumber(0.01, 2),
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out,
				-1
			),
			{
				Size = UDim2.fromOffset(v5, 0)
			},
			flag
		)
	end

	label.Size = UDim2.fromOffset(v5, v5)
	label.Position = UDim2.fromOffset(point.X, point.Y)
	label.Rotation = rotation
	angularTween:Play()
	fadeTween:Play()
	sizeTween:Play()

	if not flag then
		fastAudio(v2[math.random(#v2)], parent)
	end

	if flag then
		task.spawn(function()
			local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")

			while screenGui and task.wait(2) and label.Parent do
				label.Size = UDim2.fromOffset(v5, v5)
				label.Position = UDim2.fromOffset(
					math.random(screenGui.AbsoluteSize.X),
					math.random(screenGui.AbsoluteSize.Y)
				)
				label.Rotation = 0
				label.ImageTransparency = 0
				angularTween:Play()
				fadeTween:Play()
				sizeTween:Play()
			end
		end)
	else
		task.delay(1, function()
			if not label.Parent then
				return
			end

			table.insert(v3, {
				Label = label,
				AngularTween = angularTween,
				FadeTween = fadeTween,
				SizeTween = sizeTween
			})
		end)
	end

	return label
end

return createStar