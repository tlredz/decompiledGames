local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local hooks = parent.Hooks
local useSignal = require(hooks.useSignal)

local function useEmotes()
	local state, setState = React.useState(Emotes.GetEmotes)
	useSignal(Emotes.EmoteAdded, function(p)
		setState(function(p2)
			if p2[p.Name] then
				return p2
			end

			local clone = table.clone(p2)
			clone[p.Name] = p
			return clone
		end)
	end, { state })
	useSignal(Emotes.EmoteRemoved, function(p)
		setState(function(p2)
			if not p2[p.Name] then
				return p2
			end

			local clone = table.clone(p2)
			clone[p.Name] = nil
			return clone
		end)
	end, { state })
	useSignal(Emotes.OwnerAdded, function()
		setState(function(p)
			return table.clone(p)
		end)
	end, { state })
	useSignal(Emotes.OwnerRemoved, function()
		setState(function(p)
			return table.clone(p)
		end)
	end, { state })
	return state
end

return useEmotes