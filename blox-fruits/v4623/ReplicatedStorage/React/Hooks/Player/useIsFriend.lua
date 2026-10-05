local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local v = {}

local function useIsFriend(p: number)
	local state, setState = React.useState(v[p] or false)
	React.useEffect(function()
		local v2 = v[p]

		if v2 ~= nil then
			setState(v2)
			return
		end

		local localPlayer = Players.LocalPlayer

		if localPlayer == nil then
			return
		end

		local flag = false
		setState(false)
		task.spawn(function()
			local success, result = pcall(localPlayer.IsFriendsWithAsync, localPlayer, p)

			if not success then
				return
			end

			v[p] = result

			if flag then
				return
			end

			setState(result)
		end)
		return function()
			flag = true
		end
	end, { p })
	return state
end

return useIsFriend