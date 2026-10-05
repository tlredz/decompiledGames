local Knit = require(game.ReplicatedStorage.Knit.Knit)
Knit.AddControllersDeep(script.Parent:WaitForChild("Controllers"))
Knit.Start({
	ServicePromises = false
}):catch(warn)
print("Loaded Knit on client!")
local CmdrClient = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))
CmdrClient:SetActivationKeys({ Enum.KeyCode.F2, Enum.KeyCode.Semicolon })
local localPlayer = game.Players.LocalPlayer
local v = {
	[1241352401] = true,
	[31070091] = true,
	[174332536] = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function checkList(instance)
	if v[instance.UserId] then
		instance:SetAttribute("HidePlayer", true)
	end
end

for _, v2 in game.Players:GetPlayers() do
	checkList(v2) -- equivalent call inferred; original call site unknown
end

game.Players.PlayerAdded:Connect(checkList)
local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
	for _, v2 in game.Players:GetPlayers() do
		if v2 == localPlayer then
			continue
		end

		if v2:GetAttribute("HidePlayer") then
			v2.Parent = nil
		elseif v2.Parent ~= game.Players then
			v2.Parent = game.Players
		end
	end
end)