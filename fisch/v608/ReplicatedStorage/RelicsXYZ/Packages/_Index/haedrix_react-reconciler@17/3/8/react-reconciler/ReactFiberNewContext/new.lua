local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local number = LuauPolyfill.Number
local error2 = LuauPolyfill.Error
local Shared = require(parent.Shared)
local console = Shared.console
require(parent.Shared)
require(script.Parent.ReactInternalTypes)
local ReactFiberStacknew = require(script.Parent["ReactFiberStack.new"])
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local ReactUpdateQueuenew = require(script.Parent["ReactUpdateQueue.new"])
local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
local isPrimaryRenderer = ReactFiberHostConfig.isPrimaryRenderer
local createCursor = ReactFiberStacknew.createCursor
local push = ReactFiberStacknew.push
local pop = ReactFiberStacknew.pop
local MaxInts = require(script.Parent.MaxInts)
local MAX_SIGNED_31_BIT_INT = MaxInts.MAX_SIGNED_31_BIT_INT
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local contextProvider = ReactWorkTags.ContextProvider
local classComponent = ReactWorkTags.ClassComponent
local noLanes = ReactFiberLane.NoLanes
local noTimestamp = ReactFiberLane.NoTimestamp
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane
local Shared2 = require(parent.Shared)
local objectIs = Shared2.objectIs
local createUpdate = ReactUpdateQueuenew.createUpdate
local forceUpdate = ReactUpdateQueuenew.ForceUpdate
local New = {}
local cursor = createCursor(nil)
local currentRenderer = ReactGlobals.__DEV__ and {} or nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = false

function New.resetContextDependencies()
	v2 = nil
	v3 = nil
	v4 = nil

	if ReactGlobals.__DEV__ then
		v5 = false
	end
end

function New.enterDisallowedContextReadInDEV()
	if ReactGlobals.__DEV__ then
		v5 = true
	end
end

function New.exitDisallowedContextReadInDEV()
	if ReactGlobals.__DEV__ then
		v5 = false
	end
end

function New.pushProvider(p, currentValue)
	local _context = p.type._context

	if isPrimaryRenderer then
		push(cursor, _context._currentValue, p)
		_context._currentValue = currentValue

		if ReactGlobals.__DEV__ then
			if _context._currentRenderer ~= nil and _context._currentRenderer ~= currentRenderer then
				console.error("Detected multiple renderers concurrently rendering the same context provider. This is currently unsupported.")
			end

			_context._currentRenderer = currentRenderer
		end
	else
		push(cursor, _context._currentValue2, p)
		_context._currentValue2 = currentValue

		if ReactGlobals.__DEV__ then
			if _context._currentRenderer2 ~= nil and _context._currentRenderer2 ~= currentRenderer then
				console.error("Detected multiple renderers concurrently rendering the same context provider. This is currently unsupported.")
			end

			_context._currentRenderer2 = currentRenderer
		end
	end
end

function New.popProvider(p)
	local current = cursor.current
	pop(cursor, p)
	local _context = p.type._context

	if isPrimaryRenderer then
		_context._currentValue = current
	else
		_context._currentValue2 = current
	end
end

function New:calculateChangedBits(p2, p3)
	if objectIs(p3, p2) then
		return 0
	end

	local v6 = MAX_SIGNED_31_BIT_INT

	if typeof(self._calculateChangedBits) == "function" then
		v6 = self._calculateChangedBits(p3, p2)
	end

	return (math.floor(v6))
end

function New.scheduleWorkOnParentPath(return_, p)
	while return_ ~= nil do
		local alternate = return_.alternate

		if isSubsetOfLanes(return_.childLanes, p) then
			if alternate == nil or isSubsetOfLanes(alternate.childLanes, p) then
				break
			end

			alternate.childLanes = mergeLanes(alternate.childLanes, p)
		else
			return_.childLanes = mergeLanes(return_.childLanes, p)

			if alternate ~= nil then
				alternate.childLanes = mergeLanes(alternate.childLanes, p)
			end
		end

		return_ = return_.return_
	end
end

function New.propagateContextChange(return_, p, p2: number, p3)
	local child = return_.child

	if child ~= nil then
		child.return_ = return_
	end

	while child ~= nil do
		local dependencies = child.dependencies
		local child2

		if dependencies == nil then
			if child.tag == contextProvider then
				if child.type ~= return_.type then
					child2 = child.child
				end
			else
				child2 = child.child
			end
		else
			child2 = child.child
			local firstContext = dependencies.firstContext

			while firstContext ~= nil do
				if firstContext.context == p and bit32.band(firstContext.observedBits, p2) ~= 0 then
					if child.tag == classComponent then
						local update = createUpdate(noTimestamp, pickArbitraryLane(p3))
						update.tag = forceUpdate
						local updateQueue = child.updateQueue

						if updateQueue ~= nil then
							local shared = updateQueue.shared
							local pending = shared.pending

							if pending == nil then
								update.next = update
							else
								update.next = pending.next
								pending.next = update
							end

							shared.pending = update
						end
					end

					child.lanes = bit32.bor(child.lanes, p3)
					local alternate = child.alternate

					if alternate ~= nil then
						alternate.lanes = bit32.bor(alternate.lanes, p3)
					end

					New.scheduleWorkOnParentPath(child.return_, p3)
					dependencies.lanes = bit32.bor(dependencies.lanes, p3)
					break
				else
					firstContext = firstContext.next
				end
			end
		end

		if child2 == nil then
			child2 = child

			while child2 ~= nil do
				if child2 == return_ then
					child2 = nil
					break
				end

				local sibling = child2.sibling

				if sibling == nil then
					child2 = child2.return_
				else
					sibling.return_ = child2.return_
					child2 = sibling
					break
				end
			end
		else
			child2.return_ = child
		end

		child = child2
	end
end

function New.prepareToReadContext(p, p2, callback)
	v2 = p
	v3 = nil
	v4 = nil
	local dependencies = p.dependencies

	if dependencies ~= nil and dependencies.firstContext ~= nil then
		if includesSomeLane(dependencies.lanes, p2) then
			callback()
		end

		dependencies.firstContext = nil
	end
end

function New:readContext(MAX_SAFE_INTEGER)
	if ReactGlobals.__DEV__ and v5 then
		console.error("Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().")
	end

	if v4 ~= self and MAX_SAFE_INTEGER ~= false and MAX_SAFE_INTEGER ~= 0 then
		if typeof(MAX_SAFE_INTEGER) ~= "number" or MAX_SAFE_INTEGER == number.MAX_SAFE_INTEGER then
			v4 = self
			MAX_SAFE_INTEGER = number.MAX_SAFE_INTEGER
		end

		local v6 = {
			context = self,
			observedBits = MAX_SAFE_INTEGER,
			next = nil
		}

		if v3 == nil then
			if v2 == nil then
				error(error2.new("Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo()."))
			end

			v3 = v6
			v2.dependencies = {
				lanes = noLanes,
				firstContext = v6,
				responders = nil
			}
		else
			v3.next = v6
			v3 = v6
		end
	end

	if isPrimaryRenderer then
		return self._currentValue
	end

	return self._currentValue2
end

return New