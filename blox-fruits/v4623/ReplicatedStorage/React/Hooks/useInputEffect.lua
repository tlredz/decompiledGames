local UserInputService = game:GetService("UserInputService")
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
return function(callback, p, p2, p3, flag: boolean?, ...)
	useOnScreenEffect(function()
		if not flag then
			return function() end
		end

		local function fn(data)
			if p ~= data.UserInputState or p2 and data.UserInputType ~= p2 or p3 and data.KeyCode ~= p3 then
				return
			end

			callback(data)
		end

		local inputBeganConnection

		if p == Enum.UserInputState.Begin then
			inputBeganConnection = UserInputService.InputBegan:Connect(fn)
		elseif p == Enum.UserInputState.End then
			inputBeganConnection = UserInputService.InputEnded:Connect(fn)
		else
			inputBeganConnection = UserInputService.InputChanged:Connect(fn)
		end

		return function()
			inputBeganConnection:Disconnect()
		end
	end, {
		p,
		p2,
		p3,
		flag,
		...
	})
end