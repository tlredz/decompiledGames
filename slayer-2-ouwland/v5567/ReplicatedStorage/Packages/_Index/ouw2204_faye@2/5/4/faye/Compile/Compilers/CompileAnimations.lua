local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
local Player = require(script.Player)
local Clean = require(script.Parent.Parent.Parent.Clean)
local TweenService = game:GetService("TweenService")
local Lerps = require(script.Lerps)
local AnimatorStorage = require(script.Player.AnimatorStorage)
return function(initials, property: string, state)
	local cleanThread = initials.CleanThread or initials.Thread
	local tof = FayeUtility.tof(initials.Instance[property])

	if state.Loaded == true then
		local flag

		if state.Workers == nil then
			state.Workers = {
				Count = 0
			}
			flag = true
		end

		if state.IsPlaying == true then
			local v = AnimatorStorage.Holder ~= nil and AnimatorStorage.Holder[state.__animId]

			if not v then
				if AnimatorStorage.RegularTweenHolder == nil then
					v = false
				else
					v = AnimatorStorage.RegularTweenHolder[state.__animId]
				end
			end

			if v ~= nil then
				if v.Main == nil then
					if state.Initial ~= nil then
						initials[property] = state.Initial
					end

					local initial = state.Initial or initials.Instance[property]
					state.Workers[state.Workers.Count + 1] = {
						Entity = initials.Instance,
						Property = property,
						PropertyType = tof,
						Default = initial,
						Lerp = Lerps[tof](initial, v.To)
					}

					if flag then
						v.Others = state.Workers
					end
				else
					if flag then
						v.Others = {
							Count = 0
						}
					end

					if v.Initial ~= nil then
						initials.Instance[property] = v.Initial
					end

					v.Others[v.Others.Count + 1] = {
						Main = TweenService:Create(initials.Instance, v.Info, {
							[property] = v.To
						}),
						Property = property
					}
					v.Others[v.Others.Count + 1].Main:Play()
					v.Others.Count += 1
					state.Workers[state.Workers.Count + 1] = {
						Entity = initials.Instance,
						Property = property,
						PropertyType = tof
					}
				end
			end
		else
			if state.StartingSet ~= nil then
				initials.Instance[property] = state.StartingSet
			end

			state.Workers[state.Workers.Count + 1] = {
				Entity = initials.Instance,
				Property = property,
				PropertyType = tof
			}
		end

		state.Workers.Count += 1
	else
		state.Loaded = true
		local v = nil
		local v2 = nil
		local v3 = nil
		local mainInfoFunc

		mainInfoFunc = function(object, value: number, p2)
			if object == nil then
				return
			end

			if FayeUtility.tof(object) ~= FayeUtility.tabletxt then
				warn((`Info to set is not a table - {debug.traceback()}`))
				return
			end

			local v4 = value or 1

			if object.__type == nil or not ValueClasses[object.__type] then
				v = object
			else
				v2 = v4

				if v3 == nil then
					v3 = {}
				end

				v3[v4] = object.Changed:Connect(function(p3)
					if v4 < v2 then
						for i = v2, v4 + 1, -1 do
							v3[i]:Disconnect()
							v3[i] = nil
						end
					end

					v2 = v4
					mainInfoFunc(p3, v4 + 1)
				end, v3)
				mainInfoFunc(object:Get(), v4 + 1, p2)
			end
		end

		if state.__onetimeinfo == nil then
			mainInfoFunc(state.Info, nil, true)
		end

		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil
		local tof2 = FayeUtility.tof(state.Goal)
		local v8

		if tof2 == FayeUtility.instanceTxt then
			v8 = state.Goal:IsA(FayeUtility.valueBaseTxt)
		else
			v8 = false
		end

		local v9

		if v8 then
			v9 = v8
		elseif tof2 == FayeUtility.tabletxt and state.Goal.__type ~= nil then
			v9 = ValueClasses[state.Goal.__type]
		else
			v9 = false
		end

		local v10 = nil
		local v11 = nil
		local __animId = state.__animId
		local parentChangedConnection = nil
		local fn

		fn = function(_: boolean, flag: boolean)
			if state ~= nil then
				state.IsPlaying = nil
			end

			if flag == nil then
				if parentChangedConnection ~= nil then
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end

				if cleanThread ~= nil then
					FayeUtility.RemoveFromThread(cleanThread, fn)
				end

				FayeUtility.RemoveFromEntity(initials, fn)

				if v10 ~= nil and v10 > 0 then
					FayeUtility.ClearAllConnections(v11, v10)
				end

				if v2 ~= nil and v2 > 0 then
					FayeUtility.ClearAllConnections(v3, v2)
				end

				if state ~= nil then
					if state.Workers ~= nil then
						FayeUtility.tc(state.Workers)
						state.Workers.Count = nil
						state.Workers = nil
					end

					if state.Loaded ~= nil then
						state.Loaded = nil
					end

					if state.StartingSet ~= nil then
						state.StartingSet = nil
					end

					state = nil
				end
			end

			local v12 = Player.Remove(__animId, true)

			if cleanThread ~= nil then
				if cleanThread.AnimationsAmount ~= nil and v12 then
					cleanThread.AnimationsAmount = FayeUtility.max(cleanThread.AnimationsAmount - 1, 0)
				end

				if cleanThread.CleanWhenDone and cleanThread.AnimationsAmount ~= nil and cleanThread.AnimationsAmount <= 0 then
					cleanThread.AnimationsAmount = nil
					cleanThread.CleanWhenDone = nil

					if cleanThread ~= nil then
						FayeUtility.RemoveFromThread(cleanThread, fn)
					end

					FayeUtility.RemoveFromEntity(initials, fn)

					if state ~= nil then
						state.Loaded = nil
						state.StartingSet = nil
					end

					state = nil
					Clean(cleanThread)
					cleanThread = nil
				end
			end
		end

		local mainGoalFunc

		mainGoalFunc = function(startingSet, value: number?, flag: boolean?)
			if startingSet == nil then
				return
			end

			local v12 = value or 1
			local typeName = typeof(startingSet)
			local v13 = typeName == FayeUtility.tabletxt
			local v14 = not v13

			if v14 then
				if typeName == FayeUtility.instanceTxt then
					v14 = startingSet:IsA(FayeUtility.valueBaseTxt)
				else
					v14 = false
				end
			end

			if v13 or v14 then
				if v14 or startingSet.__type ~= nil and ValueClasses[startingSet.__type] then
					if v11 == nil then
						v11 = {}
					end

					v10 = v12
					v11[v12] = startingSet.Changed:Connect(function(p2)
						if v12 < v10 then
							for i = v10, v12 + 1, -1 do
								v11[i]:Disconnect()
								v11[i] = nil
							end
						end

						v10 = v12
						mainGoalFunc(p2, v12 + 1)
					end, v11)
					mainGoalFunc(v14 and startingSet.Value or startingSet:Get(), v12 + 1, flag)
				end
			elseif initials ~= nil and initials.Instance ~= nil then
				if flag and state.From == nil and state.AlwaysFrom == nil and state.FirstGoal == nil then
					initials.Instance[property] = startingSet
					state.StartingSet = startingSet
				else
					if state.FirstGoal and not v6 then
						startingSet = FayeUtility.GetValue(state.FirstGoal)
						v6 = true
					end

					if initials[property] ~= startingSet then
						if cleanThread ~= nil then
							cleanThread.AnimationsAmount = (cleanThread.AnimationsAmount or 0) + 1
						end

						local v15 = nil

						if state.From == nil or v4 then
							if state.AlwaysFrom then
								v15 = FayeUtility.GetValue(state.AlwaysFrom)
							end
						else
							v15 = FayeUtility.GetValue(state.From)
							v4 = true
						end

						fn(true, true)
						state.IsPlaying = true
						local clone = nil
						local firstDelayTime

						if not (state.FirstDelayTime == nil or v7) then
							v7 = true
							firstDelayTime = state.FirstDelayTime
						end

						if state.FirstInfo == nil or v5 then
							if firstDelayTime ~= nil then
								clone = table.clone(v)
								clone.DelayTime = firstDelayTime
							end
						else
							v5 = true
							clone = {
								Time = state.FirstInfo.Time or v.Time,
								RepeatCount = state.FirstInfo.RepeatCount or v.RepeatCount,
								Reverse = state.FirstInfo.Reverse or v.Reverse,
								DelayTime = firstDelayTime or state.FirstInfo ~= nil and state.FirstInfo.DelayTime or v.DelayTime
							}

							if state.FirstInfo.EasingStyle == nil and state.FirstInfo.EasingDirection == nil then
								if state.FirstInfo.Frequency == nil and state.FirstInfo.Damping == nil then
									clone.EasingStyle = v.EasingStyle
									clone.EasingDirection = v.EasingDirection
									clone.Frequency = v.Frequency
									clone.Damping = v.Damping
								else
									clone.Frequency = state.FirstInfo.Frequency or v.Frequency
									clone.Damping = state.FirstInfo.Damping or v.Damping
								end
							else
								clone.EasingStyle = state.FirstInfo.EasingStyle or v.EasingStyle
								clone.EasingDirection = state.FirstInfo.EasingDirection or v.EasingDirection
							end
						end

						Player.Add(
							state.__animId,
							startingSet,
							clone or v,
							fn,
							initials.Instance,
							property,
							state.Workers,
							v9,
							tof,
							v15
						)
					end
				end
			end
		end

		mainGoalFunc(state.Goal, nil, v9)

		if v8 then
			parentChangedConnection = state.Goal:GetPropertyChangedSignal("Parent"):Connect(function()
				if state == nil or state.Parent == nil then
					fn()
				end
			end)
		end

		FayeUtility.AddToEntity(initials, fn)

		if cleanThread ~= nil then
			FayeUtility.AddToThread(cleanThread, fn)
		end
	end
end