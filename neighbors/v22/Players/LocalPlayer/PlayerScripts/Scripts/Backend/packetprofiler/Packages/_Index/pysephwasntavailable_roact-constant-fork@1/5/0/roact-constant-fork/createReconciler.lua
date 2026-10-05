local Type = require(script.Parent.Type)
local ElementKind = require(script.Parent.ElementKind)
local ElementUtils = require(script.Parent.ElementUtils)
local Children = require(script.Parent.PropMarkers.Children)
local Symbol = require(script.Parent.Symbol)
local internalAssert = require(script.Parent.internalAssert)
local GlobalConfig = require(script.Parent.GlobalConfig)
local v = GlobalConfig.get()
local named = Symbol.named("InternalData")

local function createReconciler(data)
	local v2 = nil
	local mountVirtualNode
	local updateVirtualNode
	local unmountVirtualNode

	local function replaceVirtualNode(data2, p)
		local hostParent = data2.hostParent
		local hostKey = data2.hostKey
		local depth = data2.depth
		local parent = data2.parent
		local originalContext = data2.originalContext or data2.context
		local parentLegacyContext = data2.parentLegacyContext

		if not data2.wasUnmounted then
			unmountVirtualNode(data2)
		end

		local v3 = mountVirtualNode(p, hostParent, hostKey, originalContext, parentLegacyContext)

		if v3 ~= nil then
			v3.depth = depth
			v3.parent = parent
		end

		return v3
	end

	local function updateChildren(parent, p, p2)
		if v.internalTypeChecks then
			internalAssert(Type.of(parent) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		parent.updateChildrenCount += 1
		local updateChildrenCount = parent.updateChildrenCount
		local v3 = {}

		for k, v4 in pairs(parent.children) do
			local elementByKey = ElementUtils.getElementByKey(p2, k)
			local v5 = updateVirtualNode(v4, elementByKey)

			if parent.updateChildrenCount == updateChildrenCount then
				if v5 == nil then
					v3[k] = true
				else
					parent.children[k] = v5
				end
			else
				if v5 and v5 ~= parent.children[k] then
					unmountVirtualNode(v5)
				end

				return
			end
		end

		for k in pairs(v3) do
			parent.children[k] = nil
		end

		for k, v4 in ElementUtils.iterateElements(p2) do
			local hostKey

			if k == ElementUtils.UseParentKey then
				hostKey = parent.hostKey
			else
				hostKey = k
			end

			if parent.children[k] ~= nil then
				continue
			end

			local v5 = mountVirtualNode(v4, p, hostKey, parent.context, parent.legacyContext)

			if parent.updateChildrenCount == updateChildrenCount then
				if v5 ~= nil then
					v5.depth = parent.depth + 1
					v5.parent = parent
					parent.children[k] = v5
				end
			else
				if v5 then
					unmountVirtualNode(v5)
				end

				break
			end
		end
	end

	local function updateVirtualNodeWithRenderResult(parent, hostParent, component)
		if Type.of(component) == Type.Element or component == nil or typeof(component) == "boolean" then
			updateChildren(parent, hostParent, component)
		else
			error(
				("%s\n%s"):format(
					"Component returned invalid children:",
					parent.currentElement.source or "<enable element tracebacks>"
				),
				0
			)
		end
	end

	unmountVirtualNode = function(state)
		if v.internalTypeChecks then
			internalAssert(Type.of(state) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		state.wasUnmounted = true
		local v3 = ElementKind.of(state.currentElement)

		if v3 == ElementKind.Host then
			data.unmountHostNode(v2, state)
			return
		end

		if v3 ~= ElementKind.Function then
			if v3 == ElementKind.Stateful then
				state.instance:__unmount()
				return
			end

			if v3 ~= ElementKind.Portal and v3 ~= ElementKind.Fragment then
				error(("Unknown ElementKind %q"):format((tostring(v3))), 2)
				return
			end
		end

		for _, v4 in pairs(state.children) do
			unmountVirtualNode(v4)
		end
	end

	local function updateFunctionVirtualNode(parent, p2)
		local component = p2.component(p2.props)
		updateVirtualNodeWithRenderResult(parent, parent.hostParent, component)
		return parent
	end

	local function updatePortalVirtualNode(data2, p)
		local target = data2.currentElement.props.target
		local target2 = p.props.target
		assert(data.isHostObject(target2), "Expected target to be host object")

		if target2 == target then
			updateChildren(data2, target2, p.props[Children])
			return data2
		else
			local hostParent = data2.hostParent
			local hostKey = data2.hostKey
			local depth = data2.depth
			local parent = data2.parent
			local originalContext = data2.originalContext or data2.context
			local parentLegacyContext = data2.parentLegacyContext

			if not data2.wasUnmounted then
				unmountVirtualNode(data2)
			end

			local v3 = mountVirtualNode(p, hostParent, hostKey, originalContext, parentLegacyContext)

			if v3 ~= nil then
				v3.depth = depth
				v3.parent = parent
			end

			return v3
		end
	end

	local function updateFragmentVirtualNode(parent, p2)
		updateChildren(parent, parent.hostParent, p2.elements)
		return parent
	end

	updateVirtualNode = function(state, currentElement, p)
		if v.internalTypeChecks then
			internalAssert(Type.of(state) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		if v.typeChecks then
			assert(
				Type.of(currentElement) == Type.Element or typeof(currentElement) == "boolean" or currentElement == nil,
				"Expected arg #2 to be of type Element, boolean, or nil"
			)
		end

		if state.currentElement == currentElement and p == nil then
			return state
		end

		if typeof(currentElement) == "boolean" or currentElement == nil then
			unmountVirtualNode(state)
			return nil
		end

		if state.currentElement.component == currentElement.component then
			local v3 = ElementKind.of(currentElement)
			local v4 = true

			if v3 == ElementKind.Host then
				state = data.updateHostNode(v2, state, currentElement)
			elseif v3 == ElementKind.Function then
				local component = currentElement.component(currentElement.props)
				updateVirtualNodeWithRenderResult(state, state.hostParent, component)
			elseif v3 == ElementKind.Stateful then
				v4 = state.instance:__update(currentElement, p)
			elseif v3 == ElementKind.Portal then
				local target = state.currentElement.props.target
				local target2 = currentElement.props.target
				assert(data.isHostObject(target2), "Expected target to be host object")

				if target2 == target then
					updateChildren(state, target2, currentElement.props[Children])
				else
					local hostParent = state.hostParent
					local hostKey = state.hostKey
					local depth = state.depth
					local parent = state.parent
					local originalContext = state.originalContext or state.context
					local parentLegacyContext = state.parentLegacyContext

					if not state.wasUnmounted then
						unmountVirtualNode(state)
					end

					state = mountVirtualNode(currentElement, hostParent, hostKey, originalContext, parentLegacyContext)

					if state ~= nil then
						state.depth = depth
						state.parent = parent
					end
				end
			elseif v3 == ElementKind.Fragment then
				updateChildren(state, state.hostParent, currentElement.elements)
			else
				error(("Unknown ElementKind %q"):format((tostring(v3))), 2)
			end

			if not v4 then
				return state
			end

			state.currentElement = currentElement
			return state
		else
			local hostParent = state.hostParent
			local hostKey = state.hostKey
			local depth = state.depth
			local parent = state.parent
			local originalContext = state.originalContext or state.context
			local parentLegacyContext = state.parentLegacyContext

			if not state.wasUnmounted then
				unmountVirtualNode(state)
			end

			local v3 = mountVirtualNode(currentElement, hostParent, hostKey, originalContext, parentLegacyContext)

			if v3 ~= nil then
				v3.depth = depth
				v3.parent = parent
			end

			return v3
		end
	end

	local function createVirtualNode(currentElement, hostParent, hostKey, options, p4)
		if v.internalTypeChecks then
			internalAssert(data.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
			internalAssert(typeof(options) == "table" or options == nil, "Expected arg #4 to be of type table or nil")
			internalAssert(typeof(p4) == "table" or p4 == nil, "Expected arg #5 to be of type table or nil")
		end

		if v.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(currentElement) == Type.Element or typeof(currentElement) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		return {
			[Type] = Type.VirtualNode,
			currentElement = currentElement,
			depth = 1,
			parent = nil,
			children = {},
			hostParent = hostParent,
			hostKey = hostKey,
			updateChildrenCount = 0,
			wasUnmounted = false,
			legacyContext = p4,
			parentLegacyContext = p4,
			context = options or {},
			originalContext = nil
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mountFunctionVirtualNode(virtualNode)
		local currentElement = virtualNode.currentElement
		local component = currentElement.component(currentElement.props)
		updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, component)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mountPortalVirtualNode(virtualNode)
		local currentElement = virtualNode.currentElement
		local target = currentElement.props.target
		local v3 = currentElement.props[Children]
		assert(data.isHostObject(target), "Expected target to be host object")
		updateChildren(virtualNode, target, v3)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mountFragmentVirtualNode(virtualNode)
		local elements = virtualNode.currentElement.elements
		updateChildren(virtualNode, virtualNode.hostParent, elements)
	end

	mountVirtualNode = function(currentElement, hostParent, hostKey, p4, p5)
		if v.internalTypeChecks then
			internalAssert(data.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
			internalAssert(typeof(p5) == "table" or p5 == nil, "Expected arg #5 to be of type table or nil")
		end

		if v.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(currentElement) == Type.Element or typeof(currentElement) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		if typeof(currentElement) == "boolean" then
			return nil
		end

		local v3 = ElementKind.of(currentElement)
		local virtualNode = createVirtualNode(currentElement, hostParent, hostKey, p4, p5)

		if v3 == ElementKind.Host then
			data.mountHostNode(v2, virtualNode)
			return virtualNode
		end

		if v3 == ElementKind.Function then
			mountFunctionVirtualNode(virtualNode) -- equivalent call inferred; original call site unknown
		else
			if v3 == ElementKind.Stateful then
				currentElement.component:__mount(v2, virtualNode)
				return virtualNode
			end

			if v3 == ElementKind.Portal then
				mountPortalVirtualNode(virtualNode) -- equivalent call inferred; original call site unknown
			else
				if v3 ~= ElementKind.Fragment then
					error(("Unknown ElementKind %q"):format((tostring(v3))), 2)
					return virtualNode
				end

				mountFragmentVirtualNode(virtualNode) -- equivalent call inferred; original call site unknown
			end
		end

		return virtualNode
	end

	v2 = {
		mountVirtualTree = function(p, p2, p3)
			if v.typeChecks then
				assert(Type.of(p) == Type.Element, "Expected arg #1 to be of type Element")
				assert(data.isHostObject(p2) or p2 == nil, "Expected arg #2 to be a host object")
			end

			local v3 = p3 == nil and "RoactTree" or p3
			local v4 = {
				[Type] = Type.VirtualTree,
				[named] = {
					rootNode = nil,
					mounted = true
				}
			}
			v4[named].rootNode = mountVirtualNode(p, p2, v3)
			return v4
		end,
		unmountVirtualTree = function(p)
			local v3 = p[named]

			if v.typeChecks then
				assert(Type.of(p) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
				assert(v3.mounted, "Cannot unmounted a Roact tree that has already been unmounted")
			end

			v3.mounted = false

			if v3.rootNode ~= nil then
				unmountVirtualNode(v3.rootNode)
			end
		end,
		updateVirtualTree = function(p, p2)
			local v3 = p[named]

			if v.typeChecks then
				assert(Type.of(p) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
				assert(Type.of(p2) == Type.Element, "Expected arg #2 to be a Roact Element")
			end

			v3.rootNode = updateVirtualNode(v3.rootNode, p2)
			return p
		end,
		createVirtualNode = createVirtualNode,
		mountVirtualNode = mountVirtualNode,
		unmountVirtualNode = unmountVirtualNode,
		updateVirtualNode = updateVirtualNode,
		updateVirtualNodeWithChildren = function(parent, p2, p3)
			updateChildren(parent, p2, p3)
		end,
		updateVirtualNodeWithRenderResult = updateVirtualNodeWithRenderResult
	}
	return v2
end

return createReconciler