local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.PseudoEnum)
local parentModule = require(script.Parent)
local Box = require(script.Parent.Parent.Box)
local v = {
	Image = "http://www.roblox.com/asset/?id=9735074448",
	ImageRectOffset = Vector2.new(0, 0),
	ImageRectSize = Vector2.zero
}
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	return createElement(React.Fragment, {}, {
		Box = createElement(Box, {
			Sx = React.useMemo(function()
				return {
					CornerRadius = UDim.new(0, 0),
					SurfaceTransparency = 0.35,
					SurfaceColor3 = Color3.fromRGB(0, 0, 0),
					OnSurfaceTransparency = 0,
					OnSurfaceColor3 = Color3.fromRGB(255, 255, 255),
					MarginLeft = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingList = UDim.new(0, 5),
					TextSizePx = 40,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					HorizontalFlex = Enum.UIFlexAlignment.Fill
				}
			end, {}),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(400, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.Y,
			children = {
				NumberInput = createElement(parentModule, {
					OnFocusChanged = function(flag: boolean)
						print("IconTextIcon focused:", flag)
					end,
					OnTextChanged = function(value: string)
						print("IconTextIcon text changed:", value)
						local v2 = tonumber(value)
						print("IconTextIcon is number:", v2)

						if not v2 then
							return state2 or ""
						end

						local v3 = value:gsub("%s", "")
						print("IconTextIcon formatted text:", v3)
						setState2(v3)
						return v3
					end,
					Text = state2,
					PlaceholderText = "Number Only",
					LayoutOrder = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					BeforeIcon = v,
					AfterIcon = v
				}),
				TextInput = createElement(parentModule, {
					OnTextChanged = function(p: string)
						setState(p)
						return p
					end,
					Text = state,
					LayoutOrder = 2,
					Size = UDim2.fromOffset(300, 60),
					AfterIcon = v
				})
			}
		})
	})
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(component, {}), p)))
	end)
	return function()
		root:unmount()
	end
end