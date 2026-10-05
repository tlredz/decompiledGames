local Countdown = {}
Countdown.__index = Countdown

function Countdown.Init(_, helpers)
	local self = setmetatable({}, Countdown)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Countdown:LoadStylesheet()
	local tweens = self.tweens

	function Countdown.base(p2)
		tweens.saveInitials(p2)
	end

	Countdown.states = {
		counting = function(instance)
			local sevenSegmentDisplay = require(game.ReplicatedStorage.SharedUtils.sevenSegmentDisplay)
			local v = sevenSegmentDisplay.new(instance.Digits)

			local function toDigits(p2: number)
				local v2 = math.max(0, (math.floor(p2)))
				local v3 = v2 // 86400
				local v4 = v2 % 86400 // 3600
				local v5 = v2 % 3600 // 60
				local v6 = v2 % 60

				if v2 > 359999 then
					instance:SetAttribute("IS_HMS", false)
					return string.format("%02d%02d%02d", v3, v4, v5)
				end

				instance:SetAttribute("IS_HMS", true)
				return string.format("%02d%02d%02d", v3 * 24 + v4, v5, v6)
			end

			local function updateTimerText()
				local eventDay = instance:GetAttribute("EventDay") or -2
				local timeUntilNextDay = instance:GetAttribute("TimeUntilNextDay") or 0

				if eventDay <= 0 then
					instance.TimeLeftHeader.Text = "Calendar starts in:"
					v:setNumber(toDigits(timeUntilNextDay + math.abs(eventDay) * 86400))
				else
					instance.TimeLeftHeader.Text = "Next day starts in:"
					v:setNumber(toDigits(timeUntilNextDay))
				end
			end

			local function updateUnitLabels()
				local IS_HMS = instance:GetAttribute("IS_HMS") == true
				local details = instance.Details
				details.HourLabel.Text = IS_HMS and "HOUR" or "DAY"
				details.Display.HourLabel.Text = IS_HMS and "HOUR" or "DAY"
				details.MinuteLabel.Text = IS_HMS and "MIN" or "HOUR"
				details.Display.MinuteLabel.Text = IS_HMS and "MIN" or "HOUR"
				details.SecondLabel.Text = IS_HMS and "SEC" or "MIN"
				details.Display.SecondLabel.Text = IS_HMS and "SEC" or "MIN"
			end

			instance:GetAttributeChangedSignal("TimeUntilNextDay"):Connect(updateTimerText)
			instance:GetAttributeChangedSignal("EventDay"):Connect(updateTimerText)
			instance:GetAttributeChangedSignal("IS_HMS"):Connect(updateUnitLabels)
			updateUnitLabels()
			instance.MouseEnter:Connect(function()
				if not instance:FindFirstChild("UIScale") then
					return
				end

				tweens.playTween(instance.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Elastic), {
					Scale = 1.35
				})
				instance.Details.Visible = true

				for _, label in ipairs(instance.Details:GetDescendants()) do
					if not label:IsA("TextLabel") then
						continue
					end

					label.Visible = true
					label.TextTransparency = 1
					tweens.playTween(label, TweenInfo.new(0.15), {
						TextTransparency = label:GetAttribute(tweens.initialPrefix .. "TextTransparency")
					})
				end

				tweens.playTween(instance.TextButton.Title.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Elastic), {
					Thickness = 0.05
				})
			end)
			instance.MouseLeave:Connect(function()
				if not instance:FindFirstChild("UIScale") then
					return
				end

				tweens.playTween(instance.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Elastic), {
					Scale = 1
				})
				instance.Details.Visible = false

				for _, label in ipairs(instance.Details:GetDescendants()) do
					if not label:IsA("TextLabel") then
						continue
					end

					label.Visible = false
					label.TextTransparency = 1
				end

				tweens.playTween(instance.TextButton.Title.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Elastic), {
					Thickness = 0.1
				})
			end)
		end
	}
	Countdown.flags = {}
end

return Countdown