local RhythmObstacleGenerator = {}
local v = { -1, 0, 1 }
local v2 = {
	Block = 4,
	Box = 4,
	Dot = 4,
	Ramp = 2,
	Car = 1
}
local v3 = {
	easy = 6,
	medium = 5,
	hard = 4,
	endless = 4
}
local v4 = {
	easy = 0.35,
	medium = 0.4,
	hard = 0.5,
	endless = 0.5
}

local function getNumber(p, p2: string, p3: number)
	local v5 = p[p2]

	if typeof(v5) == "number" then
		return v5
	end

	return p3
end

local function hashString(value: string)
	local v5 = 5381

	for i = 1, #value do
		v5 = (v5 * 33 + string.byte(value, i)) % 2147483647
	end

	return (math.max(1, v5))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHitOffsets(p)
	if typeof(p.HitOffsets) == "table" and #p.HitOffsets > 0 then
		return p.HitOffsets
	end

	return { 0 }
end

local function getNoteTimes(p)
	local hitTime = p.HitTime
	local hitTime2 = p.HitTime
	local hitOffsets = getHitOffsets(p) -- equivalent call inferred; original call site unknown

	for _, hitOffset in hitOffsets, nil, nil do
		hitTime = math.min(hitTime, p.HitTime + hitOffset)
		hitTime2 = math.max(hitTime2, p.HitTime + hitOffset)
	end

	return hitTime, hitTime2
end

local function resolveSettings(chart)
	local v5 = typeof(chart.ObstacleSettings) ~= "table" and {} or chart.ObstacleSettings
	local v6 = typeof(chart.GeneratorSettings) ~= "table" and {} or chart.GeneratorSettings
	local difficulty = string.lower((tostring(chart.Difficulty or "medium")))
	local clone = table.clone(v2)

	if typeof(v5.TemplateWeights) == "table" then
		for k, templateWeight in v5.TemplateWeights do
			if not (typeof(k) == "string" and typeof(templateWeight) == "number") then
				continue
			end

			clone[k] = math.max(0, templateWeight)
		end
	end

	local v7 = string.format(
		"%s|%s|%s",
		tostring(chart.Name or "UnnamedSong"),
		tostring(chart.BPM or 0),
		(tostring(typeof(chart.Notes) == "table" and #chart.Notes or 0))
	)
	local seed = v5.Seed

	if typeof(seed) ~= "number" then
		local v8 = 5381

		for i = 1, #v7 do
			v8 = (v8 * 33 + string.byte(v7, i)) % 2147483647
		end

		seed = math.max(1, v8)
	end

	local candidateStepBeats = v5.CandidateStepBeats
	local v8 = {
		CandidateStepBeats = math.max(0.125, typeof(candidateStepBeats) ~= "number" and 0.25 or candidateStepBeats),
		MinObstacleGapBeats = 0,
		IntroBeats = 0,
		OutroBeats = 0,
		NoteClearanceBeats = 0,
		RampGapBeats = 0,
		DenseRunMinNotes = 0,
		DenseRunMaxGapBeats = 0,
		DenseRunPaddingBeats = 0,
		ReachabilityPaddingSeconds = 0,
		SpawnChance = 0,
		Seed = 0,
		TemplateWeights = 0
	}
	local v10 = v3[difficulty] or 5
	local minObstacleGapBeats = v5.MinObstacleGapBeats

	if typeof(minObstacleGapBeats) ~= "number" then
		minObstacleGapBeats = v10
	end

	v8.MinObstacleGapBeats = math.max(0.25, minObstacleGapBeats)
	local introBeats = v5.IntroBeats
	v8.IntroBeats = math.max(0, typeof(introBeats) ~= "number" and 8 or introBeats)
	local outroBeats = v5.OutroBeats
	v8.OutroBeats = math.max(0, typeof(outroBeats) ~= "number" and 4 or outroBeats)
	local noteClearanceBeats = v5.NoteClearanceBeats
	v8.NoteClearanceBeats = math.max(0, typeof(noteClearanceBeats) ~= "number" and 0.75 or noteClearanceBeats)
	local rampGapBeats = v5.RampGapBeats
	v8.RampGapBeats = math.max(1, typeof(rampGapBeats) ~= "number" and 4 or rampGapBeats)
	local denseRunMinNotes = v5.DenseRunMinNotes
	v8.DenseRunMinNotes = math.max(2, (math.floor(typeof(denseRunMinNotes) ~= "number" and 3 or denseRunMinNotes)))
	local runBreakSwitchGapBeats = v6.RunBreakSwitchGapBeats
	local v12 = typeof(runBreakSwitchGapBeats) ~= "number" and 1.1 or runBreakSwitchGapBeats
	local denseRunMaxGapBeats = v5.DenseRunMaxGapBeats

	if typeof(denseRunMaxGapBeats) == "number" then
		v12 = denseRunMaxGapBeats
	end

	v8.DenseRunMaxGapBeats = math.max(0, v12)
	local denseRunPaddingBeats = v5.DenseRunPaddingBeats
	v8.DenseRunPaddingBeats = math.max(0, typeof(denseRunPaddingBeats) ~= "number" and 0.1 or denseRunPaddingBeats)
	local reachabilityPaddingSeconds = v5.ReachabilityPaddingSeconds
	v8.ReachabilityPaddingSeconds = math.max(
		0,
		typeof(reachabilityPaddingSeconds) ~= "number" and 0.1 or reachabilityPaddingSeconds
	)
	local v13 = v4[difficulty] or 0.4
	local spawnChance = v5.SpawnChance

	if typeof(spawnChance) ~= "number" then
		spawnChance = v13
	end

	v8.SpawnChance = math.clamp(spawnChance, 0, 1)
	v8.Seed = seed
	v8.TemplateWeights = clone
	return v8
end

local function buildNoteData(chart)
	local clone = table.clone(chart.Notes)
	table.sort(clone, function(a, b)
		return a.HitTime < b.HitTime
	end)
	local result = {}
	local result2 = {}

	for _, note in clone do
		local noteTimes, lastTime = getNoteTimes(note)
		local lane = math.clamp(math.round(note.Lane), -1, 1)
		table.insert(result, {
			Note = note,
			Lane = lane,
			FirstTime = noteTimes,
			LastTime = lastTime
		})
		local hitOffsets = getHitOffsets(note) -- equivalent call inferred; original call site unknown

		for _, hitOffset in hitOffsets, nil, nil do
			table.insert(result2, {
				Time = note.HitTime + hitOffset,
				Lane = lane
			})
		end
	end

	table.sort(result2, function(a, b)
		return a.Time < b.Time
	end)
	return result, result2
end

local function findDenseRuns(noteData, p: number, settings)
	local v5 = settings.DenseRunMaxGapBeats * p
	local v6 = settings.DenseRunPaddingBeats * p
	local v7 = 1
	local result = {}

	for i = 2, #noteData + 1 do
		local v8

		if i <= #noteData then
			local v9 = noteData[i - 1]
			local v10 = noteData[i]

			if v10.Lane == v9.Lane then
				v8 = v10.FirstTime - v9.LastTime <= v5
			else
				v8 = false
			end
		else
			v8 = false
		end

		if v8 then
			continue
		end

		local noteCount = i - v7

		if settings.DenseRunMinNotes <= noteCount then
			table.insert(result, {
				StartTime = noteData[v7].FirstTime - v6,
				EndTime = noteData[i - 1].LastTime + v6,
				Lane = noteData[v7].Lane,
				NoteCount = noteCount
			})
		end

		v7 = i
	end

	return result
end

local function getTemplateInfo(data, settings)
	local v5 = data.JumpVelocity * data.JumpVelocity / (data.Gravity * 2)
	local result = {}

	for _, model in data.TemplatesFolder:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local weight = settings.TemplateWeights[model.Name] or 1
		local boundingBox, boundsSize = model:GetBoundingBox()

		if not (weight <= 0 or v5 < boundsSize.Y) then
			table.insert(result, {
				Template = model,
				Weight = weight,
				BoundsSize = boundsSize,
				BoundsToPivot = boundingBox:ToObjectSpace((model:GetPivot())),
				RelativeBoundsRotation = data.Pivot.Rotation:ToObjectSpace(boundingBox.Rotation)
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Template.Name < b.Template.Name
	end)
	return result
end

local function lanesAreProtected(affectedLanes, i: number, denseRuns)
	for _, item in denseRuns do
		if table.find(affectedLanes, item.Lane) and item.StartTime <= i and i <= item.EndTime then
			return true
		end
	end

	return false
end

local function getSurroundingHits(p: number, items)
	local v5 = nil

	for _, item in items do
		if item.Time <= p then
			v5 = item
		else
			return v5, item
		end
	end

	return v5, nil
end

local function getAffectedLanes(p: number, X: number, data)
	local v5 = X / 2 + data.ProbeWidth / 2
	local result = {}

	for _, v6 in v do
		if math.abs(v6 - p) * data.LaneWidth < v5 - 0.001 then
			table.insert(result, v6)
		end
	end

	return result
end

local function lanesAreClear(affectedLanes, i: number, items, p: number)
	for _, item in items do
		if table.find(affectedLanes, item.Lane) and math.abs(item.Time - i) < p then
			return false
		end
	end

	return true
end

local function laneIsReachable(p: number, p2: number, p3, p4, p5, p6)
	if p3 then
		local v5 = math.abs(p3.Lane - p) * p5.MoveCooldown

		if p2 - p3.Time < v5 + p6.ReachabilityPaddingSeconds then
			return false
		end
	end

	if p4 then
		local v5 = math.abs(p4.Lane - p) * p5.MoveCooldown

		if p4.Time - p2 < v5 + p6.ReachabilityPaddingSeconds then
			return false
		end
	end

	return true
end

local function chooseWeightedOption(random, list)
	local total = 0

	for _, v5 in list do
		total += v5.Weight
	end

	if total <= 0 then
		return nil
	end

	local number = random:NextNumber(0, total)
	local total2 = 0

	for _, v5 in list do
		total2 += v5.Weight

		if number <= total2 then
			return v5
		end
	end

	return list[#list]
end

function RhythmObstacleGenerator.BuildPlan(data)
	assert(typeof(data.Chart) == "table", "Obstacle generator requires a chart")
	assert(typeof(data.Chart.Notes) == "table", "Obstacle generator chart is missing Notes")
	assert(data.Speed > 0, "Obstacle generator requires a positive speed")
	assert(data.Gravity > 0, "Obstacle generator requires positive gravity")
	local settings = resolveSettings(data.Chart)
	local v5 = 60 / data.Chart.BPM
	local noteData, v6 = buildNoteData(data.Chart)
	local denseRuns = findDenseRuns(noteData, v5, settings)
	local templateInfo = getTemplateInfo(data, settings)
	local events = {}

	if #noteData == 0 or #templateInfo == 0 then
		return {
			Seed = settings.Seed,
			Events = events,
			ProtectedRuns = denseRuns,
			Settings = settings
		}
	end

	local random = Random.new(settings.Seed)
	local v8 = settings.CandidateStepBeats * v5
	local v9 = settings.IntroBeats * v5
	local v10 = noteData[#noteData].LastTime - settings.OutroBeats * v5
	local v11 = settings.MinObstacleGapBeats * v5
	local v12 = settings.NoteClearanceBeats * v5
	local v13 = settings.RampGapBeats * v5
	local v14 = {
		[-1] = -1e999,
		[0] = -1e999,
		[1] = -1e999
	}
	local v15 = {
		[-1] = -1e999,
		[0] = -1e999,
		[1] = -1e999
	}

	for i = v9, v10, v8 do
		local v16 = nil
		local v17 = nil

		for _, v19 in v6 do
			if v19.Time <= i then
				v16 = v19
			else
				v17 = v19
				break
			end
		end

		local lane

		if v16 and v17 then
			if i - v16.Time <= v17.Time - i then
				lane = v16.Lane
			else
				lane = v17.Lane
			end
		elseif v16 then
			lane = v16.Lane
		else
			lane = not v17 and 0 or v17.Lane
		end

		local clone = table.clone(v)

		for i2 = #clone, 2, -1 do
			local integer = random:NextInteger(1, i2)
			local v19 = clone[integer]
			local v20 = clone[i2]
			clone[i2] = v19
			clone[integer] = v20
		end

		local v19 = {}

		for _, lane2 in clone do
			if i - v14[lane2] < v11 or random:NextNumber() > settings.SpawnChance then
				continue
			end

			local aesthetic = lane2 ~= lane
			local v22 = {}

			for _, templateInfo3 in templateInfo do
				local affectedLanes = getAffectedLanes(lane2, templateInfo3.BoundsSize.X, data)

				if templateInfo3.Template.Name == "Ramp" then
					local flag = false

					for _, affectedLane in affectedLanes do
						if not (i - v15[affectedLane] < v13) then
							continue
						end

						flag = true
						break
					end

					if flag then
						continue
					end
				end

				if lanesAreProtected(affectedLanes, i, denseRuns) or not lanesAreClear(affectedLanes, i, v6, v12) then
					continue
				end

				if not aesthetic then
					local v24, v25

					if v16 then
						local v26 = math.abs(v16.Lane - lane2) * data.MoveCooldown

						if i - v16.Time < v26 + settings.ReachabilityPaddingSeconds then
							v24 = false
						elseif v17 then
							v25 = math.abs(v17.Lane - lane2) * data.MoveCooldown
							v24 = not (v17.Time - i < v25 + settings.ReachabilityPaddingSeconds)
						else
							v24 = true
						end
					elseif v17 then
						v25 = math.abs(v17.Lane - lane2) * data.MoveCooldown
						v24 = not (v17.Time - i < v25 + settings.ReachabilityPaddingSeconds)
					else
						v24 = true
					end

					if not v24 then
						continue
					end
				end

				local v24 = false

				for _, v26 in v19 do
					if not (math.abs(lane2 - v26.Lane) * data.LaneWidth < (templateInfo3.BoundsSize.X + v26.Width) / 2 + 0.1) then
						continue
					end

					v24 = true
					break
				end

				if not v24 then
					table.insert(v22, {
						Lane = lane2,
						TemplateInfo = templateInfo3,
						AffectedLanes = affectedLanes,
						Weight = templateInfo3.Weight
					})
				end
			end

			local v23 = chooseWeightedOption(random, v22)

			if not v23 then
				continue
			end

			local templateInfo2 = v23.TemplateInfo
			table.insert(events, {
				TargetTime = i,
				Lane = lane2,
				Template = templateInfo2.Template,
				AffectedLanes = v23.AffectedLanes,
				BoundsSize = templateInfo2.BoundsSize,
				BoundsToPivot = templateInfo2.BoundsToPivot,
				RelativeBoundsRotation = templateInfo2.RelativeBoundsRotation,
				Aesthetic = aesthetic
			})
			table.insert(v19, {
				Lane = lane2,
				Width = templateInfo2.BoundsSize.X
			})

			for _, affectedLane in v23.AffectedLanes do
				v14[affectedLane] = i

				if templateInfo2.Template.Name == "Ramp" then
					v15[affectedLane] = i
				end
			end
		end
	end

	return {
		Seed = settings.Seed,
		Events = events,
		ProtectedRuns = denseRuns,
		Settings = settings
	}
end

function RhythmObstacleGenerator.Generate(data)
	assert(data.Map, "Obstacle generator requires a runtime map")
	assert(data.Trove, "Obstacle generator requires a Trove")
	local plan = RhythmObstacleGenerator.BuildPlan(data)
	local map = data.Map
	local mapStartPivot = data.MapStartPivot or map:GetPivot()
	local parent = data.Trove:Add(Instance.new("Folder"))
	parent.Name = "GeneratedObstacles"
	parent:SetAttribute("Seed", plan.Seed)
	parent:SetAttribute("Count", #plan.Events)
	parent.Parent = map

	for k, event in plan.Events do
		local clone = data.Trove:Clone(event.Template)
		clone.Name = string.format("%03d_%s", k, event.Template.Name)
		clone:SetAttribute("Generated", true)
		clone:SetAttribute("TargetTime", event.TargetTime)
		clone:SetAttribute("Lane", event.Lane)
		clone:SetAttribute("Template", event.Template.Name)
		clone:SetAttribute("Aesthetic", event.Aesthetic)

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		local v6 = data.Pivot * CFrame.new(event.Lane * data.LaneWidth, event.BoundsSize.Y / 2, 0) * event.RelativeBoundsRotation
		local v7 = event.TargetTime * data.Speed
		clone:PivotTo((mapStartPivot * CFrame.new(0, 0, -v7) * mapStartPivot:Inverse()):Inverse() * v6 * event.BoundsToPivot)
		clone.Parent = parent
	end

	if data.Debug then
		print(string.format(
			"[OBSTACLES] song=%s seed=%d events=%d protectedRuns=%d",
			tostring(data.Chart.Name or "unknown"),
			plan.Seed,
			#plan.Events,
			#plan.ProtectedRuns
		))
	end

	return plan
end

return RhythmObstacleGenerator