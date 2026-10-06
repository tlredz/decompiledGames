local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages:WaitForChild("Net"))
local battleRenderer = battleDemo:WaitForChild("BattleRenderer")
local TemplateLibrary = require(battleRenderer:WaitForChild("TemplateLibrary"))
local RenderMath = require(battleRenderer:WaitForChild("RenderMath"))
local DuelAimBallBadge = require(battleDemo:WaitForChild("DuelAimBallBadge"))
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("杂项"):WaitForChild("发射方向箭头")
local GameModeRegistry = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("GameModeRegistry"))
local ArenaOverride = require(battleDemo:WaitForChild("ArenaOverride"))
local DuelLaunchAimClient = {}
DuelLaunchAimClient.__index = DuelLaunchAimClient

local function findTableById(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local firstChild = Workspace:FindFirstChild("双人对战", true)

	if not firstChild then
		return nil
	end

	for _, model in ipairs(firstChild:GetChildren()) do
		if model:IsA("Model") and (model:GetAttribute("DuelTableId") == value or model.Name == value) then
			return model
		end
	end

	return nil
end

local function resolveTable(model, p)
	if typeof(model) == "Instance" and model:IsA("Model") then
		return model
	end

	return (findTableById(p))
end

local function getAnchor(instance)
	local part = instance:FindFirstChild("棋盘锚点") or instance:FindFirstChild("ArenaAnchor")

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function getUserId(value)
	if typeof(value) == "number" then
		return value
	end

	if typeof(value) == "table" and typeof(value.userId) == "number" then
		return value.userId
	end

	return nil
end

local function spawnAimingBall(templates, config, parent, part, roleId: string, worldPosition: Vector3, vector2: Vector3, flag: boolean)
	local ballTemplateBundle = templates.ballTemplateBundles[roleId]

	if not ballTemplateBundle then
		return nil, nil, nil
	end

	local clone, v2 = TemplateLibrary.clone(ballTemplateBundle)
	clone.Parent = parent
	local v3 = RenderMath.getArenaBallCFrame(part.CFrame, worldPosition) * ballTemplateBundle.forwardOffset:Inverse()
	clone:PivotTo(v3)
	local attachment = v2:FindFirstChild("朝向标记")

	if not (attachment and attachment:IsA("Attachment")) then
		attachment = nil
	end

	local worldCFrame

	if attachment then
		worldCFrame = attachment.WorldCFrame
	end

	local role = config.roles[roleId]
	local facingMode = RenderMath.getFacingMode(role and role.skill and role.skill.trigger)
	local v4 = nil

	if facingMode == RenderMath.FACING_TARGET then
		v4 = RenderMath.resolveDirectionFacingCFrame(
			worldPosition,
			vector2,
			part.CFrame.LookVector,
			ballTemplateBundle.forwardOffset
		)
	elseif facingMode == RenderMath.FACING_DIRECTION and not flag then
		v4 = RenderMath.getConcealedAimingCFrame(part.CFrame, worldPosition, ballTemplateBundle.forwardOffset)
	end

	clone:PivotTo(v4 or v3)
	return clone, attachment, worldCFrame
end

function DuelLaunchAimClient.new(config)
	local object = setmetatable({}, DuelLaunchAimClient)
	object.config = config
	object.templates = TemplateLibrary.load(ReplicatedStorage, config)
	object.session = nil
	object.spectatorSessions = {}
	object.lastDirectionByTable = {}
	object.onDirectionChanged = nil
	object.onLocked = nil
	object.onSessionBegan = nil
	object.onSessionEnded = nil
	object.launchButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("战斗匹配UI"):WaitForChild("Background"):WaitForChild("对战信息层"):WaitForChild("发射按钮")
	object.launchButton.Visible = false
	object.launchButton.Selectable = false
	object.gamepadConfirmArmed = false
	local ButtonHints = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
	ButtonHints.TrackStandalone(object.launchButton, "A", function()
		local v2

		if object.session == nil then
			return false
		else
			v2 = not object.session.locked

			if v2 then
				local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
				return not GamepadPages.IsBlocking()
			end
		end

		return v2
	end)
	object.launchButton.Activated:Connect(function(p)
		if p and p.KeyCode == Enum.KeyCode.ButtonA then
			return
		end

		object:_confirmLock()
	end)
	object.launchDirectionRemote = Net:RemoteEvent("DuelTableLaunchDirection")
	object.aimPreviewRemote = Net:UnreliableRemoteEvent("DuelTableAimPreview")
	Net:Connect("DuelTableState", function(p)
		object:_onState(p)
	end)
	object.aimPreviewRemote.OnClientEvent:Connect(function(p, p2, p3)
		object:_onTeammateAimPreview(p, p2, p3)
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		object:_onInputBegan(input, gameProcessed)
	end)
	UserInputService.InputChanged:Connect(function(input)
		object:_onInputChanged(input)
	end)
	UserInputService.InputEnded:Connect(function(input)
		object:_onInputEnded(input)
	end)
	return object
end

function DuelLaunchAimClient:_onState(p)
	if typeof(p) ~= "table" or typeof(p.tables) ~= "table" then
		return
	end

	local localPlayer = Players.LocalPlayer
	local tablesByTable = {}
	local v2 = nil

	for _, table2 in pairs(p.tables) do
		if typeof(table2) ~= "table" then
			continue
		end

		local table3 = table2.table
		local tableId = table2.tableId

		if typeof(table3) ~= "Instance" or not table3:IsA("Model") then
			table3 = findTableById(tableId)
		end

		if table3 and (table2.state == "Waiting" or table2.state == "Idle") then
			self.lastDirectionByTable[table3] = nil
		end

		if not (table2.state == "Aiming" and typeof(table2.players) == "table" and table3) then
			continue
		end

		tablesByTable[table3] = table2

		for _, userId in pairs(table2.players) do
			if typeof(userId) ~= "number" then
				if typeof(userId) == "table" and typeof(userId.userId) == "number" then
					userId = userId.userId
				else
					userId = nil
				end
			end

			if userId ~= localPlayer.UserId then
				continue
			end

			v2 = table2
			break
		end
	end

	if v2 then
		local table2 = v2.table
		local tableId = v2.tableId

		if typeof(table2) ~= "Instance" or not table2:IsA("Model") then
			table2 = findTableById(tableId)
		end

		if table2 and (not self.session or self.session.tableModel ~= table2) then
			self:_endSession()
			self:_endSpectatorSession(table2)
			self:_beginSession(table2, v2)
		end
	else
		self:_endSession()
	end

	for k, v3 in tablesByTable do
		if not (not self.session or self.session.tableModel ~= k) or self.spectatorSessions[k] then
			continue
		end

		self:_beginSpectatorSession(k, v3)
	end

	for k in self.spectatorSessions do
		if not tablesByTable[k] or self.session and self.session.tableModel == k then
			self:_endSpectatorSession(k)
		end
	end
end

function DuelLaunchAimClient:_getTableConfig(p2)
	local v2 = GameModeRegistry.getForTable(p2)

	if GameModeRegistry.isTeamMode(v2) then
		return ArenaOverride.resolveConfig(self.config, ArenaOverride.buildArenaData(v2))
	end

	return self.config
end

function DuelLaunchAimClient:_beginSession(parent, p)
	local part = parent:FindFirstChild("棋盘锚点") or parent:FindFirstChild("ArenaAnchor")

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if not part then
		warn((`[DuelLaunchAimClient] 桌子缺少棋盘锚点: {parent:GetFullName()}`))
		return
	end

	local localPlayer = Players.LocalPlayer
	local players = p.players
	local localSlot = nil

	for k, userId in pairs(players) do
		if typeof(userId) ~= "number" then
			if typeof(userId) == "table" and typeof(userId.userId) == "number" then
				userId = userId.userId
			else
				userId = nil
			end
		end

		if userId == localPlayer.UserId then
			localSlot = k
		end
	end

	if not localSlot then
		return
	end

	local _getTableConfig = self:_getTableConfig(parent)
	local slots = _getTableConfig.slots
	local v3 = {}

	for k, userId in pairs(players) do
		if typeof(userId) ~= "table" then
			continue
		end

		local team

		if typeof(userId.team) == "string" then
			team = userId.team
		else
			team = k
		end

		local v4 = typeof(userId.teamIndex) ~= "number" and 1 or userId.teamIndex
		local slot = slots[team]

		if not slot then
			continue
		end

		local spawnPositionCorners = slot.spawnPositionCorners
		local spawnPosition

		if _getTableConfig == self.config or not (spawnPositionCorners and spawnPositionCorners[v4]) then
			spawnPosition = slot.spawnPosition
		else
			spawnPosition = spawnPositionCorners[v4]
		end

		local v5 = {
			slotId = k,
			team = team,
			roleId = userId.roleId,
			killCount = userId.killCount,
			serial = userId.serial,
			userId = 0,
			spawn2D = 0,
			worldPosition = 0
		}

		if typeof(userId) ~= "number" then
			if typeof(userId) == "table" and typeof(userId.userId) == "number" then
				userId = userId.userId
			else
				userId = nil
			end
		end

		v5.userId = userId
		v5.spawn2D = spawnPosition
		v5.worldPosition = RenderMath.worldFromArena(part.CFrame, 1, spawnPosition, 0)
		table.insert(v3, v5)
	end

	local v4 = nil

	for _, v5 in v3 do
		if typeof(v5.roleId) ~= "string" then
			return
		end

		if v5.slotId == localSlot then
			v4 = v5
		end
	end

	if not v4 then
		return
	end

	local roleId = v4.roleId
	local spawn2D = v4.spawn2D
	local worldPosition = v4.worldPosition
	local v5 = nil

	for _, v6 in v3 do
		if not (v6.team ~= v4.team and (not v5 or (v6.spawn2D - spawn2D).Magnitude < (v5.spawn2D - spawn2D).Magnitude)) then
			continue
		end

		v5 = v6
	end

	if not v5 then
		return
	end

	local spawn2D2 = v5.spawn2D
	local vectorToWorldSpace = part.CFrame:VectorToWorldSpace(createVector(1, 0, 0))
	local vectorToWorldSpace2 = part.CFrame:VectorToWorldSpace(createVector(0, 1, 0))
	local role = self.config.roles[roleId]
	local facesLaunchDirection = RenderMath.getFacingMode(role and role.skill and role.skill.trigger) == RenderMath.FACING_DIRECTION
	local ballTemplateBundle = self.templates.ballTemplateBundles[roleId]

	local function nearestEnemyWorldPosition(data)
		local v7 = nil

		for _, v8 in v3 do
			if not (v8.team ~= data.team and (not v7 or (v8.spawn2D - data.spawn2D).Magnitude < (v7.spawn2D - data.spawn2D).Magnitude)) then
				continue
			end

			v7 = v8
		end

		if v7 then
			return v7.worldPosition
		end

		return data.worldPosition
	end

	local ballModels = {}
	local v8 = {}
	local ballMarker = nil

	for _, v10 in v3 do
		local v11 = v10 == v4
		local v12, v13, badgeCFrame = spawnAimingBall(
			self.templates,
			self.config,
			parent,
			part,
			v10.roleId,
			v10.worldPosition,
			nearestEnemyWorldPosition(v10),
			v11
		)
		v10.badgeCFrame = badgeCFrame
		ballModels[v10.slotId] = v12
		v8[v10.slotId] = v13

		if v11 then
			ballMarker = v13
		end
	end

	local slotId = nil
	local userId = nil

	if GameModeRegistry.isTeamMode(GameModeRegistry.getForTable(parent)) then
		for _, v11 in v3 do
			if not (v11.slotId ~= localSlot and v11.team == v4.team) then
				continue
			end

			slotId = v11.slotId
			userId = v11.userId
			break
		end
	end

	if ballMarker then
		local unit = self.lastDirectionByTable[parent]

		if not unit then
			local v10 = spawn2D2 - spawn2D

			if v10.Magnitude > 1e-6 then
				local v11 = math.rad(math.random() * 10 - 5)
				local v12 = math.cos(v11)
				local v13 = math.sin(v11)
				local unit2 = v10.Unit
				unit = Vector2.new(unit2.X * v12 - unit2.Y * v13, unit2.X * v13 + unit2.Y * v12).Unit
			else
				unit = Vector2.new(1, 0)
			end
		end

		local clone = v:Clone()
		clone.Parent = parent
		local session = {
			tableModel = parent,
			localSlot = localSlot,
			anchor = part,
			arenaWorldX = vectorToWorldSpace,
			arenaWorldY = vectorToWorldSpace2,
			ballMarker = ballMarker,
			ballModels = ballModels,
			badgeHandles = {},
			badgeDelayThread = nil,
			arrowModel = clone,
			direction = unit,
			locked = false,
			dragging = false,
			dragKind = nil,
			activeTouch = nil,
			lastDragScreenPos = nil,
			autoLockThread = nil,
			clockwiseSign = 1,
			facesLaunchDirection = facesLaunchDirection,
			localBundle = ballTemplateBundle,
			localBallWorldPosition = worldPosition,
			teammateSlot = slotId,
			teammateUserId = userId,
			teammateMarker = 0,
			teammateArrowModel = nil,
			teammateDirection = nil,
			teammateRenderedDirection = nil,
			teammateSmoothConnection = nil,
			lastPreviewSentAt = 0
		}
		local teammateMarker

		if slotId then
			teammateMarker = v8[slotId]
		end

		session.teammateMarker = teammateMarker

		if facesLaunchDirection then
			print(string.format("[DuelLaunchAimClient] 本局 %s 使用 %s（Direction 类），Aiming 阶段本体朝向将跟随箭头", localSlot, roleId))
		end

		self.session = session

		if slotId then
			session.teammateSmoothConnection = RunService.RenderStepped:Connect(function(dt: number)
				self:_stepTeammateSmoothing(session, dt)
			end)
		end

		self:_bindGamepad()
		self:_applyArrowDirection(session)
		session.badgeDelayThread = task.delay(0.35, function()
			session.badgeDelayThread = nil

			if self.session ~= session then
				return
			end

			for _, v12 in v3 do
				local v13 = v8[v12.slotId]

				if v13 and v13:IsDescendantOf(parent) then
					session.badgeHandles[v12.slotId] = DuelAimBallBadge.attach(
						parent,
						v12.badgeCFrame,
						v12.roleId,
						v12.killCount,
						v12.serial
					)
				end
			end
		end)
		self.launchButton:SetAttribute("AimLocked", false)
		self.launchButton.Visible = true

		if self.onSessionBegan then
			self.onSessionBegan()
		end

		local countdownEndsAt = p.countdownEndsAt

		if typeof(countdownEndsAt) == "number" then
			local v12 = math.max(0, countdownEndsAt - Workspace:GetServerTimeNow())
			session.autoLockThread = task.delay(v12, function()
				if self.session == session and not session.locked then
					self:_confirmLock()
				end
			end)
		end
	else
		for _, v10 in ballModels do
			if v10 then
				v10:Destroy()
			end
		end
	end
end

function DuelLaunchAimClient:_beginSpectatorSession(instance, p)
	local part = instance:FindFirstChild("棋盘锚点") or instance:FindFirstChild("ArenaAnchor")

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if not part then
		return
	end

	local _getTableConfig = self:_getTableConfig(instance)
	local v2 = {}

	for k, player in pairs(p.players) do
		if not (typeof(player) == "table" and typeof(player.roleId) == "string") then
			continue
		end

		local team

		if typeof(player.team) == "string" then
			team = player.team
		else
			team = k
		end

		local v3 = typeof(player.teamIndex) ~= "number" and 1 or player.teamIndex
		local slot = _getTableConfig.slots[team]

		if not slot then
			continue
		end

		local spawnPositionCorners = slot.spawnPositionCorners
		local spawnPosition

		if _getTableConfig == self.config or not (spawnPositionCorners and spawnPositionCorners[v3]) then
			spawnPosition = slot.spawnPosition
		else
			spawnPosition = spawnPositionCorners[v3]
		end

		table.insert(v2, {
			slotId = k,
			team = team,
			roleId = player.roleId,
			killCount = player.killCount,
			serial = player.serial,
			spawn2D = spawnPosition,
			worldPosition = RenderMath.worldFromArena(part.CFrame, 1, spawnPosition, 0)
		})
	end

	local ballModels = {}
	local v4 = {}
	local badgeHandles = {}

	for _, v6 in v2 do
		local v7 = nil

		for _, v8 in v2 do
			if not (v8.team ~= v6.team and (not v7 or (v8.spawn2D - v6.spawn2D).Magnitude < (v7.spawn2D - v6.spawn2D).Magnitude)) then
				continue
			end

			v7 = v8
		end

		local v8

		if v7 then
			v8 = v7.worldPosition
		else
			v8 = v6.worldPosition
		end

		local v9, v10, badgeCFrame = spawnAimingBall(
			self.templates,
			self.config,
			instance,
			part,
			v6.roleId,
			v6.worldPosition,
			v8,
			false
		)
		v6.badgeCFrame = badgeCFrame
		ballModels[v6.slotId] = v9
		v4[v6.slotId] = v10
	end

	local v6 = {
		ballModels = ballModels,
		badgeHandles = badgeHandles,
		badgeDelayThread = nil
	}
	self.spectatorSessions[instance] = v6
	v6.badgeDelayThread = task.delay(0.35, function()
		v6.badgeDelayThread = nil

		if self.spectatorSessions[instance] ~= v6 then
			return
		end

		for _, v7 in v2 do
			local v8 = v4[v7.slotId]

			if v8 and v8:IsDescendantOf(instance) then
				badgeHandles[v7.slotId] = DuelAimBallBadge.attach(
					instance,
					v7.badgeCFrame,
					v7.roleId,
					v7.killCount,
					v7.serial
				)
			end
		end
	end)
end

function DuelLaunchAimClient:_endSpectatorSession(p2)
	local spectatorSession = self.spectatorSessions[p2]

	if not spectatorSession then
		return
	end

	self.spectatorSessions[p2] = nil

	if spectatorSession.badgeDelayThread then
		task.cancel(spectatorSession.badgeDelayThread)
	end

	for _, badgeHandle in pairs(spectatorSession.badgeHandles) do
		badgeHandle:destroy()
	end

	for _, ballModel in pairs(spectatorSession.ballModels) do
		if ballModel then
			ballModel:Destroy()
		end
	end
end

function DuelLaunchAimClient:_endSession()
	self:_unbindGamepad()
	local session = self.session

	if not session then
		return
	end

	if session.autoLockThread then
		task.cancel(session.autoLockThread)
	end

	if session.badgeDelayThread then
		task.cancel(session.badgeDelayThread)
	end

	for _, badgeHandle in pairs(session.badgeHandles) do
		badgeHandle:destroy()
	end

	for _, ballModel in pairs(session.ballModels) do
		if ballModel then
			ballModel:Destroy()
		end
	end

	if session.arrowModel then
		session.arrowModel:Destroy()
	end

	if session.teammateArrowModel then
		session.teammateArrowModel:Destroy()
	end

	if session.teammateSmoothConnection then
		session.teammateSmoothConnection:Disconnect()
	end

	self.session = nil
	self.launchButton.Visible = false

	if self.onSessionEnded then
		self.onSessionEnded()
	end
end

function DuelLaunchAimClient:_applyArrowDirection(data)
	local arrowModel = data.arrowModel

	if not arrowModel then
		return
	end

	local part = arrowModel:FindFirstChild("绑定箱")
	local attachment = part and part:FindFirstChild("朝向标记")

	if not (part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment")) then
		return
	end

	local cFrame = attachment.CFrame
	local v2 = data.arenaWorldX * data.direction.X + data.arenaWorldY * data.direction.Y

	if v2.Magnitude < 1e-6 then
		return
	end

	local worldPosition = data.ballMarker.WorldPosition
	arrowModel:PivotTo(CFrame.lookAt(worldPosition, worldPosition + v2.Unit, data.anchor.CFrame.LookVector) * cFrame:Inverse())
	self:_applyLaunchDirectionFacing(data, v2)
	self:_sendAimPreview(data)
end

function DuelLaunchAimClient:_sendAimPreview(state)
	if not state.teammateSlot then
		return
	end

	local now = os.clock()

	if now - state.lastPreviewSentAt < 0.05 then
		return
	end

	state.lastPreviewSentAt = now
	self.aimPreviewRemote:FireServer(state.tableModel, state.direction)
end

function DuelLaunchAimClient:_onTeammateAimPreview(p2, p3, teammateDirection)
	local session = self.session

	if not session or session.tableModel ~= p2 or session.teammateUserId ~= p3 or typeof(teammateDirection) ~= "Vector2" then
		return
	end

	session.teammateDirection = teammateDirection
end

function DuelLaunchAimClient:_stepTeammateSmoothing(state, p: number)
	local teammateDirection = state.teammateDirection

	if not teammateDirection then
		return
	end

	local lerped = (state.teammateRenderedDirection or teammateDirection):Lerp(teammateDirection, 1 - 0.5 ^ (p / 0.08))

	if not (lerped.Magnitude < 1e-6) then
		teammateDirection = lerped.Unit
	end

	state.teammateRenderedDirection = teammateDirection
	self:_renderTeammateArrow(state, teammateDirection)
end

function DuelLaunchAimClient:_renderTeammateArrow(state, point: Vector2)
	local teammateMarker = state.teammateMarker

	if not teammateMarker or point.Magnitude < 1e-6 then
		return
	end

	local teammateArrowModel = state.teammateArrowModel

	if not teammateArrowModel then
		teammateArrowModel = v:Clone()
		teammateArrowModel.Parent = state.tableModel
		state.teammateArrowModel = teammateArrowModel
	end

	local part = teammateArrowModel:FindFirstChild("绑定箱")
	local attachment = part and part:FindFirstChild("朝向标记")

	if not (part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment")) then
		return
	end

	local cFrame = attachment.CFrame
	local v2 = state.arenaWorldX * point.X + state.arenaWorldY * point.Y

	if v2.Magnitude < 1e-6 then
		return
	end

	local worldPosition = teammateMarker.WorldPosition
	teammateArrowModel:PivotTo(CFrame.lookAt(worldPosition, worldPosition + v2.Unit, state.anchor.CFrame.LookVector) * cFrame:Inverse())
end

function DuelLaunchAimClient:_applyLaunchDirectionFacing(data, vector2: Vector3)
	if not (data.facesLaunchDirection and data.localBundle) then
		return
	end

	local ballModel = data.ballModels[data.localSlot]

	if not ballModel then
		return
	end

	local directionFacingCFrame = RenderMath.resolveDirectionFacingCFrame(
		data.localBallWorldPosition,
		data.localBallWorldPosition + vector2,
		data.anchor.CFrame.LookVector,
		data.localBundle.forwardOffset
	)

	if directionFacingCFrame then
		ballModel:PivotTo(directionFacingCFrame)
	end
end

function DuelLaunchAimClient:_onInputBegan(activeTouch, flag: boolean)
	local session = self.session

	if not session or session.locked or flag then
		return
	end

	if activeTouch.UserInputType == Enum.UserInputType.MouseButton1 or activeTouch.UserInputType == Enum.UserInputType.MouseButton2 then
		session.dragging = true
		session.dragKind = "Mouse"
		session.lastDragScreenPos = Vector2.new(activeTouch.Position.X, activeTouch.Position.Y)
	elseif activeTouch.UserInputType == Enum.UserInputType.Touch then
		session.dragging = true
		session.dragKind = "Touch"
		session.activeTouch = activeTouch
		session.lastDragScreenPos = Vector2.new(activeTouch.Position.X, activeTouch.Position.Y)
	end
end

function DuelLaunchAimClient:_onMouseWheel(p)
	local session = self.session

	if not session or session.locked then
		return
	end

	local Z = p.Position.Z

	if Z == 0 then
		return
	end

	self:_rotateDirection(session, Z < 0 and 0.10471975511965978 or -0.10471975511965978)
end

function DuelLaunchAimClient:_rotateDirection(state, p: number)
	local v2 = state.clockwiseSign * p
	local v3 = math.cos(v2)
	local v4 = math.sin(v2)
	local direction = state.direction
	local vector2 = Vector2.new(direction.X * v3 - direction.Y * v4, direction.X * v4 + direction.Y * v3)

	if vector2.Magnitude < 1e-6 then
		return
	end

	state.direction = vector2.Unit
	self:_applyArrowDirection(state)

	if self.onDirectionChanged then
		self.onDirectionChanged((math.abs(p)))
	end
end

function DuelLaunchAimClient:_onInputChanged(p)
	local session = self.session

	if not session or session.locked then
		return
	end

	if p.UserInputType == Enum.UserInputType.MouseWheel then
		self:_onMouseWheel(p)
		return
	end

	if not (session.dragging and session.lastDragScreenPos) then
		return
	end

	local v2

	if session.dragKind == "Mouse" and p.UserInputType == Enum.UserInputType.MouseMovement then
		v2 = true
	elseif session.dragKind == "Touch" then
		v2 = p == session.activeTouch
	else
		v2 = false
	end

	if not v2 then
		return
	end

	local vector2 = Vector2.new(p.Position.X, p.Position.Y)
	local v3 = vector2 - session.lastDragScreenPos
	session.lastDragScreenPos = vector2

	if v3.Magnitude < 1e-6 then
		return
	end

	local _dragRotationAngle = self:_dragRotationAngle(session, vector2, v3)

	if _dragRotationAngle == 0 then
		return
	end

	self:_rotateDirection(session, _dragRotationAngle)
end

function DuelLaunchAimClient:_dragRotationAngle(p, point: Vector2, point2: Vector2)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return point2.Y * 0.006108652381980153
	end

	local worldToScreenPoint, v2 = currentCamera:WorldToScreenPoint(p.ballMarker.WorldPosition)

	if not v2 then
		return point2.Y * 0.006108652381980153
	end

	local v3 = point - Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y)
	local v4 = v3.X * point2.Y - v3.Y * point2.X

	if v4 == 0 then
		return 0
	end

	return (v4 > 0 and 1 or -1) * point2.Magnitude * 0.006108652381980153
end

function DuelLaunchAimClient:_onInputEnded(p2)
	local session = self.session

	if not (session and session.dragging) then
		return
	end

	if session.dragKind == "Mouse" and (p2.UserInputType == Enum.UserInputType.MouseButton1 or p2.UserInputType == Enum.UserInputType.MouseButton2) then
		session.dragging = false
		session.dragKind = nil
		session.lastDragScreenPos = nil
	elseif session.dragKind == "Touch" and p2 == session.activeTouch then
		session.dragging = false
		session.dragKind = nil
		session.activeTouch = nil
		session.lastDragScreenPos = nil
	end
end

function DuelLaunchAimClient:_confirmLock()
	local session = self.session

	if not session or session.locked then
		return
	end

	session.locked = true
	self.launchButton:SetAttribute("AimLocked", true)
	self:_unbindGamepad()
	session.dragging = false
	self.lastDirectionByTable[session.tableModel] = session.direction

	if session.autoLockThread and session.autoLockThread ~= coroutine.running() then
		task.cancel(session.autoLockThread)
	end

	session.autoLockThread = nil
	self.launchButton.Visible = false
	self.launchDirectionRemote:FireServer(session.tableModel, session.direction)

	if self.onLocked then
		self.onLocked()
	end
end

function DuelLaunchAimClient:_bindGamepad()
	self:_unbindGamepad()
	local selectedObject = GuiService.SelectedObject
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	local _31 = playerGui and playerGui:FindFirstChild("战斗3选1")

	if selectedObject and _31 and selectedObject:IsDescendantOf(_31) then
		GuiService.SelectedObject = nil
	end

	ContextActionService:BindActionAtPriority("DuelAimConfirm", function(_, p)
		local session = self.session

		if not session or session.locked or GamepadSupport.IsBlocked() or GuiService.SelectedObject then
			self.gamepadConfirmArmed = false
			return Enum.ContextActionResult.Pass
		end

		if p == Enum.UserInputState.Begin then
			self.gamepadConfirmArmed = true
		elseif p == Enum.UserInputState.End then
			local gamepadConfirmArmed = self.gamepadConfirmArmed
			self.gamepadConfirmArmed = false

			if gamepadConfirmArmed then
				self:_confirmLock()
			end
		elseif p == Enum.UserInputState.Cancel then
			self.gamepadConfirmArmed = false
		end

		return Enum.ContextActionResult.Sink
	end, false, 3000, Enum.KeyCode.ButtonA)
	ContextActionService:BindActionAtPriority("DuelAimDirection", function(_, p, p2)
		if self.session and not (self.session.locked or GamepadSupport.IsBlocked() or GuiService.SelectedObject) then
			if p == Enum.UserInputState.Change or p == Enum.UserInputState.Begin then
				self:_applyGamepadDirection(Vector2.new(p2.Position.X, p2.Position.Y))
			end

			return Enum.ContextActionResult.Sink
		else
			return Enum.ContextActionResult.Pass
		end
	end, false, 3000, Enum.KeyCode.Thumbstick1)
end

function DuelLaunchAimClient:_unbindGamepad()
	self.gamepadConfirmArmed = false
	ContextActionService:UnbindAction("DuelAimConfirm")
	ContextActionService:UnbindAction("DuelAimDirection")
end

function DuelLaunchAimClient:_applyGamepadDirection(point: Vector2)
	local session = self.session
	local currentCamera = Workspace.CurrentCamera

	if not session or session.locked or GamepadSupport.IsBlocked() or GuiService.SelectedObject then
		return
	end

	if point.Magnitude <= 0.6 or not currentCamera then
		return
	end

	local worldPosition = session.ballMarker.WorldPosition
	local worldToViewportPoint = currentCamera:WorldToViewportPoint(worldPosition)
	local worldToViewportPoint2 = currentCamera:WorldToViewportPoint(worldPosition + session.arenaWorldX)
	local worldToViewportPoint3 = currentCamera:WorldToViewportPoint(worldPosition + session.arenaWorldY)

	if worldToViewportPoint.Z <= 0 or worldToViewportPoint2.Z <= 0 or worldToViewportPoint3.Z <= 0 then
		return
	end

	local screenDirection = GamepadSupport.ScreenDirection(
		Vector2.new(worldToViewportPoint2.X - worldToViewportPoint.X, worldToViewportPoint2.Y - worldToViewportPoint.Y),
		Vector2.new(worldToViewportPoint3.X - worldToViewportPoint.X, worldToViewportPoint3.Y - worldToViewportPoint.Y),
		point
	)

	if not screenDirection then
		return
	end

	local direction = session.direction
	session.direction = screenDirection
	session.dragging = false
	session.lastDragScreenPos = nil
	self:_applyArrowDirection(session)

	if self.onDirectionChanged then
		self.onDirectionChanged((math.acos((math.clamp(direction:Dot(screenDirection), -1, 1)))))
	end
end

return DuelLaunchAimClient