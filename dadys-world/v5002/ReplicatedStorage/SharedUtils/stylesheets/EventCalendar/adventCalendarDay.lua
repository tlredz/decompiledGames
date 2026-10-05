local AdventCalendarDay = {}
AdventCalendarDay.__index = AdventCalendarDay
local v = { "rbxassetid://123203419478505", "rbxassetid://112936417260119", "rbxassetid://84058132365655" }
local uDim = UDim2.new(0.75, 0, 1, 0)
local color = Color3.fromRGB(143, 255, 151)

function AdventCalendarDay.Init(_, helpers)
	local self = setmetatable({}, AdventCalendarDay)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function AdventCalendarDay:LoadStylesheet()
	local tweens = self.tweens
	local isState = self.helpers.isState
	local isShown = self.helpers.isShown

	local function wobble(p2, p3: string, list)
		local pivot = p2.Margin.Reward.IconFrame.Pivot
		local flag = false

		while isState(p2, p3) do
			if isShown(p2) then
				if flag then
					flag = false

					for _, v2 in ipairs(list) do
						v2:Play()
					end
				end

				for _, rotation in ipairs({ -5, 5 }) do
					tweens.playTween(pivot, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Rotation = rotation,
						Size = UDim2.fromScale(1, 1)
					})
					tweens.playTween(pivot.Icon, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(1.05, 1)
					})
					task.wait(0.35)
					tweens.playTween(pivot, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Rotation = 0,
						Size = UDim2.fromScale(1, 1.05)
					})
					tweens.playTween(pivot.Icon, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(1, 1)
					})
					task.wait(0.35)
				end
			else
				if not flag then
					flag = true

					for _, v2 in ipairs(list) do
						v2:Pause()
					end
				end

				task.wait(0.5)
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setMissedVisible(p2, visible: boolean)
		local missed = p2.Margin:FindFirstChild("Missed")

		if missed then
			missed.Visible = visible
		end

		p2.Missed.Visible = visible
	end

	local function showClaimed(p2)
		local reward = p2.Margin.Reward
		setMissedVisible(p2, false) -- equivalent call inferred; original call site unknown
		p2.Margin.Background.ImageColor3 = color
		p2.Completed.Visible = true
		reward.IconFrame.Pivot.Icon.ImageTransparency = 0.5
		reward.Quantity.TextColor3 = Color3.fromRGB(174, 255, 179)
		reward.Quantity.UIStroke.Color = Color3.fromRGB(127, 127, 127)
		reward.IconFrame.Pivot.Glow.Visible = false
	end

	function AdventCalendarDay.base(instance)
		local pivot = instance.Margin.Reward.IconFrame.Pivot
		local stickerId = instance:GetAttribute("stickerId")
		local printId = instance:GetAttribute("printId")

		if stickerId or printId then
			pivot.Icon.Image = "rbxassetid://104546405902824"
			pivot.Glow.Image = "rbxassetid://104546405902824"
			pivot.Icon.Sticker.Image = stickerId or printId
			pivot.Icon.Sticker.Visible = true
			instance.Margin.Reward.Quantity.Visible = false
		end

		if printId then
			pivot.Icon.Image = "rbxassetid://139628393964880"
			pivot.Icon.Sticker.ScaleType = Enum.ScaleType.Fit
			pivot.Icon.Sticker.Size = uDim
		end

		if pivot.Icon.Image == "rbxassetid://84058132365655" then
			pivot.Icon.Image = v[(instance.LayoutOrder - 1) % #v + 1]
		end

		tweens.saveInitials(instance)
	end

	AdventCalendarDay.states = {
		claimed = function(p2, object)
			object:ClearConnections(p2, "state")
			showClaimed(p2)
		end,
		claimable = function(instance, object)
			local iconFrame = instance.Margin.Reward.IconFrame
			tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})
			object:ClearConnections(instance, "state")
			setMissedVisible(instance, false) -- equivalent call inferred; original call site unknown
			instance.Margin.Background.ImageColor3 = color
			instance.Completed.Visible = true
			iconFrame.Pivot.Glow.Visible = true
			iconFrame.Pivot.Glow.ImageTransparency = 1

			if instance:GetAttribute("DoubleEarnings") == true then
				instance.DoubleEarnings.Visible = true
			end

			task.spawn(function()
				local v2 = tweens.playTween(
					iconFrame,
					TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true),
					{
						Position = UDim2.fromScale(0.5, 0.525)
					}
				)
				local v3 = tweens.playTween(
					iconFrame.Pivot.Glow,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						ImageTransparency = 0
					}
				)
				wobble(instance, "claimable", { v2, v3 })
				v2:Cancel()
				v3:Cancel()
			end)
		end,
		newlyClaimed = function(p2, object)
			object:ClearConnections(p2, "state")
			local clone = p2.Margin.Reward:Clone()
			clone.Parent = p2.Margin
			clone.Background.Visible = false
			tweens.playTween(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Position = UDim2.fromScale(0.5, 0)
			})
			tweens.fadeOut(clone, TweenInfo.new(1))
			task.delay(1, clone.Destroy, clone)
			tweens.playTween(
				p2.UIScale,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					Scale = 0.8
				}
			)
			showClaimed(p2)
		end,
		unclaimed = function(data, _)
			local reward = data.Margin.Reward
			tweens.playTween(data.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				Scale = 1
			})
			setMissedVisible(data, false) -- equivalent call inferred; original call site unknown
			data.Margin.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
			data.Completed.Visible = false
			reward.IconFrame.Pivot.Icon.ImageTransparency = 0
			reward.Quantity.TextColor3 = Color3.fromRGB(255, 255, 255)
			reward.Quantity.UIStroke.Color = Color3.fromRGB(0, 0, 0)
			reward.IconFrame.Pivot.Glow.Visible = false
			task.spawn(function()
				local v2 = tweens.playTween(
					reward.IconFrame,
					TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true),
					{
						Position = UDim2.fromScale(0.5, 0.525)
					}
				)
				wobble(data, "unclaimed", { v2 })
				v2:Cancel()
			end)
		end,
		missed = function(instance, object)
			setMissedVisible(instance, true) -- equivalent call inferred; original call site unknown
			instance.Completed.Visible = false
			instance:SetAttribute("DoubleEarnings", instance.DoubleEarnings.Visible == true)
			instance.DoubleEarnings.Visible = false
			object:AddConnection(instance, "state", instance.TextButton.MouseEnter:Connect(function()
				tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1.1
				})
			end))
			object:AddConnection(instance, "state", instance.TextButton.MouseLeave:Connect(function()
				tweens.playTween(instance.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end))
			object:AddConnection(instance, "state", instance.TextButton.MouseButton1Click:Connect(function()
				tweens.playTween(
					instance.UIScale,
					TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, true),
					{
						Scale = 0.9
					}
				)
			end))
		end
	}
	AdventCalendarDay.flags = {
		doubleXP = function(p2, visible)
			p2.Margin.DoubleGlow.Visible = visible
			p2.DoubleEarnings.Visible = visible
		end,
		skindrop = function(p2, visible)
			p2.SkinDrop.Visible = visible
		end,
		today = function(p2, visible)
			local currentDay = p2.Margin.CurrentDay

			if visible then
				currentDay.Size = UDim2.fromScale(1.2, 1.2)
				tweens.playTween(currentDay, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Size = UDim2.fromScale(1, 1)
				})
			end

			currentDay.Visible = visible
		end
	}
end

return AdventCalendarDay