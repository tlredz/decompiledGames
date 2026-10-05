local UserInputService = game:GetService("UserInputService")
local v = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true
}
return {
	bind = function(p, callback, callback2)
		local v2 = {}
		local inputBeganConnection = p.InputBegan:Connect(function(input)
			if v[input.UserInputType] then
				v2[input] = true
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if not v2[input] then
				return
			end

			v2[input] = nil

			if callback() then
				callback2()
			end
		end)
		return {
			Disconnect = function()
				table.clear(v2)
				inputBeganConnection:Disconnect()
				inputEndedConnection:Disconnect()
			end
		}
	end
}