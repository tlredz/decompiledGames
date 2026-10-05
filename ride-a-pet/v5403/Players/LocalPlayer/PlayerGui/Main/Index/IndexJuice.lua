local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local enthusiasticArrive = BitohiUI.EnthusiasticArrive
local fade = BitohiUI.Fade
local UIIdle = require(ReplicatedStorage:WaitForChild("UIIdle"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local parent = script.Parent
local header = parent:WaitForChild("Header")
local toggles = parent:WaitForChild("Toggles")
local close = parent:WaitForChild("Close")
local petProgress = parent:WaitForChild("PetProgress")
local holders = parent:WaitForChild("Holders")
local poseTune = { 0.5, 3.6 }
local _ = {
	Header = 0.07,
	Tabs = 0.12,
	Close = 0.16,
	Progress = 0.2,
	Cards = 0.14,
	TabStep = 0.05,
	CardStep = 0.028,
	CardsMax = 0.4
}
local v2 = {
	Step = 0.005,
	MaxTotal = 0.06,
	ScaleTo = 0.3,
	Spin = 8,
	Pull = 0,
	Wind = 0.03,
	OutTuning = { 1, 11 }
}
local clone = table.clone(v2)
clone.Fade = false

local function isUnder(instance, ancestor)
	return instance == ancestor or instance:IsDescendantOf(ancestor)
end

local v3 = {
	header,
	toggles,
	close,
	petProgress,
	holders
}

local function skip(instance)
	for _, ancestor in ipairs(v3) do
		if instance == ancestor or instance:IsDescendantOf(ancestor) then
			return true
		end
	end

	return false
end

local scrollingFrames = {}
local v4 = {
	Header = {
		S = 0.45,
		R = 18,
		Y = -0.14,
		Tune = "Card",
		PoseTune = poseTune
	},
	Column = {
		X = -0.06
	},
	Tab = {
		R = -24,
		PoseTune = poseTune
	},
	Close = {
		S = 0,
		R = -220,
		Tune = "Card",
		PoseTune = { 0.55, 4.2 }
	},
	Progress = {
		S = 0.6,
		R = -6,
		Y = 0.06,
		Tune = "Card",
		PoseTune = poseTune
	},
	Cell = {
		S = 0,
		R = -12,
		Tune = "Card",
		PoseTune = { 0.55, 4 }
	}
}
local v5 = {
	Step = 0.01,
	MaxTotal = 0.05,
	ScaleTo = 0.4,
	Spin = 6,
	Pull = 0.15,
	Wind = 0.03,
	OutTuning = { 1, 11 }
}

for _, scrollingFrame in ipairs(holders:GetChildren()) do
	if not scrollingFrame:IsA("ScrollingFrame") then
		continue
	end

	table.insert(scrollingFrames, scrollingFrame)
	local v6 = scrollingFrame
	fade.group(scrollingFrame, {
		Skip = function(p)
			return p ~= v6
		end
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openPage()
	for _, v6 in ipairs(scrollingFrames) do
		if v6.Parent and v6.Visible then
			return v6
		end
	end

	return nil
end

local function cardsOf(instance)
	local guiObjects = {}

	if not instance then
		return guiObjects
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			table.insert(guiObjects, guiObject)
		end
	end

	return guiObjects
end

local function onScreen(p, list)
	local Y = p.AbsolutePosition.Y
	local v6 = Y + p.AbsoluteSize.Y
	local result = {}
	local result2 = {}

	for _, v7 in ipairs(list) do
		local Y2 = v7.AbsolutePosition.Y

		if Y2 < v6 and Y < Y2 + v7.AbsoluteSize.Y then
			table.insert(result, v7)
		else
			table.insert(result2, v7)
		end
	end

	return result, result2
end

local function tabsOf()
	local buttons = {}

	for _, button in ipairs(toggles:GetChildren()) do
		if button:IsA("GuiButton") and button.Visible then
			table.insert(buttons, button)
		end
	end

	table.sort(buttons, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	return buttons
end

local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelRuns()
	for i = #v6, 1, -1 do
		v6[i]:Cancel()
		v6[i] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function park(p, i)
	v7[p] = true
	enthusiasticArrive.set(p, v4.Cell, {
		Flip = i % 2 == 0
	})
end

local function popPage(p, p2)
	if not p then
		return
	end

	local v11 = onScreen(p, cardsOf(p))

	if UIQuality.low() and #v11 > 8 then
		table.sort(v11, function(a, b)
			local absolutePosition = a.AbsolutePosition
			local absolutePosition2 = b.AbsolutePosition

			if absolutePosition.Y < absolutePosition2.Y then
				return true
			elseif absolutePosition.Y == absolutePosition2.Y then
				return absolutePosition.X < absolutePosition2.X
			else
				return false
			end
		end)

		for i = #v11, 9, -1 do
			v11[i] = nil
		end
	end

	for i, v12 in ipairs(v11) do
		park(v12, i) -- equivalent call inferred; original call site unknown
	end

	local v12 = {
		Cancel = function(self)
			self.dead = true
		end
	}
	table.insert(v6, v12)
	task.delay(math.max(p2, 0.016666666666666666), function()
		if v12.dead or not p.Visible then
			return
		end

		table.insert(v6, enthusiasticArrive.cascade(v11, v4.Cell, {
			Step = 0.028,
			MaxTotal = 0.4,
			Order = "Grid"
		}))
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectPages()
	for i = #v10, 1, -1 do
		v10[i]:Disconnect()
		v10[i] = nil
	end
end

local function connectPages()
	if #v10 > 0 then
		return
	end

	for _, v11 in ipairs(scrollingFrames) do
		local v12 = v11
		table.insert(v10, v11:GetPropertyChangedSignal("Visible"):Connect(function()
			if v12.Visible and UIController.isOpen(parent) then
				popPage(v12, 0)
			end
		end))
	end
end

local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function idleLater()
	count += 1
	local v11 = count
	task.delay(0.7, function()
		if v11 == count and parent.Visible then
			UIIdle.start(parent)
		end
	end)
end

local function onOpen(p)
	cancelRuns() -- equivalent call inferred; original call site unknown
	UIIdle.stop(parent, not p)
	idleLater() -- equivalent call inferred; original call site unknown
	connectPages()

	if p then
		local items = tabsOf()
		local v12 = {
			{
				Obj = header,
				Pose = v4.Header,
				At = 0.07
			},
			{
				Obj = toggles,
				Pose = v4.Column,
				At = 0.12,
				Fade = false
			},
			{
				Items = items,
				Pose = v4.Tab,
				At = 0.12,
				Step = 0.05
			},
			{
				Obj = close,
				Pose = v4.Close,
				At = 0.16
			}
		}
		table.clear(v8)
		table.clear(v9)
		table.insert(v8, header)
		v9[header] = v4.Header
		table.insert(v8, close)
		v9[close] = v4.Close

		for i, v13 in ipairs(items) do
			table.insert(v8, v13)
			v9[v13] = v4.Tab
			enthusiasticArrive.set(v13, v4.Tab, {
				Flip = i % 2 == 0
			})
		end

		if petProgress.Visible then
			table.insert(v12, {
				Obj = petProgress,
				Pose = v4.Progress,
				At = 0.2
			})
			table.insert(v8, petProgress)
			v9[petProgress] = v4.Progress
		end

		for _, v13 in ipairs(scrollingFrames) do
			fade.group(v13):Apply(1)
		end

		for _, v13 in ipairs(scrollingFrames) do
			fade.group(v13):Spring(0, "OpenFade")
		end

		table.insert(v6, enthusiasticArrive.timeline(v12))
		local page = openPage() -- equivalent call inferred; original call site unknown
		popPage(page, 0.14)
	else
		for _, v11 in ipairs(v8) do
			if v11.Parent then
				enthusiasticArrive.play(v11, v9[v11], {
					Reset = false
				})
			end
		end

		enthusiasticArrive.play(toggles, v4.Column, {
			Reset = false,
			Fade = false
		})

		for _, v11 in ipairs(scrollingFrames) do
			fade.group(v11):Spring(0, "OpenFade")
		end

		for k in pairs(v7) do
			if k.Parent then
				enthusiasticArrive.play(k, v4.Cell, {
					Reset = false
				})
			end
		end
	end
end

local function onClose()
	cancelRuns() -- equivalent call inferred; original call site unknown
	count += 1
	UIIdle.stop(parent, true)
	local page = openPage() -- equivalent call inferred; original call site unknown
	local v12 = {}
	local v13 = {}

	if page then
		local low = UIQuality.low()

		for _, v14 in ipairs((onScreen(page, cardsOf(page)))) do
			if low and not fade.has(v14) then
				table.insert(v13, v14)
			else
				table.insert(v12, v14)
			end

			v7[v14] = true
		end
	end

	table.insert(v6, enthusiasticArrive.out(v12, v2))

	if #v13 > 0 then
		table.insert(v6, enthusiasticArrive.out(v13, clone))
	end

	local v14 = {}

	for _, v15 in ipairs(v8) do
		if v15.Parent and v15.Visible then
			table.insert(v14, v15)
		end
	end

	table.insert(v6, enthusiasticArrive.out(v14, v5))

	for _, v15 in ipairs(scrollingFrames) do
		fade.group(v15):Spring(1, "CloseFade")
	end
end

local function onHidden()
	cancelRuns() -- equivalent call inferred; original call site unknown
	count += 1
	UIIdle.stop(parent)
	disconnectPages() -- equivalent call inferred; original call site unknown
	enthusiasticArrive.reset(v8)
	enthusiasticArrive.reset({ toggles })
	local v11 = {}

	for k in pairs(v7) do
		if k.Parent then
			table.insert(v11, k)
		end
	end

	enthusiasticArrive.reset(v11)
	table.clear(v7)

	for _, v12 in ipairs(scrollingFrames) do
		fade.group(v12):Apply(0)
	end
end

enthusiasticArrive.mark({
	header,
	toggles,
	close,
	petProgress
})

local function warm()
	if parent.Visible then
		return
	end

	local v11 = {
		header,
		close,
		petProgress,
		toggles
	}
	enthusiasticArrive.set(header, v4.Header)
	enthusiasticArrive.set(close, v4.Close)
	enthusiasticArrive.set(petProgress, v4.Progress)
	enthusiasticArrive.set(toggles, v4.Column, {
		Fade = false
	})

	for _, v12 in ipairs((tabsOf())) do
		enthusiasticArrive.set(v12, v4.Tab)
		table.insert(v11, v12)
	end

	enthusiasticArrive.reset(v11)
end

UIController.decorate(parent, {
	Skip = skip,
	Warm = warm,
	CloseLead = 0.1,
	Open = onOpen,
	Close = onClose,
	Hidden = onHidden
})