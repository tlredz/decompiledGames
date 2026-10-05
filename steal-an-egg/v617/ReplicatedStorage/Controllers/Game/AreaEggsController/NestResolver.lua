local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
require(ReplicatedStorage.Shared.Types.AreaEggs)
local t = require(ReplicatedStorage.Packages.t)
local world = Workspace.World
assert(world:IsA("Folder"), "Workspace.World must be a Folder")
local areas = world.Areas
assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
local guardAreas = areas.GuardAreas
assert(guardAreas:IsA("Folder"), "Workspace.World.Areas.GuardAreas must be a Folder")
return {
	Resolve = function(p)
		t.strict(t.string)(p.AreaId)
		t.strict(t.string)(p.NestId)
		local model = guardAreas[p.AreaId]
		assert(model:IsA("Model"), (`Guard area {p.AreaId} must be a Model`))
		return AreaEggSlotIdentity.NestFor(model, p.NestId)
	end
}