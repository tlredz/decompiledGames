local Anims = require(game.ReplicatedStorage.Util.Anims)
require(script.Parent.Parent.Types)
local v = {
	stop = function(instance, p: number?)
		pcall(function()
			instance:Stop(p)
		end)
		pcall(function()
			instance:Destroy()
		end)
	end
}

function v.play(p, p2: string, options, maid)
	local v2 = options or {}
	local v3 = Anims:Get(p, p2)
	assert(v3 ~= nil, (`Animation "{p2}" is unavailable`))

	if v2.Looped ~= nil then
		v3.Looped = v2.Looped
	end

	if v2.Priority ~= nil then
		v3.Priority = v2.Priority
	end

	v3:Play(v2.FadeTime, v2.Weight, v2.Speed)
	maid:GiveTask(function()
		v.stop(v3, v2.FadeTime)
	end)
	return v3
end

return table.freeze(v)