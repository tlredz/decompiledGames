local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		WidthPx = UILabs.Slider(600, 200, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(400, 160, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	return createElement(Navigation.Provider, {
		value = {
			Group = PseudoEnum.InventoryItemGroup.Build,
			Bracket = state2,
			SortType = PseudoEnum.InventorySortType.Rarity,
			InitialSelection = nil,
			SetNavigation = function(_, p2, _, _)
				if state2 ~= p2 then
					setState2(p2)
				end
			end
		}
	}, {
		ItemSelection = createElement(ItemSelection.Provider, {
			value = {
				Selection = state,
				SetSelection = function(itemId: number?, networkedUID: string?)
					if itemId == nil then
						setState(nil)
					else
						setState((table.freeze({
							ItemId = itemId,
							NetworkedUID = networkedUID
						})))
					end
				end
			}
		}, {
			Panel = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(widthPx, heightPx)
			}, {
				BuildMenu = createElement(parentModule, {})
			})
		})
	})
end)