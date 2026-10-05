require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)

function CompileFunc(p, thread, object, p3, p4, callback, callback2, flag: boolean?)
	local func, v = p3.func(thread, p.Instance)
	local v2 = {
		Instance = p.Instance,
		Thread = thread
	}

	if func == nil then
		callback(true)
	elseif p4 == nil or FayeUtility.tof(p4) == FayeUtility.numbertxt then
		if v == nil then
			callback2(
				v2,
				(FayeUtility.tof(func) ~= FayeUtility.tabletxt or func.__type ~= nil or not func) and { func } or func,
				thread
			)
		else
			callback2(v2, {
				[func] = v
			}, thread)
		end
	else
		callback2(v2, {
			[p4] = func
		}, thread)
	end

	if p3.Params == nil then
		return
	end

	if flag and p3.Params.Lifetime then
		task.wait(p3.Params.Lifetime)
		callback(true)
	elseif FayeUtility.tof(p3.Params) == FayeUtility.numbertxt then
		object:Delay(p3.Params, callback, true)
	elseif p3.Params.Lifetime ~= nil then
		object:Delay(p3.Params.Lifetime, callback, true)
	end
end

return function(p, p2, p3, p4)
	local cleanThread = p.CleanThread or p.Thread

	if cleanThread == nil then
		return
	end

	local extended = cleanThread:Extend(true)
	local fn

	fn = function(_)
		if EqThread ~= nil then
			FayeUtility.RemoveFromThread(EqThread, fn)
		end

		FayeUtility.RemoveFromEntity(p, fn)

		if extended ~= nil then
			FayeUtility.CallDestroy(extended)
			extended = nil
		end
	end

	if FayeUtility.tof(p3.Params) == FayeUtility.tabletxt and p3.Params.YieldSafe then
		cleanThread:Spawn(CompileFunc, p, extended, cleanThread, p3, p2, fn, p4, true)
	else
		CompileFunc(p, extended, cleanThread, p3, p2, fn, p4)
	end

	FayeUtility.AddToEntity(p, fn)

	if cleanThread ~= nil then
		EqThread = cleanThread

		if EqThread._isCleanAncestor then
			local eqThread = EqThread

			while eqThread ~= nil and not eqThread._hc do
				eqThread = eqThread.ParentThread
			end

			EqThread = eqThread or EqThread
		end

		FayeUtility.AddToThread(EqThread, fn)
	end
end