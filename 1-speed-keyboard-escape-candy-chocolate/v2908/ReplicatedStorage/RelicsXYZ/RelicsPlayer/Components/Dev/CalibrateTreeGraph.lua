local HttpService = game:GetService("HttpService")
local parent = script.Parent.Parent
local DevTagViewer = require(script.Parent.DevTagViewer)
local DevNodeIdentifier = require(script.Parent.DevNodeIdentifier)
local TreeDebugger = require(script.Parent.TreeDebugger)
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local React = require(shared.React)
local hooks = parent2.Hooks
local useTagged = require(hooks.useTagged)
local v = {
	Frame = true,
	TextLabel = true,
	ImageLabel = true,
	ImageButton = true,
	TextButton = true,
	ScrollingFrame = true,
	CanvasGroup = true,
	TextBox = true,
	ViewportFrame = true,
	VideoFrame = true
}
local v2 = {
	"Molecules",
	"TokenOverride",
	"Layout",
	"Util",
	"Atoms",
	"Organisms"
}
local _ = {
	Good = "#00ff00",
	Medium = "#ff7300",
	Bad = "#ff0b0b"
}

local function makeIdFromInstance(parent3, p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTagsOf(parent4)
		local tags = parent4:GetTags()
		table.sort(tags)
		return table.concat(tags, "")
	end

	local tagsOf = getTagsOf(parent3) -- equivalent call inferred; original call site unknown

	while parent3.Parent ~= p.Parent and parent3.Parent ~= nil do
		parent3 = parent3.Parent
		tagsOf = getTagsOf(parent3) .. "_" .. tagsOf
	end

	return tagsOf
end

local function isTrackableUI(instance)
	return v[instance.ClassName] == true and #instance:GetTags() > 0
end

local function extractTagsFromString(selector)
	local result = {}

	for k in string.gmatch(selector, "%.[a-zA-Z0-9_]+") do
		table.insert(result, (string.sub(k, 2)))
	end

	return result
end

local function createNode(instance, current)
	return {
		id = makeIdFromInstance(instance, current),
		name = instance.Name,
		class = instance.ClassName,
		tags = instance:GetTags(),
		children = {},
		instance = instance
	}
end

local function CalibratorTreeGraph(p)
	local current = p.Root.current
	local folder = useTagged("RelicsDesign")[1]
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local v3 = React.useMemo(function()
		local v4 = {}

		for _, styleRule in folder:GetDescendants() do
			if not styleRule:IsA("StyleRule") then
				continue
			end

			for _, v5 in extractTagsFromString(styleRule.Selector) do
				v4[v5] = true
			end
		end

		local result = {}

		for k in v4 do
			table.insert(result, k)
		end

		table.sort(result)
		print("UI Calibration: Extracted", #result, "style tags:")
		return result
	end, {})
	local state3, setState3 = React.useState({})
	local ref = React.useRef({})
	local v4 = #v3 > 0
	local v5

	if v4 then
		if current == nil then
			v5 = false
		else
			v5 = ref.current ~= nil
		end
	else
		v5 = v4
	end

	local v6 = v4 and #v3 == #state3
	local v7 = math.floor(100 - #state3 / #v3 * 100)
	local v8 = v7 >= 75 and "#00ff00" or v7 >= 50 and "#ff7300" or "#ff0b0b"
	local formatted = `{#v3 - #state3}/{#v3}`

	local function exportToJson()
		local rELICSxyz_UI_Calibration_Output = workspace:FindFirstChild("RELICSxyz_UI_Calibration_Output")

		if rELICSxyz_UI_Calibration_Output then
			rELICSxyz_UI_Calibration_Output:Destroy()
		end

		local folder2 = Instance.new("Folder")
		folder2.Name = "RELICSxyz_UI_Calibration_Output"
		folder2.Parent = workspace

		-- equivalent calls inferred from this helper; original call sites unknown
		local function output(p2, name: string)
			local jSONEncode = HttpService:JSONEncode(p2)
			local moduleScript = Instance.new("ModuleScript")
			moduleScript.Name = name
			moduleScript.Source = jSONEncode
			moduleScript.Parent = folder2
			warn("UI Calibration: Succesfully outputed to file:", moduleScript)
		end

		local strip

		strip = function(data)
			local v9 = {
				id = data.id,
				name = data.name,
				tags = data.tags,
				children = {}
			}

			for _, v10 in data.children do
				table.insert(v9.children, strip(v10))
			end

			return v9
		end

		local function tokenize()
			local result = {}

			for _, child in folder:GetChildren() do
				if not (child:GetAttribute("StyleCategory") == "Tokens" and table.find(v2, child.Name) == nil) then
					continue
				end

				local attributes = child:GetAttributes()
				attributes.StyleCategory = nil
				local v9 = {}

				for k, attribute in attributes do
					table.insert(v9, {
						name = k,
						value = tostring(attribute),
						type = typeof(attribute)
					})
				end

				result[child.Name] = v9
			end

			return result
		end

		output(strip(ref.current), "Tree_Graph_Out") -- equivalent call inferred; original call site unknown
		output(tokenize(), "Table_Graph_Out") -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isDuplicate(items, instance)
		local function areTagsTheSame()
			local tags = instance:GetTags()

			for _, item in items do
				local tags2 = item:GetTags()
				local count = 0

				for _, tag in tags do
					if table.find(tags2, tag) ~= nil then
						count += 1
					end
				end

				if count == #tags2 then
					return true
				end
			end

			return false
		end

		local function areChildrenTheSame()
			for _, item in items do
				if #item:GetChildren() == #instance:GetChildren() then
					return true
				end
			end

			return false
		end

		return areTagsTheSame() and areChildrenTheSame()
	end

	local function runCalibration()
		local clone = table.clone(v3)
		local nodesById = {}
		local buildTree

		buildTree = function(instance2)
			local node = createNode(instance2, current)
			nodesById[node.id] = node
			local buildChildren

			buildChildren = function(instance)
				local children = {}

				for _, child in instance:GetChildren() do
					if isDuplicate(children, child) then
						continue
					end

					local v9

					if v[child.ClassName] == true then
						v9 = #child:GetTags() > 0
					else
						v9 = false
					end

					if v9 then
						table.insert(children, child)
						local v10 = buildTree(child)

						if v10 then
							table.insert(node.children, v10)
						end
					else
						buildChildren(child)
					end
				end
			end

			buildChildren(instance2)

			for _, tag in node.tags do
				local index = table.find(clone, tag)

				if index then
					table.remove(clone, index)
				end
			end

			return node
		end

		local tree = buildTree(current)
		ref.current = tree
		setState3(clone)
		print("UI Calibration: Initial tree built.")
		local descendantAddedConnection = tree.instance.DescendantAdded:Connect(function(descendant)
			local v9 = descendant.Parent == nil and {} or descendant.Parent:GetChildren()
			local index = table.find(v9, descendant)

			if index then
				table.remove(v9, index)
			end

			local v10

			if v[descendant.ClassName] == true then
				v10 = #descendant:GetTags() > 0
			else
				v10 = false
			end

			if v10 and not isDuplicate(v9, descendant) and nodesById[makeIdFromInstance(descendant, current)] == nil then
				local parent3 = descendant.Parent

				while nodesById[makeIdFromInstance(parent3, current)] == nil and parent3.Parent ~= tree.instance.Parent and parent3.Parent ~= nil do
					parent3 = parent3.Parent
				end

				local v11 = nodesById[makeIdFromInstance(parent3, current)]

				if not v11 then
					return
				end

				local node = createNode(descendant, current)
				nodesById[node.id] = node
				table.insert(v11.children, node)

				for _, tag in node.tags do
					local index2 = table.find(clone, tag)

					if index2 then
						table.remove(clone, index2)
					end
				end

				setState3({ table.unpack(clone) })
				print("UI Calibration: Updated tree.")
			end
		end)
		return function()
			descendantAddedConnection:Disconnect()
		end
	end

	React.useEffect(function()
		if not v5 then
			return
		end

		print("UI Calibration: Initializing..")
		local v9 = runCalibration()
		return function()
			v9()
		end
	end, { v5, v3 })
	local createElement = React.createElement
	local fragment = React.Fragment
	local createElement2 = React.createElement
	local text

	if v4 then
		if state2 then
			text = "<font color=\"#00ff00\">Exported!</font>"
		elseif state then
			text = `<font color="{v8}">{v7}%</font> <font color="#FFF">Export now</font>`
		else
			text = v6 and "100% Calibrated! Click to export" or `<font color="{v8}">{v7}%</font> Calibrated ({formatted})`
		end
	else
		text = "Calibration initializing.."
	end

	local textColor

	if v6 then
		textColor = Color3.fromRGB(0, 255, 0)
	else
		textColor = Color3.fromRGB(200, 200, 200)
	end

	return createElement(fragment, nil, {
		Calibration = createElement2("TextButton", {
			Text = text,
			RichText = true,
			TextColor3 = textColor,
			Position = UDim2.new(0.5, 0, 0, -5),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Size = UDim2.new(),
			AutomaticSize = Enum.AutomaticSize.XY,
			[React.Event.Activated] = function()
				if state2 then
					return
				end

				exportToJson()
				setState2(true)
				task.delay(0.8, function()
					setState2(false)
				end)
			end,
			[React.Event.MouseEnter] = function()
				setState(true)
			end,
			[React.Event.MouseLeave] = function()
				setState(false)
			end
		}),
		DevTagViewer = React.createElement(DevTagViewer, {
			Title = "Uncalibrated Tags",
			Root = p.Root,
			Tags = state3
		}),
		DevNodeIdentifier = React.createElement(DevNodeIdentifier, {
			ValidateSelection = isTrackableUI,
			GetId = function(p2)
				return (makeIdFromInstance(p2, current))
			end
		}),
		TreeDebugger = React.createElement(TreeDebugger, {
			Tree = ref,
			TreeUpdated = state3
		})
	})
end

return CalibratorTreeGraph