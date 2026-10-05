local React = require(game.ReplicatedStorage.Packages.React)
local PolicyServiceClient = require(game.ReplicatedStorage.Controllers.PolicyServiceClient)
local Global = require(game.ReplicatedStorage.Global)
local v = {
	ArePaidRandomItemsRestricted = false,
	IsPaidItemTradingAllowed = true
}
return function()
	if Global.IsUnitTest then
		return (React.useState(v))
	end

	local state, setState = React.useState((PolicyServiceClient.TryGet()))
	React.useEffect(function()
		local thread = task.spawn(function()
			local async, v2 = PolicyServiceClient.GetAsync()
			setState(async, v2)
		end)
		return function()
			task.cancel(thread)
		end
	end, {})
	return state
end