local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local mobile = Omni.Interface:WaitForChild("HUD"):WaitForChild("Mobile")
local Mobile = {
	Refresh = function()
		mobile.Visible = Omni.Platform == "Mobile"
	end
}
Omni.Utils.Loop:Connect({
	Time = 1,
	Callback = Mobile.Refresh
})
return Mobile