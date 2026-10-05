local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = require(ReplicatedStorage.shared.ecs.world)
require(ReplicatedStorage.packages.jecs)
return {
	ActiveChunk = world:component(),
	FrustrumCullingSubject = world:entity(),
	OutsideCamera = world:entity(),
	BoundingBox = world:component(),
	BoundingSphere = world:component(),
	WindShakeRig = world:component(),
	RainNode = world:component()
}