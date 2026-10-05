local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local ticker = BitohiUI.Ticker
local UIRewardFX = {}
local presets = {
	Rebirth = {
		Flash = Color3.fromRGB(255, 244, 250),
		FlashFrom = 0.45,
		Rings = { Color3.fromRGB(255, 110, 190), Color3.fromRGB(90, 220, 255) },
		Sparks = {
			Color3.fromRGB(255, 225, 90),
			Color3.fromRGB(255, 110, 190),
			Color3.fromRGB(90, 220, 255),
			Color3.fromRGB(255, 255, 255)
		},
		RingSize = 0.34,
		RingTo = 1.75,
		SparkDistance = { 0.16, 0.32 }
	}
}

local function easeOut(p)
	local v2 = 1 - p
	return 1 - v2 * v2 * v2
end

local screenGui = nil
local frame = nil
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = 0
local v12 = 0
local total = 0
local v13 = nil
local count = 0
local random = Random.new()

local function build()
	if screenGui then
		return
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RewardFX"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	frame = Instance.new("Frame")
	frame.Name = "Flash"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.Active = false
	frame.Parent = screenGui

	for i = 1, 2 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "Ring" .. i
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BackgroundTransparency = 1
		frame2.BorderSizePixel = 0
		frame2.Visible = false
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame2
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 7
		uIStroke.Transparency = 1
		uIStroke.Parent = frame2
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = frame2
		frame2.Parent = screenGui
		v2[i] = {
			frame = frame2,
			stroke = uIStroke,
			scale = uIScale
		}
	end

	for i = 1, 14 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "Spark"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BorderSizePixel = 0
		frame2.BackgroundTransparency = 1
		frame2.Visible = false
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = frame2
		frame2.Parent = screenGui
		local v14 = v4
		v3[i] = frame2
		v14[i] = uIScale
		local v15 = v6
		local v16 = v7
		local v17 = v8
		local v18 = v9
		local v19 = v10
		v5[i] = 0
		v15[i] = 0
		v16[i] = 0
		v17[i] = 0
		v18[i] = 45
		v19[i] = 0
	end

	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function rest()
	if v13 then
		v13:Stop()
		v13 = nil
	end

	frame.BackgroundTransparency = 1

	for i = 1, #v2 do
		v2[i].frame.Visible = false
	end

	v3[1].Visible = false
	v3[2].Visible = false
	v3[3].Visible = false
	v3[4].Visible = false
	v3[5].Visible = false
	v3[6].Visible = false
	v3[7].Visible = false
	v3[8].Visible = false
	v3[9].Visible = false
	v3[10].Visible = false
	v3[11].Visible = false
	v3[12].Visible = false
	v3[13].Visible = false
	v3[14].Visible = false
	screenGui.Enabled = false
end

local function centreOf(guiObject)
	if typeof(guiObject) == "Vector2" then
		return guiObject
	end

	if typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject") then
		return screenGui.AbsoluteSize * 0.5
	end

	local v14 = guiObject.AbsolutePosition + guiObject.AbsoluteSize * 0.5
	local screenGui2 = guiObject:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui2 and not screenGui2.IgnoreGuiInset then
		return v14 + GuiService:GetGuiInset()
	end

	return v14
end

local v14 = 1.75
local backgroundTransparency = 0.45

local function tick(p)
	total += p
	local v16 = total
	local v17 = math.min(v16 / 0.35, 1)
	local v18 = frame
	local v19 = backgroundTransparency
	local v20 = 1 - backgroundTransparency
	local v21 = 1 - v17
	v18.BackgroundTransparency = v19 + v20 * (1 - v21 * v21 * v21)

	for i = 1, v12 do
		local v22 = v2[i]
		local v23 = (v16 - (i - 1) * 0.09) / 0.75

		if not (v23 >= 0) then
			continue
		end

		if v23 >= 1 then
			v22.frame.Visible = false
		else
			local v24 = 1 - v23
			local transparency = 1 - v24 * v24 * v24
			v22.scale.Scale = 0.25 + (v14 - 0.25) * transparency
			v22.stroke.Transparency = transparency
		end
	end

	local v22 = math.min(v16 / 0.9, 1)
	local v23 = 1 - v22
	local v24 = 1 - v23 * v23 * v23
	local backgroundTransparency2 = v22 * v22

	for i = 1, v11 do
		local v26 = v3[i]
		v26.Position = UDim2.fromOffset(v5[i] + v7[i] * v24, v6[i] + v8[i] * v24)
		v26.Rotation = v9[i] + v10[i] * v24
		v26.BackgroundTransparency = backgroundTransparency2
		v4[i].Scale = 1 - 0.7 * v24
	end

	if v16 >= 1 then
		rest()
	end
end

function UIRewardFX.warm()
	build()
end

function UIRewardFX.burst(p, p2)
	build()
	local v16 = p2 or presets.Rebirth
	count += 1
	local low = UIQuality.low()
	v11 = low and 6 or 14
	v12 = low and 1 or #v2
	local ringTo = v16.RingTo
	local flashFrom = v16.FlashFrom
	v14 = ringTo
	backgroundTransparency = flashFrom
	screenGui.Enabled = true
	local absoluteSize = screenGui.AbsoluteSize
	local v17 = centreOf(p)
	local Y = absoluteSize.Y
	frame.BackgroundColor3 = v16.Flash
	frame.BackgroundTransparency = backgroundTransparency
	local v18 = math.floor(Y * v16.RingSize)

	for i, v19 in ipairs(v2) do
		local frame2 = v19.frame

		if i <= v12 then
			frame2.Size = UDim2.fromOffset(v18, v18)
			frame2.Position = UDim2.fromOffset(v17.X, v17.Y)
			v19.stroke.Color = v16.Rings[i] or v16.Rings[1]
			v19.stroke.Transparency = i == 1 and 0 or 1
			v19.scale.Scale = 0.25
			frame2.Visible = true
		else
			frame2.Visible = false
		end
	end

	local v19 = v16.SparkDistance[1] * Y
	local v20 = v16.SparkDistance[2] * Y
	local v21 = math.max(8, (math.floor(Y * 0.016)))

	for i = 1, 14 do
		local v22 = v3[i]

		if i <= v11 then
			local v23 = i / v11 * 3.141592653589793 * 2 + random:NextNumber(-0.22, 0.22)
			local number = random:NextNumber(v19, v20)
			local v24 = math.floor(v21 * random:NextNumber(0.7, 1.4))
			v22.Size = UDim2.fromOffset(v24, v24)
			local v25 = v5
			local v26 = v6
			local X = v17.X
			local Y2 = v17.Y
			v25[i] = X
			v26[i] = Y2
			local v27 = v7
			local v28 = v8
			local v29 = math.cos(v23) * number
			local v30 = math.sin(v23) * number
			v27[i] = v29
			v28[i] = v30
			local v31 = v9
			local v32 = v10
			local number2 = random:NextNumber(-200, 200)
			v31[i] = 45
			v32[i] = number2
			v22.Position = UDim2.fromOffset(v17.X, v17.Y)
			v22.Rotation = 45
			v22.BackgroundColor3 = v16.Sparks[random:NextInteger(1, #v16.Sparks)]
			v22.BackgroundTransparency = 0
			v4[i].Scale = 1
			v22.Visible = true
		else
			v22.Visible = false
		end
	end

	total = 0

	if not v13 then
		v13 = ticker.add(tick)
	end
end

function UIRewardFX.rebirth(p)
	UIRewardFX.burst(p, presets.Rebirth)
end

UIRewardFX.Presets = presets
return UIRewardFX