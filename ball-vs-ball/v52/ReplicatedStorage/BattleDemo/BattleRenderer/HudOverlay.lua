local Players = game:GetService("Players")
local HudOverlay = {}
HudOverlay.__index = HudOverlay

function HudOverlay.new(ctx)
	local object = setmetatable({}, HudOverlay)
	object._ctx = ctx
	object.config = ctx.config
	object.arenaCFrame = ctx.arenaCFrame
	object.arenaScale = ctx.arenaScale
	object.instanceId = ctx.instanceId
	object.rootFolder = ctx.rootFolder
	object.screenGui = nil
	object.hudTimerFrame = nil
	object.hudTimerLabel = nil
	object.currentTimerText = ""
	object.currentResultText = ""
	object.currentResultVisible = false
	object.isLocalParticipant = false
	object.participantTableState = "Idle"
	object:_buildScreenUi()
	return object
end

function HudOverlay._worldFromArena(p, point: Vector2, value: number?)
	return p.arenaCFrame:PointToWorldSpace((Vector3.new(
		point.X * p.arenaScale,
		point.Y * p.arenaScale,
		-(value or 0) * p.arenaScale
	)))
end

function HudOverlay:_buildScreenUi()
	if self._ctx.hideUI then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local UI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("战斗匹配UI")
	local v = UI:WaitForChild("Background"):WaitForChild("对战信息层"):WaitForChild("时间文本")
	self.screenGui = UI
	self.hudTimerFrame = v
	self.hudTimerLabel = v
end

function HudOverlay:_refreshStatusVisibility()
	if not self.isLocalParticipant then
		return
	end

	local isLocalParticipant = self.isLocalParticipant

	if isLocalParticipant then
		if self.participantTableState == "Playing" or self.participantTableState == "Identification" then
			isLocalParticipant = self.currentTimerText ~= ""
		else
			isLocalParticipant = false
		end
	end

	if self.hudTimerLabel then
		self.hudTimerLabel.Text = self.currentTimerText
	end

	if self.hudTimerFrame then
		self.hudTimerFrame.Visible = isLocalParticipant
	end
end

function HudOverlay:setParticipantView(isLocalParticipant: boolean, participantTableState: string)
	self.isLocalParticipant = isLocalParticipant
	self.participantTableState = participantTableState
	self:_refreshStatusVisibility()
end

function HudOverlay:setResult(value: string?, currentResultVisible: boolean)
	self.currentResultVisible = currentResultVisible
	self.currentResultText = value or ""
	self:_refreshStatusVisibility()
end

function HudOverlay:setTimerText(currentTimerText: string)
	local v = tonumber(currentTimerText) or tonumber(string.match(currentTimerText, "[%d%.]+"))

	if v then
		currentTimerText = string.format("⏱%.1fs", v)
	end

	self.currentTimerText = currentTimerText
	self:_refreshStatusVisibility()
end

function HudOverlay:reset()
	self:setTimerText("")
	self:setResult(nil, false)
end

function HudOverlay:destroy()
	self.screenGui = nil
	self.hudTimerFrame = nil
	self.hudTimerLabel = nil
end

return HudOverlay