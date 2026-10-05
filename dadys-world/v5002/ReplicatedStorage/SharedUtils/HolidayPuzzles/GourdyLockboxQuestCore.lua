local GourdyLockboxQuestCore = {
	BEAT_FINAL = "Final",
	BEAT_INTRO = "Intro",
	buildIndex = function(list, list2)
		local v = {}
		local result = {}
		local v2 = {
			steps = {},
			pieces = {},
			parts = {},
			partOrder = {}
		}

		for _, v3 in ipairs(list2) do
			v[v3] = true
		end

		for _, v3 in ipairs(list) do
			local id = v3.Id

			if type(id) == "string" and not v2.parts[id] then
				local v4 = {
					kind = tostring(v3.Kind),
					pieces = {},
					requiresAnotherPart = v3.RequiresAnotherPart == true
				}

				for _, v5 in ipairs(v3.Pieces or {}) do
					local id2 = v5.Id

					if v[id2] then
						if v2.pieces[id2] then
							table.insert(
								result,
								("%s: piece %s already belongs to %s — skipped"):format(id, id2, v2.pieces[id2].part)
							)
						else
							local steps = {}

							for _, v7 in ipairs(v5.Steps or {}) do
								if v2.steps[v7] then
									table.insert(
										result,
										("%s: step %s already belongs to %s — skipped"):format(
											id,
											tostring(v7),
											v2.steps[v7].part
										)
									)
								else
									v2.steps[v7] = {
										part = id,
										piece = id2,
										kind = v4.kind
									}
									table.insert(steps, v7)
								end
							end

							if #steps == 0 then
								table.insert(
									result,
									("%s: piece %s has no steps — it can never be earned"):format(id, id2)
								)
							end

							local required = math.clamp(math.floor(tonumber(v5.Required) or #steps), 0, #steps)
							v2.pieces[id2] = {
								part = id,
								steps = steps,
								required = required
							}
							table.insert(v4.pieces, id2)
						end
					else
						table.insert(
							result,
							("%s: piece %s is not in the collection roster — skipped"):format(id, (tostring(id2)))
						)
					end
				end

				v2.parts[id] = v4
				table.insert(v2.partOrder, id)
			else
				table.insert(result, ("part %s is unnamed or duplicated — skipped"):format((tostring(id))))
			end
		end

		for _, v3 in ipairs(list2) do
			if not v2.pieces[v3] then
				table.insert(result, ("roster piece %s has no quest part — it can never be earned"):format(v3))
			end
		end

		return v2, result
	end,
	normalizeState = function(p, p2)
		if type(p) ~= "table" then
			return {
				Steps = {}
			}
		end

		local steps = p.Steps

		if type(steps) ~= "table" then
			steps = {}
			p.Steps = steps
		end

		for k in pairs(steps) do
			if not p2.steps[k] then
				steps[k] = nil
			end
		end

		return p
	end,
	isPieceHeld = function(p, p2: string)
		return type(p) == "table" and p[p2] ~= nil
	end
}

function GourdyLockboxQuestCore.isPartComplete(p, p2, p3: string)
	local part = p.parts[p3]

	if not part or #part.pieces == 0 then
		return false
	end

	for _, piece in ipairs(part.pieces) do
		if not GourdyLockboxQuestCore.isPieceHeld(p2, piece) then
			return false
		end
	end

	return true
end

function GourdyLockboxQuestCore.anyOtherPartComplete(p, p2, p3: string)
	for _, v in ipairs(p.partOrder) do
		if v ~= p3 and GourdyLockboxQuestCore.isPartComplete(p, p2, v) then
			return true
		end
	end

	return false
end

function GourdyLockboxQuestCore.isPartUnlocked(p, p2, p3: string)
	local part = p.parts[p3]

	if part then
		return not part.requiresAnotherPart or GourdyLockboxQuestCore.anyOtherPartComplete(p, p2, p3)
	end

	return false
end

function GourdyLockboxQuestCore.countStepsDone(p, p2, p3: string)
	local piece = p.pieces[p3]

	if not piece or type(p2) ~= "table" then
		return 0
	end

	local count = 0

	for _, step in ipairs(piece.steps) do
		if p2[step] ~= nil then
			count += 1
		end
	end

	return count
end

function GourdyLockboxQuestCore.milestoneCompletedBy(list, p, p2: string, p3: string?)
	if p3 or type(list) ~= "table" or type(p) ~= "table" then
		return nil
	end

	for _, v in ipairs(list) do
		if not table.find(v.Steps, p2) then
			continue
		end

		local flag = true

		for _, step in ipairs(v.Steps) do
			if p[step] ~= nil then
				continue
			end

			flag = false
			break
		end

		if flag then
			return v
		end
	end

	return nil
end

function GourdyLockboxQuestCore.isStepDone(p, p2, p3, p4: string)
	local step = p.steps[p4]

	if not step then
		return false
	end

	if GourdyLockboxQuestCore.isPieceHeld(p3, step.piece) then
		return true
	end

	return type(p2) == "table" and p2[p4] ~= nil
end

function GourdyLockboxQuestCore.canAttemptStep(p, p2, p3, p4: string)
	local step = p.steps[p4]

	if not step then
		return false, "UNKNOWN_STEP"
	end

	local v

	if type(p2) == "table" then
		v = p2.Steps or nil
	end

	if GourdyLockboxQuestCore.isStepDone(p, v, p3, p4) then
		return false, "STEP_DONE"
	end

	if GourdyLockboxQuestCore.isPartUnlocked(p, p3, step.part) then
		return true, nil
	end

	return false, "PART_LOCKED"
end

function GourdyLockboxQuestCore.applyStep(p, p2, p3, p4: string, p5: number)
	if not GourdyLockboxQuestCore.canAttemptStep(p, p2, p3, p4) then
		return false, nil
	end

	local step = p.steps[p4]
	p2.Steps[p4] = p5
	local piece = p.pieces[step.piece]

	if GourdyLockboxQuestCore.countStepsDone(p, p2.Steps, step.piece) >= piece.required then
		return true, step.piece
	end

	return true, nil
end

function GourdyLockboxQuestCore.countHeld(list, p)
	local count = 0

	for _, v in ipairs(list) do
		if GourdyLockboxQuestCore.isPieceHeld(p, v) then
			count += 1
		end
	end

	return count
end

function GourdyLockboxQuestCore.isSetComplete(list, p)
	return #list > 0 and GourdyLockboxQuestCore.countHeld(list, p) == #list
end

function GourdyLockboxQuestCore.pendingLobbyBeat(p, p2, p3)
	local v

	if type(p) == "table" then
		v = p.ShrineIntroSeen ~= nil
	else
		v = false
	end

	local v2

	if type(p) == "table" then
		v2 = p.FinalRevealSeen ~= nil
	else
		v2 = false
	end

	if GourdyLockboxQuestCore.isSetComplete(p2, p3) then
		if v2 then
			return nil
		end

		return GourdyLockboxQuestCore.BEAT_FINAL
	elseif GourdyLockboxQuestCore.countHeld(p2, p3) > 0 and not v then
		return GourdyLockboxQuestCore.BEAT_INTRO
	else
		return nil
	end
end

function GourdyLockboxQuestCore.newBeatHolds()
	local v = 0
	return {
		acquire = function()
			v += 1
			local flag = false
			return function()
				if flag then
					return
				end

				flag = true
				v -= 1
			end
		end,
		isHeld = function()
			return v > 0
		end
	}
end

function GourdyLockboxQuestCore.canStartLobbyBeat(flag: boolean, flag2: boolean, flag3: boolean, flag4: boolean)
	return not flag and not flag2 and flag3 and flag4
end

function GourdyLockboxQuestCore.newQuietClock()
	local v = nil
	return {
		observe = function(flag: boolean, p: number)
			if flag then
				v = nil
				return 0
			end

			local v2 = v or p
			v = v2
			return p - v2
		end,
		disturb = function(p: number)
			v = p
		end
	}
end

function GourdyLockboxQuestCore.lobbyLetsBeatStart(p: number?, p2: number, p3: number, list)
	return not (list and table.find(list, tonumber(p) or 0)) and p3 <= p2
end

function GourdyLockboxQuestCore:markBeatSeen(p: string, p2, p3, p4: number)
	if p == GourdyLockboxQuestCore.BEAT_FINAL then
		if not GourdyLockboxQuestCore.isSetComplete(p2, p3) or self.FinalRevealSeen ~= nil then
			return false
		end

		self.FinalRevealSeen = p4

		if self.ShrineIntroSeen == nil then
			self.ShrineIntroSeen = p4
		end
	else
		if p ~= GourdyLockboxQuestCore.BEAT_INTRO or (GourdyLockboxQuestCore.countHeld(p2, p3) == 0 or self.ShrineIntroSeen ~= nil) then
			return false
		end

		self.ShrineIntroSeen = p4
	end

	return true
end

function GourdyLockboxQuestCore:stampCompletion(p2, p3, completedAt: number)
	if self.CompletedAt ~= nil or not GourdyLockboxQuestCore.isSetComplete(p2, p3) then
		return false
	end

	self.CompletedAt = completedAt
	return true
end

function GourdyLockboxQuestCore.hasCompleted(p, p2, p3)
	if type(p) == "table" and p.CompletedAt ~= nil then
		return true
	end

	return GourdyLockboxQuestCore.isSetComplete(p2, p3)
end

return GourdyLockboxQuestCore