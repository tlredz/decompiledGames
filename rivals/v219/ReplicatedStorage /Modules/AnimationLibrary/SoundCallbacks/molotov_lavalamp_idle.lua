return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://126501912769166", 0.375, 1, true)

	if sound then
		sound.Looped = true
	end
end