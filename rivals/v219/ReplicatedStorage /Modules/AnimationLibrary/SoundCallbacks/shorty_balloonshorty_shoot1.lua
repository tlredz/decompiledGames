return function(object, p, p2)
	for i = 1, 5 do
		local v = i
		task.spawn(function()
			if not object:_AnimationWait(script.Name, p2, 0.1 / p * v / 5) then
				return
			end

			object:CreateSound("rbxassetid://17803308936", 1 + 0.25 * math.random(), 1 + 0.3 * math.random(), true, 10)
		end)
	end
end