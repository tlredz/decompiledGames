local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GUI = require(ReplicatedStorage.Client.GUI)
local RoundDeferral = require(script.Parent.RoundDeferral)
local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local notifications = GUI.Notifications()
local v = {
	Banner = true
}
local v2 = {}
local v3 = {}

for k, childName in {
	Feed = "Feed",
	Banner = "Banner"
} do
	v2[k] = {
		id = k,
		holder = notifications:WaitForChild(childName),
		guarded = v[k] == true,
		waiting = {},
		live = {},
		lastAdmit = -1e999,
		issued = 0,
		wakeToken = 0,
		pumpPending = false
	}
end

local v4 = {}
local v5 = 0
local v6 = 0
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function asGroup(canvasGroup)
	if canvasGroup:IsA("CanvasGroup") then
		return canvasGroup
	end

	return nil
end

local function expectKind(p, p2: string, p3: string)
	if p ~= nil and typeof(p) ~= p2 then
		error(`notification entry field {p3} expects a {p2}, got {typeof(p)}`, 3)
	end
end

local function claimKey(p: string?)
	if p == nil then
		return true
	end

	if v4[p] then
		return false
	end

	v4[p] = true
	return true
end

local function releaseKey(p: string?)
	if p ~= nil then
		v4[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropFrom(list, state)
	local index = table.find(list, state)

	if index ~= nil then
		table.remove(list, index)
	end
end

local v7 = {}
local renderSteppedConnection = nil

local function integrate(state, p: number)
	local v8 = -227.3956854010988 * (state.value - 1) - 18.698759474166447 * state.velocity
	state.velocity += v8 * p
	state.value += state.velocity * p
	return math.abs(state.value - 1) < 0.002 and math.abs(state.velocity) < 0.02
end

local function stepSprings(p: number)
	local v8 = math.min(p, 0.03333333333333333)
	local v9 = {}

	for _, v10 in v7 do
		local scale = v10.scale

		if scale.Parent == nil then
			continue
		end

		local v11 = -227.3956854010988 * (v10.value - 1) - 18.698759474166447 * v10.velocity
		v10.velocity += v11 * v8
		v10.value += v10.velocity * v8
		local v12

		if math.abs(v10.value - 1) < 0.002 then
			v12 = math.abs(v10.velocity) < 0.02
		else
			v12 = false
		end

		if v12 then
			scale.Scale = 1
		else
			scale.Scale = v10.value
			table.insert(v9, v10)
		end
	end

	v7 = v9

	if #v7 == 0 and renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function launchSpring(uIScale)
	uIScale.Scale = 0.55
	table.insert(v7, {
		scale = uIScale,
		value = 0.55,
		velocity = 0
	})

	if renderSteppedConnection == nil then
		renderSteppedConnection = RunService.RenderStepped:Connect(stepSprings)
	end
end

local function abandonSpring(uIScale)
	for k, v8 in v7 do
		if v8.scale ~= uIScale then
			continue
		end

		table.remove(v7, k)
		break
	end
end

local function finalize(state)
	local v8 = v2[state.laneId]
	dropFrom(v8.waiting, state) -- equivalent call inferred; original call site unknown
	dropFrom(v8.live, state) -- equivalent call inferred; original call site unknown
	local uniqueKey = state.uniqueKey

	if uniqueKey ~= nil then
		v4[uniqueKey] = nil
	end

	if state.shownAt ~= nil then
		if state.pinned then
			v6 = os.clock() + 0.8
			task.delay(0.8, function()
				for _, v9 in v2 do
					fn(v9)
				end
			end)
		end

		local onRetired = state.onRetired

		if onRetired ~= nil then
			task.spawn(onRetired, state.frame)
		end
	end

	if not state.destroyed then
		state.destroyed = true
		state.frame:Destroy()
	end

	fn(v8)
end

local function retire(state)
	if state.retiring then
		return
	end

	state.retiring = true
	state.expiryToken += 1
	local frame = state.frame
	local uIScale = frame:FindFirstChildOfClass("UIScale")

	if uIScale ~= nil then
		abandonSpring(uIScale)
		TweenService:Create(uIScale, tweenInfo2, {
			Scale = 0.7
		}):Play()
	end

	if not frame:IsA("CanvasGroup") then
		frame = nil
	end

	if frame ~= nil then
		TweenService:Create(frame, tweenInfo3, {
			GroupTransparency = 1
		}):Play()
	end

	task.delay(0.28, finalize, state)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armExpiry(state)
	state.expiryToken += 1
	local expiryToken = state.expiryToken
	task.delay(state.seconds, function()
		if expiryToken == state.expiryToken and state.shownAt ~= nil and not state.retiring then
			retire(state)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchFrame(state)
	state.frame.Destroying:Connect(function()
		state.destroyed = true

		if state.retiring then
			return
		end

		state.retiring = true
		state.expiryToken += 1
		task.defer(finalize, state)
	end)
end

local function admit(state, state2)
	local now = os.clock()
	state.lastAdmit = now
	state.issued += 1
	state2.shownAt = now
	table.insert(state.live, state2)
	local frame = state2.frame
	local group = asGroup(frame) -- equivalent call inferred; original call site unknown
	local groupTransparency = group == nil and 0 or group.GroupTransparency

	if group ~= nil then
		group.GroupTransparency = 1
	end

	local uIScale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Scale = 0.55
	uIScale.Parent = frame
	local layoutOrder

	if state2.pinned then
		layoutOrder = -state.issued
	else
		layoutOrder = state.issued
	end

	frame.LayoutOrder = layoutOrder
	frame.AnchorPoint = Vector2.one * 0.5
	frame.Parent = state.holder
	launchSpring(uIScale) -- equivalent call inferred; original call site unknown

	if group ~= nil then
		TweenService:Create(group, tweenInfo, {
			GroupTransparency = groupTransparency
		}):Play()
	end

	armExpiry(state2) -- equivalent call inferred; original call site unknown
	local onShown = state2.onShown

	if onShown ~= nil then
		task.spawn(onShown, frame)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function capacityOf(state)
	local capacity = state.holder:GetAttribute("Capacity")

	if typeof(capacity) == "number" then
		return capacity
	end

	return 3
end

local function pinnedBusy()
	if os.clock() < v6 then
		return true
	end

	for _, v8 in v2 do
		for _, v9 in v8.live do
			if v9.pinned then
				return true
			end
		end
	end

	return false
end

local function takeAdmissible(state)
	local v8 = pinnedBusy()
	local v9 = false

	for k, v10 in state.waiting do
		if RoundDeferral.HoldsBack(v10.delayInRound) or v10.pinned and v8 then
			v9 = true
		else
			table.remove(state.waiting, k)
			return v10, v9
		end
	end

	return nil, v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wake(state, duration: number)
	state.wakeToken += 1
	local wakeToken = state.wakeToken
	task.delay(duration, function()
		if wakeToken == state.wakeToken then
			fn(state)
		end
	end)
end

local function pump(state)
	state.wakeToken += 1

	while #state.waiting > 0 do
		if not (#state.live < capacityOf(state)) or state.guarded and v5 > 0 then
			break
		end

		local v9 = os.clock() - state.lastAdmit

		if v9 < 0.14 then
			wake(state, 0.14 - v9) -- equivalent call inferred; original call site unknown
			break
		else
			local v10, v11 = takeAdmissible(state)

			if v10 == nil then
				if v11 then
					wake(state, 0.4) -- equivalent call inferred; original call site unknown
				end

				break
			else
				admit(state, v10)
			end
		end
	end
end

fn = function(p)
	if p.pumpPending then
		return
	end

	p.pumpPending = true
	task.defer(function()
		p.pumpPending = false
		pump(p)
	end)
end

local holder = v2.Banner.holder
local position = holder.Position
local v8 = 0

local function isDisplayed(parent)
	while parent ~= nil and not parent:IsA("LayerCollector") do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent ~= nil and parent.Enabled == true
end

local function overlaps(p, p2: number, p3: number, p4: number, p5: number)
	local absolutePosition = p.AbsolutePosition
	local v9 = absolutePosition + p.AbsoluteSize
	return absolutePosition.X < p4 and p2 < v9.X and absolutePosition.Y < p5 and p3 < v9.Y
end

local function lowestBlockerEdge(ancestor, X: number, p: number, p2: number, p3: number)
	local v9 = p

	for _, guiObject in CollectionService:GetTagged("TopNotificationBlocker") do
		if not (guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(ancestor) and isDisplayed(guiObject)) then
			continue
		end

		local absolutePosition = guiObject.AbsolutePosition
		local v10 = absolutePosition + guiObject.AbsoluteSize
		local v11

		if absolutePosition.X < p2 and X < v10.X and absolutePosition.Y < p3 then
			v11 = p < v10.Y
		else
			v11 = false
		end

		if v11 then
			v9 = math.max(v9, guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y)
		end
	end

	return v9
end

local function refreshClearance(playerGui)
	local Y = notifications.AbsoluteSize.Y

	if Y <= 0 then
		return
	end

	local Y2 = holder.AbsoluteSize.Y
	local v9 = notifications.AbsolutePosition.Y + position.Y.Scale * Y + position.Y.Offset - holder.AnchorPoint.Y * Y2
	local X = holder.AbsolutePosition.X
	local v10 = math.max(lowestBlockerEdge(playerGui, X, v9, X + holder.AbsoluteSize.X, v9 + Y2) - v9, 0) / Y

	if v10 > 0 then
		v10 += Y2 * 0.12 / Y
	end

	if math.abs(v10 - v8) < 0.0025 then
		return
	end

	v8 = v10
	TweenService:Create(holder, tweenInfo4, {
		Position = position + UDim2.fromScale(0, v10)
	}):Play()
end

function v3.Schedule(data)
	if typeof(data) ~= "table" then
		error(`Lanes.Schedule expects an entry table, got {typeof(data)}`, 2)
	end

	local v9 = v2[data.Lane]

	if v9 == nil then
		error(`unknown notification lane {tostring(data.Lane)}`, 2)
	end

	local frame = data.Frame

	if typeof(frame) ~= "Instance" or not frame:IsA("GuiObject") then
		error("a notification needs a GuiObject to show", 2)
	end

	local seconds = data.Seconds

	if seconds ~= nil and typeof(seconds) ~= "number" then
		error(`notification entry field Seconds expects a number, got {typeof(seconds)}`, 3)
	end

	local uniqueKey = data.UniqueKey

	if uniqueKey ~= nil and typeof(uniqueKey) ~= "string" then
		error(`notification entry field UniqueKey expects a string, got {typeof(uniqueKey)}`, 3)
	end

	local delayInRound = data.DelayInRound

	if delayInRound ~= nil and typeof(delayInRound) ~= "boolean" then
		error(`notification entry field DelayInRound expects a boolean, got {typeof(delayInRound)}`, 3)
	end

	local onShown = data.OnShown

	if onShown ~= nil and typeof(onShown) ~= "function" then
		error(`notification entry field OnShown expects a function, got {typeof(onShown)}`, 3)
	end

	local onRetired = data.OnRetired

	if onRetired ~= nil and typeof(onRetired) ~= "function" then
		error(`notification entry field OnRetired expects a function, got {typeof(onRetired)}`, 3)
	end

	if #v9.waiting >= 24 then
		return false
	end

	local uniqueKey2 = data.UniqueKey
	local flag

	if uniqueKey2 == nil then
		flag = true
	elseif v4[uniqueKey2] then
		flag = false
	else
		v4[uniqueKey2] = true
		flag = true
	end

	if not flag then
		return false
	end

	local sammyDialogue = frame:GetAttribute("SammyDialogue")
	local v10 = {
		frame = frame,
		seconds = data.Seconds or 3,
		uniqueKey = data.UniqueKey,
		delayInRound = data.DelayInRound == true,
		laneId = v9.id,
		onShown = data.OnShown,
		onRetired = data.OnRetired,
		pinned = sammyDialogue ~= nil and sammyDialogue ~= false,
		shownAt = nil,
		retiring = false,
		destroyed = false,
		expiryToken = 0
	}
	table.insert(v9.waiting, v10)
	watchFrame(v10) -- equivalent call inferred; original call site unknown
	fn(v9)
	return true
end

function v3.HoldBanner()
	v5 += 1
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v5 -= 1
		fn(v2.Banner)
	end
end

function v3.IsBannerShowing()
	return #v2.Banner.live > 0
end

task.spawn(function()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	while true do
		task.wait(0.25)
		refreshClearance(playerGui)
	end
end)
return table.freeze(v3)