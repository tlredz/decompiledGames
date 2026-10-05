local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FriendInvite = require(ReplicatedStorage.Modules.FriendInvite)
local React = require(ReplicatedStorage.Packages.React)

local function useCanSendInvite(p: number)
	local state, setState = React.useState(false)
	React.useEffect(function()
		local flag = false
		setState(false)
		task.spawn(function()
			local canSendInviteToUserId = FriendInvite.CanSendInviteToUserId(p)

			if flag then
				return
			end

			setState(canSendInviteToUserId)
		end)
		return function()
			flag = true
		end
	end, { p })
	return state
end

return useCanSendInvite