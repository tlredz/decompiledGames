local TurretHandlerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
Client.Events.TurretFireEffects:Connect(function(p)
	local v2 = v[p]

	if v2 then
		v2:ReplicateFire()
	end
end)

function TurretAdded(instance)
	if instance.Parent ~= workspace.Structures and not (instance:GetAttribute("EnemyTurret") and instance:IsDescendantOf(workspace)) then
		return
	end

	local turretClassClient = Client.TurretClassClient.new(instance)
	v[instance] = turretClassClient

	if not instance:GetAttribute("Deactivated") then
		turretClassClient:Activate()
		return
	end

	turretClassClient.Active = true
	turretClassClient:Deactivate()
end

function TurretRemoved(p)
	if v[p] then
		v[p]:Destroy()
		v[p] = nil
	end
end

function TurretHandlerClient.Init()
	Client.Utility.ForAllTagged("Turret", TurretAdded, TurretRemoved)
end

return TurretHandlerClient