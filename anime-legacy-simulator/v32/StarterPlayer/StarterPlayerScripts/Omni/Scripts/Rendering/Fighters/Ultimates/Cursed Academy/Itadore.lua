return {
	Steps = {
		{
			Marker = "Hit",
			Run = function(instance)
				instance:Sound("BlackFlash")
				local cache = instance:Cache(instance:Clone("Hit"))

				if cache then
					cache:PivotTo(instance.GoalCFrame)
					instance:Emit(cache)
					instance:Debris(cache, 3)
				end

				instance:Shake({
					Position = instance.Origin.Position,
					Amplitude = 3,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				instance:Impact({
					Position = instance.Origin.Position,
					Duration = 0.5,
					TintColor = Color3.fromRGB(252, 0, 0)
				})
				instance:Blur({
					Position = instance.Origin.Position,
					Size = 20
				})
			end
		}
	}
}