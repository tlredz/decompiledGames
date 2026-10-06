local createVector = vector.create
local VisualRenderer = require(script.VisualRenderer)
local AudioSystem = require(script.AudioSystem)
local IdentityLayer = require(script.IdentityLayer)
local HudOverlay = require(script.HudOverlay)
local BattleRenderer = {}
BattleRenderer.__index = BattleRenderer

function BattleRenderer.getArenaCFrame(p, position: Vector3)
	local planeRotation = p.arena.planeRotation or createVector(0, 0, 0)
	return CFrame.new(position) * CFrame.Angles(
		math.rad(planeRotation.X),
		math.rad(planeRotation.Y),
		(math.rad(planeRotation.Z))
	)
end

function BattleRenderer.new(config, data)
	local object = setmetatable({}, BattleRenderer)
	local ctx = {
		config = config,
		instanceId = not data and "Default" or data.instanceId or "Default",
		arenaCenter = data and data.arenaCenter or config.arena.worldCenter,
		arenaCFrame = data and data.arenaCFrame or BattleRenderer.getArenaCFrame(
			config,
			data and data.arenaCenter or config.arena.worldCenter
		),
		arenaScale = not data and 1 or data.arenaScale or 1,
		audioMode = not data and "spatial" or data.audioMode or "spatial",
		skipBoard = 0,
		hideUI = 0,
		showBallHealth = 0,
		hideBallHealth = 0,
		mutedCues = 0,
		onCameraImpact = 0,
		showLaunchArrows = 0,
		soundGroup = 0,
		rootFolder = nil
	}
	local skipBoard

	if data then
		skipBoard = data.skipBoard or false
	else
		skipBoard = false
	end

	ctx.skipBoard = skipBoard
	local hideUI

	if data then
		hideUI = data.hideUI or false
	else
		hideUI = false
	end

	ctx.hideUI = hideUI
	local showBallHealth

	if data then
		showBallHealth = data.showBallHealth or false
	else
		showBallHealth = false
	end

	ctx.showBallHealth = showBallHealth
	local hideBallHealth

	if data then
		hideBallHealth = data.hideBallHealth or false
	else
		hideBallHealth = false
	end

	ctx.hideBallHealth = hideBallHealth
	ctx.mutedCues = data and data.mutedCues
	ctx.onCameraImpact = data and data.onCameraImpact
	local showLaunchArrows

	if data then
		showLaunchArrows = data.showLaunchArrows or false
	else
		showLaunchArrows = false
	end

	ctx.showLaunchArrows = showLaunchArrows
	ctx.soundGroup = data and data.soundGroup
	object._ctx = ctx
	object._visual = VisualRenderer.new(ctx)
	object._audio = AudioSystem.new(ctx)
	object._identity = IdentityLayer.new(ctx)
	object._hud = HudOverlay.new(ctx)
	object._visual:bind(object._audio, object._identity)

	if data and data.parent then
		ctx.rootFolder.Parent = data.parent
	end

	object._hiddenGuis = {}

	if ctx.hideUI then
		local function register(instance)
			if instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
				if ctx.showBallHealth and instance.Name == "HealthBillboard" then
					return
				end

				object._hiddenGuis[instance] = true
				instance.Enabled = false
			end
		end

		for _, descendant in ctx.rootFolder:GetDescendants() do
			if not ((descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui")) and (not ctx.showBallHealth or descendant.Name ~= "HealthBillboard")) then
				continue
			end

			object._hiddenGuis[descendant] = true
			descendant.Enabled = false
		end

		object._uiAdded = ctx.rootFolder.DescendantAdded:Connect(register)
		object._uiRemoved = ctx.rootFolder.DescendantRemoving:Connect(function(descendant)
			object._hiddenGuis[descendant] = nil
		end)
	end

	object:reset()
	return object
end

function BattleRenderer:setAudioMode(p2: string)
	self._audio:setAudioMode(p2)
end

function BattleRenderer:playCue(p2: string, vector2: Vector3?)
	if self._ctx.mutedCues and self._ctx.mutedCues[p2] then
		return
	end

	self._audio:playCue(p2, vector2)
end

function BattleRenderer:setParticipantView(flag: boolean, p2: string)
	self._identity:setParticipantView(flag, p2)
	self._hud:setParticipantView(flag, p2)
end

function BattleRenderer:setLocalParticipantSlot(p2: string?)
	self._identity:setLocalParticipantSlot(p2)
	self._visual:setLocalParticipantSlot(p2)
end

function BattleRenderer:setForceHighlightAllEnemies(flag: boolean)
	self._visual:setForceHighlightAllEnemies(flag)
end

function BattleRenderer:setMatchPlayers(p2)
	self._identity:setMatchPlayers(p2)
end

function BattleRenderer:setIdentityMarkersVisible(flag: boolean)
	self._identity:setIdentityMarkersVisible(flag)
end

function BattleRenderer:setResult(p2: string?, flag: boolean)
	self._hud:setResult(p2, flag)
end

function BattleRenderer:setTimerText(p2: string)
	self._hud:setTimerText(p2)
end

function BattleRenderer:render(p, p2)
	self._visual:renderBalls(p)
	local v = self._ctx.config.replay.maxDuration - p.elapsed

	if v <= self._ctx.config.replay.finalDisplaySecs then
		self._hud:setTimerText(string.format("Time %.1fs", (math.max(0, v))))
	else
		self._hud:setTimerText("")
	end

	self._visual:playEvents(p2)

	for k in self._hiddenGuis do
		k.Enabled = false
	end
end

function BattleRenderer:reset()
	self._visual:reset()
	self._identity:reset()
	self._hud:reset()
end

function BattleRenderer:destroy()
	if self._uiAdded then
		self._uiAdded:Disconnect()
	end

	if self._uiRemoved then
		self._uiRemoved:Disconnect()
	end

	table.clear(self._hiddenGuis)
	self._audio:destroy()
	self._hud:destroy()
	self._visual:destroy()
	self._identity:destroy()
end

function BattleRenderer:pluckFirstBallForTeam(p2: string)
	return self._visual:pluckFirstBallForTeam(p2)
end

function BattleRenderer:pluckAllBallsForOwner(p2: string)
	return self._visual:pluckAllBallsForOwner(p2)
end

function BattleRenderer:pluckBall(p2: string)
	return self._visual:pluckBall(p2)
end

function BattleRenderer:pluckAllBallsForTeam(p2: string)
	return self._visual:pluckAllBallsForTeam(p2)
end

function BattleRenderer:getLastVanishedBallPosition(p2: string)
	return self._visual:getLastVanishedBallPosition(p2)
end

function BattleRenderer:destroyTeamBalls(p2: string)
	self._visual:destroyTeamBalls(p2)
end

return BattleRenderer