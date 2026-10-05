local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function windRibbon(cFrame, _)
	local clone = FX:WaitForChild("Weapons").WindFragments:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Color = Color3.fromRGB(0, 0, 0)
	clone.CFrame = cFrame
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(math.random(3, 5) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = clone.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				3.1066860685499065,
				(math.rad((math.random(-25, 25))))
			),
			Size = clone.Size * math.random(6, 8),
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 1
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function hitEffect(root)
	local position = root.Position
	local clone = FX:WaitForChild("Weapons").SwirlSpiral:Clone()
	clone.Size = createVector(1, 0.05, 2)
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = CFrame.new(position) * CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(2.34, 0.05, 35.13),
			CFrame = clone.CFrame * CFrame.Angles(0, 0.3490658503988659, 0)
		}
	)
	clone.Parent = _WorldOrigin
	Util.Sound:Play("QuickSlice", position, nil, 1.3 + math.random(-32, 32) / 100, 0.25)
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1)
	part.Anchored = true
	part.Size = createVector(0.05, 0.05, 0.05)
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	part.Parent = _WorldOrigin
	local clone2 = FX:WaitForChild("Weapons").HitEmitter:Clone()
	Util.Debris:AddItem(clone2, 1)
	clone2.Parent = part
	clone2:emit(1)
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		return
	end

	if stage == 2 then
		local startPos = data.StartPos
		local endPos = data.EndPos

		if (startPos - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local magnitude = (startPos - endPos).magnitude
		local part, position, _ = Util.Ray(
			startPos,
			CFrame.new(startPos, endPos).LookVector.Unit * (magnitude + 2),
			{ workspace.Characters, workspace.Enemies }
		)

		if part then
			local clone = FX:WaitForChild("Weapons").GroundWindFX:Clone()
			Util.Debris:AddItem(clone, 2)
			clone.Position = position
			clone.Parent = _WorldOrigin
			clone.Color = data.Color or clone.Color

			if part:IsA("BasePart") then
				clone.Rock.Color = ColorSequence.new(part.Color)
			end

			spawn(function()
				wait(0.8)
				clone.Wind.Enabled = false
				clone.Rock.Enabled = false
				wait(1)
				clone:Destroy()
			end)
		end

		local clone = FX:WaitForChild("Weapons").WhipWhirlParticles:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.Position = startPos
		local spirals = clone.Attach.Spirals

		if data.Color then
			spirals.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new()),
				ColorSequenceKeypoint.new(0.21, Color3.new()),
				ColorSequenceKeypoint.new(0.36, data.Color),
				ColorSequenceKeypoint.new(1, data.Color)
			})
		end

		clone.Parent = _WorldOrigin
		Util.Sound:Play("Lightning1", startPos, nil, 2.5 + math.random(-32, 32) / 100, 0.55)

		for i = 1, 22 do
			local v2 = i
			spawn(function()
				if 20 % v2 ~= 0 then
					local v3 = CFrame.new(startPos, position) * CFrame.new(
						0,
						0,
						-math.random(5, (math.max(6, magnitude)))
					) * CFrame.Angles(1.5707963267948966, 0, 0)
					windRibbon(CFrame.new(v3.p))
				end

				local v4 = v2 % 2 == 0
				local clone2

				if v4 then
					clone2 = FX:WaitForChild("Weapons").SwirlCrescent:Clone()
				else
					clone2 = FX:WaitForChild("Weapons").WindFragments:Clone()
				end

				Util.Debris:AddItem(clone2, 2)
				clone2.Transparency = v4 and 0.4 or 0.8
				Util.Sound:Play("SpinWoosh", startPos, nil, 1.5 + math.random(-42, 42) / 100, 0.75)
				local cframe = CFrame.Angles(
					math.rad((math.random(-15, 15))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-15, 15))))
				)
				local v5 = v4 and math.random(75, 85) or math.random(95, 105)
				clone2.Size = Vector3.new(v5, v4 and 5 or 20, v5)
				clone2.Color = Color3.fromRGB(255, 255, 255)
				clone2.Color = data.Color or clone2.Color
				clone2.CFrame = CFrame.new(startPos) * cframe
				local v6 = ({ -1, 1 })[math.random(1, 2)] * 179
				local tween = TweenService:Create(
					clone2,
					TweenInfo.new(v4 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = Vector3.new(5, v4 and 1 or 3, 5),
						Position = endPos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
						Transparency = part and (v4 and 0.4 or 0.8) or 1
					}
				)
				local v10 = TweenService:Create(
					clone2,
					TweenInfo.new(v4 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
					{
						Orientation = clone2.Orientation + Vector3.new(0, v6, 0)
					}
				)
				v10.Completed:Connect(function()
					if clone2 then
						v10 = TweenService:Create(
							clone2,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Orientation = clone2.Orientation + Vector3.new(0, v6, 0)
							}
						)
						v10:Play()
					end
				end)
				tween.Completed:Connect(function()
					if not part then
						clone2:Destroy()
						return
					end

					local tween2 = TweenService:Create(
						clone2,
						TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = Vector3.new(v5, 3, v5),
							Transparency = 1,
							CFrame = clone2.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
								math.rad((math.random(-5, 5))),
								v6,
								(math.rad((math.random(-5, 5))))
							)
						}
					)
					tween2.Completed:Connect(function()
						clone2:Destroy()
					end)
					tween2:Play()
				end)
				clone2.Parent = _WorldOrigin
				tween:Play()
				v10:Play()
			end)
			wait(0.025)
		end

		spawn(function()
			spirals.Enabled = false
			wait(1)
			clone:Destroy()
		end)
	else
		local root = stage == 3 and data.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			else
				hitEffect(root)
			end
		end
	end
end