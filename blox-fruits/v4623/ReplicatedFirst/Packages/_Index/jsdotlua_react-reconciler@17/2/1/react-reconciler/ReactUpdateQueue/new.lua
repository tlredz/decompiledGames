local __DEV__ = _G.__DEV__
local __YOLO__ = _G.__YOLO__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberLane = require(script.Parent:WaitForChild("ReactFiberLane"))
local noLane = ReactFiberLane.NoLane
local noLanes = ReactFiberLane.NoLanes
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function enterDisallowedContextReadInDEV()
	if not v then
		local ReactFiberNewContextnew = require(script.Parent:WaitForChild("ReactFiberNewContext.new"))
		v = ReactFiberNewContextnew
	end

	v.enterDisallowedContextReadInDEV()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function exitDisallowedContextReadInDEV()
	if not v then
		local ReactFiberNewContextnew = require(script.Parent:WaitForChild("ReactFiberNewContext.new"))
		v = ReactFiberNewContextnew
	end

	v.exitDisallowedContextReadInDEV()
end

local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local callback = ReactFiberFlags.Callback
local shouldCapture = ReactFiberFlags.ShouldCapture
local didCapture = ReactFiberFlags.DidCapture
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local debugRenderPhaseSideEffectsForStrictMode = shared2.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local strictMode = ReactTypeOfMode.StrictMode
local ReactFiberWorkInProgress = require(script.Parent:WaitForChild("ReactFiberWorkInProgress"))
local markSkippedUpdateLanes = ReactFiberWorkInProgress.markSkippedUpdateLanes
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared3.describeError
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local consolePatchingDev = shared4.ConsolePatchingDev
local disableLogs = consolePatchingDev.disableLogs
local reenableLogs = consolePatchingDev.reenableLogs
local New = {
	UpdateState = 0,
	ReplaceState = 1,
	ForceUpdate = 2,
	CaptureUpdate = 3
}
local v2 = false
local v3, shared5

if __DEV__ then
	v3 = false
	shared5 = nil

	function New.resetCurrentlyProcessingQueue()
		shared5 = nil
	end
else
	shared5 = nil
	v3 = nil
end

local v4 = table.create(210)
local v5 = 210

for i = 1, 210 do
	v4[i] = {
		eventTime = -1,
		lane = -1,
		tag = -1,
		payload = nil,
		callback = nil,
		next = nil
	}
end

function New:initializeUpdateQueue()
	self.updateQueue = {
		baseState = self.memoizedState,
		firstBaseUpdate = nil,
		lastBaseUpdate = nil,
		shared = {
			pending = nil
		},
		effects = nil
	}
end

function New.cloneUpdateQueue(p, p2)
	local updateQueue = p2.updateQueue
	local updateQueue2 = p.updateQueue

	if updateQueue == updateQueue2 then
		p2.updateQueue = table.clone(updateQueue2)
	end
end

function New.createUpdate(eventTime: number, lane, payload, callback2)
	if not (v5 > 0) then
		return {
			eventTime = eventTime,
			lane = lane,
			tag = 0,
			payload = payload,
			callback = callback2,
			next = nil
		}
	end

	local v6 = v4[v5]
	v4[v5] = nil
	v5 -= 1
	v6.eventTime = eventTime
	v6.lane = lane
	v6.tag = 0
	v6.payload = payload
	v6.callback = callback2
	return v6
end

function New.enqueueUpdate(p, p2)
	local updateQueue = p.updateQueue

	if updateQueue == nil then
		return
	end

	local shared6 = updateQueue.shared
	local pending = shared6.pending

	if pending == nil then
		p2.next = p2
	else
		p2.next = pending.next
		pending.next = p2
	end

	shared6.pending = p2

	if __DEV__ and shared5 == shared6 and not v3 then
		console.error("An update (setState, replaceState, or forceUpdate) was scheduled from inside an update function. Update functions should be pure, with zero side-effects. Consider using componentDidUpdate or a callback.")
		v3 = true
	end
end

function New:enqueueCapturedUpdate(p)
	local updateQueue = self.updateQueue
	local alternate = self.alternate

	if alternate ~= nil then
		local updateQueue2 = alternate.updateQueue

		if updateQueue == updateQueue2 then
			local firstBaseUpdate = updateQueue.firstBaseUpdate
			local firstBaseUpdate2

			if firstBaseUpdate == nil then
				firstBaseUpdate2 = p
			else
				local v7 = nil

				while true do
					local next = {
						eventTime = firstBaseUpdate.eventTime,
						lane = firstBaseUpdate.lane,
						tag = firstBaseUpdate.tag,
						payload = firstBaseUpdate.payload,
						callback = firstBaseUpdate.callback,
						next = nil
					}

					if v7 == nil then
						firstBaseUpdate2 = next
					else
						v7.next = next
					end

					firstBaseUpdate = firstBaseUpdate.next

					if firstBaseUpdate == nil then
						if next == nil then
							firstBaseUpdate2 = p
						else
							next.next = p
						end

						break
					else
						v7 = next
					end
				end
			end

			self.updateQueue = {
				baseState = updateQueue2.baseState,
				firstBaseUpdate = firstBaseUpdate2,
				lastBaseUpdate = p,
				shared = updateQueue2.shared,
				effects = updateQueue2.effects
			}
			return
		end
	end

	local lastBaseUpdate = updateQueue.lastBaseUpdate

	if lastBaseUpdate == nil then
		updateQueue.firstBaseUpdate = p
	else
		lastBaseUpdate.next = p
	end

	updateQueue.lastBaseUpdate = p
end

local function getStateFromUpdate(state, _, firstBaseUpdate, baseState, p, _)
	local tag = firstBaseUpdate.tag

	if tag == 1 then
		local payload = firstBaseUpdate.payload

		if type(payload) ~= "function" then
			return payload
		end

		if __DEV__ then
			enterDisallowedContextReadInDEV() -- equivalent call inferred; original call site unknown
		end

		local v6 = payload(baseState, p)

		if not __DEV__ then
			return v6
		end

		if debugRenderPhaseSideEffectsForStrictMode and bit32.band(state.mode, strictMode) ~= 0 then
			disableLogs()
			local v7 = nil
			local v8

			if __YOLO__ then
				payload(baseState, p)
				v8 = true
			else
				v8, v7 = xpcall(payload, describeError, baseState, p)
			end

			reenableLogs()

			if not v8 then
				error(v7)
			end
		end

		exitDisallowedContextReadInDEV() -- equivalent call inferred; original call site unknown
		return v6
	elseif tag == 3 or tag == 0 then
		if tag == 3 then
			state.flags = bit32.bor(bit32.band(state.flags, (bit32.bnot(shouldCapture))), didCapture)
		end

		local payload = firstBaseUpdate.payload
		local v6

		if type(payload) == "function" then
			if __DEV__ then
				enterDisallowedContextReadInDEV() -- equivalent call inferred; original call site unknown
			end

			v6 = payload(baseState, p)

			if __DEV__ then
				if debugRenderPhaseSideEffectsForStrictMode and bit32.band(state.mode, strictMode) ~= 0 then
					disableLogs()
					local v7 = nil
					local v8

					if __YOLO__ then
						payload(baseState, p)
						v8 = true
					else
						v8, v7 = xpcall(payload, describeError, baseState, p)
					end

					reenableLogs()

					if not v8 then
						error(v7)
					end
				end

				exitDisallowedContextReadInDEV() -- equivalent call inferred; original call site unknown
			end
		else
			v6 = payload
		end

		if v6 == nil then
			return baseState
		end

		return object.assign({}, baseState, v6)
	else
		if tag ~= 2 then
			return baseState
		end

		v2 = true
		return baseState
	end
end

New.getStateFromUpdate = getStateFromUpdate

function New:processUpdateQueue(p, p2, p3)
	local updateQueue = self.updateQueue
	v2 = false

	if __DEV__ then
		shared5 = updateQueue.shared
	end

	local firstBaseUpdate = updateQueue.firstBaseUpdate
	local lastBaseUpdate = updateQueue.lastBaseUpdate
	local pending = updateQueue.shared.pending

	if pending ~= nil then
		updateQueue.shared.pending = nil
		local next = pending.next
		pending.next = nil

		if lastBaseUpdate == nil then
			firstBaseUpdate = next
		else
			lastBaseUpdate.next = next
		end

		local alternate = self.alternate

		if alternate ~= nil then
			local updateQueue2 = alternate.updateQueue
			local lastBaseUpdate2 = updateQueue2.lastBaseUpdate

			if lastBaseUpdate2 ~= pending then
				if lastBaseUpdate2 == nil then
					updateQueue2.firstBaseUpdate = next
				else
					lastBaseUpdate2.next = next
				end

				updateQueue2.lastBaseUpdate = pending
			end
		end
	end

	if firstBaseUpdate ~= nil then
		local baseState = updateQueue.baseState
		local lanes = noLanes
		local lastBaseUpdate2 = nil
		local baseState2 = nil
		local firstBaseUpdate2 = nil

		while true do
			local lane = firstBaseUpdate.lane
			local eventTime = firstBaseUpdate.eventTime

			if isSubsetOfLanes(p3, lane) then
				if lastBaseUpdate2 ~= nil then
					local next = {
						eventTime = eventTime,
						lane = noLane,
						tag = firstBaseUpdate.tag,
						payload = firstBaseUpdate.payload,
						callback = firstBaseUpdate.callback,
						next = nil
					}
					lastBaseUpdate2.next = next
					lastBaseUpdate2 = next
				end

				baseState = getStateFromUpdate(self, updateQueue, firstBaseUpdate, baseState, p, p2)

				if firstBaseUpdate.callback ~= nil and firstBaseUpdate.lane ~= noLane then
					self.flags = bit32.bor(self.flags, callback)
					local effects = updateQueue.effects

					if effects == nil then
						updateQueue.effects = { firstBaseUpdate }
					else
						table.insert(effects, firstBaseUpdate)
					end
				end
			else
				local next = {
					eventTime = eventTime,
					lane = lane,
					tag = firstBaseUpdate.tag,
					payload = firstBaseUpdate.payload,
					callback = firstBaseUpdate.callback,
					next = nil
				}

				if lastBaseUpdate2 == nil then
					firstBaseUpdate2 = next
					baseState2 = baseState
				else
					lastBaseUpdate2.next = next
				end

				lanes = mergeLanes(lanes, lane)
				lastBaseUpdate2 = next
			end

			firstBaseUpdate = firstBaseUpdate.next

			if firstBaseUpdate ~= nil then
				continue
			end

			local pending2 = updateQueue.shared.pending

			if pending2 == nil then
				if lastBaseUpdate2 == nil then
					baseState2 = baseState
				end

				updateQueue.baseState = baseState2
				updateQueue.firstBaseUpdate = firstBaseUpdate2
				updateQueue.lastBaseUpdate = lastBaseUpdate2
				markSkippedUpdateLanes(lanes)
				self.lanes = lanes
				self.memoizedState = baseState
				break
			else
				firstBaseUpdate = pending2.next
				pending2.next = nil
				updateQueue.lastBaseUpdate = pending2
				updateQueue.shared.pending = nil
			end
		end
	end

	if __DEV__ then
		shared5 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function callCallback(callback2, p)
	if type(callback2) ~= "function" then
		error(string.format(
			"Invalid argument passed as callback. Expected a function. Instead received: %s",
			(tostring(callback2))
		))
	end

	callback2(p)
end

function New.resetHasForceUpdateBeforeProcessing()
	v2 = false
end

function New.checkHasForceUpdateAfterProcessing()
	return v2
end

function New.commitUpdateQueue(_, p, p2)
	local effects = p.effects
	p.effects = nil

	if effects ~= nil then
		for _, list in effects do
			local callback2 = list.callback

			if callback2 ~= nil then
				callCallback(callback2, p2) -- equivalent call inferred; original call site unknown
			end

			table.clear(list)
			table.insert(v4, list)
			v5 += 1
		end
	end
end

return New