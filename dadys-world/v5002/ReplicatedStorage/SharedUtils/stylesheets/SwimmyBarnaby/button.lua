local Button = {}
Button.__index = Button

function Button.Init(_, helpers)
	local self = setmetatable({}, Button)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Button:LoadStylesheet()
	local tweens = self.tweens

	local function colorAll(folder, items, color)
		for _, descendant in pairs(folder:GetDescendants()) do
			for _, item in pairs(items) do
				if tweens.hasProperty(descendant, item) then
					descendant[item] = color
				end
			end
		end
	end

	function Button.base(instance, object)
		tweens.saveInitials(instance)
		instance:SetAttribute("Hovered", false)
		object:AddConnection(instance, "mouse", instance.MouseEnter:Connect(function()
			instance:SetAttribute("Hovered", true)
		end))
		object:AddConnection(instance, "mouse", instance.MouseLeave:Connect(function()
			instance:SetAttribute("Hovered", false)
		end))
	end

	Button.states = {
		active = function(_, _) end,
		inactive = function(_, _) end
	}
	Button.flags = {
		Hovered = function(instance, p2, _)
			local selected = instance:FindFirstChild("Selected")

			if p2 then
				if selected then
					selected.Visible = true
				end

				for _, frame in pairs(instance.Parent:GetChildren()) do
					if frame:IsA("Frame") and frame ~= instance then
						colorAll(frame, { "ImageColor3", "TextColor3" }, Color3.fromRGB(203, 203, 203))
					end
				end

				colorAll(instance, { "ImageColor3", "TextColor3" }, Color3.fromRGB(255, 255, 255))
			else
				if selected then
					selected.Visible = false
				end

				colorAll(instance, { "ImageColor3", "TextColor3" }, Color3.fromRGB(203, 203, 203))
			end
		end
	}
end

return Button