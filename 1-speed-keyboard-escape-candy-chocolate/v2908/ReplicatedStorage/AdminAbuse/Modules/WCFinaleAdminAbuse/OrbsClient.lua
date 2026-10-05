local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbController = require(ReplicatedStorage.AdminAbuse.Modules.Shared.OrbController)
local ClientDebris = require(script.Parent.AttacksClient.ClientDebris)
local v = nil

local function getOrbController()
	if v then
		return v
	end

	local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse", 10)

	if not adminAbuse then
		return nil
	end

	local remotes = adminAbuse:WaitForChild("Remotes", 10)

	if not remotes then
		return nil
	end

	local wCFinaleOrbCollected = remotes:FindFirstChild("WCFinaleOrbCollected")

	if wCFinaleOrbCollected and wCFinaleOrbCollected:IsA("RemoteEvent") then
		v = OrbController.new(wCFinaleOrbCollected, {
			parent = ClientDebris(),
			noCollideGroups = { "BossCollisions_Live" }
		})
		return v
	end

	warn("[WCFinaleAdminAbuse][OrbsClient] WCFinaleOrbCollected remote not found")
	return nil
end

local OrbsClient = {}

function OrbsClient:scan()
	local orbController = getOrbController()

	if orbController then
		orbController:scan(self)
	end
end

function OrbsClient:spawnFromZone()
	local orbController = getOrbController()

	if orbController then
		orbController:spawnFromZone(self)
	end
end

function OrbsClient.cleanup()
	if v then
		v:destroy()
		v = nil
	end
end

return OrbsClient