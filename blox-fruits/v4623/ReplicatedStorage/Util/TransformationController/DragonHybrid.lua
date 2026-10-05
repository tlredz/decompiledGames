local createVector = vector.create
return {
	Dodge = function(p, instance)
		local _ = instance.Multiplier
		local _ = instance.Duration
		local _ = instance.HRP
		local _ = instance.Humanoid
		local _ = instance.NPC
		local humanoidRootPart = p.HumanoidRootPart

		if instance.Direction and instance.Direction == createVector(0, 1, 0) then
			Effect.new("Dragon2.Hybrid.Jump"):replicate({
				Root = humanoidRootPart,
				Origin = humanoidRootPart.Position,
				player = game.Players:GetPlayerFromCharacter(humanoidRootPart.Parent)
			})
		else
			Effect.new("Dragon2.Hybrid.Dash"):replicate({
				Root = humanoidRootPart,
				Origin = humanoidRootPart.Position,
				Direction = dirz,
				player = game.Players:GetPlayerFromCharacter(humanoidRootPart.Parent)
			})
			return true
		end
	end
}