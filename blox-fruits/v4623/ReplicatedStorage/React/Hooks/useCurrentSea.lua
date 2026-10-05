local React = require(game.ReplicatedStorage.Packages.React)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
return function()
	local v, v2 = useGlobalState("CurrentSea", nil)
	local v3 = useMockState("MockCurrentSea", "Sea1")

	if v3 ~= nil then
		v = v3:get()
	end

	React.useEffect(function()
		if v ~= nil then
			return function() end
		end

		local flag = false
		task.spawn(function()
			local currentSeaAsync = Realm.getCurrentSeaAsync()

			if flag then
				return
			end

			v2(currentSeaAsync)
		end)
		return function()
			flag = true
		end
	end, { v })
	return v
end