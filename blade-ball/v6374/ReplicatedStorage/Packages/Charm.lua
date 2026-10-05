local module = require("@self/system")
local link = module.link
local unlink = module.unlink
local propagate = module.propagate
local checkDirty = module.checkDirty
local shallowPropagate = module.shallowPropagate
local createReactiveSystem = module.createReactiveSystem
local count = 0
local v = {}
local count2 = 0
local count3 = 0
local v2 = 0
local v3 = nil

local function isO2()
	return debug.info(1, "n") ~= "isO2"
end

local flags2 = {
	strict = debug.info(1, "n") == "isO2",
	frozen = debug.info(1, "n") == "isO2",
	trackInnerEffects = true
}

local function wrapUserSpace(callback)
	if not (flags2.strict and debug.info(1, "s") ~= debug.info(callback, "s")) then
		return callback
	end

	local function fn(thread: thread, flag: boolean, ...)
		if flag then
			if coroutine.status(thread) == "dead" then
				return ...
			end

			error(debug.traceback(thread, "Attempted to yield in an effect or scope"), 0)
		else
			local v5 = ...

			if type(v5) == "string" then
				error(debug.traceback(thread, v5), 0)
			else
				error(tostring(v5), 0)
			end
		end
	end

	return function(...)
		local thread = coroutine.create(callback)
		return fn(thread, coroutine.resume(thread, ...))
	end
end

local deepFreeze

deepFreeze = function(list)
	if type(list) == "table" and not table.isfrozen(list) and getmetatable(list) == nil then
		table.freeze(list)

		for _, v5 in list do
			deepFreeze(v5)
		end
	end
end

local function getActiveSub()
	return v3
end

local function setActiveSub(p)
	local v5 = v3
	v3 = p
	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function purgeDeps(state)
	local depsTail = state.depsTail
	local nextDep

	if depsTail then
		nextDep = depsTail.nextDep
	else
		nextDep = state.deps
	end

	while nextDep do
		nextDep = unlink(nextDep, state)
	end
end

local function runCleanups(cleanups)
	local v5 = {}
	local flag = false

	for k, callback in cleanups do
		cleanups[k] = nil
		local v6 = v3
		v3 = nil
		local success, result = pcall(callback)
		v3 = v6

		if success then
			continue
		end

		table.insert(v5, (tostring(result)))
		flag = true
	end

	if flag then
		error(`Errors occurred during effect cleanup:\n\n{table.concat(v5, [[


]])}`, 0)
	end
end

local function run(state)
	local flags = state.flags

	if bit32.btest(flags, 16) or bit32.btest(flags, 32) and checkDirty(state.deps, state) then
		runCleanups(state.cleanups)

		if state.flags == 0 then
			return
		end

		count += 1
		state.depsTail = nil
		state.flags = 2
		local v5 = v3
		v3 = state
		local success, result = pcall(state.fn)
		v3 = v5
		purgeDeps(state) -- equivalent call inferred; original call site unknown

		if success and result then
			table.insert(state.cleanups, (wrapUserSpace(result)))
		elseif not success then
			error(result, 0)
		end

		if state.flags == 0 then
			runCleanups(state.cleanups)
		end
	else
		state.flags = 2
	end
end

local function flush()
	if v2 ~= 0 or count3 ~= 0 then
		return
	end

	local success, result = pcall(function()
		while count3 < count2 do
			count3 += 1
			local v5 = v[count3]
			v[count3] = nil
			run(v5)
		end
	end)

	while count3 < count2 do
		count3 += 1
		local v5 = v[count3]
		v[count3] = nil
		v5.flags = bit32.bor(v5.flags, 10)
	end

	count3 = 0
	count2 = 0

	if not success then
		error(result, 0)
	end
end

local function startBatch()
	v2 += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endBatch()
	v2 -= 1
	flush()
end

local function updateComputed(state)
	count += 1
	state.depsTail = nil
	state.flags = 5
	local v5 = v3
	v3 = state
	local value = state.value
	local success, result = pcall(state.getter, value)
	v3 = v5
	state.flags = bit32.band(state.flags, 4294967291)
	purgeDeps(state) -- equivalent call inferred; original call site unknown

	if success then
		state.value = result
		return value ~= result
	else
		error(result, 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSignal(state)
	state.flags = 1
	local pendingValue = state.pendingValue

	if state.currentValue == pendingValue then
		return false
	end

	state.currentValue = pendingValue
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect(state)
	state.depsTail = nil
	state.flags = 0
	purgeDeps(state) -- equivalent call inferred; original call site unknown
	local subs = state.subs

	if subs then
		unlink(subs, state)
	end

	runCleanups(state.cleanups)
end

local function update(state)
	if state.depsTail then
		return updateComputed(state)
	end

	state.flags = 1
	local pendingValue = state.pendingValue

	if state.currentValue == pendingValue then
		return false
	end

	state.currentValue = pendingValue
	return true
end

local function notify(sub)
	local v5 = count2 + 1

	repeat
		count2 += 1
		v[count2] = sub
		sub.flags = bit32.band(sub.flags, 4294967293)
		sub = sub.subs and sub.subs.sub
	until not sub or bit32.band(sub.flags, 2) == 0

	local v6 = count2

	while v5 < v6 do
		local v7 = v
		local v8 = v
		local v9 = v[v6]
		local v10 = v[v5]
		v7[v5] = v9
		v8[v6] = v10
		v5 += 1
		v6 -= 1
	end
end

local function unwatched(state)
	if bit32.band(state.flags, 1) == 0 then
		stopEffect(state) -- equivalent call inferred; original call site unknown
	elseif state.depsTail then
		state.depsTail = nil
		state.flags = 17
		purgeDeps(state) -- equivalent call inferred; original call site unknown
	end
end

local function signal(p, callback)
	local v5 = {
		currentValue = p,
		pendingValue = p,
		flags = 1
	}

	if flags2.frozen then
		deepFreeze(p)
	end

	local function signalGetter()
		if bit32.btest(v5.flags, 16) then
			local v7 = updateSignal(v5) -- equivalent call inferred; original call site unknown
			local subs = v7 and v5.subs

			if subs then
				shallowPropagate(subs)
			end
		end

		local sub = v3

		while sub do
			if bit32.btest(sub.flags, 3) then
				link(v5, sub, count)
				break
			end

			local subs = sub.subs

			if subs then
				sub = subs.sub
			else
				sub = nil
			end
		end

		return v5.currentValue
	end

	local function signalSetter(callback2)
		local pendingValue = nil

		if type(callback2) == "function" then
			local v7 = v3
			v3 = nil
			local success, result = pcall(wrapUserSpace(callback2), v5.pendingValue)
			v3 = v7

			if success then
				pendingValue = result
			else
				error(result, 2)
			end
		else
			pendingValue = callback2
		end

		local v7

		if callback then
			v7 = not callback(v5.pendingValue, pendingValue)
		else
			v7 = v5.pendingValue ~= pendingValue
		end

		if not v7 then
			return v5.pendingValue
		end

		if flags2.frozen then
			deepFreeze(pendingValue)
		end

		v5.pendingValue = pendingValue
		v5.flags = 17
		local subs = v5.subs

		if subs then
			propagate(subs)
			flush()
		end

		return v5.pendingValue
	end

	return signalGetter, signalSetter
end

local function computed(callback)
	local v5 = {
		flags = 0,
		getter = wrapUserSpace(callback)
	}

	local function computedOper()
		local flags = v5.flags

		if bit32.btest(flags, 16) then
			local subs = updateComputed(v5) and v5.subs

			if subs then
				shallowPropagate(subs)
			end
		elseif bit32.btest(flags, 32) then
			if checkDirty(v5.deps, v5) then
				local subs = updateComputed(v5) and v5.subs

				if subs then
					shallowPropagate(subs)
				end
			else
				v5.flags = bit32.band(flags, 4294967263)
			end
		elseif flags == 0 then
			v5.flags = 5
			local v6 = v3
			v3 = v5
			local success, result = pcall(v5.getter)
			v3 = v6
			v5.flags = bit32.band(v5.flags, 4294967291)

			if success then
				v5.value = result
			else
				error(result, 2)
			end
		end

		if v3 then
			link(v5, v3, count)
		end

		return v5.value
	end

	return computedOper
end

local function effect(fn)
	local v5 = {
		fn = wrapUserSpace(fn),
		flags = 2,
		cleanups = {}
	}

	if v3 and (flags2.trackInnerEffects or v3.flags == 0) then
		link(v5, v3, 0)
	end

	v2 += 1
	local v6 = v3
	v3 = v5
	local success, result = pcall(v5.fn)
	v3 = v6

	if success and result then
		table.insert(v5.cleanups, (wrapUserSpace(result)))
	elseif not success then
		endBatch() -- equivalent call inferred; original call site unknown
		error(result, 2)
	end

	endBatch() -- equivalent call inferred; original call site unknown
	return function()
		stopEffect(v5) -- equivalent call inferred; original call site unknown
	end
end

local function effectScope(fn, flag: boolean?)
	local v5 = {
		flags = 0,
		cleanups = {}
	}

	if v3 and not flag then
		link(v5, v3, 0)
	end

	local v6 = v3
	v3 = v5
	local success, result = pcall((wrapUserSpace(fn)))
	v3 = v6

	if success and result then
		table.insert(v5.cleanups, (wrapUserSpace(result)))
	elseif not success then
		error(result, 2)
	end

	return function()
		stopEffect(v5) -- equivalent call inferred; original call site unknown
	end
end

local function trigger(callback)
	local v5 = {
		flags = 2
	}
	local v6 = v3
	v3 = v5
	local success, result = pcall((wrapUserSpace(callback)))
	v3 = v6
	v5.flags = 0
	local deps = v5.deps

	while deps do
		local subs = deps.dep.subs
		deps = unlink(deps, v5)

		if not subs then
			continue
		end

		propagate(subs)
		shallowPropagate(subs)
	end

	flush()

	if not success then
		error(result, 2)
	end
end

local function onCleanup(callback, flag: boolean?)
	if v3 and v3.cleanups then
		table.insert(v3.cleanups, (wrapUserSpace(callback)))
	elseif not flag then
		warn(debug.traceback("onCleanup() can only be called inside an effect or a scope.", 2))
	end
end

local function untracked(callback, ...)
	if not v3 then
		return callback(...)
	end

	local v5 = v3
	v3 = nil
	local v6 = { pcall(wrapUserSpace(callback), ...) }
	v3 = v5

	if not v6[1] then
		error(v6[2], 2)
	end

	return unpack(v6, 2)
end

local function batch(callback, ...)
	v2 += 1
	local v5 = { pcall(wrapUserSpace(callback), ...) }
	endBatch() -- equivalent call inferred; original call site unknown

	if not v5[1] then
		error(v5[2], 2)
	end

	return unpack(v5, 2)
end

local function isSignal(callback)
	local v5 = debug.info(callback, "n")
	return v5 == "signalGetter" or v5 == "computedOper" or v5 == "atomOper"
end

local function listen(computedOper, callback)
	local v5 = debug.info(computedOper, "n")

	if v5 ~= "signalGetter" and v5 ~= "computedOper" and v5 ~= "atomOper" then
		local v6 = {
			flags = 0,
			getter = wrapUserSpace(computedOper)
		}

		computedOper = function()
			local flags = v6.flags

			if bit32.btest(flags, 16) then
				local subs = updateComputed(v6) and v6.subs

				if subs then
					shallowPropagate(subs)
				end
			elseif bit32.btest(flags, 32) then
				if checkDirty(v6.deps, v6) then
					local subs = updateComputed(v6) and v6.subs

					if subs then
						shallowPropagate(subs)
					end
				else
					v6.flags = bit32.band(flags, 4294967263)
				end
			elseif flags == 0 then
				v6.flags = 5
				local v7 = v3
				v3 = v6
				local success, result = pcall(v6.getter)
				v3 = v7
				v6.flags = bit32.band(v6.flags, 4294967291)

				if success then
					v6.value = result
				else
					error(result, 2)
				end
			end

			if v3 then
				link(v6, v3, count)
			end

			return v6.value
		end
	end

	local v6 = nil
	return (effect(function()
		local v7 = v6
		v6 = computedOper()
		untracked(callback, v6, v7)
	end))
end

local function subscribe(computedOper, callback)
	local v5 = debug.info(computedOper, "n")

	if v5 ~= "signalGetter" and v5 ~= "computedOper" and v5 ~= "atomOper" then
		local v6 = {
			flags = 0,
			getter = wrapUserSpace(computedOper)
		}

		computedOper = function()
			local flags = v6.flags

			if bit32.btest(flags, 16) then
				local subs = updateComputed(v6) and v6.subs

				if subs then
					shallowPropagate(subs)
				end
			elseif bit32.btest(flags, 32) then
				if checkDirty(v6.deps, v6) then
					local subs = updateComputed(v6) and v6.subs

					if subs then
						shallowPropagate(subs)
					end
				else
					v6.flags = bit32.band(flags, 4294967263)
				end
			elseif flags == 0 then
				v6.flags = 5
				local v7 = v3
				v3 = v6
				local success, result = pcall(v6.getter)
				v3 = v7
				v6.flags = bit32.band(v6.flags, 4294967291)

				if success then
					v6.value = result
				else
					error(result, 2)
				end
			end

			if v3 then
				link(v6, v3, count)
			end

			return v6.value
		end
	end

	local v6 = nil
	local flag = true
	return (effect(function()
		local v7 = v6
		v6 = computedOper()

		if flag then
			flag = false
		else
			untracked(callback, v6, v7)
		end
	end))
end

local function mapped(callback, callback2)
	local v5 = wrapUserSpace(callback)
	local v6 = wrapUserSpace(callback2)
	local v7 = {}
	local v8 = {}
	local v9 = {
		flags = 0,
		getter = wrapUserSpace(function(options)
			local clone = options or {}
			local v10 = v7
			v7 = v5()

			for k in v10 do
				if v7[k] ~= nil then
					continue
				end

				local v11 = v8[k]

				if v11 == nil then
					continue
				end

				if clone == options then
					clone = table.clone(clone)
				end

				clone[v11] = nil
				v8[k] = nil
			end

			for k, v11 in v7 do
				if v11 == v10[k] then
					continue
				end

				local v12, v13 = v6(v11, k)

				if v13 == nil then
					v13 = k
				end

				local v14 = v8[k]

				if v14 == nil or v14 == v13 then
					if clone[v13] ~= v12 then
						if clone == options then
							clone = table.clone(clone)
						end

						clone[v13] = v12
						v8[k] = v13
					end
				else
					if clone == options then
						clone = table.clone(clone)
					end

					clone[v14] = nil
					clone[v13] = v12
					v8[k] = v13
				end
			end

			return clone
		end)
	}

	local function computedOper()
		local flags = v9.flags

		if bit32.btest(flags, 16) then
			local subs = updateComputed(v9) and v9.subs

			if subs then
				shallowPropagate(subs)
			end
		elseif bit32.btest(flags, 32) then
			if checkDirty(v9.deps, v9) then
				local subs = updateComputed(v9) and v9.subs

				if subs then
					shallowPropagate(subs)
				end
			else
				v9.flags = bit32.band(flags, 4294967263)
			end
		elseif flags == 0 then
			v9.flags = 5
			local v10 = v3
			v3 = v9
			local success, result = pcall(v9.getter)
			v3 = v10
			v9.flags = bit32.band(v9.flags, 4294967291)

			if success then
				v9.value = result
			else
				error(result, 2)
			end
		end

		if v3 then
			link(v9, v3, count)
		end

		return v9.value
	end

	return computedOper
end

createReactiveSystem(update, notify, unwatched)
local Charm = {}
Charm.ReactiveFlags = module.ReactiveFlags
Charm.flags = flags2

function Charm.atom(p, callback)
	local v5, v6 = signal(p, callback)

	local function atomOper(...)
		if select("#", ...) == 0 then
			return (v5())
		end

		return (v6((...)))
	end

	return atomOper
end

Charm.signal = signal
Charm.computed = computed
Charm.effect = effect
Charm.effectScope = effectScope
Charm.trigger = trigger
Charm.untracked = untracked
Charm.batch = batch
Charm.subscribe = subscribe
Charm.listen = listen

function Charm.observe(callback, callback2)
	local v5 = wrapUserSpace(callback)
	local v6 = wrapUserSpace(callback2)
	local v7 = {}
	local flag = false

	local function updateScopes(items)
		for k, v8 in v7 do
			if items[k] ~= nil then
				continue
			end

			v7[k] = nil
			v8()

			if flag then
				return
			end
		end

		for k, item in items do
			if v7[k] ~= nil then
				continue
			end

			local v8 = item
			local v9 = k
			local v10 = effectScope(function()
				return v6(v8, v9)
			end, true)

			if flag then
				v10()
				break
			else
				v7[k] = v10
			end
		end
	end

	return (effectScope(function()
		effect(function()
			untracked(updateScopes, v5())
		end)
		return function()
			flag = true

			for k, v8 in v7 do
				v7[k] = nil
				v8()
			end
		end
	end))
end

Charm.mapped = mapped
Charm.onCleanup = onCleanup
Charm.getActiveSub = getActiveSub
Charm.setActiveSub = setActiveSub
Charm.startBatch = startBatch
Charm.endBatch = endBatch
return Charm