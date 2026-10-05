local React = require(game.ReplicatedStorage.Packages.React)
local BannerClient = require(game.ReplicatedStorage.Controllers.BannerClient)
require(game.ReplicatedStorage.Modules.Gacha.ClientBannerTypes)
return function()
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local function fn()
			setState(BannerClient.TryGetBannerItemIfActive())
		end

		local connection = BannerClient.ConnectOnBannerItemChanged(fn)
		task.spawn(fn)
		return function()
			connection:Disconnect()
		end
	end, {})
	return state
end