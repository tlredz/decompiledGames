local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local winStreakUpdate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("WinStreakUpdate", 15)

if not winStreakUpdate then
	return
end

local function getTaggedElement(tag)
	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

local v = {
	[10] = Color3.fromRGB(255, 255, 255),
	[20] = Color3.fromRGB(170, 255, 170),
	[30] = Color3.fromRGB(85, 255, 85),
	[40] = Color3.fromRGB(0, 255, 0),
	[50] = Color3.fromRGB(200, 255, 0),
	[60] = Color3.fromRGB(255, 255, 0),
	[70] = Color3.fromRGB(255, 200, 0),
	[80] = Color3.fromRGB(255, 140, 0),
	[90] = Color3.fromRGB(255, 80, 0),
	[100] = Color3.fromRGB(255, 30, 30)
}

local function getStreakColor(p)
	for _, v2 in ipairs({
		10,
		20,
		30,
		40,
		50,
		60,
		70,
		80,
		90,
		100
	}) do
		if p <= v2 then
			return v[v2]
		end
	end

	return v[100]
end

local v2 = nil

local function animateBounce(taggedElement)
	if not taggedElement then
		return
	end

	local v3 = taggedElement:FindFirstChildWhichIsA("UIScale")

	if not v3 then
		v3 = Instance.new("UIScale")
		v3.Parent = taggedElement
	end

	if v2 then
		v2:Cancel()
	end

	v3.Scale = 1
	local tween = TweenService:Create(v3, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1.25
	})
	local tween2 = TweenService:Create(v3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		tween2:Play()
		v2 = tween2
	end)
	v2 = tween
end

local function animateTextPunch(taggedElement)
	if not taggedElement then
		return
	end

	local v3 = taggedElement:FindFirstChildWhichIsA("UIScale")

	if not v3 then
		v3 = Instance.new("UIScale")
		v3.Parent = taggedElement
	end

	v3.Scale = 1.4
	TweenService:Create(v3, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function showFrame(taggedElement)
	if not taggedElement or taggedElement.Visible then
		return
	end

	taggedElement.Visible = true
	local v3 = taggedElement:FindFirstChildWhichIsA("UIScale")

	if not v3 then
		v3 = Instance.new("UIScale")
		v3.Parent = taggedElement
	end

	v3.Scale = 0.5
	TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function hideFrame(taggedElement)
	if not (taggedElement and taggedElement.Visible) then
		return
	end

	local uIScale = taggedElement:FindFirstChildWhichIsA("UIScale")

	if not uIScale then
		taggedElement.Visible = false
		return
	end

	local tween = TweenService:Create(uIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.5
	})
	tween:Play()
	tween.Completed:Once(function()
		taggedElement.Visible = false
	end)
end

winStreakUpdate.OnClientEvent:Connect(function(p)
	local taggedElement = getTaggedElement("WinStrikeFrame")
	local taggedElement2 = getTaggedElement("WinStrikeMultiplier")

	if not p or p <= 0 then
		hideFrame(taggedElement)
		return
	end

	if taggedElement and not taggedElement.Visible then
		showFrame(taggedElement)
	end

	if taggedElement2 then
		taggedElement2.Text = "+" .. tostring(p) .. "% Wins"
		taggedElement2.TextColor3 = getStreakColor(p)
		animateTextPunch(taggedElement2)
	end

	animateBounce(taggedElement)
end)