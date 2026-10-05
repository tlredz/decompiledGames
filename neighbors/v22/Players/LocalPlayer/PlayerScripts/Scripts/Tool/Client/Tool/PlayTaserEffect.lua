local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
local _ = {
	LifeTime = 4
}
Network:listen("Tool/PlayTaserEffect", function(p, list)
	local highlight = Instance.new("Highlight")
	highlight.Name = "TaserHighlight"
	highlight.OutlineTransparency = 0.3
	highlight.FillTransparency = 0.45
	highlight.Adornee = p
	highlight.Parent = p
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v = list[math.random(1, #list)]
		highlight.OutlineColor = v
		highlight.FillColor = v
	end)
	task.wait(1.85)
	heartbeatConnection:Disconnect()
	highlight:Destroy()
end)