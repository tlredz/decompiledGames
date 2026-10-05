local createVector = vector.create
local DonkeyKongMotion = {
	Scale = 2.5,
	Radius = 4,
	HitRadius = 5.525
}
local _, v = game.ReplicatedStorage:WaitForChild("Barrel"):GetBoundingBox()
DonkeyKongMotion.HitRadius = math.max(DonkeyKongMotion.Radius, v.X * DonkeyKongMotion.Radius / math.max(v.Y, v.Z)) + 0.9

function DonkeyKongMotion.bounce(p)
	local v2 = math.max(0, p)

	for _, v3 in {
		{ 0.9, 9 },
		{ 0.65, 4 },
		{ 0.45, 1.5 }
	} do
		if v2 < v3[1] then
			local v4 = v2 / v3[1]
			return 4 * v3[2] * v4 * (1 - v4)
		else
			v2 -= v3[1]
		end
	end

	return 0
end

function DonkeyKongMotion.position(_, data, p)
	local v2 = math.max(0, p - data.born)
	local v3 = math.clamp(v2 * data.speed / data.length, 0, 1) * (#data.points - 1)
	local v4 = math.min(#data.points - 1, math.floor(v3) + 1)
	return data.points[v4]:Lerp(data.points[v4 + 1], v3 - (v4 - 1)) + createVector(0, 1, 0) * (DonkeyKongMotion.Radius + DonkeyKongMotion.bounce(v2))
end

function DonkeyKongMotion.contact(p, p2, p3, p4, p5)
	local vector2 = p - p3
	local vector3 = p2 - p - (p4 - p3)
	return (vector2 + vector3 * (not (vector3:Dot(vector3) > 0.0001) and 0 or math.clamp(
		-vector2:Dot(vector3) / vector3:Dot(vector3),
		0,
		1
	) or 0)).Magnitude <= p5
end

return DonkeyKongMotion