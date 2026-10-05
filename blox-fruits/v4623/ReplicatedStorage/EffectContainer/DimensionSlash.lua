local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local energySlash = game.ReplicatedStorage.Assets.Models.EnergySlash
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

local function func(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 3
	local duration = data.Duration or 0.75
	local distance = data.Distance or 200

	if not data.Color then
		Color3.new(0.01, 0, 0.01)
	end

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 400 then
		return
	end

	local flag = false

	if data.Reference and data.Reference:IsDescendantOf(workspace) then
		local ancestryChangedConnection = nil
		ancestryChangedConnection = data.Reference.AncestryChanged:Connect(function()
			if not data.Reference:IsDescendantOf(workspace) then
				flag = true
				ancestryChangedConnection:Disconnect()
			end
		end)
	end

	local clones = {}

	for i = 1, 1.05, 0.05 do
		local v = duration * i
		local cframe = CFrame.Angles(3.141592653589793, 0, 1.5707963267948966)
		local clone = energySlash:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, scale * 2.5) * cframe
		local _ = (i - 0.5) * 2 + 4
		local v2 = (i - 1) / 0.05
		clone.Mesh.VertexColor = Vector3.new(v2 * 0.2 * 6, 0, v2 * 0.5 * 6)
		clone.Mesh.Scale = Vector3.new(i, 1, 1) * scale * 0.25 * (1.5 - i * 0.5)
		clone.Parent = _WorldOrigin
		table.insert(clones, clone)
		TweenService:Create(clone, TweenInfo.new(v * 1.5), {
			CFrame = cFrame * CFrame.new(0, 0, scale * 2 - distance) * cframe
		}):Play()
		TweenService:Create(clone.Mesh, TweenInfo.new(v * 1.5), {
			Scale = createVector(1, 1, 1) * scale * (1.2 - i * 0.2)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(v * (1.5 - (i - 0.2) * 0.3), Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	end

	local clone = game.ReplicatedStorage.Assets.Models.DustTrail:Clone()
	clone.Rock.Speed = NumberRange.new(4 * scale, 30 * scale)
	clone.Rock.Size = NumberSequence.new(0.03 * scale, 0.1 * scale)
	clone.Smoke.Speed = NumberRange.new(13 * scale, 22 * scale)
	clone.Smoke.Size = NumberSequence.new(scale, 0)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local lastTime = tick()
	local v = nil
	local v2 = false

	while not flag do
		local v3 = math.min((tick() - lastTime) / duration, 1) ^ 0.8
		local ray = Ray.new(
			cFrame.p + cFrame.LookVector * distance * v3 + Vector3.new(0, scale * 3, 0),
			(Vector3.new(0, -scale * 7, 0))
		)
		local part, v5, _ = workspace:FindPartOnRayWithWhitelist(ray, { map })
		local v6 = v or Vector3.new(cFrame.p.x, v5.y, cFrame.p.z)

		if part then
			local magnitude = (v5 - v6).Magnitude
			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = Vector3.new(scale * (v3 * 0.1 + 0.075), 0.4, magnitude)
			part2.CFrame = CFrame.new(v6, v5) * CFrame.new(0, 0, -magnitude / 2)
			part2.Material = "Neon"
			part2.Color = Color3.new(0.5, 0, 1)
			part2.Parent = _WorldOrigin
			local tween = TweenService:Create(part2, TweenInfo.new(0.35), {
				Color = Color3.new()
			})
			tween.Completed:Connect(function()
				wait(2)
				local tween2 = TweenService:Create(part2, TweenInfo.new(0.5), {
					Size = part2.Size * createVector(0, 0, 1)
				})
				tween2.Completed:Connect(function()
					part2:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
		end

		if _G.FastMode then
			v = v5
		else
			v = v5

			for i = -1, 1, 2 do
				local ray2 = Ray.new(
					cFrame.p + cFrame.LookVector * distance * v3 + cFrame.RightVector * i * scale * (v3 + 0.25) + Vector3.new(
						0,
						scale * 3,
						0
					),
					(Vector3.new(0, -scale * 7, 0))
				)
				local part2, v8, _ = workspace:FindPartOnRayWithWhitelist(ray2, { map })

				if not part2 then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Anchored = true
				part3.CanCollide = false
				part3.Size = createVector(0.05, 0.05, 0.05)
				part3.Color = part2.Color
				part3.Material = part2.Material
				part3.Transparency = part2.Transparency
				part3.CFrame = CFrame.new(v8) * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				)
				part3.Parent = _WorldOrigin
				local tween = TweenService:Create(part3, TweenInfo.new(0.2), {
					Size = createVector(1, 1, 1) * scale * (v3 + 0.25) * 0.5,
					CFrame = part3.CFrame * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 1.5707963267948966)
				})
				tween.Completed:Connect(function()
					wait(2)
					local tween2 = TweenService:Create(
						part3,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0.05, 0.05, 0.05),
							CFrame = part3.CFrame - createVector(0, 0.1, 0)
						}
					)
					tween2.Completed:Connect(function()
						part3:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end
		end

		if part then
			if not v2 then
				clone.Smoke.Color = ColorSequence.new(part.Color)
				v2 = true
			end

			clone.CFrame = CFrame.new(v5, v5 + cFrame.LookVector)
			clone.Rock.Enabled = true
			clone.Smoke.Enabled = true
			clone.Rock.Acceleration = Vector3.new(0, v3 * 200 + -300, 0)
		else
			clone.Rock.Enabled = false
			clone.Smoke.Enabled = false
			v2 = false
		end

		if v3 == 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	clone.Rock.Enabled = false
	clone.Smoke.Enabled = false

	if flag then
		for _, v3 in pairs(clones) do
			TweenService:Create(v3, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end
	end

	wait(3)

	for _, v3 in pairs(clones) do
		v3:Destroy()
	end

	wait(0.5)
	clone:Destroy()
end

return func