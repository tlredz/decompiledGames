local RunService = game:GetService("RunService")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidRunContext(p)
	return p == "server" or p == "client" or p == "both"
end

local function isFiniteNonNegative(p: number)
	return p >= 0 and p < 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldRunInCurrentContext(runContext: string)
	if runContext == "both" then
		return true
	end

	if RunService:IsServer() then
		return runContext == "server"
	end

	return runContext == "client"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertElapsedTime(value: number)
	local v2

	if type(value) == "number" and value >= 0 then
		v2 = value < 1e999
	else
		v2 = false
	end

	assert(v2, "AdminAbuseUtils.Sequence requires a finite, non-negative elapsedTime")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupState(state)
	if state.cleaned then
		return
	end

	state.cleaned = true
	state.version += 1
	v[state] = nil
	table.clear(state.entries)
	state.nextEntryIndex = 1
end

local function runCallback(state, entry)
	local version = state.version
	local v2, v3 = xpcall(function()
		entry.callback()
		return nil
	end, debug.traceback)

	if not v2 then
		warn((`[AdminAbuseUtils.Sequence] Callback at source index {entry.sourceIndex} failed: {tostring(v3)}`))
	end

	return not state.cleaned and version == state.version
end

local function runDueEntries(state, value: number, flag: boolean)
	while state.nextEntryIndex <= #state.entries do
		local entry = state.entries[state.nextEntryIndex]

		if value < entry.time then
			break
		end

		state.nextEntryIndex += 1
		local v2 = shouldRunInCurrentContext(entry.runContext) -- equivalent call inferred; original call site unknown

		if v2 and (not flag or entry.runOnCatchup) and not runCallback(state, entry) then
			break
		end
	end
end

local Sequencer = {}

function Sequencer.new()
	local v2 = {
		entries = {},
		nextEntryIndex = 1,
		started = false,
		cleaned = false,
		version = 1
	}
	v[v2] = true
	return {
		push = function(time: number, runContext: string, callback, flag: boolean?)
			assert(not v2.cleaned, "AdminAbuseUtils.Sequence.push cannot run after Cleanup")
			assert(not v2.started, "AdminAbuseUtils.Sequence.push cannot run after Start")
			local v3

			if type(time) == "number" and time >= 0 then
				v3 = time < 1e999
			else
				v3 = false
			end

			assert(v3, "AdminAbuseUtils.Sequence.push requires a finite, non-negative time")
			assert(isValidRunContext(runContext), "AdminAbuseUtils.Sequence.push received an invalid runContext")
			assert(type(callback) == "function", "AdminAbuseUtils.Sequence.push requires a callback")
			assert(
				flag == nil or type(flag) == "boolean",
				"AdminAbuseUtils.Sequence.push requires runOnCatchup to be a boolean when provided"
			)
			table.insert(v2.entries, {
				time = time,
				callback = callback,
				runContext = runContext,
				runOnCatchup = flag == true,
				sourceIndex = #v2.entries + 1
			})
		end,
		Start = function(value: number)
			assert(not v2.cleaned, "AdminAbuseUtils.Sequence.Start cannot run after Cleanup")
			assert(not v2.started, "AdminAbuseUtils.Sequence.Start can only be called once")
			assertElapsedTime(value) -- equivalent call inferred; original call site unknown
			v2.started = true
			table.sort(v2.entries, function(a, b)
				if a.time == b.time then
					return a.sourceIndex < b.sourceIndex
				end

				return a.time < b.time
			end)
			runDueEntries(v2, value, true)
		end,
		Run = function(value: number)
			assert(not v2.cleaned, "AdminAbuseUtils.Sequence.Run cannot run after Cleanup")
			assert(v2.started, "AdminAbuseUtils.Sequence.Run requires Start first")
			assertElapsedTime(value) -- equivalent call inferred; original call site unknown
			runDueEntries(v2, value, false)
		end,
		Cleanup = function()
			cleanupState(v2) -- equivalent call inferred; original call site unknown
		end
	}
end

function Sequencer.Cleanup()
	local v2 = {}

	for k in v do
		table.insert(v2, k)
	end

	for _, v3 in v2 do
		cleanupState(v3) -- equivalent call inferred; original call site unknown
	end
end

return Sequencer