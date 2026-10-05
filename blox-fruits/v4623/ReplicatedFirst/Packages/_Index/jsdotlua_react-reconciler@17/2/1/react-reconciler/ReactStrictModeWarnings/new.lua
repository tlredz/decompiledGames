local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactCurrentFiber = require(script.Parent:WaitForChild("ReactCurrentFiber"))
local resetCurrentFiber = ReactCurrentFiber.resetCurrentFiber
local setCurrentFiber = ReactCurrentFiber.setCurrentFiber
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared2.getComponentName
local ReactTypeOfMode = require(script.Parent:WaitForChild("ReactTypeOfMode"))
local strictMode = ReactTypeOfMode.StrictMode
local New = {
	recordUnsafeLifecycleWarnings = function(_, _) end,
	flushPendingUnsafeLifecycleWarnings = function() end,
	recordLegacyContextWarning = function(_, _) end,
	flushLegacyContextWarning = function() end,
	discardPendingWarnings = function() end
}

if not _G.__DEV__ then
	return New
end

local function fn(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	table.sort(v)
	return table.concat(v, ", ")
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}

function New.recordUnsafeLifecycleWarnings(p, data)
	if v7[p.type] then
		return
	end

	if typeof(data.componentWillMount) == "function" then
		table.insert(v, p)
	end

	if bit32.band(p.mode, strictMode) ~= 0 and typeof(data.UNSAFE_componentWillMount) == "function" then
		table.insert(v2, p)
	end

	if typeof(data.componentWillReceiveProps) == "function" then
		table.insert(v3, p)
	end

	if bit32.band(p.mode, strictMode) ~= 0 and typeof(data.UNSAFE_componentWillReceiveProps) == "function" then
		table.insert(v4, p)
	end

	if typeof(data.componentWillUpdate) == "function" then
		table.insert(v5, p)
	end

	if bit32.band(p.mode, strictMode) ~= 0 and typeof(data.UNSAFE_componentWillUpdate) == "function" then
		table.insert(v6, p)
	end
end

function New.flushPendingUnsafeLifecycleWarnings()
	local v8 = {}

	if #v > 0 then
		for _, v9 in v do
			v8[getComponentName(v9.type) or "Component"] = true
			v7[v9.type] = true
		end

		table.clear(v)
	end

	local v9 = {}

	if #v2 > 0 then
		for _, v10 in v2 do
			v9[getComponentName(v10.type) or "Component"] = true
			v7[v10.type] = true
		end

		table.clear(v2)
	end

	local v10 = {}

	if #v3 > 0 then
		for _, v11 in v3 do
			v10[getComponentName(v11.type) or "Component"] = true
			v7[v11.type] = true
		end

		table.clear(v3)
	end

	local v11 = {}

	if #v4 > 0 then
		for _, v12 in v4 do
			v11[getComponentName(v12.type) or "Component"] = true
			v7[v12.type] = true
		end

		table.clear(v4)
	end

	local v12 = {}

	if #v5 > 0 then
		for _, v13 in v5 do
			v12[getComponentName(v13.type) or "Component"] = true
			v7[v13.type] = true
		end

		table.clear(v5)
	end

	local v13 = {}

	if #v6 > 0 then
		for _, v14 in v6 do
			v13[getComponentName(v14.type) or "Component"] = true
			v7[v14.type] = true
		end

		table.clear(v6)
	end

	if next(v9) ~= nil then
		local v14 = fn(v9)
		console.error([[
Using UNSAFE_componentWillMount in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.

Please update the following components: %s]], v14)
	end

	if next(v11) ~= nil then
		local v14 = fn(v11)
		console.error([[
Using UNSAFE_componentWillReceiveProps in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state

Please update the following components: %s]], v14)
	end

	if next(v13) ~= nil then
		local v14 = fn(v13)
		console.error([[
Using UNSAFE_componentWillUpdate in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.

Please update the following components: %s]], v14)
	end

	if next(v8) ~= nil then
		local v14 = fn(v8)
		console.warn([[
componentWillMount has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.
* Rename componentWillMount to UNSAFE_componentWillMount to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]], v14)
	end

	if next(v10) ~= nil then
		local v14 = fn(v10)
		console.warn([[
componentWillReceiveProps has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state
* Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]], v14)
	end

	if next(v12) ~= nil then
		local v14 = fn(v12)
		console.warn([[
componentWillUpdate has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* Rename componentWillUpdate to UNSAFE_componentWillUpdate to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]], v14)
	end
end

local v8 = {}
local v9 = {}

function New.recordLegacyContextWarning(p, p2)
	local return_ = p
	local v10 = nil

	while return_ ~= nil do
		if bit32.band(return_.mode, strictMode) ~= 0 then
			v10 = return_
		end

		return_ = return_.return_
	end

	if v10 == nil then
		console.error("Expected to find a StrictMode component in a strict mode tree. This error is likely caused by a bug in React. Please file an issue.")
		return
	end

	if v9[p.type] then
		return
	end

	local v11 = v8[v10]

	if typeof(p.type) ~= "function" and (p.type.contextTypes ~= nil or p.type.childContextTypes ~= nil or p2 ~= nil and typeof(p2.getChildContext) == "function") then
		if v11 == nil then
			v11 = {}
			v8[v10] = v11
		end

		table.insert(v11, p)
	end
end

function New.flushLegacyContextWarning()
	for _, v10 in v8 do
		if #v10 == 0 then
			break
		end

		local v11 = v10[1]
		local v12 = {}

		for _, v13 in v10 do
			v12[getComponentName(v13.type) or "Component"] = true
			v9[v13.type] = true
		end

		local v15 = fn(v12)
		local success, result = pcall(function()
			setCurrentFiber(v11)
			console.error([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: %s

Learn more about this warning here: https://reactjs.org/link/legacy-context]], v15)
		end)
		resetCurrentFiber()

		if not success then
			error(result)
		end
	end
end

function New.discardPendingWarnings()
	table.clear(v)
	table.clear(v2)
	table.clear(v3)
	table.clear(v4)
	table.clear(v5)
	table.clear(v6)
	table.clear(v8)
end

return New