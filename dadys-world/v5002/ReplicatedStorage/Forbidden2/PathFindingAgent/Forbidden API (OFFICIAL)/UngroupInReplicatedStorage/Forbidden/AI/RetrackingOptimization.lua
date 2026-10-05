local parent = script.Parent.Parent
local ConfigHandler = require(parent.AI.ConfigHandler)
local RetrackingOptimization = {}

function RetrackingOptimization.GetDynamicRetrackTimer(p, p2, p3: string)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if p3 == "DirectMoveTo" then
		local retrackTimeFunction = activeConfig.Tracking.DynamicRetrack.MoveTo.GetRetrackTimeFunction(p, p2)

		if retrackTimeFunction == nil then
			return activeConfig.Tracking.DynamicRetrack.MoveTo.MaxTimer
		end

		return (math.clamp(
			retrackTimeFunction,
			activeConfig.Tracking.DynamicRetrack.MoveTo.MinTimer,
			activeConfig.Tracking.DynamicRetrack.MoveTo.MaxTimer
		))
	else
		if p3 ~= "Pathfind" then
			warn("this should not occur")
			return 1
		end

		local retrackTimeFunction = activeConfig.Tracking.DynamicRetrack.Pathfind.GetRetrackTimeFunction(p, p2)

		if retrackTimeFunction == nil then
			return activeConfig.Tracking.DynamicRetrack.Pathfind.MaxTimer
		end

		return (math.clamp(
			retrackTimeFunction,
			activeConfig.Tracking.DynamicRetrack.Pathfind.MinTimer,
			activeConfig.Tracking.DynamicRetrack.Pathfind.MaxTimer
		))
	end
end

function RetrackingOptimization.ShouldRetrack(p, p2, p3: string)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if p3 == "DirectMoveTo" then
		local shouldRetrackFunction = activeConfig.Tracking.DynamicRetrack.MoveTo.ShouldRetrackFunction(p, p2)

		if shouldRetrackFunction == nil then
			return activeConfig.Tracking.DynamicRetrack.MoveTo.MaxTimer
		end

		return shouldRetrackFunction
	else
		if p3 ~= "Pathfind" then
			warn("this should not occur")
			return false
		end

		local shouldRetrackFunction = activeConfig.Tracking.DynamicRetrack.Pathfind.ShouldRetrackFunction(p, p2)

		if shouldRetrackFunction == nil then
			return activeConfig.Tracking.DynamicRetrack.Pathfind.MaxTimer
		end

		return shouldRetrackFunction
	end
end

return RetrackingOptimization