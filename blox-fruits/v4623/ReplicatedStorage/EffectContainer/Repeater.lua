local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local v = {}
spawn(function()
	while wait() do
		for k, v2 in next, v, nil do
			if tick() - v2.LastTick > v2.Interval then
				v2.Effect:replicate(v2.Data)
				v2.LastTick = tick()
			end

			if not v2.Enabled then
				v[k] = nil
			end
		end
	end
end)
return function(state, p)
	if state.Enabled == nil then
		state.Enabled = true
	end

	if state.Enabled == false then
		if v[p.Id] then
			v[p.Id].Enabled = false
		end
	else
		assert(state.Data, "data required")
		assert(state.Interval, "interval required")
		state.LastTick = 0
		state.Effect = Effect.new(state.Effect)
		v[p.Id] = state
	end
end