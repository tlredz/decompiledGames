local ReactFiberLane = require(script.Parent.ReactFiberLane)
local noLanes = ReactFiberLane.NoLanes
local mergeLanes = ReactFiberLane.mergeLanes
local ReactFiberWorkInProgress = {}

function ReactFiberWorkInProgress.workInProgressRootSkippedLanes(p)
	if p == nil then
		return noLanes
	end

	noLanes = p
	return noLanes
end

function ReactFiberWorkInProgress.markSkippedUpdateLanes(p)
	noLanes = mergeLanes(p, noLanes)
end

return ReactFiberWorkInProgress