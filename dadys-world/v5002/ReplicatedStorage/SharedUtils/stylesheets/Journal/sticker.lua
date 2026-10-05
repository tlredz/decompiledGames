local Sticker = {}
Sticker.__index = Sticker

function Sticker.Init(_, helpers)
	local self = setmetatable({}, Sticker)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Sticker:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Sticker.base(instance, object)
		tweens.saveInitials(instance)

		local function stringToArray(tags)
			if not tags then
				return {}
			end

			local result = {}

			for k in string.gmatch(tags, "([^|]+)") do
				table.insert(result, k)
			end

			return result
		end

		local v = stringToArray(instance:GetAttribute("Tags"))

		for _, childName in pairs(v) do
			local child = instance:FindFirstChild(childName)

			if child then
				child.Visible = true
			end
		end

		object:AddConnection(instance, "state", instance.MouseEnter:Connect(function()
			if instance:GetAttribute("Cooldown") then
				return
			end

			tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1.1
			})
		end))
		object:AddConnection(instance, "state", instance.MouseLeave:Connect(function()
			if instance:GetAttribute("Cooldown") then
				return
			end

			tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})
		end))
		local value = instance.Reference.Value
		object:AddConnection(instance, "click", instance.TextButton.Activated:Connect(function()
			if instance:GetAttribute("Cooldown") or not instance:GetAttribute("Owned") then
				return
			end

			task.spawn(function()
				instance:SetAttribute("Cooldown", true)
				tweens.playTween(instance.UIScale, TweenInfo.new(1, Enum.EasingStyle.Circular), {
					Scale = 1.25
				})
				local clone = value:Clone()
				clone.Parent = value.Parent
				clone.Text = instance.Label.Text

				if instance.Label.Text ~= "" then
					game.SoundService.UI.Dialogue:Play()
				end

				clone.Visible = true
				clone.TextTransparency = 1
				clone.UIStroke.Transparency = 1
				clone.Position = tweens.getPositionInParent(instance.Label, instance.Parent.Parent)
				clone.Position -= UDim2.fromScale(0, 0.05)
				clone.Rotation = instance.ImageLabel.Rotation
				tweens.playTween(clone, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					TextTransparency = 0
				})
				tweens.playTween(clone.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Transparency = 0
				})
				tweens.playTween(clone.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1.3
				})
				tweens.playTween(clone, TweenInfo.new(1, Enum.EasingStyle.Circular), {
					Position = tweens.getPositionInParent(instance.Label, instance.Parent.Parent)
				})
				task.wait(1)

				if not instance.Parent then
					clone:Destroy()
					return
				end

				tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
				tweens.playTween(clone, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					TextTransparency = 1
				})
				tweens.playTween(clone.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Transparency = 1
				})
				tweens.playTween(clone, TweenInfo.new(1, Enum.EasingStyle.Circular), {
					Position = clone.Position + UDim2.fromScale(0, 0.1)
				})
				task.wait(0.15)
				clone:Destroy()
				instance:SetAttribute("Cooldown", false)
			end)
		end))
	end

	Sticker.states = {
		templateState = function(_, _) end
	}
	Sticker.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Sticker