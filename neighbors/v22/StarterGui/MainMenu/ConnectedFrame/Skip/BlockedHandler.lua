local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Modules.PlayerStates)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local v = { parent:FindFirstChild("Skip", true), parent:FindFirstChild("Pause", true) }
local v2 = 0
Network:listen("BlockSkipButton", function(p: number)
	v2 = os.time() + p
end)
localPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if localPlayer:GetAttribute("State") ~= 3 then
		v2 = 0
	end
end)

while task.wait() do
	for _, v3 in next, v, nil do
		local blocked = v3:FindFirstChild("Blocked")
		local label = blocked:FindFirstChild("Label")
		blocked.Visible = os.time() < v2

		if blocked.Visible then
			label.Text = tostring((math.ceil(v2 - os.time())))
		end
	end
end