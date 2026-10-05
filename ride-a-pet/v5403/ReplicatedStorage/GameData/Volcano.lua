local v = {
	Tag = "VolcanoTop",
	MutationName = "Magma",
	SuccessChance = 15,
	BonusSeconds = 12,
	HoverHeight = 250,
	HoverDepth = 15,
	ServerRangeSlack = 10,
	CancelDistance = 400,
	LandingSpread = 40,
	TossSeconds = 1.4,
	SinkSeconds = 0.9,
	ShakeSeconds = 1.6,
	RiseSeconds = 0.7,
	TeaseSeconds = 2.6,
	HoverSeconds = 0.8,
	ReturnSeconds = 1.2,
	FlightScale = 8,
	TossArcHeight = 20,
	ReturnArcHeight = 28,
	ArcLiftPerStud = 0.3,
	SinkDepth = 12,
	ShakeAmount = 0.07,
	RiseHeight = 18,
	RevealTag = "Volcano",
	Scorching = table.freeze({
		Name = "Scorching",
		Description = "Pets are slower inside the volcano",
		Image = "rbxassetid://91862307779596",
		Gradient = ColorSequence.new(Color3.fromRGB(255, 60, 30), Color3.fromRGB(255, 170, 40))
	})
}

function v.Timeline(p: number)
	local v2 = p + v.TossSeconds + v.SinkSeconds + v.ShakeSeconds + v.RiseSeconds + v.TeaseSeconds
	return v2, v2 + v.HoverSeconds + v.ReturnSeconds
end

function v.IsOver(instance, vector: Vector3, value: number?)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector)
	local halfSize = instance.Size / 2
	local v3 = value or 0
	return math.abs(pointToObjectSpace.X) <= halfSize.X + v3 and math.abs(pointToObjectSpace.Z) <= halfSize.Z + v3 and pointToObjectSpace.Y >= halfSize.Y - v.HoverDepth - v3 and pointToObjectSpace.Y <= halfSize.Y + v.HoverHeight + v3
end

return table.freeze(v)