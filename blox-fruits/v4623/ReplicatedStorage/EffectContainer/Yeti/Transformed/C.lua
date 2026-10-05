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
local FX = require(ReplicatedStorage.FX)
local c_Tr = FX:WaitForChild("YetiEffects").C_Tr
local Beziers = require(script.Parent.Parent.Modules.Beziers)

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
		local clone = c_Tr.DashTP:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -2.4, 0)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1)
		emitAll(clone)
		Util.Sound:Play("YETI_TNSFM_C_AfterimageAssault_Teleport_01", root.Position)
		task.spawn(function()
			task.wait(0.1)
			emitAll(root.Parent.YetiRig:FindFirstChild("YetiRig").TPEmits)
		end)

		if root.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
			end)
		end

		task.wait(0.17)

		if root.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		Util.Sound:Play("YETI_TNSFM_C_AfterimageAssault_Teleport_03", root.Position)
		local player2 = data.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 7, 0.05, 0.4, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
			task.spawn(function()
				local clone2 = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				TweenService:Create(clone2, TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0.3,
					FocusDistance = 1.74,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				task.wait(0.067)
				TweenService:Create(clone2, TweenInfo.new(0.085, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					FarIntensity = 0.4,
					FocusDistance = 1.74,
					InFocusRadius = 24.35,
					NearIntensity = 0
				}):Play()
				task.wait(0.086)
				TweenService:Create(clone2, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
			end)
		end

		task.spawn(function()
			emitAll(root.Parent.YetiRig:FindFirstChild("YetiRig").TPEmits)
		end)
		local ray, v, v2 = Util.Ray(
			(data.FinalCFrame or root.CFrame).Position + createVector(0, 1, 0),
			createVector(-0, -1, -0) * data.Height * 2,
			{ workspace.Characters, workspace.Enemies, _WorldOrigin },
			false
		)

		if ray == nil then
			local clone2 = c_Tr.TpGround:Clone()
			clone2.Floor:Destroy()
			clone2.Impact3Floor:Destroy()
			clone2.CFrame = data.FinalCFrame or root.CFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 2.5)
		else
			local cFrame = Util.Misc.AlignCFrame(CFrame.new(v, v + v2), v2) + v2 * 0.1
			local clone2 = c_Tr.TpGround:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 6)
		end
	elseif stage == 2 then
		local root = data.Root
		local parent = root.Parent
		local userCF = data.UserCF
		local victim = data.Victim
		local timestamp = data.Timestamp
		local camShift = data.CamShift
		local v = math.max(0.6 - (masterClock:GetTime() - timestamp), 0.1)
		local clone = c_Tr.TP.Shock:Clone()
		Util.SetParentOverrideWithColor(clone, root, player, "YetiFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1.7)
		Util.Sound:Play("YETI_TNSFM_C_AfterimageAssault_Connect_01", root)

		if parent and root then
			if camShift and game.Players.LocalPlayer.Character and root.Parent == game.Players.LocalPlayer.Character then
				local currentCamera = workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				local _ = cFrame.p - root.Position
				local orientation, _, _ = (cFrame - cFrame.p):ToOrientation()
				local _, v2, v3 = userCF:ToOrientation()
				RunService:BindToRenderStep("TPCAM", Enum.RenderPriority.Camera.Value + 1, function()
					if currentCamera then
						currentCamera.CFrame = currentCamera.CFrame:Lerp(
							CFrame.new(userCF.p) * CFrame.fromOrientation(orientation, v2, v3),
							0.55
						)
					else
						RunService:UnbindFromRenderStep("TPCAM")
					end

					RunService.RenderStepped:Wait()
				end)
				task.spawn(function()
					wait(v)
					RunService:UnbindFromRenderStep("TPCAM")
				end)
			end

			task.spawn(function()
				task.spawn(function()
					task.wait(0.35)
					emitAll(root.Parent.YetiRig.YetiRig.CCharge["Hand2.R"])
				end)
				local player2 = data.Player
				local Players = game:GetService("Players")

				if player2 == Players.LocalPlayer then
					task.spawn(function()
						task.wait(0.283)
						local clone2 = script.LTN:Clone()
						Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
						Util.Debris:AddItem(clone2, 2)
						TweenService:Create(
							clone2,
							TweenInfo.new(1.267, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(126, 214, 255),
									player,
									"YetiFruitVFXColor"
								),
								Brightness = -1,
								Contrast = 2,
								Saturation = -1
							}
						):Play()
						task.wait(1.267)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.033, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(17, 199, 255),
									player,
									"YetiFruitVFXColor"
								),
								Brightness = 0.3,
								Contrast = -2,
								Saturation = -2
							}
						):Play()
						task.wait(0.033)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(219, 235, 255),
									player,
									"YetiFruitVFXColor"
								),
								Brightness = 0.7,
								Contrast = 1.5,
								Saturation = -1
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									player,
									"YetiFruitVFXColor"
								),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							}
						):Play()
					end)
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.283, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								FieldOfView = 85
							}
						):Play()
						task.wait(0.283)
						Util.CameraShaker:ShakeOnce(
							12,
							7,
							0.05,
							0.4,
							createVector(1, 1, 1),
							createVector(0.7, 0.7, 0.7)
						)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.317, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								FieldOfView = 55
							}
						):Play()
						task.wait(0.317)
						Util.CameraShaker:ShakeOnce(
							12,
							7,
							0.05,
							0.3,
							createVector(1, 1, 1),
							createVector(0.7, 0.7, 0.7)
						)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								FieldOfView = 90
							}
						):Play()
						task.wait(0.1)
						Util.CameraShaker:ShakeOnce(
							7,
							7,
							0.1,
							1.2,
							createVector(0.5, 0.5, 0.5),
							createVector(0.5, 0.5, 0.5)
						)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.855, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								FieldOfView = 53
							}
						):Play()
						task.wait(0.855)
						Util.CameraShaker:ShakeOnce(
							12,
							12,
							0.05,
							0.9,
							createVector(1.3, 1.3, 1.3),
							createVector(1.5, 1.5, 1.5)
						)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.133, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								FieldOfView = 30
							}
						):Play()
						task.wait(0.133)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.333, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								FieldOfView = 70
							}
						):Play()
					end)
				elseif victim then
					local Players2 = game:GetService("Players")

					if victim == Players2.LocalPlayer.Character then
						task.spawn(function()
							task.wait(0.283)
							local clone2 = script.LTN:Clone()
							Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone2, 2)
							TweenService:Create(
								clone2,
								TweenInfo.new(1.267, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(126, 214, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = -1,
									Contrast = 2,
									Saturation = -1
								}
							):Play()
							task.wait(1.267)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.033, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(17, 199, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0.3,
									Contrast = -2,
									Saturation = -2
								}
							):Play()
							task.wait(0.033)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(219, 235, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0.7,
									Contrast = 1.5,
									Saturation = -1
								}
							):Play()
							task.wait(0.05)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 255, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0,
									Contrast = 0,
									Saturation = 0
								}
							):Play()
						end)
						task.spawn(function()
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.283, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									FieldOfView = 85
								}
							):Play()
							task.wait(0.283)
							Util.CameraShaker:ShakeOnce(
								12,
								7,
								0.05,
								0.4,
								createVector(1, 1, 1),
								createVector(0.7, 0.7, 0.7)
							)
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.317, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									FieldOfView = 55
								}
							):Play()
							task.wait(0.317)
							Util.CameraShaker:ShakeOnce(
								12,
								7,
								0.05,
								0.3,
								createVector(1, 1, 1),
								createVector(0.7, 0.7, 0.7)
							)
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									FieldOfView = 90
								}
							):Play()
							task.wait(0.1)
							Util.CameraShaker:ShakeOnce(
								7,
								7,
								0.1,
								1.2,
								createVector(0.5, 0.5, 0.5),
								createVector(0.5, 0.5, 0.5)
							)
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.855, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									FieldOfView = 53
								}
							):Play()
							task.wait(0.855)
							Util.CameraShaker:ShakeOnce(
								12,
								12,
								0.05,
								0.9,
								createVector(1.3, 1.3, 1.3),
								createVector(1.5, 1.5, 1.5)
							)
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.133, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									FieldOfView = 30
								}
							):Play()
							task.wait(0.133)
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.333, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									FieldOfView = 70
								}
							):Play()
						end)
					end
				end

				task.spawn(function()
					local clone2 = c_Tr.Lit:Clone()
					Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 3)
					TweenService:Create(clone2, TweenInfo.new(0.133, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Brightness = 1,
						Range = 20
					}):Play()
					task.wait(0.283)
					TweenService:Create(clone2, TweenInfo.new(1.267, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
						Brightness = 3,
						Range = 45
					}):Play()
					task.wait(1.267)
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						Brightness = 0,
						Range = 65
					}):Play()
				end)
				task.spawn(function()
					local clone2 = c_Tr.TPed.tp:Clone()
					Util.SetParentOverrideWithColor(clone2, root, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 1)
					emitAll(clone2)
					local clone3 = c_Tr.Hands.Charge:Clone()
					Util.SetParentOverrideWithColor(clone3, root.Parent.RightHand, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 1.5)
					local clone4 = c_Tr.Hands.Hold:Clone()
					Util.SetParentOverrideWithColor(clone4, root.Parent.RightHand, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 1.5)
					emitAll(clone3)
					clone4.Rocks.Enabled = true
					clone4.Spike.Enabled = true
					clone4.Ring.Enabled = true
					task.wait(0.167)
					clone4.RingPop:Emit(5)
				end)
				task.wait(0.535)
				local clone2 = c_Tr.ImpactExplode:Clone()
				clone2.CFrame = userCF * CFrame.new(3.514, 2.344, -9.105)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 3)
				local clone3 = c_Tr.PressurePush:Clone()
				clone3.CFrame = userCF * CFrame.new(3.514, 2.344, -6.105)
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 4)
				task.spawn(function()
					emitAll(clone2)
					task.wait(0.067)

					for _ = 1, 16 do
						task.wait(0.05)
						emitAll(clone3)
					end
				end)
				task.spawn(function()
					task.wait(1.032)
				end)
			end)

			local function whitering(_)
				local clone2 = c_Tr.BillboardGui2:Clone()
				local imageLabel2 = clone2:WaitForChild("ImageLabel2")
				Util.SetParentOverrideWithColor(clone2, parent:FindFirstChild("RightHand"), player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 4)
				imageLabel2.Size = UDim2.new(1, 0, 1, 0)
				imageLabel2.Position = UDim2.new(0, 0, 0, 0)
				TweenService:Create(imageLabel2, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0)
				}):Play()
				TweenService:Create(imageLabel2, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					ImageTransparency = 1
				}):Play()
			end

			task.spawn(function()
				task.wait(0.8)
				whitering(0.25)
				task.wait(0.317)
				whitering(0.21)
				task.wait(0.23)
				whitering(0.18)
				task.wait(0.083)
				whitering(0.11)
			end)
		end

		task.spawn(function()
			task.wait(1.683)
			task.spawn(function()
				local player2 = data.Player
				local Players = game:GetService("Players")
				local clone2

				if player2 == Players.LocalPlayer then
					clone2 = script.DOF:Clone()
					Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 2)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.433, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
				elseif victim then
					local Players2 = game:GetService("Players")

					if victim == Players2.LocalPlayer.Character then
						clone2 = script.DOF:Clone()
						Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
						Util.Debris:AddItem(clone2, 2)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.433, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								FarIntensity = 0,
								FocusDistance = 0,
								InFocusRadius = 0,
								NearIntensity = 0
							}
						):Play()
					end
				end
			end)
			task.spawn(function()
				local clone2 = c_Tr.BLASTC:Clone()
				local lookVector = userCF.LookVector
				local v2 = root.Position + lookVector * 35
				local ray = Util.Ray
				local v3 = { workspace.Characters, workspace.Enemies }
				local v4, v5, v6 = ray(v2, createVector(0, -30, 0), v3)

				if v4 then
					local v7 = v6 * 0.1
					local v8 = userCF
					clone2.CFrame = CFrame.new(v5 + v7) * v8 - v8.p
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone2, 2.5)
					emitAll(clone2)
				else
					local clone3 = c_Tr.BLASTCAir:Clone()
					clone3.CFrame = userCF * CFrame.new(0, 0, -35)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 2.5)
					emitAll(clone3)
				end
			end)
		end)
	elseif stage == 5 then
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local function enableAll(folder, enabled: boolean)
			for _, effect in folder:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = enabled
				end
			end
		end

		local v = Util.Sound:Play("YETI_TNSFM_C_Hold", root)
		local cCharge = root.Parent.YetiRig:FindFirstChild("YetiRig").CCharge
		enableAll(cCharge, true)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.035
					task.spawn(function()
						local clone = c_Tr.partflybamp:Clone()
						clone.CFrame = cCharge["Hand2.R"].CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-1.5, 15),
							math.random(-15, 15)
						)
						Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
						Util.Debris:AddItem(clone, 2)
						local v2 = math.random(15, 35) / 100
						Beziers.Interpolate(
							"Cubic",
							v2,
							100,
							v2,
							nil,
							clone.CFrame,
							clone.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							clone.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							cCharge["Hand2.R"].CFrame,
							clone,
							"CFrame"
						)
					end)
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		task.wait(0.05)
		enableAll(cCharge, false)

		for _, folder in pairs({}) do
			if folder:IsDescendantOf(workspace) then
				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			local v3 = folder
			task.spawn(function()
				task.wait(1)
				v3:Destroy()
			end)
		end
	end
end