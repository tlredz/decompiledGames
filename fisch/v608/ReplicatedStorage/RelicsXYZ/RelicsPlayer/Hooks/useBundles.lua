local parent = script.Parent
local useSignal = require(parent.useSignal)
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
local Bundles = require(shared.Bundles)

local function useBundles()
	local state, setState = React.useState(Bundles.GetBundles)

	local function updateBundles()
		setState(Bundles.GetBundles)
	end

	useSignal(Bundles.BundleAdded, updateBundles, {})
	useSignal(Bundles.BundleRemoved, updateBundles, {})
	return state
end

return useBundles