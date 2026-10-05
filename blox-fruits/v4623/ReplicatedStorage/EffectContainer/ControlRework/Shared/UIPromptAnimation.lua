local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local gameplay = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay")
local parent = script.Parent
local VisualHelper = require(parent.Utility.VisualHelper)

local function PromptGuiObjectProperties(folder, fn)
	for _, descendant in folder:GetDescendants() do
		if not descendant:IsA("GuiObject") then
			continue
		end

		for _, v in {
			"Size",
			"Transparency",
			"Position",
			"Rotation"
		} do
			if v == "Transparency" or not v then
				v = descendant:IsA("ImageLabel") and "ImageTransparency" or descendant:IsA("CanvasGroup") and "GroupTransparency" or "BackgroundTransparency"
			end

			fn(descendant, v)
		end
	end
end

return function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	if not player:FindFirstChild("PlayerGui") and player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player)
		folder.Name = "PlayerGui"
	end

	local promptControl = player.PlayerGui:FindFirstChild("Prompt-Control")

	if promptControl and promptControl.Enabled then
		return warn("Animation in process!")
	end

	local v = promptControl or gameplay.Prompt:Clone()
	v.Enabled = true
	v.Name = "Prompt-Control"
	v.Parent = player.PlayerGui

	if not promptControl then
		PromptGuiObjectProperties(v, function(instance, p)
			instance:SetAttribute(`Original{p}`, instance[p])
		end)
	end

	local main = v.Main
	local v2 = { main.KnifeRight, main.KnifeLeft }
	local slash = main.Slash
	slash.Visible = false

	for k, v3 in v2 do
		local v4 = { v3.GlowSuper, v3.GlowBlack, v3.Glow }
		local size = v3.Size
		local rotation = v3.Rotation
		local rotation2 = math.sign(v3.Rotation)
		v3.Rotation = rotation2 * -95
		v3.Size = UDim2.new()
		VisualHelper:Tween(v3, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Size = size,
			Rotation = rotation * 0.5
		})
		local center = v3.Center
		local size2 = center.Size
		center.Size = UDim2.new()
		VisualHelper:Tween(center, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Size = size2
		})
		local back = v3.Back
		local _ = back.Size
		local position = back.Position
		VisualHelper:Tween(back, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
			Position = back.Position + UDim2.new(0, 0, 0.1, 0)
		})
		local top = v3.Top
		local _ = top.Size
		local position2 = top.Position
		VisualHelper:Tween(top, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
			Position = top.Position - UDim2.new(0, 0, 0.1, 0)
		})
		local star = top.Star
		VisualHelper:Tween(star, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.5), {
			Size = UDim2.new(),
			Rotation = star.Rotation + 60
		})
		local glowPattern = v3.GlowPattern
		local size3 = glowPattern.Size
		glowPattern.Size = UDim2.new()
		VisualHelper:Tween(
			glowPattern,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2),
			{
				Size = size3,
				ImageTransparency = 1
			}
		)

		for _, v5 in v4 do
			local originalImageTransparency = v5:GetAttribute("OriginalImageTransparency")
			v5.ImageTransparency = 1
			VisualHelper:Tween(v5, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				ImageTransparency = originalImageTransparency
			})
		end

		local v5 = v3
		local v13 = k
		task.delay(0.3, function()
			VisualHelper:Tween(v5, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Rotation = rotation
			})
			task.wait(0.1)
			VisualHelper:Tween(back, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = position
			})
			VisualHelper:Tween(top, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = position2
			})
			task.wait(0.3)

			for k2, v14 in v4 do
				VisualHelper:Tween(v14, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					ImageTransparency = 1
				})
			end

			VisualHelper:Tween(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Rotation = rotation + rotation2 * -5,
				Position = v5.Position - UDim2.new(rotation2 * 0.05, 0, 0, 0)
			})
			task.wait(0.3)
			VisualHelper:Tween(v5, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Rotation = rotation,
				Position = v5.Position + UDim2.new(rotation2 * 1.7, 0, 0, 0)
			})
			task.wait(0.1)

			if v13 == 1 then
				slash.Visible = true
				VisualHelper:Tween(slash, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Size = slash.Size + UDim2.new(3, 0, -slash.Size.Y.Scale * 0.93, 0)
				})
				task.delay(0.1, function()
					VisualHelper:Tween(slash, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Size = slash.Size + UDim2.new(0.5, 0, -slash.Size.Y.Scale, 0),
						GroupTransparency = 1
					})
				end)
			end

			task.wait(1.2)
			PromptGuiObjectProperties(v, function(attributes, p)
				attributes[p] = attributes:GetAttribute((`Original{p}`))
			end)
			v.Enabled = false
		end)
	end
end