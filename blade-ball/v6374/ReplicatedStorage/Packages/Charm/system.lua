local frozen = table.freeze({
	None = 0,
	Mutable = 1,
	Watching = 2,
	RecursedCheck = 4,
	Recursed = 8,
	Dirty = 16,
	Pending = 32
})
local v = nil
local v2 = nil
local v3 = nil

local function isValidLink(p, p2)
	local depsTail = p2.depsTail

	while depsTail do
		if depsTail == p then
			return true
		else
			depsTail = depsTail.prevDep
		end
	end

	return false
end

local propagate

propagate = function(nextSub)
	repeat
		local sub = nextSub.sub
		local flags = sub.flags

		if bit32.band(flags, 60) == 0 then
			sub.flags = bit32.bor(flags, 32)
		elseif bit32.band(flags, 12) == 0 then
			flags = 0
		elseif bit32.band(flags, 4) == 0 then
			sub.flags = bit32.bor(bit32.band(flags, 4294967287), 32)
		elseif bit32.band(flags, 48) == 0 then
			local depsTail = sub.depsTail
			local flag

			while true do
				if not depsTail then
					flag = false
					break
				end

				if depsTail == nextSub then
					flag = true
					break
				else
					depsTail = depsTail.prevDep
				end
			end

			if flag then
				sub.flags = bit32.bor(flags, 40)
				flags = bit32.band(flags, 1)
			else
				flags = 0
			end
		else
			flags = 0
		end

		if bit32.band(flags, 6) == 2 then
			v2(sub)
		end

		local subs = bit32.btest(flags, 1) and sub.subs

		if subs then
			propagate(subs)
		end

		nextSub = nextSub.nextSub
	until not nextSub
end

local function shallowPropagate(nextSub)
	repeat
		local sub = nextSub.sub
		local flags = sub.flags

		if bit32.band(flags, 48) == 32 then
			sub.flags = bit32.bor(flags, 16)

			if bit32.band(flags, 6) == 2 then
				v2(sub)
			end
		end

		nextSub = nextSub.nextSub
	until not nextSub
end

local checkDirty

checkDirty = function(nextDep, dep)
	while true do
		local dep2 = nextDep.dep
		local flags = dep2.flags

		if bit32.btest(dep.flags, 16) then
			break
		end

		if bit32.band(flags, 17) == 17 then
			if v(dep2) then
				local subs = dep2.subs

				if subs.nextSub then
					shallowPropagate(subs)
				end

				return true
			end
		elseif bit32.band(flags, 33) == 33 then
			if checkDirty(dep2.deps, dep2) then
				if v(dep2) then
					local subs = dep2.subs

					if subs.nextSub then
						shallowPropagate(subs)
					end

					return true
				end
			else
				dep2.flags = bit32.band(flags, 4294967263)
			end
		end

		nextDep = nextDep.nextDep

		if not nextDep then
			return false
		end
	end

	return true
end

local System = {}
System.ReactiveFlags = frozen

function System.link(dep, state, version: number)
	local depsTail = state.depsTail

	if depsTail and depsTail.dep == dep then
		return
	end

	local nextDep

	if depsTail then
		nextDep = depsTail.nextDep
	else
		nextDep = state.deps
	end

	if nextDep and nextDep.dep == dep then
		nextDep.version = version
		state.depsTail = nextDep
	else
		local subsTail = dep.subsTail

		if subsTail and subsTail.version == version and subsTail.sub == state then
			return
		end

		local v4 = {
			version = version,
			dep = dep,
			sub = state,
			prevDep = depsTail,
			nextDep = nextDep,
			prevSub = subsTail
		}
		state.depsTail = v4
		dep.subsTail = v4

		if nextDep then
			nextDep.prevDep = v4
		end

		if depsTail then
			depsTail.nextDep = v4
		else
			state.deps = v4
		end

		if subsTail then
			subsTail.nextSub = v4
		else
			dep.subs = v4
		end
	end
end

function System.unlink(data, p)
	local v4 = p or data.sub
	local dep = data.dep
	local prevDep = data.prevDep
	local nextDep = data.nextDep
	local nextSub = data.nextSub
	local prevSub = data.prevSub

	if nextDep then
		nextDep.prevDep = prevDep
	else
		v4.depsTail = prevDep
	end

	if prevDep then
		prevDep.nextDep = nextDep
	else
		v4.deps = nextDep
	end

	if nextSub then
		nextSub.prevSub = prevSub
	else
		dep.subsTail = prevSub
	end

	if prevSub then
		prevSub.nextSub = nextSub
		return nextDep
	end

	dep.subs = nextSub

	if not nextSub then
		v3(dep)
	end

	return nextDep
end

System.propagate = propagate
System.checkDirty = checkDirty
System.shallowPropagate = shallowPropagate

function System.createReactiveSystem(callback, callback2, callback3)
	v = callback
	v2 = callback2
	v3 = callback3
end

return System