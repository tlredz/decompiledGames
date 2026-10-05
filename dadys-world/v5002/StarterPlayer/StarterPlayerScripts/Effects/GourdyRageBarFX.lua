local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {}

local function rampFrom(p, p2)
	return (math.clamp((p2 / 100 - p) / (1 - p), 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function jitter()
	return math.random() * 2 - 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPulse(state)
	if state.pulseTween then
		state.pulseTween:Cancel()
		state.pulseTween = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseBar(state)
	stopPulse(state) -- equivalent call inferred; original call site unknown

	if state.pulse then
		state.pulse:Destroy()
	end

	local mainFrame = state.mainFrame

	if mainFrame and mainFrame.Parent then
		mainFrame.Position = state.basePosition
		mainFrame.Rotation = state.baseRotation
	end

	state.mainFrame = nil
	state.fill = nil
	state.pulse = nil
	state.nextBlink = nil
end

local function buildPulse(fill)
	local clone = fill:Clone()
	clone.Name = "FillPulse"

	for _, child in clone:GetChildren() do
		if not (child:IsA("UIGradient") or child:IsA("UIScale") or child:IsA("GuiObject")) then
			continue
		end

		child:Destroy()
	end

	local anchorPoint = clone.AnchorPoint
	local size = clone.Size
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position += UDim2.new(
		size.X.Scale * (0.5 - anchorPoint.X),
		size.X.Offset * (0.5 - anchorPoint.X),
		size.Y.Scale * (0.5 - anchorPoint.Y),
		size.Y.Offset * (0.5 - anchorPoint.Y)
	)
	clone.BackgroundTransparency = 1
	clone.ImageTransparency = 1
	clone.ZIndex = fill.ZIndex - 1
	clone.Parent = fill.Parent
	return clone
end

local function playBurst(state)
	local billboardGui = state.mainFrame and state.mainFrame:FindFirstAncestorOfClass("BillboardGui")
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local gourdyRageBar = assets and assets:FindFirstChild("GourdyRageBar")

	if not (billboardGui and gourdyRageBar and gourdyRageBar:IsA("BillboardGui")) then
		return
	end

	local clone = gourdyRageBar:Clone()
	local fill = clone:FindFirstChild("Fill", true)

	if not (fill and fill:IsA("ImageLabel")) then
		clone:Destroy()
		return
	end

	for _, guiObject in clone:GetDescendants() do
		if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
			guiObject.ImageTransparency = 1
		end

		if guiObject:IsA("GuiObject") then
			guiObject.BackgroundTransparency = 1
		end
	end

	local pulse = buildPulse(fill)
	pulse.ImageColor3 = state.fill and state.fill.ImageColor3 or fill.ImageColor3
	pulse.ImageTransparency = 0.5
	local uIScale = Instance.new("UIScale")
	uIScale.Parent = pulse
	clone.Name = "GourdyRageBarBurst"
	clone.StudsOffsetWorldSpace = billboardGui.StudsOffsetWorldSpace
	clone.Adornee = billboardGui.Adornee
	clone.Parent = billboardGui.Parent
	local tween = TweenService:Create(pulse, tweenInfo, {
		ImageTransparency = 1
	})
	TweenService:Create(uIScale, tweenInfo, {
		Scale = 1.8
	}):Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

local function findBar(instance, p)
	local now = os.clock()

	if now < p.nextLookup then
		return
	end

	p.nextLookup = now + 0.5
	local gourdyRageBar = instance:FindFirstChild("GourdyRageBar", true)
	local mainFrame = gourdyRageBar and gourdyRageBar:FindFirstChild("MainFrame")

	if not (mainFrame and mainFrame:IsA("GuiObject")) then
		return
	end

	p.mainFrame = mainFrame
	p.basePosition = mainFrame.Position
	p.baseRotation = mainFrame.Rotation
	p.burstPlayed = false
	local fill = gourdyRageBar:FindFirstChild("Fill", true)

	if fill and fill:IsA("ImageLabel") then
		p.fill = fill
		p.pulse = buildPulse(fill)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p)
	if v[p] then
		return
	end

	v[p] = {
		nextLookup = 0
	}
end

local function untrack(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	releaseBar(v2) -- equivalent call inferred; original call site unknown
	v[p] = nil
end

local function updateShake(data, gourdyRagePercent)
	local v2 = math.clamp((gourdyRagePercent / 100 - 0.9) / 0.09999999999999998, 0, 1)
	local v3 = v2 * v2

	if v3 <= 0 then
		data.mainFrame.Position = data.basePosition
		data.mainFrame.Rotation = data.baseRotation
	else
		local v4 = 0.04 * v3
		data.mainFrame.Position = data.basePosition + UDim2.fromScale(jitter() * v4, jitter() * v4)
		data.mainFrame.Rotation = data.baseRotation + jitter() * 6 * v3
	end
end

local function blink(state, p)
	stopPulse(state) -- equivalent call inferred; original call site unknown
	local pulse = state.pulse
	pulse.ImageColor3 = state.fill.ImageColor3
	pulse.ImageTransparency = 0.5
	state.pulseTween = TweenService:Create(
		pulse,
		TweenInfo.new(math.min(0.45, p), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			ImageTransparency = 1
		}
	)
	state.pulseTween:Play()
end

local function updatePulse(state, gourdyRagePercent)
	if not (state.pulse and state.pulse.Parent) then
		return
	end

	if gourdyRagePercent >= 100 then
		if not state.burstPlayed then
			state.burstPlayed = true
			stopPulse(state) -- equivalent call inferred; original call site unknown
			state.pulse.ImageTransparency = 1
			playBurst(state)
		end
	else
		if gourdyRagePercent / 100 < 0.5 then
			state.nextBlink = nil
			return
		end

		local v2 = 2 + -1.75 * math.clamp((gourdyRagePercent / 100 - 0.5) / 0.5, 0, 1)
		local now = os.clock()

		if state.nextBlink and now < state.nextBlink then
			return
		end

		blink(state, v2)
		state.nextBlink = now + v2
	end
end

RunService.RenderStepped:Connect(function()
	for k, v2 in v do
		if k.Parent then
			if not (v2.mainFrame and v2.mainFrame:IsDescendantOf(k)) then
				releaseBar(v2) -- equivalent call inferred; original call site unknown
				findBar(k, v2)

				if not v2.mainFrame then
					continue
				end
			end

			local gourdyRagePercent = k:GetAttribute("GourdyRagePercent")

			if type(gourdyRagePercent) == "number" then
				updateShake(v2, gourdyRagePercent)
				updatePulse(v2, gourdyRagePercent)
			end
		else
			releaseBar(v2) -- equivalent call inferred; original call site unknown
			v[k] = nil
		end
	end
end)
CollectionService:GetInstanceAddedSignal("GourdyMonster"):Connect(track)
CollectionService:GetInstanceRemovedSignal("GourdyMonster"):Connect(untrack)

for _, v2 in CollectionService:GetTagged("GourdyMonster") do
	track(v2) -- equivalent call inferred; original call site unknown
end