local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local parent = script.Parent
local useChild = require(parent.useChild)
local useTagged = require(parent.useTagged)
local v = {
	Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Color3 = Color3.new(),
	Vector2 = Vector2.zero,
	Vector3 = vector.create(0, 0, 0),
	string = "",
	UDim2 = UDim2.new()
}

local function useStyleSheetImpl(p: string)
	local styleSheet = useChild(useTagged("RelicsDesign")[1], p)

	if styleSheet and styleSheet:IsA("StyleSheet") then
		return styleSheet
	end

	return nil
end

local function useStyleSheet(_: string, p: string?)
	local styleSheet = useChild(useTagged("RelicsDesign")[1], "TokenOverride")

	if not (styleSheet and styleSheet:IsA("StyleSheet")) then
		styleSheet = nil
	end

	local state, setState = React.useState({})

	local function readSheet(folder)
		local propertiesByName = {}

		if folder:GetAttribute("StyleCategory") == "Tokens" then
			return (folder:GetAttributes())
		end

		for _, styleRule in folder:GetDescendants() do
			if styleRule:IsA("StyleRule") then
				propertiesByName[styleRule.Name] = styleRule:GetProperties()
			end
		end

		return propertiesByName
	end

	local readDerives

	readDerives = function(styleSheet2)
		local result = {}

		local function addProperties(items)
			for k, item in items do
				result[k] = item
			end
		end

		local v3 = readSheet(styleSheet2)

		for _, styleSheet3 in styleSheet2:GetDerives() do
			if not styleSheet3:IsA("StyleSheet") then
				continue
			end

			local v4 = readDerives(styleSheet3)

			for k, v5 in v4 do
				result[k] = v5
			end
		end

		for k, v4 in v3 do
			result[k] = v4
		end

		return result
	end

	local v3 = React.useCallback(function(p2: string)
		if v[p2] == nil then
			return p2
		end

		return v[p2]
	end, {})
	local v4 = React.useMemo(function()
		return v3(p)
	end, { p })

	local function resolveToken(state2, value: string, p2: string?)
		if value:sub(1, 1) == "$" then
			value = value:sub(2)
		end

		local v5 = state2[value]

		while typeof(v5) == "string" and v5:sub(1, 1) == "$" do
			v5 = state2[v5:sub(2)]
		end

		if v5 ~= nil then
			return v5
		end

		if p2 == nil then
			return v4
		end

		return (v3(p2))
	end

	React.useEffect(function()
		if not styleSheet then
			setState({})
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reload()
			setState((readDerives(styleSheet)))
		end

		local attributeChangedConnection = styleSheet.AttributeChanged:Connect(reload)
		reload() -- equivalent call inferred; original call site unknown
		return function()
			attributeChangedConnection:Disconnect()
		end
	end, { styleSheet })
	return React.useCallback(function(p2: string, p3)
		local function fetchPattern(p4: string)
			local result = {}

			for k, _ in state do
				if string.match(k, p4) ~= nil then
					result[k] = state[k]
				end
			end

			return result
		end

		if typeof(p3) == "table" then
			return (fetchPattern(p2))
		end

		return (resolveToken(state, p2, p3))
	end, { state }), state
end

return useStyleSheet