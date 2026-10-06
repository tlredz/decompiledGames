local RunService = game:GetService("RunService")
local v = {}
local Scheduler = {}
local total = 0

function CollectGarbage() end

function SafeExecute(callback, ...)
	if not callback then
		return
	end

	local v2 = table.pack(...)
	local success, result = pcall(function()
		coroutine.wrap(callback)(table.unpack(v2))
	end)

	if not success then
		warn(result)
	end

	return success
end

function ExecuteTasks()
	RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.016666666666666666 then
			return
		end

		local v2 = total
		total = 0

		if #v <= 0 then
			return
		end

		debug.profilebegin("Scheduler")

		for i = #v, 1, -1 do
			local v3 = v[i]

			if v3._Pause then
				continue
			end

			if v3._Cancelled then
				table.remove(v, i)
			else
				local _Type = v3._Type
				local _Interval = v3._Interval or 0
				v3._CurrentInterval = (v3._CurrentInterval or 0) + v2

				if _Type == "Default" then
					v3._Elapsed = math.min(v3._Elapsed + v2 / v3._Duration, 1)

					if not (_Interval > 0 and v3._CurrentInterval < _Interval) then
						local _CurrentInterval

						if _Interval > 0 then
							_CurrentInterval = v3._CurrentInterval or v2
						else
							_CurrentInterval = v2
						end

						v3._CurrentInterval = 0
						local v4 = SafeExecute(v3._Callback, v3._Elapsed, _CurrentInterval)

						if v3._Elapsed >= 1 or not v4 then
							v3._Finished = true

							if v3._CompletedCallback and v3._Elapsed >= 1 then
								SafeExecute(v3._CompletedCallback)
							end

							if v3.Release then
								v3:Release()
							end

							table.remove(v, i)
						end
					end
				elseif _Type == "Repeat" then
					v3._Elapsed += v2

					if v3._Performance and _Interval > 0 then
						local v4 = math.floor(v3._Elapsed / _Interval)

						if (not (v3._Elapsed < _Interval) or v3._Immediate) and (not (v4 < 1) or v3._Immediate) then
							if v3._Immediate then
								v3._Immediate = nil
								v4 = math.max(v4, 1)
							else
								v3._Elapsed -= _Interval * v4
							end

							local v5 = SafeExecute(v3._Callback, v3._Index)

							if v5 and (v3._Step > 0 and v3._Index < v3._FinishIndex or v3._Step < 0 and v3._Index > v3._FinishIndex) then
								local v6 = v3._Step > 0 and math.min(v3._Index + v3._Step * v4, v3._FinishIndex)

								if not v6 then
									if v3._Step < 0 then
										v6 = math.max(v3._Index + v3._Step * v4, v3._FinishIndex)
									else
										v6 = false
									end
								end

								v3._Index = v6
							else
								v3._Finished = true

								if v3._CompletedCallback and v5 then
									SafeExecute(v3._CompletedCallback)
								end

								if v3.Release then
									v3:Release()
								end

								table.remove(v, i)
								break
							end
						end
					else
						while _Interval <= v3._Elapsed or v3._Immediate do
							if v3._Immediate then
								v3._Immediate = nil
							else
								v3._Elapsed -= _Interval
							end

							local v4 = SafeExecute(v3._Callback, v3._Index)

							if v4 and (v3._Step > 0 and v3._Index < v3._FinishIndex or v3._Step < 0 and v3._Index > v3._FinishIndex) then
								local v5 = v3._Step > 0 and math.min(v3._Index + v3._Step, v3._FinishIndex)

								if not v5 then
									if v3._Step < 0 then
										v5 = math.max(v3._Index + v3._Step, v3._FinishIndex)
									else
										v5 = false
									end
								end

								v3._Index = v5
							else
								v3._Finished = true

								if v3._CompletedCallback and v4 then
									SafeExecute(v3._CompletedCallback)
								end

								if v3.Release then
									v3:Release()
								end

								table.remove(v, i)
								break
							end
						end
					end
				end
			end
		end

		debug.profileend()
	end)
end

function RegisterTask(p)
	if table.find(v, p) then
		return
	end

	table.insert(v, p)
end

function Scheduler.new(duration: number)
	local v2 = {
		_CurrentInterval = 0,
		_Duration = duration,
		_Elapsed = 0,
		_Pause = nil,
		_Finished = nil,
		_Type = "Default"
	}

	function v2:Wait(value: number)
		v2._Interval = math.max(value or 0, 0.016666666666666666)
		return self
	end

	function v2.OnCompleted(p2, completedCallback)
		if completedCallback then
			v2._CompletedCallback = completedCallback
		end

		return p2
	end

	function v2.OnStep(p2, callback)
		if callback then
			v2._Callback = callback
		end

		return p2
	end

	function v2.Ignore(p2)
		v2._Ignore = true
		return p2
	end

	function v2.Pause(p2)
		v2._Pause = true
		return p2
	end

	function v2.Continue(p2)
		v2._Pause = nil
		return p2
	end

	function v2:Destroy()
		if v2._Cancelled then
			return
		end

		v2._Cancelled = true

		if self.Release then
			self:Release()
		end

		return self
	end

	function v2:Hold()
		if v2._Hold or v2._Finished then
			return self
		end

		v2._Hold = Instance.new("BindableEvent")
		v2._Hold.Event:Wait()
		return self
	end

	function v2:Release()
		if not v2._Hold then
			return self
		end

		v2._Hold:Fire()
		v2._Hold:Destroy()
		v2._Hold = nil
	end

	function v2.Performance(p2)
		v2._Performance = true
		return p2
	end

	function v2:Execute()
		RegisterTask(v2)

		if not self._Ignore then
			self:Hold()
		end

		return self
	end

	return v2
end

function Scheduler.Repeat(p: number, finishIndex: number, value: number)
	local v2 = Scheduler.new()
	v2._Type = "Repeat"
	v2._Step = value or 1
	v2._Index = p
	v2._FinishIndex = finishIndex

	function v2.Instant(p2)
		v2._Immediate = true
		return p2
	end

	return v2
end

ExecuteTasks()
return Scheduler