local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage.Effect)
local isRunning = RunService:IsRunning()
local require2 = require
local Effects = {
	resolve = function(p)
		local module = Effect.getModule(p)

		if isRunning then
			return module
		end

		return (require2(module))
	end
}

function Effects.new(p, flag: boolean?)
	return Effect.new(Effects.resolve(p), flag)
end

function Effects:play(p2, p3)
	Effects.new(self):play(p2, p3)
end

function Effects:replicate(p2, p3)
	Effects.new(self):replicate(p2, p3)
end

function Effects.playExceptCaster(p, p2, p3)
	local v = Effects.new(p2)

	if p.player then
		v:playExcept(p3, p.player)
	else
		v:play(p3)
	end
end

function Effects.replicateExceptCaster(p, p2, p3)
	local v = Effects.new(p2)

	if p.player then
		v:replicateExcept(p3, p.player)
	else
		v:replicate(p3)
	end
end

function Effects.playLocal(p, p2)
	if RunService:IsClient() then
		return Effects.new(p):play(p2)
	end

	return nil
end

function Effects.replicateLocal(p, p2)
	if RunService:IsClient() then
		return Effects.new(p):replicate(p2)
	end

	return nil
end

return Effects