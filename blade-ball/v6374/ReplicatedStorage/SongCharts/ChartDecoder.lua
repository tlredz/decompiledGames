local v = {
	"easy",
	"medium",
	"hard",
	"endless"
}

local function decodeStream(N, p: number, p2: number, p3: number)
	local count = #N
	local result = table.create(count // 2)
	local v2 = 60 / p
	local total = 1
	local total2 = 0

	while total < count do
		total2 += N[total]
		local v3 = N[total + 1]
		total += 2
		local v4 = v3 >= 3
		local hitOffsets

		if v4 then
			hitOffsets = { 0, N[total] / 1000 }
			total += 1
		else
			hitOffsets = { 0 }
		end

		local hitTime = total2 / 1000
		local v7 = (hitTime - p2) / v2
		result[#result + 1] = {
			HitTime = hitTime,
			Lane = v3 % 3 - 1,
			Type = v4 and "blue" or "red",
			HitOffsets = hitOffsets,
			Bar = math.floor(v7 / p3) + 1,
			Beat = v7 % p3 + 1
		}
	end

	return result
end

local function pick(p, p2, p3: string, p4)
	if p ~= nil and p[p3] ~= nil then
		return p[p3]
	end

	if p2[p3] == nil then
		return p4
	end

	return p2[p3]
end

return {
	Resolve = function(data, value: string?)
		assert(typeof(data) == "table", "ChartDecoder.Resolve: song must be a table")
		local difficulties

		if typeof(data.Difficulties) == "table" then
			difficulties = data.Difficulties
		end

		local v2

		if typeof(value) == "string" then
			v2 = string.lower(value)
		end

		local v3 = nil

		if difficulties then
			if v2 and typeof(difficulties[v2]) == "table" then
				v3 = difficulties[v2]
			else
				local defaultDifficulty

				if typeof(data.DefaultDifficulty) == "string" then
					defaultDifficulty = string.lower(data.DefaultDifficulty)
				end

				if defaultDifficulty and typeof(difficulties[defaultDifficulty]) == "table" then
					v3 = difficulties[defaultDifficulty]
					v2 = defaultDifficulty
				else
					for _, v5 in v do
						if typeof(difficulties[v5]) ~= "table" then
							continue
						end

						v3 = difficulties[v5]
						v2 = v5
						break
					end
				end
			end
		end

		local v4

		if v3 == nil or v3.BPM == nil then
			v4 = data.BPM == nil and 120 or data.BPM
		else
			v4 = v3.BPM
		end

		local BPM = tonumber(v4)
		local v6

		if v3 == nil or v3.Offset == nil then
			v6 = data.Offset == nil and 0 or data.Offset
		else
			v6 = v3.Offset
		end

		local offset = tonumber(v6)
		local v8

		if v3 == nil or v3.BeatsPerBar == nil then
			v8 = data.BeatsPerBar == nil and 4 or data.BeatsPerBar
		else
			v8 = v3.BeatsPerBar
		end

		local beatsPerBar = tonumber(v8)
		local notes3 = nil
		local N

		if v3 then
			N = v3.N
		else
			N = data.N
		end

		if typeof(N) == "table" then
			notes3 = decodeStream(N, BPM, offset, beatsPerBar)
		else
			local notes

			if v3 == nil or v3.Notes == nil then
				if data.Notes ~= nil then
					notes = data.Notes
				end
			else
				notes = v3.Notes
			end

			if typeof(notes) == "table" then
				notes3 = {}
				local notes2 = {}

				if v3 == nil or v3.Notes == nil then
					if data.Notes ~= nil then
						notes2 = data.Notes
					end
				else
					notes2 = v3.Notes
				end

				for _, note in notes2, nil, nil do
					local hitOffsets = {}

					for k, v14 in typeof(note.HitOffsets) ~= "table" and { 0 } or note.HitOffsets do
						hitOffsets[k] = v14
					end

					notes3[#notes3 + 1] = {
						HitTime = note.HitTime,
						Lane = note.Lane,
						Type = note.Type,
						HitOffsets = hitOffsets,
						Bar = note.Bar,
						Beat = note.Beat
					}
				end
			else
				error("ChartDecoder.Resolve: chart has neither N nor Notes")
			end
		end

		local judgement

		if v3 == nil or v3.Judgement == nil then
			if data.Judgement ~= nil then
				judgement = data.Judgement
			end
		else
			judgement = v3.Judgement
		end

		local judgement2 = (typeof(judgement) ~= "table" or judgement.Miss == nil or judgement.Perfect == nil or judgement.Good == nil) and {
			Perfect = 0.045,
			Great = 0.075,
			Good = 0.11,
			Ok = 0.15,
			Miss = 0.15
		} or judgement
		local name

		if v3 == nil or v3.Name == nil then
			name = data.Name == nil and "Unknown" or data.Name
		else
			name = v3.Name
		end

		local credits

		if v3 == nil or v3.Credits == nil then
			credits = data.Credits == nil and "" or data.Credits
		else
			credits = v3.Credits
		end

		local soundId

		if v3 == nil or v3.SoundId == nil then
			soundId = data.SoundId == nil and "" or data.SoundId
		else
			soundId = v3.SoundId
		end

		local thumbnailId

		if v3 == nil or v3.ThumbnailId == nil then
			thumbnailId = data.ThumbnailId == nil and "rbxassetid://0" or data.ThumbnailId
		else
			thumbnailId = v3.ThumbnailId
		end

		local v17

		if v3 == nil or v3.BasePulseBeats == nil then
			v17 = data.BasePulseBeats == nil and 2 or data.BasePulseBeats
		else
			v17 = v3.BasePulseBeats
		end

		local v12 = {
			Name = name,
			Credits = credits,
			SoundId = soundId,
			ThumbnailId = thumbnailId,
			BPM = BPM,
			Offset = offset,
			BeatsPerBar = beatsPerBar,
			BasePulseBeats = tonumber(v17),
			TimeLength = 0,
			Difficulty = 0,
			Judgement = 0,
			Endless = 0,
			GeneratorSettings = 0,
			Notes = 0
		}
		local v18

		if v3 == nil or v3.TimeLength == nil then
			v18 = data.TimeLength == nil and 0 or data.TimeLength
		else
			v18 = v3.TimeLength
		end

		v12.TimeLength = tonumber(v18)
		v12.Difficulty = v2 or "easy"
		v12.Judgement = judgement2
		local endless

		if v3 then
			endless = v3.Endless
		end

		v12.Endless = endless
		local v21

		if v3 == nil or v3.HardSameLaneGapBeats == nil then
			v21 = data.HardSameLaneGapBeats == nil and 0.75 or data.HardSameLaneGapBeats
		else
			v21 = v3.HardSameLaneGapBeats
		end

		local generatorSettings = {
			Mode = "bbgen_analytic_grid",
			HardSameLaneGapBeats = tonumber(v21),
			RunBreakSwitchGapBeats = 0
		}
		local v22

		if v3 == nil or v3.RunBreakSwitchGapBeats == nil then
			v22 = data.RunBreakSwitchGapBeats == nil and 1.1 or data.RunBreakSwitchGapBeats
		else
			v22 = v3.RunBreakSwitchGapBeats
		end

		generatorSettings.RunBreakSwitchGapBeats = tonumber(v22)
		v12.GeneratorSettings = generatorSettings
		v12.Notes = notes3
		return v12
	end
}