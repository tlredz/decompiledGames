local relicsXYZ = script:FindFirstAncestor("RelicsXYZ")
local shared = relicsXYZ.Shared
local Auras = require(shared.Auras)
local React = require(shared.React)
local hooks = relicsXYZ.RelicsPlayer.Hooks
local useSignal = require(hooks.useSignal)

local function useAuras()
	local state, setState = React.useState(Auras.GetAuras)
	useSignal(Auras.AuraAdded, function()
		setState(Auras.GetAuras())
	end, {})
	useSignal(Auras.AuraRemoved, function()
		setState(Auras.GetAuras())
	end, {})
	return state
end

return useAuras