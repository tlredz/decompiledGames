local v = nil
local v2 = nil

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpinWheelRewards = require(ReplicatedStorage.Shared.SpinWheelRewards)

while task.wait(1.5) do
	task.spawn(function()
		local _, v3 = SpinWheelRewards:GetSpinWheel(localPlayer)
		local v4 = v3:match("^(%w+)/?") or v3
		local child = v4 ~= v and script.Parent:FindFirstChild(v4)

		if child then
			if v2 then
				if v2:GetAttribute("Spinning") then
					return
				else
					v2.SpinWheelClient.Enabled = false
				end
			end

			child.SpinWheelClient.Enabled = true
			v2 = child
			v = v4
		end
	end)
end