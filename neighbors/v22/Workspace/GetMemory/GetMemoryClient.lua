local Stats = game:GetService("Stats")
local event = script.Parent:WaitForChild("Event")

event.OnClientInvoke = function(p)
	if p then
		if p == "Total" then
			return Stats:GetTotalMemoryUsageMb()
		end

		return Stats:GetMemoryUsageMbForTag(p)
	else
		local memoryUsageMbForTagsByName = {}

		for _, v in Enum.DeveloperMemoryTag:GetEnumItems() do
			memoryUsageMbForTagsByName[v.Name] = Stats:GetMemoryUsageMbForTag(v)
		end

		memoryUsageMbForTagsByName.Total = Stats:GetTotalMemoryUsageMb()
		return memoryUsageMbForTagsByName
	end
end