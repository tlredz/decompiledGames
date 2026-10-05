local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local color = Color3.fromRGB(255, 60, 60)
local uDim = UDim2.fromScale(9, 9)
local uDim2 = UDim2.fromScale(10.5, 10.5)
local uDim3 = UDim2.fromScale(15, 8)
local uDim4 = UDim2.fromScale(17, 9)

local function lighten(color2: Color3, p: number)
	return color2:Lerp(Color3.new(1, 1, 1), p)
end

local function darken(color2: Color3, p: number)
	return color2:Lerp(Color3.new(0, 0, 0), p)
end

local function resolveRoot(character)
	if typeof(character) ~= "Instance" then
		return nil
	end

	if character:IsA("BasePart") then
		return character
	end

	if character:IsA("Model") then
		return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

return function(player)
	if not player then
		return
	end

	local character = player.Character
	local root = player.Root or resolveRoot(character)

	if not (root and root:IsA("BasePart")) then
		return
	end

	local warnTime = player.WarnTime or 0
	local duration = player.Duration or 1.2
	local holdTime = player.HoldTime or 0
	local radius = player.Radius or 25
	local color2 = player.Color or color
	local head

	if typeof(character) == "Instance" and character:IsA("Model") then
		head = character:FindFirstChild("Head")
	end

	local v

	if head and head:IsA("BasePart") and head then
		v = head
	else
		v = root
	end

	local v2 = warnTime > 0
	local size

	if v2 then
		size = uDim
	else
		size = uDim3
	end

	local v4

	if v2 then
		v4 = uDim2
	else
		v4 = uDim4
	end

	local v5 = v2 and 0.18 or 0.1
	local text = v2 and "!" or "!!!"
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "BossAlert"
	billboardGui.Adornee = v
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Size = UDim2.fromScale(0, 0)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, v == head and 9 or 12, 0)
	billboardGui.MaxDistance = 1200
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Shadow"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Position = UDim2.fromScale(0.03, 0.05)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(0, 0, 0)
	textLabel.TextTransparency = 1
	textLabel.TextStrokeTransparency = 1
	textLabel.ZIndex = 1
	textLabel.Parent = billboardGui
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Text"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.Font = Enum.Font.FredokaOne
	textLabel2.Text = text
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextStrokeTransparency = 1
	textLabel2.TextTransparency = 1
	textLabel2.ZIndex = 2
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), 0.35), darken(color2, 0.4))
	uIGradient.Parent = textLabel2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 4
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.LineJoinMode = Enum.LineJoinMode.Round
	uIStroke.Parent = textLabel2
	textLabel2.Parent = billboardGui
	billboardGui.Parent = v
	TweenService:Create(billboardGui, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
	TweenService:Create(textLabel2, TweenInfo.new(0.14), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(textLabel, TweenInfo.new(0.14), {
		TextTransparency = 0.35
	}):Play()
	local thread = task.spawn(function()
		task.wait(0.18)
		local v7 = false

		while billboardGui.Parent do
			v7 = not v7
			local tweenInfo = TweenInfo.new(v5 * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(textLabel2, tweenInfo, {
				TextTransparency = v7 and 0 or 1
			}):Play()
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = v7 and 0.35 or 1
			}):Play()
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = v7 and 0 or 1
			}):Play()
			local size2

			if v7 then
				size2 = v4
			else
				size2 = size
			end

			TweenService:Create(billboardGui, tweenInfo, {
				Size = size2
			}):Play()
			task.wait(v5)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fireIndicator()
		if player.Indicator == false then
			return
		end

		task.spawn(function()
			Effect.new("Shared.BossIndicator"):play({
				Type = "Circle",
				OriginCF = root.CFrame,
				OriginPart = root,
				Radius = radius,
				Color = color2,
				ChargeTime = duration,
				HoldTime = holdTime,
				FadeTime = 0.2
			})
		end)
	end

	if v2 then
		task.delay(warnTime, function()
			if not billboardGui.Parent then
				return
			end

			textLabel2.Text = "!!!"
			textLabel.Text = "!!!"
			size = uDim3
			v4 = uDim4
			v5 = 0.1
			fireIndicator() -- equivalent call inferred; original call site unknown
		end)
	elseif player.Indicator ~= false then
		task.spawn(function()
			Effect.new("Shared.BossIndicator"):play({
				Type = "Circle",
				OriginCF = root.CFrame,
				OriginPart = root,
				Radius = radius,
				Color = color2,
				ChargeTime = duration,
				HoldTime = holdTime,
				FadeTime = 0.2
			})
		end)
	end

	task.delay(warnTime + duration, function()
		if thread then
			task.cancel(thread)
		end

		if billboardGui.Parent then
			textLabel2.TextTransparency = 0
			textLabel.TextTransparency = 0.35
			uIStroke.Transparency = 0
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(textLabel2, tweenInfo, {
				TextTransparency = 1
			})
			tween:Play()
			tween.Completed:Wait()
		end

		billboardGui:Destroy()
	end)
end