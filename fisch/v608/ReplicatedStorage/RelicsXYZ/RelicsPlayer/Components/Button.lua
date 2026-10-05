local RunService = game:GetService("RunService")
local parent = script.Parent.Parent
local State = require(parent.State)
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
require(script.Props)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useStyleSheet = require(hooks.useStyleSheet)

local function Button(data)
	local v = useStyleSheet("Sounds", "string")
	local v2, v3 = useSpring(1, {
		tension = 500,
		friction = 30
	})
	local v4 = React.useContext(State.Context)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(false)
	React.useEffect(function()
		local current = ref.current

		if current and data.LoadRefresh and not ref2.current then
			task.spawn(function()
				current.Visible = false
				RunService.Heartbeat:Wait()
				current.Visible = true
				RunService.Heartbeat:Wait()
				current.Visible = false
				RunService.Heartbeat:Wait()
				current.Visible = true
				RunService.Heartbeat:Wait()
			end)
		end
	end)
	local mapped = v2:map(function(p: number)
		return UDim.new((1 - p) / 2, 0)
	end)
	local hoverScale = data.HoverScale or 1.1
	local pressScale = data.PressScale or 0.9

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onHoverStart(p)
		local v5 = v4.Volume / 5
		v3:spring(hoverScale)
		Util.PlaySound(v("Sound-Hover"), p, v5)

		if data.OnHoverStart then
			data.OnHoverStart(p)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onHoverEnd(p)
		v3:spring(1)

		if data.OnHoverEnd then
			data.OnHoverEnd(p)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPress(p)
		local v5 = v4.Volume / 5
		v3:spring(pressScale)
		Util.PlaySound(v("Sound-Press"), p, v5)
	end

	local function onChange(p)
		local guiState = p.GuiState
		ref2.current = true

		if guiState == Enum.GuiState.Hover then
			onHoverStart(p) -- equivalent call inferred; original call site unknown
		elseif guiState == Enum.GuiState.Press then
			onPress(p) -- equivalent call inferred; original call site unknown
		else
			onHoverEnd(p) -- equivalent call inferred; original call site unknown
		end
	end

	local createElement = React.createElement
	local v6 = {
		[React.Tag] = Util.ClassNames("Button", data[React.Tag]),
		Size = data.Size,
		AnchorPoint = data.AnchorPoint,
		Position = data.Position,
		SizeConstraint = data.SizeConstraint,
		LayoutOrder = data.LayoutOrder,
		ZIndex = 500
	}
	local v7 = {
		Scale = React.createElement("UIPadding", {
			PaddingTop = mapped,
			PaddingLeft = mapped,
			PaddingRight = mapped,
			PaddingBottom = mapped
		}),
		Button = 0
	}
	local createElement2 = React.createElement
	local v9 = {
		ref = ref,
		Active = true,
		Image = data.Image,
		Rotation = data.Rotation,
		ScaleType = data.ScaleType,
		ImageColor3 = data.ImageColor3,
		BorderColor3 = data.BorderColor3,
		ImageRectSize = data.ImageRectSize,
		AutoButtonColor = data.AutoButtonColor,
		BorderSizePixel = data.BorderSizePixel,
		ImageRectOffset = data.ImageRectOffset,
		BackgroundColor3 = data.BackgroundColor3,
		ImageTransparency = data.ImageTransparency,
		BackgroundTransparency = data.BackgroundTransparency,
		[React.Change.GuiState] = onChange,
		[React.Event.Activated] = function(p, ...)
			onPress(p) -- equivalent call inferred; original call site unknown

			if data.OnActivated then
				data.OnActivated(p, ...)
			end
		end
	}
	local createElement3 = React.createElement
	local fragment = React.Fragment
	local foregroundImage = data.ForegroundImage

	if foregroundImage then
		local createElement4 = React.createElement
		local v13 = {
			Image = data.ForegroundImage,
			Size = 0
		}
		local size

		if data.ForegroundImageScale ~= nil then
			size = UDim2.fromScale(data.ForegroundImageScale, data.ForegroundImageScale)
		end

		v13.Size = size
		foregroundImage = createElement4("ImageLabel", v13)
	end

	v7.Button = createElement2("ImageButton", v9, createElement3(fragment, nil, {
		ForegroundImage = foregroundImage
	}, data.children))
	return createElement("Frame", v6, v7)
end

return Button