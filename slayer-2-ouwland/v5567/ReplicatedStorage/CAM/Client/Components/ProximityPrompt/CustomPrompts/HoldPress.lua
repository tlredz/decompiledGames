local UserInputService = game:GetService("UserInputService")
return function(object, object2)
	local v = nil
	object:Connect(UserInputService.InputEnded, function(p)
		if p ~= v then
			return
		end

		v = nil
		object2:InputHoldEnd()
	end)
	return function(_, p)
		if v ~= nil or p.UserInputType ~= Enum.UserInputType.Touch and p.UserInputType ~= Enum.UserInputType.MouseButton1 or p.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		v = p
		object2:InputHoldBegin()
	end
end