local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local MusicData = require(shared.MusicData)

local function useMutexOwnership(p, p2: number)
	local state, setState = React.useState(function()
		if p and p._ref then
			return MusicData.GetRequiresOwnership(p)
		end

		return false
	end)
	React.useEffect(function()
		if p and p._ref then
			setState(MusicData.GetRequiresOwnership(p))
			local connection = MusicData.GetRequiresOwnershipChangedSignal(p):Connect(function(p3)
				setState(p3)
			end)
			return function()
				connection:Disconnect()
			end
		end
	end, { p })
	local state2, setState2 = React.useState(function()
		if not state then
			return true
		end

		if p and p._ref then
			return MusicData.UserHasUnlocked(p, p2)
		end

		return false
	end)
	React.useEffect(function()
		if not (p and p._ref) then
			return
		end

		if state then
			setState2(MusicData.UserHasUnlocked(p, p2))
		else
			setState2(true)
		end
	end, { state, p })
	React.useEffect(function()
		if p and p._ref then
			local connection = MusicData.GetOwnershipChangedSignal(p, p2):Connect(function(p3)
				setState2(p3)
			end)
			return function()
				connection:Disconnect()
			end
		end
	end, { p })
	return state, state2
end

return useMutexOwnership