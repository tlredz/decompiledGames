local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPC = require(ReplicatedStorage.NPCManager.NPC)
require(ReplicatedStorage.NPCManager.Types)
local modules = {
	DevBros = require(script.DevBros),
	HiddenRoom = require(script.HiddenRoom)
}
local Classes = {
	get = function(p: string?)
		if not p then
			return NPC
		end

		local v2 = modules[p]

		if v2 then
			return v2
		end

		warn((`[NPCManager] unknown NPC class "{p}"; using the base class`))
		return NPC
	end
}

function Classes.new(p, p2)
	return Classes.get(p.Class).new(p, p2)
end

return Classes