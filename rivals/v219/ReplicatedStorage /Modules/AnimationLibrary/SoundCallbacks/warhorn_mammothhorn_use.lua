return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://116889597355364", 1, 1, true, 5, 100, 400)

	if sound then
		sound:SetAttribute("DontClearSound", true)
	end
end