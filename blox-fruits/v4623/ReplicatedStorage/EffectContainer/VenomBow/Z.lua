local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local RunService = game:GetService("RunService")
local assets = script.Assets
local S = Util.S
local bezier = Util.Bezier
local v = {
	Charge = function(data)
		local root = data.Root
		local holding = data.Holding

		if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 300 then
			return
		end

		local baby = data.Baby
		local clone = assets.ChargeUp:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 0.5, -4)
		clone.Parent = workspace._WorldOrigin
		S.TimeScaleParticle(clone, 1.4)
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = root.CFrame * CFrame.new(0, 0.5, -4)
		end)
		local v2 = Util.Sound:Play("BF_WPN_VenomBow_Hold_01_V2", root)

		while holding.Value and holding:IsDescendantOf(workspace) do
			if not baby then
				local position = (clone.CFrame * CFrame.new(S.Random(-15, 15), S.Random(-15, 15), S.Random(-0, 30))).Position
				local position2 = (clone.CFrame * CFrame.new(S.Random(-15, 15), S.Random(-15, 15), S.Random(-15, 15))).Position
				local v3 = bezier.new({ position, position2, clone.Position })
				local clone2 = assets.ChargeTrails:Clone()
				clone2.Parent = workspace._WorldOrigin
				clone2.Position = v3:DeCasteljau(0)
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 0.20833333333333334 do
						local v8 = (tick() - lastTime) / 0.20833333333333334
						v3.Points = { position, position2, clone.Position }
						local deCasteljau = v3:DeCasteljau(v8)
						local deCasteljau2 = v3:DeCasteljau(v8 + 0.01)
						local tween = TweenService:Create(clone2, TweenInfo.new(0.001, Enum.EasingStyle.Linear), {
							CFrame = CFrame.lookAt(deCasteljau, deCasteljau2)
						})
						tween:Play()
						tween.Completed:Wait()
						tween:Destroy()
					end

					task.wait(0.1)
					clone2.Trail.Enabled = false
					S.DisableDescendantParticles(clone2)
					debris:AddItem(clone2, 1)
				end)
			end

			task.wait(0.075)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		renderSteppedConnection:Disconnect()
		S.DisableDescendantParticles(clone)
		debris:AddItem(clone, 2)
	end
}

function RayCast(p, p2, options, p3)
	if p3 then
		local magnitude = p2.magnitude
		local part = Instance.new("Part")
		part.Material = Enum.Material.ForceField
		game.Debris:AddItem(part, 50)
		part.Size = createVector(0.4, 0.4, 1)
		part.CanCollide = false
		part.Anchored = true
		part.Color = Color3.fromRGB(math.random(-255, 255), math.random(1, 255), math.random(1, 255))
		part.Transparency = 0.6
		part.CFrame = CFrame.new(p, p + p2)
		local blockMesh = Instance.new("BlockMesh", part)
		blockMesh.Scale = Vector3.new(1, 1, magnitude * 0.95)
		blockMesh.Offset = Vector3.new(0, 0, -magnitude / 2)
		part.Parent = workspace._WorldOrigin
	end

	local filterDescendantsInstances = {}

	for _, v3 in next, options or {}, nil do
		table.insert(filterDescendantsInstances, v3)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = false
	return workspace:Raycast(p, p2, raycastParams)
end

function v.Shoot(data)
	local _ = data.Root
	local hitbox = data.Hitbox

	if not hitbox then
		return
	end

	local maxTime = data.MaxTime
	local projectileStep = data.ProjectileStep
	local cFrame = hitbox.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local clone = assets.Shoot:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace._WorldOrigin
	S.EmitDescendants(clone)
	debris:AddItem(clone, 2)
	Util.Sound:Play("BF_WPN_VenomBow_Fire_0" .. tostring(math.random(1, 3)) .. "_V2", clone)
	local clone2 = assets.Hydra:Clone()
	clone2.CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Mesh.Offset = createVector(0, 0, -2)
	clone2.Mesh.Scale = createVector(5, 5, 40)
	clone2.Parent = workspace._WorldOrigin
	debris:AddItem(clone2, 2)
	local Animate = require(clone2.Animate)
	Animate(0.041666666666666664)
	TweenService:Create(clone2.Mesh, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Offset = createVector(0, 0, 11),
		Scale = createVector(18, 18, 25)
	}):Play()

	for _ = 1, 4 do
		local clone3 = assets.Shockwave:Clone()
		clone3.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, math.rad((S.Random(-180, 180))), 0)
		clone3.Mesh.Scale = createVector(0, 5, 0)
		clone3.Parent = workspace._WorldOrigin
		task.spawn(function()
			local Animate2 = require(script.Parent.Animate)
			Animate2(1 / math.random(24, 30), clone3)
		end)
		local random = S.Random(0.7, 1.4)
		local tween = TweenService:Create(
			clone3.Mesh,
			TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Scale = createVector(20, 25, -20) * S.Random(0.8, 1.5),
				Offset = Vector3.new(0, S.Random(-35, -3), 0)
			}
		)
		tween:Play()
		tween.Completed:Connect(function()
			tween:Destroy()
		end)
		local tween2 = TweenService:Create(
			clone3,
			TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				CFrame = clone3.CFrame * CFrame.Angles(0, math.rad((S.Random(100, 179))), 0)
			}
		)
		tween2:Play()
		local v5 = clone3
		tween2.Completed:Connect(function()
			tween2:Destroy()
			debris:AddItem(v5, 1)
		end)
	end

	local clone3 = assets.Shockwave2:Clone()
	clone3.CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	clone3.Mesh.Offset = createVector(0, 0, -15)
	clone3.Mesh.Scale = createVector(40, 40, 40)
	clone3.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(
		clone3.Mesh,
		TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Offset = createVector(0, 0, 28),
			Scale = createVector(0, 0, 80)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
		clone3:Destroy()
	end)
	local clone4 = assets.Shockwave2:Clone()
	clone4.CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	clone4.Mesh.Offset = createVector(0, 0, -20)
	clone4.Mesh.Scale = createVector(30, 30, 60)
	clone4.Parent = workspace._WorldOrigin
	local tween2 = TweenService:Create(
		clone4.Mesh,
		TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Offset = createVector(0, 0, 35),
			Scale = createVector(0, 0, 100)
		}
	)
	tween2:Play()
	tween2.Completed:Connect(function()
		tween2:Destroy()
		clone4:Destroy()
	end)
	local clone5 = assets.Shot:Clone()
	clone5.CFrame = cFrame
	clone5.Parent = workspace._WorldOrigin
	local lastTime = tick()

	while true do
		local v2 = task.wait()
		clone5.CFrame *= CFrame.new(0, 0, -projectileStep * v2 * 60)

		if maxTime < tick() - lastTime or not hitbox:IsDescendantOf(workspace) then
			break
		end

		clone5.Base.Orientation -= Vector3.new(0, 0, 10 * v2 * 60)

		for _, child in clone5.Heads:GetChildren() do
			child.CFrame = clone5.Base["Offset" .. child.Name].WorldCFrame
		end
	end

	debris:AddItem(clone5, 2)

	for _, part in clone5.Heads:GetChildren() do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
		end
	end

	for _, trail in clone5:GetDescendants() do
		if trail:IsA("Trail") then
			trail.Enabled = false
		end
	end

	S.DisableDescendantParticles(clone5)

	for _, trail in clone5:GetDescendants() do
		if trail:IsA("Trail") then
			trail.Enabled = true
		end
	end
end

function v.Explode(p)
	local cFrame = p.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local ground = S.GetGround(cFrame.Position, 15)
	local clone = assets.Explosion:Clone()
	clone:ScaleTo(1)

	if ground then
		clone:PivotTo(CFrame.lookAt(ground.Position, ground.Position + ground.Normal) * CFrame.Angles(
			-1.5707961522619713,
			0,
			0
		))
	else
		clone:PivotTo(cFrame)
		clone.PrimaryPart.Ground:Destroy()
	end

	clone.Parent = workspace._WorldOrigin
	S.EmitDescendants(clone)
	debris:AddItem(clone, 3)
	Util.Sound:Play(
		"BF_WPN_VenomBow_Spit_Z_Explode_0" .. tostring(math.random(1, 4)) .. "_V3",
		clone.PrimaryPart.Position
	)

	if ground then
		local clone2 = assets.SplashVFX:Clone()
		clone2.Position = clone.PrimaryPart.Position + createVector(0, 40, 0)
		clone2.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
		clone2.Mesh.Scale = createVector(8, 80, -8)
		clone2.Decal.Color3 = Color3.new(0.729412, 0.2, 0.701961)
		clone2.Parent = workspace._WorldOrigin
		debris:AddItem(clone2, 3)
		task.spawn(function()
			local Animate = require(clone2.Animate)
			Animate(0.022222222222222223)
		end)
		local clone3 = assets.SplashVFX:Clone()
		clone3.Position = clone.PrimaryPart.Position + createVector(0, 12.5, 0)
		clone3.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
		clone3.Mesh.Scale = createVector(10, 25, -10)
		clone3.Decal.Color3 = Color3.new(0, 0, 0)
		clone3.Parent = workspace._WorldOrigin
		debris:AddItem(clone3, 3)
		task.spawn(function()
			local Animate = require(clone3.Animate)
			Animate(0.03333333333333333)
		end)
		local clone4 = assets.Splat:Clone()
		clone4.Position = ground.Position
		clone4.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
		clone4.Mesh.Scale = createVector(20, 0, -20)
		clone4.Parent = workspace._WorldOrigin
		debris:AddItem(clone4, 3)
		task.spawn(function()
			local Animate = require(clone4.Animate)
			Animate(0.03333333333333333)
		end)
		TweenService:Create(clone4.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Scale = createVector(30, 15, -30),
			Offset = createVector(0, 7.5, 0)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			CFrame = clone4.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
		}):Play()
		S.Rocks(cFrame, createVector(6, 4, 4), 2, 18, 22, 90, assets.Rock)
		local clone5 = assets.Splat:Clone()
		clone5.Position = ground.Position
		clone5.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
		clone5.Mesh.Scale = createVector(20, 0, -20)
		clone5.Parent = workspace._WorldOrigin
		debris:AddItem(clone5, 3)
		task.spawn(function()
			local Animate = require(clone5.Animate)
			Animate(0.05)
		end)
		TweenService:Create(clone5.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Scale = createVector(20, 20, -20),
			Offset = createVector(0, 10, 0)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = clone5.CFrame * CFrame.Angles(0, 0.3490658503988659, 0)
		}):Play()
	end

	task.spawn(function()
		local v2 = ground and 0 or 180

		for _ = 1, 5 do
			local clone2 = assets.ShockwavePoison:Clone()
			clone2.CFrame = cFrame * CFrame.Angles(
				math.rad((S.Random(-v2, v2))),
				math.rad((S.Random(-180, 180))),
				(math.rad((S.Random(-v2, v2))))
			)
			clone2.Mesh.Scale = createVector(0, 70, -0)
			clone2.Parent = workspace._WorldOrigin
			debris:AddItem(clone2, 3)
			task.spawn(function()
				local Animate = require(script.Parent.Animate)
				Animate(1 / math.random(15, 30), clone2)
			end)
			local random = S.Random(1.2, 1.4)
			TweenService:Create(clone2.Mesh, TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = createVector(50, 40, -50) * S.Random(0.5, 1.2) * 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end
	end)
	local v2 = ground and 180 or 90
	local clones = {}

	for _ = 1, 15 do
		local clone2 = assets.ExplosionTrail:Clone()
		clone2.Parent = workspace._WorldOrigin
		clone2.CFrame = CFrame.new(cFrame.Position, createVector(0, 1, 0)) * CFrame.Angles(
			math.rad((S.Random(-v2, v2))),
			math.rad((S.Random(-v2, v2))),
			(math.rad((S.Random(-180, 180))))
		)
		clone2:SetAttribute(
			"TurningSpeed",
			CFrame.Angles(math.rad((S.Random(-2, 2))), math.rad((S.Random(-2, 2))), (math.rad((S.Random(-2, 2)))))
		)
		clone2:SetAttribute("MoveSpeed", S.Random(-3, -0.8))
		table.insert(clones, clone2)
		task.delay(2, function()
			clone2.Trail.Enabled = false
			debris:AddItem(clone2, 1)
		end)
	end

	local v3 = 1
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		v3 *= 0.974

		for _, v4 in clones do
			v4.CFrame = v4.CFrame * v4:GetAttribute("TurningSpeed") * CFrame.new(
				0,
				0,
				v4:GetAttribute("MoveSpeed") * v3
			)
		end
	end)
	task.delay(2, function()
		heartbeatConnection:Disconnect()
	end)
end

function v.Snake(data)
	local anchor = data.Anchor
	local cFrame = data.CFrame

	if (cFrame.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 or not anchor then
		return
	end

	local v2 = false
	Util.Sound:Play("BF_WPN_VenomBow_Activate_01_V2", cFrame.Position)
	local i = data.i
	local clone = assets.HomingHydra:Clone()
	clone.Position = cFrame.Position + Vector3.new(S.Random(-3, 3), S.Random(-3, 3), S.Random(-3, 3))
	clone.Parent = workspace._WorldOrigin
	local magnitude = (clone.Position - anchor.Position).Magnitude
	local v3 = bezier.new({
		clone.Position,
		(CFrame.lookAt(cFrame.Position, anchor.Position) * CFrame.new(80 * i, S.Random(80, 120), -magnitude / 2.5)).Position,
		anchor.Position
	})
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 0.8333333333333334 do
			local v4 = (tick() - lastTime) / 0.8333333333333334

			if v4 < 0.85 then
				v3.Points[3] = anchor.Position
			end

			local deCasteljau = v3:DeCasteljau(v4)
			local deCasteljau2 = v3:DeCasteljau(v4 + 0.01)
			clone.CFrame = CFrame.lookAt(deCasteljau, deCasteljau2)
			clone.Head.CFrame = clone.CFrame
			RunService.Heartbeat:Wait()
		end

		if not v2 then
			v2 = true
			local clone2 = assets.SmallExplosion:Clone()
			clone2.Position = clone.CFrame.Position
			clone2.Parent = workspace._WorldOrigin
			S.EmitDescendants(clone2)
			debris:AddItem(clone2, 3)
			Util.Sound:Play("BF_WPN_VenomBow_Explosion_0" .. tostring(math.random(1, 4)) .. "_V2", clone2.Position)
			local clone3 = assets.SplashVFX:Clone()
			clone3.Position = clone.CFrame.Position + createVector(0, 10, 0)
			clone3.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
			clone3.Mesh.Scale = createVector(3, 20, -3)
			clone3.Decal.Color3 = Color3.new(0.729412, 0.2, 0.701961)
			clone3.Parent = workspace._WorldOrigin
			debris:AddItem(clone3, 3)
			task.spawn(function()
				local Animate = require(clone3.Animate)
				Animate(0.022222222222222223)
			end)
			local clone4 = assets.SplashVFX:Clone()
			clone4.Position = clone.CFrame.Position + createVector(0, 7.5, 0)
			clone4.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
			clone4.Mesh.Scale = createVector(3, 15, -3)
			clone4.Decal.Color3 = Color3.new(0, 0, 0)
			clone4.Parent = workspace._WorldOrigin
			debris:AddItem(clone4, 3)
			task.spawn(function()
				local Animate = require(clone4.Animate)
				Animate(0.03333333333333333)
			end)
			local clone5 = assets.Splat:Clone()
			clone5.Position = clone.CFrame.Position - createVector(0, 3, 0)
			clone5.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
			clone5.Mesh.Scale = createVector(4, 0, -4)
			clone5.Parent = workspace._WorldOrigin
			debris:AddItem(clone5, 3)
			task.spawn(function()
				local Animate = require(clone5.Animate)
				Animate(0.03333333333333333)
			end)
			TweenService:Create(clone5.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = createVector(4, 8, -4),
				Offset = createVector(0, 4, 0)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
			}):Play()
		end

		S.DisableDescendantParticles(clone)

		for _, trail in clone:GetDescendants() do
			if trail:IsA("Trail") then
				trail.Enabled = true
			end
		end

		debris:AddItem(clone, 1)
		clone.Head:Destroy()
	end)
end

return function(p)
	if p.Stage == 1 then
		v.Charge(p)
	elseif p.Stage == 2 then
		v.Shoot(p)
	elseif p.Stage == 3 then
		v.Explode(p)
	elseif p.Stage == 4 then
		v.Snake(p)
	end
end