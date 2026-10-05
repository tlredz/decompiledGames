local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
return {
	new = function(callback, p: number?)
		local class = {}
		local v = {}
		class.ScopeUpdated = Signal.new()

		local function cleanScope(p2)
			if p2 == nil then
				return "_NIL_SCOPE_"
			end

			return p2
		end

		function class.GetValue(_, p2, flag: boolean?, callback2, p3: number?)
			if not (callback or callback2) then
				error("PromiseCache:GetValue() - No `updateValue` function was passed in the constructor, and missing `scopeUpdateValue` function!")
			end

			local v2 = p3 or p

			if not v2 then
				error("PromiseCache:GetValue() - No `cacheSeconds` value was passed in the constructor, and missing `scopeCacheSeconds` value!")
			end

			local v3 = p2 == nil and "_NIL_SCOPE_" or p2
			local v4 = v[v3]
			local v5

			if v4 then
				if v2 == -1 or v4.UpdatedAtTick + v2 > tick() then
					v5 = not flag
				else
					v5 = false
				end
			else
				v5 = v4
			end

			if v5 then
				v4.LastAccessedAtTick = tick()
				return v4.Promise, nil, true
			end

			local promise = v4 and v4.Promise
			local promise2 = Promise.new(function(callback3, callback4, _)
				local success, result = pcall(function()
					if callback2 then
						return { callback2(promise) }
					end

					return { callback(v3, promise) }
				end)

				if success then
					callback3(table.unpack(result))
				elseif promise then
					callback3(promise:expect())
				else
					callback4((tostring(result)))
				end
			end)
			v[v3] = {
				UpdatedAtTick = tick(),
				Promise = promise2,
				LastAccessedAtTick = tick()
			}

			if v[v3].clearPromise then
				v[v3].clearPromise:Cancel()
				v[v3].clearPromise = nil
			end

			if p and p > 0 then
				v[v3].clearPromise = Promise.new(function(callback3, _, _)
					wait(p)
					callback3()
				end):andThen(function()
					class:RemoveScope(v3)
				end)
			end

			class.ScopeUpdated:Fire(v3, promise2, promise)
			return promise2, promise, nil
		end

		function class.GetCachedValue(_, p2)
			local v2 = v[p2 == nil and "_NIL_SCOPE_" or p2]

			if v2 then
				v2.LastAccessedAtTick = tick()
			end

			return v2 and v2.Promise or nil
		end

		function class.GetAllCachedValuesByScope(_)
			local promises = {}

			for k, v2 in pairs(v) do
				promises[k] = v2.Promise
			end

			return promises
		end

		function class.GetAllCacheDataByScope(_)
			return (table.clone(v))
		end

		function class.GetCachedAtTick(_, p2)
			local v2 = v[p2 == nil and "_NIL_SCOPE_" or p2]
			return v2 and v2.UpdatedAtTick or nil
		end

		function class.SetValue(_, p2, p3)
			local v2 = p2 == nil and "_NIL_SCOPE_" or p2
			local resolved = Promise.resolve(p3)
			local v3 = v[v2]
			local promise = v3 and v3.Promise
			v[v2] = {
				UpdatedAtTick = tick(),
				Promise = resolved,
				LastAccessedAtTick = tick()
			}
			class.ScopeUpdated:Fire(v2, resolved, promise)
			return resolved
		end

		function class:RemoveScope(p2)
			v[p2 == nil and "_NIL_SCOPE_" or p2] = nil
		end

		function class.ResetWholeCache(_)
			local clone = table.clone(v)

			for k, _ in pairs(clone) do
				class:RemoveScope(k)
			end
		end

		function class.SetCacheSeconds(_, p2: number)
			p = p2
		end

		return class
	end
}