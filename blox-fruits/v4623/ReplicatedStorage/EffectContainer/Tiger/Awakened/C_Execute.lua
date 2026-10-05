local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local tweenProperty = Util.xmc_Helper.TweenProperty
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
local ultimate = tigerEffects.Ultimate
local RockRipple = require(script.Parent.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
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

local function lateralRocks(player, startCFrame, p, magnitude, p2, p3)
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
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local _ = data.RigModel
	local root = data.Root or data.hrp
	local tigerRig = root and root.Parent.TigerRig:FindFirstChild("TigerRig")

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		Instance.new("Folder", _WorldOrigin)
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone = FX2:WaitForChild("TigerEffects").C_Trans.TigerRoot.Hold:Clone()
		Util.SetParentOverrideWithColor(clone, tigerRig.PrimaryPart, player, "LeopardFruitVFXColor")
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

		Util.Sound:Play("Halloween_Werewolf_Cutscene_Dash_In_03_V2", root)
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
		lateralRocks(player, startCFrame, 12, magnitude, 4, timeUntilReachedEndPoint / 4)
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

		local primaryPart = data.Rig.PrimaryPart
		local _ = enemyRoot.Size.Y * 0.5 + humanoid.HipHeight
		root2.Anchored = true
		enemyRoot.Anchored = true
		local name = "TigerCutscene_" .. root2.Parent.Name
		local v2 = false
		local folder = Instance.new("Folder")
		folder.Name = name
		Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local clone = ultimate.UltimateModel:Clone()
		clone:PivotTo(primaryPart.CFrame)
		CFrame.new(0, 3.612, 0)
		local vFXCMove = clone.VFXCMove
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
			local v6 = tick() + 4.449166666666667

			while not (v6 < tick()) and root2 and root2:IsDescendantOf(workspace) and enemyRoot and enemyRoot:IsDescendantOf(workspace) and humanoid and humanoid:IsDescendantOf(workspace) and not (humanoid.Health <= 0 or v5 or v2) do
				root2.CFrame = data.StartCFrame
				enemyRoot.CFrame = clone.EnemyRootPart.CFrame
				task.wait()
			end

			enemyRoot.Anchored = false
		end)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor")
		highlight.FillTransparency = 0.05
		highlight.OutlineTransparency = 1
		Util.SetParentOverrideWithColor(highlight, data.Rig, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(highlight, 5.34)
		local clone2 = ultimate.TIGERATMOSPHERE:Clone()
		local clone3 = ultimate.TIGERCCE:Clone()
		local clone4 = ultimate.TigerBlur:Clone()

		if v4 then
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local Lighting = game:GetService("Lighting")
			setParentOverrideWithColor(clone2, Lighting.LightingLayers, player, "LeopardFruitVFXColor")
			local setParentOverrideWithColor2 = Util.SetParentOverrideWithColor
			local Lighting2 = game:GetService("Lighting")
			setParentOverrideWithColor2(clone3, Lighting2, player, "LeopardFruitVFXColor")
			local setParentOverrideWithColor3 = Util.SetParentOverrideWithColor
			local Lighting3 = game:GetService("Lighting")
			setParentOverrideWithColor3(clone4, Lighting3, player, "LeopardFruitVFXColor")
		else
			clone2.Parent = folder
			clone3.Parent = folder
			clone4.Parent = folder
		end

		Util.Debris:AddItem(clone2, 5.34)
		Util.Debris:AddItem(clone3, 5.34)
		Util.Debris:AddItem(clone4, 5.34)
		local v6

		if v4 then
			local sound = Util.Sound
			local Players3 = game:GetService("Players")
			v6 = sound:Play("TF_TigerFruitCutscene_01_V2", Players3.LocalPlayer.PlayerGui)
		else
			v6 = Util.Sound:Play("TF_TigerFruitCutscene_01_V2", root2)
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

				if clone3 then
					clone3:Destroy()
				end

				if clone4 then
					clone4:Destroy()
				end

				if clone2 then
					clone2:SetAttribute("Intensity", 0)
					clone2:SetAttribute("ZIndex", -1)
					task.delay(3, function()
						if clone2 then
							clone2:Destroy()
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
			v6.TimePosition = 0
			v6.Volume = 2
			local v7 = {
				[3] = game.Workspace._WorldOrigin[name].UltimateModel.CamReAdd,
				[4] = game.Workspace.CurrentCamera,
				[5] = clone2,
				[8] = clone3,
				[9] = game.Workspace._WorldOrigin[name].UltimateModel.VFXCMove.PunchInch.Light.SpotLight,
				[10] = clone4,
				[11] = highlight,
				[12] = game.Workspace._WorldOrigin[name].UltimateModel.Wind.Mesh,
				[13] = game.Workspace._WorldOrigin[name].UltimateModel.Wind,
				[14] = game.Workspace._WorldOrigin[name].UltimateModel.Wind.Decal,
				[15] = game.Workspace._WorldOrigin[name].UltimateModel.VFXCMove.Root.Lightincrease.PointLight,
				[16] = game.Workspace._WorldOrigin[name].UltimateModel.MeshImpactRing.Mesh,
				[17] = game.Workspace._WorldOrigin[name].UltimateModel.MeshImpactRing.Decal,
				[18] = game.Workspace._WorldOrigin[name].UltimateModel.MeshImpactRing,
				[19] = game.Workspace._WorldOrigin[name].UltimateModel.windspiral,
				[20] = game.Workspace._WorldOrigin[name].UltimateModel.windspiral.Mesh,
				[21] = game.Workspace._WorldOrigin[name].UltimateModel.windspiral.Decal,
				[22] = game.Workspace._WorldOrigin[name].UltimateModel.circlerings,
				[23] = game.Workspace._WorldOrigin[name].UltimateModel.circlerings.Mesh,
				[24] = game.Workspace._WorldOrigin[name].UltimateModel.circlerings.Decal,
				[25] = game.Workspace._WorldOrigin[name].UltimateModel.f,
				[26] = game.Workspace._WorldOrigin[name].UltimateModel.f.Mesh,
				[27] = game.Workspace._WorldOrigin[name].UltimateModel.f.Decal
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

			if v4 then
				v7[4].FieldOfView = 70
			end

			v7[5].Offset = 0
			v7[5].Glare = 0
			v7[5].Color = Util.WrapColor3Constructor(Color3.fromRGB(199, 170, 107), player, "LeopardFruitVFXColor")
			v7[5].Decay = Util.WrapColor3Constructor(Color3.fromRGB(92, 60, 13), player, "LeopardFruitVFXColor")
			v7[5].Density = 0
			v7[5].Haze = 0
			v7[8].TintColor = Util.WrapColor3ConstructorForTintColor(
				Color3.fromRGB(255, 255, 255),
				player,
				"LeopardFruitVFXColor"
			)
			v7[8].Brightness = 0
			v7[8].Saturation = 0
			v7[8].Contrast = 0
			v7[9].Brightness = 23.200000762939453
			v7[10].Size = 0
			v7[11].FillTransparency = 0.05000000074505806
			v7[11].FillColor = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor")
			v7[12].Scale = createVector(0, 0, 0)
			v7[12].Offset = createVector(0, 0, 0)
			local cFrame = root2.CFrame * CFrame.new(0.353, 3.785, -3.868) * CFrame.Angles(
				0,
				1.5707963267948966,
				1.5707963267948966
			)
			v7[13].CFrame = cFrame
			v7[14].Transparency = 0
			v7[15].Brightness = 7.199999809265137
			v7[16].Scale = createVector(0, 0, 0)
			v7[17].Transparency = 0
			local cFrame2 = root2.CFrame * CFrame.new(0.353, 3.785, -3.868) * CFrame.Angles(
				1.0496410121493898,
				-1.5707963267948966,
				-1.5707963267948966
			)
			v7[18].CFrame = cFrame2
			local cFrame3 = root2.CFrame * CFrame.new(0.472, 3.473, 1.394) * CFrame.Angles(
				1.0496410121493898,
				-1.5707963267948966,
				-1.5707963267948966
			)
			v7[19].CFrame = cFrame3
			v7[20].Scale = createVector(5.0153694, 7.9961066, 5.0153694)
			v7[21].Transparency = 0
			v7[23].Scale = createVector(5.0153694, 5.6477656, 5.0153694)
			v7[24].Transparency = 0
			local cFrame4 = root2.CFrame * CFrame.new(-0.686, 13.533, 15.061) * CFrame.Angles(
				0,
				1.5707963267948966,
				-1.5707963267948966
			)
			v7[25].CFrame = cFrame4
			v7[26].Scale = createVector(5.4416943, 6, 5.371766)
			v7[27].Transparency = 0

			v8[0] = function()
				task.spawn(function()
					for _, effect in vFXCMove.FloorFire.Initial:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.06667, "Linear", nil)
				end

				tweenProperty(v7[5], "Offset", 0, 2.9, "Linear", nil)
				tweenProperty(v7[5], "Haze", 10, 2.9, "Linear", nil)
				tweenProperty(
					v7[5],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 0, 0), player, "LeopardFruitVFXColor"),
					2.9,
					"Linear",
					nil
				)
				tweenProperty(
					v7[5],
					"Decay",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 59, 52), player, "LeopardFruitVFXColor"),
					2.9,
					"Linear",
					nil
				)
				tweenProperty(v7[5], "Density", 0.5799999833106995, 2.78333, "Linear", nil)
				tweenProperty(v7[5], "Glare", 0, 2.9, "Linear", nil)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 220, 189),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.29999998211860657, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.550000011920929, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1.25, 0.01667, "Linear", nil)
				tweenProperty(v7[9], "Brightness", 0, 2.83333, "Linear", nil)
				tweenProperty(v7[10], "Size", 0, 2, "Linear", nil)
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(v7[15], "Brightness", 0, 3.88333, "Linear", nil)
				local v13 = primaryPart.CFrame * CFrame.new(0.472, -3.473, 1.394)
				tweenProperty(v7[19], "CFrame", v13, 4.7, "Linear", nil)
				tweenProperty(v7[20], "Scale", createVector(0, 0, 0), 4.7, "Linear", nil)
				tweenProperty(v7[21], "Transparency", 1, 4.7, "Linear", nil)
				local v14 = primaryPart.CFrame * CFrame.new(-0.231, -4.763, -2.671)
				tweenProperty(v7[22], "CFrame", v14, 4.7, "Linear", nil)
				tweenProperty(v7[23], "Scale", createVector(0, 0, 0), 4.7, "Linear", nil)
				tweenProperty(v7[24], "Transparency", 1, 4.7, "Linear", nil)
				tweenProperty(v7[26], "Scale", createVector(0, 0, 0), 4.71667, "Linear", nil)
				tweenProperty(v7[27], "Transparency", 1, 4.71667, "Linear", nil)
			end

			v8[1] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -1.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6000000238418579, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 5, 0.01667, "Linear", nil)
			end

			v8[2] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Lunge1st:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6000000238418579, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 2, 0.03333, "Linear", nil)
				tweenProperty(v7[11], "FillTransparency", 1, 0.13333, "Linear", nil)
			end

			v8[4] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Claw1:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.05, "Linear", nil)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.21667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.21667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.21667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.21667, "Linear", nil)
			end

			v8[7] = function()
				task.spawn(function()
					for _, effect in vFXCMove.StarsEtc:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.13333, "Back", "In", 1.70158)
				end
			end

			v8[10] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[11] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpFirst:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[12] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[14] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Root:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[11], "FillTransparency", 1, 0.15, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[15] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.05, "Linear", nil)
				end

				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.13333,
					"Linear",
					nil
				)
			end

			v8[17] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[18] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Hit.Second:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.21667, "Back", "In", 1.70158)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[20] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[22] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.18333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.18333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.18333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.18333, "Linear", nil)
			end

			v8[23] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[25] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpSecond:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[27] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.23333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[28] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.21667,
					"Linear",
					nil
				)
			end

			v8[31] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.05, "Linear", nil)
				end
			end

			v8[33] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[34] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Claw2:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)

				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.2, "Back", "In", 1.70158)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[36] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[38] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.16667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.16667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.16667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.16667, "Linear", nil)
			end

			v8[40] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpThird:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[41] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[43] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[45] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.16667, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[46] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.05, "Linear", nil)
				end

				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.15,
					"Linear",
					nil
				)
			end

			v8[48] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Hit.Third:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[49] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.18333, "Back", "In", 1.70158)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[51] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[53] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.11667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.11667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.11667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.11667, "Linear", nil)
			end

			v8[55] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpFourth:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[57] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[59] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.11667, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[60] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.06667, "Linear", nil)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.1,
					"Linear",
					nil
				)
			end

			v8[61] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Hit.Third2:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[63] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[64] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.13333, "Back", "In", 1.70158)
				end
			end

			v8[65] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.11667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.11667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.11667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.11667, "Linear", nil)
			end

			v8[66] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[68] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpFifth:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[70] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.15, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[71] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.13333,
					"Linear",
					nil
				)
			end

			v8[72] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.03333, "Linear", nil)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[73] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Claw3:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[74] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.13333, "Back", "In", 1.70158)
				end
			end

			v8[75] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[77] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.13333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.13333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.13333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.13333, "Linear", nil)
			end

			v8[79] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[81] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpSixth:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[82] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.06667, "Linear", nil)
				end
			end

			v8[83] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.08333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[84] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.06667,
					"Linear",
					nil
				)
			end

			v8[85] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[86] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.13333, "Back", "In", 1.70158)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[88] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[90] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.08333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.08333, "Linear", nil)
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[91] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpSeventh:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[92] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.11667, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[93] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.1,
					"Linear",
					nil
				)
			end

			v8[94] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.05, "Linear", nil)
				end
			end

			v8[95] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[96] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[97] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 65, 0.1, "Back", "In", 1.70158)
				end
			end

			v8[98] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[99] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[100] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpEighth:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.08333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.08333, "Linear", nil)
			end

			v8[101] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[103] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 64, 0.03333, "Linear", nil)
				end

				tweenProperty(v7[11], "FillTransparency", 1, 0.1, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[104] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.08333,
					"Linear",
					nil
				)
			end

			v8[105] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 90, 0.25, "Back", "In", 1.70158)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[106] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[108] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[109] = function()
				tweenProperty(v7[11], "FillTransparency", 0.05000000074505806, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[110] = function()
				task.spawn(function()
					for _, effect in vFXCMove.TpNinth:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.08333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.08333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.08333, "Linear", nil)
			end

			v8[111] = function()
				tweenProperty(v7[11], "FillTransparency", 1, 0.03333, "Linear", nil)
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.03333,
					"Linear",
					nil
				)
			end

			v8[113] = function()
				tweenProperty(
					v7[11],
					"FillColor",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 110, 0), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
			end

			v8[114] = function() end

			v8[115] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.6, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v8[116] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 185, 123),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.5, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.3, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v8[118] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 221, 195),
						player,
						"LeopardFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.10000000149011612, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.03333, "Linear", nil)
			end

			v8[120] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 90, 0.71667, "Linear", nil)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.76667,
					"Sextic",
					"In"
				)
				tweenProperty(v7[8], "Brightness", 0, 0.76667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0.09999999999999999, 0.76667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0.09999999999999999, 0.76667, "Linear", nil)
				tweenProperty(v7[10], "Size", 8, 0.01667, "Linear", nil)
			end

			v8[121] = function()
				task.spawn(function()
					for _, effect in vFXCMove.FloorFire.First:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[10], "Size", 0, 0.16667, "Bounce", "In")
			end

			v8[131] = function()
				tweenProperty(v7[10], "Size", 0, 1.41667, "Linear", nil)
			end

			v8[152] = function() end

			v8[163] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 50, 0.05, "Linear", nil)
				end
			end

			v8[166] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 100, 0.08333, "Linear", nil)
				end

				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.11667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -2, 0.03333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0.09999999999999999, 0.11667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0.09999999999999999, 0.11667, "Linear", nil)
			end

			v8[167] = function()
				tweenProperty(v7[5], "Density", 0.7999999999999999, 0.11667, "Linear", nil)
			end

			v8[168] = function()
				tweenProperty(v7[8], "Brightness", 0, 0.08333, "Linear", nil)
			end

			v8[169] = function()
				tweenProperty(v7[12], "Scale", createVector(8, 12, 8), 0.21667, "Linear", nil)
				tweenProperty(
					v7[13],
					"CFrame",
					CFrame.new(
						391.09246826171875,
						3.009312868118286,
						1273.80224609375,
						0.2394566535949707,
						0,
						0.9709070324897766,
						-0.9709070324897766,
						0,
						0.2394566535949707,
						0,
						-0.9999999403953552,
						0
					),
					0.21667,
					"Linear",
					nil
				)
				tweenProperty(v7[14], "Transparency", 1, 0.21667, "Linear", nil)
			end

			v8[170] = function()
				tweenProperty(v7[9], "Brightness", 25, 0.68333, "Quad", "In")
			end

			v8[171] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 52, 0.73333, "Sine", "InOut")
				end
			end

			v8[172] = function()
				task.spawn(function()
					for _, effect in vFXCMove.PunchInch:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[173] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 190, 151),
						player,
						"LeopardFruitVFXColor"
					),
					0.73333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -0.09999999999999999, 0.73333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.20000000298023224, 0.73333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.73333, "Linear", nil)
			end

			v8[174] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Eyes:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[5], "Offset", 0, 1.76667, "Linear", nil)
				tweenProperty(v7[5], "Haze", 10, 1.76667, "Linear", nil)
				tweenProperty(
					v7[5],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 0, 0), player, "LeopardFruitVFXColor"),
					1.76667,
					"Linear",
					nil
				)
				tweenProperty(
					v7[5],
					"Decay",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 59, 52), player, "LeopardFruitVFXColor"),
					1.76667,
					"Linear",
					nil
				)
				tweenProperty(v7[5], "Density", 1, 0.68333, "Sine", "In")
				tweenProperty(v7[5], "Glare", 0, 1.76667, "Linear", nil)
			end

			v8[182] = function() end

			v8[194] = function() end

			v8[210] = function()
				task.spawn(function()
					for _, effect in vFXCMove.FloorFire.Second:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[211] = function()
				task.spawn(function()
					for _, effect in vFXCMove.PunchInchHit:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(v7[9], "Brightness", 0, 0.13333, "Linear", nil)
			end

			v8[215] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 100, 0.08333, "Back", "Out", 1.70158)
				end

				tweenProperty(v7[5], "Density", 0.5799999833106995, 1.08333, "Linear", nil)
			end

			v8[216] = function()
				tweenProperty(v7[10], "Size", 12, 0.01667, "Linear", nil)
			end

			v8[217] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 190, 151),
						player,
						"LeopardFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 2, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.01667, "Linear", nil)
				tweenProperty(v7[10], "Size", 0, 0.6, "Bounce", "In")
				tweenProperty(v7[16], "Scale", createVector(12.015, 35.996, 12.015), 0.4, "Linear", nil)
				local v13 = primaryPart.CFrame * CFrame.new(0, 0, 0)
				tweenProperty(v7[18], "CFrame", v13, 0.4, "Linear", nil)
			end

			v8[218] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.05,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -50, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 75, 0.05, "Linear", nil)
				tweenProperty(v7[17], "Transparency", 1, 0.4, "Linear", nil)
			end

			v8[219] = function() end

			v8[220] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 55, 0.91667, "Sine", "Out")
				end
			end

			v8[221] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.05,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 3, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 75, 0.05, "Linear", nil)
			end

			v8[222] = function()
				task.spawn(function()
					for _, effect in vFXCMove.LoadPunch:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
			end

			v8[224] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.05,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.30000001192092896, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0.4000000059604645, 0.05, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0.4000000059604645, 0.05, "Linear", nil)
			end

			v8[227] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 196, 157),
						player,
						"LeopardFruitVFXColor"
					),
					0.88333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0, 0.88333, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -0.4000000059604645, 0.88333, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0.5, 0.88333, "Linear", nil)
			end

			v8[233] = function()
				tweenProperty(v7[15], "Brightness", 14, 0.68333, "Linear", nil)
			end

			v8[241] = function() end

			v8[242] = function() end

			v8[253] = function()
				tweenProperty(v7[10], "Size", 0, 0.38333, "Linear", nil)
			end

			v8[274] = function() end

			v8[275] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 100, 0.08333, "Sine", "In")
				end
			end

			v8[276] = function()
				tweenProperty(v7[10], "Size", 25, 0.06667, "Linear", nil)
			end

			v8[280] = function()
				if v4 then
					tweenProperty(v7[4], "FieldOfView", 70, 0.61667, "Quad", "Out")
				end

				tweenProperty(v7[5], "Offset", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Haze", 10, 0.01667, "Linear", nil)
				tweenProperty(
					v7[5],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(
					v7[5],
					"Decay",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[5], "Density", 0, 0.01667, "Linear", nil)
				tweenProperty(v7[5], "Glare", 0, 0.01667, "Linear", nil)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(Color3.fromRGB(255, 78, 62), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", -2, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", -1, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 10, 0.01667, "Linear", nil)
				tweenProperty(v7[10], "Size", 0, 0.05, "Linear", nil)
			end

			v8[281] = function()
				task.spawn(function()
					for _, effect in vFXCMove.Explosion:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							Emit(effect)
						end
					end
				end)
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(Color3.fromRGB(255, 105, 35), player, "LeopardFruitVFXColor"),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0.39999999999999997, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0.5, 0.01667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 1, 0.01667, "Linear", nil)
			end

			v8[282] = function()
				tweenProperty(
					v7[8],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LeopardFruitVFXColor"
					),
					0.13333,
					"Linear",
					nil
				)
				tweenProperty(v7[8], "Brightness", 0, 0.76667, "Linear", nil)
				tweenProperty(v7[8], "Saturation", 0, 0.76667, "Linear", nil)
				tweenProperty(v7[8], "Contrast", 0, 0.76667, "Linear", nil)
				tweenProperty(
					v7[19],
					"CFrame",
					CFrame.new(
						390.2669982910156,
						2.6968512535095215,
						1276.276123046875,
						0.4063262343406677,
						0,
						0.9137281775474548,
						-0.9137281775474548,
						0,
						0.4063262343406677,
						0,
						-1,
						0
					),
					0.16667,
					"Linear",
					nil
				)
				tweenProperty(v7[20], "Scale", createVector(45, 125, 45), 0.16667, "Linear", nil)
				tweenProperty(v7[21], "Transparency", 0, 0.05, "Linear", nil)
				tweenProperty(
					v7[22],
					"CFrame",
					CFrame.new(
						390.9695739746094,
						3.9866294860839844,
						1280.341064453125,
						-0.7053799033164978,
						0,
						-0.7088294625282288,
						0.7088294625282288,
						0,
						-0.7053799033164978,
						0,
						-1,
						0
					),
					0.01667,
					"Linear",
					nil
				)
				tweenProperty(v7[23], "Scale", createVector(5.0153694, 5.6477656, 5.0153694), 0.01667, "Linear", nil)
				tweenProperty(v7[24], "Transparency", 0, 0.01667, "Linear", nil)
			end

			v8[283] = function()
				tweenProperty(
					v7[22],
					"CFrame",
					CFrame.new(
						390.9695739746094,
						3.9866294860839844,
						1280.341064453125,
						-0.7053799033164978,
						0,
						-0.7088294625282288,
						0.7088294625282288,
						0,
						-0.7053799033164978,
						0,
						-1,
						0
					),
					0.03333,
					"Linear",
					nil
				)
				tweenProperty(v7[23], "Scale", createVector(5.0153694, 5.6477656, 5.0153694), 0.03333, "Linear", nil)
				tweenProperty(v7[24], "Transparency", 0, 0.03333, "Linear", nil)
				tweenProperty(
					v7[25],
					"CFrame",
					CFrame.new(
						390.0528869628906,
						12.757080078125,
						1327.7784423828125,
						-0.3071908950805664,
						0,
						-0.951647937297821,
						0.951647937297821,
						0,
						-0.3071908950805664,
						0,
						-1,
						0
					),
					0.08333,
					"Linear",
					nil
				)
				tweenProperty(v7[26], "Scale", createVector(15, 75, 15), 0.1, "Linear", nil)
				tweenProperty(v7[27], "Transparency", 0, 0.01667, "Linear", nil)
			end

			v8[284] = function()
				tweenProperty(v7[27], "Transparency", 1, 0.08333, "Linear", nil)
			end

			v8[285] = function()
				tweenProperty(v7[21], "Transparency", 1, 0.11667, "Linear", nil)
				tweenProperty(
					v7[22],
					"CFrame",
					CFrame.new(
						390.9695739746094,
						3.9866294860839844,
						1317.4921875,
						0.9274707436561584,
						0,
						0.37389567494392395,
						-0.37389567494392395,
						0,
						0.9274707436561584,
						0,
						-1,
						0
					),
					0.81667,
					"Cubic",
					"Out"
				)
				tweenProperty(v7[23], "Scale", createVector(56, 86, 56), 0.81667, "Cubic", "Out")
				tweenProperty(v7[24], "Transparency", 1, 0.81667, "Cubic", "Out")
			end

			v8[288] = function() end

			v8[289] = function() end

			v8[290] = function() end

			v8[292] = function() end

			v8[317] = function() end

			v8[328] = function() end

			v8[334] = function() end

			local total = 0
			local v13 = -1

			while not v2 do
				local v14 = total * 60 // 1
				local v15 = v14 - v13

				if v15 > 0 then
					for i = v13 + 1, v13 + v15 do
						local v16 = v8[i]

						if v16 then
							pcall(v16)
						end
					end

					v13 = v14
				end

				total += RunService.RenderStepped:Wait() * 1

				if v14 > 340 then
					break
				end
			end
		end)
		Util.Anims:Get(data.Rig, "TigerUltimate"):Play()
		Util.Anims:Get(clone.CamReAdd, "TigerUltimate_Camera"):Play()
		Util.Anims:Get(enemyRoot.Parent, "TigerUltimate_Victim"):Play()
		local lastTime = tick()
		local currentCamera = workspace.CurrentCamera

		if v4 then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
			if tick() - lastTime > 4.683333333333334 then
				v5 = true
				renderSteppedConnection:Disconnect()

				if characterRemovingConnection then
					characterRemovingConnection:Disconnect()
				end

				if enemyRoot then
					enemyRoot.Anchored = false
				end

				if root2 then
					root2.Anchored = false
				end

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
	elseif stage == 4 then
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 8)
		local origin2 = data.Origin
		local ray = Util.Ray
		local v = origin2 + createVector(0, 2, 0)
		local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v3, v4, v5 = ray(v, createVector(-0, -10, -0), v2, false)

		if v3 ~= nil then
			local cframe = CFrame.new(v4)
			local clone = tigerEffects.X_Awak.XFloor:Clone()
			clone.CFrame = cframe
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 4.5)
		end

		local cframe = CFrame.new(origin2)
		Util.Sound:Play("BF_TigerFt_AWK_X_Explode_01", cframe.Position)
		local clone = tigerEffects.X_Awak.Explode:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 2)
		task.spawn(function()
			local part = Instance.new("Part")
			part.Name = "BAMPROCK"
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
			part.Anchored = true
			RockRipple.createRippleEffect(part, v4, 12, 5, 4, 3)
		end)
		local v6 = CFrame.new(v4, v4 + v5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local random = Random.new()

		for i = 1, 45 do
			local v7 = 6.283185307179586 * (i / 45)
			local v8 = Rock2.new({
				Type = "Ground",
				FadeOut = { 0.25, 0.5 },
				FadeIn = { 0.25, 0.5 },
				Lifetime = { 1, 2.5 },
				Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
				Scale = { 3.75, 7.5 }
			})

			if random:NextInteger(1, 20) % 4 == 0 then
				local unit = Vector3.new(
					math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
					random:NextNumber(0, 1) * 1.25,
					math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
				).Unit
				v8.Type = "Flying"
				v8:Spawn(v6 * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -34.199999999999996))
				v8:Eject({
					Velocity = Util.Misc.Physics.Velocity(
						Vector3.new(),
						unit * random:NextNumber(30, 120),
						Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
						0.25 + random:NextNumber(0, 2)
					),
					AngularVelocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					) * 2 * 3.141592653589793 * (1 / v8.Scale)
				})
			else
				v8:Spawn(v6 * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -34.199999999999996))
				v8:TweenShift((v6 * CFrame.Angles(0, v7, 0)).LookVector * 15 * random:NextNumber(1, 2), 0.25)
			end
		end
	end
end