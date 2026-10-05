local BendServer = {
	Id = {}
}
local Projectile = require(script.Projectile)
require(game.ServerStorage:WaitForChild("SAM"):WaitForChild("Services"):WaitForChild("Server_Mouse_Pos"))

function BendServer.Hold(player, _)
	local _ = BendServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or Projectile:GetProjectile(player.Character) then
		return
	end

	Projectile:Shoot(player, player.Character)
end

function BendServer.UnHold(player, _)
	local projectile = Projectile:GetProjectile(player.Character)
	local character = player.Character

	if projectile then
		Projectile:Expire(character, projectile)
	end
end

function BendServer.Cancel(player, _)
	local projectile = Projectile:GetProjectile(player.Character)
	local character = player.Character

	if projectile then
		Projectile:Expire(character, projectile)
	end
end

return BendServer