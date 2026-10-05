local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local mapIds = ItemConfig.mapIds(ItemConfig.Query.select({
	Index = {
		IdType = "Skin"
	},
	Skin = {
		IsDefault = false
	}
}))
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SizeXPx = UILabs.Slider(
			math.round(0.9 * workspace.CurrentCamera.ViewportSize.Y),
			1,
			math.round(workspace.CurrentCamera.ViewportSize.X),
			1
		),
		SizeYPx = UILabs.Slider(
			math.round(0.6 * workspace.CurrentCamera.ViewportSize.Y),
			1,
			math.round(workspace.CurrentCamera.ViewportSize.Y),
			1
		),
		Owned = UILabs.Slider(5, 0, #mapIds, 1),
		Unlocked = UILabs.Slider(5, 0, #mapIds, 1)
	}
}, function(p)
	local owned = React.useMemo(function()
		local clone = table.clone(mapIds)
		TableUtil.randomize(clone, 123)
		local result = {}

		for i = 1, math.min(#clone, p.controls.Owned) do
			table.insert(result, clone[i])
		end

		return result
	end, { p.controls.Owned })
	local unlocked = React.useMemo(function()
		local clone = table.clone(mapIds)
		TableUtil.randomize(clone, 123)
		local result = {}

		for k, _ in clone do
			if k < #owned then
				continue
			end

			if #result > p.controls.Unlocked then
				break
			else
				table.insert(result, clone[k])
			end
		end

		return result
	end, { p.controls.Unlocked, owned })
	local state, setState = React.useState(nil)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(p.controls.SizeXPx, p.controls.SizeYPx)
	}, {
		ItemSelectionContext = createElement(ItemSelection.Provider, {
			value = {
				Selection = state,
				SetSelection = function(itemId, networkedUID)
					setState(itemId and {
						ItemId = itemId,
						NetworkedUID = networkedUID
					} or nil)
				end
			}
		}, {
			Grid = createElement(parentModule, {
				Items = mapIds,
				Unlocked = unlocked,
				Owned = owned
			})
		})
	})
end)