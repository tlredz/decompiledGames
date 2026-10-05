local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
FX:WaitForChild("Dough")
require(ReplicatedStorage.Util)
local Projectile = require(ReplicatedStorage.EffectContainer.Dough.Util.Projectile)
return function(data)
	local anchor = data.Anchor
	local method = data.Method or "Create"
	local scale = data.Scale
	local _ = data.Duration or 1
	local _ = data.Hold
	local attach = data.Attach

	if method == "Create" then
		Projectile.new(anchor, scale, data.Data)
		return
	end

	local v = Projectile.get(anchor) or Projectile.get(attach)

	if not v then
		return
	end

	if method == "Destroy" then
		v:Destroy(data.Data)
	elseif method == "Ignite" then
		v:ignite(data.Enabled)
	elseif method == "Resize" or method == "Scale" then
		v:scale(scale)
	end
end