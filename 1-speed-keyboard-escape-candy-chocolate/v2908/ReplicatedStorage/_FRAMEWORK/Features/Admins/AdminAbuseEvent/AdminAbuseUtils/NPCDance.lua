local RunService = game:GetService("RunService")
local Animations = require(script.Parent.Animations)
local v = {
	stop = function() end
}

local function resolveFolder(child, npcsFolderPath: string)
	for childName in string.gmatch(npcsFolderPath, "[^/]+") do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

local function pickNextIndex(p: number, p2: number?)
	if p == 1 or p2 == nil then
		return math.random(1, p)
	end

	local v2 = math.random(1, p - 1)

	if p2 <= v2 then
		return v2 + 1
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIndex(state, currentIndex: number, p: number)
	if state.currentIndex then
		local track = state.tracks[state.currentIndex]

		if track.IsPlaying then
			track:Stop(p)
		end
	end

	state.tracks[currentIndex]:Play(p)
	state.currentIndex = currentIndex
end

local function loadTracks(instance, items)
	local result = {}

	for _, item in items do
		local success, result2 = pcall(Animations.loadAnimation, instance, item)

		if success then
			result2.Looped = true
			table.insert(result, result2)
		else
			warn(string.format(
				"[AdminAbuseUtils.NPCDance] LoadAnimation failed for %s: %s",
				instance:GetFullName(),
				(tostring(result2))
			))
		end
	end

	return result
end

local function checkStartReady(data)
	if data.map == nil then
		return false, nil, "AdminAbuseUtils.NPCDance.start requires a map"
	end

	if #data.animationIds == 0 and data.animationIdsForRig == nil then
		return false, nil, "AdminAbuseUtils.NPCDance.start requires animationIds or animationIdsForRig"
	end

	local npcsFolderPath = data.npcsFolderPath or "Scriptables/NPCs"
	local folder = resolveFolder(data.map, npcsFolderPath)

	if folder then
		return true, folder, ""
	end

	return
		true,
		nil,
		string.format("[AdminAbuseUtils.NPCDance] '%s' was not found under %s", npcsFolderPath, data.map:GetFullName())
end

local function applyStart(data, instance)
	local fadeSeconds = data.fadeSeconds or 0.25
	local switchMinSeconds = data.switchMinSeconds or 6
	local switchMaxSeconds = data.switchMaxSeconds or 14
	local v2 = {}
	local v3 = {}
	local flag = false

	local function addRig(model)
		if flag or v3[model] then
			return
		end

		local v4

		if data.animationIdsForRig then
			v4 = data.animationIdsForRig(model)
		else
			v4 = data.animationIds
		end

		local tracks = loadTracks(model, v4)

		if #tracks > 0 then
			v3[model] = true
			local v6 = {
				rig = model,
				tracks = tracks,
				currentIndex = nil,
				timeSinceLastChange = 0,
				nextChangeDuration = math.random(switchMinSeconds, switchMaxSeconds)
			}
			playIndex(v6, math.random(1, #tracks), fadeSeconds) -- equivalent call inferred; original call site unknown
			table.insert(v2, v6)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChild(model)
		if model:IsA("Model") then
			addRig(model)
		end
	end

	local childAddedConnection = instance.ChildAdded:Connect(onChild)

	for _, child in instance:GetChildren() do
		onChild(child) -- equivalent call inferred; original call site unknown
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		for _, v4 in v2 do
			if #v4.tracks == 1 then
				continue
			end

			v4.timeSinceLastChange += dt

			if not (v4.timeSinceLastChange >= v4.nextChangeDuration) then
				continue
			end

			v4.timeSinceLastChange = 0
			v4.nextChangeDuration = math.random(switchMinSeconds, switchMaxSeconds)
			local count = #v4.tracks
			local currentIndex = v4.currentIndex
			local v5

			if count == 1 or currentIndex == nil then
				v5 = math.random(1, count)
			else
				v5 = math.random(1, count - 1)

				if currentIndex <= v5 then
					v5 += 1
				end
			end

			playIndex(v4, v5, fadeSeconds) -- equivalent call inferred; original call site unknown
		end
	end)
	return {
		stop = function()
			if flag then
				return
			end

			flag = true

			if childAddedConnection then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			for _, v4 in v2 do
				for _, track in v4.tracks do
					if track.IsPlaying then
						track:Stop(0)
					end
				end
			end

			table.clear(v2)
			table.clear(v3)
		end
	}
end

return {
	start = function(p)
		local v2, v3, v4 = checkStartReady(p)

		if not v2 then
			error(v4)
			return
		end

		if v3 then
			return (applyStart(p, v3))
		end

		warn(v4)
		return v
	end
}