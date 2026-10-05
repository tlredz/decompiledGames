local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
return function(p: string, p2)
	local v = useMockState(p, p2)

	if v and v:get() ~= p2 then
		v:set(p2)
	end
end