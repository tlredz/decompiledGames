local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local services = game.ReplicatedStorage:WaitForChild("Services")
local String = require(services:WaitForChild("String"))
RunService.RenderStepped:Connect(function()
	for _, v in CollectionService:GetTagged("Timer") do
		local startTime = v:FindFirstChild("StartTime")

		if startTime and startTime.Value ~= 0 then
			local value = startTime.Value
			v.Text = String:ConvertSecondsToMS((math.max(
				(v:GetAttribute("Duration") or 15) * 60 - (workspace:GetServerTimeNow() - value.Value),
				0
			)))
		else
			v.Text = "XX:XX"
		end
	end
end)