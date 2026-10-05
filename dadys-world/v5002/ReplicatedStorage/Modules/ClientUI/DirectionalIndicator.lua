local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.SharedUtils.Maid)
local playerGui = game.Players.LocalPlayer.PlayerGui
local activeIndicators = {}

local function resolvePosition(instance)
	if typeof(instance) == "Vector3" then
		return instance
	end

	if typeof(instance) ~= "Instance" then
		return createVector(0, 0, 0)
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	if not instance:IsA("Model") then
		return createVector(0, 0, 0)
	end

	local primaryPart = instance.PrimaryPart

	if primaryPart then
		return primaryPart.Position
	end

	return instance:GetPivot().Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRotationAngle(position)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 0
	end

	local worldToScreenPoint = currentCamera:WorldToScreenPoint(position)
	local halfViewportSize = currentCamera.ViewportSize / 2
	local v3 = worldToScreenPoint.X - halfViewportSize.X
	local v4 = worldToScreenPoint.Y - halfViewportSize.Y

	if worldToScreenPoint.Z < 0 then
		v3 = -v3
		v4 = -v4
	end

	return (math.deg((math.atan2(v3, -v4))))
end

local DirectionalIndicator = {}

function DirectionalIndicator.CreateIndicator(_, instance, options)
	local v2 = options or {}
	local fadeInTime = v2.fadeInTime or 0.15
	local fadeOutTime = v2.fadeOutTime or 0.15
	local directionalIndicators = playerGui:FindFirstChild("DirectionalIndicators")
	local radial = directionalIndicators and directionalIndicators:FindFirstChild("Radial")
	local indicator = radial and radial:FindFirstChild("indicator")

	if not indicator then
		warn("[DirectionalIndicator] DirectionalIndicators.Radial.indicator template missing — skipping")
		return {
			Remove = function() end
		}
	end

	local clone = indicator:Clone()
	clone.Parent = radial
	clone.Visible = true
	clone.ImageTransparency = 1
	clone.UIScale.Scale = 1
	clone.Size = UDim2.fromScale(1.5, 0.7)

	if v2.image then
		clone.Image = v2.image
	end

	if v2.color then
		clone.ImageColor3 = v2.color
	end

	local imageLabel

	if v2.badgeImage then
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = v2.badgeSize or UDim2.fromScale(0.1, 0.1)
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.fromScale(0.5, v2.badgeOffset or -0.075)
		frame.Parent = clone
		imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Image = v2.badgeImage
		imageLabel.ImageTransparency = 1
		imageLabel.Parent = frame
		imageLabel.ImageColor3 = v2.badeColor or v2.color or Color3.fromRGB(255, 255, 255)
	else
		imageLabel = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyRotation(rotationAngle)
		clone.Rotation = rotationAngle

		if imageLabel then
			imageLabel.Parent.Rotation = -rotationAngle
		end
	end

	local rotationAngle = getRotationAngle(resolvePosition(instance)) -- equivalent call inferred; original call site unknown
	applyRotation(rotationAngle) -- equivalent call inferred; original call site unknown
	TweenService:Create(clone.UIScale, TweenInfo.new(fadeInTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		Scale = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(fadeInTime + 0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut), {
		Size = v2.size and v2.size or UDim2.fromScale(0.6, 0.6)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(fadeInTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		ImageTransparency = 0.25
	}):Play()

	if imageLabel then
		TweenService:Create(imageLabel, TweenInfo.new(fadeInTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			ImageTransparency = 0.5
		}):Play()
	end

	local class = {}
	local flag = false
	local maid = Maid.new()

	if typeof(instance) == "Instance" then
		maid:GiveTask(RunService.Heartbeat:Connect(function()
			if clone.Parent then
				local rotationAngle2 = getRotationAngle(resolvePosition(instance)) -- equivalent call inferred; original call site unknown
				applyRotation(rotationAngle2) -- equivalent call inferred; original call site unknown
			else
				flag = true
				maid:Destroy()
				clone:Destroy()
			end
		end))
	end

	maid:GiveTask(function()
		activeIndicators[class] = nil
	end)

	function class:Remove()
		if flag then
			return
		end

		flag = true
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeOutTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
			{
				ImageTransparency = 1
			}
		)
		tween:Play()

		if imageLabel then
			TweenService:Create(
				imageLabel,
				TweenInfo.new(fadeOutTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 1
				}
			):Play()
		end

		tween.Completed:Connect(function()
			maid:Destroy()
			clone:Destroy()
		end)
	end

	activeIndicators[class] = class

	if v2.timeout then
		task.delay(v2.timeout, function()
			class:Remove()
		end)
	end

	return class
end

function DirectionalIndicator.RemoveAll(_)
	local v2 = {}

	for k in pairs(activeIndicators) do
		v2[#v2 + 1] = k
	end

	for _, v3 in ipairs(v2) do
		v3:Remove()
	end
end

function DirectionalIndicator:Start()
	self.activeIndicators = activeIndicators
end

return DirectionalIndicator