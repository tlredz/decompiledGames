local TweenService = game:GetService("TweenService")
local AvatarPortraits = require(script.Parent.AvatarPortraits)
local VerifiedName = require(script.Parent.VerifiedName)
local RecapHighlights = {}
RecapHighlights.__index = RecapHighlights
local v = {
	{
		key = "mvp",
		title = "MATCH MVP",
		color = Color3.fromRGB(255, 205, 112),
		empty = "No scoring actions this match"
	},
	{
		key = "survival",
		title = "LONGEST SURVIVAL",
		color = Color3.fromRGB(107, 226, 186),
		empty = "No Runner time recorded"
	},
	{
		key = "catches",
		title = "MOST CATCHES",
		color = Color3.fromRGB(255, 130, 136),
		empty = "Everyone got away"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function timeText(p)
	local v2 = math.max(0, math.floor(p * 10 + 0.5) / 10)
	return v2 >= 60 and ("%dm %04.1fs"):format(math.floor(v2 / 60), v2 % 60) or ("%.1fs"):format(v2)
end

function RecapHighlights.new(panel, cfg, cue)
	local object = setmetatable({
		panel = panel,
		cfg = cfg,
		cue = cue,
		portraits = AvatarPortraits.new(),
		cards = {},
		connections = {},
		tweens = {},
		revision = 0
	}, RecapHighlights)

	for k, v2 in { "First", "Second", "Third" } do
		local view = panel.Stage[v2]
		object.cards[k] = {
			view = view,
			position = view.Position
		}
	end

	for k, v2 in v do
		local tab = panel.Tabs[v2.key]
		local manual = k
		table.insert(object.connections, tab.Activated:Connect(function()
			if object.active then
				object.manual = manual
				object.manualUntil = workspace:GetServerTimeNow() + cfg.StageSeconds
				object:setStage(manual, workspace:GetServerTimeNow())
			end
		end))
	end

	return object
end

function RecapHighlights:cancel()
	self.revision += 1

	for _, tween in self.tweens do
		tween:Cancel()
	end

	table.clear(self.tweens)
	self.portraits:clear()
end

function RecapHighlights:tween(p2, duration, p3, p4)
	local tween = TweenService:Create(
		p2,
		TweenInfo.new(duration, p4 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		p3
	)
	table.insert(self.tweens, tween)
	tween:Play()
end

function RecapHighlights:setStage(p, stageAt)
	if self.index == p then
		return
	end

	self:cancel()
	self.index = p
	self.stageAt = stageAt
	local revision = self.revision
	local v2 = v[p]
	local v3 = self.data.rankings[v2.key] or {}
	self.panel.StageTitle.Text = v2.title
	self.panel.StageTitle.TextColor3 = v2.color
	self.panel.Stage.GroupTransparency = 1
	self:tween(self.panel.Stage, self.cfg.StageFade, {
		GroupTransparency = 0
	})
	self.panel.Stage.Empty.Text = v2.empty
	self.panel.Stage.Empty.Visible = #v3 == 0

	for k, card in self.cards do
		local view = card.view
		local v4 = v3[k]
		local v5 = v4 and self.rows[v4.userId]
		card.award = v5 and v4 or nil
		view.Visible = v5 ~= nil
		view.Position = card.position
		self.portraits:bind(view, v5)

		if not v5 then
			continue
		end

		view.PlayerName.RichText = true
		view.PlayerName.Text = VerifiedName.format(v5.name, v5.verified)
		view.Rank.Text = (v4.tiedCount > 1 and "JOINT #" or "#") .. v4.rank
		view.Rank.TextColor3 = v2.color
		view.Metric.TextColor3 = v2.color
		view.Metric.Text = ""
		view.GroupTransparency = 1
		view.Position = UDim2.fromScale(k == 1 and 0.5 or k == 2 and 0.37 or 0.63, card.position.Y.Scale + 0.025)
		local view2 = view
		local v7 = card

		local function reveal()
			if not self.active or revision ~= self.revision then
				return
			end

			self:tween(view2, 0.32, {
				Position = v7.position,
				GroupTransparency = 0
			}, Enum.EasingStyle.Back)
		end

		if k == 1 then
			reveal()
		else
			task.delay(self.cfg.SideRevealDelay, reveal)
		end
	end

	for k, v4 in v do
		local tab = self.panel.Tabs[v4.key]
		tab.TextColor3 = k == p and v2.color or Color3.fromRGB(159, 177, 190)
		tab.Underline.BackgroundColor3 = v2.color
		tab.Underline.Visible = k == p
	end

	self.cue("RecapOpen")
end

function RecapHighlights:show(p, p2)
	self.active = true
	self.data = p
	self.rows = {}
	self.index = nil
	self.manual = nil

	for _, participant in p.participants do
		self.rows[participant.userId] = participant
	end

	self:update(p2)
end

function RecapHighlights:update(p)
	if not self.active then
		return
	end

	local manual = math.clamp(math.floor(math.max(0, p - self.data.shownAt) / self.cfg.StageSeconds) + 1, 1, #v)

	if self.manual and p < self.manualUntil then
		manual = self.manual
	else
		self.manual = nil
	end

	self:setStage(manual, p)
	local v2 = 1 - (1 - math.clamp((p - self.stageAt) / 0.9, 0, 1)) ^ 3
	local key = v[manual].key

	for _, card in self.cards do
		if not card.award then
			continue
		end

		local v3 = key == "survival" and 10 or 1
		local v4 = math.floor(card.award.value * v2 * v3 + 0.5) / v3
		local metric = card.view.Metric
		local text = key == "mvp" and v4 .. " XP"

		if not text then
			if key == "survival" then
				text = timeText(v4)

				if not text then
					text = v4 .. " " .. (v4 == 1 and "CATCH" or "CATCHES")
				end
			else
				text = v4 .. " " .. (v4 == 1 and "CATCH" or "CATCHES")
			end
		end

		metric.Text = text
	end
end

function RecapHighlights:hide()
	self.active = false
	self:cancel()
end

function RecapHighlights:destroy()
	self:hide()
	self.portraits:destroy()

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return RecapHighlights