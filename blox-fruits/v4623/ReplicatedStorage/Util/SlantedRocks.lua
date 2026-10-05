local createVector = vector.create
local TweenService = game:GetService("TweenService")
return function(data)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local size = data.Size
	local X = data.X
	local Z = data.Z
	local cframe = data.Cframe
	local ammount = data.Ammount
	coroutine.wrap(function()
		for _ = 1, ammount do
			local raycastResult = workspace:Raycast(
				cframe * CFrame.new(-X, 0, -Z).Position,
				createVector(0, -15, 0),
				raycastParams
			)
			local raycastResult2 = workspace:Raycast(
				cframe * CFrame.new(X, 0, -Z).Position,
				createVector(0, -15, 0),
				raycastParams
			)

			if raycastResult then
				local instance = raycastResult.Instance
				local position = raycastResult.Position
				local part = Instance.new("Part")
				part.CFrame = CFrame.new(position)
				part.Material = instance.Material
				part.Color = instance.Color
				part.Size = Vector3.new()
				part.CanCollide = false
				part.Anchored = true
				part.Parent = workspace._WorldOrigin
				local tween = TweenService:Create(part, TweenInfo.new(0.2), {
					Size = Vector3.new(size, size, size),
					CFrame = part.CFrame * CFrame.Angles(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
				})
				tween:Play()
				tween:Destroy()
				coroutine.wrap(function()
					task.wait(1)
					local tween2 = TweenService:Create(part, TweenInfo.new(0.2), {
						Size = Vector3.new()
					})
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)()
			end

			if raycastResult2 then
				local instance = raycastResult2.Instance
				local position = raycastResult2.Position
				local part = Instance.new("Part")
				part.CFrame = CFrame.new(position)
				part.Material = instance.Material
				part.Color = instance.Color
				part.Size = Vector3.new()
				part.CanCollide = false
				part.Anchored = true
				part.Parent = workspace._WorldOrigin
				local tween = TweenService:Create(part, TweenInfo.new(0.2), {
					Size = Vector3.new(size, size, size),
					CFrame = part.CFrame * CFrame.Angles(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
				})
				tween:Play()
				tween:Destroy()
				coroutine.wrap(function()
					task.wait(1)
					local tween2 = TweenService:Create(part, TweenInfo.new(0.2), {
						Size = Vector3.new()
					})
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)()
			end

			Z += 5
			X += 1.5
			task.wait()
		end
	end)()
end