local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local PreviewModel = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel)
local new = require(game.ServerStorage.Modules.Player.ReplicateGachaModel.SharedUtils.new)
local parentModule = require(script.Parent)
local createElement = React.createElement
local v = {
	Featured = require(game.ReplicatedStorage.Modules.Gacha.PreviewModels),
	Fruits = {}
}
local v2 = {
	Fruits = {},
	Featured = {}
}
local v3 = {}

for k, v4 in pairs(v) do
	v2[k] = v2[k] or {}

	for _, v5 in pairs(v4) do
		local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
		local unwrapped = ItemConfig.match(v5):unwrap()
		v3[unwrapped.Index.DebugLabel] = v5
		table.insert(v2[k], unwrapped.Index.DebugLabel)
	end
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Selection = UILabs.Choose(v2.Featured, 1)
	}
}, function(p)
	local state, setState = React.useState(nil)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		setState(nil)
		PreviewModel.Destroy()
	end

	React.useEffect(function()
		return fn
	end, {})
	React.useEffect(function()
		local flag = false

		if p.controls.Selection then
			task.spawn(function()
				local v4 = new(v3[p.controls.Selection])

				if not flag and v4 then
					setState(v4)
				end
			end)
		end

		return function()
			fn() -- equivalent call inferred; original call site unknown
			flag = true
		end
	end, { p.controls.Selection })
	return createElement(parentModule, {
		Selected = state,
		OnClose = function()
			fn() -- equivalent call inferred; original call site unknown
		end
	})
end)