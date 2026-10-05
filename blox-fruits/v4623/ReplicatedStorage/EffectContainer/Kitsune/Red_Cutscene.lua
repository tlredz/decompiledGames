local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cutscene = FX:WaitForChild("RedKitsune"):WaitForChild("Cutscene")
local red_Cutscene = FX:WaitForChild("Kitsune"):WaitForChild("Red_Cutscene")
local _ = workspace._WorldOrigin
game:GetService("Lighting")
game:GetService("HttpService")
local _ = {
	"Ambient",
	"Brightness",
	"ColorShift_Bottom",
	"ColorShift_Top",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"ExposureCompensation",
	"GeographicLatitude",
	"OutdoorAmbient"
}

function Emit(beam)
	if beam:IsA("Beam") then
		local emitDelay = beam:GetAttribute("EmitDelay")
		local emitDuration = beam:GetAttribute("EmitDuration")
		task.delay(tonumber(emitDelay) or 0, function()
			if tonumber(emitDuration) and emitDuration ~= 0 then
				beam.Enabled = true

				if not beam:GetAttribute("pr3") then
					beam:SetAttribute("pr3", 0)
				end

				local v = (beam:GetAttribute("pr3") + 1) % 1000
				beam:SetAttribute("pr3", v)
				task.wait(emitDuration)

				if v == beam:GetAttribute("pr3") then
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

				local v = (beam:GetAttribute("pr3") + 1) % 1000
				beam:SetAttribute("pr3", v)
				task.wait(emitDuration)

				if v == beam:GetAttribute("pr3") then
					beam.Enabled = false
				end
			end
		end)
	end
end

return function(player)
	local folder = Instance.new("Folder")
	folder.Name = "FakePlayerForRecolor_" .. script.Name
	folder.Parent = workspace.CurrentCamera
	Util.DestroyAfter(folder, 10)

	if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == true then
		local clone = red_Cutscene.VFXColor:Clone()
		clone.Name = "KitsuneFruitVFXColor"
		clone.Parent = folder
	else
		local clone = red_Cutscene.VFXColorRed:Clone()
		clone.Name = "KitsuneFruitVFXColor"
		clone.Parent = folder
	end

	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder_2 = Instance.new("Folder", player.Player)
		folder_2.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1400 then
		return
	end

	local stage = player.Stage

	if stage == "POUNCE" then
		local Players = game:GetService("Players")
		local RunService2 = game:GetService("RunService")

		if player.player ~= Players.LocalPlayer then
			return
		end

		local root = player.Root or player.hrp

		if not root then
			return
		end

		local _ = player.origin
		local fireDir = player.fireDir
		local forwardCylinderLength = player.forwardCylinderLength
		local endsAfter = player.endsAfter
		local pounceStartPos = player.pounceStartPos or player.origin
		local pounceEndPos = player.pounceEndPos or pounceStartPos + fireDir * forwardCylinderLength
		local clone = cutscene.StartImpact:Clone()
		clone.CFrame = CFrame.lookAt(pounceStartPos, pounceEndPos)
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, folder, "KitsuneFruitVFXColor")
		Util.Debris:AddItem(clone, 4)
		Util.Sound:Play("KitsuneMutationC Dash", root)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Emit(emitter)
			end
		end

		task.spawn(function()
			root.Anchored = true
			local cFrame = CFrame.new(pounceEndPos, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime = os.clock()

			while os.clock() - lastTime < endsAfter do
				local v2 = (os.clock() - lastTime) / endsAfter
				root.CFrame = cFrame * CFrame.new(0, 0, forwardCylinderLength * (1 - v2 ^ 0.5))
				RunService2.PreSimulation:Wait()
			end

			root.CFrame = cFrame
			root.Anchored = false
		end)
	else
		if stage == 1 then
			return
		end

		if stage == 2 then
			local model = nil
			local v = nil
			local success, result = pcall(function()
				local Players = game:GetService("Players")
				local localPlayer = Players.LocalPlayer
				local v2 = localPlayer == player.Player or false
				local clones = {}
				model = Instance.new("Model", workspace._WorldOrigin)
				Util.Debris:AddItem(model, 30)
				local root = player.Root
				local _ = player.Character
				local rig = player.Rig
				local enemyChar = player.EnemyChar
				local v3 = game.Players:GetPlayerFromCharacter(enemyChar) == game.Players.LocalPlayer or v2
				root.Anchored = true
				local v4 = false

				if v3 then
					_G.InCutscene = true
				end

				local clone = cutscene.UltimateModel:Clone()
				clone:PivotTo(player.dashEndCF * CFrame.new(0, -7.297, 0))
				local victimCF = clone.VictimCF
				local REDEXPLODE = clone.REDEXPLODE
				local camReAdd = clone.CamReAdd
				local clone2 = cutscene.WeldedVFX:Clone()

				for _, rigidConstraint in pairs(clone2:GetDescendants()) do
					if rigidConstraint:IsA("RigidConstraint") then
						rigidConstraint.Attachment1 = rig:FindFirstChild(
							rigidConstraint:GetAttribute("Attachment1"),
							true
						)
					end
				end

				Util.SetParentOverrideWithColor(clone2, model, folder, "KitsuneFruitVFXColor")
				table.insert(clones, clone2)

				for _, child in pairs(cutscene.RootVFX:GetChildren()) do
					local clone3 = child:Clone()
					Util.SetParentOverrideWithColor(clone3, rig.RootPart, folder, "KitsuneFruitVFXColor")

					if clone3:IsA("Weld") then
						clone3.Part0 = rig.RootPart
						clone3.Part1 = clone2.Sphere2.Sphere2
					end

					table.insert(clones, clone3)
				end

				local rootPart = rig.RootPart
				local sphere2 = rootPart:FindFirstChild("Sphere2")
				local part0 = sphere2.Part0
				local part1 = sphere2.Part1
				local objectSpace = part0.CFrame:ToObjectSpace(part1.CFrame)
				sphere2:Destroy()
				local heartbeatConnection = nil
				local sphere22 = clone2.Sphere2
				sphere22.PrimaryPart.Anchored = true
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					if not rootPart.Parent then
						heartbeatConnection:Disconnect()
						return
					end

					sphere22:PivotTo(rootPart.CFrame * objectSpace)
				end)
				local clone3 = cutscene.Lighting.RED_KITSUNE_ATMOSPHERE:Clone()
				local clone4 = cutscene.Lighting.RedKitsune:Clone()
				local clone5 = cutscene.Lighting.RedKitsuneBlur:Clone()
				Util.SetParentOverrideWithColor(clone, model, folder, "KitsuneFruitVFXColor")
				local v5

				if v3 then
					v5 = Util.Sound:Play("KitsuneMutation_Cutscene_01", game.Players.LocalPlayer.PlayerGui)
				else
					v5 = Util.Sound:Play("KitsuneMutation_Cutscene_01", rootPart)
				end

				task.spawn(function()
					local humanoid = enemyChar:FindFirstChild("Humanoid")
					local humanoidRootPart = enemyChar:FindFirstChild("HumanoidRootPart")
					local v6 = tick() + 2.7666666666666666

					while not (v6 < tick()) and root and root:IsDescendantOf(workspace) and humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace) and humanoid and humanoid:IsDescendantOf(workspace) and not (humanoid.Health <= 0 or v4) do
						root.CFrame = player.dashEndCF
						humanoidRootPart.CFrame = victimCF.CFrame
						task.wait()
					end

					humanoidRootPart.Anchored = false
				end)

				if v3 then
					Util.SetParentOverrideWithColor(clone3, game.Lighting, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone4, game.Lighting, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone5, game.Lighting, folder, "KitsuneFruitVFXColor")
				elseif (currentCamera.CFrame.Position - rig.RootPart.Position).Magnitude < 200 then
					Util.SetParentOverrideWithColor(clone3, game.Lighting, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone4, game.Lighting, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone5, game.Lighting, folder, "KitsuneFruitVFXColor")
				else
					Util.SetParentOverrideWithColor(clone3, model, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone4, model, folder, "KitsuneFruitVFXColor")
					Util.SetParentOverrideWithColor(clone5, model, folder, "KitsuneFruitVFXColor")
				end

				table.insert(clones, clone3)
				table.insert(clones, clone4)
				table.insert(clones, clone5)
				local renderSteppedConnection = nil
				local characterRemovingConnection = nil

				local function clear()
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end

					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end

					if characterRemovingConnection then
						characterRemovingConnection:Disconnect()
					end

					if v5 then
						Util.Sound:FadeOut(v5, 0.2)
					end

					if v3 then
						currentCamera.CameraType = Enum.CameraType.Custom
						currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
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
							_G.InCutscene = nil
						end)
						_G.updateMusic2(false)
					end

					v4 = true
					root.Anchored = false

					for _, v6 in pairs(clones) do
						if v6.Name == "RED_KITSUNE_ATMOSPHERE" then
							Util.Debris:AddItem(v6, 1)
						else
							v6:Destroy()
						end
					end

					task.delay(2, function()
						model:Destroy()
						model = nil
					end)
					clones = nil
				end

				v = clear
				task.spawn(function()
					local RunService2 = game:GetService("RunService")
					local tweenProperty = Util.xmc_Helper.TweenProperty
					local v6 = {
						[1] = rig,
						[2] = enemyChar,
						[4] = rootPart.fire.FlameThrowerLight,
						[5] = clone4,
						[6] = workspace.CurrentCamera,
						[7] = camReAdd,
						[8] = clone5,
						[9] = clone.PROJECTILE.Sphere2,
						[10] = clone3
					}
					local v7 = {}
					task.wait()
					v5.TimePosition = 1
					v5.Volume = 1
					v6[4].Color = Util.WrapColor3Constructor(
						Color3.fromRGB(255, 255, 255),
						folder,
						"KitsuneFruitVFXColor"
					)
					v6[4].Brightness = 0
					v6[4].Range = 42
					v6[4].Angle = 90
					v6[5].TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						folder,
						"KitsuneFruitVFXColor"
					)
					v6[5].Brightness = 0
					v6[5].Saturation = 0
					v6[5].Contrast = 0

					if v3 then
						v6[6].FieldOfView = 70
					end

					v6[8].Size = 0
					v6[9].CFrame = root.CFrame * CFrame.new(0, 10000, 0)
					v6[10].Offset = 0.5860000252723694
					v6[10].Haze = 7
					v6[10].Color = Util.WrapColor3Constructor(
						Color3.fromRGB(147, 32, 32),
						folder,
						"KitsuneFruitVFXColor"
					)
					v6[10].Decay = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), folder, "KitsuneFruitVFXColor")
					v6[10].Density = 0
					v6[10].Glare = 0

					v7[0] = function()
						tweenProperty(
							v6[4],
							"Color",
							Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), folder, "KitsuneFruitVFXColor"),
							1.55,
							"Linear",
							nil
						)
						tweenProperty(v6[4], "Brightness", 0, 1.55, "Linear", nil)
						tweenProperty(v6[4], "Range", 42, 1.55, "Linear", nil)

						if v3 then
							tweenProperty(v6[6], "FieldOfView", 96.67877960205078, 0.66667, "Back", "In", 1.70158)
						end

						task.spawn(function()
							for _, effect in clone2.SphereHold:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						tweenProperty(v6[8], "Size", 24, 0.01667, "Linear", nil)
					end

					v7[1] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 0, 0),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.01667,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", -0.30000001192092896, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 1, 0.01667, "Bounce", "In")
						task.spawn(function()
							for _, effect in rootPart.Spins:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						tweenProperty(v6[8], "Size", 0, 0.11667, "Linear", nil)
					end

					v7[2] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.18333,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", 0, 0.18333, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", 0, 0.18333, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 0, 0.18333, "Bounce", "In")
						tweenProperty(v6[10], "Offset", 0, 1.98333, "Linear", nil)
						tweenProperty(v6[10], "Glare", 0, 1.98333, "Linear", nil)
						tweenProperty(
							v6[10],
							"Color",
							Util.WrapColor3Constructor(Color3.fromRGB(147, 32, 32), folder, "KitsuneFruitVFXColor"),
							1.98333,
							"Linear",
							nil
						)
						tweenProperty(
							v6[10],
							"Decay",
							Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), folder, "KitsuneFruitVFXColor"),
							1.98333,
							"Linear",
							nil
						)
						tweenProperty(v6[10], "Density", 0.6549999713897705, 1.98333, "Linear", nil)
						tweenProperty(v6[10], "Haze", 7, 1.98333, "Linear", nil)
					end

					v7[8] = function()
						tweenProperty(v6[8], "Size", 0, 0.16667, "Linear", nil)
					end

					v7[13] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 208, 208),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.38333,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", 0, 0.38333, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -0.23000000417232513, 0.38333, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 0.5, 0.38333, "Bounce", "In")
					end

					v7[18] = function()
						tweenProperty(v6[8], "Size", 12, 0.13333, "Linear", nil)
					end

					v7[26] = function()
						tweenProperty(v6[8], "Size", 0, 0.16667, "Linear", nil)
					end

					v7[36] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 164, 164),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.01667,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", -2, 0.01667, "Linear", nil)
						tweenProperty(v6[5], "Saturation", -1, 0.01667, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 6, 0.01667, "Linear", nil)
						tweenProperty(v6[8], "Size", 0, 0.01667, "Linear", nil)
					end

					v7[37] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 0, 0),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.03333,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", -0.30000001192092896, 0.03333, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.03333, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 1, 0.03333, "Bounce", "In")
						tweenProperty(v6[8], "Size", 8, 0.01667, "Linear", nil)
					end

					v7[38] = function()
						tweenProperty(v6[8], "Size", 0, 0.73333, "Linear", nil)
					end

					v7[39] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 35, 35),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.01667,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", -1, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -1, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", -10, 0.01667, "Bounce", "In")
						task.spawn(function()
							for _, effect in clone2.Sphere2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							local sphere23 = clone2.Sphere2
							local TweenService2 = game:GetService("TweenService")
							local numberValue = Instance.new("NumberValue")
							numberValue.Value = sphere23:GetScale()
							local tween = TweenService2:Create(
								numberValue,
								TweenInfo.new(1.15, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									Value = 4
								}
							)
							tween.Completed:Connect(function()
								numberValue:Destroy()
							end)
							tween:Play()
							numberValue:GetPropertyChangedSignal("Value"):Connect(function()
								sphere23:ScaleTo(numberValue.Value)
							end)
							task.wait(1.15)
							local numberValue2 = Instance.new("NumberValue")
							numberValue2.Value = sphere23:GetScale()
							local tween2 = TweenService2:Create(
								numberValue2,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									Value = 0.3
								}
							)
							tween2.Completed:Connect(function()
								numberValue2:Destroy()
							end)
							tween2:Play()
							numberValue2:GetPropertyChangedSignal("Value"):Connect(function()
								sphere23:ScaleTo(numberValue2.Value)
							end)
							v6[9]:PivotTo(rootPart.CFrame * objectSpace)
							task.wait(1.15)
							sphere23:ScaleTo(1)
							TweenService2:Create(clone3, TweenInfo.new(1), {
								Haze = 0
							}):Play()

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
							end
						end)
					end

					v7[40] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.05,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", 0, 0.05, "Linear", nil)
						tweenProperty(v6[5], "Saturation", 0, 0.05, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 0, 0.05, "Linear", nil)

						if v3 then
							tweenProperty(v6[6], "FieldOfView", 95, 0.05, "Linear", nil)
						end
					end

					v7[43] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.75,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", 0, 0.75, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", 0, 0.75, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 0, 0.75, "Bounce", "In")

						if v3 then
							tweenProperty(v6[6], "FieldOfView", 45, 0.1, "Linear", nil)
						end
					end

					v7[49] = function()
						if v3 then
							tweenProperty(v6[6], "FieldOfView", 33, 0.41667, "Bounce", "In")
						end
					end

					v7[74] = function()
						if v3 then
							tweenProperty(v6[6], "FieldOfView", 78, 0.68333, "Back", "In", 1.70158)
						end
					end

					v7[82] = function()
						tweenProperty(v6[8], "Size", 0, 0.7, "Linear", nil)
					end

					v7[88] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 139, 139),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.45,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", -0.20000000298023224, 0.45, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.45, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", 1, 0.45, "Bounce", "In")
					end

					v7[89] = function()
						task.spawn(function()
							for _, effect in rootPart.fire:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v7[93] = function()
						tweenProperty(
							v6[4],
							"Color",
							Util.WrapColor3Constructor(Color3.fromRGB(255, 77, 77), folder, "KitsuneFruitVFXColor"),
							0.21667,
							"Linear",
							nil
						)
						tweenProperty(v6[4], "Brightness", 15, 0.21667, "Linear", nil)
						tweenProperty(v6[4], "Range", 42, 0.21667, "Linear", nil)
						tweenProperty(v6[4], "Angle", 140, 0.21667, "Linear", nil)
					end

					v7[106] = function()
						tweenProperty(v6[4], "Brightness", 11.0600004196167, 0.26667, "Linear", nil)
						tweenProperty(v6[4], "Angle", 90, 0.06667, "Linear", nil)
					end

					v7[108] = function() end

					v7[110] = function()
						tweenProperty(v6[4], "Angle", 140, 0.06667, "Linear", nil)
					end

					v7[114] = function() end

					v7[115] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 139, 139),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.03333,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", -0.20000000298023224, 0.03333, "Linear", nil)
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.03333, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 1, 0.03333, "Linear", nil)
					end

					v7[117] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 0, 0),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.11667,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", -0.30000001192092896, 0.11667, "Linear", nil)
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.11667, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 1, 0.11667, "Linear", nil)
					end

					v7[121] = function()
						tweenProperty(v6[10], "Offset", 0, 0.18333, "Linear", nil)
						tweenProperty(v6[10], "Glare", 0, 0.18333, "Linear", nil)
						tweenProperty(
							v6[10],
							"Color",
							Util.WrapColor3Constructor(Color3.fromRGB(147, 32, 32), folder, "KitsuneFruitVFXColor"),
							0.18333,
							"Linear",
							nil
						)
						tweenProperty(
							v6[10],
							"Decay",
							Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), folder, "KitsuneFruitVFXColor"),
							0.18333,
							"Linear",
							nil
						)
						tweenProperty(v6[10], "Density", 0.28700000047683716, 0.18333, "Linear", nil)
						tweenProperty(v6[10], "Haze", 7, 0.18333, "Linear", nil)
					end

					v7[122] = function()
						tweenProperty(v6[4], "Brightness", 0, 0.11667, "Linear", nil)
					end

					v7[124] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 35, 35),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.01667,
							"Bounce",
							"In"
						)
						tweenProperty(v6[5], "Brightness", -1, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Saturation", -1, 0.01667, "Bounce", "In")
						tweenProperty(v6[5], "Contrast", -10, 0.01667, "Bounce", "In")
						tweenProperty(v6[8], "Size", 16, 0.01667, "Linear", nil)
					end

					v7[125] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 139, 139),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.05,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", -0.20000000298023224, 0.05, "Linear", nil)
						tweenProperty(v6[5], "Saturation", -0.699999988079071, 0.05, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 1, 0.05, "Linear", nil)
						tweenProperty(v6[8], "Size", 0, 0.26667, "Linear", nil)
					end

					v7[127] = function() end

					v7[128] = function()
						tweenProperty(
							v6[5],
							"TintColor",
							Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								folder,
								"KitsuneFruitVFXColor"
							),
							0.36667,
							"Linear",
							nil
						)
						tweenProperty(v6[5], "Brightness", 1, 0.05, "Linear", nil)
						tweenProperty(v6[5], "Saturation", 0, 0.36667, "Linear", nil)
						tweenProperty(v6[5], "Contrast", 0, 0.36667, "Linear", nil)
					end

					v7[129] = function() end

					v7[130] = function()
						task.spawn(function()
							for _, effect in rootPart.shoot:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					local renderSteppedConnection2 = nil
					local v8 = nil
					local position2 = createVector(0, 0, 0)

					v7[131] = function()
						tweenProperty(v6[5], "Brightness", 0, 0.31667, "Linear", nil)
						local folder2 = v6[9]

						if not folder2 then
							return
						end

						Util.Sound:Play("KitsuneMutation_Explosion_01", position2)

						for _, part in ipairs(folder2:GetDescendants()) do
							if not part:IsA("BasePart") then
								continue
							end

							part.Anchored = true
							part.CanCollide = false
							part.CanTouch = false
							part.CanQuery = false
						end

						local _ = root.Position + createVector(0, 5, 0)
						local _ = root.CFrame.LookVector
						local projectileEndPos = player.ProjectileEndPos
						position2 = projectileEndPos
						folder2:PivotTo(rootPart.CFrame * objectSpace)
						local pivot = folder2:GetPivot()
						local position = pivot.Position
						local v10 = projectileEndPos - position
						local lastTime = os.clock()
						local v11 = pivot - position

						if renderSteppedConnection2 then
							renderSteppedConnection2:Disconnect()
						end

						v8 = folder2
						renderSteppedConnection2 = RunService2.RenderStepped:Connect(function()
							if folder2.Parent then
								local v12 = math.clamp((os.clock() - lastTime) / 0.5666666666666667, 0, 1)
								local v13 = position + v10 * v12
								folder2:PivotTo(v11 + v13)

								if enemyChar and enemyChar.Parent then
									enemyChar:PivotTo(CFrame.new(v13) * enemyChar:GetPivot().Rotation)
								end

								if v12 >= 1 then
									folder2:PivotTo(v11 + projectileEndPos)
									renderSteppedConnection2:Disconnect()
									renderSteppedConnection2 = nil
								end
							else
								renderSteppedConnection2:Disconnect()
								renderSteppedConnection2 = nil
							end
						end)
					end

					v7[132] = function()
						task.spawn(function()
							for _, effect in rootPart.fire2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v7[141] = function() end

					v7[150] = function() end

					v7[165] = function()
						task.spawn(function()
							local folder2 = REDEXPLODE
							REDEXPLODE.Position = position2

							if renderSteppedConnection2 then
								renderSteppedConnection2:Disconnect()
								renderSteppedConnection2 = nil
							end

							if v8 and v8.Parent then
								v8:Destroy()
							end

							v8 = nil

							for _, effect in folder2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v7[166] = function() end

					local total = 0
					local v10 = -1

					while not v4 do
						local v11 = total * 60 // 1
						local v12 = v11 - v10

						if v12 > 0 then
							for i = v10 + 1, v10 + v12 do
								local v13 = v7[i]

								if not v13 then
									continue
								end

								local success2, result2 = pcall(v13)

								if not success2 then
									task.spawn(error, result2)
								end
							end

							v10 = v11
						end

						total += RunService2.RenderStepped:Wait() * 1

						if v11 > 190 then
							break
						end
					end

					v()
				end)
				Util.Anims:Get(rig, "RedKitCutscene_Rig"):Play()
				Util.Anims:Get(camReAdd, "RedKitCutscene_Camera"):Play()
				local redKitCutsceneVictim = Util.Anims:Get(enemyChar, "RedKitCutscene_Victim")
				redKitCutsceneVictim.Priority = Enum.AnimationPriority.Action4
				redKitCutsceneVictim:Play()
				local lastTime = tick()
				local currentCamera2 = workspace.CurrentCamera

				if v3 then
					currentCamera2.CameraType = Enum.CameraType.Scriptable
				end

				characterRemovingConnection = localPlayer.CharacterRemoving:Once(function()
					v()
				end)
				renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
					if v3 then
						if camReAdd.Parent == nil or tick() - lastTime > 2.7666666666666666 then
							renderSteppedConnection:Disconnect()
							currentCamera2.CameraType = Enum.CameraType.Custom
							currentCamera2.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
						else
							currentCamera2.CFrame = camReAdd.Cam.CFrame
						end
					end
				end)
			end)

			if not success then
				warn("wow nice it broke", result)

				if model then
					model:Destroy()
				end

				if v then
					task.spawn(v)
				end
			end
		end
	end
end