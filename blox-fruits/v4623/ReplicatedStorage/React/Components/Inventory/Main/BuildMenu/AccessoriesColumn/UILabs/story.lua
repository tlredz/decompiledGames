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
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
require(game.ReplicatedStorage.AccessoriesShared)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Empty = {},
	TrinketsOnly = {
		["00000000-0000-0000-0000-000000000001"] = {
			Equipped = true,
			Grade = 1,
			Modifiers = { "Punchy", "Brutal" },
			Name = "Ring of Striking",
			Type = "Trinket"
		},
		["00000000-0000-0000-0000-000000000002"] = {
			Equipped = true,
			Grade = 2,
			Modifiers = { "Levitating", "Airborne" },
			Name = "Ring of Carving",
			Type = "Trinket"
		}
	},
	Full = {
		["00000000-0000-0000-0000-000000000001"] = {
			Equipped = true,
			Grade = 1,
			Modifiers = { "Punchy", "Brutal" },
			Name = "Ring of Striking",
			Type = "Trinket"
		},
		["00000000-0000-0000-0000-000000000002"] = {
			Equipped = true,
			Grade = 2,
			Modifiers = { "Levitating", "Airborne" },
			Name = "Ring of Carving",
			Type = "Trinket"
		},
		["00000000-0000-0000-0000-000000000003"] = {
			Equipped = true,
			Grade = 0,
			Modifiers = {},
			Name = "Divine Cloak",
			Type = "Super"
		}
	}
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Accessories = UILabs.Choose({ "Full", "TrinketsOnly", "Empty" }, 1),
		WidthPx = UILabs.Slider(160, 60, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(400, 120, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	useMockStateWriter("PlayerDynamicAccessories", v[p.controls.Accessories])
	return createElement(DrawContextProvider, {
		Context = "Default"
	}, {
		Navigation = createElement(Navigation.Provider, {
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
					AccessoriesColumn = createElement(parentModule, {})
				})
			})
		})
	})
end)