local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local Tags = require(shared.Tags)
local Trove = require(shared.Trove)
local React = require(shared.React)
local ReactRoblox = require(shared.ReactRoblox)
local ReflectionService = game:GetService("ReflectionService")
local instancesByClassName = {}
local hooks = parent.Hooks
local Util = require(parent.Util)
local useChild = require(hooks.useChild)
local useSignal = require(hooks.useSignal)
local useTagged = require(hooks.useTagged)

local function hasPerms(new)
	if not new then
		return false
	end

	local securityCapabilities = SecurityCapabilities.fromCurrent()

	for _, v in Enum.SecurityCapability:GetEnumItems() do
		if new:Contains(v) and not securityCapabilities:Contains(v) then
			return false
		end
	end

	return true
end

local virtualize

virtualize = function(instance)
	local className = instance.ClassName
	local class = ReflectionService:GetClass(className)
	local propertiesOfClass = ReflectionService:GetPropertiesOfClass(className)

	if not (class and propertiesOfClass and hasPerms(class.Permits.New)) then
		return nil
	end

	local instance2 = instancesByClassName[className]

	if not instance2 then
		instance2 = Instance.new(className)
		instancesByClassName[className] = instance2
	end

	local v = {
		[React.Tag] = Util.ClassNames(table.unpack(instance:GetTags()))
	}

	for _, v2 in propertiesOfClass do
		local name = v2.Name

		if not (v2.Permits.Write and name ~= "Name" and name ~= "Parent") then
			continue
		end

		local v3 = instance[name]

		if v3 ~= instance2[name] then
			v[name] = v3
		end
	end

	local v2 = {}

	for _, child in instance:GetChildren() do
		v2[child.Name] = virtualize(child)
	end

	return React.createElement(className, v, v2)
end

local virtualizeStyleTree

virtualizeStyleTree = function(object, styleRule, p)
	if styleRule:IsA("StyleRule") then
		if styleRule:HasTag("DemoOnly") and not Util.IsDemo() then
			return
		end

		local descendants = object:QueryDescendants(styleRule.Selector)

		if #descendants > 0 then
			for _, descendant in descendants do
				for _, child in styleRule:GetChildren() do
					virtualizeStyleTree(descendant, child, p)
				end
			end
		end
	else
		if not p[object] then
			p[object] = {}
		end

		p[object][styleRule.Name] = virtualize(styleRule)
	end
end

local function extractTagsInString(selector: string)
	local result = {}

	for k in selector:gmatch("[^,]+") do
		local v = {}
		local v2 = {}

		for k2 in k:gmatch("%S+") do
			table.insert(v, k2)
		end

		local count = #v

		while count > 0 and v[count]:sub(1, 1) ~= "." do
			count -= 1
		end

		if count > 0 then
			local v3 = count

			while v3 > 0 and v[v3]:sub(1, 1) == "." do
				v3 -= 1
			end

			for i = v3 + 1, count do
				table.insert(v2, (v[i]:sub(2)))
			end
		end

		for _, v3 in v2 do
			table.insert(result, v3)
		end
	end

	return result
end

local function CustomNode(p)
	local node = p.Node
	local styleLink = p.StyleLink
	local v = React.useMemo(function()
		if node:IsA("StyleRule") then
			return (extractTagsInString(node.Selector))
		end

		return {}
	end, { not node:IsA("StyleRule") and "" or node.Selector })
	local state, setState = React.useState({})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshNode()
		local current = styleLink.current
		local parent2 = current and current.Parent

		if not (current and parent2) then
			return
		end

		local v2 = {}
		virtualizeStyleTree(parent2, node, v2)
		setState(v2)
	end

	React.useEffect(function()
		refreshNode() -- equivalent call inferred; original call site unknown

		if #v == 0 then
			return
		end

		local thread = nil

		local function debouncedRefresh()
			if thread then
				return
			end

			thread = task.defer(function()
				thread = nil
				local current = styleLink.current
				local parent2 = current and current.Parent

				if current then
					if not parent2 then
						return
					end

					local v2 = {}
					virtualizeStyleTree(parent2, node, v2)
					setState(v2)
				end
			end)
		end

		local maid = Trove.new()

		for _, v2 in v do
			maid:Add((Tags.Bind(v2, debouncedRefresh)))
		end

		maid:Connect(node.DescendantAdded, debouncedRefresh)
		maid:Connect(node.DescendantRemoving, debouncedRefresh)
		return function()
			if thread then
				task.cancel(thread)
			end

			maid:Clean()
		end
	end, { v })

	if not next(state) then
		return nil
	end

	local v2 = {}

	for k, v3 in state do
		table.insert(v2, (ReactRoblox.createPortal(v3, k)))
	end

	return React.createElement(React.Fragment, nil, v2)
end

local function CustomNodes(p)
	local v2 = useChild(useTagged("RelicsDesign")[1], "Custom")
	local state, setState = React.useState(function()
		local result = {}

		if v2 then
			for _, child in v2:GetChildren() do
				result[child] = true
			end
		end

		return result
	end)
	React.useEffect(function()
		if v2 then
			setState(function()
				local result = {}

				for _, child in v2:GetChildren() do
					result[child] = true
				end

				return result
			end)
		else
			setState(function()
				return {}
			end)
		end
	end, { v2 })
	useSignal(v2 and v2.ChildAdded, function(p2)
		setState(function(p3)
			local clone = table.clone(p3)
			clone[p2] = true
			return clone
		end)
	end, { v2 })
	useSignal(v2 and v2.ChildRemoved, function(p2)
		setState(function(p3)
			local clone = table.clone(p3)
			clone[p2] = nil
			return clone
		end)
	end, { v2 })
	local children = {}

	for k in state do
		children[k.Name] = React.createElement(CustomNode, {
			StyleLink = p.StyleLink,
			Node = k
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return CustomNodes