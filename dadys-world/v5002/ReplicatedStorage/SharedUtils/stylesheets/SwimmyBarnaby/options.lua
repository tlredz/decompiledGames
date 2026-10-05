local Options = {}
Options.__index = Options

function Options.Init(_, helpers)
	local self = setmetatable({}, Options)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Options:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	local function colorAll(folder, items, color)
		for _, descendant in pairs(folder:GetDescendants()) do
			for _, item in pairs(items) do
				if tweens.hasProperty(descendant, item) then
					descendant[item] = color
				end
			end
		end
	end

	function Options.base(instance, object)
		tweens.saveInitials(instance)
		instance:SetAttribute("Hovered", false)
		object:AddConnection(instance, "mouse", instance.MouseEnter:Connect(function()
			instance:SetAttribute("Hovered", true)
		end))
		object:AddConnection(instance, "mouse", instance.MouseLeave:Connect(function()
			instance:SetAttribute("Hovered", false)
		end))
	end

	Options.states = {
		active = function(_, _) end,
		inactive = function(_, _) end
	}
	Options.flags = {
		Hovered = function(instance, p2, _)
			local selected = instance:FindFirstChild("Selected")

			if p2 then
				if selected then
					selected.Visible = true
				end
			else
				if selected then
					selected.Visible = false
				end

				colorAll(instance, { "ImageColor3", "TextColor3" }, Color3.fromRGB(255, 255, 255))
			end
		end
	}
end

return Options