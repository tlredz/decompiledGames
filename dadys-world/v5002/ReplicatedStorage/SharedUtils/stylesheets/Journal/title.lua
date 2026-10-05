local Title = {}
Title.__index = Title

function Title.Init(_, helpers)
	local self = setmetatable({}, Title)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Title:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Title.base(instance, object)
		tweens.saveInitials(instance)
		local difficulty = instance:GetAttribute("Difficulty")
		local child = instance.Display:FindFirstChild(difficulty)

		if child then
			for _, image in pairs(instance.Display:GetChildren()) do
				if image:IsA("ImageLabel") then
					image.Visible = false
				end
			end

			child.Visible = true
		end

		object:Apply(instance.Pinned, "Shared.Journal.pin")
		object:Apply(instance.TextButton, "Shared.Journal.textButton")
	end

	Title.states = {
		equipped = function(data, object)
			tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1.045
			})

			for _, frame in pairs(data.Parent:GetChildren()) do
				if frame:IsA("Frame") and frame ~= data then
					object:SetState(frame, "unEquipped")
				end
			end

			data.TextButton.Inactive.Visible = true
			data.TextButton.Title.Text = "EQUIPPED"
			data.Display.Equipped.Visible = true
			data.Fade.Visible = true
			object:SetState(data.Pinned, "open")
			object:SetState(data.TextButton, "inactive")
		end,
		unEquipped = function(data, object)
			tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})
			data.TextButton.Inactive.Visible = false
			data.TextButton.Title.Text = "EQUIP"
			data.Display.Equipped.Visible = false
			data.Fade.Visible = false
			object:SetState(data.Pinned, "closed")
			object:SetState(data.TextButton, "active")
		end
	}
	Title.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Title