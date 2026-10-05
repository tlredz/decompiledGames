local LerpPlayer = require(script.LerpPlayer)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
require(script.Parent.Parent.Parent.FayeTypes)
return function(data, property, state)
	if state.Loaded then
		if state.Workers == nil then
			state.Workers = {
				Count = 0
			}
			local _, v = LerpPlayer.Find(state.__lerpid)

			if v then
				v.Workers = state.Workers
			end
		end

		if state.From ~= nil then
			data.Instance[property] = state.From
		end

		state.Workers.Count += 1
		state.Workers[state.Workers.Count] = {
			Entity = data.Instance,
			Property = property
		}
	else
		state.Loaded = true
		local cleanThread = data.CleanThread or data.Thread
		local __lerpid = state.__lerpid
		local v = nil
		local v2 = nil
		local tof = FayeUtility.tof(state.To)
		local v3

		if tof == FayeUtility.instanceTxt then
			v3 = state.To:IsA(FayeUtility.valueBaseTxt)
		else
			v3 = false
		end

		if not v3 then
			if tof == FayeUtility.tabletxt and state.To.__type ~= nil then
				v3 = ValueClasses[state.To.__type]
			else
				v3 = false
			end
		end

		local v4 = v3
		local fn

		fn = function(p2)
			LerpPlayer.Remove(__lerpid)

			if not p2 then
				if cleanThread ~= nil then
					FayeUtility.RemoveFromThread(cleanThread, fn)
				end

				if v ~= nil and v > 0 then
					FayeUtility.ClearAllConnections(v2, v)
				end

				state.Loaded = nil
				state.Workers = nil
				FayeUtility.RemoveFromEntity(data, fn)
			end
		end

		local mainGoalFunc

		mainGoalFunc = function(instance, value: number?)
			if instance == nil then
				return
			end

			local v5 = value or 1
			local typeName = typeof(instance)
			local v6 = typeName == FayeUtility.tabletxt
			local v7 = not v6

			if v7 then
				if typeName == FayeUtility.instanceTxt then
					v7 = instance:IsA(FayeUtility.valueBaseTxt)
				else
					v7 = false
				end
			end

			if v6 or v7 then
				if v7 or instance.__type ~= nil and ValueClasses[instance.__type] then
					if v2 == nil then
						v2 = {}
					end

					v = v5
					v2[v5] = instance.Changed:Connect(function(p2)
						if v5 < v then
							for i = v, v5 + 1, -1 do
								v2[i]:Disconnect()
								v2[i] = nil
							end
						end

						v = v5
						mainGoalFunc(p2, v5 + 1)
					end, v2)
					mainGoalFunc(v7 and instance.Value or instance:Get(), v5 + 1)
				end
			elseif data ~= nil and data.Instance ~= nil then
				if v4 then
					data.Instance[property] = instance
					v4 = false
				else
					if v3 and state.From ~= nil and not state.AppliedFrom then
						data.Instance[property] = state.From
						state.From = nil
						state.AppliedFrom = true
					end

					LerpPlayer.Add(__lerpid, data.Instance, property, instance, state.Factor, v3, fn, state.Workers)
				end
			end
		end

		mainGoalFunc(state.To)
		FayeUtility.AddToEntity(data, fn)

		if cleanThread ~= nil then
			FayeUtility.AddToThread(cleanThread, fn)
		end
	end
end