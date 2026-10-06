return {
	Setup = function(instance)
		instance.SlashCount = 0
		instance.Slash = instance:Cache(instance:Clone("Slash"))

		if instance.Slash then
			instance:Weld(instance.HRP, instance.Slash)
		end
	end,
	OnMarker = {
		Slash = function(object)
			object.SlashCount += 1
			object:Sound("Slash" .. (object.SlashCount - 1) % 2 + 1, {
				Group = object.Fighter,
				MaxVoices = 3
			})

			if object.Slash then
				object:Emit(object.Slash)
			end
		end
	},
	Steps = {
		{
			Marker = "Wind",
			Run = function(instance)
				instance:Sound("Wind")
				instance.Wind = instance:Cache(instance:Clone("Wind"))

				if instance.Wind then
					instance.Wind.Position = instance.Origin.Position - Vector3.new(0, instance.Fighter.MediumSize, 0)
					instance:Emit(instance.Wind)
					instance:Debris(instance.Wind, 3)
				end
			end
		},
		{
			Marker = "Heavy Slash",
			Run = function(object)
				object:Sound("HeavySlash")

				if object.Slash then
					object:Emit(object.Slash)
					object:Debris(object.Slash, 3)
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
					TintColor = Color3.fromRGB(0, 255, 255)
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