local processingBackground = script.Parent:WaitForChild("ProcessingBackground")
local RunService = game:GetService("RunService")
return function()
	local v = {
		_Destroyed = false
	}
	local thread = nil

	function v.Begin()
		if thread then
			return
		end

		thread = task.spawn(function()
			processingBackground.Visible = true
			processingBackground.ProcessLabel.Text = "Processing"
			local lastTime = tick()

			while not v._Destroyed do
				local v2 = math.floor((tick() - lastTime) * 2) % 4
				local v3 = string.rep(".", v2)
				processingBackground.ProcessLabel.Text = "Processing" .. v3
				RunService.Heartbeat:Wait()
			end
		end)
	end

	function v.Destroy(_)
		v._Destroyed = true

		if thread then
			task.cancel(thread)
			thread = nil
		end

		processingBackground.Visible = nil
	end

	return v
end