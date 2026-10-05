local __DEV__ = _G.__DEV__
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local array = luaupolyfill.Array
local error2 = luaupolyfill.Error
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local describeError = shared2.describeError
require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent.Parent:WaitForChild("react"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent:WaitForChild("ReactFiberLane"))
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared3.getComponentName
local ReactFiberFlags = require(script.Parent:WaitForChild("ReactFiberFlags"))
local placement = ReactFiberFlags.Placement
local deletion = ReactFiberFlags.Deletion
local shared4 = require(script.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared4.ReactSymbols
local getIteratorFn = reactSymbols.getIteratorFn
local REACT_ELEMENT_TYPE = reactSymbols.REACT_ELEMENT_TYPE
local REACT_FRAGMENT_TYPE = reactSymbols.REACT_FRAGMENT_TYPE
local REACT_PORTAL_TYPE = reactSymbols.REACT_PORTAL_TYPE
local REACT_LAZY_TYPE = reactSymbols.REACT_LAZY_TYPE
local REACT_BLOCK_TYPE = reactSymbols.REACT_BLOCK_TYPE
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local _ = ReactWorkTags.FunctionComponent
local _ = ReactWorkTags.ClassComponent
local hostText = ReactWorkTags.HostText
local hostPortal = ReactWorkTags.HostPortal
local _ = ReactWorkTags.ForwardRef
local fragment = ReactWorkTags.Fragment
local _ = ReactWorkTags.SimpleMemoComponent
local block = ReactWorkTags.Block
local shared5 = require(script.Parent.Parent:WaitForChild("shared"))
local invariant = shared5.invariant
local shared6 = require(script.Parent.Parent:WaitForChild("shared"))
local reactFeatureFlags = shared6.ReactFeatureFlags
local enableLazyElements = reactFeatureFlags.enableLazyElements
local enableBlocksAPI = reactFeatureFlags.enableBlocksAPI
local ReactFibernew = require(script.Parent:WaitForChild("ReactFiber.new"))
local createWorkInProgress = ReactFibernew.createWorkInProgress
local resetWorkInProgress = ReactFibernew.resetWorkInProgress
local createFiberFromElement = ReactFibernew.createFiberFromElement
local createFiberFromFragment = ReactFibernew.createFiberFromFragment
local createFiberFromText = ReactFibernew.createFiberFromText
local createFiberFromPortal = ReactFibernew.createFiberFromPortal
local v = nil
local v2 = nil
local fn, v3

if __DEV__ then
	v = false
	v2 = {}

	fn = function(p, p2)
		if p == nil or type(p) ~= "table" then
			return
		end

		if not p._store or p._store.validated or p.key ~= nil then
			return
		end

		invariant(
			p._store ~= nil and type(p._store) == "table",
			"React Component in warnForMissingKey should have a _store. This error is likely caused by a bug in React. Please file an issue."
		)
		p._store.validated = true
		local v6 = getComponentName(p2.type) or "Component"

		if v2[v6] then
			return
		end

		v2[v6] = true
		console.error("Each child in a list should have a unique \"key\" prop. See https://reactjs.org/link/warning-keys for more information.")
	end

	v3 = {}
else
	v3 = nil

	fn = function(_, _) end
end

local isArray = array.isArray

function coerceRef(p, _, data)
	local ref = data.ref

	if ref == nil or type(ref) ~= "string" then
		return ref
	end

	if not data._owner or not data._self or data._owner.stateNode == data._self then
		local v4 = not __DEV__ and "<enable __DEV__ mode for component names>" or getComponentName(p.type) or "Component"
		error(error2.new(string.format(
			"Component \"%s\" contains the string ref \"%s\". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref",
			v4,
			(tostring(ref))
		)))
	end

	if not data._owner then
		error("Expected ref to be a function or an object returned by React.createRef(), or nil.")
	end

	return ref
end

local function warnOnFunctionType(p)
	if __DEV__ then
		local v4 = getComponentName(p.type) or "Component"

		if v3[v4] then
			return
		end

		v3[v4] = true
		console.error("Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.")
	end
end

function resolveLazyType(p)
	local _payload = p._payload
	local _init = p._init
	local v4, v5 = xpcall(_init, describeError, _payload)

	if v4 then
		return v5
	end

	return p
end

local function ChildReconciler(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function deleteChild(state, p2)
		if not p then
			return
		end

		local deletions = state.deletions

		if deletions ~= nil then
			table.insert(deletions, p2)
			return
		end

		state.deletions = { p2 }
		state.flags = bit32.bor(state.flags, deletion)
	end

	local function deleteRemainingChildren(state, sibling)
		if not p then
			return nil
		end

		while sibling ~= nil do
			deleteChild(state, sibling) -- equivalent call inferred; original call site unknown
			sibling = sibling.sibling
		end

		return nil
	end

	local function mapRemainingChildren(_, sibling)
		local siblings = {}

		while sibling ~= nil do
			if sibling.key == nil then
				siblings[sibling.index] = sibling
			else
				siblings[sibling.key] = sibling
			end

			sibling = sibling.sibling
		end

		return siblings
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function useFiber(p2, p3)
		local workInProgress = createWorkInProgress(p2, p3)
		workInProgress.index = 1
		workInProgress.sibling = nil
		return workInProgress
	end

	local function placeChild(state, p2: number, p3: number)
		state.index = p3

		if not p then
			return p2
		end

		local alternate = state.alternate

		if alternate == nil then
			state.flags = bit32.bor(state.flags, placement)
			return p2
		end

		local index = alternate.index

		if index < p2 then
			state.flags = bit32.bor(state.flags, placement)
			return p2
		else
			return index
		end
	end

	local function placeSingleChild(state)
		if p and state.alternate == nil then
			state.flags = bit32.bor(state.flags, placement)
		end

		return state
	end

	local function updateTextNode(return_, p2, p3: string, p4)
		if p2 == nil or p2.tag ~= hostText then
			local fiberFromText = createFiberFromText(p3, return_.mode, p4)
			fiberFromText.return_ = return_
			return fiberFromText
		else
			local workInProgress = useFiber(p2, p3) -- equivalent call inferred; original call site unknown
			workInProgress.return_ = return_
			return workInProgress
		end
	end

	local function updateElement(return_, data, data2, p2)
		if data ~= nil then
			if data.elementType == data2.type then
				local workInProgress = useFiber(data, data2.props) -- equivalent call inferred; original call site unknown
				workInProgress.ref = coerceRef(return_, data, data2)
				workInProgress.return_ = return_

				if __DEV__ then
					workInProgress._debugSource = data2._source
					workInProgress._debugOwner = data2._owner
				end

				return workInProgress
			elseif enableBlocksAPI and data.tag == block then
				local type2 = data2.type

				if type(type2) == "table" and type2["$$typeof"] == REACT_LAZY_TYPE then
					type2 = resolveLazyType(type2)
				end

				if type2["$$typeof"] == REACT_BLOCK_TYPE and type2._render == data.type._render then
					local workInProgress = useFiber(data, data2.props) -- equivalent call inferred; original call site unknown
					workInProgress.return_ = return_
					workInProgress.type = type2

					if __DEV__ then
						workInProgress._debugSource = data2._source
						workInProgress._debugOwner = data2._owner
					end

					return workInProgress
				end
			end
		end

		local fiberFromElement = createFiberFromElement(data2, return_.mode, p2)
		fiberFromElement.ref = coerceRef(return_, data, data2)
		fiberFromElement.return_ = return_
		return fiberFromElement
	end

	local function updatePortal(return_, p2, data, p3)
		if p2 == nil or p2.tag ~= hostPortal or p2.stateNode.containerInfo ~= data.containerInfo or p2.stateNode.implementation ~= data.implementation then
			local fiberFromPortal = createFiberFromPortal(data, return_.mode, p3)
			fiberFromPortal.return_ = return_
			return fiberFromPortal
		else
			local children = data.children or {}
			local workInProgress = useFiber(p2, children) -- equivalent call inferred; original call site unknown
			workInProgress.return_ = return_
			return workInProgress
		end
	end

	local function updateFragment(return_, p2, p3, p4, p5: string?)
		if p2 == nil or p2.tag ~= fragment then
			local fiberFromFragment = createFiberFromFragment(p3, return_.mode, p4, p5)
			fiberFromFragment.return_ = return_
			return fiberFromFragment
		else
			local workInProgress = useFiber(p2, p3) -- equivalent call inferred; original call site unknown
			workInProgress.return_ = return_
			return workInProgress
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function assignStableKey(p2, data)
		if data.key == nil then
			local typeName = type(p2)

			if typeName == "string" or typeName == "number" then
				data.key = p2
			elseif typeName == "table" then
				data.key = tostring(p2)
			end
		end
	end

	local createChild

	createChild = function(return_, data, p2, p3)
		if data == nil then
			return nil
		end

		local typeName = type(data)

		if typeName == "table" then
			assignStableKey(p3, data) -- equivalent call inferred; original call site unknown
			local typeof = data["$$typeof"]

			if typeof == REACT_ELEMENT_TYPE then
				local fiberFromElement = createFiberFromElement(data, return_.mode, p2)
				fiberFromElement.ref = coerceRef(return_, nil, data)
				fiberFromElement.return_ = return_
				return fiberFromElement
			elseif typeof == REACT_PORTAL_TYPE then
				local fiberFromPortal = createFiberFromPortal(data, return_.mode, p2)
				fiberFromPortal.return_ = return_
				return fiberFromPortal
			elseif typeof == REACT_LAZY_TYPE and enableLazyElements then
				local _payload = data._payload
				return createChild(return_, data._init(_payload), p2)
			else
				local fiberFromFragment = createFiberFromFragment(data, return_.mode, p2, nil)
				fiberFromFragment.return_ = return_
				return fiberFromFragment
			end
		elseif typeName == "string" or typeName == "number" then
			local fiberFromText = createFiberFromText(tostring(data), return_.mode, p2)
			fiberFromText.return_ = return_
			return fiberFromText
		else
			if not __DEV__ or typeName ~= "function" or not __DEV__ then
				return nil
			end

			local v4 = getComponentName(return_.type) or "Component"

			if not v3[v4] then
				v3[v4] = true
				console.error("Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.")
			end

			return nil
		end
	end

	local updateSlot

	updateSlot = function(return_, p2, data, p3, p4)
		if data == nil then
			return nil
		end

		local key

		if p2 ~= nil then
			key = p2.key
		end

		local typeName = type(data)

		if typeName == "table" then
			assignStableKey(p4, data) -- equivalent call inferred; original call site unknown
			local typeof = data["$$typeof"]

			if typeof == REACT_ELEMENT_TYPE then
				if data.key ~= key then
					return nil
				end

				if data.type ~= REACT_FRAGMENT_TYPE then
					return (updateElement(return_, p2, data, p3))
				end

				local children = data.props.children

				if p2 == nil or p2.tag ~= fragment then
					local fiberFromFragment = createFiberFromFragment(children, return_.mode, p3, key)
					fiberFromFragment.return_ = return_
					return fiberFromFragment
				else
					local workInProgress = useFiber(p2, children) -- equivalent call inferred; original call site unknown
					workInProgress.return_ = return_
					return workInProgress
				end
			elseif typeof == REACT_PORTAL_TYPE then
				if data.key == key then
					return (updatePortal(return_, p2, data, p3))
				end

				return nil
			elseif typeof == REACT_LAZY_TYPE and enableLazyElements then
				local _payload = data._payload
				return updateSlot(return_, p2, data._init(_payload), p3)
			else
				if key ~= nil then
					return nil
				end

				if p2 == nil or p2.tag ~= fragment then
					local fiberFromFragment = createFiberFromFragment(data, return_.mode, p3, nil)
					fiberFromFragment.return_ = return_
					return fiberFromFragment
				else
					local workInProgress = useFiber(p2, data) -- equivalent call inferred; original call site unknown
					workInProgress.return_ = return_
					return workInProgress
				end
			end
		elseif typeName == "string" or typeName == "number" then
			if key ~= nil then
				return nil
			end

			local v4 = tostring(data)

			if p2 == nil or p2.tag ~= hostText then
				local fiberFromText = createFiberFromText(v4, return_.mode, p3)
				fiberFromText.return_ = return_
				return fiberFromText
			else
				local workInProgress = useFiber(p2, v4) -- equivalent call inferred; original call site unknown
				workInProgress.return_ = return_
				return workInProgress
			end
		else
			if not __DEV__ or typeName ~= "function" or not __DEV__ then
				return nil
			end

			local v4 = getComponentName(return_.type) or "Component"

			if not v3[v4] then
				v3[v4] = true
				console.error("Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.")
			end

			return nil
		end
	end

	local updateFromMap

	updateFromMap = function(p2, return_, key: number, data, p3, p4)
		if data == nil then
			return nil
		end

		local typeName = type(data)

		if typeName == "table" then
			assignStableKey(p4, data) -- equivalent call inferred; original call site unknown
			local typeof = data["$$typeof"]

			if typeof == REACT_ELEMENT_TYPE then
				if data.key ~= nil then
					key = data.key
				end

				local v4 = p2[key]

				if data.type ~= REACT_FRAGMENT_TYPE then
					return (updateElement(return_, v4, data, p3))
				end

				local children = data.props.children
				local key2 = data.key

				if v4 == nil or v4.tag ~= fragment then
					local fiberFromFragment = createFiberFromFragment(children, return_.mode, p3, key2)
					fiberFromFragment.return_ = return_
					return fiberFromFragment
				else
					local workInProgress = useFiber(v4, children) -- equivalent call inferred; original call site unknown
					workInProgress.return_ = return_
					return workInProgress
				end
			elseif typeof == REACT_PORTAL_TYPE then
				if data.key ~= nil then
					key = data.key
				end

				return (updatePortal(return_, p2[key], data, p3))
			elseif typeof == REACT_LAZY_TYPE and enableLazyElements then
				local _payload = data._payload
				return updateFromMap(p2, return_, key, data._init(_payload), p3)
			else
				local v4 = p2[key]

				if v4 == nil or v4.tag ~= fragment then
					local fiberFromFragment = createFiberFromFragment(data, return_.mode, p3, nil)
					fiberFromFragment.return_ = return_
					return fiberFromFragment
				else
					local workInProgress = useFiber(v4, data) -- equivalent call inferred; original call site unknown
					workInProgress.return_ = return_
					return workInProgress
				end
			end
		elseif typeName == "string" or typeName == "number" then
			local v4 = p2[key] or nil
			local v5 = tostring(data)

			if v4 == nil or v4.tag ~= hostText then
				local fiberFromText = createFiberFromText(v5, return_.mode, p3)
				fiberFromText.return_ = return_
				return fiberFromText
			else
				local workInProgress = useFiber(v4, v5) -- equivalent call inferred; original call site unknown
				workInProgress.return_ = return_
				return workInProgress
			end
		else
			if not __DEV__ or typeName ~= "function" or not __DEV__ then
				return nil
			end

			local v4 = getComponentName(return_.type) or "Component"

			if not v3[v4] then
				v3[v4] = true
				console.error("Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.")
			end

			return nil
		end
	end

	local warnOnInvalidKey

	warnOnInvalidKey = function(data, p2, p3)
		if not __DEV__ or (data == nil or type(data) ~= "table") then
			return p2
		end

		local typeof = data["$$typeof"]

		if typeof == REACT_ELEMENT_TYPE or typeof == REACT_PORTAL_TYPE then
			fn(data, p3)
			local key = data.key

			if type(key) ~= "string" then
				return p2
			end

			if p2 == nil then
				return {
					[key] = true
				}
			end

			if p2[key] then
				console.error(
					"Encountered two children with the same key, `%s`. Keys should be unique so that components maintain their identity across updates. Non-unique keys may cause children to be duplicated and/or omitted — the behavior is unsupported and could change in a future version.",
					key
				)
				return p2
			end

			p2[key] = true
			return p2
		elseif typeof == REACT_LAZY_TYPE and enableLazyElements then
			local _payload = data._payload
			warnOnInvalidKey(data._init(_payload), p2, p3)
		end

		return p2
	end

	local function reconcileChildrenArray(state, sibling, children, p2)
		if __DEV__ then
			local v4 = nil

			for _, v5 in children do
				v4 = warnOnInvalidKey(v5, v4, state)
			end
		end

		local count = #children
		local v4 = 1
		local v5 = nil
		local v6 = 1
		local v7 = nil

		while sibling ~= nil and v4 <= count do
			local sibling2

			if v4 < sibling.index then
				sibling2 = sibling
				sibling = nil
			else
				sibling2 = sibling.sibling
			end

			local v8 = children[v4]
			local sibling3

			if v8 == nil or type(v8) ~= "table" or v8["$$typeof"] == nil then
				sibling3 = updateSlot(state, sibling, v8, p2)
			else
				sibling3 = updateSlot(state, sibling, v8, p2, v4)
			end

			if sibling3 == nil then
				if sibling ~= nil then
					break
				end

				sibling = sibling2
				break
			else
				if p and sibling and sibling3.alternate == nil and p then
					local deletions = state.deletions

					if deletions == nil then
						state.deletions = { sibling }
						state.flags = bit32.bor(state.flags, deletion)
					else
						table.insert(deletions, sibling)
					end
				end

				sibling3.index = v4

				if p then
					local alternate = sibling3.alternate

					if alternate == nil then
						sibling3.flags = bit32.bor(sibling3.flags, placement)
					else
						local index = alternate.index

						if index < v6 then
							sibling3.flags = bit32.bor(sibling3.flags, placement)
						else
							v6 = index
						end
					end
				end

				if v7 == nil then
					v5 = sibling3
				else
					v7.sibling = sibling3
				end

				v4 += 1
				v7 = sibling3
				sibling = sibling2
			end
		end

		if count < v4 then
			if not p then
				return v5
			end

			while sibling ~= nil do
				deleteChild(state, sibling) -- equivalent call inferred; original call site unknown
				sibling = sibling.sibling
			end

			return v5
		elseif sibling == nil then
			while v4 <= count do
				local v8 = children[v4]
				local sibling2

				if v8 == nil or type(v8) ~= "table" or v8["$$typeof"] == nil then
					sibling2 = createChild(state, v8, p2)
				else
					sibling2 = createChild(state, v8, p2, v4)
				end

				if sibling2 == nil then
					v4 += 1
				else
					sibling2.index = v4

					if p then
						local alternate = sibling2.alternate

						if alternate == nil then
							sibling2.flags = bit32.bor(sibling2.flags, placement)
						else
							local index = alternate.index

							if index < v6 then
								sibling2.flags = bit32.bor(sibling2.flags, placement)
							else
								v6 = index
							end
						end
					end

					if v7 == nil then
						v5 = sibling2
					else
						v7.sibling = sibling2
					end

					v4 += 1
					v7 = sibling2
				end
			end

			return v5
		else
			local v8 = mapRemainingChildren(state, sibling)

			while v4 <= count do
				local sibling2 = updateFromMap(v8, state, v4, children[v4], p2, v4)

				if sibling2 ~= nil then
					if p and sibling2.alternate ~= nil then
						local v10

						if sibling2.key == nil then
							v10 = v4
						else
							v10 = sibling2.key
						end

						v8[v10] = nil
					end

					sibling2.index = v4

					if p then
						local alternate = sibling2.alternate

						if alternate == nil then
							sibling2.flags = bit32.bor(sibling2.flags, placement)
						else
							local index = alternate.index

							if index < v6 then
								sibling2.flags = bit32.bor(sibling2.flags, placement)
							else
								v6 = index
							end
						end
					end

					if v7 == nil then
						v5 = sibling2
					else
						v7.sibling = sibling2
					end

					v7 = sibling2
				end

				v4 += 1
			end

			if p then
				for _, v9 in v8 do
					deleteChild(state, v9) -- equivalent call inferred; original call site unknown
				end
			end

			return v5
		end
	end

	local function reconcileChildrenIterator(state, sibling, children, p2, iteratorFn)
		if __DEV__ then
			if children.entries == iteratorFn then
				if not v then
					console.error("Using Maps as children is not supported. Use an array of keyed ReactElements instead.")
				end

				v = true
			end

			local v4 = iteratorFn(children)

			if v4 then
				local next = v4.next()
				local v5 = nil

				while not next.done do
					next = v4.next()
					v5 = warnOnInvalidKey(next.value, v5, state)
				end
			end
		end

		local v4 = iteratorFn(children)
		local next = v4.next()
		local v5 = 1
		local v6 = nil
		local v7 = 1
		local v8 = nil

		while sibling ~= nil and not next.done do
			local sibling2

			if v5 < sibling.index then
				sibling2 = sibling
				sibling = nil
			else
				sibling2 = sibling.sibling
			end

			local sibling3 = updateSlot(state, sibling, next.value, p2, next.key)

			if sibling3 == nil then
				if sibling ~= nil then
					break
				end

				sibling = sibling2
				break
			else
				if p and sibling and sibling3.alternate == nil and p then
					local deletions = state.deletions

					if deletions == nil then
						state.deletions = { sibling }
						state.flags = bit32.bor(state.flags, deletion)
					else
						table.insert(deletions, sibling)
					end
				end

				sibling3.index = v5

				if p then
					local alternate = sibling3.alternate

					if alternate == nil then
						sibling3.flags = bit32.bor(sibling3.flags, placement)
					else
						local index = alternate.index

						if index < v7 then
							sibling3.flags = bit32.bor(sibling3.flags, placement)
						else
							v7 = index
						end
					end
				end

				if v8 == nil then
					v6 = sibling3
				else
					v8.sibling = sibling3
				end

				v5 += 1
				next = v4.next()
				v8 = sibling3
				sibling = sibling2
			end
		end

		if next.done then
			if not p then
				return v6
			end

			while sibling ~= nil do
				deleteChild(state, sibling) -- equivalent call inferred; original call site unknown
				sibling = sibling.sibling
			end

			return v6
		elseif sibling == nil then
			while not next.done do
				local child = createChild(state, next.value, p2, next.key)

				if child == nil then
					v5 += 1
					next = v4.next()
				else
					child.index = v5

					if p then
						local alternate = child.alternate

						if alternate == nil then
							child.flags = bit32.bor(child.flags, placement)
						else
							local index = alternate.index

							if index < v7 then
								child.flags = bit32.bor(child.flags, placement)
							else
								v7 = index
							end
						end
					end

					if v8 == nil then
						v6 = child
					else
						v8.sibling = child
					end

					v5 += 1
					next = v4.next()
					v8 = child
				end
			end

			return v6
		else
			local v9 = nil

			while not next.done do
				v9 = v9 or mapRemainingChildren(state, sibling)
				local sibling2 = updateFromMap(v9, state, v5, next.value, p2, next.key)

				if sibling2 ~= nil then
					if p and sibling2.alternate ~= nil then
						if sibling2.key == nil then
							v9[v5] = nil
						else
							v9[sibling2.key] = nil
						end
					end

					sibling2.index = v5

					if p then
						local alternate = sibling2.alternate

						if alternate == nil then
							sibling2.flags = bit32.bor(sibling2.flags, placement)
						else
							local index = alternate.index

							if index < v7 then
								sibling2.flags = bit32.bor(sibling2.flags, placement)
							else
								v7 = index
							end
						end
					end

					if v8 == nil then
						v6 = sibling2
					else
						v8.sibling = sibling2
					end

					v8 = sibling2
				end

				v5 += 1
				next = v4.next()
			end

			if p then
				for _, v10 in v9 do
					deleteChild(state, v10) -- equivalent call inferred; original call site unknown
				end
			end

			return v6
		end
	end

	local function reconcileSingleTextNode(return_, sibling, p2: string, p3)
		if sibling == nil or sibling.tag ~= hostText then
			if p then
				while sibling ~= nil do
					deleteChild(return_, sibling) -- equivalent call inferred; original call site unknown
					sibling = sibling.sibling
				end
			end

			local fiberFromText = createFiberFromText(p2, return_.mode, p3)
			fiberFromText.return_ = return_
			return fiberFromText
		else
			local sibling2 = sibling.sibling

			if p then
				while sibling2 ~= nil do
					deleteChild(return_, sibling2) -- equivalent call inferred; original call site unknown
					sibling2 = sibling2.sibling
				end
			end

			local workInProgress = useFiber(sibling, p2) -- equivalent call inferred; original call site unknown
			workInProgress.return_ = return_
			return workInProgress
		end
	end

	local function reconcileSingleElement(return_, sibling, children, p2)
		local key = children.key
		local sibling2 = sibling

		while sibling2 ~= nil do
			if sibling2.key == key then
				if sibling2.tag == fragment then
					if children.type == REACT_FRAGMENT_TYPE then
						local sibling3 = sibling2.sibling

						if p then
							while sibling3 ~= nil do
								deleteChild(return_, sibling3) -- equivalent call inferred; original call site unknown
								sibling3 = sibling3.sibling
							end
						end

						local result = useFiber(sibling2, children.props.children) -- equivalent call inferred; original call site unknown
						result.return_ = return_

						if __DEV__ then
							result._debugSource = children._source
							result._debugOwner = children._owner
						end

						return result
					end
				elseif sibling2.elementType == children.type then
					local sibling3 = sibling2.sibling

					if p then
						while sibling3 ~= nil do
							deleteChild(return_, sibling3) -- equivalent call inferred; original call site unknown
							sibling3 = sibling3.sibling
						end
					end

					local result = useFiber(sibling2, children.props) -- equivalent call inferred; original call site unknown
					result.ref = coerceRef(return_, sibling2, children)
					result.return_ = return_

					if __DEV__ then
						result._debugSource = children._source
						result._debugOwner = children._owner
					end

					return result
				end

				if not p then
					break
				end

				while sibling2 ~= nil do
					deleteChild(return_, sibling2) -- equivalent call inferred; original call site unknown
					sibling2 = sibling2.sibling
				end

				break
			else
				deleteChild(return_, sibling2) -- equivalent call inferred; original call site unknown
				sibling2 = sibling2.sibling
			end
		end

		if children.type == REACT_FRAGMENT_TYPE then
			local fiberFromFragment = createFiberFromFragment(children.props.children, return_.mode, p2, children.key)
			fiberFromFragment.return_ = return_
			return fiberFromFragment
		else
			local fiberFromElement = createFiberFromElement(children, return_.mode, p2)
			fiberFromElement.ref = coerceRef(return_, sibling, children)
			fiberFromElement.return_ = return_
			return fiberFromElement
		end
	end

	local function reconcileSinglePortal(return_, sibling, children, p2)
		local key = children.key

		while sibling ~= nil do
			if sibling.key == key then
				if sibling.tag == hostPortal and sibling.stateNode.containerInfo == children.containerInfo and sibling.stateNode.implementation == children.implementation then
					local sibling2 = sibling.sibling

					if p then
						while sibling2 ~= nil do
							deleteChild(return_, sibling2) -- equivalent call inferred; original call site unknown
							sibling2 = sibling2.sibling
						end
					end

					local children2 = children.children or {}
					local result = useFiber(sibling, children2) -- equivalent call inferred; original call site unknown
					result.return_ = return_
					return result
				else
					if not p then
						break
					end

					while sibling ~= nil do
						deleteChild(return_, sibling) -- equivalent call inferred; original call site unknown
						sibling = sibling.sibling
					end

					break
				end
			else
				deleteChild(return_, sibling) -- equivalent call inferred; original call site unknown
				sibling = sibling.sibling
			end
		end

		local fiberFromPortal = createFiberFromPortal(children, return_.mode, p2)
		fiberFromPortal.return_ = return_
		return fiberFromPortal
	end

	local reconcileChildFibers

	reconcileChildFibers = function(state, sibling, children, p2)
		local typeName = type(children)
		local v4

		if children == nil or typeName ~= "table" or children.type ~= REACT_FRAGMENT_TYPE then
			v4 = false
		else
			v4 = children.key == nil
		end

		if v4 then
			children = children.props.children
			typeName = type(children)
		end

		local array2 = isArray(children)
		local v5

		if children == nil or typeName ~= "table" then
			v5 = false
		else
			v5 = not array2
		end

		if v5 then
			local typeof = children["$$typeof"]

			if typeof == REACT_ELEMENT_TYPE then
				local v6 = reconcileSingleElement(state, sibling, children, p2)

				if p and v6.alternate == nil then
					v6.flags = bit32.bor(v6.flags, placement)
				end

				return v6
			elseif typeof == REACT_PORTAL_TYPE then
				local v6 = reconcileSinglePortal(state, sibling, children, p2)

				if p and v6.alternate == nil then
					v6.flags = bit32.bor(v6.flags, placement)
				end

				return v6
			elseif typeof == REACT_LAZY_TYPE and enableLazyElements then
				local _payload = children._payload
				return reconcileChildFibers(state, sibling, children._init(_payload), p2)
			end
		else
			if array2 then
				return (reconcileChildrenArray(state, sibling, children, p2))
			end

			if typeName == "string" or typeName == "number" then
				local v6 = reconcileSingleTextNode(state, sibling, tostring(children), p2)

				if p and v6.alternate == nil then
					v6.flags = bit32.bor(v6.flags, placement)
				end

				return v6
			end
		end

		local iteratorFn = getIteratorFn(children)

		if iteratorFn then
			return (reconcileChildrenIterator(state, sibling, children, p2, iteratorFn))
		end

		if __DEV__ and typeName == "function" and __DEV__ then
			local v6 = getComponentName(state.type) or "Component"

			if not v3[v6] then
				v3[v6] = true
				console.error("Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.")
			end
		end

		if not p then
			return nil
		end

		while sibling ~= nil do
			deleteChild(state, sibling) -- equivalent call inferred; original call site unknown
			sibling = sibling.sibling
		end

		return nil
	end

	return reconcileChildFibers
end

local New = {}
New.reconcileChildFibers = ChildReconciler(true)
New.mountChildFibers = ChildReconciler(false)

function New.cloneChildFibers(_, return_)
	if return_.child == nil then
		return
	end

	local child = return_.child
	local workInProgress = createWorkInProgress(child, child.pendingProps)
	return_.child = workInProgress
	workInProgress.return_ = return_

	while child.sibling ~= nil do
		child = child.sibling
		workInProgress.sibling = createWorkInProgress(child, child.pendingProps)
		workInProgress = workInProgress.sibling
		workInProgress.return_ = return_
	end

	workInProgress.sibling = nil
end

function New.resetChildFibers(p, p2)
	local child = p.child

	while child ~= nil do
		resetWorkInProgress(child, p2)
		child = child.sibling
	end
end

return New