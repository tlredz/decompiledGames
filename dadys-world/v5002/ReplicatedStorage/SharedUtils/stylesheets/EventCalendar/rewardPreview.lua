local RewardPreview = {}
RewardPreview.__index = RewardPreview

function RewardPreview.Init(_, helpers)
	local self = setmetatable({}, RewardPreview)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function RewardPreview:LoadStylesheet()
	local tweens = self.tweens

	function RewardPreview.base(instance, object)
		tweens.saveInitials(instance)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function follow()
			object:SetState(instance, instance:GetAttribute("OwnsSkin") and "claimed" or "unclaimed")
		end

		instance:GetAttributeChangedSignal("OwnsSkin"):Connect(follow)
		follow() -- equivalent call inferred; original call site unknown
	end

	RewardPreview.states = {
		claimed = function(p2)
			p2.Claimed.Visible = true
		end,
		unclaimed = function(p2)
			p2.Claimed.Visible = false
		end
	}
	RewardPreview.flags = {}
end

return RewardPreview