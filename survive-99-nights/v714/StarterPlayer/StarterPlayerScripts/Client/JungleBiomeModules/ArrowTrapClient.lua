local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function FireArrows(instance)
	if v[instance] then
		return
	end

	v[instance] = true
	task.delay(2, function()
		v[instance] = nil
	end)
	local arrowTrapFolder = instance:FindFirstChild("ArrowTrapFolder")

	if not arrowTrapFolder then
		return
	end

	local pressurePlate = arrowTrapFolder:FindFirstChild("PressurePlate")

	if pressurePlate then
		Client.Sound.Play("ArrowFired", {
			Volume = 0.4,
			Position = pressurePlate.Position
		})
		task.delay(1.5, function()
			Client.Sound.Play("ArrowHit", {
				Volume = 0.4,
				Position = pressurePlate.Position
			})
		end)
	end

	for _, child in pairs(arrowTrapFolder:GetChildren()) do
		if child.Name ~= "ArrowLaunch" then
			continue
		end

		local v2 = {
			ProjectileDamage = instance:GetAttribute("ProjectileDamage") or 15,
			ProjectileGravity = 5,
			Speed = 70,
			ProjectileName = "Poison Arrow",
			NPCModel = instance,
			ProjectileParams = Client.CollisionUtility.EnemyProjectileParams,
			LeaveHandle = true
		}
		local position = child:GetPivot().Position
		local v3 = child:GetPivot().LookVector * (v2.Speed or 20)
		local projectileClass = Client.ProjectileClass.new(v2, position, v3)
		projectileClass.NPCBullet = true
		projectileClass:Fire()
	end
end

local ArrowTrapClient = {
	FireArrows = FireArrows
}
Client.Events.FireArrowTrap:Connect(function(p)
	if v[p] then
		return
	end

	FireArrows(p)
end)

function ArrowTrapAdded(instance)
	instance:WaitForChild("ArrowTrapFolder"):WaitForChild("PressurePlate").Touched:Connect(function(otherPart)
		if instance:GetAttribute("LastTrigger") and workspace:GetServerTimeNow() < instance:GetAttribute("LastTrigger") + 2 or v[instance] then
			return
		end

		if otherPart.Parent == localPlayer.Character then
			Client.Events.TriggerArrowTrap:FireServer(instance)
			FireArrows(instance)
		end
	end)
end

function ArrowTrapClient.Init()
	Client.Utility.ForAllTagged("ArrowTrap", ArrowTrapAdded)
end

return ArrowTrapClient