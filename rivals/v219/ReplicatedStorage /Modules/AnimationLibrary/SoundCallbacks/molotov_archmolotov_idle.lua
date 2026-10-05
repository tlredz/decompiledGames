return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://14812965418", 0.375, 0.5, true)

	if sound then
		sound.Looped = true
	end
end