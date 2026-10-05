local Medals = {}
Medals.__index = Medals

function Medals.Init(_, helpers)
	local self = setmetatable({}, Medals)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Medals:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local Debris = game:GetService("Debris")

	local function playSound(dupeItem, options)
		local clone = dupeItem:Clone()
		clone.Name = "Temp" .. clone.Name
		clone.Parent = dupeItem.Parent

		for k, v in pairs(options or {}) do
			if tweens.hasProperty(clone, k) then
				clone[k] = v
			end
		end

		clone:Play()
		Debris:AddItem(clone, dupeItem.TimeLength or 5)
	end

	function Medals.base(instance, object)
		tweens.saveInitials(instance)
		instance:GetAttributeChangedSignal("Redeemed"):Connect(function()
			if instance:GetAttribute("Redeemed") then
				if instance:GetAttribute("Initiated") then
					local dupeItem = playerGui.MainGui:FindFirstChild("DupeItem")

					if dupeItem and dupeItem:IsA("Sound") then
						playSound(dupeItem)
					end

					task.spawn(function()
						local click = instance.Click.Click
						click.Enabled = true
						task.wait(0.25)
						click.Enabled = false
					end)
				end

				object:SetState(instance, "Redeemed")
			end

			if not instance:GetAttribute("Initiated") then
				instance:SetAttribute("Initiated", true)
			end
		end)
		instance:GetAttributeChangedSignal("CanRedeem"):Connect(function()
			if instance:GetAttribute("CanRedeem") and not instance:GetAttribute("Redeemed") then
				object:SetState(instance, "CanRedeem")
			end
		end)
		object:AddConnection(instance, "state", instance.MouseEnter:Connect(function()
			tweens.playTween(instance.ImageLabel.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1.1
			})
		end))
		object:AddConnection(instance, "state", instance.MouseLeave:Connect(function()
			tweens.playTween(instance.ImageLabel.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})
		end))
		object:AddConnection(instance, "click", instance.ImageButton.Activated:Connect(function()
			task.spawn(function()
				local _ = instance.Click.Click
				task.wait(0.25)
			end)
		end))
		instance:GetAttributeChangedSignal("Selected"):Connect(function() end)
	end

	local v = {}
	local v2 = {}
	Medals.states = {
		Redeemed = function(data, _)
			data.ParticleGroup.Glow.Glow.Enabled = false
			data.ImageLabel.ProgressShadow.UIGradient.Enabled = true

			if v[data] then
				v[data]:Cancel()
			end

			if v2[data] then
				v2[data]:Cancel()
			end

			task.spawn(function()
				while true do
					wait(2)
					data.Particles.Sparkle.Enabled = true
					wait(0.15)
					data.Particles.Sparkle.Enabled = false
				end
			end)
		end,
		CanRedeem = function(p2, _)
			if v2[p2] then
				v2[p2]:Play()
			else
				v2[p2] = tweens.playTween(
					p2.ImageLabel,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						AnchorPoint = Vector2.new(0.5, 0.4)
					}
				)
			end

			p2.ParticleGroup.Glow.Glow.Enabled = true
			p2.ImageLabel.ProgressShadow.UIGradient.Enabled = false

			if v[p2] then
				v[p2]:Play()
			else
				v[p2] = tweens.playTween(
					p2.ImageLabel.ProgressShadow,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						ImageTransparency = 1
					}
				)
			end
		end
	}
	Medals.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Medals