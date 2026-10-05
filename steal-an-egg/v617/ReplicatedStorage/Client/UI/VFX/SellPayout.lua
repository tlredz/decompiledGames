local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Hud = require(ReplicatedStorage.Client.Hud)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local OverlayRoot = require(script.Parent.OverlayRoot)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local quart = Enum.EasingStyle.Quart
local v = Enum.EasingDirection.In
local tweenInfo2 = TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.04)
local tweenInfo5 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local color = Color3.fromRGB(126, 255, 92)
local tweenInfo7 = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function money(p: number)
	if p > 99999 then
		return "$" .. Simple.FormatCompact(math.round(p), ".#")
	end

	return "$" .. Numbers.AddCommas((math.round(p)))
end

local function namedScale(parent, name: string)
	local uIScale = parent:FindFirstChild(name)

	if uIScale and uIScale:IsA("UIScale") then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Name = name
	uIScale2.Parent = parent
	return uIScale2
end

local function quadBezier(point: Vector2, point2: Vector2, point3: Vector2, p: number)
	local v3 = 1 - p
	return point * (v3 * v3) + point2 * (v3 * 2 * p) + point3 * (p * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, tweenInfo8, p2)
	local tween = TweenService:Create(p, tweenInfo8, p2)
	tween:Play()
	return tween
end

local function readout()
	local plate = Hud.Find("Money")
	local icon = Hud.Find("MoneyIcon")
	local v5 = Hud.Find("MoneyValue")

	if plate == nil or icon == nil or v5 == nil then
		return nil
	end

	return {
		Plate = plate,
		Icon = icon,
		Value = v5
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function iconCenter(icon)
	return icon.AbsolutePosition + icon.AbsoluteSize / 2
end

local function punch(data, p: number)
	local plate = data.Plate
	local icon = data.Icon
	local parent = data.Value
	local v3 = p % 2 == 0 and 1 or -1
	local v4 = icon:FindFirstChild("PayoutPunch")

	if not (v4 and v4:IsA("UIScale")) then
		v4 = Instance.new("UIScale")
		v4.Name = "PayoutPunch"
		v4.Parent = icon
	end

	v4.Scale = 1.32
	TweenService:Create(v4, tweenInfo2, {
		Scale = 1
	}):Play()
	local payoutRotation = icon:GetAttribute("PayoutRotation")

	if typeof(payoutRotation) ~= "number" then
		payoutRotation = icon.Rotation
		icon:SetAttribute("PayoutRotation", payoutRotation)
	end

	icon.Rotation = payoutRotation + v3 * 14
	TweenService:Create(icon, tweenInfo3, {
		Rotation = payoutRotation
	}):Play()
	local v5 = parent:FindFirstChild("PayoutPunch")

	if not (v5 and v5:IsA("UIScale")) then
		v5 = Instance.new("UIScale")
		v5.Name = "PayoutPunch"
		v5.Parent = parent
	end

	v5.Scale = 1.16
	TweenService:Create(v5, tweenInfo4, {
		Scale = 1
	}):Play()
	local payoutColor = parent:GetAttribute("PayoutColor")

	if typeof(payoutColor) ~= "Color3" then
		payoutColor = parent.TextColor3
		parent:SetAttribute("PayoutColor", payoutColor)
	end

	parent.TextColor3 = color
	TweenService:Create(parent, tweenInfo5, {
		TextColor3 = payoutColor
	}):Play()
	local v6 = plate:FindFirstChild("PayoutShake")

	if not (v6 and v6:IsA("UIScale")) then
		v6 = Instance.new("UIScale")
		v6.Name = "PayoutShake"
		v6.Parent = plate
	end

	v6.Scale = 1.05
	TweenService:Create(v6, tweenInfo6, {
		Scale = 1
	}):Play()
end

local function floatTotal(p, p2: number)
	local plate = p.Plate
	local value = p.Value
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "PayoutFloater"
	textLabel.BackgroundTransparency = 1
	local v4 = money(p2) -- equivalent call inferred; original call site unknown
	textLabel.Text = "+" .. v4
	textLabel.TextColor3 = color
	textLabel.FontFace = value.FontFace
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Size = UDim2.fromOffset(plate.AbsoluteSize.X, plate.AbsoluteSize.Y * 0.8)
	textLabel.Position = UDim2.fromOffset(plate.AbsolutePosition.X, plate.AbsolutePosition.Y)
	textLabel.Parent = OverlayRoot()
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Parent = textLabel
	TweenService:Create(textLabel, tweenInfo7, {
		Position = UDim2.fromOffset(plate.AbsolutePosition.X, plate.AbsolutePosition.Y - plate.AbsoluteSize.Y * 1.6),
		TextTransparency = 1
	}):Play()
	;(playTween(uIStroke, tweenInfo7, {
		Transparency = 1
	})).Completed:Once(function()
		textLabel:Destroy()
	end)
end

local function flyCoin(p, point: Vector2, p2: number, duration: number, i: number, onArrive)
	local icon = p.Icon
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Coin"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://119640363267627"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(p2, p2)
	imageLabel.Position = UDim2.fromOffset(point.X, point.Y)
	imageLabel.ImageTransparency = 1
	imageLabel.Parent = OverlayRoot()
	local v3 = point + Vector2.new(random:NextNumber(-46, 46), random:NextNumber(-46, 27.599999999999998))
	local v4 = iconCenter(icon) -- equivalent call inferred; original call site unknown
	local v5 = (v3 + v4) / 2 + Vector2.new(random:NextNumber(-130, 130), -random:NextNumber(65, 130))
	local v6 = random:NextNumber(140, 320) * (random:NextInteger(0, 1) == 0 and -1 or 1)
	local numberValue = Instance.new("NumberValue")
	numberValue.Changed:Connect(function(p3: number)
		if imageLabel.Parent == nil then
			return
		end

		local v10 = 1 - p3
		local v11 = v3 * (v10 * v10) + v5 * (v10 * 2 * p3) + v4 * (p3 * p3)
		imageLabel.Position = UDim2.fromOffset(v11.X, v11.Y)
		imageLabel.Rotation = v6 * p3
		local v12 = p2 * (1 - p3 * 0.45)
		imageLabel.Size = UDim2.fromOffset(v12, v12)
	end)
	task.delay(duration, function()
		if imageLabel.Parent == nil then
			numberValue:Destroy()
			return
		end

		TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		;(playTween(numberValue, TweenInfo.new(0.55 + random:NextNumber(-0.12, 0.12), quart, v), {
			Value = 1
		})).Completed:Once(function()
			imageLabel:Destroy()
			numberValue:Destroy()
			onArrive(i)
		end)
	end)
end

return table.freeze({
	Award = function(p: number, options)
		if p <= 0 then
			return
		end

		local v3 = readout()

		if v3 == nil then
			return
		end

		local v4 = options or {}
		local v5 = math.clamp(#v4, 5, 14)
		local v6 = math.clamp(v3.Icon.AbsoluteSize.Y * 0.9, 26, 72)
		local count = 0

		local function onArrive(p2: number)
			count += 1
			punch(v3, p2)
			Audio.Play("rbxassetid://8807960350", script, {
				PlaybackSpeed = p2 / v5 * 0.5 + 0.95,
				Volume = 0.165
			})

			if count == v5 then
				Audio.Play("rbxassetid://134810204798705", script, {
					Volume = 0.49500000000000005
				})
				floatTotal(v3, p)
			end
		end

		for i = 1, v5 do
			local v7

			if #v4 > 0 then
				v7 = v4[(i - 1) % #v4 + 1]
			else
				v7 = iconCenter(v3.Icon)
			end

			flyCoin(v3, v7, v6, (i - 1) * 0.045, i, onArrive)
		end
	end
})