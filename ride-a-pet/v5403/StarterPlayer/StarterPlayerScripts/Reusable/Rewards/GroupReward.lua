local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local localPlayer = Players.LocalPlayer
local handle = workspace:WaitForChild("Functionals"):WaitForChild("Meat"):WaitForChild("Handle")
local claim = handle:WaitForChild("Claim")
local timer = handle:WaitForChild("Timer")
local label = timer:WaitForChild("Label")
local v = nil

while true do
	local groupRewardClaimTime = localPlayer:GetAttribute("GroupRewardClaimTime")

	if groupRewardClaimTime ~= nil then
		local v2 = 86400 - (workspace:GetServerTimeNow() - groupRewardClaimTime)
		local enabled = v2 > 0

		if enabled ~= v then
			claim.Enabled = not enabled
			timer.Enabled = enabled
			v = enabled
		end

		if enabled then
			label.Text = String:ConvertToHMS((math.ceil(v2)))
		end
	end

	task.wait(0.5)
end