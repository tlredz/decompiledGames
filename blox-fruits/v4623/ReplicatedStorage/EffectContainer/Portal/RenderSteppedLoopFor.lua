local RunService = game:GetService("RunService")
local time2 = RunService:IsRunning() and time or os.clock
local RenderSteppedLoopFor = {}

function RenderSteppedLoopFor.RenderSteppedLoopFor(p: number, callback, callback2)
	local renderSteppedConnection = nil
	local v = time2()
	local v2 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		else
			v2 = true
			callback2()

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	end)
	return renderSteppedConnection
end

function RenderSteppedLoopFor.AwaitRenderSteppedLoopFor(p: number, callback, callback2)
	local renderSteppedConnection = nil
	local v = time2()
	local bindableEvent = Instance.new("BindableEvent")
	local v2 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		else
			v2 = true
			callback2()

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

return RenderSteppedLoopFor