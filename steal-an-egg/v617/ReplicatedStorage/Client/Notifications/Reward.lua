local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local GUI = require(ReplicatedStorage.Client.GUI)
local Lanes = require(script.Parent.Lanes)
local NotificationItem = require(ReplicatedStorage.Shared.NotificationItem)
local NotificationItemCard = require(ReplicatedStorage.Client.UI.NotificationItemCard)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local assets = ReplicatedStorage:WaitForChild("Assets")
local layout2 = {
	Bloom = "Bloom",
	Card = assets.UI.Notifs.MainItem,
	Halo = "Halo",
	HolderPath = { "Frame", "CardSlot" },
	Placeholder = "Placeholder",
	Portrait = "coreImage",
	Slot = assets.UI.Notifs.MainItem.Slot
}
local newItem = assets.UI.Items.NewItem
local v2 = {
	{
		Rank = Rarity.Rarities.Cosmic.Rank,
		Sound = "rbxassetid://73352992887992"
	},
	{
		Gain = 1.6,
		Rank = -1e999,
		Sound = "rbxassetid://103957546380416"
	}
}
local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(1.05, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(1.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo5 = TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 1)
local v3 = {
	CanvasGroup = { "BackgroundTransparency", "GroupTransparency" },
	Frame = { "BackgroundTransparency" },
	ImageButton = { "BackgroundTransparency", "ImageTransparency" },
	ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
	TextButton = { "BackgroundTransparency", "TextStrokeTransparency", "TextTransparency" },
	TextLabel = { "BackgroundTransparency", "TextStrokeTransparency", "TextTransparency" },
	UIStroke = { "Transparency" }
}

local function isFlag(p)
	return typeof(p) == "boolean"
end

local function isLabel(value)
	return typeof(value) == "string" and value ~= ""
end

local function isSpan(value)
	return typeof(value) == "number" and value > 0 and value < 1e999
end

local function anyRaised(p, p2)
	return p == true or p2 == true
end

local function firstNamed(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local function soonest(p, p2)
	if p == nil then
		return p2
	end

	return (math.min(p, p2))
end

local v4 = {
	{
		accepts = isFlag,
		fold = anyRaised,
		key = "DelayInRound"
	},
	{
		accepts = isSpan,
		fold = soonest,
		key = "Seconds"
	},
	{
		accepts = isLabel,
		fold = firstNamed,
		key = "UniqueKey"
	}
}
local v5 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function cueFor(p)
	for _, v6 in v2 do
		if p.Rank >= v6.Rank then
			return v6
		end
	end

	return v2[#v2]
end

local function playCue(p)
	local now = os.clock()

	if now < v5 then
		return
	end

	v5 = now + 0.2
	local v6 = cueFor(p) -- equivalent call inferred; original call site unknown
	Audio.Play(v6.Sound, script, v6.Gain and {
		Volume = v6.Gain
	} or nil)
end

local function descend(clone, holderPath)
	for _, childName in holderPath do
		clone = assert(clone:FindFirstChild(childName), (`reward card template lacks {childName}`))
	end

	return clone
end

local function paintTier(p, p2)
	SwapGradient(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function headline(p: number)
	if p > 1 then
		return "Rewards claimed!"
	end

	return "Reward claimed!"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cardOptions(p)
	return {
		ShowCount = p.Kind == "Currency" or p.Amount > 1,
		Sparkle = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mountSquare(parent, parent2)
	parent.Size = UDim2.fromScale(1, 1)
	parent.Parent = parent2
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = parent
end

local collectFades

collectFades = function(instance, p, list)
	if instance == p or instance:IsA("GuiObject") and not instance.Visible or instance:IsA("UIStroke") and not instance.Enabled then
		return
	end

	local v6 = v3[instance.ClassName]

	if v6 then
		for _, property in v6 do
			local resting = instance[property]

			if resting < 1 then
				table.insert(list, {
					instance = instance,
					property = property,
					resting = resting
				})
			end
		end
	end

	if instance:IsA("CanvasGroup") then
		return
	end

	for _, child in instance:GetChildren() do
		collectFades(child, p, list)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function conceal(clone, size: UDim2, items, child)
	clone.Size = size:Lerp(UDim2.new(), 0.44999999999999996)

	for _, item in items do
		item.instance[item.property] = 1
	end

	if child then
		child.ImageTransparency = 1
	end
end

local function reveal(clone, size: UDim2, items)
	TweenService:Create(clone, tweenInfo, {
		Size = size
	}):Play()

	for _, item in items do
		local instance = item.instance
		local restingsByProperty = {
			[item.property] = item.resting
		}
		TweenService:Create(instance, tweenInfo2, restingsByProperty):Play()
	end
end

local function bloomOut(child, imageTransparency: number)
	child.ImageTransparency = imageTransparency
	TweenService:Create(child, tweenInfo4, {
		ImageTransparency = 1
	}):Play()
	local uIScale = child:FindFirstChildOfClass("UIScale")

	if uIScale then
		uIScale.Scale = 0.4
		TweenService:Create(uIScale, tweenInfo3, {
			Scale = 1.45
		}):Play()
	end
end

local function pulseRing(parent, color: Color3)
	local uIStroke = parent:FindFirstChildOfClass("UIStroke")
	local v6 = uIStroke or Instance.new("UIStroke")
	local v7 = {
		Color = v6.Color,
		Enabled = v6.Enabled,
		Thickness = v6.Thickness,
		Transparency = v6.Transparency
	}
	local thickness = math.max(v6.Thickness, 3) * 2.5
	v6.Color = color
	v6.Enabled = true
	v6.Thickness = 0
	v6.Transparency = 0.1
	v6.Parent = parent
	local tween = TweenService:Create(v6, tweenInfo5, {
		Thickness = thickness,
		Transparency = 1
	})
	tween.Completed:Once(function()
		if uIStroke == nil then
			v6:Destroy()
			return
		end

		v6.Color = v7.Color
		v6.Enabled = v7.Enabled
		v6.Thickness = v7.Thickness
		v6.Transparency = v7.Transparency
	end)
	tween:Play()
end

local function createSlot(data, item)
	local rarity = NotificationItem.Describe(item).Rarity
	local rarityGradient = rarity.RarityGradient
	local clone = data.Slot:Clone()
	local parent = descend(clone, data.HolderPath)
	local child = clone:FindFirstChild(data.Bloom)
	local child2 = parent:FindFirstChild(data.Placeholder)

	if child2 then
		child2:Destroy()
	end

	SwapGradient(parent, rarityGradient)

	for _, childName in { data.Halo, data.Portrait } do
		local child3 = parent:FindFirstChild(childName)

		if child3 then
			SwapGradient(child3, rarityGradient)
		end
	end

	local textLabel = clone:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		local clone_2 = newItem:Clone()
		clone_2.Parent = textLabel
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.Text = headline(item.Amount)
	end

	mountSquare(NotificationItemCard.Build(item, cardOptions(item)), parent) -- equivalent call inferred; original call site unknown
	local v8 = {}
	collectFades(clone, child, v8)
	local size = clone.Size
	local imageTransparency = not child and 1 or child.ImageTransparency
	conceal(clone, size, v8, child) -- equivalent call inferred; original call site unknown
	return {
		frame = clone,
		play = function()
			reveal(clone, size, v8)

			if child then
				bloomOut(child, imageTransparency)
			end

			pulseRing(parent, rarity.Color)
		end,
		rarity = rarity
	}
end

local function laneArea()
	local notifications = GUI.Get("Notifications")
	local feed

	if notifications then
		feed = notifications:FindFirstChild("Feed")
	end

	if feed and feed:IsA("GuiObject") then
		return feed.AbsoluteSize
	end

	return nil
end

local function slotCapacity(layout)
	local notifications = GUI.Get("Notifications")
	local feed

	if notifications then
		feed = notifications:FindFirstChild("Feed")
	end

	local absoluteSize

	if feed and feed:IsA("GuiObject") then
		absoluteSize = feed.AbsoluteSize
	end

	if absoluteSize == nil then
		return 6
	end

	local size = layout.Card.Size
	local v6 = absoluteSize.X * size.X.Scale + size.X.Offset
	local v7 = absoluteSize.Y * size.Y.Scale + size.Y.Offset
	local uIListLayout = layout.Card:FindFirstChildOfClass("UIListLayout")
	local v8 = not uIListLayout and 0 or uIListLayout.Padding.Scale * v6 + uIListLayout.Padding.Offset
	local uIAspectRatioConstraint = layout.Slot:FindFirstChildOfClass("UIAspectRatioConstraint")
	local v9 = math.min(v6, v7 * (not uIAspectRatioConstraint and 1 or uIAspectRatioConstraint.AspectRatio))

	if v9 <= 0 then
		return 1
	end

	return (math.clamp(math.floor((v6 + v8) / (v9 + v8)), 1, 6))
end

local function liveCards(p)
	local now = os.clock()
	local cards = {}

	for _, card in p.cards do
		local shownAt = card.shownAt
		local v6

		if shownAt == nil then
			v6 = now - card.queuedAt >= 12
		else
			v6 = now - shownAt > card.lifetime + 2
		end

		if not (card.closed or v6) then
			table.insert(cards, card)
		end
	end

	p.cards = cards
	return cards
end

local function openCard(p)
	local v6 = liveCards(p)
	local v7 = v6[#v6]

	if v7 == nil or v7.filled >= v7.capacity then
		return nil
	end

	local shownAt = v7.shownAt

	if shownAt == nil or v7.lifetime - (os.clock() - shownAt) >= 1.3 then
		return v7
	end

	return nil
end

local function placeSlot(state, data)
	state.filled += 1
	data.frame.LayoutOrder = state.filled
	data.frame.Parent = state.frame

	if state.shownAt == nil then
		table.insert(state.deferredPlays, data.play)
		local loudest = state.loudest

		if loudest == nil or data.rarity.Rank > loudest.Rank then
			state.loudest = data.rarity
		end
	else
		playCue(data.rarity)
		data.play()
	end
end

local function resolvePolicy(items)
	local result = {}

	for _, item in items do
		for _, hint in item.hints do
			for _, v6 in v4 do
				local v7 = hint[v6.key]

				if v6.accepts(v7) then
					result[v6.key] = v6.fold(result[v6.key], v7)
				end
			end
		end
	end

	if result.Seconds == nil then
		result.Seconds = 3.4
	end

	return result
end

local function buildCard(state, items, capacity: number)
	local policy = resolvePolicy(items)
	local clone = state.layout.Card:Clone()

	for _, guiObject in clone:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v6 = {
		capacity = capacity,
		closed = false,
		deferredPlays = {},
		filled = 0,
		frame = clone,
		lifetime = policy.Seconds or 3.4,
		loudest = nil,
		queuedAt = os.clock(),
		shownAt = nil
	}
	clone.Destroying:Once(function()
		v6.closed = true
	end)
	table.insert(state.cards, v6)

	for _, item in items do
		placeSlot(v6, createSlot(state.layout, item.item))
	end

	Lanes.Schedule({
		Lane = "Feed",
		Frame = clone,
		Seconds = policy.Seconds,
		UniqueKey = policy.UniqueKey,
		DelayInRound = policy.DelayInRound,
		OnShown = function()
			v6.shownAt = os.clock()
			local loudest = v6.loudest

			if loudest then
				playCue(loudest)
			end

			local deferredPlays = v6.deferredPlays
			v6.deferredPlays = {}

			for k, deferredPlay in deferredPlays do
				if k > 1 then
					task.wait(0.07)
				end

				if v6.closed then
					break
				else
					deferredPlay()
				end
			end
		end
	})
end

local function flush(state)
	state.flushScheduled = false
	local capacity = slotCapacity(state.layout)

	while #state.inbox > 0 do
		local v7 = math.min(capacity, #state.inbox)
		local v8 = table.move(state.inbox, 1, v7, 1, {})
		state.inbox = table.move(state.inbox, v7 + 1, #state.inbox, 1, {})
		buildCard(state, v8, capacity)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stackKey(data)
	return (`{data.Kind}/{data.Id or ""}/{data.Mutation or ""}`)
end

local function stage(state, item, p)
	local stack = stackKey(item) -- equivalent call inferred; original call site unknown

	for _, v7 in state.inbox do
		if v7.stack ~= stack then
			continue
		end

		local clone = table.clone(v7.item)
		clone.Amount += item.Amount
		v7.item = clone

		if p then
			table.insert(v7.hints, p)
		end

		return
	end

	if #state.inbox >= 18 then
		return
	end

	table.insert(state.inbox, {
		hints = p and { p } or {},
		item = item,
		stack = stack
	})

	if not state.flushScheduled then
		state.flushScheduled = true
		task.delay(0.12, flush, state)
	end
end

local function acceptItem(p)
	local item

	if typeof(p) == "table" then
		item = p.Item
	end

	local schema, v6 = NotificationItem.Schema(item)
	assert(schema, (`reward notification rejected: {v6 or "malformed payload"}`))
	return item
end

local function hintFrom(p)
	local result = {}
	local flag = false

	for _, v6 in v4 do
		local v7 = p[v6.key]

		if v7 == nil then
			continue
		end

		result[v6.key] = v7
		flag = true
	end

	if flag then
		return result
	end

	return nil
end

local function createChannel(layout)
	local v6 = {
		cards = {},
		flushScheduled = false,
		inbox = {},
		layout = layout
	}
	return {
		Show = function(p2)
			local item

			if typeof(p2) == "table" then
				item = p2.Item
			end

			local schema, v7 = NotificationItem.Schema(item)
			assert(schema, (`reward notification rejected: {v7 or "malformed payload"}`))
			local v8 = liveCards(v6)
			local v9 = v8[#v8]

			if v9 == nil or v9.filled >= v9.capacity then
				v9 = nil
			else
				local shownAt = v9.shownAt

				if shownAt ~= nil and not (v9.lifetime - (os.clock() - shownAt) >= 1.3) then
					v9 = nil
				end
			end

			if v9 then
				placeSlot(v9, createSlot(layout, item))
			else
				stage(v6, item, hintFrom(p2))
			end
		end
	}
end

return {
	Show = createChannel(layout2).Show,
	CreateChannel = function(p)
		return (createChannel(p or layout2))
	end
}