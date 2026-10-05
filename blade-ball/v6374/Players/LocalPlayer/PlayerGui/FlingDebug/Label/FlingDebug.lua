local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local thread = nil
Net:RemoteEvent("ReteleportWarnDebug").OnClientEvent:Connect(function()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	script.Parent.Visible = true
	thread = task.delay(0.5, function()
		script.Parent.Visible = false
	end)
end)