return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://122734338191015", 0.1, 1, true, nil, 8, 24)

	if sound then
		sound.Looped = true
	end
end