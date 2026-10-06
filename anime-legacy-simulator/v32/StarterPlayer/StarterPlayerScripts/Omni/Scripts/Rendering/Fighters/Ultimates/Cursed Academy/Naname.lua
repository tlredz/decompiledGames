return {
	Steps = {
		{
			Time = 3.03,
			Run = function(object)
				object:Sound("Charge")
			end
		},
		{
			Marker = "Hit",
			Run = function(instance)
				instance:Sound("Hit")
				local cache = instance:Cache(instance:Clone("Hit"))

				if cache then
					cache.CFrame = instance.GoalCFrame
					instance:Emit(cache)
					instance:Debris(cache, 3)
				end

				instance:Shake({
					Position = instance.Origin.Position,
					Amplitude = 2,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				instance:Impact({
					Position = instance.Origin.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(32, 208, 252)
				})
				instance:Blur({
					Position = instance.Origin.Position,
					Size = 20
				})
			end
		}
	}
}