return {
	Setup = function(object)
		object:OnCleanup(function()
			if object.ScaleConnection then
				object.ScaleConnection:Disconnect()
				object.ScaleConnection = nil
			end
		end)
	end,
	OnMarker = {
		Start = function(instance)
			instance:Sound("Summon")
			instance.Effect = instance:Cache(instance:Clone("Effect"))

			if instance.Effect then
				instance:Weld(
					instance.EnemyHRP,
					instance.Effect.Main,
					Vector3.new(0, 2.5 * instance.Enemy.ModelScale, 0),
					true
				)
			end
		end,
		Explosion = function(object)
			object:Sound("Explosion")

			if object.Effect then
				object:Emit(object.Effect)
				object:Disable(object.Effect)
				object:Debris(object.Effect, 5)
			end

			object:Shake({
				Position = object.Origin.Position,
				Amplitude = 2,
				Frequency = 0.05,
				FadeOutTime = 0.25
			})
			object:Impact({
				Position = object.Origin.Position,
				Duration = 0.25,
				TintColor = Color3.fromRGB(0, 0, 0)
			})
			object:Blur({
				Position = object.Origin.Position,
				Size = 20
			})
		end
	}
}