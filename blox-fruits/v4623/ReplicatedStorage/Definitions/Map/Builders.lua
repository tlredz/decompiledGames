local BonusMomentBuilder = require(script.BonusMomentBuilder)
local DisplayBuilder = require(script.DisplayBuilder)
local IslandBuilder = require(script.IslandBuilder)
local MapBuilder = require(script.MapBuilder)
local ReferenceBuilder = require(script.ReferenceBuilder)
local RequirementBuilder = require(script.RequirementBuilder)
local TeleportPointBuilder = require(script.TeleportPointBuilder)
local WorldBuilder = require(script.WorldBuilder)
require(game.ReplicatedStorage.Definitions.Map.Types)
return {
	BonusMoment = BonusMomentBuilder,
	Display = DisplayBuilder,
	Reference = ReferenceBuilder,
	Requirement = RequirementBuilder,
	TeleportPoint = TeleportPointBuilder,
	World = WorldBuilder,
	Island = IslandBuilder,
	Map = MapBuilder
}