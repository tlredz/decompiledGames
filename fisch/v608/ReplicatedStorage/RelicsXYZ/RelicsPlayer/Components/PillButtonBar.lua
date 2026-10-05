local parent = script.Parent.Parent
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local parent2 = script.Parent
local PillButton = require(parent2.PillButton)

local function PillButtonBar(data)
	local state, setState = React.useState(data.InitialSelection or "RECENTS")
	local textTransparency, v2 = React.useBinding(0)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local current = ref.current

		if current and data.InitialCanvasX then
			current.CanvasPosition = Vector2.new(data.InitialCanvasX, 0)
		end
	end, {})
	useClock(30, function()
		local current = ref.current

		if current then
			local X = current.CanvasPosition.X
			v2((math.clamp(X / 100, 0, 1)))

			if data.OnCanvasXChanged then
				data.OnCanvasXChanged(X)
			end
		end
	end, {})
	local count = 0
	local children = {}

	for _, _ in pairs(data.ButtonInfo) do
		count += 1
	end

	for _, info in pairs(data.ButtonInfo) do
		local title = info.Title
		local title2 = info.Title
		local createElement = React.createElement
		local v5 = {
			[React.Tag] = `is{Util.FormatTitle(title)}`,
			Info = info,
			IsSelected = state == title
		}

		function v5.OnClick()
			setState(title)
			data.OnTabSelected(title)
		end

		children[title2] = createElement(PillButton, v5)
	end

	local createElement = React.createElement
	local v4 = {
		[React.Tag] = Util.ClassNames("ButtonBar", data[React.Tag])
	}
	local children2 = {
		Header = React.createElement("Frame", {
			[React.Tag] = "Header"
		}, {
			TextLabel = React.createElement("TextLabel", {
				[React.Tag] = "HeaderText",
				TextTransparency = textTransparency
			})
		}),
		Scrolling = 0
	}
	local createElement4 = React.createElement
	local canvasSize

	if count < 3 then
		canvasSize = UDim2.fromScale(0, 0)
	else
		canvasSize = UDim2.fromScale(1.85, 0)
	end

	children2.Scrolling = createElement4("ScrollingFrame", {
		CanvasSize = canvasSize,
		ref = ref
	}, children, {
		TextBuffer = React.createElement("Frame", {
			[React.Tag] = "TextBuffer"
		})
	})
	return createElement("Frame", v4, children2)
end

return PillButtonBar