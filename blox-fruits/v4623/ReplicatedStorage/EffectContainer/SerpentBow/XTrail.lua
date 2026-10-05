local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sound = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function CreatePart()
	local part = Instance.new("Part")
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Anchored = true
	part.CanCollide = false
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Brick
	specialMesh.Scale = createVector(5, 5, 5)
	specialMesh.Parent = part
	return part, specialMesh
end

function RandomCFRot()
	return CFrame.Angles(math.rad((math.random(360))), math.rad((math.random(360))), (math.rad((math.random(360)))))
end

function RandomV3(value)
	return Vector3.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10) * (value or 1)
end

return function(data)
	local cFrame = data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
		return
	end

	local hitbox = data.Hitbox
	local maxTime = data.MaxTime or 10

	if not hitbox then
		return
	end

	local value = hitbox:WaitForChild("Value", 0.5)

	if not value then
		return
	end

	local connections = {}
	local clone = FX:WaitForChild("SerpentBow").XSnakeHead:Clone()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endmove()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end

	local clone2 = FX:WaitForChild("SerpentBow").ShockRing:Clone()
	clone2.CFrame = hitbox.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
	local tween = TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1,
		Color = Color3.fromRGB(251, 251, 255),
		Size = createVector(35.532, 2.952, 35.532)
	})
	table.insert(connections, tween.Completed:Connect(function()
		clone2:Destroy()
	end))
	clone2.Parent = _WorldOrigin
	sound:Play("BowLaunch1", cFrame, nil, 1.5, 2)

	for _ = 1, math.random(13, 25) do
		local v, v2 = CreatePart()
		v.CFrame = hitbox.CFrame * RandomCFRot()
		v.Transparency = 0.25
		v.Material = Enum.Material.Neon
		v.Color = Color3.fromRGB(173, 58, 255)
		v2.Scale = createVector(10, 10, 10)
		local tween2 = TweenService:Create(v2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = createVector(0, 0, 0)
		})
		local tween3 = TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v.Position + RandomV3(15) + hitbox.CFrame.LookVector * 10) * RandomCFRot()
		})
		table.insert(connections, tween2.Completed:Connect(function()
			v:Destroy()
		end))
		v.Parent = _WorldOrigin
		tween2:Play()
		tween3:Play()
	end

	local lastTime = tick()
	local v = hitbox.CFrame * CFrame.new(5, 0, 0) * CFrame.Angles(0, 0, 0.08726646259971647)
	local children = FX:WaitForChild("SerpentBow").StringyMeshs:GetChildren()
	clone.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
	clone.Parent = _WorldOrigin
	tween:Play()
	local lastTime2 = tick()
	local v2 = sound:Play("HissLoop1", clone, nil, nil, 1.5)
	local total = 15
	local total2 = 5

	while tick() - lastTime < maxTime and value.Value == false do
		RunService.RenderStepped:Wait()

		if value.Value == true then
			break
		end

		if (hitbox.Position - v.Position).Magnitude >= 1 then
			local v3 = hitbox.CFrame * CFrame.Angles(0, 0, (math.rad(total))) * CFrame.new(5, 0, 0)
			local magnitude = (v.Position - v3.Position).Magnitude
			local v4, v5 = CreatePart()
			v5.MeshType = Enum.MeshType.Cylinder
			v4.CFrame = CFrame.new(v.Position, v3.Position) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			clone.CFrame = v3 * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -magnitude / 2)
			v4.Size = createVector(1, 1, 1)
			v5.Scale = Vector3.new(magnitude, 1.5, 1.5)
			local tween2 = TweenService:Create(
				v5,
				TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false),
				{
					Scale = Vector3.new(v5.Scale.X, 0, 0)
				}
			)
			table.insert(connections, tween2.Completed:Connect(function()
				v4:Destroy()
			end))
			v4.Transparency = 0
			v4.Color = Color3.fromRGB(255, 3, 251)
			v4.Material = Enum.Material.Neon
			v4.Anchored = true
			v4.CanCollide = false
			v4.Parent = _WorldOrigin
			tween2:Play()

			if total2 < 20 then
				total2 += 20
			end

			total += total2
			v = v3
		end

		if tick() - lastTime2 >= 0.2 then
			lastTime2 = tick()
			local clone3 = FX:WaitForChild("SerpentBow").ShockRing:Clone()
			clone3.CFrame = hitbox.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					CFrame = clone3.CFrame * CFrame.new(0, -35, 0),
					Transparency = 1,
					Color = Color3.fromRGB(251, 251, 255),
					Size = createVector(35.532, 3.952, 35.532)
				}
			)
			table.insert(connections, tween2.Completed:Connect(function()
				clone3:Destroy()
			end))
			clone3.Parent = _WorldOrigin
			tween2:Play()
		end

		local clone3 = children[math.random(1, #children)]:Clone()
		clone3.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		local tween2 = TweenService:Create(
			clone3,
			TweenInfo.new(math.random(10, 15) / 35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Size = clone3.Size * math.random(15, 20),
				Transparency = 1,
				CFrame = clone3.CFrame * RandomCFRot()
			}
		)
		table.insert(connections, tween2.Completed:Connect(function()
			clone3:Destroy()
		end))
		clone3.Parent = _WorldOrigin
		tween2:Play()
	end

	sound:Kill(v2)
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	TweenService:Create(clone.accent, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	clone.Attachment.ParticleEmitter.Enabled = false
	clone.Attachment.ParticleEmitter1.Enabled = false
	clone.Attachment.ParticleEmitter2.Enabled = false
	Util.Debris:AddItem(clone, 1)
	wait(1.6)
	endmove() -- equivalent call inferred; original call site unknown
end