return {
	Steps = {
		{
			Marker = "Start",
			Run = function(instance)
				instance:Sound("Swing")
				instance.Effect = instance:Cache(instance:Clone("Effect"))

				if instance.Effect then
					instance.Effect:PivotTo(instance.Origin)
				end
			end
		},
		{
			Marker = "Hit",
			Run = function(object)
				object:Sound("Slash")

				if object.Effect then
					object:Emit(object.Effect.Hit)
					object:Disable(object.Effect.Water)
					object:Debris(object.Effect, 3)
				end

				object:Shake({
					Amplitude = 2,
					Frequency = 1,
					FadeOutTime = 1
				})
				object:Impact({
					Duration = 1,
					TintColor = Color3.fromRGB(25, 255, 255)
				})
				object:Blur({
					InTime = 0.1,
					OutTime = 0.9,
					Size = 30
				})
			end
		}
	}
}