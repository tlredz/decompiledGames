local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local TemporaryDescription = require(game.ReplicatedStorage.React.Contexts.Inventory.TemporaryDescription)
local parentModule = require(script.Parent)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Race = UILabs.Choose(TableUtil.keys(IdMap.Race), 1),
		RaceLevel = UILabs.Slider(1, 1, 4, 1),
		HasAura = true,
		WidthPx = UILabs.Slider(200, 60, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(400, 120, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	useMockStateWriter("PlayerRaceId", IdMap.Race[p.controls.Race])
	useMockStateWriter("PlayerRaceLevel", p.controls.RaceLevel)
	useMockStateWriter("HasAuraV1", p.controls.HasAura)
	return createElement(DrawContextProvider, {
		Context = "Default"
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
			TemporaryDescription = createElement(TemporaryDescription.Provider, {
				value = {
					Description = state2,
					SetDescription = function(message: string?, itemId: number?, networkedUID: string?)
						print("description", message)

						if message == nil or itemId == nil then
							setState2(nil)
						else
							setState2((table.freeze({
								Message = message,
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
					MiscColumn = createElement(parentModule, {})
				})
			})
		})
	})
end)