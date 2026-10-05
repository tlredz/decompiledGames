local createVector = vector.create
local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getCurrentRealmDifficultyAsync() < 3 then
	return
end

local position = createVector(1, 1, 1) * 1e999
local v = {
	{
		"Map",
		"Temple of Time",
		"NewStairs",
		"Step1"
	},
	{ "Map", "Temple of Time", "ClockRoomExit" },
	{ "_WorldOrigin", "LightingZones", "TempleOfTimeStairs" }
}
local workspaces = {}

while task.wait() do
	for k, v3 in pairs(v) do
		if workspaces[k] and workspaces[k].Parent then
			continue
		end

		local workspace2 = workspace

		for _, childName in pairs(v3) do
			workspace2 = workspace2:FindFirstChild(childName)

			if not workspace2 then
				break
			end
		end

		if workspace2 then
			workspaces[k] = workspace2
		else
			break
		end
	end

	local v3 = workspaces[1]
	local v4 = workspaces[2]
	local v5 = workspaces[3]
	local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if v3 and v4 and v5 and humanoidRootPart then
		if game.Players.LocalPlayer.Character:FindFirstChild("ValidClockRoom") then
			local v6 = v4
			pcall(function()
				v6.Transparency = 1
				v6.CanCollide = false
				v6.CanTouch = false
				workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:SetAttribute("Disabled", true)
			end)
		else
			local v6 = v4
			pcall(function()
				v6.Transparency = 0
				v6.CanCollide = true
				v6.CanTouch = true
				workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:SetAttribute("Disabled", false)
			end)
		end

		if not workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:GetAttribute("Disabled") then
			if humanoidRootPart.Position.Y >= v3.Position.Y - 20 and humanoidRootPart.Position.Z >= v3.Position.Z - 47 and humanoidRootPart.Position.Z <= v3.Position.Z + 47 then
				if humanoidRootPart.Position.X > position.X and humanoidRootPart.Position.X >= v3.Position.X + 176 then
					humanoidRootPart.CFrame -= createVector(88, 49.544, 0)
					wait(0.2)
				end
			else
				wait(1)
			end
		end
	end

	if humanoidRootPart then
		position = humanoidRootPart.Position
	end
end