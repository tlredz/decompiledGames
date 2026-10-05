local createVector = vector.create
game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.ParticleTween)
local Bezier = require(ReplicatedStorage.CAM.Client.Modules.Effects.Bezier)
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local _ = Players.LocalPlayer

function MakeCharacterTransparent(folder)
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if (descendant:IsA("MeshPart") or descendant:IsA("BasePart") or descendant:IsA("Part") or descendant:IsA("Decal")) and descendant.Name ~= "HumanoidRootPart" and descendant.Transparency ~= 1 then
			local transparency = descendant.Transparency
			descendant.Transparency = 1
			table.insert(result, {
				Part = descendant,
				Transparency = transparency
			})
		end

		if descendant:IsA("ParticleEmitter") and descendant.Enabled == true then
			local transparency = descendant.Transparency
			descendant.Transparency = NumberSequence.new(1, 1)
			descendant.Enabled = false
			table.insert(result, {
				Particle = descendant,
				Particle_Saved_Transparency = transparency
			})
		end

		if descendant:IsA("Beam") and descendant.Enabled == true then
			descendant.Enabled = false
			table.insert(result, {
				Beam = descendant
			})
		end

		if descendant:IsA("Trail") and descendant.Enabled == true then
			descendant.Enabled = false
			table.insert(result, {
				Trail = descendant
			})
		end

		if not (descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight")) then
			continue
		end

		local range = descendant.Range
		local brightness = descendant.Brightness
		descendant.Range = 0
		descendant.Brightness = 0
		table.insert(result, {
			Light = descendant,
			Range = range,
			Brightness = brightness
		})
	end

	return result
end

function ReturnCharacterTransparency(items)
	for _, item in items do
		if typeof(item) ~= "table" then
			continue
		end

		if item.Part then
			item.Part.Transparency = item.Transparency
		end

		if item.Particle then
			item.Particle.Enabled = true
			item.Transparency = item.Particle_Saved_Transparency
		end

		if item.Beam then
			item.Beam.Enabled = true
		end

		if item.Trail then
			item.Trail.Enabled = true
		end

		if not item.Light then
			continue
		end

		item.Light.Brightness = item.Brightness
		item.Light.Range = item.Range
	end
end

local AuraEffects = require(script.Parent.AuraEffects)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, p, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" then
		return
	end

	local rightHand = instance:FindFirstChild("RightHand")
	instance:FindFirstChild("LeftHand")
	local name = string.format("%s TwinHeadedReptileEffects", instance.Name)

	if p == "Start" then
		AuraEffects.TurnOnAura(instance)
	elseif p == "Dash" then
		AuraEffects.TurnOffAura(instance)
		local child = parent:FindFirstChild(name)

		if child then
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)

			for _, child2 in child:GetChildren() do
				vfxUtility.EnableAll(child2, false)
				DebrisModule:AddItem(child2, 2)
			end
		end

		local cframe = CFrame.lookAlong(vector3, vector2)
		local cframe2 = CFrame.lookAlong(vector4, vector2)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
		DebrisModule:AddItem(folder, 10)
		folder:SetAttribute("Active", true)
		vfxUtility.PlaySound(sounds, "PS2snakeTHSlungeslash", humanoidRootPart, true)
		local v3 = {}

		local function fn()
			for _, connection in v3 do
				connection:Disconnect()
			end
		end

		table.insert(v3, folder.AttributeChanged:Connect(fn))
		table.insert(v3, folder.Destroying:Connect(fn))
		local clone = assets["Dash and Slash"]:Clone()
		clone:PivotTo(CFrame.new(cframe.Position, cframe2.Position))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 5)
		Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
		vfxUtility.EmitAll(clone.Dash, vfxUtility.Owned(instance))
		vfxUtility.EmitAll(clone.Slashes.Slash1, vfxUtility.Owned(instance))

		for _, folder2 in { clone.Dash, clone.Slashes.Slash1 } do
			for _, beam in folder2:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				local width0 = beam.Width0
				local width1 = beam.Width1
				beam.Width0 = 0
				beam.Width1 = 0
				TweenService:Create(beam, TweenInfo.new(0.2), {
					Width0 = width0,
					Width1 = width1
				}):Play()
				local v4 = beam
				task.delay(beam:GetAttribute("EmitDuration"), function()
					TweenService:Create(v4, TweenInfo.new(0.5), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end

		task.delay(0.1, function()
			if folder:GetAttribute("Active") == true then
				vfxUtility.EmitAll(clone.Slashes.Slash2, vfxUtility.Owned(instance))

				for _, beam in clone.Slashes.Slash2:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(0.2), {
						Width0 = width0,
						Width1 = width1
					}):Play()
					local v4 = beam
					task.delay(beam:GetAttribute("EmitDuration"), function()
						TweenService:Create(v4, TweenInfo.new(0.5), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			elseif folder:GetAttribute("Active") == false then
				return
			end

			task.wait(0.05)

			if folder:GetAttribute("Active") == true then
				vfxUtility.EmitAll(clone.Slashes.Slash3, vfxUtility.Owned(instance))

				for _, beam in clone.Slashes.Slash3:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(0.2), {
						Width0 = width0,
						Width1 = width1
					}):Play()
					local v4 = beam
					task.delay(beam:GetAttribute("EmitDuration"), function()
						TweenService:Create(v4, TweenInfo.new(0.5), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			elseif folder:GetAttribute("Active") == false then
				return
			end

			task.wait(0.05)

			if folder:GetAttribute("Active") == true then
				vfxUtility.EmitAll(clone.Slashes.FinalSlash, vfxUtility.Owned(instance))

				for _, beam in clone.Slashes.FinalSlash:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(0.2), {
						Width0 = width0,
						Width1 = width1
					}):Play()
					local v4 = beam
					task.delay(beam:GetAttribute("EmitDuration"), function()
						TweenService:Create(v4, TweenInfo.new(0.5), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end
		end)

		for _ = 1, 6 do
			local clone2 = assets.SnakeTrail:Clone()
			clone2.CFrame = clone.PrimaryPart.CFrame * CFrame.new(
				math.random(-10, 10),
				math.random(5, 5),
				math.random(-2, 2)
			)
			clone2.Parent = parent:FindFirstChild(name)
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
			local v4 = math.random(200, 350) / 100
			local total = 0
			local cFrame = clone2.CFrame
			local v5 = cframe2 * CFrame.new(math.random(-5, 5), math.random(-2, 3), math.random(-3, 3))
			local heartbeatConnection = nil
			local position = (CFrame.lookAt(clone2.Position:Lerp(v5.Position, 0.25), v5.Position) * CFrame.new(
				math.random(-30, 30),
				math.random(-10, 15),
				math.random(-10, 5)
			)).Position
			local position2 = (CFrame.lookAt(clone2.Position:Lerp(v5.Position, 0.75), v5.Position) * CFrame.new(
				math.random(-30, 30),
				math.random(-10, 15),
				math.random(-10, 5)
			)).Position
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt * v4
				local cubicBezier = Bezier.CubicBezier(total, cFrame.Position, position, position2, v5.Position)
				local cubicBezier2 = Bezier.CubicBezier(total + 0.01, cFrame.Position, position, position2, v5.Position)

				if not (total >= 1) then
					clone2.CFrame = CFrame.new(cubicBezier, cubicBezier2)
					return
				end

				heartbeatConnection:Disconnect()
				clone2.Position = v5.Position
				vfxUtility.EnableAll(clone2, false)
				DebrisModule:AddItem(clone2, 2)
			end)
			table.insert(v3, heartbeatConnection)
		end
	elseif p == "Cancel" then
		AuraEffects.TurnOffAura(instance)
		local child = parent:FindFirstChild(name)

		if child then
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)

			for _, child2 in child:GetChildren() do
				vfxUtility.EnableAll(child2, false)
				DebrisModule:AddItem(child2, 2)
			end
		end
	elseif p == "Success" then
		AuraEffects.TurnOffAura(instance)
		local child = parent:FindFirstChild(name)

		if child then
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)

			for _, child2 in child:GetChildren() do
				vfxUtility.EnableAll(child2, false)
				DebrisModule:AddItem(child2, 2)
			end
		end

		local child2 = parent:FindFirstChild(name)

		if child2 then
			child2.Name = "_"
			child2:SetAttribute("Active", false)
			DebrisModule:AddItem(child2, 2.5)

			for _, child3 in child2:GetChildren() do
				vfxUtility.EnableAll(child3, false)
				DebrisModule:AddItem(child3, 2)
			end
		end

		vfxUtility.PlaySound(sounds, "PS2snakeTHSsuccess", humanoidRootPart, true)
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 5)
		task.delay(0.5, function()
			local clone = assets.Strike:Clone()
			clone.CFrame = CFrame.lookAlong(vector3, vector2) * CFrame.new(0, -2, 10)
			clone.Parent = parent
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
			local tween = TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
				CFrame = cFrame * CFrame.new(0, -2, -3)
			})
			tween:Play()
			task.delay(0.4, function()
				vfxUtility.EnableAll(clone, false)
				DebrisModule:AddItem(clone, 2)
				tween:Pause()
			end)
		end)
		local clone = assets.Snake:Clone()
		clone.Cube.CFrame = humanoidRootPart.CFrame * CFrame.new(
			-0.38543701171875,
			-3.7476654052734375,
			5.309661865234375
		) * CFrame.fromEulerAnglesYXZ(-0.09161286056041718, 3.141502618789673, -0.001621622359380126)
		clone.Parent = parent
		local snake1 = script.Animations["Snake 1"]
		clone.AnimationController:LoadAnimation(snake1):Play()
		local clone2 = assets.Snake:Clone()
		clone2.Cube.CFrame = humanoidRootPart.CFrame * CFrame.new(
			-0.38543701171875,
			-3.7476654052734375,
			5.309661865234375
		) * CFrame.fromEulerAnglesYXZ(-0.09161286056041718, 3.141502618789673, -0.001621622359380126)
		clone2.Parent = parent
		local snake2 = script.Animations["Snake 2"]
		clone2.AnimationController:LoadAnimation(snake2):Play()
		clone.Cube.Transparency = 1
		clone2.Cube.Transparency = 1
		vfxUtility.EnableAll(clone, false)
		vfxUtility.EnableAll(clone2, false)
		local clone3 = assets.TickDMG:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = parent
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.07,
			Amplitude = 0.25,
			SustainTime = 1,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
		task.wait(1)
		vfxUtility.EnableAll(clone3, false)
		DebrisModule:AddItem(clone3, 2)
		task.wait(0.3333)
		local clone4 = assets.SwordDismiss:Clone()
		clone4.CFrame = rightHand.CFrame
		clone4.Parent = parent
		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 2)
		AuraEffects.TurnOffAura(instance)
		task.wait(0.5)
		TweenService:Create(clone2.Cube, TweenInfo.new(0.2), {
			Transparency = 0
		}):Play()
		TweenService:Create(clone.Cube, TweenInfo.new(0.2), {
			Transparency = 0
		}):Play()
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		task.wait(0.266)
		task.delay(0.35, function()
			vfxUtility.EnableAll(clone, false)
			vfxUtility.EnableAll(clone2, false)
		end)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		local clone5 = assets.KnockBack:Clone()
		clone5.CFrame = cFrame
		clone5.Parent = parent
		vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone5, 2)
		TweenService:Create(clone.Cube, TweenInfo.new(0.8), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2.Cube, TweenInfo.new(0.8), {
			Transparency = 1
		}):Play()
		DebrisModule:AddItem(clone, 2)
		DebrisModule:AddItem(clone2, 2)
	end
end