local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local BattleSimulation = require(battleDemo:WaitForChild("BattleSimulation"))
local BattleReplayBuilder = require(battleDemo:WaitForChild("BattleReplayBuilder"))
local cloneState = BattleReplayBuilder.cloneState
local ArenaOverride = require(battleDemo:WaitForChild("ArenaOverride"))
local StateInterpolator = require(script.Parent:WaitForChild("StateInterpolator"))
local BattlePlaybackController = {}
BattlePlaybackController.__index = BattlePlaybackController

local function formatResultMessage(winner: string?, matchPlayers)
	if winner ~= "Blue" and winner ~= "Yellow" then
		return "Draw"
	end

	local v = matchPlayers and matchPlayers[winner]
	local username = v and (v.username or v.name)

	if typeof(username) == "string" and username ~= "" then
		return string.format("%s Win", username)
	end

	return string.format("%s Win", winner)
end

function BattlePlaybackController.new(config, renderer)
	local object = setmetatable({}, BattlePlaybackController)
	object.config = config
	object.renderer = renderer
	object.simulation = nil
	object.previousState = nil
	object.currentState = nil
	object.matchPlayers = nil
	object.identificationStartTime = 0
	object.playbackStartTime = 0
	object.accumulatedTime = 0
	object.fixedDt = config.replay.fixedDt
	object.stepCount = 0
	object.maxSteps = math.max(1, (math.ceil(config.replay.maxDuration / config.replay.fixedDt)))
	object.maxStepsPerFrame = 8
	object.startedPlayback = false
	object.finishedPlayback = false
	object.onFinished = nil
	object.playbackSpeed = 1
	object.renderInterval = 1
	object._renderCountdown = 0
	object._pendingRenderEvents = {}
	object.paused = false
	object.connection = RunService.Heartbeat:Connect(function(dt: number)
		object:_update(dt)
	end)
	return object
end

function BattlePlaybackController:clear()
	self.simulation = nil
	self.previousState = nil
	self.currentState = nil
	self.matchPlayers = nil
	self.identificationStartTime = 0
	self.accumulatedTime = 0
	self.stepCount = 0
	self.startedPlayback = false
	self.finishedPlayback = false
	self.paused = false
	self._renderCountdown = 0
	self._pendingRenderEvents = {}
	self.renderer:setMatchPlayers(nil)
	self.renderer:setIdentityMarkersVisible(false)
	self.renderer:reset()
end

function BattlePlaybackController:loadReplay(data)
	local seed = tonumber(data.seed)

	if seed == nil then
		warn("[BattlePlaybackController] payload 缺少 seed，无法本地重建战斗")
		return
	end

	local replayOptions = data.replayOptions or {}
	self.fixedDt = tonumber(replayOptions.fixedDt) or self.config.replay.fixedDt
	self.maxSteps = math.max(
		1,
		(math.ceil((tonumber(replayOptions.maxDuration) or self.config.replay.maxDuration) / self.fixedDt))
	)
	self.simulation = BattleSimulation.new(
		ArenaOverride.resolveConfig(self.config, replayOptions.arena),
		seed,
		replayOptions.selectedRoles,
		replayOptions.selectedSecondaryTraits,
		replayOptions.statLevels,
		replayOptions.initialDirections
	)
	self.matchPlayers = data.players
	self.identificationStartTime = data.identificationStartTime or data.playbackStartTime or Workspace:GetServerTimeNow()
	self.playbackStartTime = data.playbackStartTime or Workspace:GetServerTimeNow()
	self.accumulatedTime = 0
	self.stepCount = 0
	self.startedPlayback = false
	self.finishedPlayback = false
	self.playbackSpeed = math.max(0.01, tonumber(data.playbackSpeed) or 1)
	self.maxStepsPerFrame = math.max(1, (math.ceil(8 * self.playbackSpeed)))
	self.paused = false
	self.renderer:setMatchPlayers(self.matchPlayers)
	self.renderer:setIdentityMarkersVisible(false)
	self.renderer:reset()
	self.renderer:setResult(nil, false)
	local state2 = cloneState(self.simulation:getState())
	self.previousState = state2
	self.currentState = state2
	self._renderCountdown = 0
	self._pendingRenderEvents = {}
	self.renderer:render(state2, {})
end

function BattlePlaybackController:setOnFinished(onFinished)
	self.onFinished = onFinished
end

function BattlePlaybackController:pause()
	self.paused = true
end

function BattlePlaybackController:setRenderInterval(p2: number)
	local renderInterval = math.max(1, (math.floor(p2)))

	if renderInterval == self.renderInterval then
		return
	end

	self.renderInterval = renderInterval
	self._renderCountdown = 0
end

function BattlePlaybackController:_finishPlayback(p)
	if self.finishedPlayback then
		return
	end

	self.finishedPlayback = true
	self.renderer:setResult(formatResultMessage(p.winner, self.matchPlayers), true)

	if self.onFinished then
		self.onFinished()
	end
end

function BattlePlaybackController:_update(p: number)
	if self.paused or not self.simulation then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.identificationStartTime then
		local v = math.max(0, self.identificationStartTime - serverTimeNow)
		self.renderer:setIdentityMarkersVisible(false)
		self.renderer:setTimerText("")
		self.renderer:setResult(string.format("Starting in %.1fs", v), true)
	elseif serverTimeNow < self.playbackStartTime then
		local v = math.max(1, (math.ceil(self.playbackStartTime - serverTimeNow - 0.05)))
		self.renderer:setIdentityMarkersVisible(true)
		self.renderer:setResult(nil, false)
		self.renderer:setTimerText(string.format("Battle Starts In %d", v))
	else
		local flag = false

		if self.startedPlayback then
			self.accumulatedTime += p * self.playbackSpeed
		else
			self.startedPlayback = true
			self.accumulatedTime = math.max(0, serverTimeNow - self.playbackStartTime) * self.playbackSpeed
			self.renderer:setIdentityMarkersVisible(false)
			self.renderer:setResult(nil, false)
			self.renderer:playCue("roundStart")
			flag = true
		end

		local maxSteps

		if flag then
			maxSteps = self.maxSteps
		else
			maxSteps = self.maxStepsPerFrame
		end

		local count = 0

		while self.accumulatedTime >= self.fixedDt and count < maxSteps and self.stepCount < self.maxSteps and not self.finishedPlayback do
			if count == 0 then
				self.previousState = self.currentState
			end

			local v, v2 = self.simulation:step(self.fixedDt)
			self.accumulatedTime -= self.fixedDt
			count += 1
			self.stepCount += 1

			for _, v3 in v2 do
				table.insert(self._pendingRenderEvents, v3)
			end

			if v.finished then
				break
			end
		end

		if count > 0 then
			self.currentState = cloneState(self.simulation:getState())
		end

		if not flag and self.maxStepsPerFrame <= count then
			self.accumulatedTime = 0
		end

		if not self.finishedPlayback and self.stepCount >= self.maxSteps then
			local state = self.simulation:getState()

			if not state.finished then
				state.finished = true
				state.winner = "Draw"
				table.insert(self._pendingRenderEvents, {
					type = "battle_end",
					winner = state.winner
				})
				self.currentState = cloneState(state)
			end
		end

		local v

		if self.currentState == nil then
			v = false
		else
			v = self.currentState.finished == true
		end

		if self._renderCountdown > 0 and not v then
			self._renderCountdown -= 1
		else
			self._renderCountdown = self.renderInterval - 1
			local v2 = v and 1 or math.clamp(self.accumulatedTime / self.fixedDt, 0, 1)
			local interpolated = StateInterpolator.interpolate(self.previousState, self.currentState, v2)

			if interpolated then
				self.renderer:render(interpolated, self._pendingRenderEvents)
			end

			table.clear(self._pendingRenderEvents)
		end

		if v then
			self:_finishPlayback(self.currentState)
		end
	end
end

function BattlePlaybackController.isPlaying(p)
	return p.simulation ~= nil and not p.finishedPlayback
end

function BattlePlaybackController:destroy()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

return BattlePlaybackController