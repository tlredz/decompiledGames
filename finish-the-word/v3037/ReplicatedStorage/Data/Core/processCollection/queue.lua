local import = _G.import("modelUtil")
local Queue = {}

function Queue.joinQueue(instance, p, p2, p3)
	if instance:GetAttribute("InGame") then
		return "You are already in a match"
	end

	if instance:GetAttribute("IsQueuing") then
		return "You are already in a queue"
	end

	local v = import.getAttribute(workspace, "Mode"):await()

	if p2.Sitting and v ~= "RANKED" then
		return "You cannot queue while seated"
	end

	return true, instance, p, p2, p3
end

function Queue.leaveQueue(p, p2, p3)
	return true, p, p2, p3
end

return Queue