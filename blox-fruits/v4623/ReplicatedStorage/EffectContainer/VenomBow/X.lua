local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local RunService = game:GetService("RunService")
local assets = script.Assets
local currentCamera = workspace.CurrentCamera
local S = Util.S
local bezier = Util.Bezier
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSpiralPosition(p, p2)
	return (Vector3.new(
		math.cos(p * 8 + p2 * 3.141592653589793 * 3.33) * 10.5,
		14 * p / p2,
		math.sin(p * 8 + p2 * 3.141592653589793 * 3.33) * 10.5
	))
end

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
	local cFrame = data.CFrame
	local root = data.Root
	local maxTime = data.MaxTime
	local hitbox = data.Hitbox
	local projectileStep = data.ProjectileStep

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local cFrame2 = cFrame * CFrame.new(0, 0, -3)
	local v3 = maxTime * projectileStep * 60
	local position = cFrame * Vector3.new(0, 0, -v3)
	local _ = { workspace.Characters, workspace.Enemies, root.Parent }
	Util.Sound:Play("BF_WPN_VenomBow_SerpentBite_Xfire_01_V3", cFrame2.Position)
	local v4 = 1

	for i = 1, 3 do
		local clone = assets.Hydra:Clone()
		clone.CFrame = cFrame2
		clone.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(clone, maxTime + 3)
		local v5 = bezier.new({
			cFrame2.Position,
			(CFrame.lookAt(cFrame2.Position, position) * CFrame.new(S.Random(40, 0) * v4, S.Random(-0, 20), -v3)).Position,
			position
		})
		v4 *= -1
		local deCasteljau = v5:DeCasteljau(0)
		local deCasteljau2 = v5:DeCasteljau(0.01)
		clone.CFrame = CFrame.lookAt(deCasteljau, deCasteljau2)
		local clone2 = assets.Shoot:Clone()
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -6)
		clone2.Parent = workspace._WorldOrigin
		S.EmitDescendants(clone2)
		debris:AddItem(clone2, 1)
		local v8 = i
		task.spawn(function()
			local maxTime2 = maxTime
			local lastTime = tick()

			while tick() - lastTime < maxTime2 and not (maxTime2 < tick() - lastTime) and not hitbox:GetAttribute("TargetPoint") and hitbox:IsDescendantOf(workspace) do
				local v10 = (tick() - lastTime) / (maxTime2 * 1.2)
				local deCasteljau3 = v5:DeCasteljau(v10)
				local deCasteljau4 = v5:DeCasteljau(v10 + 0.01)
				clone.CFrame = CFrame.lookAt(deCasteljau3, deCasteljau4)
				clone.Velocity = clone.CFrame.LookVector * 15
				RunService.RenderStepped:Wait()
			end

			local lastTime2 = tick()

			repeat
				task.wait()
			until hitbox:GetAttribute("TargetPoint") or tick() - lastTime2 > 3

			if not hitbox:GetAttribute("TargetPoint") then
				return
			end

			local cframe2 = CFrame.new(hitbox:GetAttribute("TargetPoint"))
			Util.Sound:Play(
				"BF_WPN_VenomBow_SerpentBite_X_Hit_0" .. tostring(math.random(1, 3)) .. "_V3",
				clone.Position
			)
			task.spawn(function()
				local clone3 = assets.ShockwavePoison:Clone()
				clone3.CFrame = cframe2 * CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
				clone3.Mesh.Scale = createVector(0, 28, -0)
				clone3.Parent = workspace._WorldOrigin
				debris:AddItem(clone3, 3)
				task.spawn(function()
					local Animate = require(script.Parent.Animate)
					Animate(1 / math.random(20, 45), clone3)
				end)
				local random = S.Random(1.2, 1.4)
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Scale = createVector(40, 30, -40) * S.Random(0.5, 1.2) * 0.7
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(0, 3.12413936106985, 0)
				}):Play()
			end)
			local lastTime3 = tick()

			while tick() - lastTime3 < 0.39999999999999997 do
				local v10 = (tick() - lastTime3) / 0.39999999999999997
				local spiralPosition = GetSpiralPosition(v10, v8) -- equivalent call inferred; original call site unknown
				local spiralPosition2 = GetSpiralPosition(v10 + 0.01, v8) -- equivalent call inferred; original call site unknown
				position = cframe2.Position
				clone.CFrame = clone.CFrame:Lerp(
					CFrame.lookAt(position + spiralPosition, position + spiralPosition2),
					0.25
				)
				RunService.RenderStepped:Wait()
			end

			S.EmitDescendants(clone)
			S.DisableDescendantParticles(clone)
			clone.Transparency = 1
		end)
		task.wait(0.1)
	end
end

function v.Bite(p)
	local targetPosition = p.TargetPosition
	local biteSpeed = p.BiteSpeed

	if (targetPosition - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local clone = assets.Bite:Clone()
	clone:ScaleTo(0.7)
	clone:PivotTo(CFrame.lookAt(targetPosition + createVector(0, 7, 0), currentCamera.CFrame.Position))
	clone.Parent = workspace._WorldOrigin
	clone.PrimaryPart.Attachment.Bite.Lifetime = NumberRange.new(biteSpeed * 2.5)
	S.EmitDescendants(clone)
	debris:AddItem(clone, 3)
	task.wait(biteSpeed)

	for _ = 1, 4 do
		local clone2 = assets.Shockwave:Clone()
		clone2.CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(
			math.rad((S.Random(-180, 180))),
			math.rad((S.Random(-180, 180))),
			(math.rad((S.Random(-180, 180))))
		)
		clone2.Mesh.Scale = createVector(0, 5, 0)
		clone2.Parent = workspace._WorldOrigin
		debris:AddItem(clone2, 3)
		task.spawn(function()
			local Animate = require(script.Parent.Animate)
			Animate(1 / math.random(30, 60), clone2)
		end)
		local random = S.Random(0.7, 1.4)
		TweenService:Create(clone2.Mesh, TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Scale = createVector(20, 25, -20) * S.Random(0.8, 1.5)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(random, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(0, 0, -S.Random(1, 5)) * CFrame.Angles(
				0,
				math.rad((S.Random(100, 179))),
				0
			)
		}):Play()
	end

	local ground = S.GetGround(targetPosition, 8)

	if not ground then
		return
	end

	local clone2 = assets.SplashVFX:Clone()
	clone2.Position = targetPosition + createVector(0, 14, 0)
	clone2.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
	clone2.Mesh.Scale = createVector(7, 28, -7)
	clone2.Decal.Color3 = Color3.new(0, 0, 0)
	clone2.Parent = workspace._WorldOrigin
	debris:AddItem(clone2, 3)
	task.spawn(function()
		local Animate = require(clone2.Animate)
		Animate(0.03333333333333333)
	end)
	Util.Sound:Play(
		"BF_WPN_VenomBow_SerpentBite_Xplosion_0" .. tostring(math.random(1, 3)) .. "_V3",
		clone.PrimaryPart.Position
	)
	local clone3 = assets.Splat:Clone()
	clone3.Position = ground.Position
	clone3.CFrame *= CFrame.Angles(0, math.rad((S.Random(-180, 180))), 0)
	clone3.Mesh.Scale = createVector(14, 0, -14)
	clone3.Parent = workspace._WorldOrigin
	debris:AddItem(clone3, 3)
	task.spawn(function()
		local Animate = require(clone3.Animate)
		Animate(0.03333333333333333)
	end)
	TweenService:Create(clone3.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = createVector(21, 10.5, -21),
		Offset = createVector(0, 5.25, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
	}):Play()
end

return function(p)
	if p.Stage == 1 then
		v.Shoot(p)
	elseif p.Stage == 2 then
		v.Bite(p)
	end
end