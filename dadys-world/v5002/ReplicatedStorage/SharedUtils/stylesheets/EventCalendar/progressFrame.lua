local ProgressFrame = {}
ProgressFrame.__index = ProgressFrame
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function ProgressFrame.Init(_, helpers)
	local self = setmetatable({}, ProgressFrame)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function ProgressFrame:LoadStylesheet()
	local tweens = self.tweens

	local function setBar(p2, value: number?, flag: boolean)
		local v = math.ceil(value or 0)
		local uIGradient = p2.UIGradient
		local progressStart = uIGradient:GetAttribute("progressStart")
		local offset = progressStart + (uIGradient:GetAttribute("progressEnd") - progressStart) * (v / 100)

		if v == 0 or not flag then
			uIGradient.Offset = offset
		else
			tweens.playTween(uIGradient, tweenInfo, {
				Offset = offset
			})
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setBars(p2, progress: number?, flag: boolean)
		setBar(p2.fill, progress, flag)
		setBar(p2.empty, progress, flag)
	end

	function ProgressFrame.base(instance)
		tweens.saveInitials(instance)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update(flag: boolean)
			local progress = instance:GetAttribute("Progress") or 0
			setBars(instance, progress, flag) -- equivalent call inferred; original call site unknown

			if string.find(instance.TextLabel.Text, "%%") then
				instance.TextLabel.Text = math.ceil(progress) .. "%"
			end
		end

		task.delay(1, update, false)
		instance:GetAttributeChangedSignal("Progress"):Connect(function()
			update(true) -- equivalent call inferred; original call site unknown
		end)
	end

	ProgressFrame.states = {
		animate = function(instance, object)
			setBars(instance, 0, true) -- equivalent call inferred; original call site unknown
			task.wait(0.1)
			setBars(instance, instance:GetAttribute("Progress"), true) -- equivalent call inferred; original call site unknown
			task.wait(0.5)
			object:SetState(instance, "idle")
		end,
		idle = function() end
	}
	ProgressFrame.flags = {}
end

return ProgressFrame