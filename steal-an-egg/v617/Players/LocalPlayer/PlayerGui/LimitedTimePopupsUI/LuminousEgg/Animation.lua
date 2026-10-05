local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local parent2 = script.Parent
local BG = parent2:WaitForChild("BG")
local shadowBG = parent2:FindFirstChild("ShadowBG")
local strokeBG = parent2:FindFirstChild("StrokeBG")
local content = parent2:FindFirstChild("Content")
local close = parent2:FindFirstChild("Close")
local checkItOutBtn = parent2:FindFirstChild("CheckItOutBtn")
local icon = content and content:FindFirstChild("Icon")
local eggName = content and content:FindFirstChild("EggName")
local label = content and content:FindFirstChild("Label")
local item = content and content:FindFirstChild("Item")
local newLabel = content and content:FindFirstChild("NewLabel")
local timerHolder = content and content:FindFirstChild("TimerHolder")
local icon2 = timerHolder and timerHolder:FindFirstChild("Icon")
local uIScale = icon and icon:FindFirstChildOfClass("UIScale")
local uIScale2 = icon2 and icon2:FindFirstChildOfClass("UIScale")

local function ensureScale(parent3, name)
	if not parent3 then
		return nil
	end

	local v = parent3:FindFirstChild(name)

	if not (v and v:IsA("UIScale")) then
		v = Instance.new("UIScale")
		v.Name = name
		v.Parent = parent3
	end

	v.Scale = 1
	return v
end

local v

if parent2 then
	v = parent2:FindFirstChild("OpenAnimScale")

	if not (v and v:IsA("UIScale")) then
		v = Instance.new("UIScale")
		v.Name = "OpenAnimScale"
		v.Parent = parent2
	end

	v.Scale = 1
else
	v = nil
end

local v2

if close then
	v2 = close:FindFirstChild("PressScale")

	if not (v2 and v2:IsA("UIScale")) then
		v2 = Instance.new("UIScale")
		v2.Name = "PressScale"
		v2.Parent = close
	end

	v2.Scale = 1
else
	v2 = nil
end

local v3 = {
	{
		inst = shadowBG,
		dx = 0,
		dy = 0,
		rot = 0,
		scale = 0.94,
		inDelay = 0.06,
		inFade = 0.16,
		outDelay = 0.08
	},
	{
		inst = timerHolder,
		dx = -0.06,
		dy = 0,
		rot = 0,
		scale = 0.92,
		inDelay = 0.14,
		inFade = 0.18,
		outDelay = 0.04
	},
	{
		inst = icon2,
		dx = 0,
		dy = 0,
		rot = 0,
		scale = 1,
		scaleObject = uIScale2,
		scaleFrom = 0.55,
		inDelay = 0.24,
		inFade = 0.14,
		outDelay = 0
	},
	{
		inst = eggName,
		dx = -0.03,
		dy = -0.04,
		rot = 0,
		scale = 0.96,
		inDelay = 0.18,
		inFade = 0.18,
		outDelay = 0.06
	},
	{
		inst = label,
		dx = -0.03,
		dy = -0.04,
		rot = 0,
		scale = 0.96,
		inDelay = 0.22,
		inFade = 0.18,
		outDelay = 0.06
	},
	{
		inst = newLabel,
		dx = 0,
		dy = 0,
		rot = -6,
		scale = 0.6,
		inDelay = 0.26,
		inFade = 0.14,
		outDelay = 0.02
	},
	{
		inst = item,
		dx = 0.07,
		dy = 0.03,
		rot = 4,
		scale = 0.94,
		inDelay = 0.3,
		inFade = 0.18,
		outDelay = 0
	},
	{
		inst = icon,
		dx = 0,
		dy = 0,
		rot = 0,
		scale = 1,
		scaleObject = uIScale,
		scaleFrom = 0.8,
		inDelay = 0.34,
		inFade = 0.18,
		outDelay = 0.02
	},
	{
		inst = checkItOutBtn,
		dx = 0,
		dy = 0.06,
		rot = 0,
		scale = 0.88,
		inDelay = 0.38,
		inFade = 0.18,
		outDelay = 0.02
	},
	{
		inst = close,
		dx = 0,
		dy = -0.03,
		rot = 0,
		scale = 0.7,
		inDelay = 0.42,
		inFade = 0.16,
		outDelay = 0
	}
}

for i = #v3, 1, -1 do
	if not v3[i].inst then
		table.remove(v3, i)
	end
end

local v4 = {}

for _, v5 in ipairs(v3) do
	v4[v5.inst] = true
end

if content then
	local count = 0

	for _, guiObject in ipairs(content:GetChildren()) do
		if not guiObject:IsA("GuiObject") or v4[guiObject] then
			continue
		end

		table.insert(v3, {
			inst = guiObject,
			dx = 0,
			dy = 0.04,
			rot = 0,
			scale = 0.95,
			inDelay = count * 0.04 + 0.46,
			inFade = 0.18,
			outDelay = 0.04
		})
		count += 1
	end
end

local v5 = {
	ImageLabel = { "ImageTransparency", "BackgroundTransparency" },
	ImageButton = { "ImageTransparency", "BackgroundTransparency" },
	TextLabel = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	TextButton = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	TextBox = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	Frame = { "BackgroundTransparency" },
	CanvasGroup = { "GroupTransparency", "BackgroundTransparency" },
	ScrollingFrame = { "ScrollBarImageTransparency", "BackgroundTransparency" },
	ViewportFrame = { "ImageTransparency", "BackgroundTransparency" },
	UIStroke = { "Transparency" },
	UIShadow = { "Transparency" }
}

local function collectFade(folder, insts)
	local v6 = {}

	local function add(guiObject)
		local v7 = v5[guiObject.ClassName]

		if not v7 then
			return
		end

		local props = {}

		for _, name in ipairs(v7) do
			local base = guiObject[name]

			if typeof(base) == "number" and base < 1 then
				table.insert(props, {
					name = name,
					base = base
				})
			end
		end

		if #props > 0 then
			table.insert(v6, {
				inst = guiObject,
				props = props,
				gui = guiObject:IsA("GuiObject")
			})
		end
	end

	add(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		local v7 = false

		if insts then
			for _, ancestor in ipairs(insts) do
				if not (ancestor ~= folder and (descendant == ancestor or descendant:IsDescendantOf(ancestor))) then
					continue
				end

				v7 = true
				break
			end
		end

		if not v7 then
			add(descendant)
		end
	end

	return v6
end

local function scaled(p, p2)
	return UDim2.new(p.X.Scale * p2, p.X.Offset * p2, p.Y.Scale * p2, p.Y.Offset * p2)
end

local function fadeGoal(data, p)
	local result = {}

	for _, v6 in ipairs(data.props) do
		result[v6.name] = v6.base + (1 - v6.base) * p
	end

	return result
end

local function applyFadeList(list, p)
	for _, v6 in ipairs(list) do
		for _, v7 in ipairs(v6.props) do
			v6.inst[v7.name] = v7.base + (1 - v7.base) * p
		end
	end
end

local insts = {}

for _, v6 in ipairs(v3) do
	table.insert(insts, v6.inst)
end

local v6 = {}

for _, v7 in ipairs(v3) do
	local v8 = {
		inst = v7.inst,
		fade = collectFade(v7.inst, insts),
		homePos = v7.inst.Position,
		homeSize = v7.inst.Size,
		homeRot = v7.inst.Rotation,
		parkPos = v7.inst.Position + UDim2.fromScale(v7.dx, v7.dy),
		parkSize = 0,
		parkRot = 0,
		scaleObject = 0,
		scaleHome = 0,
		scaleFrom = 0,
		inDelay = 0,
		inTime = 0.272,
		inFade = 0,
		outDelay = 0,
		outTime = 0.128
	}
	local size = v7.inst.Size
	local scale = v7.scale
	v8.parkSize = UDim2.new(size.X.Scale * scale, size.X.Offset * scale, size.Y.Scale * scale, size.Y.Offset * scale)
	v8.parkRot = v7.inst.Rotation + v7.rot
	v8.scaleObject = v7.scaleObject
	local scaleHome

	if v7.scaleObject then
		scaleHome = v7.scaleObject.Scale or nil
	end

	v8.scaleHome = scaleHome
	local scaleFrom

	if v7.scaleObject then
		scaleFrom = v7.scaleObject.Scale * (v7.scaleFrom or 0.8) or nil
	end

	v8.scaleFrom = scaleFrom
	v8.inDelay = v7.inDelay * 0.8
	v8.inFade = v7.inFade * 0.8
	v8.outDelay = v7.outDelay * 0.8
	table.insert(v6, v8)
end

local v7 = {}

for _, folder in ipairs({ BG, strokeBG }) do
	if not folder then
		continue
	end

	local v8 = {}

	local function add(guiObject)
		local v10 = v5[guiObject.ClassName]

		if not v10 then
			return
		end

		local props = {}

		for i, name in ipairs(v10) do
			local base = guiObject[name]

			if typeof(base) == "number" and base < 1 then
				table.insert(props, {
					name = name,
					base = base
				})
			end
		end

		if #props > 0 then
			table.insert(v8, {
				inst = guiObject,
				props = props,
				gui = guiObject:IsA("GuiObject")
			})
		end
	end

	add(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		add(descendant)
	end

	for _, v10 in ipairs(v8) do
		table.insert(v7, v10)
	end
end

local count = 0
local v8 = false
local v9 = false
local v10 = false
local tweens = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	table.insert(tweens, tween)
	tween:Play()
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTweens()
	for _, v11 in ipairs(tweens) do
		v11:Cancel()
	end

	table.clear(tweens)
end

local function playFade(data, tweenInfo, p)
	if data.gui and not data.inst.Visible then
		for _, v11 in ipairs(data.props) do
			data.inst[v11.name] = v11.base + (1 - v11.base) * p
		end
	else
		play(data.inst, tweenInfo, fadeGoal(data, p)) -- equivalent call inferred; original call site unknown
	end
end

local v11 = {
	HoverBob = true,
	GradientLoop = true,
	PlaySprite = true
}
local v12 = false
local v13 = {}

local function isArtScript(baseScript)
	return baseScript ~= script and baseScript:IsA("BaseScript") and (v11[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
end

local function rememberArtScript(p)
	if v13[p] == nil then
		v13[p] = p.Enabled
	end

	return v13[p]
end

local function setArtRunning(enabled)
	v12 = enabled

	for _, baseScript in ipairs(parent:GetDescendants()) do
		local v14

		if baseScript == script then
			v14 = false
		else
			v14 = baseScript:IsA("BaseScript") and (v11[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
		end

		if not v14 then
			continue
		end

		if v13[baseScript] == nil then
			v13[baseScript] = baseScript.Enabled
		end

		if v13[baseScript] and baseScript.Enabled ~= enabled then
			baseScript.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function park(data)
	data.inst.Position = data.parkPos
	data.inst.Size = data.parkSize
	data.inst.Rotation = data.parkRot

	if data.scaleObject then
		data.scaleObject.Scale = data.scaleFrom
	end

	applyFadeList(data.fade, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function home(data)
	data.inst.Position = data.homePos
	data.inst.Size = data.homeSize
	data.inst.Rotation = data.homeRot

	if data.scaleObject then
		data.scaleObject.Scale = data.scaleHome
	end
end

local function snapOpenRest()
	for _, v14 in ipairs(v6) do
		home(v14) -- equivalent call inferred; original call site unknown
		applyFadeList(v14.fade, 0)
	end

	applyFadeList(v7, 0)
	v.Scale = 1

	if v2 then
		v2.Scale = 1
	end

	parent2.Visible = true
end

local function finishClose()
	stopTweens() -- equivalent call inferred; original call site unknown
	setArtRunning(false)
	parent2.Visible = false
	v.Scale = 1

	if v2 then
		v2.Scale = 1
	end

	for _, v14 in ipairs(v6) do
		home(v14) -- equivalent call inferred; original call site unknown
		applyFadeList(v14.fade, 1)
	end

	applyFadeList(v7, 1)
	v8 = false
	v9 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isShown()
	return parent.Visible and parent:IsDescendantOf(game)
end

local function playOpen()
	count += 1
	local v14 = count
	v8 = true
	v9 = false
	v10 = false
	stopTweens() -- equivalent call inferred; original call site unknown
	setArtRunning(false)

	for _, v15 in ipairs(v6) do
		park(v15) -- equivalent call inferred; original call site unknown
	end

	applyFadeList(v7, 1)
	v.Scale = 0.9

	if v2 then
		v2.Scale = 1
	end

	parent2.Visible = true

	if isShown() then
		play(v, TweenInfo.new(0.336, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}) -- equivalent call inferred; original call site unknown
		local tweenInfo2 = TweenInfo.new(0.11200000000000002, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, v16 in ipairs(v7) do
			playFade(v16, tweenInfo2, 0)
		end

		local v16 = 0.336

		for _, v17 in ipairs(v6) do
			local tweenInfo3 = TweenInfo.new(
				v17.inTime,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out,
				0,
				false,
				v17.inDelay
			)
			play(v17.inst, tweenInfo3, {
				Position = v17.homePos,
				Size = v17.homeSize,
				Rotation = v17.homeRot
			}) -- equivalent call inferred; original call site unknown

			if v17.scaleObject then
				local tween = TweenService:Create(v17.scaleObject, tweenInfo3, {
					Scale = v17.scaleHome
				})
				table.insert(tweens, tween)
				tween:Play()
			end

			local tweenInfo4 = TweenInfo.new(
				v17.inFade,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out,
				0,
				false,
				v17.inDelay
			)

			for _, v19 in ipairs(v17.fade) do
				playFade(v19, tweenInfo4, 0)
			end

			v16 = math.max(v16, v17.inDelay + v17.inTime)
		end

		task.delay(v16, function()
			if count == v14 and v8 and not v10 then
				setArtRunning(true)
			end
		end)
	else
		snapOpenRest()
		v10 = true
	end
end

local function playClose()
	count += 1
	local v14 = count
	v8 = false
	v9 = true
	stopTweens() -- equivalent call inferred; original call site unknown
	setArtRunning(false)

	if v10 or not isShown() then
		finishClose()
		v10 = false
	else
		local v15 = 0

		for _, v16 in ipairs(v6) do
			local tweenInfo = TweenInfo.new(
				v16.outTime,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In,
				0,
				false,
				v16.outDelay
			)
			play(v16.inst, tweenInfo, {
				Position = v16.parkPos,
				Size = v16.parkSize,
				Rotation = v16.parkRot
			}) -- equivalent call inferred; original call site unknown

			if v16.scaleObject then
				local tween = TweenService:Create(v16.scaleObject, tweenInfo, {
					Scale = v16.scaleFrom
				})
				table.insert(tweens, tween)
				tween:Play()
			end

			for _, v18 in ipairs(v16.fade) do
				playFade(v18, tweenInfo, 1)
			end

			v15 = math.max(v15, v16.outDelay + v16.outTime)
		end

		play(v, TweenInfo.new(0.096, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.19199999999999998), {
			Scale = 1.03
		}) -- equivalent call inferred; original call site unknown
		task.delay(0.288, function()
			if count == v14 then
				local tween = TweenService:Create(
					v,
					TweenInfo.new(0.272, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Scale = 0.9
					}
				)
				table.insert(tweens, tween)
				tween:Play()
			end
		end)
		local tweenInfo2 = TweenInfo.new(0.272, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.288)

		for _, v17 in ipairs(v7) do
			playFade(v17, tweenInfo2, 1)
		end

		local v17 = math.max(v15, 0.56) + 0.02
		task.delay(v17, function()
			if count == v14 then
				finishClose()
			end
		end)
	end
end

local function setOpen(p)
	if p == v8 and not (p and v9) then
		return
	end

	if p then
		playOpen()
	else
		playClose()
	end
end

if close then
	close.Activated:Connect(function()
		if not v8 then
			return
		end

		if v2 then
			TweenService:Create(v2, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 0.88
			}):Play()
		end

		parent:SetAttribute("Open", false)
	end)
end

parent:GetAttributeChangedSignal("Open"):Connect(function()
	local open = parent:GetAttribute("Open") == true

	if open == v8 then
		if not (open and v9) then
			return
		end
	end

	if open then
		playOpen()
	else
		playClose()
	end
end)
parent.DescendantAdded:Connect(function(baseScript)
	local v14

	if baseScript == script then
		v14 = false
	else
		v14 = baseScript:IsA("BaseScript") and (v11[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
	end

	if v14 then
		if v13[baseScript] == nil then
			v13[baseScript] = baseScript.Enabled
		end

		if v13[baseScript] and not v12 then
			baseScript.Enabled = false
		end
	end
end)
parent.DescendantRemoving:Connect(function(descendant)
	v13[descendant] = nil
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function suspend()
	count += 1

	if v9 or not v8 then
		finishClose()
		return
	end

	stopTweens() -- equivalent call inferred; original call site unknown
	setArtRunning(false)
	snapOpenRest()
	v10 = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resume()
	v10 = false
	count += 1
	setArtRunning(true)
end

local function onShownChanged()
	if isShown() then
		if v10 and v8 then
			resume() -- equivalent call inferred; original call site unknown
		end
	elseif v8 and not v10 or v9 then
		suspend() -- equivalent call inferred; original call site unknown
	end
end

local function onMainVisibleChanged()
	if parent2.Visible then
		if not (v8 or v9) then
			if v8 ~= true or v9 then
				playOpen()
			end

			parent:SetAttribute("Open", true)
		end
	elseif v8 or v9 then
		count += 1
		finishClose()
		parent:SetAttribute("Open", false)
	end
end

parent2.Visible = false
setArtRunning(false)

for _, v14 in ipairs(v6) do
	applyFadeList(v14.fade, 1)
end

applyFadeList(v7, 1)

if parent:GetAttribute("Open") == true then
	playOpen()
elseif parent:GetAttribute("Open") == nil then
	parent:SetAttribute("Open", false)
end

parent:GetPropertyChangedSignal("Visible"):Connect(onShownChanged)
parent.AncestryChanged:Connect(onShownChanged)
parent2:GetPropertyChangedSignal("Visible"):Connect(onMainVisibleChanged)
parent.Destroying:Once(function()
	count += 1
	stopTweens() -- equivalent call inferred; original call site unknown
	setArtRunning(false)
end)
task.spawn(function()
	local LimitedEgg = require(ReplicatedStorage.Data.LimitedEgg)
	local Assets = require(ReplicatedStorage.Data.Assets)
	local assetId = LimitedEgg.MechaReroll.Entries[1].AssetId
	local v14 = Assets.Directory[assetId]
	local icon3 = content.Item.Icon
	local icon22 = content.Item.Icon2
	icon3.Image = v14.Icon
	icon22.Image = v14.Icon
	local v15 = 1

	while true do
		if not isShown() then
			parent:GetPropertyChangedSignal("Visible"):Wait()
		end

		v15 = v15 % #LimitedEgg.MechaReroll.Entries + 1
		local assetId2 = LimitedEgg.MechaReroll.Entries[v15].AssetId
		local v16 = Assets.Directory[assetId2]
		icon22.Image = v16.Icon
		TweenService:Create(icon3, TweenInfo.new(0.5), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(icon22, TweenInfo.new(0.5), {
			ImageTransparency = 0
		}):Play()
		task.wait(1)
		icon3.Image = v16.Icon
		icon3.ImageTransparency = 0
		icon22.ImageTransparency = 1
		task.wait(1)
	end
end)