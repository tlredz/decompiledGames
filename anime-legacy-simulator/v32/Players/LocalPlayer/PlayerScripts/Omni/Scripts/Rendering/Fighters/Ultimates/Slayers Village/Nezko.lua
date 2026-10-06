return {
	OnMarker = {
		Slash = function(instance)
			instance.SlashSound = (instance.SlashSound or 0) + 1
			instance:Sound("Slash" .. (instance.SlashSound - 1) % 3 + 1, {
				Group = instance.Fighter,
				MaxVoices = 3
			})
			local cache = instance:Cache(instance:Clone("Slash"))
			local slashIndex = instance.SlashIndex or 1

			if cache then
				cache.CFrame = instance.Origin * CFrame.Angles(
					0,
					0,
					(math.rad(slashIndex == 1 and 90 or slashIndex == 2 and -90 or 90))
				)
				instance:Emit(cache)
				instance:Debris(cache, 3)
				instance.SlashIndex = slashIndex + 1
			end
		end
	},
	Steps = {
		{
			Marker = "Heavy Slash",
			Run = function(instance)
				instance:Sound("HeavySlash")
				local cache = instance:Cache(instance:Clone("Slash"))

				if cache then
					cache.CFrame = instance.Origin
					instance:Emit(cache)
					instance:Debris(cache, 3)
				end

				local v = instance.Goal - Vector3.new(0, instance.Enemy.MediumSize, 0)
				instance:Shake({
					Position = instance.Origin.Position,
					Amplitude = 2,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				instance:Impact({
					Position = instance.Origin.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(255, 50, 255)
				})
				instance:Blur({
					Position = instance.Origin.Position,
					Size = 20
				})
				instance:Rock("Explosion", CFrame.new(v), 8, 0.5, 1.6, false)
			end
		}
	}
}