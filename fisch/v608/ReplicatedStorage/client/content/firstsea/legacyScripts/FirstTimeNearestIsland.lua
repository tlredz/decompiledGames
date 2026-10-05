local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local localPlayer = Players.LocalPlayer
local first_island_visited = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("first_island_visited")
local oceanPOIs = workspace:WaitForChild("active"):WaitForChild("OceanPOI's")

-- equivalent calls inferred from this helper; original call sites unknown
local function isOceanZone(zone)
	local value = zone.Value

	if value then
		return value.Name == "Ocean"
	end

	return false
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	assert(humanoid:IsA("Humanoid"), "Luau")
	local zone = character:WaitForChild("zone")
	assert(zone:IsA("ObjectValue"), "zone should be an object value")
	local clone = oceanPOIs:WaitForChild("Roslit Bay"):Clone()
	clone.Name = `{clone.Name}TemporaryPoi`
	clone.POIHeader.Enabled = false
	clone.POIHeader:RemoveTag("poi_icon")
	clone.POIHeader:RemoveTag("poi_island")
	clone.Parent = workspace

	if first_island_visited.Value == false then
		while not humanoid.SeatPart do
			task.wait()
		end

		clone.POIHeader.Enabled = true

		while true do
			-- equivalent call inferred; original call site unknown
			if isOceanZone(zone) then
				clone.POIHeader.Enabled = false
				break
			else
				task.wait()
			end
		end
	end
end

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)