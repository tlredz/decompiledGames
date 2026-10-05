local React = require(game.ReplicatedStorage.Packages.React)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function measureTextBounds(text: string, textSize: number, font, p: number?)
	return TextMetrics.measureRich(text, textSize, font, p)
end

local function LogText(data)
	local ref = React.useRef(nil)
	local state, setState = React.useState(0)
	local ref2 = React.useRef(state)
	ref2.current = state
	local font = data.Font

	if not font then
		if data.Bold then
			font = Theme.FontBold
		else
			font = Theme.MonoFont
		end
	end

	local textSize = data.TextSize or Theme.RawTextSize
	local textOverflowMode = data.TextOverflowMode or "clip"
	local textBounds = measureTextBounds(data.Text, textSize, font, nil) -- equivalent call inferred; original call site unknown
	local v2 = textOverflowMode ~= "wrap" and 0 or textBounds.X

	if textOverflowMode == "wrap" and state > 0 then
		v2 = math.min(v2, state)
	end

	local v3 = math.max(1, (math.ceil(v2)))
	local v4

	if textOverflowMode == "wrap" then
		local text2 = data.Text
		v4 = TextMetrics.measureRich(text2, textSize, font, v3)
	else
		v4 = textBounds
	end

	local v5 = math.max(textSize + 2, (math.ceil(v4.Y)))
	local textWrapped

	if textOverflowMode == "wrap" then
		textWrapped = string.find(data.Text, "\n", 1, true) ~= nil or math.ceil(v4.Y) > math.ceil(textBounds.Y)
	else
		textWrapped = false
	end

	local function updateAvailableWidth(p)
		if not (textOverflowMode == "wrap" and p) then
			return
		end

		local current = math.max(0, (math.floor(p.AbsoluteSize.X)))
		local parent = p.Parent

		if parent and parent:IsA("GuiObject") then
			current = math.max(0, (math.floor(parent.AbsoluteSize.X)))
		end

		if current == ref2.current then
			return
		end

		ref2.current = current
		setState(current)
	end

	React.useEffect(function()
		task.defer(function()
			updateAvailableWidth(ref.current)
		end)
	end, { data.Text, textOverflowMode, textSize })
	local v9 = {
		ref = ref
	}
	local automaticSize

	if textOverflowMode == "wrap" then
		automaticSize = Enum.AutomaticSize.Y
	else
		automaticSize = Enum.AutomaticSize.X
	end

	v9.AutomaticSize = automaticSize
	v9.BackgroundTransparency = 1
	v9.Font = font
	v9.LayoutOrder = data.LayoutOrder
	v9.RichText = true
	local size

	if textOverflowMode == "wrap" then
		size = UDim2.fromOffset(v3, v5)
	else
		size = UDim2.fromOffset(0, v5)
	end

	v9.Size = size
	v9.Text = data.Text
	v9.TextColor3 = data.TextColor3 or Theme.Text
	v9.TextScaled = false
	v9.TextSize = textSize
	v9.TextStrokeTransparency = 1
	v9.TextWrapped = textWrapped
	v9.TextXAlignment = Enum.TextXAlignment.Left
	local textYAlignment

	if textWrapped then
		textYAlignment = Enum.TextYAlignment.Top
	else
		textYAlignment = Enum.TextYAlignment.Center
	end

	v9.TextYAlignment = textYAlignment

	v9[React.Change.AbsoluteSize] = function(p)
		updateAvailableWidth(p)
	end

	return createElement("TextLabel", v9)
end

return React.memo(LogText)