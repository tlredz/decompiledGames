local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local parent2 = script.Parent
local Button = require(parent2.Button)
local Util = require(parent.Util)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local useSpring = require(hooks.useSpring)
local useStyleSheet = require(hooks.useStyleSheet)

local function TabButton(data)
	local v = useStyleSheet("Palette", "Color3")
	local v2 = useStyleSheet("Icons", "string")
	local v3, v4 = React.useBinding(data.Active and 1 or 0)
	local v5 = useSpring(v3)
	local mapped = v5:map(function(p)
		return v("Color-White"):Lerp(v("Color-Active"), p)
	end)
	local image = v2((`Image-NavBar-{data.Tab}`))
	local v7 = v2(`Image-NavOverlay-{data.Tab}`, nil)
	local ref = React.useRef(nil)
	useClock(data.Spin and 30 or 1, function(p)
		if not data.Spin then
			return
		end

		local current = ref.current

		if current then
			current.Rotation += p * 90
			current.Rotation %= 360
		end
	end)
	v4(data.Active and 1 or 0)
	local createElement = React.createElement
	local v9 = {
		[React.Tag] = Util.ClassNames("NavItemButton", data.Active and "isActive" or "", data[React.Tag]),
		OnActivated = data.OnActivated,
		LayoutOrder = data.Order
	}
	local createElement2 = React.createElement
	local v12 = {
		[React.Tag] = "NavItemBackground",
		BackgroundTransparency = v5:map(function(p: number)
			return 1 - p
		end)
	}
	local children = {
		Stroke = React.createElement("UIStroke", {
			Color = mapped,
			Transparency = v5:map(function(p: number)
				return 1 - p * 0.5
			end)
		}),
		Image = 0,
		Text = 0
	}
	local createElement3 = React.createElement
	local v14 = {
		[React.Tag] = "IconImage",
		ImageColor3 = mapped,
		Image = image,
		ref = ref
	}

	if v7 then
		v7 = React.createElement("ImageLabel", {
			[React.Tag] = "IconOverlay",
			Image = v7,
			ImageColor3 = mapped,
			ImageTransparency = v5:map(function(p)
				return 1 - p
			end)
		})
	end

	children.Image = createElement3("ImageLabel", v14, {
		Overlay = v7
	})
	children.Text = React.createElement("TextLabel", {
		[React.Tag] = "NameLabel",
		TextColor3 = mapped,
		Text = data.Tab
	})
	return createElement(Button, v9, {
		Background = createElement2("Frame", v12, children)
	})
end

return TabButton