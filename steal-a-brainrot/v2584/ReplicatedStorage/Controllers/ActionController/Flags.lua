local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
return table.freeze({
	DraggingThreshold = FastFlags.Replicated("ActionController.DraggingThreshold", Asserts.Finite, 4),
	TouchDuration = FastFlags.Replicated("ActionController.TouchDuration", Asserts.Finite, 0.2)
})