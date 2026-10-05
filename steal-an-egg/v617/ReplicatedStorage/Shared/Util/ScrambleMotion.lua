local createVector = vector.create
return table.freeze({
	Pose = function(data, p: number)
		local v = (p - data.StartedAt) * data.Speed + data.Phase
		local vector2 = Vector3.new(math.cos(v) * data.Radius, math.sin(v * 2.1) * data.Bob, math.sin(v) * data.Radius)
		return data.Home * CFrame.new(vector2) * CFrame.Angles(0, -v, math.sin(v) * 0.08)
	end,
	Read = function(instance)
		local flightHome = instance:GetAttribute("FlightHome")

		if typeof(flightHome) == "CFrame" then
			return {
				Home = flightHome,
				StartedAt = instance:GetAttribute("FlightStartedAt"),
				Phase = instance:GetAttribute("FlightPhase"),
				Radius = instance:GetAttribute("FlightRadius"),
				Speed = instance:GetAttribute("FlightSpeed"),
				Bob = instance:GetAttribute("FlightBob")
			}
		end

		return nil
	end,
	Envelope = function(vector2: Vector3, data, vector3: Vector3, p: number, p2: number, value: number?)
		local halfMagnitude = vector2.Magnitude / 2
		local v2 = math.max((value or 12) / 2, data.Radius + halfMagnitude + p)
		local v3 = math.max(p2, data.Home.Position.Y - vector3.Y + halfMagnitude + data.Bob + p)
		return CFrame.new(vector3 + Vector3.new(0, v3 / 2, 0)), (Vector3.new(v2 * 2, v3, v2 * 2))
	end,
	Hitbox = function(vector2: Vector3, cframe: CFrame, cframe2: CFrame, p: number)
		return cframe * cframe2, vector2 + createVector(1, 1, 1) * math.min(p, 1) * 2
	end
})