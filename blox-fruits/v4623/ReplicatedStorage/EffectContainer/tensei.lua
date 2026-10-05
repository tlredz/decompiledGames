local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = workspace._WorldOrigin
game:GetService("TweenService")
game:GetService("RunService")

local function ScaleModel(instance, p)
	local primaryPart = instance.PrimaryPart
	local cFrame = primaryPart.CFrame

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size *= p

		if part ~= primaryPart then
			part.CFrame = cFrame + cFrame:inverse() * part.Position * p
		end
	end

	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroy(clone, p)
	spawn(function()
		wait(p)

		if clone then
			clone:Destroy()
		end
	end)
end

local function crack(clone, i, max)
	local _ = Util.Sound
	local _ = Util.MasterClock
	local children = clone:GetChildren()

	for i2 = 1, #children do
		if children[i2] == clone.PrimaryPart then
			continue
		end

		local cFrame = children[i2].CFrame
		children[i2].Parent = nil
		children[i2].CFrame = CFrame.new(cFrame.p) * CFrame.new(
			math.random(-1000, 1000),
			-1000,
			math.random(-1000, 1000)
		) * CFrame.Angles(
			math.rad((math.random(-360, 360))),
			math.rad((math.random(-360, 360))),
			(math.rad((math.random(-360, 360))))
		)
		local ray = Ray.new(cFrame.p, (cFrame.Position - children[i2].Position).unit * -1000)
		local part, v, _ = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Map })
		children[i2].CFrame = CFrame.new(v) * CFrame.Angles(
			math.rad((math.random(-360, 360))),
			math.rad((math.random(-360, 360))),
			(math.rad((math.random(-360, 360))))
		)

		if part then
			children[i2].Color = part.Color
			children[i2].Material = part.Material
		end

		local v2 = i2
		spawn(function()
			wait(math.random(300, 800) / 1000)
			children[v2].Parent = clone
			Util.ReplicatedTween:Create(
				children[v2],
				TweenInfo.new(
					math.random(500, 1000) / 1000,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out,
					0,
					false,
					0
				),
				{
					CFrame = cFrame
				}
			):Play()
		end)
		local v4 = i2
		local cFrame2 = cFrame
		spawn(function()
			if i == max then
				wait(2)
				Util.ReplicatedTween:Create(
					children[v4],
					TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0),
					{
						CFrame = clone.PrimaryPart.CFrame:lerp(cFrame2, 0.75),
						Size = children[v4].Size * 0.75
					}
				):Play()
				wait(0.35)
				children[v4].Anchored = false
				local v6 = children[v4].Size.Magnitude * 7
				children[v4].Velocity = Vector3.new(math.random(-v6, v6), math.random(-50, 175), math.random(-v6, v6))
				children[v4].RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				local touchedConnection = nil
				touchedConnection = children[v4].Touched:connect(function(instance)
					if instance and instance:IsDescendantOf(workspace.Map) then
						children[v4].Anchored = true
						children[v4].Transparency = 1
						local clone2 = script.ParticleEmitter:Clone()
						clone2.Parent = children[v4]
						clone2.Color = ColorSequence.new(children[v4].Color)
						clone2.Size = NumberSequence.new(children[v4].Size.Magnitude / 2)
						clone2:Emit(25)
						local Sound = require(game.ReplicatedStorage.Util.Sound)
						Sound:Play("tensei.brickburst" .. math.random(1, 3), children[v4])
						touchedConnection:Disconnect()
					end
				end)
			end
		end)
	end
end

local function wave(cFrame)
	for i = 1, 6 do
		local clone = script.CircleShockwave:Clone()
		clone.Parent = workspace._WorldOrigin
		clone.CFrame = cFrame * CFrame.Angles(math.rad(i * 60), 0, 0)
		Util.ReplicatedTween:Create(
			clone,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = createVector(300, 2, 300)
			}
		):Play()
		destroy(clone, 0.25) -- equivalent call inferred; original call site unknown
	end
end

local v = {}

local function scale(instance, p)
	if v[p] == nil then
		ScaleModel(instance, p)
		v[p] = instance:clone()
		return instance
	else
		local clone = v[p]:Clone()
		clone.Parent = instance.Parent
		instance:Destroy()
		return clone
	end
end

return function(data)
	local _ = Util.Sound
	local _ = Util.MasterClock
	local _ = data.target
	local char = data.char
	local max = data.max
	local targetCF = data.targetCF
	local clone = script.orb:Clone()
	clone.Parent = workspace._WorldOrigin
	clone:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame)
	clone.PrimaryPart.Attachment.ParticleEmitter:Emit(1)
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	Sound:Play("tensei.orbsfx2", clone.PrimaryPart)
	Util.ReplicatedTween:Create(
		clone.PrimaryPart,
		TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = targetCF
		}
	):Play()
	wait(2)
	local Sound2 = require(game.ReplicatedStorage.Util.Sound)
	Sound2:Play("tensei.orbsfx", clone.PrimaryPart)
	local size = script.phoeyuRock.Ball.Size

	for i = 1, max do
		if i == max then
			Util.ReplicatedTween:Create(
				clone.PrimaryPart.sfx,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Volume = 0
				}
			):Play()
		end

		local clone2 = script.phoeyuRock:Clone()
		local v2 = i + 1

		if v[v2] == nil then
			ScaleModel(clone2, v2)
			v[v2] = clone2:clone()
		else
			local clone3 = v[v2]:Clone()
			clone3.Parent = clone2.Parent
			clone2:Destroy()
			clone2 = clone3
		end

		clone2:SetPrimaryPartCFrame(targetCF)
		clone2:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame * CFrame.Angles(
			math.rad((math.random(-360, 360))),
			math.rad((math.random(-360, 360))),
			(math.rad((math.random(-360, 360))))
		))
		local size2 = clone2.PrimaryPart.Size
		clone2.PrimaryPart.Size = size
		size = size2 * 0.25
		crack(clone2, i, max)
		clone2.Parent = workspace._WorldOrigin
		Util.ReplicatedTween:Create(
			clone2.PrimaryPart,
			TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = size2
			}
		):Play()

		if i == max then
			wait(2)
			Util.ReplicatedTween:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = clone2.PrimaryPart.Size * 0.75
				}
			):Play()
			wait(0.35)
			wave(clone2.PrimaryPart.CFrame)
			local Sound3 = require(game.ReplicatedStorage.Util.Sound)
			Sound3:Play("tensei.phoeyuRocksfx", clone2.PrimaryPart)

			if (workspace.CurrentCamera.CFrame.p - targetCF.p).magnitude <= 1000 then
				Util.CameraShaker:ShakeOnce(10, 2, 0.5, 1, createVector(1, 2, 1), createVector(1, 1, 1))
			end

			Util.ReplicatedTween:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = clone2.PrimaryPart.Size * 2,
					Transparency = 1
				}
			):Play()
			destroy(clone2, 15) -- equivalent call inferred; original call site unknown
		else
			destroy(clone2, 1.8) -- equivalent call inferred; original call site unknown
		end

		wait(0.25)
	end

	clone:Destroy()
end