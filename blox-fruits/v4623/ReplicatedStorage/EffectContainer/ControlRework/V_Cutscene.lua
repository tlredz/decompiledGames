local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local FX = require(ReplicatedStorage:WaitForChild("FX"))
local vUltimateCutscene = FX:WaitForChild("ControlRework").VUltimateCutscene
local VisualHelper = require(script.Parent.Shared.Utility.VisualHelper)
local _ = workspace._WorldOrigin
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local v = {
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

local function decodeValue(data)
	if typeof(data) ~= "table" or not data.__t then
		return data
	end

	if data.__t == "Color3" then
		return Color3.new(data.r, data.g, data.b)
	end

	if data.__t == "Vector3" then
		return (Vector3.new(data.x, data.y, data.z))
	end

	return data
end

local function ApplyLightingFromJSON(json)
	local v2 = {}

	for _, v3 in ipairs(v) do
		v2[v3] = Lighting[v3]
	end

	local jSONDecode = HttpService:JSONDecode(json)

	for k, v3 in pairs(jSONDecode) do
		local v4 = k
		local v5 = v3
		pcall(function()
			local v6 = Lighting
			local color = v5

			if typeof(color) == "table" and color.__t then
				if color.__t == "Color3" then
					color = Color3.new(color.r, color.g, color.b)
				elseif color.__t == "Vector3" then
					color = Vector3.new(color.x, color.y, color.z)
				end
			end

			v6[v4] = color
		end)
	end

	local function revert()
		for k, v3 in pairs(v2) do
			local v4 = k
			local v5 = v3
			pcall(function()
				Lighting[v4] = v5
			end)
		end
	end

	return revert
end

local v2 = {
	{ "CamReAdd", "Cam", "Glitchsave" },
	{ "CamReAdd", "AnimationController", "Glitchsave" },
	{ "CamReAdd", "Cam", "Cam 🡪 Part1" },
	{
		"CamReAdd",
		"Cam",
		"BAMP",
		"GlitchBreakDomain"
	}
}

local function findByPath(child, items)
	for _, childName in items do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function foldDuplicateEmitters(glitch, p: string)
	if not glitch then
		return nil
	end

	local v3 = nil

	for _, emitter in glitch:GetChildren() do
		if not (emitter.Name == p and emitter:IsA("ParticleEmitter")) then
			continue
		end

		if v3 then
			emitter:Destroy()
		else
			v3 = emitter
		end
	end

	return v3
end

local function thinCutsceneFill(p)
	local child = p

	for _, childName in { "ControlRig", "SETCFRAMES", "DOMAINAURA" } do
		if child then
			child = child:FindFirstChild(childName)
		else
			child = nil
			break
		end
	end

	if child then
		local emitter = child

		for _, childName in { "BG", "SmokeStay" } do
			if emitter then
				emitter = emitter:FindFirstChild(childName)
			else
				emitter = nil
				break
			end
		end

		if emitter and emitter:IsA("ParticleEmitter") then
			emitter.Rate = 100
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.13, 0.03),
				NumberSequenceKeypoint.new(0.71, 0.03),
				NumberSequenceKeypoint.new(0.88, 0.4),
				NumberSequenceKeypoint.new(1, 1)
			})
		end

		local child2 = child

		for _, childName in { "BG", "SmokeStayB" } do
			if child2 then
				child2 = child2:FindFirstChild(childName)
			else
				child2 = nil
				break
			end
		end

		if child2 then
			child2:SetAttribute("EmitCount", 20)
		end

		local star = child:FindFirstChild("Star")

		if star and star:IsA("ParticleEmitter") then
			star.Rate = 50
			star.Brightness *= 3
		end

		local v6 = foldDuplicateEmitters(child:FindFirstChild("Glitch"), "PushSmokeFast")

		if v6 then
			v6:SetAttribute("EmitCount", 60)
		end
	end

	local child2 = p

	for _, childName in {
		"ControlRig",
		"SETCFRAMES",
		"CubeBreak",
		"bre"
	} do
		if child2 then
			child2 = child2:FindFirstChild(childName)
		else
			child2 = nil
			break
		end
	end

	if child2 then
		local ARGGHGHG = child2:FindFirstChild("ARGGHGHG")

		if ARGGHGHG then
			local v5 = nil

			for _, emitter in ARGGHGHG:GetDescendants() do
				if not (emitter.Name == "Flash" and emitter:IsA("ParticleEmitter")) then
					continue
				end

				if v5 then
					emitter:Destroy()
				else
					v5 = emitter
				end
			end
		end

		for _, childName in { "second", "Flash2" } do
			if child2 then
				child2 = child2:FindFirstChild(childName)
			else
				child2 = nil
				break
			end
		end

		if child2 then
			child2:SetAttribute("EmitCount", 10)
		end
	end

	local folder = p

	for _, childName in {
		"CamReAdd",
		"Cam",
		"BAMP",
		"Glitch"
	} do
		if folder then
			folder = folder:FindFirstChild(childName)
		else
			folder = nil
			break
		end
	end

	if folder then
		for _, emitter in folder:GetDescendants() do
			if emitter.Name == "Cube" and emitter:IsA("ParticleEmitter") then
				emitter.Rate /= 2
			end
		end
	end

	for _, v6 in v2 do
		local folder2 = p

		for _, childName in v6 do
			if folder2 then
				folder2 = folder2:FindFirstChild(childName)
			else
				folder2 = nil
				break
			end
		end

		if not folder2 then
			continue
		end

		for _, emitter in folder2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Destroy()
			end
		end
	end
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1400 then
		return
	end

	local stage = player.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local model = nil
		local v3 = nil
		local success, result = pcall(function()
			local Players = game:GetService("Players")
			local localPlayer = Players.LocalPlayer
			local v4 = localPlayer == player.Player
			local caughtPlayers = player.CaughtPlayers
			local v5 = v4 and true or false

			for _, caughtPlayer in pairs(caughtPlayers) do
				if caughtPlayer ~= localPlayer then
					continue
				end

				v5 = true
				break
			end

			model = Instance.new("Model", workspace._WorldOrigin)
			Util.Debris:AddItem(model, 30)
			local child = workspace._WorldOrigin:FindFirstChild("ControlVIndicators" .. VisualHelper:OwnerName(player.Player))

			if child then
				child.Name = "Destroying"
			end

			local root = player.Root
			local character = player.Character
			local v7 = false

			if v5 then
				local hipHeight = character.Humanoid.HipHeight
				character.Humanoid.HipHeight = 2
				_G.InCutscene = true
				character:SetAttribute("InControlCutscene", true)
				root.Anchored = true
				local applyLightingFromJSON = ApplyLightingFromJSON("{\"ExposureCompensation\":0,\"ColorShift_Bottom\":{\"__t\":\"Color3\",\"b\":0,\"g\":0,\"r\":0},\"EnvironmentDiffuseScale\":0.30000001192092898,\"EnvironmentSpecularScale\":0.30000001192092898,\"GeographicLatitude\":0,\"Ambient\":{\"__t\":\"Color3\",\"b\":0.6666666865348816,\"g\":0.6666666865348816,\"r\":0.6666666865348816},\"OutdoorAmbient\":{\"__t\":\"Color3\",\"b\":0.49803921580314639,\"g\":0.49803921580314639,\"r\":0.49803921580314639},\"Brightness\":2,\"ColorShift_Top\":{\"__t\":\"Color3\",\"b\":0,\"g\":0,\"r\":0}}")
				local clockTime = Lighting.ClockTime
				task.spawn(function()
					local v9 = task.wait(1)
					TweenService:Create(Lighting, TweenInfo.new(1), {
						ClockTime = 0
					}):Play()
					local v10 = v9 + task.wait(1)
					local v11 = tick() + 15.133333333333333 - (v10 + 1.5)

					while tick() < v11 and not v7 do
						Lighting.ClockTime = 0
						task.wait()
					end

					TweenService:Create(Lighting, TweenInfo.new(1.5), {
						ClockTime = clockTime
					}):Play()
				end)
				root.CFrame = CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector * createVector(1, 0, 1)) + root.Position
				local cFrame = root.CFrame
				local clone = vUltimateCutscene.UltimateModel:Clone()
				clone:PivotTo(root.CFrame)
				pcall(thinCutsceneFill, clone)
				local upperTorso = character.UpperTorso
				local v9 = {}
				local clone2 = vUltimateCutscene.DaggerAttach.DaggerL:Clone()
				local clone3 = vUltimateCutscene.DaggerAttach.DaggerR:Clone()
				local leftDaggerWeld = clone2.LeftDaggerWeld
				local rightDaggerWeld = clone3.RightDaggerWeld
				leftDaggerWeld.Part0 = character.LeftHand
				rightDaggerWeld.Part0 = character.RightHand
				Util.SetParentOverrideWithColor(clone2, character, player.Player, "ControlFruitVFXColor")
				Util.SetParentOverrideWithColor(clone3, character, player.Player, "ControlFruitVFXColor")
				table.insert(v9, clone2)
				table.insert(v9, clone3)
				table.insert(v9, leftDaggerWeld)
				table.insert(v9, rightDaggerWeld)
				local cubes = clone.Cubes
				local camReAdd = clone.CamReAdd
				local controlRig = clone.ControlRig
				local _ = controlRig.CUTSCENEVFX
				local SETCFRAMES = controlRig.SETCFRAMES
				SETCFRAMES.CubeBreak.CFrame = root.CFrame * CFrame.new(0, 10169.997, 0)
				SETCFRAMES.DOMAINAURA.CFrame = root.CFrame * CFrame.new(0, 10000, 0)
				SETCFRAMES.Main.CFrame = root.CFrame * CFrame.new(0, -3.645, 0)
				clone.CamReAdd.H.CFrame *= CFrame.new(0, 3.182, 0)

				for _, child2 in pairs(controlRig.CUTSCENEVFX:GetChildren()) do
					child2.CFrame = upperTorso.CFrame
				end

				for _, child2 in pairs(vUltimateCutscene.CharStuff.UpperTorso:GetChildren()) do
					local clone4 = child2:Clone()
					Util.SetParentOverrideWithColor(
						clone4,
						root.Parent.UpperTorso,
						player.Player,
						"ControlFruitVFXColor"
					)
					table.insert(v9, clone4)

					if not clone4:IsA("Weld") then
						continue
					end

					clone4.Part0 = root.Parent.UpperTorso
					clone4.Part1 = controlRig.CUTSCENEVFX:FindFirstChild(clone4.Name)
				end

				local clone4 = vUltimateCutscene.CharStuff.LowerTorso.SPIN:Clone()
				Util.SetParentOverrideWithColor(clone4, character.LowerTorso, player.Player, "ControlFruitVFXColor")
				table.insert(v9, clone4)

				for _, child2 in pairs(vUltimateCutscene.CharStuff.HumanoidRootPart:GetChildren()) do
					local clone5 = child2:Clone()
					Util.SetParentOverrideWithColor(clone5, root, player.Player, "ControlFruitVFXColor")
					table.insert(v9, clone5)
				end

				for _, child2 in pairs(vUltimateCutscene.CharStuff.DaggerVFX:GetChildren()) do
					local clone5 = child2:Clone()
					local clone6 = child2:Clone()
					Util.SetParentOverrideWithColor(clone5, clone2.Texture, player.Player, "ControlFruitVFXColor")
					Util.SetParentOverrideWithColor(clone6, clone3.Texture, player.Player, "ControlFruitVFXColor")
					table.insert(v9, clone5)
					table.insert(v9, clone6)
				end

				local clone5 = vUltimateCutscene.BAMPBLOOM:Clone()
				local clone6 = vUltimateCutscene.BAMPDOF:Clone()
				local clone7 = vUltimateCutscene.CONTROLCCE:Clone()
				local clone8 = vUltimateCutscene.BAMPAtmosphere:Clone()
				local clone9 = vUltimateCutscene.Bloom:Clone()
				clone5.Parent = Lighting
				clone6.Parent = Lighting
				clone7.Parent = Lighting
				clone8.Parent = Lighting.LightingLayers
				clone9.Parent = Lighting
				table.insert(v9, clone5)
				table.insert(v9, clone6)
				table.insert(v9, clone7)
				table.insert(v9, clone8)
				table.insert(v9, clone9)
				local highlight = Instance.new("Highlight")
				local player2 = player.Player
				local color = Color3.fromRGB(255, 0, 0)

				if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
					color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
				end

				highlight.FillColor = color
				highlight.FillTransparency = 1
				local player3 = player.Player
				local color2 = Color3.fromRGB(255, 255, 255)

				if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
					color2 = Util.WrapColor3Constructor(color2, player3, "ControlFruitVFXColor")
				end

				highlight.OutlineColor = color2
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Enabled = true
				highlight.Parent = root.Parent
				table.insert(v9, highlight)
				Util.SetParentOverrideWithColor(clone, model, player.Player, "ControlFruitVFXColor")
				local renderSteppedConnection = nil
				local characterRemovingConnection = nil
				local v10 = Util.Sound:Play("Ctrl_Ult_Cutscene_01_V2", localPlayer.PlayerGui)

				local function clear()
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end

					if characterRemovingConnection then
						characterRemovingConnection:Disconnect()
					end

					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
					pcall(function()
						if v10 then
							Util.Sound:FadeOut(v10, 0.2)
						end
					end)
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
					v7 = true
					_G.InCutscene = nil
					character:SetAttribute("InControlCutscene", nil)
					character.Humanoid.HipHeight = hipHeight
					root.Anchored = false

					for _, v11 in pairs(v9) do
						v11:Destroy()
					end

					applyLightingFromJSON()
					model:Destroy()
					model = nil
					v9 = nil
					_G.updateMusic2(false)
				end

				v3 = clear
				task.spawn(function()
					task.wait()
					v10.TimePosition = 0
					v10.Volume = 1

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

									local v11 = (beam:GetAttribute("pr3") + 1) % 1000
									beam:SetAttribute("pr3", v11)
									task.wait(emitDuration)

									if v11 == beam:GetAttribute("pr3") then
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

									local v11 = (beam:GetAttribute("pr3") + 1) % 1000
									beam:SetAttribute("pr3", v11)
									task.wait(emitDuration)

									if v11 == beam:GetAttribute("pr3") then
										beam.Enabled = false
									end
								end
							end)
						end
					end

					local tweenProperty = Util.xmc_Helper_Control.TweenProperty

					local function fn(p, p2, p3, ...)
						if typeof(p3) == "Color3" then
							local player4 = player.Player

							if typeof(player4) == "Instance" and player4:IsA("Player") and player4.Parent then
								p3 = Util.WrapColor3Constructor(p3, player4, "ControlFruitVFXColor")
							end
						end

						return tweenProperty(p, p2, p3, ...)
					end

					local v11 = {
						[1] = clone.CamReAdd,
						[2] = clone.Cubes,
						[3] = clone.ControlRig,
						[4] = currentCamera,
						[5] = game.Lighting,
						[6] = clone6,
						[7] = clone5,
						[8] = clone7,
						[9] = highlight,
						[10] = clone3.Texture.Star,
						[11] = clone2.Texture.Trail,
						[12] = clone3.Texture.Trail,
						[13] = upperTorso.torsotrail.TORSOTRAIL,
						[14] = upperTorso:FindFirstChild("BODYTRAIL", true),
						[19] = root.Slice.BEAM1.SliceBeam2,
						[20] = root.Slice.BEAM2.SliceBeam1,
						[21] = cubes.LargeCubeHalf1.Shader.fade.fade1,
						[22] = cubes.LargeCubeHalf2.Shader.fade.fade2,
						[23] = cubes.SplitCubeB8.Shader.FADE22.ImageLabel,
						[24] = cubes.SplitCubeB8.Shader.FADE21.ImageLabel,
						[25] = cubes.SplitCubeB8.Shader.FADE2.ImageLabel,
						[26] = cubes.SplitCubeB7.Shader.FADE22.ImageLabel,
						[27] = cubes.SplitCubeB7.Shader.FADE21.ImageLabel,
						[28] = cubes.SplitCubeB7.Shader.FADE2.ImageLabel,
						[29] = cubes.SplitCubeB6.Shader.FADE22.ImageLabel,
						[30] = cubes.SplitCubeB6.Shader.FADE21.ImageLabel,
						[31] = cubes.SplitCubeB6.Shader.FADE2.ImageLabel,
						[32] = cubes.SplitCubeB5.Shader.FADE21.ImageLabel,
						[33] = cubes.SplitCubeB5.Shader.FADE2.ImageLabel,
						[34] = cubes.SplitCubeB4.Shader.FADE21.ImageLabel,
						[35] = cubes.SplitCubeB4.Shader.FADE2.ImageLabel,
						[36] = cubes.SplitCubeB3.Shader.FADE21.ImageLabel,
						[37] = cubes.SplitCubeB3.Shader.FADE2.ImageLabel,
						[38] = cubes.SplitCubeB2.Shader.FADE21.ImageLabel,
						[39] = cubes.SplitCubeB2.Shader.FADE2.ImageLabel,
						[40] = cubes.SplitCubeB1.Shader.FADE21.ImageLabel,
						[41] = cubes.SplitCubeB1.Shader.FADE2.ImageLabel,
						[42] = clone2.Texture.StarEnable.star,
						[43] = clone3.Texture.StarEnable.star,
						[44] = root.BIGSLICE.b2x.BIGSLASH2,
						[45] = root.BIGSLICE.b2x.BIGSLASH,
						[46] = root.BIGSLICE.b2.BIGSLASH2,
						[47] = root.BIGSLICE.b2.BIGSLASH,
						[48] = root.BIGSLICE.Attachment.Wind,
						[49] = clone.CamReAdd.Cam.BAMP.Glitch,
						[50] = cubes.RootPart,
						[51] = root,
						[52] = clone.CamReAdd.H
					}
					local cFrame2 = v11[50].CFrame
					local cFrame3 = v11[51].CFrame
					local cFrame4 = v11[52].CFrame
					local exposureCompensation = v11[5].ExposureCompensation
					local v12 = {}
					v11[4].FieldOfView = 70
					v11[4].CFrame *= CFrame.new(
						2.371880292892456,
						32.62141799926758,
						-59.45380783081055,
						-0.998380184173584,
						-0.03514741361141205,
						0.0447407141327858,
						1.862645149230957e-9,
						0.7863696217536926,
						0.6177563071250916,
						-0.05689527094364166,
						0.6167556643486023,
						-0.7850958108901978
					)
					v11[5].ExposureCompensation = 0
					v11[6].InFocusRadius = 0
					v11[6].FarIntensity = 0
					v11[6].FocusDistance = 0
					v11[6].NearIntensity = 0
					v11[7].Threshold = 4
					v11[7].Intensity = 0
					v11[7].Size = 0
					local v14 = v11[8]
					local player4 = player.Player
					local color3 = Color3.fromRGB(255, 255, 255)

					if typeof(player4) == "Instance" and player4:IsA("Player") and player4.Parent then
						color3 = Util.WrapColor3Constructor(color3, player4, "ControlFruitVFXColor")
					end

					v14.TintColor = color3
					v11[8].Brightness = 0
					v11[8].Saturation = 0
					v11[8].Contrast = 0
					local v15 = v11[9]
					local player5 = player.Player
					local color4 = Color3.fromRGB(255, 0, 0)

					if typeof(player5) == "Instance" and player5:IsA("Player") and player5.Parent then
						color4 = Util.WrapColor3Constructor(color4, player5, "ControlFruitVFXColor")
					end

					v15.FillColor = color4
					v11[9].OutlineTransparency = 0
					v11[9].FillTransparency = 1
					v11[10].CFrame *= CFrame.new(
						0.025390625,
						-0.41717529296875,
						-0.129669189453125,
						1,
						2.8610236313397763e-6,
						-1.4901171425663051e-6,
						-2.8610238587134518e-6,
						1,
						-1.639088367255681e-7,
						1.4901166878189542e-6,
						1.6391309998198267e-7,
						1
					)
					v11[11].Enabled = true
					v11[11].Lifetime = 0.30000001192092896
					v11[12].Enabled = true
					v11[12].Lifetime = 0.30000001192092896
					v11[13].Enabled = false
					v11[14].Enabled = true
					v11[14].WidthScale = NumberSequence.new(0)
					v11[14].Lifetime = 2
					v11[19].Enabled = false
					v11[19].Width0 = 0
					v11[19].Width1 = 2
					v11[20].Enabled = false
					v11[20].Width0 = 0
					v11[20].Width1 = 2
					v11[21].ImageTransparency = 0
					v11[22].ImageTransparency = 0
					v11[23].ImageTransparency = 0
					v11[24].ImageTransparency = 0
					v11[25].ImageTransparency = 0
					v11[26].ImageTransparency = 0
					v11[27].ImageTransparency = 0
					v11[28].ImageTransparency = 0
					v11[29].ImageTransparency = 0
					v11[30].ImageTransparency = 0
					v11[31].ImageTransparency = 0
					v11[32].ImageTransparency = 0
					v11[33].ImageTransparency = 0
					v11[34].ImageTransparency = 0
					v11[35].ImageTransparency = 0
					v11[36].ImageTransparency = 0
					v11[37].ImageTransparency = 0
					v11[38].ImageTransparency = 0
					v11[39].ImageTransparency = 0
					v11[40].ImageTransparency = 0
					v11[41].ImageTransparency = 0
					v11[42].Enabled = false
					v11[43].Enabled = false
					v11[44].Enabled = false
					v11[44].Width0 = 15
					v11[44].Width1 = 15
					v11[45].Enabled = false
					v11[45].Width0 = 15
					v11[45].Width1 = 15
					v11[46].Enabled = false
					v11[46].Width0 = 15
					v11[46].Width1 = 15
					v11[47].Enabled = false
					v11[47].Width0 = 15
					v11[47].Width1 = 15
					v11[48]:Emit(10)
					v11[48].Enabled = false
					v11[49].CFrame *= CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					v11[50].CFrame *= CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					v11[51].CFrame *= CFrame.new(
						0,
						0,
						0,
						1,
						-2.9016967560466852e-40,
						0,
						-8.705090268140056e-40,
						1,
						1.284651299361831e-19,
						0,
						4.282171213284388e-20,
						1
					)
					v11[52].CFrame *= CFrame.new(0, -3.181999921798706, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

					v12[0] = function()
						fn(v11[4], "FieldOfView", 40, 0.1, "Linear", nil)
						task.spawn(function()
							for _, effect in camReAdd.Cam.ScreenFX.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[5], "ExposureCompensation", 0, 2.35, "Linear", nil)
						fn(v11[6], "FarIntensity", 0, 0.63333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.63333, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.63333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.63333, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.31667, "Linear", nil)
						fn(v11[11], "Enabled", true, 0.51667, "Constant", nil)
						fn(v11[12], "Enabled", true, 0.51667, "Constant", nil)
						fn(v11[13], "Enabled", true, 10.25, "Constant", nil)
						fn(v11[14], "Enabled", false, 5.23333, "Constant", nil)
						fn(v11[19], "Width0", 0, 6.8, "Linear", nil)
						fn(v11[19], "Width1", 0, 6.8, "Linear", nil)
						fn(v11[20], "Width0", 0, 6.8, "Linear", nil)
						fn(v11[20], "Width1", 0, 6.8, "Linear", nil)
						fn(v11[21], "ImageTransparency", 1, 6.78333, "Linear", nil)
						fn(v11[22], "ImageTransparency", 1, 6.78333, "Linear", nil)
						fn(v11[23], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[24], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[25], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[26], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[27], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[28], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[29], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[30], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[31], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[32], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[33], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[34], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[35], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[36], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[37], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[38], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[39], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[40], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[41], "ImageTransparency", 1, 10.48333, "Linear", nil)
						fn(v11[42], "Enabled", true, 7.13333, "Constant", nil)
						fn(v11[43], "Enabled", true, 6.46667, "Constant", nil)
						fn(
							v11[50],
							"CFrame",
							cFrame2 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							3.31667,
							"Linear",
							nil
						)
						fn(
							v11[51],
							"CFrame",
							cFrame3 * CFrame.new(
								0,
								0,
								0,
								1,
								-2.9016967560466852e-40,
								0,
								-8.705090268140056e-40,
								1,
								1.284651299361831e-19,
								0,
								4.282171213284388e-20,
								1
							),
							3.31667,
							"Linear",
							nil
						)
						fn(
							v11[52],
							"CFrame",
							cFrame4 * CFrame.new(0, -3.181999921798706, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							3.31667,
							"Linear",
							nil
						)
					end

					v12[4] = function()
						task.spawn(function()
							for _, effect in controlRig.SETCFRAMES.Main:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[6] = function()
						fn(v11[4], "FieldOfView", 40, 0.18333, "Linear", nil)
					end

					v12[9] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.SPIN2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.SPIN2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[17] = function()
						fn(v11[4], "FieldOfView", 100, 0.31667, "Linear", nil)
					end

					v12[31] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[11], "Enabled", false, 4.6, "Constant", nil)
						fn(v11[12], "Enabled", false, 4.6, "Constant", nil)
					end

					v12[35] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[36] = function()
						fn(v11[4], "FieldOfView", 30, 0.13333, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(75, 0, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", -2, 0.05, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.05, "Linear", nil)
					end

					v12[38] = function()
						task.spawn(function()
							for _, effect in root.GlowShape:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[6], "FarIntensity", 0.39800000190734863, 0.11667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 1.6150000095367432, 0.11667, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.11667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.39800000190734863, 0.11667, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
					end

					v12[39] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.01667, "Linear", nil)
					end

					v12[40] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.36667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.36667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.36667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.36667, "Linear", nil)
					end

					v12[44] = function()
						fn(v11[4], "FieldOfView", 15, 0.33333, "Back", "In", 1.70158)
						task.spawn(function()
							for _, effect in clone2.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[45] = function()
						fn(v11[6], "FarIntensity", 0, 0.26667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.26667, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.26667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.26667, "Linear", nil)
					end

					v12[52] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[57] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[61] = function()
						fn(v11[6], "FarIntensity", 0, 2.4, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 2.4, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 2.4, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 2.4, "Linear", nil)
					end

					v12[62] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[63] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.03333, "Linear", nil)
					end

					v12[64] = function()
						fn(v11[4], "FieldOfView", 75, 0.16667, "Linear", nil)
					end

					v12[65] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[66] = function()
						task.spawn(function()
							for _, effect in root.SliceFirst:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(62, 70, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[67] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.BAMP.Glint:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[68] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(186, 177, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0.7, 0.03333, "Linear", nil)
					end

					v12[70] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.71667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 1.71667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 1.71667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 1.71667, "Linear", nil)
					end

					v12[74] = function()
						fn(v11[4], "FieldOfView", 50, 0.25, "Sine", "Out")
					end

					v12[79] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.BAMP.Glitch:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[89] = function()
						fn(v11[4], "FieldOfView", 48, 1.83333, "Linear", nil)
					end

					v12[104] = function()
						task.spawn(function()
							for _, effect in camReAdd.Camweld:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[141] = function()
						fn(v11[5], "ExposureCompensation", 7, 0.1, "Linear", nil)
					end

					v12[147] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.26667, "Linear", nil)
					end

					v12[163] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.51667, "Linear", nil)
					end

					v12[173] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.2, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.2, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.2, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.2, "Linear", nil)
					end

					v12[181] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.BAMP.error:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[185] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 2.23333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.23333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 2.23333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 2.23333, "Linear", nil)
					end

					v12[194] = function()
						fn(v11[5], "ExposureCompensation", 9, 0.06667, "Linear", nil)
					end

					v12[198] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.2, "Linear", nil)
						task.spawn(function()
							for _, emitter in clone2:GetDescendants() do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = false
								emitter:Clear()
							end

							for _, emitter in clone3:GetDescendants() do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = false
								emitter:Clear()
							end
						end)
					end

					v12[199] = function()
						fn(v11[4], "FieldOfView", 38, 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 1, 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(
							v11[50],
							"CFrame",
							cFrame2 * CFrame.new(0, 10000, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							0.01667,
							"Linear",
							nil
						)
						fn(
							v11[51],
							"CFrame",
							cFrame3 * CFrame.new(
								0,
								10000,
								0,
								1,
								-2.9016967560466852e-40,
								0,
								2.9016967560466852e-40,
								1,
								1.284651299361831e-19,
								0,
								-1.284651299361831e-19,
								1
							),
							0.01667,
							"Linear",
							nil
						)
						fn(
							v11[52],
							"CFrame",
							cFrame4 * CFrame.new(0, 9996.7998046875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							0.01667,
							"Linear",
							nil
						)
					end

					v12[200] = function()
						fn(v11[4], "FieldOfView", 60, 1.78333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.36667, "Sine", "Out")
						fn(v11[9], "OutlineTransparency", 0, 1.98333, "Linear", nil)
						fn(
							v11[50],
							"CFrame",
							cFrame2 * CFrame.new(0, 10000, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							9.55,
							"Linear",
							nil
						)
						fn(
							v11[51],
							"CFrame",
							cFrame3 * CFrame.new(
								0,
								10000,
								0,
								1,
								-2.9016967560466852e-40,
								0,
								2.9016967560466852e-40,
								1,
								1.284651299361831e-19,
								0,
								-1.284651299361831e-19,
								1
							),
							10.78333,
							"Linear",
							nil
						)
						fn(
							v11[52],
							"CFrame",
							cFrame4 * CFrame.new(0, 9996.7998046875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							10.78333,
							"Linear",
							nil
						)
					end

					v12[202] = function()
						task.spawn(function()
							for _, effect in controlRig.SETCFRAMES.DOMAINAURA.Glitch:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[205] = function()
						fn(v11[6], "FarIntensity", 0, 0.98333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.98333, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.98333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.98333, "Linear", nil)
					end

					v12[210] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.65, "Linear", nil)
					end

					v12[220] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[222] = function()
						fn(v11[8], "Brightness", 0, 1.61667, "Linear", nil)
					end

					v12[223] = function()
						fn(v11[7], "Threshold", 0.19999999999999998, 0.13333, "Linear", nil)
						fn(v11[7], "Intensity", 1, 0.13333, "Linear", nil)
						fn(v11[7], "Size", 56, 0.13333, "Linear", nil)
					end

					v12[231] = function()
						fn(v11[7], "Threshold", 1.090999960899353, 0.28333, "Linear", nil)
						fn(v11[7], "Intensity", 0.6499999761581421, 0.28333, "Linear", nil)
						fn(v11[7], "Size", 56, 0.28333, "Linear", nil)
					end

					v12[248] = function()
						fn(v11[7], "Threshold", 1.4780000448226929, 0.6, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 0.6, "Linear", nil)
						fn(v11[7], "Size", 56, 0.6, "Linear", nil)
					end

					v12[249] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.96667, "Linear", nil)
					end

					v12[264] = function()
						fn(v11[6], "FarIntensity", 0.024444444105029106, 0.91667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.91667, "Linear", nil)
						fn(v11[6], "FocusDistance", 4.891194820404053, 0.91667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.91667, "Linear", nil)
					end

					v12[284] = function()
						fn(v11[7], "Threshold", 1.4780000448226929, 0.66667, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 0.66667, "Linear", nil)
						fn(v11[7], "Size", 56, 0.66667, "Linear", nil)
					end

					v12[304] = function() end

					v12[307] = function()
						fn(v11[4], "FieldOfView", 25, 0.21667, "Linear", nil)
						fn(v11[5], "ExposureCompensation", 0, 0.2, "Linear", nil)
						fn(v11[11], "Enabled", false, 1.36667, "Constant", nil)
						fn(v11[12], "Enabled", false, 1.36667, "Constant", nil)
					end

					v12[314] = function()
						fn(v11[14], "Enabled", false, 2.93333, "Constant", nil)
					end

					v12[319] = function()
						fn(v11[5], "ExposureCompensation", 2, 0.01667, "Linear", nil)
						fn(v11[6], "FarIntensity", 0.24699999392032623, 0.05, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.05, "Linear", nil)
						fn(v11[6], "FocusDistance", 5.1579999923706055, 0.05, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.31200000643730164, 0.05, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.01667, "Linear", nil)
					end

					v12[320] = function()
						fn(v11[4], "FieldOfView", 70, 0.06667, "Linear", nil)
						task.spawn(function()
							for _, effect in clone2.Texture.POP:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[5], "ExposureCompensation", -2, 0.05, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(75, 0, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", -2, 0.05, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.05, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.05, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.05, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.05, "Linear", nil)
					end

					v12[322] = function()
						fn(v11[6], "FarIntensity", 0.26899999380111694, 0.06667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.06667, "Linear", nil)
						fn(v11[6], "FocusDistance", 40.86000061035156, 0.06667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.3440000116825104, 0.06667, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
					end

					v12[323] = function()
						fn(v11[5], "ExposureCompensation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)
					end

					v12[324] = function()
						fn(v11[4], "FieldOfView", 50, 0.01667, "Linear", nil)
						fn(v11[5], "ExposureCompensation", 0, 9.45, "Linear", nil)
						fn(v11[7], "Threshold", 1.4780000448226929, 1.01667, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 1.01667, "Linear", nil)
						fn(v11[7], "Size", 56, 1.01667, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.35, "Linear", nil)
						fn(v11[8], "Brightness", 0, 1.35, "Linear", nil)
						fn(v11[8], "Saturation", 0, 1.35, "Linear", nil)
						fn(v11[8], "Contrast", 0, 1.35, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 2.76667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 2.76667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 2.76667, "Linear", nil)
					end

					v12[325] = function()
						fn(v11[4], "FieldOfView", 95, 0.43333, "Back", "In", 1.70158)
						task.spawn(function()
							for _, effect in clone2.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[326] = function()
						fn(v11[6], "FarIntensity", 0, 0.13333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.13333, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.13333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.13333, "Linear", nil)
					end

					v12[334] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 1.36667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 1.36667, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 1.36667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 1.36667, "Linear", nil)
					end

					v12[337] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP1:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[342] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[348] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP3:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[351] = function()
						fn(v11[4], "FieldOfView", 70, 0.61667, "Linear", nil)
					end

					v12[354] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP4:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[358] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP5:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[361] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP6:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[367] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP7:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[372] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.STEP8:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[376] = function()
						task.spawn(function()
							for _, effect in root.Dash:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[385] = function()
						fn(v11[7], "Threshold", 1.4780000448226929, 5.88333, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 5.88333, "Linear", nil)
						fn(v11[7], "Size", 56, 5.88333, "Linear", nil)
					end

					v12[388] = function()
						fn(v11[4], "FieldOfView", 50, 0.01667, "Linear", nil)
						fn(v11[43], "Enabled", false, 1.03333, "Constant", nil)
					end

					v12[389] = function()
						fn(v11[4], "FieldOfView", 30, 0.18333, "Linear", nil)
						fn(v11[11], "Enabled", true, 0.45, "Constant", nil)
						fn(v11[12], "Enabled", true, 0.45, "Constant", nil)
					end

					v12[400] = function()
						fn(v11[4], "FieldOfView", 35, 0.06667, "Linear", nil)
					end

					v12[404] = function()
						fn(v11[4], "FieldOfView", 56, 0.1, "Linear", nil)
					end

					v12[405] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[406] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(62, 70, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 1, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.03333, "Linear", nil)
					end

					v12[407] = function()
						fn(v11[21], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[22], "ImageTransparency", 0, 0.01667, "Linear", nil)
					end

					v12[408] = function()
						task.spawn(function()
							for _, effect in root.Slice:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
						fn(v11[19], "Width0", 0, 0.13333, "Linear", nil)
						fn(v11[19], "Width1", 11, 0.13333, "Linear", nil)
						fn(v11[20], "Width0", 0, 0.13333, "Linear", nil)
						fn(v11[20], "Width1", 11, 0.13333, "Linear", nil)
						fn(v11[21], "ImageTransparency", 1, 0.75, "Sine", "InOut")
						fn(v11[22], "ImageTransparency", 1, 0.75, "Sine", "InOut")
					end

					v12[409] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.01667, "Linear", nil)
					end

					v12[410] = function()
						fn(v11[4], "FieldOfView", 90, 0.18333, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.36667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 1.36667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 1.36667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 1.36667, "Linear", nil)
					end

					v12[411] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.ScreenFX.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[416] = function()
						fn(v11[6], "FarIntensity", 0.4300000071525574, 0.08333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.08333, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.08333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.15000000596046448, 0.08333, "Linear", nil)
						fn(v11[11], "Enabled", false, 0.48333, "Constant", nil)
						fn(v11[12], "Enabled", false, 0.48333, "Constant", nil)
						fn(v11[19], "Width0", 0, 0.2, "Sine", "Out")
						fn(v11[19], "Width1", 0, 0.2, "Sine", "InOut")
						fn(v11[20], "Width0", 0, 0.2, "Sine", "Out")
						fn(v11[20], "Width1", 0, 0.2, "Sine", "InOut")
					end

					v12[420] = function()
						task.spawn(function()
							for _, effect in character.LowerTorso.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[421] = function()
						fn(v11[4], "FieldOfView", 76, 0.16667, "Linear", nil)
						fn(v11[6], "FarIntensity", 0.7850000262260437, 0.45, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.45, "Linear", nil)
						fn(v11[6], "FocusDistance", 55.91999816894531, 0.45, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.45, "Linear", nil)
					end

					v12[428] = function()
						fn(v11[42], "Enabled", false, 0.36667, "Constant", nil)
					end

					v12[431] = function()
						fn(v11[4], "FieldOfView", 70, 0.35, "Linear", nil)
					end

					v12[441] = function()
						task.spawn(function()
							for _, effect in cubes.LargeCube5.GroundPart:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[444] = function()
						task.spawn(function()
							for _, effect in root.Expand:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[445] = function()
						fn(v11[11], "Enabled", false, 0.68333, "Constant", nil)
						fn(v11[12], "Enabled", false, 0.68333, "Constant", nil)
					end

					v12[448] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 0.16667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.16667, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 0.16667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.16667, "Linear", nil)
					end

					v12[450] = function()
						fn(v11[42], "Enabled", true, 2.63333, "Constant", nil)
						fn(v11[43], "Enabled", true, 2.63333, "Constant", nil)
					end

					v12[452] = function()
						fn(v11[4], "FieldOfView", 51, 0.01667, "Linear", nil)
					end

					v12[453] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.68333, "Linear", nil)
					end

					v12[458] = function()
						fn(v11[6], "FarIntensity", 0, 0.45, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.45, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.45, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.45, "Linear", nil)
					end

					v12[479] = function()
						task.spawn(function()
							for _, effect in controlRig.CUTSCENEVFX.TP1st:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[485] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 0.81667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.81667, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 0.81667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.81667, "Linear", nil)
					end

					v12[486] = function()
						fn(v11[11], "Enabled", false, 2.38333, "Constant", nil)
						fn(v11[12], "Enabled", false, 2.38333, "Constant", nil)
					end

					v12[490] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[14], "Enabled", true, 3.71667, "Constant", nil)
					end

					v12[491] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.11667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.11667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.11667, "Linear", nil)
					end

					v12[492] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[493] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 0.5, 0.05, "Linear", nil)
					end

					v12[494] = function()
						fn(v11[4], "FieldOfView", 61, 0.01667, "Linear", nil)
					end

					v12[495] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
					end

					v12[496] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.POUNCE1:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 2, 0.01667, "Linear", nil)
					end

					v12[497] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.38333, "Linear", nil)
						task.spawn(function()
							for _, effect in controlRig.CUTSCENEVFX.TP2nd:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
					end

					v12[498] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)
					end

					v12[499] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.35, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.35, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.35, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.35, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.26667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.26667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.26667, "Linear", nil)
					end

					v12[515] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.01667, "Linear", nil)
					end

					v12[516] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.11667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.11667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.11667, "Linear", nil)
					end

					v12[520] = function()
						fn(v11[4], "FieldOfView", 96, 0.03333, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[521] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 0.5, 0.05, "Linear", nil)
					end

					v12[522] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.06667, "Linear", nil)
					end

					v12[523] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.POUNCE2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)
					end

					v12[524] = function()
						task.spawn(function()
							for _, effect in controlRig.CUTSCENEVFX.TP3rd:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 2, 0.01667, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.56667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.56667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.56667, "Linear", nil)
					end

					v12[525] = function()
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
					end

					v12[526] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.21667, "Linear", nil)
					end

					v12[527] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.6, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.6, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.6, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.6, "Linear", nil)
					end

					v12[534] = function()
						fn(v11[6], "FarIntensity", 0.4300000071525574, 0.08333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.08333, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.08333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.15000000596046448, 0.08333, "Linear", nil)
					end

					v12[539] = function()
						fn(v11[4], "FieldOfView", 45, 0.13333, "Linear", nil)
						fn(v11[6], "FarIntensity", 0.7850000262260437, 0.45, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.45, "Linear", nil)
						fn(v11[6], "FocusDistance", 55.91999816894531, 0.45, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.45, "Linear", nil)
					end

					v12[547] = function()
						fn(v11[4], "FieldOfView", 64, 0.06667, "Linear", nil)
					end

					v12[551] = function()
						fn(v11[4], "FieldOfView", 51.000003814697266, 0.1, "Linear", nil)
					end

					v12[557] = function()
						fn(v11[4], "FieldOfView", 42, 0.08333, "Linear", nil)
					end

					v12[558] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.01667, "Linear", nil)
					end

					v12[559] = function()
						fn(v11[9], "FillColor", Color3.fromRGB(0, 0, 0), 0.11667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.11667, "Linear", nil)
						fn(v11[9], "FillTransparency", 0, 0.11667, "Linear", nil)
					end

					v12[562] = function()
						fn(v11[4], "FieldOfView", 40, 0.4, "Linear", nil)
					end

					v12[563] = function()
						task.spawn(function()
							for _, effect in root.Footsteps.POUNCE:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[564] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 0.5, 0.05, "Linear", nil)
					end

					v12[566] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 0.16667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.16667, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 0.16667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.16667, "Linear", nil)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
						fn(v11[9], "FillColor", Color3.fromRGB(255, 0, 0), 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)
					end

					v12[567] = function()
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 2, 0.01667, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 0, 4.5, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 4.5, "Linear", nil)
					end

					v12[568] = function()
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
					end

					v12[570] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.01667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 1.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 1.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 1.01667, "Linear", nil)
					end

					v12[576] = function()
						fn(v11[6], "FarIntensity", 0, 0.45, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.45, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.45, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.45, "Linear", nil)
					end

					v12[586] = function()
						fn(v11[4], "FieldOfView", 41, 0.01667, "Linear", nil)
					end

					v12[587] = function()
						fn(v11[4], "FieldOfView", 35, 0.68333, "Back", "In", 1.70158)
					end

					v12[603] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 2.3, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 2.3, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 2.3, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 2.3, "Linear", nil)
					end

					v12[608] = function()
						fn(v11[42], "Enabled", false, 0.43333, "Constant", nil)
						fn(v11[43], "Enabled", false, 0.43333, "Constant", nil)
					end

					v12[615] = function()
						fn(v11[13], "Enabled", false, 0.68333, "Constant", nil)
					end

					v12[622] = function()
						task.spawn(function()
							for _, effect in clone3.Texture.Pressure:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[623] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.ScreenFX.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[624] = function()
						task.spawn(function()
							for _, effect in clone2.Texture.Pressure:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[628] = function()
						fn(v11[4], "FieldOfView", 15, 0.03333, "Bounce", "Out")
						task.spawn(function()
							for _, effect in controlRig.SETCFRAMES.CubeBreak:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[629] = function()
						fn(v11[11], "Enabled", false, 0.46667, "Constant", nil)
						fn(v11[12], "Enabled", false, 0.46667, "Constant", nil)
						fn(v11[23], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[24], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[25], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[26], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[27], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[28], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[29], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[30], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[31], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[32], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[33], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[34], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[35], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[36], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[37], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[38], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[39], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[40], "ImageTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[41], "ImageTransparency", 0, 0.01667, "Linear", nil)
					end

					v12[630] = function()
						fn(v11[4], "FieldOfView", 66, 0.1, "Linear", nil)
						fn(v11[23], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[24], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[25], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[26], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[27], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[28], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[29], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[30], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[31], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[32], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[33], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[34], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[35], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[36], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[37], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[38], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[39], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[40], "ImageTransparency", 1, 0.46667, "Bounce", "In")
						fn(v11[41], "ImageTransparency", 1, 0.46667, "Bounce", "In")
					end

					v12[631] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[632] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.03333, "Linear", nil)
					end

					v12[633] = function()
						fn(v11[11], "Lifetime", 0.30000001192092896, 1.33333, "Linear", nil)
						fn(v11[12], "Lifetime", 0.30000001192092896, 1.33333, "Linear", nil)
					end

					v12[634] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
						fn(v11[42], "Enabled", true, 1.26667, "Constant", nil)
						fn(v11[43], "Enabled", true, 1.26667, "Constant", nil)
					end

					v12[635] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(62, 70, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[636] = function()
						fn(v11[4], "FieldOfView", 66, 0.33333, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[637] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(186, 177, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0.7, 0.03333, "Linear", nil)
					end

					v12[639] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.51667, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.51667, "Linear", nil)
						fn(v11[8], "Saturation", -0.695652186870575, 0.23333, "Linear", nil)
						fn(v11[8], "Contrast", 0.695652186870575, 0.23333, "Linear", nil)
					end

					v12[653] = function()
						fn(v11[8], "Saturation", 0, 0.28333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.28333, "Linear", nil)
					end

					v12[656] = function()
						fn(v11[4], "FieldOfView", 104, 0.01667, "Linear", nil)
						fn(v11[13], "Enabled", true, 0.03333, "Constant", nil)
					end

					v12[657] = function()
						fn(v11[4], "FieldOfView", 55, 0.65, "Back", "InOut", 1.70158)
						fn(v11[11], "Enabled", true, 0.28333, "Constant", nil)
						fn(v11[12], "Enabled", true, 0.28333, "Constant", nil)
					end

					v12[658] = function()
						fn(v11[13], "Enabled", false, 1.15, "Constant", nil)
					end

					v12[670] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[671] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.ScreenFX.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
						fn(v11[8], "Brightness", -0.7, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 0.5, 0.05, "Linear", nil)
					end

					v12[673] = function()
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
					end

					v12[674] = function()
						fn(v11[8], "Saturation", 0, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 2, 0.01667, "Linear", nil)
						fn(v11[11], "Enabled", true, 0.65, "Constant", nil)
						fn(v11[12], "Enabled", true, 0.65, "Constant", nil)
					end

					v12[675] = function()
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
					end

					v12[677] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.1, "Linear", nil)
						fn(v11[8], "Brightness", 0, 1.1, "Linear", nil)
						fn(v11[8], "Saturation", 0, 1.1, "Linear", nil)
						fn(v11[8], "Contrast", 0, 1.1, "Linear", nil)
					end

					v12[680] = function()
						task.spawn(function()
							for _, effect in camReAdd.Cam.ScreenFX.Wind:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[696] = function()
						fn(v11[4], "FieldOfView", 55, 0.01667, "Linear", nil)
					end

					v12[697] = function()
						fn(v11[4], "FieldOfView", 98, 0.48333, "Bounce", "In")
					end

					v12[708] = function() end

					v12[710] = function()
						task.spawn(function()
							for _, effect in character.LowerTorso.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[42], "Enabled", false, 1.3, "Constant", nil)
						fn(v11[43], "Enabled", false, 1.3, "Constant", nil)
					end

					v12[713] = function()
						fn(v11[11], "Enabled", false, 0.36667, "Constant", nil)
						fn(v11[11], "Lifetime", 2, 0.46667, "Linear", nil)
						fn(v11[12], "Enabled", false, 0.36667, "Constant", nil)
						fn(v11[12], "Lifetime", 2, 0.46667, "Linear", nil)
						fn(v11[14], "Enabled", false, 0.28333, "Constant", nil)
					end

					v12[718] = function()
						fn(v11[14], "Lifetime", 0, 0.8, "Linear", nil)
					end

					v12[726] = function()
						fn(v11[4], "FieldOfView", 40, 0.01667, "Linear", nil)
					end

					v12[727] = function()
						fn(v11[4], "FieldOfView", 65, 0.4, "Linear", nil)
					end

					v12[730] = function()
						fn(v11[14], "Enabled", true, 0.1, "Constant", nil)
					end

					v12[735] = function()
						fn(v11[11], "Enabled", true, 0.01667, "Constant", nil)
						fn(v11[12], "Enabled", true, 0.01667, "Constant", nil)
					end

					v12[736] = function()
						fn(v11[11], "Enabled", false, 0.18333, "Constant", nil)
						fn(v11[12], "Enabled", false, 0.18333, "Constant", nil)
						fn(v11[14], "Enabled", false, 0.46667, "Constant", nil)
					end

					v12[738] = function()
						fn(v11[7], "Threshold", 5, 0.26667, "Linear", nil)
						fn(v11[7], "Intensity", 0, 0.26667, "Linear", nil)
						fn(v11[7], "Size", 56, 0.26667, "Linear", nil)
					end

					v12[739] = function()
						task.spawn(function()
							for _, effect in character.LowerTorso.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[741] = function()
						fn(v11[6], "FarIntensity", 0.4300000071525574, 0.2, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.2, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.2, "Linear", nil)
						fn(v11[6], "NearIntensity", 0.15000000596046448, 0.2, "Linear", nil)
						fn(v11[11], "Lifetime", 0.30000001192092896, 0.28333, "Linear", nil)
						fn(v11[12], "Lifetime", 0.30000001192092896, 0.2, "Linear", nil)
					end

					v12[743] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 1.48333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.56667, "Linear", nil)
						fn(v11[8], "Saturation", -0.695652186870575, 0.56667, "Bounce", "In")
						fn(v11[8], "Contrast", 0.695652186870575, 0.56667, "Bounce", "In")
					end

					v12[744] = function()
						task.spawn(function()
							for _, effect in root.DOWNSHOCK:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[747] = function()
						fn(v11[11], "Enabled", false, 0.56667, "Constant", nil)
						fn(v11[12], "Enabled", false, 0.56667, "Constant", nil)
					end

					v12[751] = function()
						fn(v11[4], "FieldOfView", 61, 0.23333, "Linear", nil)
					end

					v12[753] = function()
						fn(v11[6], "FarIntensity", 0.7850000262260437, 0.33333, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.33333, "Linear", nil)
						fn(v11[6], "FocusDistance", 8.600000381469727, 0.33333, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.33333, "Linear", nil)
						fn(v11[12], "Lifetime", 0, 0.43333, "Linear", nil)
					end

					v12[754] = function()
						fn(v11[7], "Threshold", 1.4780000448226929, 0.25, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 0.25, "Linear", nil)
						fn(v11[7], "Size", 56, 0.25, "Linear", nil)
					end

					v12[758] = function()
						fn(v11[11], "Lifetime", 0.30000001192092896, 0.35, "Linear", nil)
					end

					v12[764] = function() end

					v12[765] = function()
						fn(v11[4], "FieldOfView", 52, 0.06667, "Linear", nil)
					end

					v12[766] = function() end

					v12[769] = function()
						fn(v11[4], "FieldOfView", 58, 0.13333, "Linear", nil)
						fn(v11[7], "Threshold", 1.4780000448226929, 0.6, "Linear", nil)
						fn(v11[7], "Intensity", 0.20000000298023224, 0.6, "Linear", nil)
						fn(v11[7], "Size", 56, 0.6, "Linear", nil)
					end

					v12[772] = function()
						task.spawn(function()
							for _, effect in character.LowerTorso.SPIN:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[773] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 0.16667, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.16667, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 0.16667, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.16667, "Linear", nil)
						fn(
							v11[50],
							"CFrame",
							cFrame2 * CFrame.new(0, 10000, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							1.23333,
							"Linear",
							nil
						)
					end

					v12[777] = function()
						fn(v11[4], "FieldOfView", 48, 0.33333, "Linear", nil)
						fn(v11[8], "Brightness", -1.5, 0.05, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.05, "Linear", nil)
					end

					v12[779] = function() end

					v12[780] = function()
						fn(v11[8], "Brightness", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.01667, "Linear", nil)
					end

					v12[781] = function()
						fn(v11[8], "Brightness", 0, 0.6, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.6, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.6, "Linear", nil)
					end

					v12[783] = function()
						fn(v11[6], "FarIntensity", 0.21199999749660492, 0.7, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.7, "Linear", nil)
						fn(v11[6], "FocusDistance", 42.41999816894531, 0.7, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.7, "Linear", nil)
					end

					v12[788] = function() end

					v12[792] = function()
						task.spawn(function()
							for _, effect in root.SLICEBAMP:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
					end

					v12[796] = function() end

					v12[797] = function()
						fn(v11[4], "FieldOfView", 42, 0.53333, "Linear", nil)
					end

					v12[805] = function()
						fn(v11[7], "Threshold", 5, 0.26667, "Linear", nil)
						fn(v11[7], "Intensity", 0, 0.26667, "Linear", nil)
						fn(v11[7], "Size", 56, 0.26667, "Linear", nil)
					end

					v12[817] = function()
						fn(v11[8], "Brightness", 0, 0.23333, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.23333, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.23333, "Linear", nil)
					end

					v12[821] = function()
						fn(v11[7], "Threshold", 1, 0.25, "Linear", nil)
						fn(v11[7], "Intensity", 0.19999999999999998, 0.25, "Linear", nil)
						fn(v11[7], "Size", 12, 0.25, "Linear", nil)
					end

					v12[825] = function()
						fn(v11[6], "FarIntensity", 0.7850000262260437, 0.15, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.15, "Linear", nil)
						fn(v11[6], "FocusDistance", 8.600000381469727, 0.15, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.15, "Linear", nil)
					end

					v12[829] = function()
						fn(v11[4], "FieldOfView", 12, 0.01667, "Linear", nil)
					end

					v12[830] = function()
						fn(v11[4], "FieldOfView", 12, 0.03333, "Linear", nil)
					end

					v12[831] = function()
						fn(v11[8], "Brightness", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.01667, "Linear", nil)
					end

					v12[832] = function()
						fn(v11[4], "FieldOfView", 55, 0.2, "Expo", "Out")
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[833] = function()
						task.spawn(function()
							if not v4 then
								local character2 = localPlayer.Character
								local cFrame5 = character2.HumanoidRootPart.CFrame
								camReAdd:PivotTo(cFrame5)
								cFrame4 = cFrame5
								local cRUltimateVictimPlayer = Util.Anims:Get(character2, "CRUltimate_VictimPlayer")
								cRUltimateVictimPlayer.Priority = Enum.AnimationPriority.Action4
								cRUltimateVictimPlayer:Play()
								local cRUltimateVictimCamera = Util.Anims:Get(camReAdd, "CRUltimate_VictimCamera")
								cRUltimateVictimCamera.Priority = Enum.AnimationPriority.Action4
								cRUltimateVictimCamera:Play()
							end

							for _, effect in root.BIGSLICE:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[834] = function()
						fn(v11[6], "FarIntensity", 0, 0.25, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.25, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.25, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.25, "Linear", nil)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.03333, "Linear", nil)
					end

					v12[836] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(62, 70, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", 2, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", 1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[837] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.05, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.05, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.05, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.05, "Linear", nil)
						fn(v11[9], "OutlineTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)
						fn(v11[44], "Enabled", true, 0.05, "Constant", nil)
						fn(v11[44], "Width0", 0, 0.15, "Linear", nil)
						fn(v11[44], "Width1", 0, 0.15, "Linear", nil)
						fn(v11[45], "Enabled", true, 0.05, "Constant", nil)
						fn(v11[45], "Width0", 0, 0.15, "Linear", nil)
						fn(v11[45], "Width1", 0, 0.15, "Linear", nil)
						fn(v11[46], "Enabled", true, 0.05, "Constant", nil)
						fn(v11[46], "Width0", 0, 0.15, "Linear", nil)
						fn(v11[46], "Width1", 0, 0.15, "Linear", nil)
						fn(v11[47], "Enabled", true, 0.05, "Constant", nil)
						fn(v11[47], "Width0", 0, 0.15, "Linear", nil)
						fn(v11[47], "Width1", 0, 0.15, "Linear", nil)
					end

					v12[838] = function()
						fn(v11[9], "OutlineTransparency", 1, 0.15, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.15, "Linear", nil)
					end

					v12[840] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(186, 177, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0.5, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0.7, 0.03333, "Linear", nil)
					end

					v12[842] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
					end

					v12[844] = function()
						fn(v11[4], "FieldOfView", 120, 1.06667, "Back", "In", 1.70158)
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[845] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(133, 85, 255), 0.01667, "Linear", nil)
						fn(v11[8], "Brightness", -5, 0.01667, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", -5, 0.01667, "Linear", nil)
					end

					v12[846] = function()
						task.spawn(function()
							for _, effect in root.DOMAINBREAK:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end

							for _, effect in clone3.Texture.Star:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									Emit(effect)
								end
							end
						end)
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.03333, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.03333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.03333, "Linear", nil)
						fn(v11[44], "Width0", 15, 0.06667, "Linear", nil)
						fn(v11[44], "Width1", 15, 0.06667, "Linear", nil)
						fn(v11[45], "Width0", 15, 0.06667, "Linear", nil)
						fn(v11[45], "Width1", 15, 0.06667, "Linear", nil)
						fn(v11[46], "Width0", 15, 0.06667, "Linear", nil)
						fn(v11[46], "Width1", 15, 0.06667, "Linear", nil)
						fn(v11[47], "Width0", 15, 0.06667, "Linear", nil)
						fn(v11[47], "Width1", 15, 0.06667, "Linear", nil)
					end

					v12[847] = function()
						fn(v11[9], "OutlineTransparency", 0, 0.01667, "Linear", nil)
						fn(v11[9], "FillTransparency", 1, 0.01667, "Linear", nil)

						if v4 then
							fn(
								v11[51],
								"CFrame",
								cFrame3 * CFrame.new(
									0,
									10000,
									0,
									1,
									-2.9016967560466852e-40,
									0,
									-8.705090268140056e-40,
									1,
									1.284651299361831e-19,
									0,
									4.282171213284388e-20,
									1
								),
								0.01667,
								"Linear",
								nil
							)
							fn(
								v11[52],
								"CFrame",
								cFrame4 * CFrame.new(0, 9996.818000078201, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
								0.01667,
								"Linear",
								nil
							)
						else
							fn(
								v11[51],
								"CFrame",
								cFrame3 * CFrame.new(
									0,
									0,
									0,
									1,
									-2.9016967560466852e-40,
									0,
									-8.705090268140056e-40,
									1,
									1.284651299361831e-19,
									0,
									4.282171213284388e-20,
									1
								),
								0.01667,
								"Linear",
								nil
							)
							fn(
								v11[52],
								"CFrame",
								cFrame4 * CFrame.new(0, -3.181999921798706, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
								0.01667,
								"Linear",
								nil
							)
						end
					end

					v12[848] = function()
						fn(v11[8], "TintColor", Color3.fromRGB(255, 255, 255), 0.1, "Linear", nil)
						fn(v11[8], "Brightness", 0, 0.1, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.01667, "Linear", nil)
						fn(v11[8], "Contrast", 1, 0.01667, "Linear", nil)
					end

					v12[849] = function()
						fn(v11[6], "FarIntensity", 0.22599999606609344, 0.7, "Bounce", "In")
						fn(v11[6], "InFocusRadius", 20.969999313354492, 0.7, "Bounce", "In")
						fn(v11[6], "FocusDistance", 12.899999618530273, 0.7, "Bounce", "In")
						fn(v11[6], "NearIntensity", 0, 0.7, "Bounce", "In")
						fn(v11[8], "Saturation", 0, 0.08333, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.08333, "Linear", nil)
					end

					v12[850] = function()
						fn(v11[44], "Width0", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[44], "Width1", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[45], "Width0", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[45], "Width1", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[46], "Width0", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[46], "Width1", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[47], "Width0", 0, 0.75, "Back", "In", 1.70158)
						fn(v11[47], "Width1", 0, 0.75, "Back", "In", 1.70158)
					end

					v12[854] = function()
						fn(v11[8], "Brightness", 0, 0.55, "Linear", nil)
						fn(v11[8], "Saturation", 0, 0.55, "Linear", nil)
						fn(v11[8], "Contrast", 0, 0.55, "Linear", nil)
					end

					v12[887] = function()
						fn(v11[8], "Brightness", 1.5, 0.35, "Linear", nil)
						fn(v11[8], "Saturation", -1, 0.35, "Linear", nil)
					end

					v12[891] = function()
						fn(v11[5], "ExposureCompensation", 3, 0.18333, "Linear", nil)
						fn(v11[6], "FarIntensity", 0, 0.25, "Linear", nil)
						fn(v11[6], "InFocusRadius", 0, 0.25, "Linear", nil)
						fn(v11[6], "FocusDistance", 0, 0.25, "Linear", nil)
						fn(v11[6], "NearIntensity", 0, 0.25, "Linear", nil)
					end

					v12[895] = function() end

					v12[902] = function() end

					v12[906] = function() end

					v12[908] = function()
						root.CFrame = cFrame
						fn(v11[51], "CFrame", cFrame, 0.05, "Linear", nil)
						fn(v11[4], "FieldOfView", 70, 0.05, "Back", "In", 1.70158)
						fn(v11[5], "ExposureCompensation", exposureCompensation, 0.05, "Linear", nil)
					end

					_G.updateMusic2(true)
					local total = 0
					local v21 = -1

					while not v7 do
						local v22 = total * 60 // 1
						local v23 = v22 - v21

						if v23 > 0 then
							for i = v21 + 1, v21 + v23 do
								local v24 = v12[i]

								if v24 then
									pcall(v24)
								end
							end

							v21 = v22
						end

						total += RunService.RenderStepped:Wait() * 1

						if v22 > 908 then
							break
						end
					end

					_G.updateMusic2(false)
					pcall(function()
						_G.InCutscene = nil
						character:SetAttribute("InControlCutscene", nil)
						character.Humanoid.HipHeight = hipHeight
						root.Anchored = false
					end)
					pcall(function()
						for _, v22 in pairs(v9) do
							v22:Destroy()
						end

						applyLightingFromJSON()
						model:Destroy()
						model = nil
						v9 = nil
					end)
					v11 = nil
				end)
				Util.Anims:Get(character, "CRUltimate_Player"):Play()
				Util.Anims:Get(clone2, "CRUltimate_LeftDagger"):Play()
				Util.Anims:Get(clone3, "CRUltimate_RightDagger"):Play()
				Util.Anims:Get(camReAdd, "CRUltimate_Camera"):Play()
				Util.Anims:Get(cubes, "CRUltimate_Cubes"):Play()
				local lastTime = tick()
				local currentCamera2 = workspace.CurrentCamera

				if v5 then
					currentCamera2.CameraType = Enum.CameraType.Scriptable
				end

				characterRemovingConnection = localPlayer.CharacterRemoving:Once(function()
					v3()
				end)
				renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
					if camReAdd.Parent ~= nil and not (tick() - lastTime > 15.133333333333333) then
						currentCamera2.CFrame = camReAdd.Cam.CFrame
						return
					end

					renderSteppedConnection:Disconnect()
					currentCamera2.CameraType = Enum.CameraType.Custom
					currentCamera2.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				end)
			end
		end)

		if not success then
			warn("wow nice it broke", result)

			if model then
				model:Destroy()
			end

			if v3 then
				task.spawn(v3)
			end
		end
	end
end