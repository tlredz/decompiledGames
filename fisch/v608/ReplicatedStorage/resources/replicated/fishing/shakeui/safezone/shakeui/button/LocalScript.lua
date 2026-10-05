local parent = script.Parent
local clone = parent.ripple:Clone()
local parent2 = parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local TweenService = game:GetService("TweenService")
local animations = ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations")
local rods = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local fishing = animations:WaitForChild("fishing")
task.delay(0.2, function()
	parent.Selectable = true
end)
script.Parent.MouseButton1Click:Connect(function()
	clone.Position = parent.Position
	clone.Parent = parent2
	clone.Visible = true

	if parent2 and parent2:FindFirstChild("bobber") ~= nil and parent2:FindFirstChild("char") ~= nil then
		if parent2:FindFirstChild("bobber").Value ~= nil then
			local bobber = parent2:FindFirstChild("bobber")

			if bobber and bobber.Value then
				local shakeparticle = bobber.Value:FindFirstChild("shakeparticle")

				if shakeparticle then
					shakeparticle:Emit(math.random(1, 4))
				end

				fx:PlaySound(
					ReplicatedStorage.resources.sounds.sfx.fishing.shake,
					parent2:WaitForChild("bobber").Value,
					true
				)
			end
		end

		task.spawn(function()
			if parent2:FindFirstChild("char").Value ~= nil then
				local humanoid = parent2:FindFirstChild("char").Value:FindFirstChild("Humanoid")
				local tool = parent2:FindFirstChild("char").Value:FindFirstChildOfClass("Tool")

				if not (tool and rods[tool.Name]) then
					return
				end

				local handle = tool:FindFirstChild("handle")

				if not handle then
					return
				end

				local v

				if handle:FindFirstChild("shake") and handle.shake:IsA("Animation") then
					v = handle.shake
				else
					v = fishing.shake
				end

				local track = humanoid:LoadAnimation(v)
				track.Priority = Enum.AnimationPriority.Action3
				track:Play()
			end
		end)
		local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1,
			Size = UDim2.new(0.25, 40, 0.25, 40)
		})
		tween:Play()
		tween.Completed:Wait()
		clone:Destroy()
		parent:Destroy()
	end
end)