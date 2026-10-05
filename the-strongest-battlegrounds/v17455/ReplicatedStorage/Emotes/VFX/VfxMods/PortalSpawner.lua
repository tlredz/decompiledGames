local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local thrown = game.Workspace.Thrown
local LightningModule = require(game.ReplicatedStorage:WaitForChild("Resources"):WaitForChild("LightningModule"))

local function fn(cframe: CFrame?, thrown2)
	if cframe then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		elseif typeof(cframe) ~= "CFrame" then
			cframe = nil
		end
	end

	if not thrown2 then
		thrown2 = workspace:FindFirstChild("MeshCache")

		if not thrown2 then
			thrown2 = Instance.new("Folder")
			thrown2.Name = "MeshCache"
			thrown2.Parent = workspace
		end
	end

	local v = cframe or CFrame.new(0, 0, 0)
	local v2 = {
		Sidering1 = script.StartMesh.Sidering1,
		fastglass = script.StartMesh.fastglass,
		glassIN = script.StartMesh.glassIN
	}
	local v3 = {
		[v2.Sidering1] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
				Tween_Duration = 0.5,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(20, 0.001, 20),
					CFrame = v * CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.fastglass] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.470561028, 0, -0.882366598, 0, 1, 0, 0.882366598, 0, 0.470561028),
				Tween_Duration = 0.2,
				Transparency = 4
			},
			BasePart = {
				Property = {
					Size = createVector(20, 0.001, 20),
					CFrame = v * CFrame.new(
						0.0000152362973,
						0,
						8.28109876e-7,
						0.054270979,
						0,
						0.998525441,
						0,
						1,
						0,
						-0.998525441,
						0,
						0.054270979
					),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 8
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Quad
				}
			}
		},
		[v2.glassIN] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
				Tween_Duration = 0.15,
				Transparency = 4
			},
			BasePart = {
				Property = {
					Size = createVector(15, 0.001, 15),
					CFrame = v * CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 8
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		}
	}

	for k, v4 in pairs(v3) do
		if not (k and k:IsDescendantOf(game) and k:FindFirstChild("Start")) then
			continue
		end

		local v5 = k
		local v6 = v4

		local function Emit()
			local clone = v5.Start:Clone()
			clone.Name = v5.Name
			clone.Transparency = v6.General.Transparency

			if clone:FindFirstChildOfClass("Decal") then
				local decal = clone:FindFirstChildOfClass("Decal")
				decal.Transparency = v6.General.Transparency
				clone.Transparency = 1
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Locked = true
			clone.CFrame = v * v6.General.Offset
			clone.Parent = thrown2
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(
				clone,
				TweenInfo.new(
					v6.General.Tween_Duration,
					v6.BasePart.Tween.Easing_Style,
					v6.BasePart.Tween.Easing_Direction
				),
				v6.BasePart.Property
			):Play()
			task.delay(v6.General.Tween_Duration, clone.Destroy, clone)
		end

		task.spawn(Emit)
	end
end

local function fn2(cFrame, thrown2)
	local v

	if typeof(cFrame) == "Instance" and cFrame:IsA("BasePart") then
		v = cFrame
		cFrame = cFrame.CFrame
	else
		v = nil
	end

	if cFrame then
		if typeof(cFrame) == "Vector3" then
			cFrame = CFrame.new(cFrame)
		elseif typeof(cFrame) ~= "CFrame" then
			cFrame = nil
		end
	end

	if not thrown2 then
		thrown2 = workspace:FindFirstChild("MeshCache")

		if not thrown2 then
			thrown2 = Instance.new("Folder")
			thrown2.Name = "MeshCache"
			thrown2.Parent = workspace
		end
	end

	local v2 = cFrame or CFrame.new(0, 0, 0)
	local v3 = {
		neonIN = script.EndMesh.neonIN,
		glassIN = script.EndMesh.glassIN
	}
	local v4 = {
		[v3.glassIN] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Tween_Duration = 0.15,
				Transparency = 4
			},
			BasePart = {
				Property = {
					Size = createVector(0.002, 0.002, 0.002),
					CFrame = v2 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 8
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v3.neonIN] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Tween_Duration = 0.2,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(0.002, 0.002, 0.002),
					CFrame = v2 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		}
	}

	for k, v5 in pairs(v4) do
		if not (k and k:IsDescendantOf(game) and k:FindFirstChild("Start")) then
			continue
		end

		local v6 = k
		local v7 = v5

		local function Emit()
			local clone = v6.Start:Clone()
			clone.Name = v6.Name
			clone.Transparency = v7.General.Transparency

			if clone:FindFirstChildOfClass("Decal") then
				local decal = clone:FindFirstChildOfClass("Decal")
				decal.Transparency = v7.General.Transparency
				clone.Transparency = 1
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Locked = true
			clone.CFrame = (v and v.CFrame or v2) * v7.General.Offset
			clone.Parent = thrown2
			local property

			if v then
				local property2 = v7.BasePart.Property
				property = {
					Size = property2.Size,
					Color = property2.Color,
					Transparency = property2.Transparency
				}
			else
				property = v7.BasePart.Property
			end

			TweenService:Create(
				clone,
				TweenInfo.new(
					v7.General.Tween_Duration,
					v7.BasePart.Tween.Easing_Style,
					v7.BasePart.Tween.Easing_Direction
				),
				property
			):Play()

			if v then
				local offset = v7.General.Offset
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					if clone.Parent and v.Parent then
						clone.CFrame = v.CFrame * offset
					else
						renderSteppedConnection:Disconnect()
					end
				end)
				clone.Destroying:Once(function()
					if renderSteppedConnection.Connected then
						renderSteppedConnection:Disconnect()
					end
				end)
			end

			task.delay(v7.General.Tween_Duration, clone.Destroy, clone)
		end

		task.spawn(Emit)
	end
end

local PortalSpawner = {}
local random = Random.new()

function PortalSpawner.EmitAttributes(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount")) then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDuration = emitter:GetAttribute("EmitDuration")

		if emitDuration and emitDuration > 0 then
			if emitDelay and emitDelay > 0 then
				local v = emitter
				local v2 = emitDuration
				task.delay(emitDelay, function()
					v.Enabled = true
					task.delay(v2, function()
						v.Enabled = false
					end)
				end)
			else
				emitter.Enabled = true
				local v = emitter
				task.delay(emitDuration, function()
					v.Enabled = false
				end)
			end
		elseif emitDelay and emitDelay > 0 then
			local v = emitter
			local v2 = emitCount
			task.delay(emitDelay, function()
				v:Emit(v2)
			end)
		else
			emitter:Emit(emitCount)
		end
	end
end

function PortalSpawner.ScaleTween(instance, p, duration, p2, p3)
	instance:GetScale()
	tick()
	local numberValue = Instance.new("NumberValue")
	local changedConnection = nil
	task.delay(duration, function()
		numberValue:Destroy()
		changedConnection:Disconnect()
	end)
	numberValue.Value = instance:GetScale()
	changedConnection = numberValue.Changed:Connect(function()
		instance:ScaleTo(numberValue.Value)
	end)
	local tweenInfo = TweenInfo.new(duration, p2, p3)
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(numberValue, tweenInfo, {
		Value = p
	}):Play()
	return controller
end

function PortalSpawner.Spawnportal(data)
	local anchor = data.Anchor
	local timeScale = data.TimeScale or 1
	local scale = data.Scale or 1
	local _ = data.Bind
	local clone = script.PortalModel:Clone()
	clone:PivotTo(anchor)
	clone:ScaleTo(0.01)
	clone.Parent = thrown
	PortalSpawner.ScaleTween(clone, 1 * scale, 0.3 * timeScale, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	local clone2 = script.StartEmit:Clone()
	clone2.CFrame = anchor
	fn(clone2.CFrame, thrown)
	clone2.Parent = thrown
	PortalSpawner.EmitAttributes(clone2)
	Debris:AddItem(clone2, 2)
	local color = Color3.new(0.764706, 0.560784, 1)
	task.spawn(function()
		random:NextNumber(4, 7)

		for _ = 1, 5 do
			LightningModule.Cast(
				clone:GetPivot() * CFrame.new(random:NextNumber(-5, 5), 0, random:NextNumber(-5, 5)).Position,
				clone:GetPivot() * CFrame.new(
					random:NextNumber(-5, 5),
					random:NextNumber(5, 10),
					random:NextNumber(-5, 5)
				).Position,
				{
					Duration = 0.05,
					Thickness = random:NextNumber(1, 2.05) * 0.25,
					Color = Color3.new(color.R * 1, color.G * 1, color.B * 1)
				}
			)
			task.wait(0.03)
		end
	end)

	if data.Lightning then
		task.spawn(function()
			local pivot = clone:GetPivot()
			random:NextNumber(4, 7)

			if data.Bind then
				local count = 0

				while data.Bind.Parent do
					for _ = 1, 5 do
						LightningModule.Cast(
							pivot * CFrame.new(random:NextNumber(-5, 5), 0, random:NextNumber(-5, 5)).Position,
							pivot * CFrame.new(
								random:NextNumber(-5, 5),
								random:NextNumber(5, 10),
								random:NextNumber(-5, 5)
							).Position,
							{
								Duration = 0.05,
								Thickness = random:NextNumber(1, 2.05) * 0.25,
								Color = Color3.new(color.R * 1, color.G * 1, color.B * 1)
							}
						)
						task.wait(0.03)
					end

					count += 1

					if not (count > 1) then
						continue
					end

					local clone3 = script.StartEmit:Clone()
					clone3.CFrame = anchor
					fn(clone3.CFrame, thrown)
					clone3.Parent = thrown
					PortalSpawner.EmitAttributes(clone3)
					Debris:AddItem(clone3, 2)
				end
			else
				for _ = 1, 2 do
					for _ = 1, 5 do
						LightningModule.Cast(
							pivot * CFrame.new(random:NextNumber(-5, 5), 0, random:NextNumber(-5, 5)).Position,
							pivot * CFrame.new(
								random:NextNumber(-5, 5),
								random:NextNumber(5, 10),
								random:NextNumber(-5, 5)
							).Position,
							{
								Duration = 0.05,
								Thickness = random:NextNumber(1, 2.05) * 0.25,
								Color = Color3.new(color.R * 1, color.G * 1, color.B * 1)
							}
						)
						task.wait(0.03)
					end
				end
			end
		end)
	end

	return clone
end

function PortalSpawner.ClosePortal(instance, value)
	local v = value or 1
	PortalSpawner.ScaleTween(instance, 0.001, 0.4 * v, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
	Debris:AddItem(instance, 0.5 * v)
	task.spawn(function()
		local clone = script.EndEmit:Clone()
		clone.CFrame = instance:GetPivot()
		clone.Parent = thrown
		PortalSpawner.EmitAttributes(clone.absorb)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 3 and instance and instance.Parent and instance.PrimaryPart do
				clone:PivotTo(instance:GetPivot())
				local RunService2 = game:GetService("RunService")
				RunService2.RenderStepped:Wait()
			end
		end)
		task.wait(0.33 * v)
		fn2(clone, thrown)
		PortalSpawner.EmitAttributes(clone.INfast)
		Debris:AddItem(clone, 2.5)
	end)
end

return PortalSpawner