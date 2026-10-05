local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
require(script.Parent.Types)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Feed = {}
Feed.__index = Feed

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTweens(p)
	for _, tween in p.tweens do
		tween:Cancel()
	end

	table.clear(p.tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(p, p2, p3)
	local tween2 = TweenService:Create(p2, tweenInfo, p3)
	table.insert(p.tweens, tween2)
	tween2:Play()
end

local function setOpacity(p, flag: boolean, flag2: boolean)
	local descendants = p.notification.Label:GetDescendants()
	table.insert(descendants, p.notification.Label)

	for _, guiObject in descendants do
		if guiObject:IsA("TextLabel") and guiObject.Name ~= "TranslateMe" then
			local textTransparency = flag and 1 or 0
			local textStrokeTransparency = flag and 1 or 0.5

			if flag2 then
				guiObject.TextTransparency = textTransparency
				guiObject.TextStrokeTransparency = textStrokeTransparency
			else
				tween(p, guiObject, {
					TextTransparency = textTransparency,
					TextStrokeTransparency = textStrokeTransparency
				}) -- equivalent call inferred; original call site unknown
			end
		elseif guiObject:IsA("Frame") and guiObject.Name == "Banner" then
			if flag2 then
				guiObject.BackgroundTransparency = flag and 1 or 0.5
			else
				tween(p, guiObject, {
					BackgroundTransparency = flag and 1 or 0.5
				}) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

local function addBanner(folder)
	folder.ZIndex = 100

	for _, label in folder:GetDescendants() do
		if label:IsA("TextLabel") then
			label.ZIndex = 102
		end
	end

	local textSize = TextService:GetTextSize(folder.ContentText, folder.TextSize, folder.Font, Vector2.new(1e999, 31))
	local frame = Instance.new("Frame")
	frame.Name = "Banner"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(textSize.X + 100, 31)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 101
	frame.Parent = folder
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
end

local function expire(list, now: number)
	local v = false

	for i = #list, 1, -1 do
		local v2 = list[i]

		if not (v2.startedAt and now - v2.startedAt >= v2.remaining) then
			continue
		end

		table.remove(list, i)
		cancelTweens(v2) -- equivalent call inferred; original call site unknown
		setOpacity(v2, true, false)
		local v3 = v2
		task.delay(tweenInfo.Time, function()
			v3.notification.Label:Destroy()
		end)
		v = true
	end

	return v
end

local function resize(list, list2, p: number, now: number)
	local v = false

	while p < #list do
		local v2 = table.remove(list)
		v2.remaining -= now - v2.startedAt
		v2.startedAt = nil
		v2.notification.Label.Visible = false
		cancelTweens(v2) -- equivalent call inferred; original call site unknown
		table.insert(list2, 1, v2)
		v = true
	end

	while #list < p and #list2 > 0 do
		local v2 = table.remove(list2, 1)
		v2.startedAt = now
		v2.notification.CreationTime = now - (v2.notification.Duration - v2.remaining)
		v2.entering = true
		table.insert(list, v2)
		v = true
	end

	return v
end

local function reflow(items, p: number)
	for k, item in items do
		cancelTweens(item) -- equivalent call inferred; original call site unknown
		local label = item.notification.Label
		local uDim = UDim2.new(0.5, 0, 0, p + (k - 1) * 33 + label.Size.Y.Offset * 0.5)

		if item.entering then
			item.entering = false
			label.Position = uDim - UDim2.fromOffset(0, 16)
			setOpacity(item, true, true)
		end

		label.Visible = true
		tween(item, label, {
			Position = uDim
		}) -- equivalent call inferred; original call site unknown
		setOpacity(item, false, false)
	end
end

function Feed.new(container, playerGui)
	return (setmetatable({
		_container = container,
		_playerGui = playerGui,
		_active = {},
		_priority = {},
		_pending = {},
		_pendingPriority = {},
		_offset = 0,
		_capacity = 0
	}, Feed))
end

function Feed:Add(notification)
	local label = notification.Label
	label.Visible = false
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Parent = self._container

	if notification.Prioritized then
		addBanner(label)
	end

	local v

	if notification.Prioritized then
		v = self._pendingPriority
	else
		v = self._pending
	end

	table.insert(v, {
		notification = notification,
		remaining = notification.Duration,
		startedAt = nil,
		tweens = {},
		entering = true
	})
	self:Update()
end

function Feed:Update()
	local offset = 0
	local transformationHUD = self._playerGui:FindFirstChild("TransformationHUD")
	local bossBar

	if transformationHUD then
		bossBar = transformationHUD:FindFirstChild("BossBar")
	end

	if transformationHUD and transformationHUD:IsA("ScreenGui") and transformationHUD.Enabled and bossBar and bossBar:IsA("GuiObject") and bossBar.Visible then
		for _, guiObject in bossBar:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				offset = math.max(
					offset,
					guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y + 4 - self._container.AbsolutePosition.Y
				)
			end
		end
	end

	local currentCamera = workspace.CurrentCamera
	local viewportSize

	if currentCamera then
		viewportSize = currentCamera.ViewportSize
	else
		viewportSize = Vector2.new(1280, 720)
	end

	local capacity = math.min(
		math.min(viewportSize.X, viewportSize.Y) <= 600 and 5 or 10,
		(math.max(0, (math.floor((self._container.AbsoluteSize.Y - offset - 16) / 33))))
	)
	local now = tick()
	local v3 = expire(self._active, now)
	local v4 = expire(self._priority, now) or v3
	local v5 = resize(self._priority, self._pendingPriority, capacity, now) or v4

	if resize(self._active, self._pending, capacity - #self._priority, now) or v5 or self._offset ~= offset or self._capacity ~= capacity then
		self._offset = offset
		self._capacity = capacity
		reflow(self._priority, offset)
		reflow(self._active, offset + #self._priority * 33)
	end
end

return Feed