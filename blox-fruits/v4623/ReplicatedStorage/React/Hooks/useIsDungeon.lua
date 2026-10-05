local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
return function()
	local v = useAttribute(workspace, "IsDungeonInstance")

	if type(v) == "boolean" then
		return v
	end

	local v2 = useMockState("IsDungeon", false)

	if v2 then
		return v2:get()
	end

	return nil
end