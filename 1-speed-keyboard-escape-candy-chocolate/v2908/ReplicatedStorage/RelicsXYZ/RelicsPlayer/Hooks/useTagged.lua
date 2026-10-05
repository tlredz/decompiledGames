local CollectionService = game:GetService("CollectionService")
local parent = script.Parent
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
local useSignal = require(parent.useSignal)

local function useTagged(tag: string)
	local thread = nil
	local state, setState = React.useState(function()
		return CollectionService:GetTagged(tag)
	end)
	local v = React.useMemo(function()
		return CollectionService:GetInstanceAddedSignal(tag)
	end, { tag })
	local v2 = React.useMemo(function()
		return CollectionService:GetInstanceRemovedSignal(tag)
	end, { tag })
	local v3 = React.useCallback(function()
		if thread then
			return
		end

		thread = task.defer(function()
			thread = nil
			setState(CollectionService:GetTagged(tag))
		end)
	end, { tag })
	useSignal(v, v3, { tag })
	useSignal(v2, v3, { tag })
	return state
end

return useTagged