local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage.Util)
local Projectile = require(ReplicatedStorage.EffectContainer.Dough.Util.Arms.Projectile)
local distributedLoop = Util.DistributedLoop
local tween = Util.Tween
return function(player)
	local character = player.Character or player.Reference
	local method = player.Method or "Create"
	local scale = player.Scale or 1
	local duration = player.Duration or 1
	local hold = player.Hold
	local attach = player.Attach

	if method == "Create" then
		Projectile.new(character, scale, player.Haki, player.Color, player.PhysicalColor)
		return
	end

	local v = Projectile.get(character) or Projectile.get(attach)

	if not v then
		return
	end

	if method == "Attach" then
		v:attach(attach, player.Data)
	elseif method == "Deflate" then
		v:deflate(player.Duration, player.FadeOut)
	elseif method == "Ignite" then
		v:ignite(player.Enabled, player.Mode, player.Side, player.Portion)
	elseif method == "Destroy" then
		v:Destroy(player.CFrame)
	elseif method == "Resize" or method == "Scale" then
		v:scale(scale)
	elseif method == "AnimateResize" or method == "AnimateScale" then
		local originalScale = v.OriginalScale
		distributedLoop:add(function(p, _)
			local v2 = math.min(1, p / duration)
			local v3 = math.min(1, p / 0.15)
			local quart = Util.Tween.ease.out.quart(v2, 0, 1, 1)
			local back = Util.Tween.ease.out.back(v3, 0, 1, 1)
			v.AnimatedScale = tween.point(originalScale * back, scale, quart)
			v:scale(v.AnimatedScale)

			if v3 == 1 then
				v.DoneGrowing = true
			end

			if hold and hold.Value and not (duration < p) then
				return
			else
				return true
			end
		end)
	end
end