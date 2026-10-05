local createVector = vector.create
local v = {
	Cave = {
		Center = CFrame.new(10000, -600, 0),
		Size = createVector(1160, 220, 1550)
	},
	["Alien Command Ship"] = {
		Center = CFrame.new(-10000, -300, 0),
		Size = createVector(1000, 1000, 1000)
	},
	["Alien Mothership"] = {
		Center = CFrame.new(-10000, -300, 4000),
		Size = createVector(400, 120, 150)
	},
	HedgeMaze = {
		Center = CFrame.new(-10000, -300, -4000),
		Size = createVector(700, 150, 700)
	},
	FrogCave = {
		Center = CFrame.new(-10000, -300, -8000),
		Size = createVector(200, 100, 200)
	}
}
local ZoneModule = {}

function ZoneModule.GetZone(p)
	if (p * createVector(1, 0, 1)).Magnitude < 1600 and p.Y > -150 and p.Y < 1500 then
		return "Forest"
	end

	for k, v2 in pairs(v) do
		local v3 = v2.Center - p

		if math.abs(v3.X) < v2.Size.X / 2 and math.abs(v3.Y) < v2.Size.Y and math.abs(v3.Z) < v2.Size.Z then
			return k
		end
	end
end

function ZoneModule.GetZoneCFrame(p)
	if v[p] then
		return v[p].Center
	end
end

return ZoneModule