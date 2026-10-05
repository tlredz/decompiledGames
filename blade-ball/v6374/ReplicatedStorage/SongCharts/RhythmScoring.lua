local RhythmScoring = {}
local v = {
	"Perfect",
	"Great",
	"Good",
	"Ok"
}
local defaultWindows = {
	Perfect = 0.045,
	Great = 0.075,
	Good = 0.11,
	Ok = 0.15,
	Miss = 0.15
}
local points = {
	Perfect = 300,
	Great = 200,
	Good = 100,
	Ok = 50,
	Miss = 0
}
local v4 = {
	{
		combo = 40,
		multiplier = 8
	},
	{
		combo = 20,
		multiplier = 4
	},
	{
		combo = 8,
		multiplier = 2
	},
	{
		combo = 0,
		multiplier = 1
	}
}

function RhythmScoring.MultiplierFor(p: number)
	for _, v5 in v4 do
		if v5.combo <= p then
			return v5.multiplier
		end
	end

	return 1
end

function RhythmScoring.Judge(p: number, p2)
	if typeof(p2) ~= "table" then
		p2 = defaultWindows
	end

	local v5 = math.abs(p)

	for _, v6 in v do
		if v5 <= (tonumber(p2[v6]) or defaultWindows[v6]) then
			return v6
		end
	end

	return "Miss"
end

function RhythmScoring.DistanceFor(p: number, p2: number)
	return math.abs(p) * p2
end

function RhythmScoring.NewSession(totalNotes: number)
	return {
		score = 0,
		combo = 0,
		bestCombo = 0,
		hits = 0,
		totalNotes = totalNotes,
		counts = {
			Perfect = 0,
			Great = 0,
			Good = 0,
			Ok = 0,
			Miss = 0
		},
		earned = 0,
		possible = 0
	}
end

function RhythmScoring:Register(p: number?, p2)
	local v5 = p == nil and "Miss" or RhythmScoring.Judge(p, p2)
	local multiplierFor = RhythmScoring.MultiplierFor(self.combo)
	local v6 = points[v5]

	if v5 == "Miss" then
		self.combo = 0
		multiplierFor = RhythmScoring.MultiplierFor(0)
	else
		self.combo += 1
		self.hits += 1

		if self.combo > self.bestCombo then
			self.bestCombo = self.combo
		end
	end

	local v7 = v6 * multiplierFor
	self.score += v7
	self.counts[v5] += 1
	self.earned += v6
	self.possible += points.Perfect
	return v5, v7, multiplierFor
end

function RhythmScoring:RegisterEmptyClick()
	self.combo = 0
end

function RhythmScoring.Accuracy(p)
	if p.possible <= 0 then
		return 0
	end

	return p.earned / p.possible
end

function RhythmScoring.Grade(p: number)
	if p >= 0.95 then
		return "SS"
	end

	if p >= 0.9 then
		return "S"
	end

	if p >= 0.8 then
		return "A"
	end

	if p >= 0.7 then
		return "B"
	end

	if p >= 0.6 then
		return "C"
	end

	return "D"
end

function RhythmScoring.Summary(data)
	local accuracy = RhythmScoring.Accuracy(data)
	return {
		Score = data.score,
		Accuracy = accuracy,
		Grade = RhythmScoring.Grade(accuracy),
		BestCombo = data.bestCombo,
		FullCombo = data.counts.Miss == 0 and data.hits > 0,
		Counts = data.counts
	}
end

RhythmScoring.Points = points
RhythmScoring.DefaultWindows = defaultWindows
RhythmScoring.MaxMultiplier = 8
return RhythmScoring