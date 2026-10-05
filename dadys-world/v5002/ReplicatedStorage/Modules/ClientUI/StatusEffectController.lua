local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DebuffConfig = require(ReplicatedStorage.Modules.Gameplay.DebuffConfig)
local RadialProgress = require(ReplicatedStorage.Modules.UI.RadialProgress)
local tweenHelpers = require(ReplicatedStorage.Modules.Utils.tweenHelpers)
local StatusEffectController = {}

local function debugEnabled()
	local info = workspace:FindFirstChild("Info")
	return info ~= nil and info:GetAttribute("StatusHudDebug") == true
end

local fredokaOne = Enum.Font.FredokaOne
local v = {
	TEMPLATE_START_SCALE = 0.4,
	TEMPLATE_TIME = 0.35,
	REFILL_DIP_SCALE = 0.75,
	REFILL_DIP_TIME = 0.12,
	ICHOR_START_SCALE = 0.4,
	ICHOR_DELAY = 0.06,
	ICHOR_TIME = 0.55,
	SPLAT_START_SCALE = 0.2,
	SPLAT_BURST_TIME = 0.18,
	SPLAT_FADE_DELAY = 0.1,
	SPLAT_FADE_TIME = 0.9,
	SPLAT_ON_REFILL = false,
	ICHOR_ON_REFILL = false
}
v.SPLAT_COOLDOWN = v.SPLAT_BURST_TIME + v.SPLAT_FADE_DELAY + v.SPLAT_FADE_TIME
local back = Enum.EasingStyle.Back
local out = Enum.EasingDirection.Out
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut
local quad2 = Enum.EasingStyle.Quad
local out2 = Enum.EasingDirection.Out
local color = Color3.fromRGB(66, 204, 94)
local color2 = Color3.fromRGB(204, 73, 59)
local color3 = Color3.fromRGB(255, 255, 255)
local v2 = {}
local v3 = 0
local renderSteppedConnection = nil
local count = 0
local parent = nil
local v5 = nil
local callbacks = {}
local flag = false
local v6 = {}

local function debugLog(...)
	local info = workspace:FindFirstChild("Info")
	local v7

	if info == nil then
		v7 = false
	else
		v7 = info:GetAttribute("StatusHudDebug") == true
	end

	if v7 then
		print("[StatusEffectHud]", ...)
	end
end

local function invalidate()
	parent = nil
	v5 = nil

	for k in pairs(v2) do
		v2[k] = nil
	end

	v3 = 0

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	debugLog("Stats GUI went away - cleared all active effects")
end

local function resolveContainer()
	if parent and parent.Parent and v5 and v5.Parent then
		return true
	end

	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	local screenGui = playerGui:FindFirstChild("ScreenGui")

	if not screenGui then
		return false
	end

	local buffsFrame = screenGui:FindFirstChild("BuffsFrame")

	if not buffsFrame then
		warn(("[StatusEffectHud] %s has no %s"):format(screenGui:GetFullName(), "BuffsFrame"))
		return false
	end

	local template = buffsFrame:FindFirstChild("Template")

	if not template then
		warn(("[StatusEffectHud] %s has no %s"):format(buffsFrame:GetFullName(), "Template"))
		return false
	end

	template.Visible = false
	parent = buffsFrame
	v5 = template
	screenGui.Destroying:Once(invalidate)
	debugLog("resolved", buffsFrame:GetFullName())
	return true
end

local function notifyAvailable()
	local v7 = v6
	v6 = {}

	for k, v8 in pairs(v7) do
		StatusEffectController.show(k, v8)
	end

	for _, callback in ipairs(callbacks) do
		local success, result = pcall(callback)

		if not success then
			warn("[StatusEffectHud] onAvailable subscriber errored:", result)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchPlayerGui()
	if flag then
		return
	end

	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	flag = true
	playerGui.ChildAdded:Connect(function(child)
		if child.Name ~= "ScreenGui" then
			return
		end

		task.defer(function()
			if resolveContainer() then
				debugLog("Stats GUI came back - re-pushing active effects")
				notifyAvailable()
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function computePercent(p, now)
	if p.duration then
		return (math.clamp((1 - (now - p.startClock) / p.duration) * 100, 0, 100))
	end

	return 100
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyEntry(p, p2, p3)
	if p2.frame then
		p2.frame:Destroy()
	end

	v2[p] = nil
	v3 -= 1
	debugLog(("%s removed (%s)"):format(p, p3))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoopIfIdle()
	if v3 <= 0 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
		debugLog("no effects left - update loop stopped")
	end
end

local applyRainbow

local function step()
	local now = os.clock()

	for k, v7 in pairs(v2) do
		local percent = computePercent(v7, now) -- equivalent call inferred; original call site unknown
		RadialProgress.setPercent(v7.progressRing, percent - RadialProgress.PROGRESS_TRAIL)
		RadialProgress.setPercent(v7.outlineRing, percent - RadialProgress.OUTLINE_TRAIL)

		if v7.rainbow then
			applyRainbow(v7, now)
		end

		if not (v7.duration and percent <= 0) then
			continue
		end

		destroyEntry(k, v7, "expired") -- equivalent call inferred; original call site unknown
	end

	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLoop()
	if renderSteppedConnection then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(step)
	debugLog("update loop started")
end

local function backgroundColorFor(data)
	return Color3.new(
		math.clamp(data.R * 0.286 + 0.10980392156862745, 0, 1),
		math.clamp(data.G * 0.286 + 0.10980392156862745, 0, 1),
		(math.clamp(data.B * 0.286 + 0.10980392156862745, 0, 1))
	)
end

local function resolveDisplay(data, data2)
	local isBuff = data2.isBuff

	if isBuff == nil then
		if data == nil then
			isBuff = false
		else
			isBuff = data.isBuff == true
		end
	end

	local hideTier = data2.hideTier

	if hideTier == nil then
		if data == nil then
			hideTier = false
		else
			hideTier = data.hideStageNumeral == true
		end
	end

	local color4 = data2.color or data and data.color or color3
	local rainbow = data2.rainbow

	if rainbow == nil then
		if data == nil then
			rainbow = false
		else
			rainbow = data.rainbow == true
		end
	end

	return {
		icon = data2.icon or data and data.icon,
		color = color4,
		rainbow = rainbow,
		outlineColor = data2.outlineColor,
		backgroundColor = data2.backgroundColor or Color3.new(
			math.clamp(color4.R * 0.286 + 0.10980392156862745, 0, 1),
			math.clamp(color4.G * 0.286 + 0.10980392156862745, 0, 1),
			(math.clamp(color4.B * 0.286 + 0.10980392156862745, 0, 1))
		),
		isBuff = isBuff,
		hideTier = hideTier,
		halloween = data ~= nil and data.halloween == true
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cornerText(data, tier, p)
	if p and p > 1 then
		return "x" .. p
	end

	if data.hideTier then
		return ""
	end

	return (DebuffConfig.GetStageNumeral(tier))
end

local function applyVisuals(state, data, tier, p)
	RadialProgress.setTint(state.progressRing, data.color)

	if data.outlineColor then
		RadialProgress.setTint(state.outlineRing, data.outlineColor)
	end

	if state.background then
		state.background.ImageColor3 = data.backgroundColor
	end

	if state.icon and data.icon then
		state.icon.Image = data.icon
	end

	if state.halloweenGradient then
		state.halloweenGradient.Visible = data.halloween
	end

	local cornerText2 = cornerText(data, tier, p) -- equivalent call inferred; original call site unknown
	state.cornerText = cornerText2
	state.color = data.color

	if state.tierLabel then
		state.tierLabel.Text = state.cornerText
	end

	if state.arrow then
		state.arrow.Rotation = data.isBuff and 0 or 180
		state.arrow.ImageColor3 = data.isBuff and color or color2
	end

	if data.rainbow then
		local _, saturation, v9 = data.color:ToHSV()
		state.rainbow = {
			saturation = saturation,
			value = v9
		}
	else
		state.rainbow = nil
	end

	state.tier = tier
end

applyRainbow = function(data, now)
	local v7 = now / 3 % 1
	local color4 = Color3.fromHSV(v7, data.rainbow.saturation, data.rainbow.value)
	RadialProgress.setTint(data.progressRing, color4)

	if data.background then
		data.background.ImageColor3 = Color3.new(
			math.clamp(color4.R * 0.286 + 0.10980392156862745, 0, 1),
			math.clamp(color4.G * 0.286 + 0.10980392156862745, 0, 1),
			(math.clamp(color4.B * 0.286 + 0.10980392156862745, 0, 1))
		)
	end
end

local function collectSplats(clone)
	local images = {}
	local ichorSplats = clone:FindFirstChild("IchorSplats")

	if not ichorSplats then
		return images
	end

	for _, image in ipairs(ichorSplats:GetChildren()) do
		if image:IsA("ImageLabel") then
			table.insert(images, image)
		end
	end

	table.sort(images, function(a, b)
		return a.Name < b.Name
	end)
	return images
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newLayer()
	return {
		tweens = {},
		generation = 0
	}
end

local function beginLayer(state)
	for _, tween in ipairs(state.tweens) do
		local v7 = tween
		pcall(function()
			v7:Cancel()
		end)
	end

	table.clear(state.tweens)
	state.generation += 1
	return state.generation
end

local function trackTween(p, p2)
	table.insert(p.tweens, p2)
	return p2
end

local function playSplat(state)
	local splats = state.splats

	if #splats == 0 then
		return
	end

	local now = os.clock()

	if state.lastSplatClock and now - state.lastSplatClock < v.SPLAT_COOLDOWN then
		return
	end

	state.lastSplatClock = now
	local splatLayer = state.splatLayer
	local v7 = beginLayer(splatLayer)
	local v8 = math.random(1, #splats)

	for i, splat in ipairs(splats) do
		splat.Visible = i == v8
	end

	local splat = splats[v8]
	splat.Rotation = math.random(0, 359)
	splat.ImageTransparency = 0
	local uIScale = splat:FindFirstChildWhichIsA("UIScale")

	if uIScale then
		uIScale.Scale = v.SPLAT_START_SCALE
		local v9 = tweenHelpers.playTween(uIScale, TweenInfo.new(v.SPLAT_BURST_TIME, back, out), {
			Scale = 1
		})
		table.insert(splatLayer.tweens, v9)
	end

	task.delay(v.SPLAT_BURST_TIME + v.SPLAT_FADE_DELAY, function()
		if not (splatLayer.generation == v7 and splat.Parent) then
			return
		end

		local v10 = tweenHelpers.playTween(splat, TweenInfo.new(v.SPLAT_FADE_TIME, quad2, out2), {
			ImageTransparency = 1
		})
		table.insert(splatLayer.tweens, v10)
	end)
end

local function playEntrance(data, p)
	if data.scale then
		local templateLayer = data.templateLayer
		beginLayer(templateLayer)

		if p then
			data.scale.Scale = 1
			local v7 = tweenHelpers.playTween(data.scale, TweenInfo.new(v.REFILL_DIP_TIME, quad, inOut, 0, true), {
				Scale = v.REFILL_DIP_SCALE
			})
			table.insert(templateLayer.tweens, v7)
		else
			data.scale.Scale = v.TEMPLATE_START_SCALE
			local v7 = tweenHelpers.playTween(data.scale, TweenInfo.new(v.TEMPLATE_TIME, back, out), {
				Scale = 1
			})
			table.insert(templateLayer.tweens, v7)
		end
	end

	if data.ichorScale and (not p or v.ICHOR_ON_REFILL) then
		local ichorLayer = data.ichorLayer
		local v7 = beginLayer(ichorLayer)
		data.ichorScale.Scale = v.ICHOR_START_SCALE
		task.delay(v.ICHOR_DELAY, function()
			if not (ichorLayer.generation == v7 and data.ichorScale.Parent) then
				return
			end

			local v9 = tweenHelpers.playTween(data.ichorScale, TweenInfo.new(v.ICHOR_TIME, back, out), {
				Scale = 1
			})
			table.insert(ichorLayer.tweens, v9)
		end)
	end

	if not p or v.SPLAT_ON_REFILL then
		playSplat(data)
	end
end

local function findHalloweenGradient(clone, background_Ichor)
	for _, folder in ipairs({ background_Ichor, clone }) do
		if not folder then
			continue
		end

		for _, image in ipairs(folder:GetDescendants()) do
			if image.Name == "GradientBackground" and image:IsA("ImageLabel") then
				return image
			end
		end
	end

	warn(("[StatusEffectHud] no %s ImageLabel in the template - Halloween statuses render plain"):format("GradientBackground"))
	return nil
end

local function buildEntry(name, display, tier, stacks, layoutOrder)
	local clone = v5:Clone()
	clone.Name = name
	local progressRing = RadialProgress.bind(clone:FindFirstChild("Progress"))
	local outlineRing = RadialProgress.bind(clone:FindFirstChild("Outline"))

	if progressRing then
		local background_Ichor = clone:FindFirstChild("Background_Ichor")
		local textLabel = clone:FindFirstChild("TextLabel")

		if textLabel and textLabel:IsA("TextLabel") then
			textLabel.Font = fredokaOne
		end

		local v9 = {
			frame = clone,
			progressRing = progressRing,
			outlineRing = outlineRing,
			background = clone:FindFirstChild("StatBackground"),
			icon = clone:FindFirstChild("StatIcon"),
			halloweenGradient = findHalloweenGradient(clone, background_Ichor),
			tierLabel = textLabel,
			arrow = clone:FindFirstChild("StatArrow"),
			scale = clone:FindFirstChildWhichIsA("UIScale"),
			ichorScale = background_Ichor and background_Ichor:FindFirstChildWhichIsA("UIScale"),
			splats = collectSplats(clone),
			templateLayer = newLayer(),
			ichorLayer = newLayer(),
			splatLayer = newLayer()
		}
		applyVisuals(v9, display, tier, stacks)
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		playEntrance(v9, false)
		clone.Parent = parent
		return v9
	else
		warn(("[StatusEffectHud] %s has no usable %s ring - not rendering %s"):format("Template", "Progress", name))
		clone:Destroy()
		return nil
	end
end

local function normalizeDuration(value)
	if type(value) ~= "number" or value ~= value or (value <= 0 or value == 1e999) then
		return nil
	end

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setClock(p, duration, totalDuration)
	if type(totalDuration) == "number" and totalDuration == totalDuration then
		if totalDuration <= 0 or totalDuration == 1e999 then
			totalDuration = nil
		end
	else
		totalDuration = nil
	end

	if duration and totalDuration and duration < totalDuration then
		p.duration = totalDuration
		p.startClock = os.clock() - (totalDuration - duration)
	else
		p.duration = duration
		p.startClock = os.clock()
	end
end

function StatusEffectController.init()
	if not RunService:IsClient() then
		warn("[StatusEffectHud] init() is client-only")
		return false
	end

	watchPlayerGui() -- equivalent call inferred; original call site unknown

	if resolveContainer() then
		return true
	end

	task.spawn(function()
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:WaitForChild("PlayerGui", 30)

		if not playerGui then
			return
		end

		watchPlayerGui() -- equivalent call inferred; original call site unknown

		if not playerGui:WaitForChild("ScreenGui", 30) then
			warn(("[StatusEffectHud] no %s ScreenGui in PlayerGui after 30s"):format("ScreenGui"))
		elseif resolveContainer() then
			notifyAvailable()
		end
	end)
	return false
end

function StatusEffectController.onAvailable(callback)
	if type(callback) == "function" then
		table.insert(callbacks, callback)
	else
		warn("[StatusEffectHud] onAvailable() needs a function")
	end
end

function StatusEffectController.show(name, options)
	if type(name) ~= "string" or name == "" then
		warn("[StatusEffectHud] show() needs an effect name")
		return nil
	end

	local v7 = options or {}
	local display = resolveDisplay(DebuffConfig.Get(name), v7)
	local duration = v7.duration

	if type(duration) == "number" and duration == duration then
		if duration <= 0 or duration == 1e999 then
			duration = nil
		end
	else
		duration = nil
	end

	local tier = v7.tier or 1
	local v9 = v2[name]

	if v9 and not v9.frame.Parent then
		v2[name] = nil
		v3 -= 1
		v9 = nil
	end

	if v9 then
		applyVisuals(v9, display, tier, v7.stacks)
		setClock(v9, duration, v7.totalDuration) -- equivalent call inferred; original call site unknown
		playEntrance(v9, true)
		debugLog(("%s refilled (%s, tier %s)"):format(
			name,
			duration and ("%.1fs"):format(duration) or "infinite",
			(tostring(tier))
		))
		return v9
	elseif resolveContainer() then
		local entry = buildEntry(name, display, tier, v7.stacks, v7.layoutOrder or count)

		if not entry then
			return nil
		end

		count += 1
		setClock(entry, duration, v7.totalDuration) -- equivalent call inferred; original call site unknown
		v2[name] = entry
		v3 += 1
		RadialProgress.setPercent(entry.progressRing, 100 - RadialProgress.PROGRESS_TRAIL)
		RadialProgress.setPercent(entry.outlineRing, 100 - RadialProgress.OUTLINE_TRAIL)
		startLoop() -- equivalent call inferred; original call site unknown
		debugLog(("%s shown (%s, tier %s)"):format(
			name,
			duration and ("%.1fs"):format(duration) or "infinite",
			(tostring(tier))
		))
		return entry
	else
		v6[name] = v7
		warn(("[StatusEffectHud] cannot show %s - Stats GUI not available (queued)"):format(name))
		return nil
	end
end

function StatusEffectController.hide(p)
	v6[p] = nil
	local v7 = v2[p]

	if not v7 then
		return false
	end

	destroyEntry(p, v7, "hidden") -- equivalent call inferred; original call site unknown
	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
	return true
end

function StatusEffectController.clear()
	table.clear(v6)

	for k, v7 in pairs(v2) do
		destroyEntry(k, v7, "cleared") -- equivalent call inferred; original call site unknown
	end

	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
end

function StatusEffectController.isActive(p)
	return v2[p] ~= nil
end

function StatusEffectController.getRemaining(p)
	local v7 = v2[p]

	if v7 and v7.duration then
		return (math.max(0, v7.duration - (os.clock() - v7.startClock)))
	end

	return nil
end

function StatusEffectController.getActiveRings()
	local now = os.clock()
	local result = {}

	for k, v7 in pairs(v2) do
		if not v7.frame.Parent then
			continue
		end

		local v8 = {
			name = k,
			frame = v7.frame,
			tier = v7.tier,
			cornerText = v7.cornerText or "",
			color = v7.color or color3,
			plateColor = 0,
			remaining = 0
		}
		local color4 = v7.color or color3
		v8.plateColor = Color3.new(
			math.clamp(color4.R * 0.286 + 0.10980392156862745, 0, 1),
			math.clamp(color4.G * 0.286 + 0.10980392156862745, 0, 1),
			(math.clamp(color4.B * 0.286 + 0.10980392156862745, 0, 1))
		)
		local remaining

		if v7.duration then
			remaining = math.max(0, v7.duration - (now - v7.startClock)) or nil
		end

		v8.remaining = remaining
		table.insert(result, v8)
	end

	return result
end

return StatusEffectController