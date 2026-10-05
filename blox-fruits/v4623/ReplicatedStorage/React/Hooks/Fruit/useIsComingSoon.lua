local React = require(game.ReplicatedStorage.Packages.React)
local ComingSoonUtil = require(game.ReplicatedStorage.Util.ComingSoonUtil)
require(game.ReplicatedStorage.ItemConfig)
return function(p: string)
	local state, setState = React.useState(ComingSoonUtil.getIsComingSoonList())
	React.useEffect(function()
		local onChangedConnection = ComingSoonUtil.OnChanged:Connect(function()
			setState(ComingSoonUtil.getIsComingSoonList())
		end)
		return function()
			onChangedConnection:Disconnect()
		end
	end, {})
	return (React.useMemo(function()
		for _, v in state do
			if v.Index.StorageKey == `Permanent {p}` then
				return true
			end
		end

		return false
	end, { state, p }))
end