local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p, uIGradient)
	if uIGradient:IsA("UIGradient") and uIGradient:IsDescendantOf(playerGui) then
		p[uIGradient] = true
	end
end

local function untrack(p, p2)
	p[p2] = nil
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local total = 0

for _, v5 in ipairs(CollectionService:GetTagged("UIGradientRainbow")) do
	track(v, v5) -- equivalent call inferred; original call site unknown
end

for _, v5 in ipairs(CollectionService:GetTagged("UIGradientSecret")) do
	track(v2, v5) -- equivalent call inferred; original call site unknown
end

for _, v5 in ipairs(CollectionService:GetTagged("UIGradientExotic")) do
	track(v3, v5) -- equivalent call inferred; original call site unknown
end

for _, v5 in ipairs(CollectionService:GetTagged("UIGradientUnreal")) do
	track(v4, v5) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("UIGradientRainbow"):Connect(function(p)
	task.defer(track, v, p)
end)
CollectionService:GetInstanceRemovedSignal("UIGradientRainbow"):Connect(function(p)
	v[p] = nil
end)
CollectionService:GetInstanceAddedSignal("UIGradientSecret"):Connect(function(p)
	task.defer(track, v2, p)
end)
CollectionService:GetInstanceRemovedSignal("UIGradientSecret"):Connect(function(p)
	v2[p] = nil
end)
CollectionService:GetInstanceAddedSignal("UIGradientExotic"):Connect(function(p)
	task.defer(track, v3, p)
end)
CollectionService:GetInstanceRemovedSignal("UIGradientExotic"):Connect(function(p)
	v3[p] = nil
end)
CollectionService:GetInstanceAddedSignal("UIGradientUnreal"):Connect(function(p)
	task.defer(track, v4, p)
end)
CollectionService:GetInstanceRemovedSignal("UIGradientUnreal"):Connect(function(p)
	v4[p] = nil
end)
RunService.RenderStepped:Connect(function(dt)
	total += dt * 0.3
	local v5 = total % 1
	local v6 = (total + 0.15) % 1
	local v7 = (total + 0.3) % 1
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(v5, 0.8, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(v6, 0.8, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(v7, 0.8, 1))
	})
	local v8 = math.cos(total * 3.141592653589793 * 2) * 0.4 + 0.6
	local v9 = math.cos((total + 0.15) * 3.141592653589793 * 2) * 0.4 + 0.6
	local v10 = math.cos((total + 0.3) * 3.141592653589793 * 2) * 0.4 + 0.6
	local colorSequence2 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(v8 * 255, v8 * 255, v8 * 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(v9 * 255, v9 * 255, v9 * 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(v10 * 255, v10 * 255, v10 * 255))
	})
	local v11 = total * 3.141592653589793 * 2
	local v12 = math.cos(v11) * 0.25 + 0.35
	local v13 = math.cos(v11 + 0.9424777960769379) * 0.35 + 0.55
	local v14 = math.cos(v11 + 1.8849555921538759) * 0.3 + 0.4
	local colorSequence3 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, v12 * 180 + 40, 30)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, v13 * 200 + 55, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, v14 * 190 + 45, 35))
	})
	local colorSequence4 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(v12 * 180 + 40, 20, v12 * 180 + 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(v13 * 30 + 8, 6, v13 * 40 + 10)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, v14 * 40 + 20, v14 * 190 + 45))
	})

	for k in pairs(v) do
		if k.Parent then
			k.Color = colorSequence
		else
			v[k] = nil
		end
	end

	for k in pairs(v2) do
		if k.Parent then
			k.Color = colorSequence2
		else
			v2[k] = nil
		end
	end

	for k in pairs(v3) do
		if k.Parent then
			k.Color = colorSequence3
		else
			v3[k] = nil
		end
	end

	for k in pairs(v4) do
		if k.Parent then
			k.Color = colorSequence4
		else
			v4[k] = nil
		end
	end
end)