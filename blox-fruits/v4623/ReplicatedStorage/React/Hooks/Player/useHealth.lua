local React = require(game.ReplicatedStorage.Packages.React)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
return function()
	local v2 = useMatchingChild(useCharacter(), function(humanoid)
		if humanoid:IsA("Humanoid") then
			return humanoid
		end

		return nil
	end)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local v3 = v2

		if not v3 then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tryUpdate()
			setState(table.freeze({
				Current = v3.Health,
				Max = v3.MaxHealth
			}))
		end

		local healthChangedConnection = v3:GetPropertyChangedSignal("Health"):Connect(tryUpdate)
		local maxHealthChangedConnection = v3:GetPropertyChangedSignal("MaxHealth"):Connect(tryUpdate)
		tryUpdate() -- equivalent call inferred; original call site unknown
		return function()
			healthChangedConnection:Disconnect()
			maxHealthChangedConnection:Disconnect()
		end
	end, { v2 })
	local v3 = useMockState("Health", 100)
	local v4 = useMockState("MaxHealth", 100)

	if v3 and v4 then
		return table.freeze({
			Current = v3:get(),
			Max = v4:get()
		})
	end

	return state
end