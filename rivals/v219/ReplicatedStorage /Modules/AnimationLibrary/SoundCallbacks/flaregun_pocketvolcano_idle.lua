return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://91973216667023", 0.375, 1, true)

	if sound then
		sound.Looped = true
	end
end