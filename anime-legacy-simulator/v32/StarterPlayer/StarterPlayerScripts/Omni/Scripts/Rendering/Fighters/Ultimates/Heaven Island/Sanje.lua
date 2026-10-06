-- equivalent calls inferred from this helper; original call sites unknown
local function PlayKick(object, p: number)
	object:Sound("Kick" .. (p - 1) % 2 + 1, {
		Group = object.Fighter,
		MaxVoices = 3
	})
end

local steps = {
	{
		Marker = "Hit Start",
		Run = function(instance)
			local v2 = {
				Group = instance.Fighter,
				MaxVoices = 3
			}
			instance:Sound("Kick" .. 1, v2)
			instance.Gatling = instance:Cache(instance:Clone("Gatling"))

			if instance.Gatling then
				instance.Gatling:PivotTo(instance.Origin)
			end

			instance:Shake({
				Position = instance.Origin.Position,
				Amplitude = 1,
				Frequency = 0.1,
				FadeOutTime = 0.5
			})
		end
	}
}

for i = 2, 4 do
	local v2 = i
	table.insert(steps, {
		Time = (i - 1) / 4 * 0.29 + 1.13,
		Run = function(object)
			PlayKick(object, v2) -- equivalent call inferred; original call site unknown
		end
	})
end

table.insert(steps, {
	Marker = "Hit End",
	Run = function(object)
		local v2 = {
			Group = object.Fighter,
			MaxVoices = 3
		}
		object:Sound("Kick" .. 1, v2)

		if object.Gatling then
			object:Disable(object.Gatling)
			object:Debris(object.Gatling, 3)
		end
	end
})
table.insert(steps, {
	Marker = "Slash",
	Run = function(instance)
		instance:Sound("Slash")
		instance.Slash = instance:Cache(instance:Clone("Slash"))

		if instance.Slash then
			instance.Slash:PivotTo(instance.Origin)
		end

		local v2 = instance.Goal - Vector3.new(0, instance.Enemy.MediumSize, 0)
		instance:Shake({
			Position = instance.Origin.Position,
			Amplitude = 2,
			Frequency = 0.05,
			FadeOutTime = 0.25
		})
		instance:Impact({
			Position = instance.Origin.Position,
			Duration = 0.25,
			TintColor = Color3.fromRGB(255, 140, 60)
		})
		instance:Blur({
			Position = instance.Origin.Position,
			Size = 20
		})
		instance:Rock("Explosion", CFrame.new(v2), 8, 0.5, 1.6, false)

		if instance.Slash then
			instance:Emit(instance.Slash)
			instance:Debris(instance.Slash, 3)
		end
	end
})
return {
	Steps = steps
}