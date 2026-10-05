local Collection = {}
Collection.__index = Collection

function Collection.Init(_, helpers)
	local self = setmetatable({}, Collection)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Collection:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local Debris = game:GetService("Debris")

	local function playSound(instance, options)
		local clone = instance:Clone()
		clone.Name = "Temp" .. clone.Name
		clone.Parent = instance.Parent

		for k, v in pairs(options or {}) do
			if tweens.hasProperty(clone, k) then
				clone[k] = v
			end
		end

		clone:Play()
		Debris:AddItem(clone, instance.TimeLength or 5)
	end

	function Collection.base(p2, object)
		tweens.saveInitials(p2)
		local stickers = p2.Margin.Stickers
		local stickers2 = p2.Margin.Stickers.Envelope.Stickers
		wait(0.15)
		local v = {}

		for i, image in pairs(stickers2:GetChildren()) do
			if not image:IsA("ImageLabel") then
				continue
			end

			local random = Random.new(i)
			image.Keyframe.BackgroundTransparency = 1
			v[image] = {}
			v[image].enter = tweens.playTween(
				image,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Position = tweens.getPositionInParent(image.Keyframe, image.Parent.Parent),
					Rotation = image.Keyframe.Rotation
				}
			)
			v[image].leave = tweens.playTween(
				image,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Position = tweens.getInitial(image, "Position"),
					Rotation = tweens.getInitial(image, "Rotation")
				}
			)
			v[image].enter:Pause()
			v[image].leave:Pause()
			v[image].idle = tweens.playTween(
				image,
				TweenInfo.new(random:NextNumber(1.8, 2), Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true),
				{
					AnchorPoint = Vector2.new(0.5, 0.4)
				}
			)
			v[image].idle:Pause()
		end

		local mouseEnterLeaveEvent, v2 = tweens.mouseOver.MouseEnterLeaveEvent(stickers.Button)
		local v3 = false
		mouseEnterLeaveEvent:Connect(function()
			v3 = true
			playSound(game.SoundService.UI.envelope1)
			tweens.playTween(
				stickers.Envelope.Top.UIScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = 1.05
				}
			)
			tweens.playTween(
				stickers.Envelope.Back.UIScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = 1.05
				}
			)
			tweens.playTween(stickers.Leaves, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = tweens.getPositionInParent(stickers.Leaves.Keyframe, stickers.Leaves.Parent),
				Rotation = stickers.Leaves.Keyframe.Rotation
			})
			tweens.playTween(stickers.Flower, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = tweens.getPositionInParent(stickers.Flower.Keyframe, stickers.Flower.Parent),
				Rotation = stickers.Flower.Keyframe.Rotation
			})
			tweens.playTween(
				stickers.Envelope.Top,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = UDim2.fromScale(1.18, 1.3),
					Position = UDim2.fromScale(0.488, 0.35)
				}
			)
			tweens.playTween(
				stickers.Envelope.Back,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = UDim2.fromScale(1.18, 1.3),
					Position = UDim2.fromScale(0.488, 0.35)
				}
			)
			tweens.playTween(
				stickers.Envelope.Tape,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = UDim2.fromScale(1.18, 1.25),
					Position = UDim2.fromScale(0.488, 0.35)
				}
			)
			object:SetFlag(stickers.TextButton, "glowing", true)
			object:SetFlag(stickers.TextButton, "hovered", true)

			for k, v4 in pairs(v) do
				v4.enter:Play()

				if k:FindFirstChild("Particles") then
					k.Particles.ParticleEmitter.Enabled = true
				end

				local v5 = v4
				task.spawn(function()
					wait(0.25)

					if not v3 then
						return
					end

					v5.idle:Play()
				end)
			end
		end)
		v2:Connect(function()
			v3 = false
			playSound(game.SoundService.UI.envelope2)
			tweens.playTween(
				stickers.Envelope.Top.UIScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = 1
				}
			)
			tweens.playTween(
				stickers.Envelope.Back.UIScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = 1
				}
			)
			tweens.playTween(stickers.Leaves, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = tweens.getInitial(stickers.Leaves, "Position"),
				Rotation = 0
			})
			tweens.playTween(stickers.Flower, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = tweens.getInitial(stickers.Flower, "Position"),
				Rotation = 0
			})
			object:SetFlag(stickers.TextButton, "glowing", false)
			object:SetFlag(stickers.TextButton, "hovered", false)
			tweens.playTween(
				stickers.Envelope.Top,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = tweens.getInitial(stickers.Envelope.Top, "Size"),
					Position = tweens.getInitial(stickers.Envelope.Top, "Position")
				}
			)
			tweens.playTween(
				stickers.Envelope.Back,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = tweens.getInitial(stickers.Envelope.Back, "Size"),
					Position = tweens.getInitial(stickers.Envelope.Back, "Position")
				}
			)
			tweens.playTween(
				stickers.Envelope.Tape,
				TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
				{
					Size = tweens.getInitial(stickers.Envelope.Back, "Size"),
					Position = tweens.getInitial(stickers.Envelope.Back, "Position")
				}
			)

			for k, v4 in pairs(v) do
				v4.leave:Play()
				v4.idle:Pause()

				if k:FindFirstChild("Particles") then
					k.Particles.ParticleEmitter.Enabled = false
				end

				tweens.playTween(k, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					AnchorPoint = Vector2.new(0.5, 0.5)
				})
			end
		end)
		task.spawn(function()
			while true do
				wait(5)

				if v3 then
					continue
				end

				tweens.playTween(
					stickers.Envelope.UIScale,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, true),
					{
						Scale = 1.05
					}
				)
				wait(0.5)

				if not v3 then
					tweens.playTween(
						stickers.Envelope.UIScale,
						TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, true),
						{
							Scale = 1.05
						}
					)
				end
			end
		end)
	end

	Collection.states = {
		templateState = function(_, _) end
	}
	Collection.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Collection