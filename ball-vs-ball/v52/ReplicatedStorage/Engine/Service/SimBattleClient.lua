local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local SimBattleClient = {}

local function createArenaAnchor()
	local part = Workspace:WaitForChild("模拟对战"):WaitForChild("棋盘锚点")
	assert(part:IsA("BasePart"), "Workspace.模拟对战.棋盘锚点 必须是 BasePart")
	part.Transparency = 1

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			part2.Transparency = 1
		end
	end

	local part2 = Instance.new("Part")
	part2.Name = "SimBattleArenaAnchor"
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.Transparency = 1
	part2.Size = createVector(1, 1, 1)
	part2.CFrame = part.CFrame
	part2.Parent = Workspace
	return part2
end

function SimBattleClient.start(instance)
	local BattleConfig = require(instance:WaitForChild("BattleConfig"))
	local BattleRenderer = require(instance:WaitForChild("BattleRenderer"))
	local BattlePlaybackController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Battle"):WaitForChild("BattlePlaybackController"))
	local CameraShake = require(instance:WaitForChild("BattleRenderer"):WaitForChild("CameraShake"))
	local BattleSettlementEffects = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("BattleSettlementEffects"))
	local BGMPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("BGMPlayer"))
	local part = Workspace:WaitForChild("模拟对战"):WaitForChild("对战视角")
	assert(part:IsA("BasePart"), "Workspace.模拟对战.对战视角 必须是 BasePart")
	local v = nil
	local v2 = nil
	local v3 = CameraShake.new(BattleConfig)
	local flag = false
	local v4 = {}

	local function isValidRoleId(value)
		return typeof(value) == "string" and BattleConfig.roles[value] ~= nil
	end

	local function buildResizedBoardModel(boardSize: number)
		local parent = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("棋盘")
		local model = parent:FindFirstChild(BattleConfig.arena.boardAssetName)
		assert(model and model:IsA("Model"), "模拟对战：默认棋盘素材缺失")
		local v6 = boardSize / BattleConfig.arena.size.X
		local clone = model:Clone()
		local part2 = clone:FindFirstChild("绑定箱")
		assert(part2 and part2:IsA("BasePart"), "模拟对战：棋盘缺少绑定箱")
		local cFrame = part2.CFrame

		local function scaleComponent(p: number)
			if p <= 2 then
				return p
			end

			return p * v6
		end

		for _, part3 in ipairs(clone:GetDescendants()) do
			if not (part3:IsA("BasePart") and part3 ~= part2) then
				continue
			end

			local objectSpace = cFrame:ToObjectSpace(part3.CFrame)
			local v7 = objectSpace - objectSpace.Position
			local vector2 = Vector3.new(
				objectSpace.Position.X * v6,
				objectSpace.Position.Y * v6,
				objectSpace.Position.Z
			)
			local X = part3.Size.X

			if not (X <= 2) then
				X *= v6
			end

			local Y = part3.Size.Y

			if not (Y <= 2) then
				Y *= v6
			end

			local Z = part3.Size.Z

			if not (Z <= 2) then
				Z *= v6
			end

			part3.Size = Vector3.new(X, Y, Z)
			part3.CFrame = cFrame * CFrame.new(vector2) * v7
		end

		part2.Size = Vector3.new(boardSize, boardSize, part2.Size.Z)
		clone.Name = string.format("模拟对战自定义棋盘_%d", (math.floor(os.clock() * 1000)))
		clone.Parent = parent
		return clone, clone.Name
	end

	local function buildArenaOverrideConfig(boardSize: number, boardAssetName: string)
		local arena = {}

		for k, v6 in pairs(BattleConfig.arena) do
			arena[k] = v6
		end

		arena.size = Vector2.new(boardSize, boardSize)
		arena.boardAssetName = boardAssetName
		local v6 = boardSize / BattleConfig.arena.size.X

		-- equivalent calls inferred from this helper; original call sites unknown
		local function scaleCorners(spawnPositionCorners)
			if not spawnPositionCorners then
				return nil
			end

			local result = {}

			for i, v7 in ipairs(spawnPositionCorners) do
				result[i] = v7 * v6
			end

			return result
		end

		local blue = {
			spawnPosition = BattleConfig.slots.Blue.spawnPosition * v6,
			spawnPositionCorners = 0
		}
		local spawnPositionCorners2 = scaleCorners(BattleConfig.slots.Blue.spawnPositionCorners) -- equivalent call inferred; original call site unknown
		blue.spawnPositionCorners = spawnPositionCorners2
		local yellow = {
			spawnPosition = BattleConfig.slots.Yellow.spawnPosition * v6,
			spawnPositionCorners = 0
		}
		local spawnPositionCorners3 = scaleCorners(BattleConfig.slots.Yellow.spawnPositionCorners) -- equivalent call inferred; original call site unknown
		yellow.spawnPositionCorners = spawnPositionCorners3
		return (setmetatable({
			arena = arena,
			slots = {
				Blue = blue,
				Yellow = yellow
			}
		}, {
			__index = BattleConfig
		}))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pauseBgmForBattle()
		if flag then
			return
		end

		flag = true
		BGMPlayer.Pause()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resumeBgmAfterBattle()
		if not flag then
			return
		end

		flag = false
		BGMPlayer.Resume()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreCamera()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if not v2 then
			currentCamera.CameraType = Enum.CameraType.Custom
			return
		end

		currentCamera.CameraType = v2.cameraType
		currentCamera.CameraSubject = v2.cameraSubject
		v2 = nil
	end

	local function destroyActiveBattle()
		if not v then
			return
		end

		v.controller:destroy()
		v.renderer:destroy()
		v.anchor:Destroy()

		if v.customBoardTemplate then
			v.customBoardTemplate:Destroy()
		end

		v = nil
		local RewardNotification = require(ReplicatedStorage.Engine.Gui.RewardNotification)
		RewardNotification.SetSimulationActive(false)
		v3:reset()
		restoreCamera() -- equivalent call inferred; original call site unknown
		resumeBgmAfterBattle() -- equivalent call inferred; original call site unknown
	end

	local function lockCamera()
		if not v then
			return false
		end

		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return false
		end

		if not v2 then
			v2 = {
				cameraType = currentCamera.CameraType,
				cameraSubject = currentCamera.CameraSubject
			}
		end

		if part.Parent == nil then
			return false
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = v.cameraBaseCFrame
		currentCamera.Focus = v.cameraBaseCFrame
		return true
	end

	local function applyCameraShake(p: number)
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera or not v or part.Parent == nil then
			return
		end

		currentCamera.CFrame = v.cameraBaseCFrame * CFrame.new(v3:getOffset(p))
		currentCamera.Focus = v.cameraBaseCFrame
	end

	local function finishBattle(p)
		if p.finished then
			return
		end

		p.finished = true
		local RewardNotification = require(ReplicatedStorage.Engine.Gui.RewardNotification)
		RewardNotification.SetSimulationActive(false)
		p.animating = false
		restoreCamera() -- equivalent call inferred; original call site unknown

		for _, callback in ipairs(v4) do
			task.spawn(callback)
		end

		task.delay(2.5, function()
			if v == p then
				destroyActiveBattle()
			end
		end)
	end

	local function startLocalBattle(data)
		destroyActiveBattle()
		local arenaAnchor = createArenaAnchor()
		local boardSize = data.boardSize or BattleConfig.arena.size.X
		local resizedBoardModel, boardAssetName = buildResizedBoardModel(boardSize)
		local arenaOverrideConfig = buildArenaOverrideConfig(boardSize, boardAssetName)
		local unit = (part.Position - arenaAnchor.Position).Unit
		local fieldOfView = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
		local v6 = (boardSize / 2 + 0.3 + 1) / math.tan(math.rad(fieldOfView) / 2)
		local cframe = CFrame.new(arenaAnchor.Position + unit * v6, arenaAnchor.Position)
		local arenaScale = BattleConfig.tournament.arenaScale
		local renderer = BattleRenderer.new(arenaOverrideConfig, {
			instanceId = data.matchId or "SimBattle",
			arenaCenter = arenaAnchor.Position,
			arenaCFrame = arenaAnchor.CFrame,
			arenaScale = arenaScale,
			audioMode = "global",
			hideBallHealth = data.hideBallHealth == true,
			onCameraImpact = function(p: number, p2)
				v3:trigger(p, p2)
			end
		})
		local controller = BattlePlaybackController.new(arenaOverrideConfig, renderer)
		renderer:setLocalParticipantSlot("Blue")
		renderer:setForceHighlightAllEnemies(data.isTeamBattle == true)
		renderer:setParticipantView(true, "Playing")
		controller:loadReplay(data)
		local v9 = {
			anchor = arenaAnchor,
			renderer = renderer,
			controller = controller,
			scale = arenaScale,
			finished = false,
			animating = false,
			cameraLocked = false,
			customBoardTemplate = resizedBoardModel,
			cameraBaseCFrame = cframe
		}
		v = v9
		local RewardNotification = require(ReplicatedStorage.Engine.Gui.RewardNotification)
		RewardNotification.SetSimulationActive(true)
		local killDeathSettlement = BattleConfig.visual.killDeathSettlement
		controller:setOnFinished(function()
			if v ~= v9 then
				return
			end

			v9.animating = true
			local currentState = controller.currentState
			local winner = currentState and currentState.winner

			if winner ~= "Blue" and winner ~= "Yellow" then
				finishBattle(v9)
				return
			end

			controller:pause()
			local v10 = winner == "Blue" and "Yellow" or "Blue"
			local pluckAllBallsForTeam = renderer:pluckAllBallsForTeam(v10)
			local v11

			if #pluckAllBallsForTeam == 0 then
				v11 = renderer:getLastVanishedBallPosition(v10)
			else
				v11 = nil
			end

			BattleSettlementEffects.killShake(pluckAllBallsForTeam, arenaAnchor.CFrame, v11, function(p)
				if v ~= v9 then
					return
				end

				BattleSettlementEffects.deathEffect(pluckAllBallsForTeam, p, v11, function()
					if v ~= v9 then
						return
					end

					task.delay(killDeathSettlement.deathParticleWaitDuration, function()
						if v ~= v9 then
							return
						end

						local pluckAllBallsForTeam2 = renderer:pluckAllBallsForTeam(winner)
						BattleSettlementEffects.jumpKillWindup(pluckAllBallsForTeam2, arenaAnchor.CFrame, function()
							for _, v12 in pluckAllBallsForTeam2 do
								if v12.Parent then
									v12:Destroy()
								end
							end

							if v ~= v9 then
								return
							end

							finishBattle(v9)
						end)
					end)
				end, nil, nil, arenaAnchor.CFrame)
			end)
		end)
	end

	local function normalizeTeamSelection(list)
		if #list <= 1 then
			return list[1]
		end

		return list
	end

	function SimBattleClient.startBattle(list, list2, p: number?, p2)
		if typeof(list) ~= "table" or typeof(list2) ~= "table" or #list == 0 or #list2 == 0 then
			return false, "invalid_role"
		end

		for _, v5 in ipairs(list) do
			local v6

			if typeof(v5) == "string" then
				v6 = BattleConfig.roles[v5] ~= nil
			else
				v6 = false
			end

			if not v6 then
				return false, "invalid_role"
			end
		end

		for _, v5 in ipairs(list2) do
			local v6

			if typeof(v5) == "string" then
				v6 = BattleConfig.roles[v5] ~= nil
			else
				v6 = false
			end

			if not v6 then
				return false, "invalid_role"
			end
		end

		local boardSize = p or BattleConfig.arena.size.X

		if typeof(boardSize) ~= "number" or boardSize ~= boardSize or boardSize < 10 or boardSize > 100 then
			return false, "invalid_board_size"
		end

		local integer = Random.new():NextInteger(1, 2147483647)
		local localPlayer = Players.LocalPlayer
		local blue

		if #list <= 1 then
			blue = list[1]
		else
			blue = list
		end

		local yellow

		if #list2 <= 1 then
			yellow = list2[1]
		else
			yellow = list2
		end

		startLocalBattle({
			seed = integer,
			replayOptions = {
				selectedRoles = {
					Blue = blue,
					Yellow = yellow
				}
			},
			matchId = string.format(
				"SimBattle_%d_%d",
				localPlayer and localPlayer.UserId or 0,
				(math.floor(os.clock() * 1000))
			),
			boardSize = boardSize,
			isTeamBattle = #list > 1 or #list2 > 1,
			hideBallHealth = p2 ~= nil and p2.showHealth == false
		})
		return true, nil
	end

	function SimBattleClient.onEnded(callback)
		table.insert(v4, callback)
	end

	RunService.RenderStepped:Connect(function(dt: number)
		if not v then
			return
		end

		if v.controller:isPlaying() or v.animating then
			pauseBgmForBattle() -- equivalent call inferred; original call site unknown

			if not v.cameraLocked and lockCamera() then
				v.cameraLocked = true
			end

			if v.cameraLocked then
				local currentCamera = Workspace.CurrentCamera

				if currentCamera and v then
					if part.Parent == nil then
						return
					end

					currentCamera.CFrame = v.cameraBaseCFrame * CFrame.new(v3:getOffset(dt))
					currentCamera.Focus = v.cameraBaseCFrame
				end
			end
		end
	end)
end

return SimBattleClient