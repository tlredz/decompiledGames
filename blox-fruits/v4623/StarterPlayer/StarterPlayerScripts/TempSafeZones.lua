local createVector = vector.create
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:WaitForChild("Boats") }
workspace:WaitForChild("Characters").ChildAdded:Connect(function(child)
	child:GetPropertyChangedSignal("Parent"):Connect(function()
		if not child.Parent then
			task.delay(5, workspace.Destroy, child)
		end
	end)
	child.ChildAdded:Connect(function(child2)
		local raycastResult = child2.Name == "TempSafeZone" and workspace:Raycast(
			child2:GetAttribute("Position") + createVector(0, 1, 0),
			createVector(0, -35, 0),
			raycastParams
		)

		if raycastResult then
			local vector2 = Vector3.new(
				child2:GetAttribute("Size"),
				child2:GetAttribute("Size"),
				child2:GetAttribute("Size")
			)

			if raycastResult.Position then
				local clone = game.ReplicatedStorage.Assets.Models.tempsafezone:Clone()
				clone.Circle.Size = vector2 * createVector(1, 0, 1)
				clone:SetPrimaryPartCFrame(CFrame.new(raycastResult.Position + createVector(0, 0.1, 0)))
				clone.Circle.SurfaceGui.Frame.BackgroundColor3 = child2:GetAttribute("Color")
				clone.Circle.SurfaceGui.Frame.UIStroke.Color = child2:GetAttribute("Color")
				clone.Part.Color = child2:GetAttribute("Color")
				clone.Parent = workspace
				local TweenService = game:GetService("TweenService")
				TweenService:Create(clone.Circle.SurfaceGui.Frame, TweenInfo.new(0.4), {
					Size = UDim2.fromScale(1, 1)
				}):Play()
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(clone.Part, TweenInfo.new(0.4), {
					Size = vector2 * createVector(1, 3, 1)
				}):Play()

				local function fn()
					if not child2.Parent then
						clone:Destroy()
						child2:Destroy()
					end
				end

				if not (child2.Parent and child2.Parent:FindFirstChild("HumanoidRootPart") or child2.Parent) then
					clone:Destroy()
					child2:Destroy()
				end

				child2:GetPropertyChangedSignal("Parent"):Connect(fn)
				child2.Destroying:Connect(function()
					clone:Destroy()
				end)
			end
		end
	end)
end)