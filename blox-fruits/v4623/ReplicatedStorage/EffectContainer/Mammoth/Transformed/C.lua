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
local RocksModule2 = require(game.ReplicatedStorage.Util.RocksModule2)

local function debrisPart(data, p, p2)
	local v = math.random(90, 124) / 10
	local v2 = math.random(47, 78) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v2, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(250, 370),
		math.random(70, 100),
		math.random(250, 370)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

local mammoth = FX:WaitForChild("Mammoth")

local function CMOVE(plr, hrp, hold, mammoth2)
	local v = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight
	local _ = mammoth2.PrimaryPart
	local body4002 = mammoth2["body4.002"]
	local _ = mammoth2.AnimationController
	local children = mammoth2:GetChildren()

	local function lightup()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Color = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()
			local v3 = part
			task.spawn(function()
				task.wait(0.05)

				if tween.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(255, 57, 57)
					}
				)
				tween2:Play()
				task.wait(0.1)

				if tween2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Color = Color3.fromRGB(112, 22, 22)
				}):Play()
			end)
		end
	end

	local function lightoff()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Color = Color3.fromRGB(13, 105, 172)
			}):Play()
		end
	end

	lightup()

	while hold and hold.Value and hold.Parent and hold.Parent:IsDescendantOf(workspace) do
		wait()
	end

	Util.Sound:Play("MammothCrush", hrp, 25, 1 + math.random(-5, 5) / 100, 2)
	mammoth2.exp.Size = createVector(26.202, 4.679, 31.044)
	body4002.aura1.Enabled = true
	body4002.aura2.Enabled = true
	mammoth2.exp.FR2.Enabled = true
	mammoth2.exp.FR3.Enabled = true
	task.wait(0.07)
	local children2 = body4002.CDashStart:GetChildren()
	local v2 = {}

	for k, v3 in pairs(children2) do
		v2[k] = {
			count = v3:GetAttribute("EmitCount") or 0,
			delay = v3:GetAttribute("EmitDelay") or 0
		}
	end

	for k, v3 in pairs(children2) do
		if not v2[k] then
			continue
		end

		if v2[k].delay > 0 then
			local v4 = k
			local v5 = v3
			task.spawn(function()
				task.wait(v2[v4].delay)
				v5:Emit(v2[v4].count)
			end)
		else
			v3:Emit(v2[k].count)
		end
	end

	task.spawn(function()
		task.wait(0.098)

		for _, child in pairs(mammoth2.exp.beams3:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 13.799,
				Width0 = 3.067
			}):Play()
		end

		for _, child in pairs(mammoth2.exp.beams2:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 22.999,
				Width0 = 3.067
			}):Play()
		end

		for _, child in pairs(mammoth2.exp.beams1:GetChildren()) do
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 18.399
			}):Play()
		end

		mammoth2.exp.Sparks2.Enabled = true
		mammoth2.exp.Sparks3.Enabled = true
	end)
	body4002.WINDTRAIL4.Trail2.Enabled = true
	body4002.WINDTRAIL1.Trail2.Enabled = true
	body4002.t2.Trail2.Enabled = true
	task.spawn(function()
		task.wait(0.07)

		for _ = 1, 3 do
			task.wait(0.038)

			for _, child in pairs(body4002.CDashEmit:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end)
	task.spawn(function()
		task.wait(0.2)
		local position = hrp.Position
		local rayMap, v3, _ = Util.RayMap(position, createVector(0, -1, 0) * (v + 10))

		if rayMap then
			local function groundEffects(_, rayMap2)
				if rayMap2 then
					body4002.emitground.Rocks.Color = ColorSequence.new(rayMap2.Color)
					body4002.emitground.SlashSmoke.Color = ColorSequence.new(rayMap2.Color)
					body4002.emitground.SlashSmoke:Emit(16)
					body4002.emitground.Rocks:Emit(8)
				end
			end

			groundEffects(v3, rayMap)
		end
	end)
	Util.Sound:Play("port2", hrp, nil, 1 + math.random(-5, 5) / 100, 2.5)
	task.wait(0.23)
	local v3 = Util.Sound:Play("MammothTrunkSlam", hrp, 25, 1 + math.random(-12, 12) / 100, 3)
	task.delay(2, function()
		Util.Sound:FadeOut(v3, 1.5)
	end)
	local clone = mammoth.SlamTrunkBig:Clone()
	local primaryPart = clone.PrimaryPart
	local clone2 = mammoth.RedCracksGround:Clone()
	task.spawn(function()
		task.wait(0.147)
		local descendants = primaryPart.Attachment:GetDescendants()
		local v4 = {}

		for k, descendant in pairs(descendants) do
			v4[k] = {
				count = descendant:GetAttribute("EmitCount") or 0,
				delay = descendant:GetAttribute("EmitDelay") or 0
			}
		end

		for k, descendant in pairs(descendants) do
			if not v4[k] then
				continue
			end

			if v4[k].delay > 0 then
				local v5 = k
				local v6 = descendant
				task.spawn(function()
					task.wait(v4[v5].delay)
					v6:Emit(v4[v5].count)
				end)
			else
				descendant:Emit(v4[k].count)
			end
		end
	end)

	for _, folder in pairs(clone:GetChildren()) do
		if folder == clone.SlamTrunkBig then
			continue
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant.Name == "wind" or descendant.Name == "dust2" then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end
		end
	end

	task.spawn(function()
		task.wait(0.1)

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 1.5, 0.1, 0.6, createVector(0.1, 1.3, 0.1), createVector(1, 1, 1))
		end

		for _, child in pairs(body4002.CMove_Up:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.wait(0.39)
		mammoth2.trunk.TrunkTrail.Enabled = true

		for _, child in pairs(body4002.CMove_DOWN3:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.wait(0.05)
		Util.Sound:Play("MammothCrush", hrp, 25, 1 + math.random(-5, 5) / 100, 3)

		for _, child in pairs(body4002.CMove_DOWN:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.spawn(function()
			local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
			local v4 = hrp.Position + lookVector * 23.5
			local rayMap, v5, v6 = Util.RayMap(v4, createVector(0, -1, 0) * (v + 10))

			if rayMap then
				local v7 = v6 * 0.1
				local _ = plr.Character.PrimaryPart.CFrame
				primaryPart.CFrame = CFrame.new(v5, v5 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone.Parent = _WorldOrigin
				clone2.CFrame = primaryPart.CFrame * CFrame.new(0, 0.05, 0)
				clone2.Parent = _WorldOrigin
				Util.Debris:AddItem(clone2, 2)
				Util.Debris:AddItem(clone, 3.5)
				task.spawn(function()
					TweenService:Create(
						primaryPart,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(115, 0.03, 115)
						}
					):Play()
					TweenService:Create(
						clone2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(115, 0.05, 115)
						}
					):Play()
					task.wait(0.3)
					TweenService:Create(
						clone2.Decal,
						TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						primaryPart.Decal,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
						{
							Color3 = Color3.new(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						primaryPart.Decal,
						TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
						{
							Transparency = 1
						}
					):Play()
				end)
				local clone3 = mammoth.FlashDown:Clone()
				Util.Debris:AddItem(clone3, 1.5)
				clone3.CFrame = primaryPart.CFrame * CFrame.new(0, 7, 0)
				clone3.Parent = _WorldOrigin
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = createVector(0.05, 3, 0.05)
					}
				):Play()
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
				task.spawn(function()
					local _, _ = Util.RayMap(primaryPart.Position, createVector(-0, -5, -0))

					for _ = 1, 16 do
						debrisPart(rayMap, v5, v6)
					end
				end)
				task.spawn(function()
					for _, folder in pairs(clone:GetChildren()) do
						if folder == clone.SlamTrunkBig then
							continue
						end

						for _, descendant in pairs(folder:GetDescendants()) do
							if not (descendant.Name == "wind" or descendant.Name == "Embers") then
								continue
							end

							descendant:Emit(descendant:GetAttribute("EmitCount"))

							if descendant.Name ~= "wind" then
								continue
							end

							local v8 = descendant
							task.delay(descendant.Lifetime.Max + 0.1, function()
								v8:Destroy()
							end)
						end
					end

					task.wait(0.075)
					RocksModule2.Ground(
						primaryPart.Position + createVector(0, 1, 0),
						58,
						createVector(10, 5.83, 10),
						nil,
						5,
						false,
						2.5
					)
					RocksModule2.Ground(
						primaryPart.Position + createVector(0, 1, 0),
						68,
						createVector(15.5, 7.25, 15.5),
						nil,
						8,
						false,
						2.75
					)
					RocksModule2.Ground(
						primaryPart.Position + createVector(0, 1, 0),
						73,
						createVector(20, 15.5, 20),
						nil,
						10,
						false,
						3
					)
					RocksModule2.Ground(
						primaryPart.Position + createVector(0, 1, 0),
						94,
						createVector(25, 19.5, 25),
						nil,
						12,
						false,
						3
					)
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function groundEffects(_, rayMap2)
					if rayMap2 then
						primaryPart.Rocks.Color = ColorSequence.new(rayMap2.Color)
						primaryPart.Attachment.SMOKE.Color = ColorSequence.new(rayMap2.Color)
					end
				end

				if plr == game.Players.LocalPlayer then
					task.spawn(function()
						task.wait(0.08)
						Util.CameraShaker:ShakeOnce(17, 15, 0.05, 0.4, createVector(3, 3, 3), createVector(3, 3, 3))
						task.wait(0.025)
						local clone4 = script.Blur:Clone()
						local Debris = game:GetService("Debris")
						Debris:AddItem(clone4, 1)
						clone4.Parent = game.Lighting
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								FieldOfView = 98
							}
						):Play()
						TweenService:Create(
							clone4,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = 35
							}
						):Play()
						task.wait(0.082)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = 0
							}
						):Play()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								FieldOfView = 70
							}
						):Play()
					end)
					task.spawn(function()
						task.wait(0.075)
						local clone4 = script.LTN:Clone()
						clone4.Parent = game.Lighting
						Util.Debris:AddItem(clone4, 2)
						TweenService:Create(clone4, TweenInfo.new(0.013), {
							TintColor = Color3.fromRGB(0, 0, 0),
							Brightness = 0.3,
							Contrast = -1,
							Saturation = 30
						}):Play()
						task.wait()
						TweenService:Create(clone4, TweenInfo.new(0.01), {
							TintColor = Color3.fromRGB(255, 16, 16),
							Brightness = 1,
							Contrast = 10,
							Saturation = -1
						}):Play()
						task.wait()
						TweenService:Create(clone4, TweenInfo.new(0.01), {
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Contrast = 0,
							Saturation = 0
						}):Play()
						Util.Debris:AddItem(clone4, 1)
					end)
				end

				groundEffects(nil, rayMap) -- equivalent call inferred; original call site unknown
			end
		end)
	end)

	for _, child in pairs(mammoth2.exp.beams3:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams2:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams1:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	mammoth2.exp.FR2.Enabled = false
	mammoth2.exp.FR3.Enabled = false
	mammoth2.exp.Sparks2.Enabled = false
	mammoth2.exp.Sparks3.Enabled = false
	body4002.aura1.Enabled = false
	body4002.aura2.Enabled = false
	task.wait(1)
	lightoff()
	mammoth2.trunk.TrunkTrail.Enabled = false
	body4002.t2.Trail2.Enabled = false
	body4002.WINDTRAIL4.Trail2.Enabled = false
	body4002.WINDTRAIL1.Trail2.Enabled = false
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold

	if not hrp or (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local mammoth2 = hrp.Parent:FindFirstChild("Mammoth").Mammoth

	if not mammoth2 then
		return
	end

	CMOVE(plr, hrp, hold, mammoth2)
end