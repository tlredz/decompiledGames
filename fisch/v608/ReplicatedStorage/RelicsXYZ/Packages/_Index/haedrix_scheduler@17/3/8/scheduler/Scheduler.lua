return function(p)
	local parent = script.Parent.Parent
	local ReactGlobals = require(parent.ReactGlobals)
	local Shared = require(parent.Shared)
	local describeError = Shared.describeError
	local reactFeatureFlags = Shared.ReactFeatureFlags
	local SchedulerFeatureFlags = require(script.Parent.SchedulerFeatureFlags)
	local enableSchedulerDebugging = SchedulerFeatureFlags.enableSchedulerDebugging
	local enableProfiling = SchedulerFeatureFlags.enableProfiling
	local v = p or require(script.Parent.SchedulerHostConfig)
	local requestHostCallback = v.requestHostCallback
	local requestHostTimeout = v.requestHostTimeout
	local cancelHostTimeout = v.cancelHostTimeout
	local shouldYieldToHost = v.shouldYieldToHost
	local getCurrentTime = v.getCurrentTime
	local forceFrameRate = v.forceFrameRate
	local requestPaint = v.requestPaint
	local setSchedulerFlags = v.setSchedulerFlags
	local getSchedulerFlags = v.getSchedulerFlags
	local NoYield = require(script.Parent.NoYield)
	local fn
	local fn2
	local fn3

	fn2 = function(p2, p3, p4: number)
		while true do
			local v2 = math.floor(p4 / 2)
			local v3 = p2[v2]

			if v3 == nil or not (fn(v3, p3) > 0) then
				break
			end

			p2[v2] = p3
			p2[p4] = v3
			p4 = v2
		end
	end

	fn3 = function(list, p2, p3: number)
		local v2 = #list

		while p3 < v2 do
			local v3 = p3 * 2
			local v4 = list[v3]
			local v5 = v3 + 1
			local v6 = list[v5]

			if v4 == nil or not (fn(v4, p2) < 0) then
				if v6 == nil or not (fn(v6, p2) < 0) then
					break
				end

				list[p3] = v6
				list[v5] = p2
				p3 = v5
			elseif v6 == nil or not (fn(v6, v4) < 0) then
				list[p3] = v4
				list[v3] = p2
				p3 = v3
			else
				list[p3] = v6
				list[v5] = p2
				p3 = v5
			end
		end
	end

	fn = function(p2, p3)
		local v2 = p2.sortIndex - p3.sortIndex

		if v2 == 0 then
			return p2.id - p3.id
		end

		return v2
	end

	local SchedulerPriorities = require(script.Parent.SchedulerPriorities)
	local immediatePriority = SchedulerPriorities.ImmediatePriority
	local userBlockingPriority = SchedulerPriorities.UserBlockingPriority
	local normalPriority = SchedulerPriorities.NormalPriority
	local lowPriority = SchedulerPriorities.LowPriority
	local idlePriority = SchedulerPriorities.IdlePriority
	local SchedulerProfiling = require(script.Parent.SchedulerProfiling)
	local markTaskRun = SchedulerProfiling.markTaskRun
	local markTaskYield = SchedulerProfiling.markTaskYield
	local markTaskCompleted = SchedulerProfiling.markTaskCompleted
	local markTaskCanceled = SchedulerProfiling.markTaskCanceled
	local markTaskErrored = SchedulerProfiling.markTaskErrored
	local markSchedulerSuspended = SchedulerProfiling.markSchedulerSuspended
	local markSchedulerUnsuspended = SchedulerProfiling.markSchedulerUnsuspended
	local markTaskStart = SchedulerProfiling.markTaskStart
	local stopLoggingProfilingEvents = SchedulerProfiling.stopLoggingProfilingEvents
	local startLoggingProfilingEvents = SchedulerProfiling.startLoggingProfilingEvents
	local v2 = {}
	local v3 = {}
	local id = 1
	local v5 = false
	local v6 = nil
	local priorityLevel = normalPriority
	local v7 = false
	local v8 = false
	local flag = false
	local fn4
	local fn5

	local function advanceTimers(p2)
		local v9 = v3[1]

		while v9 ~= nil do
			if v9.callback == nil then
				local v10 = v3
				local v11 = v10[1]

				if v11 ~= nil then
					local v12 = v10[#v10]
					v10[#v10] = nil

					if v12 ~= v11 then
						v10[1] = v12
						fn3(v10, v12, 1)
					end
				end
			else
				if not (v9.startTime <= p2) then
					break
				end

				local v10 = v3
				local v11 = v10[1]

				if v11 ~= nil then
					local v12 = v10[#v10]
					v10[#v10] = nil

					if v12 ~= v11 then
						v10[1] = v12
						fn3(v10, v12, 1)
					end
				end

				v9.sortIndex = v9.expirationTime
				local v12 = v2
				local v13 = #v12 + 1
				v12[v13] = v9
				fn2(v12, v9, v13)

				if enableProfiling then
					markTaskStart(v9, p2)
					v9.isQueued = true
				end
			end

			v9 = v3[1]
		end
	end

	local fn6

	fn6 = function(p2)
		flag = false
		advanceTimers(p2)

		if not v8 then
			if v2[1] == nil then
				local v9 = v3[1]

				if v9 ~= nil then
					requestHostTimeout(fn6, v9.startTime - p2)
				end
			else
				v8 = true
				requestHostCallback(fn4)
			end
		end
	end

	fn4 = function(p2, p3)
		if enableProfiling then
			markSchedulerUnsuspended(p3)
		end

		v8 = false

		if flag then
			flag = false
			cancelHostTimeout()
		end

		v7 = true
		local v9 = priorityLevel
		local v10, v11

		if ReactGlobals.__YOLO__ then
			v10 = fn5(p2, p3)
			v11 = true
		elseif enableProfiling then
			v11, v10 = xpcall(fn5, describeError, p2, p3)

			if not v11 and v6 ~= nil then
				local currentTime = getCurrentTime()
				markTaskErrored(v6, currentTime)
				v6.isQueued = false
			end
		else
			v10 = fn5(p2, p3)
			v11 = true
		end

		v6 = nil
		priorityLevel = v9
		v7 = false

		if enableProfiling then
			markSchedulerSuspended((getCurrentTime()))
		end

		if not v11 then
			error(v10)
		end

		return v10
	end

	fn5 = function(p2, p3)
		local catchYieldingInDEV = ReactGlobals.__DEV__ and reactFeatureFlags.catchYieldingInDEV
		advanceTimers(p3)
		v6 = v2[1]

		while v6 ~= nil and not (enableSchedulerDebugging and v5) and (not (p3 < v6.expirationTime) or p2 and not shouldYieldToHost()) do
			local callback = v6.callback

			if typeof(callback) == "function" then
				v6.callback = nil
				priorityLevel = v6.priorityLevel
				local v9 = v6.expirationTime <= p3
				markTaskRun(v6, p3)
				local callback2

				if catchYieldingInDEV then
					callback2 = NoYield(callback, v9)
				else
					callback2 = callback(v9)
				end

				p3 = getCurrentTime()

				if typeof(callback2) == "function" then
					v6.callback = callback2
					markTaskYield(v6, p3)
				else
					if enableProfiling then
						markTaskCompleted(v6, p3)
						v6.isQueued = false
					end

					if v6 == v2[1] then
						local v11 = v2
						local v12 = v11[1]

						if v12 ~= nil then
							local v13 = v11[#v11]
							v11[#v11] = nil

							if v13 ~= v12 then
								v11[1] = v13
								fn3(v11, v13, 1)
							end
						end
					end
				end

				advanceTimers(p3)
			else
				local v9 = v2
				local v10 = v9[1]

				if v10 ~= nil then
					local v11 = v9[#v9]
					v9[#v9] = nil

					if v11 ~= v10 then
						v9[1] = v11
						fn3(v9, v11, 1)
					end
				end
			end

			v6 = v2[1]
		end

		if v6 ~= nil then
			return true
		end

		local v9 = v3[1]

		if v9 ~= nil then
			requestHostTimeout(fn6, v9.startTime - p3)
		end

		return false
	end

	return {
		unstable_ImmediatePriority = immediatePriority,
		unstable_UserBlockingPriority = userBlockingPriority,
		unstable_NormalPriority = normalPriority,
		unstable_IdlePriority = idlePriority,
		unstable_LowPriority = lowPriority,
		unstable_runWithPriority = function(p2, callback)
			if p2 ~= immediatePriority and p2 ~= userBlockingPriority and p2 ~= normalPriority and p2 ~= lowPriority and p2 ~= idlePriority then
				p2 = normalPriority
			end

			local v9 = priorityLevel
			priorityLevel = p2
			local v10, v11

			if ReactGlobals.__YOLO__ then
				v10 = callback()
				v11 = true
			else
				v11, v10 = xpcall(callback, describeError)
			end

			priorityLevel = v9

			if not v11 then
				error(v10)
			end

			return v10
		end,
		unstable_next = function(callback)
			local v9

			if priorityLevel == immediatePriority or priorityLevel == userBlockingPriority or priorityLevel == normalPriority then
				v9 = normalPriority
			else
				v9 = priorityLevel
			end

			local v10 = priorityLevel
			priorityLevel = v9
			local v11, v12

			if ReactGlobals.__YOLO__ then
				v11 = callback()
				v12 = true
			else
				v12, v11 = xpcall(callback, describeError)
			end

			priorityLevel = v10

			if not v12 then
				error(v11)
			end

			return v11
		end,
		unstable_scheduleCallback = function(priorityLevel2, callback, p4)
			local currentTime = getCurrentTime()
			local v9

			if typeof(p4) == "table" then
				local delay = p4.delay

				if typeof(delay) == "number" and delay > 0 then
					v9 = currentTime + delay
				else
					v9 = currentTime
				end
			else
				v9 = currentTime
			end

			local v10 = v9 + (priorityLevel2 == immediatePriority and -1 or priorityLevel2 == userBlockingPriority and 250 or priorityLevel2 == idlePriority and 1073741823 or priorityLevel2 == lowPriority and 10000 or 5000)
			local v11 = {
				id = id,
				callback = callback,
				priorityLevel = priorityLevel2,
				startTime = v9,
				expirationTime = v10,
				sortIndex = -1
			}
			id += 1

			if enableProfiling then
				v11.isQueued = false
			end

			if currentTime < v9 then
				v11.sortIndex = v9
				local v12 = v3
				local v13 = #v12 + 1
				v12[v13] = v11
				fn2(v12, v11, v13)

				if #v2 == 0 and v11 == v3[1] then
					if flag then
						cancelHostTimeout()
					else
						flag = true
					end

					requestHostTimeout(fn6, v9 - currentTime)
					return v11
				end
			else
				v11.sortIndex = v10
				local v12 = v2
				local v13 = #v12 + 1
				v12[v13] = v11
				fn2(v12, v11, v13)

				if enableProfiling then
					markTaskStart(v11, currentTime)
					v11.isQueued = true
				end

				if not (v8 or v7) then
					v8 = true
					requestHostCallback(fn4)
				end
			end

			return v11
		end,
		unstable_cancelCallback = function(p2)
			if enableProfiling and p2.isQueued then
				markTaskCanceled(p2, (getCurrentTime()))
				p2.isQueued = false
			end

			p2.callback = nil
		end,
		unstable_wrapCallback = function(callback)
			local v9 = priorityLevel
			return function(...)
				local v10 = priorityLevel
				priorityLevel = v9
				local v11, v12

				if ReactGlobals.__YOLO__ then
					v11 = callback(...)
					v12 = true
				else
					v12, v11 = xpcall(callback, describeError, ...)
				end

				priorityLevel = v10

				if not v12 then
					error(v11)
				end

				return v11
			end
		end,
		unstable_getCurrentPriorityLevel = function()
			return priorityLevel
		end,
		unstable_shouldYield = shouldYieldToHost,
		unstable_requestPaint = requestPaint,
		unstable_continueExecution = function()
			v5 = false

			if not (v8 or v7) then
				v8 = true
				requestHostCallback(fn4)
			end
		end,
		unstable_pauseExecution = function()
			v5 = true
		end,
		unstable_getFirstCallbackNode = function()
			return v2[1]
		end,
		unstable_now = getCurrentTime,
		unstable_forceFrameRate = forceFrameRate,
		unstable_setSchedulerFlags = setSchedulerFlags,
		unstable_getSchedulerFlags = getSchedulerFlags,
		unstable_Profiling = enableProfiling and {
			startLoggingProfilingEvents = startLoggingProfilingEvents,
			stopLoggingProfilingEvents = stopLoggingProfilingEvents
		} or nil
	}
end