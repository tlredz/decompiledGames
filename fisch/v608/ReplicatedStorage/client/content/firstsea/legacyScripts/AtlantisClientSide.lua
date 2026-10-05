local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("CollectionService")
local events = ReplicatedStorage:WaitForChild("events")
local actives = workspace.world.map:WaitForChild("Forsaken Shores"):WaitForChild("Actives")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
local atlantisQuest = legacyLocalPlayerData.fetch():WaitForChild("AtlantisQuest")
local clone = nil
local part = Instance.new("Part", workspace)
part.Anchored = true
part.Transparency = 1
part.CanQuery = false
part.CanTouch = false
part.CanCollide = false
part.Massless = true
local attachment = Instance.new("Attachment", part)
attachment.WorldPosition = vector.create(-3576.865, 151.01, 524.48)
events:WaitForChild("HeartOfZeusBeam").OnClientEvent:Connect(function(p, p2)
	local beam = p.handle.Beam
	beam.Attachment1 = attachment
	beam.Enabled = true
	wait(p2)
	beam.Enabled = false
end)

function UpdateTNT()
	if atlantisQuest:WaitForChild("TNT Revealed").Value == true then
		if not clone then
			clone = script.TNT:Clone()
			clone:AddTag("TNTENTITY")
			clone.Parent = workspace
			clone.ProximityPrompt.Triggered:Connect(function()
				clone:Destroy()
				events.TNTReveal:FireServer()
			end)
		end

		task.spawn(function()
			local doorPart = actives:WaitForChild("DoorPart", 1e999)

			if doorPart then
				doorPart:Destroy()
			end
		end)
	end

	if atlantisQuest:WaitForChild("TNT Grabbed").Value == true and clone then
		clone:Destroy()
	end
end

events.TNTReveal.OnClientEvent:Connect(function()
	UpdateTNT()
end)
UpdateTNT()