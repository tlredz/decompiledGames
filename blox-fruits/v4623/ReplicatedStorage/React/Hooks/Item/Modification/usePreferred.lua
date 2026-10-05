local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useData)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("UI"):tag("React"):traceback():display():build()
return function()
	local v2 = useData()
	local v3 = useAdorneeData()
	return React.useMemo(function()
		local preferred = Modification.getPreferred(v2, v3)
		v.trace(function()
			local debugLabels = {}

			for _, v4 in ItemConfig.map(preferred) do
				table.insert(debugLabels, v4.Index.DebugLabel)
			end

			return "preferred:", debugLabels
		end)
		table.freeze(preferred)
		return preferred
	end, { v2, v3 })
end