local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local parentModule = require(script.Parent)
local Box = require(script.Parent.Parent.Box)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	return createElement(React.Fragment, {}, {
		Box = createElement(Box, {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			children = {
				Default = createElement(parentModule, {
					Sx = React.useMemo(function()
						return {}
					end, {}),
					LayoutOrder = -1,
					Size = UDim2.fromOffset(100, 50),
					IsOpen = state,
					IsQuick = false,
					EquipButtonText = "Claim",
					IsEastEnabled = false,
					IsWestEnabled = true,
					HeaderOverride = "Claim your Dragon",
					BodyText = `Your Permanent Dragon Fruit has been converted \ninto the {FormatUtil.arrowBracket("Permanent Dragon (West)", "Green")} Fruit at random.`,
					OnDiscountClick = function()
						print("Discount")
					end,
					OnSelectionClick = function(p: string?)
						print((`click {p}`))
						setState(false)
					end,
					OnCloseComplete = function()
						print("Closed")
					end
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