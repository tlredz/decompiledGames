local TeleportService = game:GetService("TeleportService")
return function(_, p, value)
	local v = value or "PlaceIdJobId"
	local success, _, v2, v3, v4 = pcall(function()
		return TeleportService:GetPlayerPlaceInstanceAsync(p)
	end)

	if not success or v2 and #v2 > 0 then
		if v == "PlaceIdJobId" then
			return "0 -"
		elseif v == "PlaceId" then
			return "0"
		elseif v == "JobId" then
			return "-"
		end
	end

	if v == "PlaceIdJobId" then
		return v3 .. " " .. v4
	elseif v == "PlaceId" then
		return (tostring(v3))
	elseif v == "JobId" then
		return (tostring(v4))
	end
end