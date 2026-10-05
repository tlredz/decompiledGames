local TweenService = game:GetService("TweenService")
local AvatarPortraits = require(script.Parent.AvatarPortraits)
local VerifiedName = require(script.Parent.VerifiedName)
local RecapSoloWin = {}
RecapSoloWin.__index = RecapSoloWin

function RecapSoloWin.winner(p)
	if type(p.soloWinnerUserId) ~= "number" then
		return
	end

	for _, participant in p.participants do
		if participant.userId == p.soloWinnerUserId and participant.won == true and not participant.left and not participant.caught and participant.hasRun then
			return participant
		end
	end
end

function RecapSoloWin.new(frame, cue)
	return (setmetatable({
		frame = frame,
		cue = cue,
		portraits = AvatarPortraits.new(),
		tweens = {}
	}, RecapSoloWin))
end

function RecapSoloWin:hide()
	for _, tween in self.tweens do
		tween:Cancel()
	end

	table.clear(self.tweens)
	self.portraits:clear()
	self.frame.Visible = false
end

function RecapSoloWin:show(p)
	self:hide()
	local frame = self.frame
	frame.PlayerName.RichText = true
	frame.PlayerName.Text = VerifiedName.format(p.name, p.verified)
	frame.Visible = true
	frame.GroupTransparency = 1
	frame.RevealScale.Scale = 0.94
	self.portraits:bind(frame, p)
	local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0
	})
	local tween2 = TweenService:Create(
		frame.RevealScale,
		TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	table.insert(self.tweens, tween)
	table.insert(self.tweens, tween2)
	tween:Play()
	tween2:Play()
	self.cue("RecapOpen", 0.9)
end

function RecapSoloWin:destroy()
	self:hide()
	self.portraits:destroy()
end

return RecapSoloWin