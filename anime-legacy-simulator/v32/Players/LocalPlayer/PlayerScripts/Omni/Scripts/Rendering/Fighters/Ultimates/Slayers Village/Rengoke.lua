return {
	Steps = {
		{
			Marker = "StarStart",
			Run = function(instance)
				instance:Sound("Ignite")
				instance.Star = instance:Cache(instance:Clone("Star"))

				if instance.Star then
					instance.Star.CFrame = instance.Origin
				end
			end
		},
		{
			Marker = "StarEnd",
			Run = function(object)
				if object.Star then
					object:Disable(object.Star)
					object:Debris(object.Star, 3)
				end
			end
		},
		{
			Marker = "TornadoStart",
			Run = function(instance)
				instance:Sound("Tornado")
				instance:Sound("Impact")
				instance.Tornado = instance:Cache(instance:Clone("Tornado"))

				if instance.Tornado then
					instance.Tornado:PivotTo(instance.Origin)
				end

				instance:Shake({
					Amplitude = 1,
					Frequency = 1,
					FadeOutTime = 0.97
				})
				instance:Impact({
					Duration = 0.97,
					TintColor = Color3.fromRGB(255, 165, 29)
				})
				instance:Blur({
					InTime = 0.1,
					OutTime = 0.87,
					Size = 30
				})
			end
		},
		{
			Marker = "TornadoEnd",
			Run = function(object)
				if object.Tornado then
					object:Disable(object.Tornado)
					object:Debris(object.Tornado, 3)
				end
			end
		}
	}
}