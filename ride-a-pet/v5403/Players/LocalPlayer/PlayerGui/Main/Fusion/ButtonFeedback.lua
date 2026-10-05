local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local v = { parent:WaitForChild("Fuse"), parent:WaitForChild("SkipFuse"), parent:WaitForChild("Close") }
local clickPulseScale = parent:GetAttribute("ClickPulseScale")
local v2 = { parent:GetAttribute("ClickPulseDamping"), parent:GetAttribute("ClickPulseSpeed") }

for _, v3 in v do
	local v4 = v3
	v3.Activated:Connect(function()
		if v4.Interactable and v4.Active then
			BitohiUI.Juice.punch(v4, clickPulseScale, v2, "AnimScale")
		end
	end)
end