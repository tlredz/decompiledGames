local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ValleyTheme = require(script.Parent.ValleyTheme)
local NotificationDock = require(script.Parent.NotificationDock)
local CrossingBalanceNotice = {}
CrossingBalanceNotice.__index = CrossingBalanceNotice

local function metric(p, value, baseline)
	local v = math.round(p * 10) / 10

	if math.abs(v) < 0.05 then
		return baseline and "Standard " .. value or value:sub(1, 1):upper() .. value:sub(2) .. " unchanged"
	end

	return ("%+.1f%% %s"):format(v, value)
end

function CrossingBalanceNotice.describe(data)
	local v = metric(data.speed, "speed", data.baseline)
	local v2 = metric(data.acceleration, "acceleration", data.baseline)
	local v3 = math.round(data.turning * 10) / 10
	local v4 = data.role:upper() .. " · " .. (data.baseline and "TEAM BALANCE" or "CROSSING UPDATE")

	if v3 >= 0.1 then
		v4 ..= " · SHARPER TURNS"
	elseif v3 <= -0.1 then
		v4 ..= " · TURNING RESET"
	end

	return v4, v .. "  ·  " .. v2
end

function CrossingBalanceNotice.new(gui, player)
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "CrossingBalanceNotice"
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0)
	canvasGroup.Size = UDim2.fromOffset(520, 44)
	canvasGroup.Visible = false
	canvasGroup.GroupTransparency = 1
	canvasGroup.Active = false
	canvasGroup.Parent = gui.MainFrame

	local function label(name, p3, font, textColor, p4, p5)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = name
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 0, p5)
		textLabel.Position = UDim2.fromOffset(0, p4)
		textLabel.Font = font
		textLabel.TextSize = p3
		textLabel.TextScaled = true
		textLabel.TextColor3 = textColor
		textLabel.TextStrokeColor3 = ValleyTheme.Ink
		textLabel.TextStrokeTransparency = 0.55
		textLabel.Text = ""
		textLabel.Active = false
		textLabel.Parent = canvasGroup
		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.MinTextSize = 9
		uITextSizeConstraint.MaxTextSize = p3
		uITextSizeConstraint.Parent = textLabel
		return textLabel
	end

	return (setmetatable({
		gui = gui,
		frame = canvasGroup,
		caption = label("Caption", 10, Enum.Font.GothamMedium, ValleyTheme.Muted, 0, 14),
		stats = label("Stats", 16, Enum.Font.GothamBold, ValleyTheme.Paper, 18, 22),
		player = player
	}, CrossingBalanceNotice))
end

function CrossingBalanceNotice:hide(p)
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end

	self.showing = false

	if p then
		self.frame.Visible = false
		self.frame.GroupTransparency = 1
	else
		local tween = TweenService:Create(self.frame, TweenInfo.new(0.22), {
			GroupTransparency = 1
		})
		self.tween = tween
		tween.Completed:Once(function(p2)
			if self.tween == tween and p2 == Enum.PlaybackState.Completed then
				self.frame.Visible = false
				self.tween = nil
			end
		end)
		tween:Play()
	end
end

function CrossingBalanceNotice:update(p)
	local player = self.player
	local serverTimeNow = workspace:GetServerTimeNow()
	local crossingBalanceNotice = player:GetAttribute("CrossingBalanceNotice")

	if crossingBalanceNotice ~= self.raw then
		self.raw = crossingBalanceNotice
		self:hide(true)
		self.pending = nil
		local success, result = pcall(HttpService.JSONDecode, HttpService, crossingBalanceNotice or "")

		if success and type(result) == "table" and type(result.speed) == "number" and type(result.acceleration) == "number" and type(result.turning) == "number" and type(result.expiresAt) == "number" and (result.role == "Runner" or result.role == "Catcher") then
			self.pending = result
		end
	end

	if player:GetAttribute("InMatch") == true and player:GetAttribute("GameRole") ~= "Lobby" and p ~= "Results" and p ~= "Intermission" then
		if player:GetAttribute("ScreenPresentationActive") or player:GetAttribute("GlobalWheelOpen") or player:GetAttribute("MatchSummaryVisible") or self.gui.MainFrame.Choices.Visible then
			self:hide(true)
			return
		end

		if self.pending and self.pending.expiresAt <= serverTimeNow then
			self.pending = nil
		end

		if self.pending then
			local pending = self.pending
			self.pending = nil

			if self.tween then
				self.tween:Cancel()
				self.tween = nil
			end

			local caption = self.caption
			local stats = self.stats
			local describe, text = CrossingBalanceNotice.describe(pending)
			caption.Text = describe
			stats.Text = text
			self.stats.TextColor3 = pending.role == "Runner" and ValleyTheme.Blue or ValleyTheme.Paper
			self.untilAt = serverTimeNow + 3.2
			self.showing = true
			self.frame.Visible = true
			self.frame.GroupTransparency = 1
			self.tween = TweenService:Create(self.frame, TweenInfo.new(0.18), {
				GroupTransparency = 0
			})
			self.tween:Play()
		end

		if self.showing and self.untilAt <= serverTimeNow then
			self:hide(false)
		end

		if self.frame.Visible then
			local mainFrame = self.gui.MainFrame
			self.frame.Position = UDim2.new(0.5, 0, 0, NotificationDock.bottom(self.gui.Parent, mainFrame))
			self.frame.Size = UDim2.fromOffset(math.min(mainFrame.AbsoluteSize.X - 28, 520), 44)
		end
	else
		self.pending = nil
		self:hide(true)
	end
end

function CrossingBalanceNotice:destroy()
	self:hide(true)
	self.frame:Destroy()
end

return CrossingBalanceNotice