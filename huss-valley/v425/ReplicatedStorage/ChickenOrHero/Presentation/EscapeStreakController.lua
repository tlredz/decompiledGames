local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local EscapeStreakController = {}
EscapeStreakController.__index = EscapeStreakController

function EscapeStreakController.new(p, session, player, colors)
	local escapeStreak = p.MainFrame.NotificationsF:WaitForChild("EscapeStreak")
	escapeStreak.Visible = false
	escapeStreak.GroupTransparency = 1
	return (setmetatable({
		view = escapeStreak,
		session = session,
		player = player,
		colors = colors,
		snapshot = {},
		raw = nil,
		count = 0,
		serial = 0,
		tweens = {},
		allowed = false,
		alive = true
	}, EscapeStreakController))
end

function EscapeStreakController:cancel()
	self.serial += 1

	for _, tween in self.tweens do
		tween:Cancel()
	end

	table.clear(self.tweens)

	if self.pulse then
		self.pulse:Cancel()
		self.pulse = nil
	end

	self.view.Count.TextTransparency = 0
end

function EscapeStreakController:tween(p2, duration, p3, p4)
	local tween = TweenService:Create(
		p2,
		TweenInfo.new(duration, p4 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		p3
	)
	table.insert(self.tweens, tween)
	tween:Play()
	return tween
end

function EscapeStreakController:hide()
	self:cancel()
	self.view.Visible = false
	self.view.GroupTransparency = 1
end

function EscapeStreakController:updateHint()
	local count = self.snapshot.count or 0
	local goal = self.snapshot.goal or 3

	if goal <= count then
		self.view.Hint.Text = "RUNNERS WIN!"
	elseif count == goal - 1 then
		self.view.Hint.Text = self.player:GetAttribute("GameRole") == "Catcher" and "Catch someone to break the streak!" or "One more clean escape to win!"
	else
		self.view.Hint.Text = ("Runners win at %d clean escapes in a row."):format(goal)
	end
end

function EscapeStreakController:show()
	local view = self.view
	local count = self.snapshot.count
	local goal = self.snapshot.goal
	local v = not view.Visible
	self:cancel()
	view.Visible = true
	view.Caption.Text = "CLEAN ESCAPES"
	view.Count.Text = ("%d/%d"):format(count, goal)
	local gold = count == goal - 1 and self.colors.Gold or self.colors.Mint
	view.Caption.TextColor3 = self.colors.Text
	view.Count.TextColor3 = gold
	view.Hint.TextColor3 = self.colors.Text

	if v then
		view.GroupTransparency = 1
		view.Reveal.Scale = 0.96

		for i = 1, 3 do
			view.Segments["Segment" .. i].Fill.Size = UDim2.fromScale(0, 1)
		end
	end

	self:tween(view, 0.22, {
		GroupTransparency = 0
	})
	self:tween(view.Reveal, 0.32, {
		Scale = 1
	}, Enum.EasingStyle.Back)

	for i = 1, 3 do
		local fill = view.Segments["Segment" .. i].Fill
		fill.BackgroundColor3 = gold
		self:tween(fill, 0.38, {
			Size = UDim2.fromScale(i <= count and 1 or 0, 1)
		})
	end

	self:updateHint()

	if count == goal - 1 then
		self.pulse = TweenService:Create(
			view.Count,
			TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				TextTransparency = 0.3
			}
		)
		self.pulse:Play()
	end
end

function EscapeStreakController:broken(p)
	local view = self.view
	self:cancel()
	local serial = self.serial
	view.Visible = true
	view.GroupTransparency = 0
	view.Reveal.Scale = 1
	view.Caption.Text = p == "RunnerLeft" and "ESCAPE STREAK RESET" or "ESCAPE STREAK BROKEN"
	view.Caption.TextColor3 = self.colors.Text
	view.Count.Text = "0/" .. tostring(self.snapshot.goal or 3)
	view.Count.TextColor3 = self.colors.Text
	view.Hint.Text = p == "RunnerLeft" and "A runner left the match." or "Build another streak next round."

	for i = 1, 3 do
		self:tween(view.Segments["Segment" .. i].Fill, 0.3, {
			Size = UDim2.fromScale(0, 1)
		})
	end

	task.delay(1, function()
		if not self.alive or self.serial ~= serial then
			return
		end

		self:tween(view, 0.35, {
			GroupTransparency = 1
		})
		task.delay(0.35, function()
			if self.alive and self.serial == serial then
				view.Visible = false
			end
		end)
	end)
end

function EscapeStreakController:update(p)
	local escapeStreakState = self.session:GetAttribute("EscapeStreakState")
	local v = escapeStreakState ~= self.raw
	local matchId = self.snapshot.matchId

	if v then
		self.raw = escapeStreakState
		local success, result = pcall(HttpService.JSONDecode, HttpService, escapeStreakState or "{}")
		self.snapshot = (not success or type(result) ~= "table" or not result) and {} or result
	end

	local snapshot = self.snapshot
	local count = snapshot.count or 0
	local v2

	if self.player:GetAttribute("InMatch") == true and self.player:GetAttribute("GameRole") ~= "Lobby" and p ~= "Lobby" and p ~= "Countdown" and p ~= "FinalRun" then
		v2 = p ~= "Results" or snapshot.event == "Won"
	else
		v2 = false
	end

	if v2 then
		if v or not self.allowed then
			if matchId ~= snapshot.matchId then
				self:hide()
				self.count = 0
			end

			if count > 0 then
				self:show()
			elseif self.count > 0 and (snapshot.event == "Broken" or snapshot.event == "RunnerLeft" or snapshot.event == "Interrupted") then
				self:broken(snapshot.event)
			else
				self:hide()
			end
		end

		self.allowed = true
		self.count = count

		if count > 0 then
			self:updateHint()
		end
	else
		if self.allowed or self.view.Visible then
			self:hide()
		end

		self.allowed = false
		self.count = count
	end
end

function EscapeStreakController:destroy()
	self.alive = false
	self:hide()
end

return EscapeStreakController