local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
require(game.ReplicatedStorage.Types.StatTypes)
local PlayerStats = {
	getMockKey = function(p, p2: string)
		return (`{p}_{p2}`)
	end,
	useFolder = function(p)
		return function()
			return useMatchingChild(useMatchingChild(useDataInstance(), function(folder)
				if folder:IsA("Folder") and folder.Name == "Stats" then
					return folder
				end

				return nil
			end), function(folder)
				if folder:IsA("Folder") and folder.Name == p then
					return folder
				end

				return nil
			end)
		end
	end
}

function PlayerStats.useValue(p, p2: string, p3: number?)
	local v = PlayerStats.useFolder(p)
	return function()
		local v4 = useProperty(useMatchingChild(v(), function(intValue)
			if intValue:IsA("IntValue") and intValue.Name == p2 then
				return intValue
			end

			return nil
		end), function(p4)
			return p4 and p4.Value or nil
		end)
		local v5 = useMockState(PlayerStats.getMockKey(p, p2), p3)

		if v5 then
			return v5:get()
		end

		return v4
	end
end

return PlayerStats