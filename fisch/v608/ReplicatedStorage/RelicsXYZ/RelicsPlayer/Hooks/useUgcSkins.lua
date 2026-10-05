local parent = script.Parent
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
local Boombox = require(shared.Boombox)
local useSignal = require(parent.useSignal)

local function useUgcSkins()
	local state, setState = React.useState(Boombox.GetSkins)
	useSignal(Boombox.SkinAdded, function()
		setState(Boombox.GetSkins())
	end, {})
	useSignal(Boombox.SkinRemoved, function()
		setState(Boombox.GetSkins())
	end, {})
	return state
end

return useUgcSkins