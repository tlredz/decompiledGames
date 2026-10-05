local TweenService = game:GetService("TweenService")
local parent = script.Parent
local dRScrambleEventUIMain = parent:WaitForChild("DRScrambleEventUIMain")
local BG = dRScrambleEventUIMain:WaitForChild("BG")
local close = dRScrambleEventUIMain:FindFirstChild("Close")
local contentFrame = dRScrambleEventUIMain:FindFirstChild("ContentFrame")
local rollButton = dRScrambleEventUIMain:FindFirstChild("RollButton")
local middleLaser = dRScrambleEventUIMain:FindFirstChild("MiddleLaser")
local leftTube = dRScrambleEventUIMain:FindFirstChild("LeftTube")
local rightTube = dRScrambleEventUIMain:FindFirstChild("RightTube")
local leftTopTube = dRScrambleEventUIMain:FindFirstChild("LeftTopTube")
local rightTopTube = dRScrambleEventUIMain:FindFirstChild("RightTopTube")
local leftLaser = dRScrambleEventUIMain:FindFirstChild("LeftLaser")
local rightLaser = dRScrambleEventUIMain:FindFirstChild("RightLaser")
local paperNote1 = dRScrambleEventUIMain:FindFirstChild("PaperNote1")
local paperNote2 = dRScrambleEventUIMain:FindFirstChild("PaperNote2")
local playSprite = middleLaser and middleLaser:FindFirstChild("PlaySprite")
local _ = playSprite and not playSprite:IsA("BaseScript")
local itemsHolder = contentFrame and contentFrame:FindFirstChild("ItemsHolder", true)
local container2 = nil

if contentFrame then
	for _, scrollingFrame in ipairs(contentFrame:GetDescendants()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		container2 = scrollingFrame
		break
	end
end

local v2 = {}

if itemsHolder then
	table.insert(v2, {
		container = itemsHolder,
		mode = "layers"
	})
end

if container2 then
	table.insert(v2, {
		container = container2,
		mode = "item"
	})
end

local containers = {}

for _, v3 in ipairs(v2) do
	table.insert(containers, v3.container)
end

local labels = {}

for _, label in ipairs(dRScrambleEventUIMain:GetChildren()) do
	if label:IsA("TextLabel") then
		table.insert(labels, label)
	end
end

local frozen = table.freeze({})
local zero = Vector2.zero
local v3 = dRScrambleEventUIMain:FindFirstChild("OpenAnimScale")

if not (v3 and v3:IsA("UIScale")) then
	v3 = Instance.new("UIScale")
	v3.Name = "OpenAnimScale"
	v3.Parent = dRScrambleEventUIMain
end

v3.Scale = 1
local v4

if close then
	v4 = close:FindFirstChild("PressScale")

	if not (v4 and v4:IsA("UIScale")) then
		v4 = Instance.new("UIScale")
		v4.Name = "PressScale"
		v4.Parent = close
	end

	v4.Scale = 1
else
	v4 = nil
end

local v5 = {
	{
		inst = leftTopTube,
		dx = 0.09,
		dy = 0.19,
		rot = 5,
		scale = 0.97,
		hidden = true,
		inDelay = 0.18,
		inTime = 0.55,
		inFade = 0,
		outDelay = 0.08,
		outTime = 0.22
	},
	{
		inst = rightTopTube,
		dx = -0.09,
		dy = 0.19,
		rot = -5,
		scale = 0.97,
		hidden = true,
		inDelay = 0.18,
		inTime = 0.55,
		inFade = 0,
		outDelay = 0.08,
		outTime = 0.22
	},
	{
		inst = leftTube,
		dx = 0.175,
		dy = 0,
		rot = 6,
		scale = 0.97,
		hidden = true,
		inDelay = 0.26,
		inTime = 0.55,
		inFade = 0,
		outDelay = 0.12,
		outTime = 0.22
	},
	{
		inst = rightTube,
		dx = -0.175,
		dy = 0,
		rot = -6,
		scale = 0.97,
		hidden = true,
		inDelay = 0.26,
		inTime = 0.55,
		inFade = 0,
		outDelay = 0.12,
		outTime = 0.22
	},
	{
		inst = leftLaser,
		dx = 0.02,
		dy = 0.18,
		rot = 3,
		scale = 0.95,
		hidden = true,
		inDelay = 0.34,
		inTime = 0.46,
		inFade = 0,
		outDelay = 0.04,
		outTime = 0.22
	},
	{
		inst = rightLaser,
		dx = -0.02,
		dy = 0.18,
		rot = -3,
		scale = 0.95,
		hidden = true,
		inDelay = 0.34,
		inTime = 0.46,
		inFade = 0,
		outDelay = 0.04,
		outTime = 0.22
	},
	{
		inst = middleLaser,
		dx = 0,
		dy = 0,
		rot = 0,
		scale = 0.55,
		inDelay = 0.48,
		inTime = 0.34,
		inFade = 0.2,
		outDelay = 0,
		outTime = 0.1
	},
	{
		inst = contentFrame,
		dx = 0,
		dy = 0.05,
		rot = 0,
		scale = 0.94,
		inDelay = 0.36,
		inTime = 0.34,
		inFade = 0.2,
		outDelay = 0.1,
		outTime = 0.16
	},
	{
		inst = paperNote1,
		dx = -0.012,
		dy = 0.036,
		rot = -7,
		scale = 0.9,
		inDelay = 0.4,
		inTime = 0.34,
		inFade = 0.18,
		outDelay = 0.06,
		outTime = 0.16
	},
	{
		inst = paperNote2,
		dx = 0.012,
		dy = 0.036,
		rot = 7,
		scale = 0.9,
		inDelay = 0.4,
		inTime = 0.34,
		inFade = 0.18,
		outDelay = 0.06,
		outTime = 0.16
	},
	{
		inst = rollButton,
		dx = 0,
		dy = 0.06,
		rot = 0,
		scale = 0.88,
		inDelay = 0.44,
		inTime = 0.34,
		inFade = 0.18,
		outDelay = 0.02,
		outTime = 0.16
	},
	{
		inst = close,
		dx = 0,
		dy = -0.03,
		rot = 0,
		scale = 0.7,
		inDelay = 0.44,
		inTime = 0.34,
		inFade = 0.16,
		outDelay = 0.08,
		outTime = 0.16
	}
}

for i = #v5, 1, -1 do
	if not v5[i].inst then
		table.remove(v5, i)
	end
end

for i, inst in ipairs(labels) do
	table.insert(v5, {
		inst = inst,
		dx = 0,
		dy = 0.045,
		rot = 0,
		scale = 0.92,
		inDelay = 0.28 + (i - 1) * 0.04,
		inTime = 0.34,
		inFade = 0.2,
		outDelay = 0.14,
		outTime = 0.16
	})
end

local v6 = {}

for _, v7 in ipairs(v5) do
	v6[v7.inst] = true
end

v6[BG] = true
local count = 0

for _, guiObject in ipairs(dRScrambleEventUIMain:GetChildren()) do
	if not guiObject:IsA("GuiObject") or v6[guiObject] then
		continue
	end

	if guiObject.ZIndex < BG.ZIndex then
		local v7 = guiObject.Position.X.Scale - 0.5
		local v8 = guiObject.Position.Y.Scale - 0.5
		local v9 = math.max(math.sqrt(v7 * v7 + v8 * v8), 0.05)
		table.insert(v5, {
			inst = guiObject,
			dx = -v7 / v9 * 0.16,
			dy = -v8 / v9 * 0.16,
			rot = v7 < 0 and 5 or -5,
			scale = 0.97,
			inDelay = 0.22,
			inTime = 0.55,
			inFade = 0.12,
			outDelay = 0.1,
			outTime = 0.22
		})
	else
		table.insert(v5, {
			inst = guiObject,
			dx = 0,
			dy = 0.045,
			rot = 0,
			scale = 0.95,
			inDelay = count * 0.04 + 0.52,
			inTime = 0.34,
			inFade = 0.2,
			outDelay = 0.16,
			outTime = 0.16
		})
	end

	count += 1
end

local v7 = {
	ImageLabel = { "ImageTransparency", "BackgroundTransparency" },
	ImageButton = { "ImageTransparency", "BackgroundTransparency" },
	TextLabel = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	TextButton = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	Frame = { "BackgroundTransparency" },
	CanvasGroup = { "GroupTransparency", "BackgroundTransparency" },
	TextBox = { "TextTransparency", "TextStrokeTransparency", "BackgroundTransparency" },
	ScrollingFrame = { "ScrollBarImageTransparency", "BackgroundTransparency" },
	ViewportFrame = { "ImageTransparency", "BackgroundTransparency" },
	VideoFrame = { "BackgroundTransparency" },
	UIStroke = { "Transparency" },
	UIShadow = { "Transparency" }
}

local function collectFade(folder, containers2)
	local v8 = {}

	local function add(guiObject)
		local v9 = v7[guiObject.ClassName]

		if not v9 then
			return
		end

		local props = {}

		for _, name in ipairs(v9) do
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
		local v9 = false

		if containers2 then
			for _, ancestor in ipairs(containers2) do
				if not descendant:IsDescendantOf(ancestor) then
					continue
				end

				v9 = true
				break
			end
		end

		if not v9 then
			add(descendant)
		end
	end

	return v8
end

local function scaled(p, p2)
	return UDim2.new(p.X.Scale * p2, p.X.Offset * p2, p.Y.Scale * p2, p.Y.Offset * p2)
end

local function fadeGoal(data, p)
	local result = {}

	for _, v8 in ipairs(data.props) do
		result[v8.name] = v8.base + (1 - v8.base) * p
	end

	return result
end

local function applyFadeList(list, p)
	for _, v8 in ipairs(list) do
		for _, v9 in ipairs(v8.props) do
			v8.inst[v9.name] = v9.base + (1 - v9.base) * p
		end
	end
end

local v8 = {}
local v9 = {}

for _, v10 in ipairs(v5) do
	local fade = collectFade(v10.inst, containers)
	local rootFade = nil
	local subFade = {}

	for _, v14 in ipairs(fade) do
		if v14.inst == v10.inst and not rootFade then
			rootFade = v14
		else
			table.insert(subFade, v14)
		end
	end

	local v14 = {
		inst = v10.inst,
		fade = fade,
		rootFade = rootFade,
		subFade = subFade,
		hidden = v10.hidden == true,
		homePos = v10.inst.Position,
		homeSize = v10.inst.Size,
		homeRot = v10.inst.Rotation,
		parkPos = v10.inst.Position + UDim2.fromScale(v10.dx, v10.dy),
		parkSize = 0,
		parkRot = 0,
		inDelay = 0,
		inTime = 0,
		inFade = 0,
		outDelay = 0,
		outTime = 0
	}
	local size = v10.inst.Size
	local scale = v10.scale
	v14.parkSize = UDim2.new(size.X.Scale * scale, size.X.Offset * scale, size.Y.Scale * scale, size.Y.Offset * scale)
	v14.parkRot = v10.inst.Rotation + v10.rot
	v14.inDelay = v10.inDelay * 0.8
	v14.inTime = v10.inTime * 0.8
	v14.inFade = v10.inFade * 0.8
	v14.outDelay = v10.outDelay * 0.8
	v14.outTime = v10.outTime * 0.8
	table.insert(v8, v14)

	if v14.hidden then
		table.insert(v9, v14)
	end
end

local v10 = {}

local function add(guiObject)
	local v11 = v7[guiObject.ClassName]

	if not v11 then
		return
	end

	local props = {}

	for _, name in ipairs(v11) do
		local base = guiObject[name]

		if typeof(base) == "number" and base < 1 then
			table.insert(props, {
				name = name,
				base = base
			})
		end
	end

	if #props > 0 then
		table.insert(v10, {
			inst = guiObject,
			props = props,
			gui = guiObject:IsA("GuiObject")
		})
	end
end

add(BG)

for _, descendant in ipairs(BG:GetDescendants()) do
	add(descendant)
end

local count2 = 0
local v11 = false
local v12 = false
local flag = false
local v13 = true
local tweens = {}
local v14 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	table.insert(tweens, tween)
	tween:Play()
	return tween
end

local function stopTweens()
	for _, v15 in ipairs(tweens) do
		v15:Cancel()
	end

	table.clear(tweens)

	if v14 then
		v14:Cancel()
		v14 = nil
	end
end

local function playFade(data, tweenInfo, p)
	if data.gui and not data.inst.Visible then
		for _, v15 in ipairs(data.props) do
			data.inst[v15.name] = v15.base + (1 - v15.base) * p
		end
	else
		play(data.inst, tweenInfo, fadeGoal(data, p)) -- equivalent call inferred; original call site unknown
	end
end

local v15 = {
	PlaySprite = true,
	GradientLoop = true
}
local v16 = false

local function isArtScript(baseScript)
	return baseScript ~= script and baseScript:IsA("BaseScript") and (v15[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
end

local function setSpriteRunning(enabled)
	v16 = enabled

	for _, baseScript in ipairs(parent:GetDescendants()) do
		local v17

		if baseScript == script then
			v17 = false
		else
			v17 = baseScript:IsA("BaseScript") and (v15[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
		end

		if v17 and baseScript.Enabled ~= enabled then
			baseScript.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetPress()
	if v4 then
		v4.Scale = 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function park(data)
	data.inst.Position = data.parkPos
	data.inst.Size = data.parkSize
	data.inst.Rotation = data.parkRot
	applyFadeList(data.fade, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function home(data)
	data.inst.Position = data.homePos
	data.inst.Size = data.homeSize
	data.inst.Rotation = data.homeRot
end

local vector = Vector2.new(0.5, 0.5)
local uDim = UDim2.fromScale(0.5, 0.5)
local v17 = {}
local v18 = {}

local function drawsSomething(guiObject, list)
	for _, v19 in ipairs(list) do
		if v19.inst == guiObject or v19.inst:IsDescendantOf(guiObject) then
			return true
		end
	end

	return false
end

local function isSpacer(guiObject)
	if guiObject.BackgroundTransparency < 1 or (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		return false
	end

	for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
		if guiObject2:IsA("GuiObject") then
			return false
		end
	end

	return true
end

local function getItem(folder, p, mode)
	local v19 = v17[folder]

	if v19 and not p then
		return v19
	end

	if mode == "item" then
		local v20 = folder:FindFirstChild("PopScale")

		if not (v20 and v20:IsA("UIScale")) then
			v20 = Instance.new("UIScale")
			v20.Name = "PopScale"
			v20.Parent = folder
		end

		v20.Scale = 1
		local selected = v19 or {
			card = folder,
			order = 0,
			index = 0
		}
		selected.fade = frozen
		selected.pops = { v20 }
		selected.mode = "item"
		v17[folder] = selected
		return selected
	else
		local fade = {}

		local function add2(guiObject)
			local v21 = v7[guiObject.ClassName]

			if not v21 then
				return
			end

			local props = {}

			for _, name in ipairs(v21) do
				local base = guiObject[name]

				if typeof(base) == "number" and base < 1 then
					table.insert(props, {
						name = name,
						base = base
					})
				end
			end

			if #props > 0 then
				table.insert(fade, {
					inst = guiObject,
					props = props,
					gui = guiObject:IsA("GuiObject")
				})
			end
		end

		add2(folder)

		for _, descendant in ipairs(folder:GetDescendants()) do
			add2(descendant)
		end

		local pops = {}

		for _, guiObject in ipairs(folder:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject.AnchorPoint == vector and guiObject.Position == uDim and drawsSomething(
				guiObject,
				fade
			)) then
				continue
			end

			local v22 = guiObject:FindFirstChild("PopScale")

			if not (v22 and v22:IsA("UIScale")) then
				v22 = Instance.new("UIScale")
				v22.Name = "PopScale"
				v22.Parent = guiObject
			end

			v22.Scale = 1
			table.insert(pops, v22)
		end

		local selected = v19 or {
			card = folder,
			order = 0,
			index = 0
		}
		selected.fade = fade
		selected.pops = pops
		selected.mode = "layers"
		v17[folder] = selected
		return selected
	end
end

local function forgetCard(p)
	v17[p] = nil

	for i = #v18, 1, -1 do
		if v18[i].card == p then
			table.remove(v18, i)
		end
	end
end

local function sortCards(p, p2)
	if p.order == p2.order then
		return p.index < p2.index
	end

	return p.order < p2.order
end

local result = {}

local function collectGroup(p, p2)
	table.clear(result)
	local container = p.container

	if not container.Visible then
		return result
	end

	for i, guiObject in ipairs(container:GetChildren()) do
		if not guiObject:IsA("GuiObject") or not guiObject.Visible or isSpacer(guiObject) then
			continue
		end

		local item = getItem(guiObject, p2, p.mode)
		item.order = guiObject.LayoutOrder
		item.index = i
		table.insert(result, item)
		table.insert(v18, item)
	end

	table.sort(result, sortCards)
	return result
end

local function playItemsIn(p)
	table.clear(v18)
	local v19 = 0

	for _, v20 in ipairs(v2) do
		if v20.mode == "item" and v20.container:IsA("ScrollingFrame") then
			v20.container.CanvasPosition = zero
		end

		for i, v21 in ipairs((collectGroup(v20, p))) do
			local v22 = (0.4 + (i - 1) * 0.03) * 0.8
			local scale = v21.mode == "item" and 0 or 0.6
			applyFadeList(v21.fade, 1)

			for _, pop in ipairs(v21.pops) do
				pop.Scale = scale
			end

			local tweenInfo = TweenInfo.new(
				0.11200000000000002,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out,
				0,
				false,
				v22
			)

			for _, v24 in ipairs(v21.fade) do
				playFade(v24, tweenInfo, 0)
			end

			local quint = v21.mode == "item" and Enum.EasingStyle.Quint or Enum.EasingStyle.Back
			local tweenInfo2 = TweenInfo.new(0.272, quint, Enum.EasingDirection.Out, 0, false, v22)

			for _, pop in ipairs(v21.pops) do
				local tween = TweenService:Create(pop, tweenInfo2, {
					Scale = 1
				})
				table.insert(tweens, tween)
				tween:Play()
			end

			v19 = math.max(v19, v22 + 0.272)
		end
	end

	return v19
end

local function playItemsOut(p)
	table.clear(v18)
	local v19 = 0

	for _, v20 in ipairs(v2) do
		local v21 = collectGroup(v20, p)
		local v22 = #v21

		for i, v23 in ipairs(v21) do
			local v24 = (v22 - i) * 0.012 * 0.8
			local tweenInfo = TweenInfo.new(0.128, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, v24)

			for _, v25 in ipairs(v23.fade) do
				playFade(v25, tweenInfo, 1)
			end

			local scale = v23.mode == "item" and 0 or 0.8

			for _, pop in ipairs(v23.pops) do
				local tween = TweenService:Create(pop, tweenInfo, {
					Scale = scale
				})
				table.insert(tweens, tween)
				tween:Play()
			end

			v19 = math.max(v19, v24 + 0.128)
		end
	end

	return v19
end

local function restoreItems()
	for _, v19 in ipairs(v18) do
		applyFadeList(v19.fade, 0)

		for _, pop in ipairs(v19.pops) do
			pop.Scale = 1
		end
	end
end

local count3 = 0
local v19 = {}

for _, v20 in ipairs(v8) do
	if not (v20.inst == paperNote1 or v20.inst == paperNote2) then
		continue
	end

	count3 += 1
	local v21 = count3 == 1
	table.insert(v19, {
		inst = v20.inst,
		homeRot = v20.homeRot,
		rate = 6.283185307179586 / (v21 and 2.6 or 3.1),
		phase = v21 and 0 or 1.9,
		sway = v21 and 1.5 or -1.5,
		last = v20.homeRot
	})
end

local imageColor3 = BG.ImageColor3
local flag2 = false
local v20 = 1

local function idleStep(total)
	for _, v21 in ipairs(v19) do
		local v22 = v21.homeRot + math.sin(total * v21.rate + v21.phase) * v21.sway

		if not (math.abs(v22 - v21.last) >= 0.05) then
			continue
		end

		v21.last = v22
		v21.inst.Rotation = v22
	end

	local v21 = 1 - (0.5 - math.cos(total * 1.7951958020513104) * 0.5) * 0.045

	if math.abs(v21 - v20) >= 0.0015 then
		v20 = v21
		BG.ImageColor3 = Color3.new(imageColor3.R * v21, imageColor3.G * v21, imageColor3.B * v21)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopIdle()
	flag2 = false

	for _, v21 in ipairs(v19) do
		v21.inst.Rotation = v21.homeRot
		v21.last = v21.homeRot
	end

	BG.ImageColor3 = imageColor3
	v20 = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startIdle(p)
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		local total = 0

		while flag2 and count2 == p do
			total += task.wait(0.05)

			if not flag2 or count2 ~= p then
				break
			end

			idleStep(total)
		end
	end)
end

local function runLaserCycle(p)
	if not middleLaser then
		return
	end

	while count2 == p do
		local v21 = 4 + math.random() * 1
		local total = 0

		while total < v21 and count2 == p do
			local v22 = 0.05 + math.random() * 0.09
			task.wait(v22)
			total += v22
			middleLaser.ImageTransparency = math.random() < 0.22 and 0.2 + math.random() * 0.3 or 0
		end

		if count2 ~= p then
			break
		end

		v14 = TweenService:Create(middleLaser, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		})
		v14:Play()
		task.wait(0.3)

		if count2 ~= p then
			break
		end

		v14 = nil
		middleLaser.Visible = false
		setSpriteRunning(false)
		task.wait(1.1 + math.random() * 0.7)

		if count2 ~= p then
			break
		end

		setSpriteRunning(true)
		middleLaser.Visible = true
		v14 = TweenService:Create(middleLaser, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		})
		v14:Play()
		task.wait(0.26)

		if count2 ~= p then
			break
		end

		v14 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isShown()
	return parent.Enabled and parent.Parent ~= nil
end

local function snapOpenRest()
	for _, v21 in ipairs(v8) do
		home(v21) -- equivalent call inferred; original call site unknown
		applyFadeList(v21.fade, 0)
	end

	applyFadeList(v10, 0)
	v3.Scale = 1
	resetPress() -- equivalent call inferred; original call site unknown

	if middleLaser then
		middleLaser.Visible = true
	end

	restoreItems()
end

local function finishClose()
	v11 = false
	v12 = false
	flag = false
	v13 = true
	stopTweens()
	stopIdle() -- equivalent call inferred; original call site unknown
	dRScrambleEventUIMain.Visible = false
	v3.Scale = 1
	resetPress() -- equivalent call inferred; original call site unknown
	setSpriteRunning(false)

	for _, v21 in ipairs(v8) do
		home(v21) -- equivalent call inferred; original call site unknown
		applyFadeList(v21.fade, 1)
	end

	applyFadeList(v10, 1)
	restoreItems()
	table.clear(v18)
end

local function playOpen()
	local v21 = v13
	count2 += 1
	local v22 = count2
	v11 = true
	v12 = false
	flag = false
	v13 = false
	stopTweens()
	stopIdle() -- equivalent call inferred; original call site unknown

	for _, v23 in ipairs(v8) do
		park(v23) -- equivalent call inferred; original call site unknown
	end

	applyFadeList(v10, 1)

	if middleLaser then
		middleLaser.Visible = true
	end

	setSpriteRunning(true)
	resetPress() -- equivalent call inferred; original call site unknown
	v3.Scale = 0.88
	dRScrambleEventUIMain.Visible = true
	parent.Enabled = true

	if isShown() then
		play(v3, TweenInfo.new(0.336, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}) -- equivalent call inferred; original call site unknown
		local tweenInfo2 = TweenInfo.new(0.11200000000000002, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, v24 in ipairs(v10) do
			playFade(v24, tweenInfo2, 0)
		end

		if #v9 > 0 then
			task.delay(0.128, function()
				if count2 ~= v22 then
					return
				end

				for _, v24 in ipairs(v9) do
					applyFadeList(v24.fade, 0)
				end
			end)
		end

		local v24 = 0.336

		for _, v25 in ipairs(v8) do
			local tweenInfo3 = TweenInfo.new(
				v25.inTime,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out,
				0,
				false,
				v25.inDelay
			)
			play(v25.inst, tweenInfo3, {
				Position = v25.homePos,
				Size = v25.homeSize,
				Rotation = v25.homeRot
			}) -- equivalent call inferred; original call site unknown

			if not v25.hidden then
				local tweenInfo4 = TweenInfo.new(
					v25.inFade,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					false,
					v25.inDelay
				)

				for _, v27 in ipairs(v25.fade) do
					playFade(v27, tweenInfo4, 0)
				end
			end

			v24 = math.max(v24, v25.inDelay + v25.inTime)
		end

		local v25 = math.max(v24, (playItemsIn(v21)))
		task.delay(v25, function()
			if count2 == v22 then
				table.clear(tweens)
				v13 = true
				startIdle(v22) -- equivalent call inferred; original call site unknown
				runLaserCycle(v22)
			end
		end)
	else
		setSpriteRunning(false)
		snapOpenRest()
		flag = true
		v13 = true
	end
end

local function playClose()
	local v21 = v13
	count2 += 1
	local v22 = count2
	v11 = false
	v12 = true
	v13 = false
	stopTweens()
	stopIdle() -- equivalent call inferred; original call site unknown

	if flag or not parent.Enabled or parent.Parent == nil then
		finishClose()
		return
	end

	local v23 = 0

	for _, v24 in ipairs(v8) do
		local tweenInfo = TweenInfo.new(
			v24.outTime,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In,
			0,
			false,
			v24.outDelay
		)
		local v25 = {
			Position = v24.parkPos,
			Size = v24.parkSize,
			Rotation = v24.parkRot
		}

		if not v24.hidden and v24.rootFade then
			for _, v26 in ipairs(v24.rootFade.props) do
				v25[v26.name] = 1
			end
		end

		play(v24.inst, tweenInfo, v25) -- equivalent call inferred; original call site unknown

		if not v24.hidden then
			for _, v26 in ipairs(v24.subFade) do
				playFade(v26, tweenInfo, 1)
			end
		end

		v23 = math.max(v23, v24.outDelay + v24.outTime)
	end

	local v24 = math.max(v23, (playItemsOut(v21)))

	if #v9 > 0 then
		task.delay(0.32000000000000006, function()
			if count2 ~= v22 then
				return
			end

			for _, v25 in ipairs(v9) do
				applyFadeList(v25.fade, 1)
			end
		end)
	end

	play(v3, TweenInfo.new(0.096, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.24000000000000002), {
		Scale = 1.03
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.336, function()
		if count2 == v22 then
			local tween = TweenService:Create(
				v3,
				TweenInfo.new(0.272, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Scale = 0.9
				}
			)
			table.insert(tweens, tween)
			tween:Play()
		end
	end)
	local tweenInfo2 = TweenInfo.new(0.272, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.336)

	for _, v26 in ipairs(v10) do
		playFade(v26, tweenInfo2, 1)
	end

	local v26 = math.max(v24, 0.32000000000000006, 0.6080000000000001) + 0.02
	task.delay(v26, function()
		if count2 == v22 then
			finishClose()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setOpen(open)
	if open == v11 then
		return
	end

	if open then
		playOpen()
	else
		playClose()
	end
end

if close then
	close.Activated:Connect(function()
		if not v11 then
			return
		end

		TweenService:Create(v4, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 0.88
		}):Play()
		parent:SetAttribute("Open", false)
	end)
end

parent:GetAttributeChangedSignal("Open"):Connect(function()
	local open = parent:GetAttribute("Open") == true
	setOpen(open) -- equivalent call inferred; original call site unknown
end)
parent.DescendantAdded:Connect(function(baseScript)
	if v16 then
		return
	end

	local v21

	if baseScript == script then
		v21 = false
	else
		v21 = baseScript:IsA("BaseScript") and (v15[baseScript.Name] or baseScript:GetAttribute("ArtLoop") == true)
	end

	if v21 then
		baseScript.Enabled = false
	end
end)

for _, v21 in ipairs(v2) do
	v21.container.ChildRemoved:Connect(forgetCard)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function suspend()
	count2 += 1

	if v12 or not v11 then
		finishClose()
		return
	end

	stopTweens()
	stopIdle() -- equivalent call inferred; original call site unknown
	setSpriteRunning(false)
	snapOpenRest()
	flag = true
	v13 = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resume()
	flag = false
	count2 += 1
	local v21 = count2
	setSpriteRunning(true)
	startIdle(v21) -- equivalent call inferred; original call site unknown
	task.spawn(runLaserCycle, v21)
end

local function onShownChanged()
	if isShown() then
		if flag then
			resume() -- equivalent call inferred; original call site unknown
		end
	elseif v11 and not flag or v12 then
		suspend() -- equivalent call inferred; original call site unknown
	end
end

local function onMainVisibleChanged()
	if dRScrambleEventUIMain.Visible then
		if not (v11 or v12) then
			if v11 ~= true then
				playOpen()
			end

			parent:SetAttribute("Open", true)
		end
	elseif v11 or v12 then
		count2 += 1
		finishClose()
		parent:SetAttribute("Open", false)
	end
end

dRScrambleEventUIMain.Visible = false
setSpriteRunning(false)

for _, v21 in ipairs(v8) do
	applyFadeList(v21.fade, 1)
end

applyFadeList(v10, 1)

if parent:GetAttribute("Open") == true then
	playOpen()
elseif parent:GetAttribute("Open") == nil then
	parent:SetAttribute("Open", false)
end

parent:GetPropertyChangedSignal("Enabled"):Connect(onShownChanged)
parent.AncestryChanged:Connect(onShownChanged)
dRScrambleEventUIMain:GetPropertyChangedSignal("Visible"):Connect(onMainVisibleChanged)
parent.Destroying:Once(function()
	count2 += 1
	stopTweens()
	setSpriteRunning(false)
	table.clear(v18)
	table.clear(v17)
end)