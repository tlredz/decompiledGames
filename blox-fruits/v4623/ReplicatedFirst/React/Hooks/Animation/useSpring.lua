local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local Spring = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("Spring"))
local useDrawContext = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("useDrawContext"))
return function(p: number, p2: number, p3: number, p4: number, p5: number?, p6: number?, flag: boolean?, flag2: boolean?)
	local state, setState = React.useState(p)
	local state2, setState2 = React.useState(0)
	local v = p5 == nil and 0.001 or p5
	local v2 = p6 == nil and 60 or p6

	if flag == nil then
		flag = false
	end

	local v3 = useDrawContext()
	local useEffect = React.useEffect

	local function fn()
		if flag2 == false or v3 == "Offscreen" then
			if p2 ~= state then
				setState(p2)
				setState2(0)
			end
		else
			local v4 = state - state % v

			if v4 ~= p2 - p2 % v then
				local v5 = Spring.new(p3, p4, state)
				v5.Velocity = state2
				v5:Set(p2)
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
					v5:Step(dt)
					setState2(v5.Velocity)
					local v6 = v5:Get()
					local v7 = v6 - v6 % v

					if math.abs(v5.Velocity) <= 0.0005 then
						v7 = p2
						setState2(0)
						renderSteppedConnection:Disconnect()
					end

					if v7 ~= v4 then
						setState(v7)
					end
				end)
				return function()
					renderSteppedConnection:Disconnect()
				end
			end
		end

		return function() end
	end

	local v5 = p2 - p2 % v

	if v3 == "Offscreen" then
		flag2 = false
	end

	useEffect(fn, {
		v5,
		p4,
		p3,
		v,
		v2,
		flag,
		flag2
	})
	return state
end