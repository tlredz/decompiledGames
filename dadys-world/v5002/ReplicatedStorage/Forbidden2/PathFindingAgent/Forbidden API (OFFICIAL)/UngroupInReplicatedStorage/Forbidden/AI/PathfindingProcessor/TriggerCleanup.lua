local parent = script.Parent.Parent.Parent
local ConfigHandler = require(parent.AI.ConfigHandler)
local DirectMoveTo = require(parent.AI.DirectMoveTo)
local WaypointLooper = require(parent.AI.PathfindingProcessor.WaypointLooper)
local WaypointsVisualization = require(parent.AI.Visualization.WaypointsVisualization)
local Common = require(parent.Common)
local _ = {
	TriggerCleanup = function(p)
		WaypointsVisualization.DeleteVisualization(p)
		ConfigHandler.TriggerCleanup(p)
		WaypointLooper.TriggerCleanup(p)
		DirectMoveTo.TriggerCleanup(p)
		Common.TriggerCleanupTypeHelp(p)
	end
}