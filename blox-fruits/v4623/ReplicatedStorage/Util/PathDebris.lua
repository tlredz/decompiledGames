local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local CF = data.CF

	if not CF then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Enemies, workspace.Characters, workspace._WorldOrigin }
	local length = data.Length or 10
	local width = data.Width or 7
	local lifetime = data.Lifetime or 3
	local size = data.Size or 3
	local v = {}
	local v2 = {}
	local v3 = nil

	for i = 1, length, data.LengthSpace or 1 do
		for i2 = -1, 1, 2 do
			local raycastResult = workspace:Raycast(
				(CF * CFrame.new((width + (data.WidthProgress or 0) * i / length) * i2, 0, -i * 2)).p + createVector(
					0,
					5,
					0
				),
				createVector(0, -10, 0),
				raycastParams
			)

			if raycastResult then
				local part = Instance.new("Part")
				part.CanTouch = false
				part.CanQuery = false
				part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				part.TopSurface = Enum.SurfaceType.Smooth
				part.BottomSurface = Enum.SurfaceType.Smooth
				part.Material = raycastResult.Material
				part.Size = createVector(0, 0, 0)
				part.Color = raycastResult.Instance.Color
				part.Anchored = true
				part.CanCollide = false
				part.Parent = workspace._WorldOrigin
				local tweenInfo = TweenInfo.new(0.25)
				local v5 = {
					CFrame = part.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					),
					Size = 0
				}
				local v7

				if data.Progressive then
					v7 = data.Progressive * (i / length) + size or size
				else
					v7 = size
				end

				v5.Size = createVector(1, 1, 1) * v7
				v3 = TweenService:Create(part, tweenInfo, v5)
				v3:Play()
				v[#v + 1] = v3
				v2[#v2 + 1] = part
			end

			if not data.WaitFrames then
				continue
			end

			for _ = 1, data.WaitFrames do
				RunService.RenderStepped:Wait()
			end
		end
	end

	task.delay(lifetime, function()
		for k, v4 in pairs(v2) do
			v3 = TweenService:Create(v4, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0)
			})
			local v5 = v4
			v3.Completed:Connect(function()
				v5:Destroy()
			end)
			v3:Play()
			v[#v + 1] = v3

			if k % 2 == 0 then
				wait(0.1)
			end
		end

		task.wait(0.5)

		for _, v4 in pairs(v) do
			v4:Destroy()
		end

		v = {}
	end)
end