local frozen = table.freeze({
	Type = "Option",
	IsSome = false,
	IsNone = true,
	Value = nil
})
local flattenResult

flattenResult = function(value)
	if not value.IsOk then
		return value
	end

	if type(value.Value) == "table" and rawget(value.Value, "Type") == "Result" then
		return flattenResult(value.Value)
	end

	return value
end

local function some(p)
	return table.freeze({
		Type = "Option",
		IsSome = true,
		IsNone = false,
		Value = p
	})
end

function none()
	return frozen
end

local flattenOption

flattenOption = function(value)
	if not value.IsSome then
		return frozen
	end

	if type(value.Value) == "table" and rawget(value.Value, "Type") == "Option" then
		return flattenOption(value.Value)
	end

	return value
end

local function transposeResult(p)
	if not p.IsOk then
		return frozen
	end

	local value = p.Value
	return (table.freeze({
		Type = "Option",
		IsSome = true,
		IsNone = false,
		Value = value
	}))
end

local function transposeOption(p, p2)
	if not p.IsSome then
		return (table.freeze({
			Type = "Result",
			IsOk = false,
			IsErr = true,
			Value = p2
		}))
	end

	local value = p.Value
	return (table.freeze({
		Type = "Result",
		IsOk = true,
		IsErr = false,
		Value = value
	}))
end

local function doing(p)
	local frozen2 = none()
	local frozen3 = table.freeze({
		Type = "Result",
		IsOk = false,
		IsErr = true,
		Value = "Incomplete"
	})
	local fn = p.Fn
	task.spawn(function()
		fn(function(p2)
			if frozen3.IsErr and frozen3.Value == "Incomplete" then
				frozen3 = table.freeze({
					Type = "Result",
					IsOk = true,
					IsErr = false,
					Value = p2
				})
			end
		end, function()
			if frozen3.IsErr then
				return frozen3.Value == "Canceled"
			end

			return false
		end, function(...)
			local v = table.pack(...)
			frozen2 = table.freeze({
				Type = "Option",
				IsSome = true,
				IsNone = false,
				Value = function()
					return table.unpack(v)
				end
			})
		end)

		if frozen3.IsErr and frozen3.Value == "Incomplete" then
			frozen3 = table.freeze({
				Type = "Result",
				IsOk = false,
				IsErr = true,
				Value = "Canceled"
			})
		end
	end)
	return table.freeze({
		Type = "Future",
		IsToDo = false,
		IsDoing = true,
		IsCanceled = false,
		IsDone = false,
		_Cancel = function()
			frozen3 = table.freeze({
				Type = "Result",
				IsOk = false,
				IsErr = true,
				Value = "Canceled"
			})
		end,
		_GetProgress = function()
			return frozen2
		end,
		_GetValue = function()
			return frozen3
		end,
		Fn = fn
	})
end

local function done(p, value)
	return table.freeze({
		Type = "Future",
		IsToDo = false,
		IsDoing = false,
		IsCanceled = false,
		IsDone = true,
		Value = value,
		Fn = p.Fn
	})
end

local function cancel(p)
	return table.freeze({
		Type = "Future",
		IsToDo = false,
		IsDoing = false,
		IsCanceled = true,
		IsDone = false,
		Fn = p.Fn
	})
end

return {
	Result = {
		err = function(p)
			return table.freeze({
				Type = "Result",
				IsOk = false,
				IsErr = true,
				Value = p
			})
		end,
		ok = function(p)
			return table.freeze({
				Type = "Result",
				IsOk = true,
				IsErr = false,
				Value = p
			})
		end,
		transpose = transposeResult,
		flatten = flattenResult
	},
	Option = {
		none = none,
		some = some,
		transpose = transposeOption,
		flatten = flattenOption
	},
	Future = {
		toDo = function(fn)
			return table.freeze({
				Type = "Future",
				IsToDo = true,
				IsDoing = false,
				IsCanceled = false,
				IsDone = false,
				Fn = fn
			})
		end,
		await = function(frozen2)
			if not frozen2.IsDoing then
				frozen2 = doing(frozen2)
			end

			local _GetValue = frozen2._GetValue()

			if _GetValue.IsOk then
				local value = _GetValue.Value
				frozen2 = table.freeze({
					Type = "Future",
					IsToDo = false,
					IsDoing = false,
					IsCanceled = false,
					IsDone = true,
					Value = value,
					Fn = frozen2.Fn
				})
			elseif _GetValue.Value == "Canceled" then
				frozen2 = table.freeze({
					Type = "Future",
					IsToDo = false,
					IsDoing = false,
					IsCanceled = true,
					IsDone = false,
					Fn = frozen2.Fn
				})
			end

			while frozen2.IsDoing do
				task.wait()

				if not frozen2.IsDoing then
					frozen2 = doing(frozen2)
				end

				local _GetValue2 = frozen2._GetValue()

				if _GetValue2.IsOk then
					local value = _GetValue2.Value
					frozen2 = table.freeze({
						Type = "Future",
						IsToDo = false,
						IsDoing = false,
						IsCanceled = false,
						IsDone = true,
						Value = value,
						Fn = frozen2.Fn
					})
				elseif _GetValue2.Value == "Canceled" then
					frozen2 = table.freeze({
						Type = "Future",
						IsToDo = false,
						IsDoing = false,
						IsCanceled = true,
						IsDone = false,
						Fn = frozen2.Fn
					})
				end
			end

			assert(frozen2.IsDoing == false, "expected IsDoing to be false, received true")
			return frozen2
		end,
		cancel = cancel,
		poll = function(p)
			if not p.IsDoing then
				p = doing(p)
			end

			local _GetValue = p._GetValue()

			if _GetValue.IsOk then
				return done(p, _GetValue.Value)
			end

			if _GetValue.Value == "Canceled" then
				return cancel(p)
			end

			return p
		end,
		progress = function(p)
			local _GetProgress = p._GetProgress()

			if _GetProgress.IsSome then
				return some(_GetProgress.Value())
			end

			return none()
		end
	}
}