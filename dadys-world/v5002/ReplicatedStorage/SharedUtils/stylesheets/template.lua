local Template = {}
Template.__index = Template

function Template.Init(_, helpers)
	local self = setmetatable({}, Template)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Template:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Template.base(p2, _)
		tweens.saveInitials(p2)
	end

	Template.states = {
		templateState = function(_, _) end
	}
	Template.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Template