local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("Spirit").Z
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local _ = Util.RenderLoop

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function vanishSmoke(position, value)
	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local cFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)

	for _ = 1, 8 do
		local clone = Z.Cloud:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.Size = Vector3.new()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v2 = math.random(25, 38)
		local v3 = math.random(30, 50) / 100
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(v3 / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = Vector3.new(v2, v2, v2) * (value or 1)
			}
		)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = cFrame * CFrame.new(0, math.random(5, 15), 0 - math.random(20, 30)) * CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
			}
		)
		tween.Completed:Connect(function()
			if clone then
				clone:Destroy()
			end
		end)
		tween:Play()
		tween2:Play()
		cFrame *= CFrame.Angles(0, 0.7853981633974483, 0)
	end
end

local function windRing(cFrame)
	local clone = Z.Wind:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.CFrame = cFrame
	clone.Size = Vector3.new()
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.Angles(0, 3.07177948351002, 0),
			Size = createVector(75.9, 33.397, 76.155)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function soulBall(position, position2, duration)
	local clone = Z.Ball:Clone()
	Util.Debris:AddItem(clone, duration + 1.5)
	clone.Position = position
	clone.Parent = _WorldOrigin
	task.spawn(function()
		task.wait(duration / 2)
		local clone2 = Z.Blast:Clone()
		Util.Debris:AddItem(clone2, 3)
		clone2.Position = (position + position2) / 2
		clone2.Parent = _WorldOrigin
		clone2.Slash:Emit(2)
	end)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Position = position2
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		clone.Center.Burst.Enabled = false
		clone.Center.Ring.Enabled = false
		clone.Trail.Enabled = false
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1
			}
		)
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		tween2:Play()
	end)
	Util.Sound:Play("ElectricBounce", clone, nil, math.random(16, 20) / 10, 1)
end

local function captureField(position: Vector3, p: number)
	local parent = Util.Sound:Play("IceSummon", position, nil, 1.5, 1)
	local flangeSoundEffect = Instance.new("FlangeSoundEffect")
	flangeSoundEffect.Depth = 0.2
	flangeSoundEffect.Rate = 1
	flangeSoundEffect.Parent = parent
	local tween = TweenService:Create(
		parent,
		TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			PlaybackSpeed = 0.9
		}
	)
	local tween2 = TweenService:Create(
		parent,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Volume = 0
		}
	)
	tween2.Completed:Connect(function()
		parent:Destroy()
	end)
	tween.Completed:Connect(function()
		tween2:Play()
	end)
	tween:Play()
	local clone = Z.FieldBubble:Clone()
	Util.Debris:AddItem(clone, p + 1)
	local core = clone.Core
	clone.Position = position
	clone.Parent = _WorldOrigin
	task.spawn(function()
		for _ = 1, 5 do
			windRing(CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(1, 360))),
				math.rad((math.random(1, 360))),
				(math.rad((math.random(1, 360))))
			))

			for _, child in pairs(core:GetChildren()) do
				child:Emit((child:GetAttribute("EmitCount")))
			end

			task.wait(0.05)
		end
	end)
	local tween3 = TweenService:Create(
		clone.Mesh,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Scale = createVector(40, 40, 40)
		}
	)
	tween3:Play()
	tween3.Completed:Connect(function()
		local tween4 = TweenService:Create(
			clone,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1
			}
		)
		tween4.Completed:Connect(function()
			task.delay(2, function()
				if clone then
					clone:Destroy()
				end
			end)
		end)
		task.delay(0.35, function()
			tween4:Play()
		end)
	end)
end

local function iceCube(cFrame: CFrame, size: Vector3, vector2: Vector3, p: number)
	local clone = Z.FrozenBlock:Clone()
	debris:AddItem(clone, p + 5)
	clone.Size = size
	clone.CFrame = cFrame
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = vector2
		}
	)
	clone.Parent = _WorldOrigin
	tween:Play()
	return clone
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		captureField(position, 2)
	elseif stage == 2 then
		local position = data.Position
		local timestamp = data.Timestamp
		local stuckTime = data.StuckTime

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		local v = math.max(0.1, stuckTime - (masterClock:GetTime() - timestamp))
		local cFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
		task.delay(v, function()
			vanishSmoke(position, 1.2)
			local clone = Z.Blast:Clone()
			Util.Debris:AddItem(clone, 5)
			local blastSmoke = clone.At.BlastSmoke
			local spikes = clone.Spikes
			local sparks = clone.Sparks
			clone.Position = position
			clone.Parent = _WorldOrigin
			Util.Sound:Play("Explosion2", position, nil, 1, 0.8)
			Util.Sound:Play("IcebergExplosion2", position, nil, 0.8, 1)
			blastSmoke:Emit(math.random(20, 25))
			spikes:Emit(math.random(4, 5))
			sparks:Emit(math.random(15, 20))
		end)
		local v3 = { -11, 11 }
		local v4 = { -11, 11 }

		for i = 1, 10 do
			if i == 1 then
				local parent = iceCube(cFrame, Vector3.new(), createVector(30, 30, 30), v)
				task.delay(0.05, function()
					local v6 = { 0.15, 0.3, 0.4 }

					for i2 = 1, 3 do
						Util.Sound:Play("BlockedHit1", position, nil, v6[i2], 0.3)
						task.wait(i2 == 1 and 0.3 or 0.15)
					end
				end)

				for _ = 1, 10 do
					local clone = parent.Center:Clone()
					clone.Parent = parent
					clone.Orientation = Vector3.new(
						math.random(1, 6) * 60,
						math.random(1, 6) * 60,
						math.random(1, 6) * 60
					)
					local attachment = Instance.new("Attachment")
					attachment.Parent = parent
					attachment.Position = clone.Position
					local beam = Instance.new("Beam")
					beam.Texture = "rbxassetid://7251229594"
					beam.TextureSpeed = 0
					beam.Brightness = 5
					beam.LightEmission = 1
					beam.LightInfluence = 0
					beam.Width0 = 0
					beam.Width1 = 0
					beam.Color = ColorSequence.new(Color3.fromRGB(255, 94, 0))
					beam.Attachment0 = attachment
					beam.Attachment1 = clone
					beam.FaceCamera = true
					beam.Parent = parent
					local tween = TweenService:Create(
						beam,
						TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Width0 = 1,
							Width1 = math.random(5, 15)
						}
					)
					local tween2 = TweenService:Create(
						attachment,
						TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							CFrame = attachment.CFrame:ToObjectSpace(clone.CFrame) * CFrame.new(
								0,
								math.random(50, 70),
								0
							)
						}
					)
					tween:Play()
					tween2:Play()
					tween.Completed:Connect(function()
						if beam then
							beam:Destroy()
						end
					end)
				end

				local tween = TweenService:Create(
					parent,
					TweenInfo.new(
						math.random(15, 35) / 100,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					),
					{
						Size = Vector3.new()
					}
				)
				tween.Completed:Connect(function()
					if parent then
						parent:Destroy()
					end
				end)
				task.delay(v, function()
					tween:Play()
				end)
			else
				local cframe = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
				local _ = v3[math.random(1, #v3)]
				local _ = v4[math.random(1, #v4)]
				local v5 = math.random(-10, 10)
				local v6 = CFrame.new(cFrame.Position) * cframe * (Vector3.new(v3[math.random(1, #v3)]) + Vector3.new(
					0,
					v5,
					0
				))
				local v8 = iceCube(
					CFrame.new(v6) * CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360)),
					Vector3.new(),
					Vector3.new(math.random(5, 11), math.random(5, 11), math.random(5, 11)),
					v
				)
				local velocity = CFrame.new(cFrame.Position, v8.Position).LookVector.Unit * math.random(50, 100)
				task.delay(v, function()
					if v8 then
						v8.Anchored = false
						v8.Velocity = velocity
						v8.RotVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
						local tween = TweenService:Create(
							v8,
							TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = Vector3.new()
							}
						)
						tween.Completed:Connect(function()
							if v8 then
								v8:Destroy()
							end
						end)
						task.delay(0.5, function()
							tween:Play()
						end)
					end
				end)
			end
		end
	elseif stage == 3 then
		if (data.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end
	else
		local root = stage == 4 and data.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local clone = Z.ZCharge.At:Clone()
			Util.Debris:AddItem(clone, 3)
			clone.Parent = root
			clone.Ring:Emit(1)
			clone.Sparkle:Emit(1)
			Util.Sound:Play("MagicCast", root.Position, nil, 2, 1)
		end
	end
end