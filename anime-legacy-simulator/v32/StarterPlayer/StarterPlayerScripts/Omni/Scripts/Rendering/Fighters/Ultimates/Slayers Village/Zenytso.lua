local createVector = vector.create
return {
	Steps = {
		{
			Marker = "Prepare",
			Run = function(instance)
				instance:Sound("Prepare")
				local cache = instance:Cache(instance:Clone("Prepare"))

				if cache then
					cache:PivotTo(instance.Origin)
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
					TintColor = Color3.fromRGB(255, 255, 0)
				})
				instance:Blur({
					Position = instance.Origin.Position,
					Size = 20
				})
				instance:Rock("Crater", CFrame.new(instance.Origin.Position), 5, 5, 11, false)
			end
		},
		{
			Marker = "Hit",
			Run = function(instance)
				instance:Sound("Thunderclap")
				local cache = instance:Cache(instance:Clone("Hit"))

				if cache then
					cache:PivotTo(instance.Origin)
					instance:Emit(cache)
					instance:Debris(cache, 3)
				end

				instance:Shake({
					Position = instance.GoalCFrame.Position,
					Amplitude = 2,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				instance:Impact({
					Position = instance.GoalCFrame.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(255, 255, 0)
				})
				instance:Blur({
					Position = instance.GoalCFrame.Position,
					Size = 20
				})
				instance.Fighter.Offset.Value = createVector(0, 0, -50)
			end
		},
		{
			Marker = "End",
			Run = function(p)
				p.Fighter.Offset.Value = createVector(0, 0, 0)
			end
		}
	}
}