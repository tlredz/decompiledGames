local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = nil
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local tweenProperty = Util.xmc_Helper.TweenProperty
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
local werewolfUltimate = tigerEffects.WerewolfUltimate
local Beziers = require(script.Parent.Parent.Modules.Beziers)
local TweenService = game:GetService("TweenService")

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

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function lateralRocks(startCFrame, p, magnitude, p2, p3)
	local v = {
		workspace._WorldOrigin,
		workspace.Characters,
		workspace.Enemies,
		workspace.Boats
	}
	task.spawn(function()
		local v2 = math.floor(magnitude / p2)

		for i = 1, v2 do
			local v3 = (1 - math.pow(1 - (i - 1) / v2, 2)) * magnitude
			local v4 = p2 * (1 + 0.4 * math.random())

			for i2 = -1, 1, 2 do
				if ((v3 <= p2 * 4 or magnitude - p2 * 4 <= v3) and 0.6 or 0.75) < math.random() then
					continue
				end

				local v5

				if math.random(1, 5) == 1 then
					v5 = 0.5 + math.random() * 0.25
				else
					v5 = false
				end

				if v5 then
					v4 *= v5
				end

				local v6 = p / 2 * i2 * (1 + math.random() * 0.2) * (v5 or 1)
				local v7 = startCFrame.Position + startCFrame.RightVector * v6 + startCFrame.LookVector * v3 + createVector(
					0,
					1,
					0
				)
				local vector2 = Vector3.new(0, -p, 0)
				local ray, v8, v9 = Util.Ray(v7, vector2, v)

				if not (ray and ray.Anchored and ray.Transparency <= 0) then
					continue
				end

				local alignCFrame = Util.Misc.AlignCFrame(
					CFrame.lookAt(createVector(0, 0, 0), startCFrame.LookVector) + v8,
					v9
				)
				local cFrame = alignCFrame * CFrame.new(0, -v4 * 0.5, 0)
				local cFrame2 = alignCFrame * CFrame.new(0, -v4 * 0.25, 0) * CFrame.Angles(
					0,
					0,
					i2 * math.rad((math.random(10, 30)))
				)
				local part = Instance.new("Part")
				part.Color = ray.Color
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Material = ray.Material
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(1 + math.random(), 1, 1 + math.random() * 1.5) * v4
				part.CFrame = cFrame
				Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "LeopardFruitVFXColor")
				local tween = TweenService:Create(
					part,
					TweenInfo.new(0.1 + math.random() * 0.2, Enum.EasingStyle.Back),
					{
						CFrame = cFrame2
					}
				)
				tween.Completed:Connect(function()
					task.wait(1.8 + 0.2 * math.random())
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							CFrame = cFrame * CFrame.new(0, -v4 * 0.1, 0)
						}
					)
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end

			task.wait(p3 / v2)
		end
	end)
end

return function(data)
	player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local rigModel = data.RigModel
	local root = data.Root or data.hrp
	local tigerRig = root.Parent.TigerRig:FindFirstChild("TigerRig")

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		Instance.new("Folder", _WorldOrigin)
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone = FX2:WaitForChild("TigerEffects").C_Trans.TigerRoot.Hold:Clone()
		Util.SetParentOverrideWithColor(clone, tigerRig.PrimaryPart, player, "LeopardFruitVFXColor")
		clone.Position = createVector(0, -5.5, 0)
		task.spawn(function()
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(2, 8, 0.05, 0.4, createVector(1, 1, 1), createVector(0.9, 0.9, 0.9))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 97, 34),
							player,
							"LeopardFruitVFXColor"
						),
						Brightness = -0.4,
						Saturation = -0.4,
						Contrast = 8
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 166, 93),
							player,
							"LeopardFruitVFXColor"
						),
						Brightness = 0.4,
						Saturation = 0,
						Contrast = 1
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"LeopardFruitVFXColor"
						),
						Brightness = 0,
						Saturation = 0,
						Contrast = 0
					}
				):Play()
			end
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.05

					if root.Parent == game.Players.LocalPlayer.Character then
						Util.CameraShaker:ShakeOnce(
							2,
							4,
							0.05,
							0.14,
							createVector(0.2, 0.2, 0.2),
							createVector(0.2, 0.2, 0.2)
						)
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.8
					emitAll(clone.DASH)
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		repeat
			task.wait()
		until not (holding.Value and holding)

		task.delay(0.1, function()
			clone:Destroy()
		end)
	elseif stage == 2 then
		if root.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(6, 9, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 0.3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 48, 11),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = -1,
							Saturation = -1,
							Contrast = 8
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 166, 93),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.4,
							Saturation = 0,
							Contrast = 1
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0,
							Contrast = 0
						}
					):Play()
				end
			end)
			task.spawn(function()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						7,
						7,
						0.05,
						0.6,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
				end

				task.wait(0.15)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		local clone = tigerEffects.Z_Awak.DashStart:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 2.5)
		emitAll(clone)
		local _ = data.timeUntilReachedEndPoint
		local _ = data.endPoint
		local startCFrame = data.StartCFrame
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 20)
		local clone2 = tigerEffects.PART_TEMPLATE:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
		task.spawn(function()
			for _ = 1, 12 do
				local clone3 = tigerEffects.Z_Awak.Floor:Clone()
				local ray = Util.Ray
				local v = root.Position + createVector(0, 2, 0)
				local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
				local v3, v4, _ = ray(v, createVector(-0, -25, -0), v2, false)

				if v3 ~= nil then
					local v5 = v4
					local v6 = clone3
					task.spawn(function()
						v6.CFrame = CFrame.new(v5)
						Util.SetParentOverrideWithColor(v6, _WorldOrigin, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(v6, 2.8)
						emitAll(v6)
					end)
				end

				task.wait(0.015)
			end
		end)
		local clone3 = tigerEffects.Z_Awak.DashLoop:Clone()
		clone3.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
		task.spawn(function()
			for _ = 1, 9 do
				task.spawn(function()
					for _ = 1, 2 do
						local clone4 = tigerEffects.Z_Awak.partfly:Clone()
						clone4.CFrame = root.CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-1.5, 15),
							math.random(-15, 15)
						)
						Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone4, 2)
						local v = math.random(11, 16) / 100
						Beziers.Interpolate(
							"Cubic",
							v,
							100,
							v,
							nil,
							clone4.CFrame,
							clone4.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							clone4.CFrame * CFrame.new(math.random(-45, 45), math.random(-1, 15), math.random(-45, 45)),
							root.CFrame,
							clone4,
							"CFrame"
						)
					end
				end)
				task.wait(0.0075)
			end
		end)
		task.spawn(function()
			clone3.AttachmentX.WindBack.Enabled = true
			clone3.strike.Enabled = true
			clone3.strike2.Enabled = true
			clone3.strike3.Enabled = true
			task.wait(0.2)
			clone3.AttachmentX.WindBack.Enabled = false
			clone3.strike.Enabled = false
			clone3.strike2.Enabled = false
			clone3.strike3.Enabled = false
		end)
		task.spawn(function()
			for _ = 1, 5 do
				emitAll(clone3.dashloop)
				task.wait(0.0125)
			end
		end)
		local endPoint = data.endPoint
		local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint or 0.2
		local magnitude = (startCFrame.Position - endPoint).Magnitude
		lateralRocks(startCFrame, 12, magnitude, 4, timeUntilReachedEndPoint / 4)
		task.spawn(function()
			root.Anchored = true
			local cFrame = CFrame.new(data.endPoint, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime = os.clock()

			while os.clock() - lastTime < timeUntilReachedEndPoint do
				local v2 = (os.clock() - lastTime) / timeUntilReachedEndPoint
				root.CFrame = cFrame * CFrame.new(0, 0, magnitude * (1 - v2 ^ 0.5))
				clone3.CFrame = root.CFrame
				RunService.PreSimulation:Wait()
			end

			root.CFrame = cFrame
			root.Anchored = false
		end)

		if data.Player then
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				return
			end
		end
	elseif stage == 3 then
		local enemyRoot = data.EnemyRoot

		if not enemyRoot then
			return
		end

		local root2 = data.Root

		if not (root2 and data.Rig) then
			return
		end

		local humanoid = enemyRoot.Parent:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local primaryPart = data.Rig.PrimaryPart
		local _ = enemyRoot.Size.Y * 0.5 + humanoid.HipHeight
		root2.Anchored = true
		enemyRoot.Anchored = true
		root2.CFrame = data.StartCFrame
		local name = "WerewolfCutscene_" .. root2.Parent.Name
		local folder = Instance.new("Folder")
		folder.Name = name
		Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local clone = werewolfUltimate.UltimateModel:Clone()
		clone:PivotTo(primaryPart.CFrame)
		local VFX = clone.RootPart.VFX
		VFX.Parent = primaryPart
		local folder2 = Instance.new("Folder")
		folder2.Name = "CutsceneEffects"
		folder2.Parent = rigModel
		Util.Debris:AddItem(folder2, 5)
		local clone_2 = werewolfUltimate.Eyes:Clone()
		clone_2.Parent = folder2
		local clone2 = werewolfUltimate.Cutscene:Clone()
		clone2.Parent = folder2
		local v2 = false

		for _, rigidConstraint in pairs(folder2:GetDescendants()) do
			if not rigidConstraint:IsA("RigidConstraint") then
				continue
			end

			local boneAttach = rigidConstraint:GetAttribute("BoneAttach")

			if not boneAttach then
				continue
			end

			local child = primaryPart.Controller:FindFirstChild(boneAttach, true)

			if not child then
				continue
			end

			rigidConstraint.Attachment1 = child
			print("set attachment")
		end

		local attacker = data.Attacker
		local Players2 = game:GetService("Players")
		local v4

		if attacker == Players2.LocalPlayer then
			v4 = true
		else
			local Players3 = game:GetService("Players")
			local playerFromCharacter = Players3:GetPlayerFromCharacter(enemyRoot.Parent)
			local Players4 = game:GetService("Players")
			v4 = playerFromCharacter == Players4.LocalPlayer or false
		end

		local v5 = false
		task.spawn(function()
			local v6 = tick() + 2.1374999999999997

			while not (v6 < tick()) and root2 and root2:IsDescendantOf(workspace) and enemyRoot and enemyRoot:IsDescendantOf(workspace) and humanoid and humanoid:IsDescendantOf(workspace) and not (humanoid.Health <= 0 or v5) do
				root2.CFrame = data.StartCFrame
				enemyRoot.CFrame = clone.EnemyRootPart.CFrame
				task.wait()
			end

			enemyRoot.Anchored = false
		end)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		local clone3 = werewolfUltimate.TIGERATMOSPHERE:Clone()
		local clone4 = werewolfUltimate.TIGERCCE:Clone()
		local clone5 = werewolfUltimate.TigerBlur:Clone()

		if v4 then
			local Lighting = game:GetService("Lighting")
			clone3.Parent = Lighting.LightingLayers
			clone4.Parent = game:GetService("Lighting")
			clone5.Parent = game:GetService("Lighting")
		else
			clone3.Parent = folder
			clone4.Parent = folder
			clone5.Parent = folder
		end

		Util.Debris:AddItem(clone3, 2.5)
		Util.Debris:AddItem(clone4, 2.5)
		Util.Debris:AddItem(clone5, 2.5)
		local v6

		if v4 then
			local sound = Util.Sound
			local Players3 = game:GetService("Players")
			v6 = sound:Play("Halloween_Werewolf_Cutscene_01_V2", Players3.LocalPlayer.PlayerGui)
		else
			v6 = Util.Sound:Play("Halloween_Werewolf_Cutscene_01_V2", root2)
		end

		local renderSteppedConnection = nil
		local characterRemovingConnection = nil

		local function clear()
			v2 = true

			if v4 then
				task.spawn(function()
					TweenService:Create(workspace.Camera, TweenInfo.new(0.2), {
						FieldOfView = 70
					}):Play()
					task.wait()
					TweenService:Create(workspace.Camera, TweenInfo.new(0.2), {
						FieldOfView = 70
					}):Play()
					task.wait()
					TweenService:Create(workspace.Camera, TweenInfo.new(1), {
						FieldOfView = 70
					}):Play()
				end)

				if clone4 then
					clone4:Destroy()
				end

				if clone5 then
					clone5:Destroy()
				end

				if clone3 then
					clone3:SetAttribute("Intensity", 0)
					clone3:SetAttribute("ZIndex", -1)
					task.delay(3, function()
						if clone3 then
							clone3:Destroy()
						end
					end)
				end

				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				workspace.CurrentCamera.FieldOfView = 70

				if v6 then
					Util.Sound:FadeOut(v6, 0.5)
				end
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if characterRemovingConnection then
				characterRemovingConnection:Disconnect()
			end
		end

		if v4 then
			characterRemovingConnection = localPlayer.CharacterRemoving:Once(function()
				clear()
			end)
		end

		task.spawn(function()
			task.wait()

			if v6 then
				v6.TimePosition = 0
				v6.Volume = 1.3
			end

			local v7 = {
				[1] = data.Rig,
				[2] = clone.CamReAdd,
				[4] = clone3,
				[5] = clone4,
				[6] = game.Workspace.CurrentCamera,
				[7] = clone5,
				[8] = folder2.Eyes.EyeR.VFX.EyeL.Trail,
				[9] = folder2.Eyes.EyeL.VFX.EyeL.Trail
			}
			local v8 = {}

			local function Emit(beam)
				if beam:IsA("Beam") then
					local emitDelay = beam:GetAttribute("EmitDelay")
					local emitDuration = beam:GetAttribute("EmitDuration")
					task.delay(tonumber(emitDelay) or 0, function()
						if tonumber(emitDuration) and emitDuration ~= 0 then
							beam.Enabled = true

							if not beam:GetAttribute("pr3") then
								beam:SetAttribute("pr3", 0)
							end

							local v9 = (beam:GetAttribute("pr3") + 1) % 1000
							beam:SetAttribute("pr3", v9)
							task.wait(emitDuration)

							if v9 == beam:GetAttribute("pr3") then
								beam.Enabled = false
							end
						end
					end)
				else
					local emitCount = beam:GetAttribute("EmitCount")
					local emitDelay = beam:GetAttribute("EmitDelay")
					local emitDuration = beam:GetAttribute("EmitDuration")
					task.delay(tonumber(emitDelay) or 0, function()
						beam:Emit(emitCount or 0)

						if tonumber(emitDuration) and emitDuration ~= 0 then
							beam.Enabled = true

							if not beam:GetAttribute("pr3") then
								beam:SetAttribute("pr3", 0)
							end

							local v9 = (beam:GetAttribute("pr3") + 1) % 1000
							beam:SetAttribute("pr3", v9)
							task.wait(emitDuration)

							if v9 == beam:GetAttribute("pr3") then
								beam.Enabled = false
							end
						end
					end)
				end
			end

			v7[4].Offset = 0
			v7[4].Color = Color3.fromRGB(199, 170, 107)
			v7[4].Decay = Color3.fromRGB(92, 60, 13)
			v7[4].Density = 0
			v7[4].Haze = 0
			v7[5].TintColor = Color3.fromRGB(255, 255, 255)
			v7[5].Brightness = 0
			v7[5].Saturation = 0
			v7[5].Contrast = 0

			if v4 then
				v7[6].FieldOfView = 70
			end

			v7[7].Size = 0
			v7[8].Enabled = true
			v7[9].Enabled = true

			v8[0] = function()
				task.spawn(function()
					for _, effect in clone2.LHand:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.1, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.1, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.1, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.08333, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 0, 0.16667, "Linear", nil)
				tweenProperty(v7[8], "Enabled", true, 0.01667, "Constant", nil)
				tweenProperty(v7[9], "Enabled", true, 0.01667, "Constant", nil)
			end

			v8[1] = function()
				tweenProperty(v7[8], "Enabled", false, 2.46667, "Constant", nil)
				tweenProperty(v7[9], "Enabled", false, 2.46667, "Constant", nil)
			end

			v8[5] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 80, 0.13333, "Linear", nil)
				end
			end

			v8[6] = function()
				task.spawn(function()
					for _, effect in clone2.LHandGrab:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(62, 53, 132), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -5, 0.01667, "Linear", nil)
			end

			v8[7] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(156, 138, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0.800000011920929, 0.01667, "Linear", nil)
			end

			v8[8] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[9] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.18333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.18333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.18333, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.18333, "Linear", nil)
			end

			v8[10] = function()
				tweenProperty(v7[7], "Size", 10, 0.01667, "Linear", nil)
			end

			v8[11] = function()
				task.spawn(function()
					for _, effect in clone2.LFootKickPre:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[7], "Size", 0, 0.16667, "Linear", nil)
			end

			v8[13] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.16667, "Back", "InOut", 1.70158)
				end
			end

			v8[20] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(5, 0, 128), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -55, 0.01667, "Linear", nil)
			end

			v8[21] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(104, 11, 255), 0.05, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.05, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 15, 0.05, "Linear", nil)
				tweenProperty(v7[7], "Size", 0, 0.1, "Linear", nil)
			end

			v8[22] = function()
				task.spawn(function()
					for _, effect in clone2.LFootKickFirst:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[23] = function()
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 50, 0.06667, "Back", "InOut", 1.70158)
				end
			end

			v8[24] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[25] = function()
				task.spawn(function()
					for _, effect in VFX.Push1:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.55, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.55, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.55, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.55, "Linear", nil)
			end

			v8[27] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 90, 0.03333, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 12, 0.01667, "Linear", nil)
			end

			v8[28] = function()
				task.spawn(function()
					for _, effect in VFX.LegHit:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[7], "Size", 0, 0.1, "Sine", "InOut")
			end

			v8[29] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.26667, "Back", "Out", 1.70158)
				end
			end

			v8[34] = function()
				tweenProperty(v7[7], "Size", 0, 0.38333, "Linear", nil)
			end

			v8[45] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.2, "Linear", nil)
				end
			end

			v8[55] = function()
				task.spawn(function()
					for _, effect in VFX.clawfirst:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[57] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 95, 0.01667, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 25, 0.01667, "Linear", nil)
			end

			v8[58] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(62, 53, 132), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -5, 0.01667, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.15, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 0, 0.05, "Sine", "InOut")
			end

			v8[59] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(5, 0, 128), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -55, 0.01667, "Linear", nil)
			end

			v8[60] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(31, 12, 255), 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 15, 0.03333, "Linear", nil)
			end

			v8[61] = function()
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[7], "Size", 0, 0.3, "Linear", nil)
			end

			v8[62] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[63] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.28333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.28333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.28333, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.28333, "Linear", nil)
			end

			v8[67] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.2, "Linear", nil)
				end
			end

			v8[79] = function()
				task.spawn(function()
					for _, effect in VFX.clawsecond:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 95, 0.01667, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 25, 0.01667, "Linear", nil)
			end

			v8[80] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(62, 53, 132), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -5, 0.01667, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.15, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 0, 0.1, "Sine", "InOut")
			end

			v8[81] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(5, 0, 128), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -55, 0.01667, "Linear", nil)
			end

			v8[82] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(31, 12, 255), 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 15, 0.03333, "Linear", nil)
			end

			v8[83] = function()
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)
			end

			v8[84] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[85] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.26667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.26667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.26667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.26667, "Linear", nil)
			end

			v8[86] = function()
				tweenProperty(v7[7], "Size", 0, 0.33333, "Linear", nil)
			end

			v8[89] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.28333, "Linear", nil)
				end
			end

			v8[101] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(62, 53, 132), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -5, 0.01667, "Linear", nil)
			end

			v8[102] = function()
				task.spawn(function()
					for _, effect in VFX.clawthird:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(5, 0, 128), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -55, 0.01667, "Linear", nil)
			end

			v8[103] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(31, 12, 255), 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 15, 0.03333, "Linear", nil)
			end

			v8[104] = function()
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)
			end

			v8[105] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[106] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.38333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.38333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.38333, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.38333, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 95, 0.01667, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 25, 0.01667, "Linear", nil)
			end

			v8[107] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.1, "Linear", nil)
				end

				tweenProperty(v7[7], "Size", 0, 0.1, "Sine", "InOut")
			end

			v8[113] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 60, 0.06667, "Linear", nil)
				end
			end

			v8[115] = function()
				task.spawn(function()
					for _, effect in clone2.LFootKickPre2:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[117] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 66, 0.21667, "Linear", nil)
				end
			end

			v8[129] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(62, 53, 132), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -5, 0.01667, "Linear", nil)
			end

			v8[130] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(0, 22, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 3, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", -15, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", -25, 0.01667, "Linear", nil)

				if v4 then
					tweenProperty(v7[6], "FieldOfView", 90, 0.03333, "Linear", nil)
				end
			end

			v8[131] = function()
				task.spawn(function()
					for _, effect in VFX.KICK:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(0, 0, 0), 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Brightness", -2, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 15, 0.03333, "Linear", nil)
			end

			v8[132] = function()
				if v4 then
					tweenProperty(v7[6], "FieldOfView", 70, 0.28333, "Linear", nil)
				end
			end

			v8[133] = function()
				tweenProperty(v7[5], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Brightness", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Saturation", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v8[134] = function() end

			v8[149] = function() end

			local total = 0
			local v9 = -1

			while not v2 do
				local v10 = total * 60 // 1
				local v11 = v10 - v9

				if v11 > 0 then
					for i = v9 + 1, v9 + v11 do
						local v12 = v8[i]

						if v12 then
							v12()
						end
					end

					v9 = v10
				end

				total += task.wait() * 1

				if v10 > 150 then
					break
				end
			end
		end)
		local werewolfUltimate2 = Util.Anims:Get(data.Rig, "WerewolfUltimate")
		werewolfUltimate2.Priority = Enum.AnimationPriority.Action4
		werewolfUltimate2:Play()
		Util.Anims:Get(clone.CamReAdd, "WerewolfUltimate_Camera"):Play()
		local werewolfUltimateVictim = Util.Anims:Get(enemyRoot.Parent, "WerewolfUltimate_Victim")
		werewolfUltimateVictim.Priority = Enum.AnimationPriority.Action4
		werewolfUltimateVictim:Play()
		local lastTime = tick()
		local currentCamera = workspace.CurrentCamera

		if v4 then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
			if tick() - lastTime > 2.25 then
				v5 = true
				renderSteppedConnection:Disconnect()

				if enemyRoot then
					enemyRoot.Anchored = false
				end

				if root2 then
					root2.Anchored = false
				end

				if characterRemovingConnection then
					characterRemovingConnection:Disconnect()
				end

				local part = Instance.new("Part")
				part.Transparency = 1
				part.CanCollide = false
				part.Anchored = true
				part.Size = primaryPart.Size
				part.CFrame = primaryPart.CFrame
				part.Parent = folder
				VFX.Parent = part

				if v4 then
					if not (root2 and root2:IsA("BasePart")) then
						currentCamera.CameraType = Enum.CameraType.Custom
						return
					end

					local position = (root2.CFrame * CFrame.new(0, 2, 5)).Position
					currentCamera.CameraType = Enum.CameraType.Scriptable
					currentCamera.CFrame = CFrame.lookAt(position, root2.Position)
					currentCamera.CameraType = Enum.CameraType.Custom
				end
			elseif v4 then
				currentCamera.CFrame = clone.CamReAdd.Cam.CFrame
			end
		end)
	end
end