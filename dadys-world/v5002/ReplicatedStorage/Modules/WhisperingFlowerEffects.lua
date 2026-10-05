local createVector = vector.create
local WhisperingFlowerEffects = {}
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function WhisperingFlowerEffects.ClientAbility(_, instance)
	while workspace.Info.Panic.Value and instance and instance.Parent do
		if workspace:FindFirstChild("CurrentRoom") then
			if workspace.CurrentRoom:FindFirstChildWhichIsA("Model") and workspace.Info.FloorActive.Value then
				local success, result = pcall(function()
					local result2 = {}

					for _, tag in ipairs({ "Item", "Collectible", "PuzzleItem" }) do
						for _, v in ipairs(CollectionService:GetTagged(tag)) do
							if v:IsDescendantOf(workspace) then
								table.insert(result2, v)
							end
						end
					end

					return result2
				end)

				if success then
					for _, v in ipairs(result) do
						if not (v:IsDescendantOf(workspace) and v.PrimaryPart and instance.PrimaryPart) then
							continue
						end

						local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 2, true)
						local clone = ReplicatedStorage.GUI.HolidayWarningIcon:Clone()
						clone.StudsOffset = createVector(0, 3, 0)
						clone.Size = UDim2.new(8, 0, 8, 0)
						clone.Frame.TextLabel.Text = "ITEM"
						clone.Frame.TextLabel.TextColor3 = Color3.fromRGB(173, 216, 230)
						clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(173, 216, 230)
						clone.Name = "WhisperingFlowerWarningIcon"
						local highlight = Instance.new("Highlight")
						highlight.FillTransparency = 0.7
						highlight.OutlineColor = Color3.fromRGB(173, 216, 230)
						highlight.OutlineTransparency = 0
						highlight.Name = "WhisperingFlowerHighlight"
						local parent = v
						task.spawn(function()
							pcall(function()
								highlight.Parent = parent

								if parent.PrimaryPart then
									clone.Parent = parent.PrimaryPart
								end
							end)
							TweenService:Create(highlight, tweenInfo, {
								OutlineTransparency = 0.5,
								FillTransparency = 0.9
							}):Play()
							task.spawn(function()
								while workspace.Info.Panic.Value and highlight.Parent do
									task.wait(0.5)
								end

								if highlight and highlight.Parent then
									highlight:Destroy()
								end

								if clone and clone.Parent then
									clone:Destroy()
								end
							end)
						end)
					end
				else
					warn("WhisperingFlowerEffects: Failed to get items -", result)
					task.wait(1)
				end
			end

			task.wait(1)
		else
			task.wait(0.5)
		end
	end
end

return WhisperingFlowerEffects