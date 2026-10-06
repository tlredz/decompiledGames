return {
	Setup = function(instance)
		instance.HitEffect = instance:Cache(instance:Clone("Hit"))

		if instance.HitEffect then
			instance.HitEffect:PivotTo(instance.HRP.CFrame)
			instance:SetPart0(instance.HitEffect, instance.HRP)
		end

		instance.Swords = {}
		instance.HitCount = 0
	end,
	OnMarker = {
		Hit = function(object)
			object.HitCount += 1
			object:Sound("Slash" .. (object.HitCount - 1) % 3 + 1, {
				Group = object.Fighter,
				MaxVoices = 3
			})

			if object.HitEffect then
				object:Emit(object.HitEffect.NormalSlash)
			end
		end
	},
	Steps = {
		{
			Marker = "Aura",
			Run = function(instance)
				instance:Sound("Aura")
				instance.Aura = instance:Cache(instance:Clone("Aura"))

				if instance.Aura then
					instance.Aura.CFrame = instance.HRP.CFrame
					instance:SetPart0(instance.Aura, instance.HRP)
				end
			end
		},
		{
			Marker = "UltraHit",
			Run = function(object)
				object:Sound("UltraSlash")

				if object.HitEffect then
					object:Emit(object.HitEffect.NormalSlash)
					object:Emit(object.HitEffect.UltraSlash)
					object:Debris(object.HitEffect, 3)
				end

				if object.Aura then
					object:Disable(object.Aura)
					object:Debris(object.Aura, 3)
				end

				local v = object.Goal - Vector3.new(0, object.Enemy.MediumSize, 0)
				object:Shake({
					Position = object.Origin.Position,
					Amplitude = 2,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				object:Impact({
					Position = object.Origin.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(138, 255, 60)
				})
				object:Blur({
					Position = object.Origin.Position,
					Size = 20
				})
				object:Rock("Explosion", CFrame.new(v), 8, 0.5, 1.6, false)
			end
		}
	}
}