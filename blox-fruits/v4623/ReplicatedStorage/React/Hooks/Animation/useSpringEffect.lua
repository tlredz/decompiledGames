local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Spring)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
return function(p: number, p2, flag: boolean, callback, callback2, callback3, position: number?)
	local ref = React.useRef(p2)
	useOnScreenEffect(function()
		if not flag then
			return function() end
		end

		local current = ref.current

		if math.abs(current.Goal - p) > 0.001 then
			if position then
				current.Position = position
			end

			current:Set(p)

			if callback2 then
				callback2()
			end
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			current:Step(dt)

			if current.Velocity < 0.001 and math.abs(current.Position - current.Goal) < 0.001 then
				current.Position = current.Goal
				current.Velocity = 0
			end

			callback(current.Position, current.Velocity)

			if current.Goal == current:Get() then
				renderSteppedConnection:Disconnect()

				if callback3 then
					callback3()
				end
			end
		end)
		return function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		end
	end, {
		flag,
		p,
		ref.current,
		position
	})
end