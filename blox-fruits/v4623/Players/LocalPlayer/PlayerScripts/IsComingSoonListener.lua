local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local onIsComingSoonChanged = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OnIsComingSoonChanged")
local getIsComingSoon = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetIsComingSoon")
onIsComingSoonChanged.OnClientEvent:Connect(function(p)
	workspace:SetAttribute("IsComingSoonList", HttpService:JSONEncode(p))
end)

while true do
	local success, result = pcall(function()
		local v = getIsComingSoon:InvokeServer()

		if v then
			workspace:SetAttribute("IsComingSoonList", HttpService:JSONEncode(v))
		end
	end)

	if not success then
		warn((`Failed to get is coming soon list: {result}`))
	end

	task.wait(10)
end