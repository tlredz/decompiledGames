local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local LimitedPackService = require(parent.LimitedPackService)
local EmoteMountService = require(parent.EmoteMountService)
local BattleSettlementEffects = require(parent.BattleSettlementEffects)
local BattleConfig = require(ReplicatedStorage.BattleDemo.BattleConfig)
local BattleSimulation = require(ReplicatedStorage.BattleDemo.BattleSimulation)
local BattleRenderer = require(ReplicatedStorage.BattleDemo.BattleRenderer)
local BattlePlaybackController = require(ReplicatedStorage.Engine.Battle.BattlePlaybackController)
local LimitedPackShowcase = {}
local v = nil
local random = Random.new()

local function alive(p)
	return v == p and not p.closed and p.root.Parent ~= nil
end

local function stopRound(p)
	local round = p.round
	p.round = nil

	if not round then
		return
	end

	round.cancelled = true

	if round.controller then
		round.controller:destroy()
	end

	for _, handle in round.handles do
		if handle and handle.destroy then
			handle.destroy()
		end
	end

	if round.renderer then
		round.renderer:destroy()
	end

	round.root:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unmount(state)
	EmoteMountService.client.unmountLocal(state.mountFolder, state.mountTrack)
	state.mountFolder = nil
	state.mountTrack = nil
end

function LimitedPackShowcase.Close()
	local v2 = v

	if not v2 then
		return
	end

	v = nil
	v2.closed = true
	stopRound(v2)
	unmount(v2) -- equivalent call inferred; original call site unknown

	for k, hiddenPart in v2.hiddenParts do
		if k.Parent then
			k.LocalTransparencyModifier = hiddenPart
		end
	end

	v2.root:Destroy()
end

local function readContents(p)
	local groupContents = LimitedPackService.getGroupContents(p)

	if groupContents.ball and groupContents.flyer and groupContents.explosion then
		return groupContents
	end

	return nil
end

local function chooseFriend(p)
	p.root:SetAttribute("FriendStatus", "Loading")
	local success, result = pcall(function()
		return Players:GetFriendsAsync(Players.LocalPlayer.UserId)
	end)
	local v2

	if v == p then
		v2 = not p.closed and p.root.Parent ~= nil
	else
		v2 = false
	end

	if not v2 then
		return nil
	end

	if success then
		local count = 0
		local id = nil

		while true do
			local v3

			if v == p then
				v3 = not p.closed and p.root.Parent ~= nil
			else
				v3 = false
			end

			if v3 then
				for _, v4 in result:GetCurrentPage() do
					count += 1

					if random:NextInteger(1, count) == 1 then
						id = v4.Id
					end
				end

				if not result.IsFinished then
					local success2, result2 = pcall(function()
						result:AdvanceToNextPageAsync()
					end)
					local v4

					if v == p then
						v4 = not p.closed and p.root.Parent ~= nil
					else
						v4 = false
					end

					if not v4 then
						return nil
					end

					if not success2 then
						p.root:SetAttribute("FriendStatus", "QueryFailed")
						warn("[LimitedPackShowcase] 好友分页查询失败: " .. tostring(result2))
						return nil
					end

					continue
				end
			end

			local v4

			if v == p then
				v4 = not p.closed and p.root.Parent ~= nil
			else
				v4 = false
			end

			if not v4 then
				return nil
			end

			p.root:SetAttribute("FriendCount", count)
			p.root:SetAttribute("FriendStatus", id and "Selected" or "Empty")

			if not id then
				warn("[LimitedPackShowcase] Roblox 好友接口返回空列表，使用默认 R15；UserId=" .. Players.LocalPlayer.UserId)
			end

			return id
		end
	else
		p.root:SetAttribute("FriendStatus", "QueryFailed")
		warn("[LimitedPackShowcase] 好友查询失败: " .. tostring(result))
		return nil
	end
end

local function createAvatar(p, R15, p2: number?)
	local v2 = nil

	if p2 then
		local success, result = pcall(function()
			local result2 = Players:CreateHumanoidModelFromUserIdAsync(p2)
			local humanoid = result2:FindFirstChildOfClass("Humanoid")

			if not humanoid or humanoid.RigType == Enum.HumanoidRigType.R15 then
				return result2
			end

			local appliedDescription = humanoid:GetAppliedDescription()
			result2:Destroy()
			local success2
			success2, result2 = pcall(function()
				return Players:CreateHumanoidModelFromDescriptionAsync(appliedDescription, Enum.HumanoidRigType.R15)
			end)
			appliedDescription:Destroy()

			if not success2 then
				error(result2)
			end

			return result2
		end)

		if success then
			v2 = result
		else
			local v3

			if v == p then
				v3 = not p.closed and p.root.Parent ~= nil
			else
				v3 = false
			end

			if v3 then
				warn("[LimitedPackShowcase] 角色外观加载失败；UserId=" .. p2 .. ": " .. tostring(result))
			end
		end
	end

	local v3

	if v == p then
		v3 = not p.closed and p.root.Parent ~= nil
	else
		v3 = false
	end

	if v3 then
		local v4 = v2 == nil
		local folder = v2 or R15:Clone()
		folder:SetAttribute("UsesFallback", v4)

		if v4 then
			p2 = nil
		end

		folder:SetAttribute("AvatarUserId", p2)
		folder.Name = R15.Name .. "_展示"

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") then
				descendant:Destroy()
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = descendant.Name == "HumanoidRootPart"
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
				descendant.LocalTransparencyModifier = 0
			elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
				descendant.Enabled = false
			end
		end

		local humanoid = folder:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) then
			folder:Destroy()
			return nil
		end

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayDistance = 0
		humanoid.AutoRotate = false
		folder:ScaleTo(R15:GetScale())
		folder.Parent = p.root
		folder:PivotTo(R15.HumanoidRootPart.CFrame * humanoidRootPart.CFrame:ToObjectSpace(folder:GetPivot()))
		return folder
	else
		if v2 then
			v2:Destroy()
		end

		return nil
	end
end

local function mountFlyer(state)
	unmount(state) -- equivalent call inferred; original call site unknown

	if not (state.left and state.content) then
		return
	end

	local humanoid = state.left:FindFirstChildOfClass("Humanoid")
	humanoid.HipHeight = state.leftHipHeight
	local mountFolder, mountTrack = EmoteMountService.client.mountLocal(state.left, state.content.flyer)
	state.mountFolder = mountFolder
	state.mountTrack = mountTrack
	state.root:SetAttribute("CameraBoundsRevision", (state.root:GetAttribute("CameraBoundsRevision") or 0) + 1)
end

local function makeBattleConfig(instance)
	local part = instance:FindFirstChild("绑定箱")
	assert(part and part:IsA("BasePart"), "礼包棋盘缺少绑定箱")
	local scale = instance:GetScale()
	local clone = table.clone(BattleConfig.arena)
	clone.size = Vector2.new(part.Size.X, part.Size.Y) / scale
	local clones = {}

	for k, v2 in { "Blue", "Yellow" } do
		clones[v2] = table.clone(BattleConfig.slots[v2])
		local part2 = instance:FindFirstChild("球位置" .. k)
		assert(part2 and part2:IsA("BasePart"), "礼包棋盘缺少球位置标记")
		local v3 = part.CFrame:PointToObjectSpace(part2.Position) / scale
		clones[v2].spawnPosition = Vector2.new(v3.X, v3.Y)
	end

	local roles = {}

	for k, role in BattleConfig.roles do
		roles[k] = role
	end

	if roles["测试球"] then
		roles["测试球"] = table.clone(roles["测试球"])
		roles["测试球"].maxHp = 25
	end

	return setmetatable({
		arena = clone,
		slots = clones,
		roles = roles
	}, {
		__index = BattleConfig
	}), part.CFrame, scale
end

local function selectShortestBattle(battleConfig, p, current)
	local fixedDt = battleConfig.replay.fixedDt
	local v2 = math.max(1, (math.ceil(battleConfig.replay.maxDuration / fixedDt)))
	local lastTime = os.clock()
	local v3 = 1e999
	local v4 = nil

	for _ = 1, 10 do
		if not current() then
			return nil
		end

		local integer = random:NextInteger(1, 2147483647)
		local v5 = BattleSimulation.new(battleConfig, integer, p)
		local v6 = 0

		for i = 1, v2 do
			local v7 = v5:step(fixedDt)

			if os.clock() - lastTime >= 0.004 then
				task.wait()

				if not current() then
					return nil
				end

				lastTime = os.clock()
			end

			if v7.finished then
				v6 = i
				break
			else
				v6 = i
			end
		end

		if not (v6 < v3) then
			continue
		end

		v4 = integer
		v3 = v6
	end

	return v4, v3 * fixedDt
end

local fn

fn = function(state)
	local v2

	if v == state then
		v2 = not state.closed and state.root.Parent ~= nil
	else
		v2 = false
	end

	if not (v2 and state.ready and state.content) then
		return
	end

	stopRound(state)
	local content = state.content
	local round = {
		handles = {},
		cancelled = false,
		root = Instance.new("Folder")
	}
	round.root.Name = "当前对战"
	round.root.Parent = state.root
	state.round = round

	local function current()
		local v4 = state
		local v5

		if v == v4 then
			v5 = not v4.closed and v4.root.Parent ~= nil
		else
			v5 = false
		end

		if v5 then
			if state.round == round then
				return not round.cancelled
			else
				return false
			end
		end

		return v5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function later(duration, fn2)
		task.delay(duration, function()
			local v4 = state
			local v5

			if v == v4 then
				v5 = not v4.closed and v4.root.Parent ~= nil
			else
				v5 = false
			end

			if v5 then
				if state.round == round then
					v5 = not round.cancelled
				else
					v5 = false
				end
			end

			if v5 then
				fn2()
			end
		end)
	end

	local v4, v5 = xpcall(function()
		local battleConfig, arenaCFrame, arenaScale = makeBattleConfig(state.scene["棋盘"])
		assert(battleConfig.roles[content.ball] and battleConfig.roles["测试球"], "礼包球或测试球未登记到战斗球池")
		state.root:SetAttribute("Phase", "Selecting")
		local selectedRoles = {
			Blue = content.ball,
			Yellow = "测试球"
		}
		local seed, v10 = selectShortestBattle(battleConfig, selectedRoles, current)

		if seed then
			local v11 = state
			local v12

			if v == v11 then
				v12 = not v11.closed and v11.root.Parent ~= nil
			else
				v12 = false
			end

			if v12 then
				if state.round == round then
					v12 = not round.cancelled
				else
					v12 = false
				end
			end

			if v12 then
				state.root:SetAttribute("CandidateCount", 10)
				state.root:SetAttribute("SelectedDuration", v10)
				round.renderer = BattleRenderer.new(battleConfig, {
					instanceId = "LimitedPackShowcase",
					arenaCFrame = arenaCFrame,
					arenaCenter = arenaCFrame.Position,
					arenaScale = arenaScale,
					skipBoard = true,
					hideUI = true,
					showBallHealth = true,
					mutedCues = {
						roundStart = true
					},
					parent = round.root,
					audioMode = "global"
				})
				round.controller = BattlePlaybackController.new(battleConfig, round.renderer)
				round.controller:setOnFinished(function()
					local v13 = state
					local v14

					if v == v13 then
						v14 = not v13.closed and v13.root.Parent ~= nil
					else
						v14 = false
					end

					if v14 then
						if state.round == round then
							v14 = not round.cancelled
						else
							v14 = false
						end
					end

					if not v14 then
						return
					end

					round.controller:pause()
					local winner = round.controller.currentState.winner
					state.root:SetAttribute("Phase", "Settlement")
					state.root:SetAttribute("LastWinner", winner)

					if winner == "Blue" then
						local pluckAllBallsForTeam = round.renderer:pluckAllBallsForTeam("Yellow")
						local pluckAllBallsForTeam2 = round.renderer:pluckAllBallsForTeam("Blue")

						for _, v15 in { pluckAllBallsForTeam, pluckAllBallsForTeam2 } do
							for _, v16 in v15 do
								v16.Parent = round.root
							end
						end

						local v15

						if #pluckAllBallsForTeam == 0 then
							v15 = round.renderer:getLastVanishedBallPosition("Yellow")
						else
							v15 = nil
						end

						local v16 = BattleSettlementEffects.killShake(
							pluckAllBallsForTeam,
							arenaCFrame,
							v15,
							function(p)
								local v17 = state
								local v18

								if v == v17 then
									v18 = not v17.closed and v17.root.Parent ~= nil
								else
									v18 = false
								end

								if v18 then
									if state.round == round then
										v18 = not round.cancelled
									else
										v18 = false
									end
								end

								if not v18 then
									return
								end

								BattleSettlementEffects.deathEffect(pluckAllBallsForTeam, p, v15, function()
									local deathParticleWaitDuration = battleConfig.visual.killDeathSettlement.deathParticleWaitDuration

									local function fn2()
										BattleSettlementEffects.jumpKillWindup(
											pluckAllBallsForTeam2,
											arenaCFrame,
											function()
												local v19 = state
												local v20

												if v == v19 then
													v20 = not v19.closed and v19.root.Parent ~= nil
												else
													v20 = false
												end

												if v20 then
													if state.round == round then
														v20 = not round.cancelled
													else
														v20 = false
													end
												end

												if not v20 then
													return
												end

												if #pluckAllBallsForTeam2 == 0 then
													local function fn3()
														fn(state)
													end

													later(1, fn3) -- equivalent call inferred; original call site unknown
												else
													state.root:SetAttribute("Phase", "Flight")
													local count = #pluckAllBallsForTeam2
													local v21 = 0

													for k, v22 in pluckAllBallsForTeam2 do
														local v23 = v22
														local flyAndImpact = BattleSettlementEffects.flyAndImpact(
															v22,
															state.right.HumanoidRootPart.Position,
															function(p2)
																local v24 = state
																local v25

																if v == v24 then
																	v25 = not v24.closed and v24.root.Parent ~= nil
																else
																	v25 = false
																end

																if v25 then
																	if state.round == round then
																		v25 = not round.cancelled
																	else
																		v25 = false
																	end
																end

																if not v25 then
																	return
																end

																v23:Destroy()
																v21 = math.max(v21, p2)
																count -= 1

																if count == 0 then
																	state.root:SetAttribute("Phase", "Impact")

																	local function fn3()
																		fn(state)
																	end

																	later(v21 + 1, fn3) -- equivalent call inferred; original call site unknown
																end
															end,
															{
																arenaCFrame = arenaCFrame,
																skinCnId = content.explosion,
																effectParent = round.root,
																playImpactEffect = k == 1
															}
														)
														table.insert(round.handles, flyAndImpact)
													end
												end
											end,
											content.explosion,
											nil,
											round.root
										)
									end

									later(deathParticleWaitDuration, fn2) -- equivalent call inferred; original call site unknown
								end, content.explosion, nil, arenaCFrame, round.root)
							end,
							content.explosion,
							nil,
							round.root
						)

						for _, v17 in v16 do
							table.insert(round.handles, v17)
						end
					else
						local function fn2()
							fn(state)
						end

						later(1, fn2) -- equivalent call inferred; original call site unknown
					end
				end)
				state.root:SetAttribute("Phase", "Playing")
				state.root:SetAttribute("Seed", seed)
				state.root:SetAttribute("Round", (state.root:GetAttribute("Round") or 0) + 1)
				round.controller:loadReplay({
					seed = seed,
					replayOptions = {
						selectedRoles = selectedRoles,
						fixedDt = battleConfig.replay.fixedDt,
						maxDuration = battleConfig.replay.maxDuration
					}
				})
			end
		end
	end, debug.traceback)

	if not v4 then
		local v6

		if v == state then
			v6 = not state.closed and state.root.Parent ~= nil
		else
			v6 = false
		end

		if v6 then
			if state.round == round then
				v6 = not round.cancelled
			else
				v6 = false
			end
		end

		if v6 then
			warn("[LimitedPackShowcase] " .. tostring(v5))
			stopRound(state)
			state.root:SetAttribute("Phase", "Error")
		end
	end
end

function LimitedPackShowcase.SetGroup(p)
	local v2 = v

	if not v2 then
		return
	end

	local groupContents = LimitedPackService.getGroupContents(p)

	if not (groupContents.ball and groupContents.flyer and groupContents.explosion) then
		groupContents = nil
	end

	local joined = groupContents and table.concat({
		p.group,
		groupContents.ball,
		groupContents.flyer,
		groupContents.explosion
	}, "|") or p.group

	if v2.signature == joined then
		return
	end

	v2.signature = joined
	v2.content = groupContents
	v2.root:SetAttribute("Group", p.group)
	stopRound(v2)
	unmount(v2) -- equivalent call inferred; original call site unknown

	if not groupContents then
		warn("[LimitedPackShowcase] 包组缺少包含小球、飞行器、爆炸特效的全套奖励: " .. p.group)
	elseif v2.ready then
		mountFlyer(v2)
		fn(v2)
	end
end

function LimitedPackShowcase.Open(parent2, p)
	if v and v.scene == parent2 then
		LimitedPackShowcase.SetGroup(p)
		return
	end

	LimitedPackShowcase.Close()
	local R15 = parent2:FindFirstChild("左侧R15")
	local R152 = parent2:FindFirstChild("右侧R15")
	assert(R15 and R15:IsA("Model") and R152 and R152:IsA("Model"), "礼包场景缺少左右 R15 模板")
	assert(parent2:FindFirstChild("棋盘"), "礼包场景缺少预制棋盘")
	local folder = Instance.new("Folder")
	folder.Name = "礼包展示运行时"
	folder.Parent = parent2
	local v2 = {
		scene = parent2,
		root = folder,
		hiddenParts = {},
		ready = false,
		closed = false
	}
	v = v2

	for _, folder2 in { R15, R152 } do
		for _, part in folder2:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			v2.hiddenParts[part] = part.LocalTransparencyModifier
			part.LocalTransparencyModifier = 1
		end
	end

	LimitedPackShowcase.SetGroup(p)
	folder:SetAttribute("Phase", "LoadingAvatars")
	local count = 0

	local function finishAvatar()
		local v3 = v2
		local v4

		if v == v3 then
			v4 = not v3.closed and v3.root.Parent ~= nil
		else
			v4 = false
		end

		if not v4 then
			return
		end

		count += 1

		if count < 2 then
			return
		end

		if not (v2.left and v2.right) then
			warn("[LimitedPackShowcase] 展示人偶创建失败")
			return
		end

		v2.leftHipHeight = v2.left.Humanoid.HipHeight
		v2.ready = true
		mountFlyer(v2)
		fn(v2)
	end

	task.spawn(function()
		v2.left = createAvatar(v2, R15, Players.LocalPlayer.UserId)
		finishAvatar()
	end)
	task.spawn(function()
		local v3 = chooseFriend(v2)
		local v4 = v2
		local v5

		if v == v4 then
			v5 = not v4.closed and v4.root.Parent ~= nil
		else
			v5 = false
		end

		if not v5 then
			return
		end

		folder:SetAttribute("FriendUserId", v3)
		v2.right = createAvatar(v2, R152, v3)
		finishAvatar()
	end)
end

return LimitedPackShowcase