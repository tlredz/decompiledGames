local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Beziers = require(script.Parent.Modules.Beziers)
local FX = require(ReplicatedStorage.FX)
local c_Un = FX:WaitForChild("YetiEffectsRed").C_Un

local function mockRootPart(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local clone = c_Un.StartTP:Clone()
		local clone2 = c_Un.DashTP:Clone()
		local clone3 = c_Un.TPC:Clone()
		clone2.CFrame = root.CFrame * CFrame.new(0, -2.4, 0)
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone2, 1)
		emitAll(clone2)
		Util.Sound:Play("AkumaYeti_UnTransformed_C_ReleaseTeleport_01", root.Position)
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1)
		emitAll(clone)
		task.wait(0.17)
		task.spawn(function()
			task.wait(0.085)
			clone3.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone3, 1)
			emitAll(clone3)
		end)
		local player2 = data.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 7, 0.05, 0.4, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
			task.spawn(function()
				local clone4 = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone4, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone4, 2)
				TweenService:Create(clone4, TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				task.wait(0.067)
				TweenService:Create(clone4, TweenInfo.new(0.085, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 24.35,
					NearIntensity = 0
				}):Play()
				task.wait(0.086)
				TweenService:Create(clone4, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
		end

		Util.Sound:Play("AkumaYeti_UnTransformed_C_ReleaseTeleport_01", root)
		local ray, v, v2 = Util.Ray(
			(data.FinalCFrame or root.CFrame).Position + createVector(0, 1, 0),
			createVector(-0, -1, -0) * data.Height * 2,
			{ workspace.Characters, workspace.Enemies, _WorldOrigin },
			false
		)

		if ray == nil then
			local clone4 = c_Un.TpGround:Clone()
			clone4.Floor:Destroy()
			clone4.Impact3Floor:Destroy()
			clone4.CFrame = data.FinalCFrame
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone4)
			Util.Debris:AddItem(clone4, 2.5)
		else
			local alignCFrame = Util.Misc.AlignCFrame(CFrame.new(v, v + v2), v2)
			local clone4 = c_Un.TpGround:Clone()
			clone4.CFrame = alignCFrame
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone4)
			Util.Debris:AddItem(clone4, 6)
		end
	elseif stage == 2 then
		local root = data.Root
		local user = data.User
		local clone = c_Un.DashTP:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -2.4, 0)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1)
		emitAll(clone)
		local player2 = data.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 7, 0.05, 0.4, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
			task.spawn(function()
				local clone2 = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(182, 146, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.9,
					Contrast = 0,
					Saturation = -1
				}):Play()
				task.wait(0.2)
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(151, 103, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.1,
					Contrast = 0,
					Saturation = -1
				}):Play()
				task.wait(0.35)
				TweenService:Create(clone2, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				task.wait(0.067)
				local clone3 = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 2)
				TweenService:Create(clone3, TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				task.wait(0.067)
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					FarIntensity = 1,
					FocusDistance = 1.74,
					InFocusRadius = 24.35,
					NearIntensity = 0
				}):Play()
				task.wait(0.15)
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
		end

		task.wait(0.067)
		Util.Sound:Play("AkumaYeti_UnTransformed_C_ReleaseTeleport_01", root)

		local function whitering()
			local clone2 = c_Un.BillboardGui2:Clone()
			local imageLabel2 = clone2:WaitForChild("ImageLabel2")
			Util.SetParentOverrideWithColor(clone2, user:FindFirstChild("RightHand"), player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 4)
			imageLabel2.Size = UDim2.new(0, 0, 0, 0)
			imageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
			TweenService:Create(imageLabel2, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				ImageTransparency = 1
			}):Play()
		end

		task.spawn(function()
			task.wait(0.2)
			local clone2 = c_Un.BillboardGui:Clone()
			local imageLabel = clone2:WaitForChild("ImageLabel")
			Util.SetParentOverrideWithColor(clone2, user:FindFirstChild("RightHand"), player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 4)
			imageLabel.Size = UDim2.new(0, 0, 0, 0)
			imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			TweenService:Create(imageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				ImageTransparency = 0
			}):Play()
			local player3 = data.Player
			local Players2 = game:GetService("Players")

			if player3 == Players2.LocalPlayer then
				task.spawn(function()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							FieldOfView = 53
						}
					):Play()
					Util.CameraShaker:ShakeOnce(
						6,
						9,
						0.05,
						1.2,
						createVector(0.8, 0.8, 0.8),
						createVector(0.8, 0.8, 0.8)
					)
					task.wait(0.35)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							FieldOfView = 70
						}
					):Play()
				end)
			end

			task.wait(0.35)
			whitering()
			TweenService:Create(imageLabel, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ImageTransparency = 0
			}):Play()
		end)
	elseif stage == 3 then
		local _ = data.Root
		local _ = data.CFrame
		local _ = data.stage
		local user = data.User
		local userCF = data.UserCF
		local victim = data.Victim
		local victimCF = data.VictimCF
		local timestamp = data.Timestamp
		local camShift = data.CamShift
		local v = masterClock:GetTime() - timestamp
		local humanoidRootPart = victim:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart2 = user:FindFirstChild("HumanoidRootPart")
		local v2 = math.max(0.6 - v, 0.1)
		local root = data.Root
		local clone = c_Un.TP.Shock:Clone()
		Util.SetParentOverrideWithColor(clone, root, player, "YetiFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1.7)
		Util.Sound:Play("AkumaYeti_UnTransformed_C_Connect_Hit_01", root)

		if user and humanoidRootPart2 then
			if camShift and game.Players.LocalPlayer.Character and humanoidRootPart2.Parent == game.Players.LocalPlayer.Character then
				local currentCamera = workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				local _ = cFrame.p - humanoidRootPart2.Position
				local orientation, _, _ = (cFrame - cFrame.p):ToOrientation()
				local _, v3, v4 = userCF:ToOrientation()
				RunService:BindToRenderStep("TPCAM", Enum.RenderPriority.Camera.Value + 1, function()
					if currentCamera then
						currentCamera.CFrame = currentCamera.CFrame:Lerp(
							CFrame.new(userCF.p) * CFrame.fromOrientation(orientation, v3, v4),
							0.15
						)
					else
						RunService:UnbindFromRenderStep("TPCAM")
					end

					RunService.RenderStepped:Wait()
				end)
				task.spawn(function()
					wait(v2)
					RunService:UnbindFromRenderStep("TPCAM")
				end)
			end

			task.spawn(function()
				local clone2 = c_Un.Hands2.Charge:Clone()
				Util.SetParentOverrideWithColor(clone2, user:WaitForChild("RightHand"), player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 1.5)
				task.spawn(function()
					task.wait(0.65)

					for _ = 1, 10 do
						task.spawn(function()
							task.wait(math.random(0.25, 0.45))
							local clone3 = c_Un.partfly:Clone()
							clone3.CFrame = root.CFrame * CFrame.new(
								math.random(-15, 15),
								math.random(-1.5, 15),
								math.random(-15, 15)
							)
							Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone3, 2)
							local v3 = math.random(15, 35) / 100
							Beziers.Interpolate(
								"Cubic",
								v3,
								100,
								v3,
								nil,
								clone3.CFrame,
								clone3.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								clone3.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								root.Parent.RightHand.CFrame,
								clone3,
								"CFrame"
							)
						end)
					end
				end)
				task.spawn(function()
					local clone3 = c_Un.Hands2.FreezeR:Clone()
					local clone4 = c_Un.Hands2.FreezeR2:Clone()
					Util.SetParentOverrideWithColor(clone3, root.Parent.RightHand, player, "YetiFruitVFXColor")
					Util.SetParentOverrideWithColor(clone4, root.Parent.RightHand, player, "YetiFruitVFXColor")
					clone3.Trail.Attachment0 = clone3
					clone3.Trail.Attachment1 = clone4
					task.wait(0.273)
					emitAll(clone2)
					task.wait(0.3)
					clone3:Destroy()
					clone4:Destroy()
				end)
			end)
		end

		if humanoidRootPart then
			task.spawn(function()
				task.wait(0.1)

				if humanoidRootPart.Anchored == false and not humanoidRootPart.Parent:FindFirstChild("AntiMover") then
					humanoidRootPart.CFrame = victimCF
				end

				local primaryPart = victim.PrimaryPart
				victim:GetExtentsSize()
				local clone2 = c_Un.IceCube:Clone()
				Util.Debris:AddItem(clone2, 4)
				clone2.CFrame = primaryPart.CFrame
				Util.SetParentOverrideWithColor(clone2, primaryPart, player, "YetiFruitVFXColor")
				local weld = Instance.new("Weld")
				weld.Name = "WeldIceCube"
				weld.Part0 = primaryPart
				weld.Part1 = clone2
				weld.C0 = CFrame.new()
				Util.SetParentOverrideWithColor(weld, primaryPart, player, "YetiFruitVFXColor")
			end)
		end

		task.spawn(function()
			task.wait(1.305)
			local clone2 = c_Un.Explode.FINAL:Clone()
			Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 1.8)
			emitAll(clone2)
			local v3 = false
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				v3 = true
			elseif victim then
				local Players2 = game:GetService("Players")
				v3 = victim == Players2.LocalPlayer.Character or v3
			end

			if v3 then
				Util.CameraShaker:ShakeOnce(12, 17, 0.05, 1.1, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
			end

			task.spawn(function()
				if v3 then
					local clone3 = script.LTN:Clone()
					Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 2)
					TweenService:Create(clone3, TweenInfo.new(0.01), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(167, 138, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0.4,
						Contrast = 1,
						Saturation = 0.2
					}):Play()
					task.wait(0.01)
					TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					}):Play()
				end
			end)
			task.spawn(function()
				if v3 then
					local clone3 = script.DepthOfField:Clone()
					Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 2)
					TweenService:Create(clone3, TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 1,
						FocusDistance = 1.74,
						InFocusRadius = 0,
						NearIntensity = 0
					}):Play()
					task.wait(0.067)
					TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						FarIntensity = 1,
						FocusDistance = 1.74,
						InFocusRadius = 24.35,
						NearIntensity = 0
					}):Play()
					task.wait(0.15)
					TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 0,
						FocusDistance = 0,
						InFocusRadius = 0,
						NearIntensity = 0
					}):Play()
				end
			end)
			task.spawn(function()
				if v3 then
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.067, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 123
						}
					):Play()
					task.wait(0.067)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end
			end)
			task.spawn(function()
				for _ = 1, 14 do
					local clone3 = c_Un.IceWind:Clone()
					clone3.CFrame = root.CFrame * CFrame.Angles(
						math.rad(math.random(-450, 450) / 10),
						math.rad(math.random(-450, 450) / 10),
						(math.rad(math.random(-2, 2) / 10))
					)
					clone3.Position = root.position
					clone3.Anchored = false
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
					local v4 = math.random(2, 5) / 5
					local v5 = math.random(10, 20) / 5

					if math.random(2) == 1 then
						v5 *= -1
					end

					for _, attachment in pairs(clone3:GetDescendants()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						attachment.Position = Vector3.new(0, attachment.Name == "Top" and v4 or -v4, 0)
						attachment.Position += Vector3.new(0, v5, 0)
					end

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
					bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(120, 320)
					Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
					local v6 = math.random(-42, 41) / 1.5
					clone3.RotVelocity = clone3.CFrame.LookVector * v6
					coroutine.resume(coroutine.create(function()
						task.wait(math.random(50, 80) / 100)
						clone3.Anchored = true
						Util.Debris:AddItem(clone3, 1.5)
					end))
				end
			end)
			task.spawn(function()
				local clone3 = c_Un.finalC:Clone()
				local lookVector = userCF.LookVector
				local v4 = root.Position + lookVector * 35
				local ray = Util.Ray
				local v5 = { workspace.Characters, workspace.Enemies }
				local v6, v7, v8 = ray(v4, createVector(0, -15, 0), v5)

				if v6 then
					local v9 = v8 * 0.1
					local v10 = userCF
					clone3.CFrame = CFrame.new(v7 + v9) * v10 - v10.p
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 2.5)
					emitAll(clone3)
				else
					local clone4 = c_Un.finalCAir:Clone()
					clone4.CFrame = userCF * CFrame.new(0, 0, -35)
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2.5)
					emitAll(clone4)
				end
			end)
		end)
	elseif stage == 4 then
		local primaryPart = data.VictimChar.PrimaryPart
		local iceCube = primaryPart:FindFirstChild("IceCube")

		if iceCube then
			iceCube.Name = "DESTROYING"
			iceCube.Transparency = 1
			Util.Debris:AddItem(iceCube, 1)
			emitAll(iceCube)
		end

		local clone = c_Un.flypa.Fly:Clone()
		Util.SetParentOverrideWithColor(clone, primaryPart, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 2)
	elseif stage == 5 then
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local clone = c_Un.Hands.FreezeL:Clone()
		local clone2 = c_Un.Hands.FreezeR:Clone()
		local clone3 = c_Un.Hands.FreezeL2:Clone()
		local clone4 = c_Un.Hands.FreezeR2:Clone()
		local v = {}
		local leftHand = root.Parent:FindFirstChild("LeftHand")
		local rightHand = root.Parent:FindFirstChild("RightHand")
		local cFrame = leftHand.CFrame
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = cFrame
		part.Parent = workspace._WorldOrigin
		local cFrame2 = rightHand.CFrame
		local part2 = Instance.new("Part")
		part2.Name = "Mock" .. part2.Name
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.Transparency = 1
		part2.CFrame = cFrame2
		part2.Parent = workspace._WorldOrigin
		part.Size = leftHand.Size
		part2.Size = rightHand.Size
		Util.SetParentOverrideWithColor(clone, part, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, part2, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone3, part, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, part2, player, "YetiFruitVFXColor")
		emitAll(clone)
		emitAll(clone2)
		local v2 = Util.Sound:Play("AkumaYeti_UnTransformed_C_Held_01", root)
		local clone5 = c_Un.TPHold:Clone()
		clone5.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
		local ray = Util.Ray
		local v3 = root.Position + createVector(0, 1, 0)
		local v4 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v5, v6, v7 = ray(v3, createVector(-0, -8, -0), v4)

		if v5 ~= nil then
			local cFrame3 = CFrame.new(v6, v6 + v7) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
			local clone6 = c_Un.FloorHold:Clone()
			clone6.CFrame = cFrame3
			Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone6)
			table.insert(v, clone6)
		end

		clone2.Aura.Enabled = true
		clone2.SpikeSide.Enabled = true
		clone2.AuraIn.Enabled = true
		clone.Aura.Enabled = true
		clone.SpikeSide.Enabled = true
		clone2.AuraIn.Enabled = true
		table.insert(v, part)
		table.insert(v, part2)
		table.insert(v, clone)
		table.insert(v, clone3)
		table.insert(v, clone2)
		table.insert(v, clone4)
		table.insert(v, clone4)
		table.insert(v, clone5)
		local now = tick()

		while true do
			task.wait()
			part.CFrame = leftHand.CFrame
			part2.CFrame = rightHand.CFrame

			if now < tick() then
				now = tick() + 0.15
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			task.wait(0.05)

			for _, folder in pairs(v) do
				if folder:IsDescendantOf(workspace) then
					for _, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = false
						end
					end
				end

				local v8 = folder
				task.spawn(function()
					task.wait(1)
					v8:Destroy()
				end)
			end

			break
		end
	end
end