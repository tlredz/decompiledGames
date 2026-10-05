local v = nil
task.defer(function()
	local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
	v = Promise
end)

local function executeSequence(instance, p)
	local animationSequence = p.AnimationSequence
	local executeStep

	executeStep = function(p2: number)
		if not (instance:IsDescendantOf(workspace) and p2 ~= #animationSequence + 1) then
			return v.resolve()
		end

		local v2 = animationSequence[p2]
		return v.new(function(callback)
			v2.Animate(instance)
			callback()
		end):andThenCall(executeStep, p2 + 1)
	end

	return executeStep(1):catch(function(p2)
		warn(p2)
	end):finally(function(p2)
		if p2 == "Cancelled" and instance:IsDescendantOf(workspace) then
			p.ApplyEndState(instance)
		end
	end)
end

return function(p, p2)
	return executeSequence(p, p2)
end