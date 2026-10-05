local SlashHit = require(script.SlashHit)
local BlockHit = require(script.BlockHit)
local Damage = require(script.Damage)
local Util = require(game.ReplicatedStorage.Util)
local v = {
	Hit1 = "Punch",
	Hit1Electric = "Electric",
	QuickSliceElectric = "Electric",
	QuickSlice = "Sword",
	WaterHit = "Fishman",
	FireHit = "Dragon",
	BlueFireHit = "Kitsune",
	GhoulHit = "Ghoul",
	DivineHit = "Angel"
}
return {
	play = function(p, position, p3)
		if Util.RenderDistance.value(position) > 150 then
			return
		end

		local hitSound = p3.HitSound
		local v2 = v[hitSound]

		if p == "Hit" then
			if hitSound and not p3.CustomSound then
				Util.Sound:Play(hitSound, position)
			end

			SlashHit.playAt(position, v2 or "Punch")
		elseif p == "DamageIndicator" then
			Damage.new({
				Position = position,
				Value = hitSound
			}):Run()
		elseif p == "Block" then
			Util.Sound:Play("BlockedHit1", position)
			BlockHit.playAt(position)
		end
	end
}