local createVector = vector.create
local WaterEffect = require(script:WaitForChild("WaterEffect"))
local AirEffect = require(script:WaitForChild("AirEffect"))
local Effect = {}

function Effect.register(boat)
	local v = {
		Boat = boat
	}
	v.ModelSize = v.Boat:GetModelSize()
	v.VehicleSeat = v.Boat.VehicleSeat
	v.PositionOffset = v.VehicleSeat.BodyPosition:GetAttribute("PositionInfluence") or createVector(0, 0, 0)
	v.Particles = {}

	for _, emitter in pairs(v.Boat:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("SpeedAlpha")) then
			continue
		end

		emitter.Enabled = false
		table.insert(v.Particles, {
			Object = emitter,
			Rate = emitter.Rate
		})
	end

	v.WaterEffect = WaterEffect(v.Boat)
	v.AirEffect = AirEffect(v.Boat)
	return (setmetatable(v, {
		__index = Effect
	}))
end

function Effect.update(data, p: number, p2: number, _: number)
	for _, particle in pairs(data.Particles) do
		local speedAlpha = particle.Object:GetAttribute("SpeedAlpha")
		local v = math.clamp((p - speedAlpha) / (1 - speedAlpha), 0, 1)
		particle.Object.Rate = particle.Rate * v
		particle.Object.Enabled = speedAlpha < p
	end

	local positionOffset = data.VehicleSeat.BodyPosition:GetAttribute("PositionOffset")
	data.VehicleSeat.BodyPosition:GetAttribute("YOffset")

	if positionOffset.Y > 2 then
		data.AirEffect:UpdateSpeedAlpha(p)

		if p > 0.25 then
			data.AirEffect:Enable("All", true, nil, 0.25)
		else
			data.AirEffect:Enable("All", false, nil, 0.25)
		end

		data.WaterEffect:Enable("All", "All", false, nil, 0.5)
	else
		data.WaterEffect:UpdateSpeedAlpha(p)

		if p > 0.5 then
			local v = p2 > 0.5 and "Left" or p2 < -0.5 and "Right" or false
			local v2 = v == "Left" and "Right" or v == "Right" and "Left" or false

			if p < 0.8 then
				data.WaterEffect:Enable("Front", "All", false, nil, 0.8)
			end

			if v then
				data.WaterEffect:Enable("Back", v, true, nil, 0.5)
				data.WaterEffect:Enable("Back", v2, false, nil, 0.5)
			else
				data.WaterEffect:Enable("Back", "All", true, nil, 0.5)
			end
		end

		if p > 0.8 then
			data.WaterEffect:Enable("Front", "All", true, nil, 0.8)
		elseif p < 0.5 then
			data.WaterEffect:Enable("All", "All", false, nil, 0.5)
		end

		data.AirEffect:Enable("All", false, nil, 0.5)
	end
end

return Effect