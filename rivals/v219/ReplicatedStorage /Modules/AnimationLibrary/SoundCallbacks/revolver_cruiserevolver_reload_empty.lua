return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	for i = 1, 8 do
		object:CreateSound("rbxassetid://134815282110155", 1, (i - 1) * 0.05 + 1, true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.05625 / p) then
			break
		end
	end
end