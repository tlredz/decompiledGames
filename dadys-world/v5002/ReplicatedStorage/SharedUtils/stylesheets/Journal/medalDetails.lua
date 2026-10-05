local MedalDetails = {}
MedalDetails.__index = MedalDetails

function MedalDetails.Init(_, helpers)
	local self = setmetatable({}, MedalDetails)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function MedalDetails:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local Debris = game:GetService("Debris")

	local function playSound(click, options)
		local clone = click:Clone()
		clone.Name = "Temp" .. clone.Name
		clone.Parent = click.Parent

		for k, v in pairs(options or {}) do
			if tweens.hasProperty(clone, k) then
				clone[k] = v
			end
		end

		clone:Play()
		Debris:AddItem(clone, click.TimeLength or 5)
	end

	function MedalDetails.base(data, object)
		tweens.saveInitials(data)
		local textButton = data.TextButton
		local parent = data.Parent.Parent
		local pinned = data.Pinned
		object:Apply(textButton, "Shared.Journal.textButton")
		object:Apply(pinned, "Shared.Journal.textButton")
		object:SetState(pinned, "active")

		local function updateRedeem()
			local redeemed = parent:GetAttribute("Redeemed")
			object:SetState(textButton, redeemed and "inactive" or "active")
			textButton.Title.Text = redeemed and "REDEEMED" or "REDEEM"

			if not (redeemed or parent:GetAttribute("CanRedeem")) then
				object:SetState(textButton, "inactive")
			end
		end

		parent:GetAttributeChangedSignal("Redeemed"):Connect(updateRedeem)
		parent:GetAttributeChangedSignal("CanRedeem"):Connect(updateRedeem)

		local function updatePinned()
			local pinned2 = parent:GetAttribute("Pinned")
			pinned.Title.Text = pinned2 and "UNPIN" or "PIN"
		end

		parent:GetAttributeChangedSignal("Pinned"):Connect(updatePinned)
		parent:GetAttributeChangedSignal("PreviewID"):Connect(function()
			local random = Random.new(tick())
			playSound(game.SoundService.UI.click, {
				PlaybackSpeed = random:NextNumber(1, 1.5)
			})
			tweens.playTween(data, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(tweens.getInitial(data, "Position").X.Scale, 0.475)
			})
			wait(0.15)
			tweens.playTween(data, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = tweens.getInitial(data, "Position")
			})
		end)
	end

	MedalDetails.states = {
		templateState = function(_, _) end
	}
	MedalDetails.flags = {
		templateFlag = function(_, _, _) end
	}
end

return MedalDetails