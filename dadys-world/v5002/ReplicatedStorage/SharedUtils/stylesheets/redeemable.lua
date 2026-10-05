local Redeemable = {}
Redeemable.__index = Redeemable

function Redeemable.Init(_, helpers)
	local self = setmetatable({}, Redeemable)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Redeemable:LoadStylesheet()
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

	function Redeemable.base(instance, object)
		tweens.saveInitials(instance)

		if not instance:GetAttribute("RedeemableBaseWired") then
			instance:SetAttribute("RedeemableBaseWired", true)
			instance:GetAttributeChangedSignal("Redeemed"):Connect(function()
				if instance:GetAttribute("Redeemed") then
					if instance:GetAttribute("Initiated") then
						playSound(playerGui.MainGui.DupeItem)

						if instance:FindFirstChild("Click") then
							task.spawn(function()
								local clone = instance.Click:Clone()
								clone.Visible = true
								clone.Parent = instance.Click.Parent
								tweens.playTween(clone, TweenInfo.new(0.25, Enum.EasingStyle.Circular), {
									Size = UDim2.fromScale(2, 2),
									ImageTransparency = 1
								})
								task.wait(0.25)
								clone:Destroy()
							end)
						end
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
				tweens.playTween(instance.Preview.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1.1
				})
			end))
			object:AddConnection(instance, "state", instance.MouseLeave:Connect(function()
				tweens.playTween(instance.Preview.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end))
			object:AddConnection(instance, "click", instance.ImageButton.Activated:Connect(function() end))
			instance:GetAttributeChangedSignal("Selected"):Connect(function() end)
		end
	end

	local v = {}
	local v2 = {}
	local v3 = {}
	Redeemable.states = {
		Redeemed = function(instance, _)
			instance.ParticleGroup.Glow.Glow.Enabled = false

			if v[instance] then
				v[instance]:Cancel()
			end

			if v2[instance] then
				v2[instance]:Cancel()
			end

			if v3[instance] then
				pcall(task.cancel, v3[instance])
				v3[instance] = nil
			end

			if instance:FindFirstChild("Particles") then
				v3[instance] = task.spawn(function()
					-- equivalent calls inferred from this helper; original call sites unknown
					local function aliveSparkle()
						local particles = instance.Parent and instance:FindFirstChild("Particles")
						return particles and particles:FindFirstChild("Sparkle") or nil
					end

					while true do
						task.wait(2)
						local v4 = aliveSparkle() -- equivalent call inferred; original call site unknown

						if not v4 then
							break
						end

						v4.Enabled = true
						task.wait(0.15)
						local v5 = aliveSparkle() -- equivalent call inferred; original call site unknown

						if not v5 then
							break
						end

						v5.Enabled = false
					end
				end)
			end
		end,
		CanRedeem = function(p2, _)
			if v2[p2] then
				v2[p2]:Play()
			else
				v2[p2] = tweens.playTween(
					p2.Preview,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						AnchorPoint = Vector2.new(0.5, 0.4)
					}
				)
			end

			p2.ParticleGroup.Glow.Glow.Enabled = true
		end
	}
	Redeemable.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Redeemable