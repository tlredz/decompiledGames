local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
return function(flag: boolean)
	local state, setState = React.useState(flag)
	return {
		on = state,
		enable = React.useCallback(function()
			setState(true)
		end, {}),
		disable = React.useCallback(function()
			setState(false)
		end, {}),
		toggle = React.useCallback(function()
			setState(function(p)
				return not p
			end)
		end, {})
	}
end