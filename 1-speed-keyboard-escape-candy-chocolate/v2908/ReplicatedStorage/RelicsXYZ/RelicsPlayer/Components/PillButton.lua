local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local State = require(parent.State)
local Util = require(parent.Util)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useStyleSheet = require(hooks.useStyleSheet)

local function PillButton(data)
	local v = useStyleSheet("Palette", "Color3")
	local v2 = useStyleSheet("Sounds", "string")
	local isSelected = data.IsSelected
	local info = data.Info
	local onClick = data.OnClick
	local v3 = React.useContext(State.Context)
	local ref = React.useRef(nil)
	local v4, v5 = React.useBinding(isSelected and 1 or 0)
	local color = Color3.fromRGB(0, 0, 0)
	local color2 = info.Color
	React.useEffect(function()
		v5(isSelected and 1 or 0)
	end, { isSelected })
	local mapped = useSpring(v4, {
		tension = 500,
		friction = 40
	}):map(function(value: number)
		return (math.clamp(value, 0, 1))
	end)
	return React.createElement("TextButton", {
		[React.Tag] = Util.ClassNames("TabButton", data[React.Tag]),
		BackgroundColor3 = info.Color,
		LayoutOrder = info.Order,
		ref = ref,
		[React.Event.MouseEnter] = function()
			if ref.current then
				Util.PlaySound(v2("Sounds-Hover"), ref.current, v3.Volume / 5)
			end
		end,
		[React.Event.MouseButton1Down] = function()
			if ref.current then
				Util.PlaySound(v2("Sounds-Press"), ref.current, v3.Volume / 5)
			end
		end,
		[React.Event.MouseButton1Click] = function()
			onClick()
		end
	}, {
		TextLabel = React.createElement("TextLabel", {
			Text = info.Title,
			TextColor3 = mapped:map(function(p: number)
				return color2:Lerp(color, p)
			end)
		}),
		Frame = React.createElement("Frame", {
			BackgroundColor3 = mapped:map(function(p: number)
				return v("Color-BackgroundMidPanel"):Lerp(info.Color, p)
			end)
		})
	})
end

return PillButton