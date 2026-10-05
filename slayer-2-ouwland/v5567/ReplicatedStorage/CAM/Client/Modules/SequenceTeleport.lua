local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local WipeTransition = require(ReplicatedStorage.CAM.Client.Components.Misc.Transitions.WipeTransition)
local localPlayer = Players.LocalPlayer
local SequenceTeleport = {}
local v = nil

function SequenceTeleport.GroundSnap(cframe: CFrame)
	local v2 = cframe.Position + createVector(0, 10, 0)
	local raycastResult = workspace:Raycast(v2, createVector(0, -35, 0), RaycastHelper.Ground)

	if raycastResult == nil or raycastResult.Instance == nil then
		return cframe, false
	end

	return CFrame.new(raycastResult.Position + createVector(0, 3.15, 0)) * cframe.Rotation, true
end

function SequenceTeleport.IsActive()
	return v ~= nil
end

function SequenceTeleport.Cancel()
	local v2 = v

	if v2 == nil then
		return
	end

	v = nil

	if v2.Thread ~= nil then
		pcall(task.cancel, v2.Thread)
		v2.Thread = nil
	end

	for _, v3 in { v2.Ring, v2.Fall, v2.Rise } do
		if v3 ~= nil then
			v3:Stop()
		end
	end

	if v2.Transition ~= nil then
		v2.Transition.Switch = true
		v2.Transition = nil
	end

	v2.PendingDestination = nil

	if v2.Lock ~= nil then
		v2.Lock:Destroy()
		v2.Lock = nil
	end
end

function SequenceTeleport.Start(data)
	SequenceTeleport.Cancel()
	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or nil
	end

	local humanoid

	if character == nil then
		humanoid = nil
	else
		humanoid = character:FindFirstChildOfClass("Humanoid") or nil
	end

	if humanoidRootPart == nil or humanoid == nil then
		return nil
	end

	local ringLength = data.RingLength or 0
	local fallLead = data.FallLead or 0
	local fallDelay = data.FallDelay or 0
	local coverDelay = data.CoverDelay or 0
	local uncoverLead = data.UncoverLead or 0
	local groundSnap = SequenceTeleport.GroundSnap(humanoidRootPart.CFrame)
	character:PivotTo(groundSnap)
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadTrack(animation)
		if animation == nil then
			return nil
		end

		return humanoid.Animator:LoadAnimation(animation)
	end

	v2.Lock = Utility.lock(
		humanoidRootPart,
		groundSnap,
		nil,
		data.LockName or `{localPlayer.Name}_SequenceTeleportLock`
	)
	local ring = loadTrack(data.Ring) -- equivalent call inferred; original call site unknown
	v2.Ring = ring
	local fall = loadTrack(data.Fall) -- equivalent call inferred; original call site unknown
	v2.Fall = fall
	local rise = loadTrack(data.Rise) -- equivalent call inferred; original call site unknown
	v2.Rise = rise
	v2.CutPassed = false
	v = v2

	local function setDestination(pendingDestination: CFrame)
		if v ~= v2 or v2.CutPassed then
			return false
		end

		v2.PendingDestination = pendingDestination
		task.spawn(function()
			pcall(function()
				localPlayer:RequestStreamAroundAsync(pendingDestination.Position, 1)
			end)
		end)
		return true
	end

	if data.Destination ~= nil then
		local destination = data.Destination

		if v == v2 and not v2.CutPassed then
			v2.PendingDestination = destination
			task.spawn(function()
				pcall(function()
					localPlayer:RequestStreamAroundAsync(destination.Position, 1)
				end)
			end)
		end
	end

	v2.Thread = task.spawn(function()
		local v6, v7, v8, v9, v10, v11, lastTime, v12, v13, v14, v15, pendingDestination, v16, v17, v18, v19, v20, v21, v22, v23, v24
		local controlFlowState = 57

		while true do
			if controlFlowState == 0 then
				controlFlowState = 18
				continue
			end

			if controlFlowState == 1 then
				v2.Ring:Play()
				controlFlowState = 2
				continue
			elseif controlFlowState == 2 then
				v12 = v6 - (os.clock() - lastTime)

				if v12 > 0 then
					controlFlowState = 3
				else
					controlFlowState = 4
				end

				continue
			elseif controlFlowState == 3 then
				task.wait(v12)
				controlFlowState = 4
				continue
			elseif controlFlowState == 4 then
				if v2.Fall == nil then
					controlFlowState = 6
				else
					controlFlowState = 5
				end

				continue
			elseif controlFlowState == 5 then
				v2.Fall:Play()
				controlFlowState = 6
				continue
			elseif controlFlowState == 6 then
				v13 = v7 - (os.clock() - lastTime)

				if v13 > 0 then
					controlFlowState = 7
				else
					controlFlowState = 8
				end

				continue
			elseif controlFlowState == 7 then
				task.wait(v13)
				controlFlowState = 8
				continue
			elseif controlFlowState == 8 then
				v2.Transition = {
					Switch = false
				}
				WipeTransition(v2.Transition)
				v14 = v8 - (os.clock() - lastTime)

				if v14 > 0 then
					controlFlowState = 9
				else
					controlFlowState = 10
				end

				continue
			elseif controlFlowState == 9 then
				task.wait(v14)
				controlFlowState = 10
				continue
			elseif controlFlowState == 10 then
				v15 = os.clock() + 1
				controlFlowState = 14
				continue
			else
				if controlFlowState == 11 then
					controlFlowState = 18
					continue
				end

				if controlFlowState == 12 then
					v2.CutPassed = true

					if data.OnCovered == nil then
						controlFlowState = 16
					else
						controlFlowState = 15
					end

					continue
				elseif controlFlowState == 13 then
					task.wait()
					controlFlowState = 14
					continue
				elseif controlFlowState == 14 then
					if v2.PendingDestination == nil and os.clock() < v15 then
						controlFlowState = 13
					else
						controlFlowState = 12
					end

					continue
				elseif controlFlowState == 15 then
					task.spawn(data.OnCovered)
					controlFlowState = 16
					continue
				elseif controlFlowState == 16 then
					local function place(cframe: CFrame)
						if v2.Lock ~= nil then
							v2.Lock:PivotTo(cframe)
						end

						if localPlayer.Character == character then
							character:PivotTo(cframe)
						end
					end

					pendingDestination = v2.PendingDestination
					v16 = nil

					if pendingDestination == nil then
						controlFlowState = 11
					else
						controlFlowState = 17
					end

					continue
				elseif controlFlowState == 17 then
					v2.PendingDestination = nil

					if v2.Lock == nil then
						controlFlowState = 20
					else
						controlFlowState = 19
					end

					continue
				elseif controlFlowState == 18 then
					v17 = v10 - (os.clock() - lastTime)

					if v17 > 0 then
						controlFlowState = 33
					else
						controlFlowState = 34
					end

					continue
				elseif controlFlowState == 19 then
					v2.Lock:PivotTo(pendingDestination)
					controlFlowState = 20
					continue
				elseif controlFlowState == 20 then
					if localPlayer.Character == character then
						controlFlowState = 21
					else
						controlFlowState = 22
					end

					continue
				elseif controlFlowState == 21 then
					character:PivotTo(pendingDestination)
					controlFlowState = 22
					continue
				elseif controlFlowState == 22 then
					local v25 = pendingDestination
					task.spawn(function()
						pcall(function()
							localPlayer:RequestStreamAroundAsync(v25.Position, 2)
						end)
					end)
					v24 = nil
					controlFlowState = 27
					continue
				elseif controlFlowState == 23 then
					v16 = pendingDestination
					controlFlowState = 29
					continue
				elseif controlFlowState == 24 then
					task.wait(0.1)
					local v25 = os.clock() - lastTime

					if v10 - 0.1 <= v25 then
						controlFlowState = 28
					else
						controlFlowState = 26
					end

					continue
				elseif controlFlowState == 25 then
					if v24 == nil then
						controlFlowState = 23
					else
						controlFlowState = 58
					end

					continue
				else
					if controlFlowState == 26 then
						controlFlowState = 27
						continue
					end

					if controlFlowState == 27 then
						local v25
						v22, v25 = SequenceTeleport.GroundSnap(pendingDestination)

						if v25 then
							controlFlowState = 52
						else
							controlFlowState = 24
						end

						continue
					else
						if controlFlowState == 28 then
							controlFlowState = 25
							continue
						end

						if controlFlowState == 29 then
							v23 = v24 or pendingDestination

							if v2.Lock == nil then
								controlFlowState = 31
							else
								controlFlowState = 30
							end

							continue
						elseif controlFlowState == 30 then
							v2.Lock:PivotTo(v23)
							controlFlowState = 31
							continue
						elseif controlFlowState == 31 then
							if localPlayer.Character == character then
								controlFlowState = 32
							else
								controlFlowState = 0
							end

							continue
						elseif controlFlowState == 32 then
							character:PivotTo(v23)
							controlFlowState = 18
							continue
						elseif controlFlowState == 33 then
							task.wait(v17)
							controlFlowState = 34
							continue
						elseif controlFlowState == 34 then
							if v2.Transition == nil then
								controlFlowState = 36
							else
								controlFlowState = 35
							end

							continue
						elseif controlFlowState == 35 then
							v2.Transition.Switch = true
							v2.Transition = nil
							controlFlowState = 36
							continue
						elseif controlFlowState == 36 then
							v18 = v9 - (os.clock() - lastTime)

							if v18 > 0 then
								controlFlowState = 37
							else
								controlFlowState = 38
							end

							continue
						elseif controlFlowState == 37 then
							task.wait(v18)
							controlFlowState = 38
							continue
						elseif controlFlowState == 38 then
							if v2.Fall == nil then
								controlFlowState = 40
							else
								controlFlowState = 39
							end

							continue
						elseif controlFlowState == 39 then
							v2.Fall:Stop(0)
							controlFlowState = 40
							continue
						elseif controlFlowState == 40 then
							if v2.Rise == nil then
								controlFlowState = 42
							else
								controlFlowState = 41
							end

							continue
						elseif controlFlowState == 41 then
							v2.Rise:Play()
							controlFlowState = 42
							continue
						elseif controlFlowState == 42 then
							v19 = v11 - (os.clock() - lastTime)

							if v19 > 0 then
								controlFlowState = 43
							else
								controlFlowState = 44
							end

							continue
						elseif controlFlowState == 43 then
							task.wait(v19)
							controlFlowState = 44
							continue
						elseif controlFlowState == 44 then
							if v16 == nil then
								controlFlowState = 46
							else
								controlFlowState = 45
							end

							continue
						elseif controlFlowState == 45 then
							v20 = os.clock() + 5
							controlFlowState = 53
							continue
						elseif controlFlowState == 46 then
							v2.Thread = nil

							if v == v2 then
								controlFlowState = 54
							else
								controlFlowState = 55
							end

							continue
						elseif controlFlowState == 47 then
							if v2.Lock == nil then
								controlFlowState = 50
							else
								controlFlowState = 49
							end

							continue
						elseif controlFlowState == 48 then
							if v20 <= os.clock() then
								controlFlowState = 46
							else
								controlFlowState = 59
							end

							continue
						elseif controlFlowState == 49 then
							v2.Lock:PivotTo(v21)
							controlFlowState = 50
							continue
						elseif controlFlowState == 50 then
							if localPlayer.Character == character then
								controlFlowState = 51
							else
								controlFlowState = 46
							end

							continue
						elseif controlFlowState == 51 then
							character:PivotTo(v21)
							controlFlowState = 46
							continue
						elseif controlFlowState == 52 then
							v24 = v22
							controlFlowState = 25
							continue
						elseif controlFlowState == 53 then
							task.wait(0.1)
							local v25
							v21, v25 = SequenceTeleport.GroundSnap(v16)

							if v25 then
								controlFlowState = 47
							else
								controlFlowState = 48
							end

							continue
						elseif controlFlowState == 54 then
							v = nil

							if v2.Lock == nil then
								controlFlowState = 55
							else
								controlFlowState = 56
							end

							continue
						else
							if controlFlowState == 55 then
								break
							end

							if controlFlowState == 56 then
								v2.Lock:Destroy()
								v2.Lock = nil
								controlFlowState = 55
								continue
							elseif controlFlowState == 57 then
								v6 = math.max(0, ringLength - fallLead + fallDelay)
								v7 = v6 + math.min(
									math.max(0, data.TeleportAtFall - 0.35) + coverDelay,
									data.FallLength
								)
								v8 = v7 + 0.35
								v9 = v6 + data.FallLength
								v10 = math.max(v8 + 0.05, v9 - uncoverLead)
								v11 = v9 + data.RiseLength
								lastTime = os.clock()
								local v25 = lastTime

								local function waitUntil(p: number)
									local v26 = p - (os.clock() - v25)

									if v26 > 0 then
										task.wait(v26)
									end
								end

								if v2.Ring == nil then
									controlFlowState = 2
								else
									controlFlowState = 1
								end

								continue
							else
								if controlFlowState == 58 then
									controlFlowState = 29
									continue
								end

								if controlFlowState ~= 59 then
									break
								end

								controlFlowState = 53
								continue
							end
						end
					end
				end
			end
		end
	end)
	return {
		SetDestination = setDestination,
		Cancel = function()
			if v == v2 then
				SequenceTeleport.Cancel()
			end
		end,
		IsActive = function()
			return v == v2
		end
	}
end

return SequenceTeleport