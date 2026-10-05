local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = require(script.Parent.world)
require(ReplicatedStorage.packages.jecs)
return {
	SpatialChunk = world:component(),
	SpatialRegion = world:component(),
	Position = world:component(),
	Physics = world:entity(),
	NoPhysics = world:entity(),
	Model = world:component(),
	Part = world:component(),
	Zone = world:component()
}