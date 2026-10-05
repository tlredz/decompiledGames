local TeleportService = game:GetService("TeleportService")
return function(object, p, p2, p3)
	local v = p or { object.Executor }

	if p2 <= 0 then
		return "Invalid place ID"
	end

	if p3 == "-" then
		return "Invalid job ID"
	end

	object:Reply("Commencing teleport...")

	if p3 then
		for _, v2 in ipairs(v) do
			TeleportService:TeleportToPlaceInstance(p2, p3, v2)
		end
	else
		TeleportService:TeleportAsync(p2, v)
	end

	return "Teleported."
end