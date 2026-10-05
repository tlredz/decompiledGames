local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local v = {
	parent:WaitForChild("Previous"),
	parent:WaitForChild("Back"),
	parent:WaitForChild("Next"),
	parent:WaitForChild("Close")
}
local clickPulseScale = parent:GetAttribute("ClickPulseScale")
local v2 = { parent:GetAttribute("ClickPulseDamping"), parent:GetAttribute("ClickPulseSpeed") }

for _, v3 in v do
	local v4 = v3
	v3.Activated:Connect(function()
		if not v4.Interactable then
			return
		end

		BitohiUI.Juice.punch(v4, clickPulseScale, v2, "AnimScale")
	end)
end