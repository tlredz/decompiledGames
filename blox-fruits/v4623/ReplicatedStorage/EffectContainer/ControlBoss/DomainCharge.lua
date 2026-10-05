local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local domain_Katsuo = FX:WaitForChild("ControlRework").Domain_Katsuo
local dagger = FX:WaitForChild("ControlRework").Domain:WaitForChild("Dagger")
local z_Katsuo = FX:WaitForChild("ControlRework").Z_Katsuo
local f_Katsuo = FX:WaitForChild("ControlRework").F_Katsuo
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local Textures = require(shared.Textures)
local Rocks = require(shared.Rocks)
local Dome = require(script.Parent.Domain.Dome)
require(game.ReplicatedStorage.Util.CameraShaker)
require(shared.HexsStormClass)
local UIPromptAnimation = require(shared:WaitForChild("UIPromptAnimation"))
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local currentCamera = workspace.CurrentCamera

local function EmitExplosion(cFrame, flag: boolean?)
	if not cFrame then
		return
	end

	local v = typeof(cFrame) == "RaycastResult"
	Util.CameraShaker:Shake("Fast")

	if v then
		cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + cFrame.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.5, 0) or cFrame
	end

	local clone = f_Katsuo.Explosion:Clone()
	clone:PivotTo(cFrame)
	clone:ScaleTo(clone:GetScale() * 0.55)
	clone.Parent = workspace._WorldOrigin

	if not v then
		clone.Main.GlowShape.Crater:Destroy()
	end

	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 6)
	local v2 = clone.Main.Size.X / 2
	local beams = clone.Main.Beams
	VisualHelper:Tween(beams, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Orientation = beams.Orientation + createVector(0, 550, 0)
	})

	for _, beam in beams:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.2 + math.random() * 0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	Util.Debris:AddItem(beams, 0.5)
	local clone2 = c_Katsuo.BallNeon:Clone()
	clone2.CFrame = cFrame
	clone2.Transparency = 0.94
	clone2.Color = Color3.fromRGB(89, 133, 255)
	clone2.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
	clone2.Parent = workspace._WorldOrigin
	VisualHelper:Tween(clone2, TweenInfo.new(0.14, Enum.EasingStyle.Sine), {
		Size = clone2.Size * 1.35,
		Transparency = 1
	})
	Util.Debris:AddItem(clone2, 0.14)
	local clone3 = c_Katsuo.BallNeon:Clone()
	clone3.CFrame = cFrame
	clone3.Transparency = 0.85
	clone3.Color = Color3.fromRGB(89, 133, 255)
	clone3.Size = createVector(1, 1, 1) * clone.Main.Size.Y
	clone3.Parent = workspace._WorldOrigin
	VisualHelper:Tween(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = clone3.Size * 1.6,
		Transparency = 1
	})
	Util.Debris:AddItem(clone3, 0.15)

	if flag then
		return
	end

	for _, child in clone.Main.Boom:GetChildren() do
		if child.Name == "Smoke" then
			child:Destroy()
		end
	end

	task.spawn(function()
		for _ = 1, 3 do
			local v3 = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v2 + 5, v2 + 25)
			)
			local rayCast = MathHelper:RayCast(
				v3.Position,
				v3.UpVector * -10,
				{ workspace.Map },
				Enum.RaycastFilterType.Include
			)

			if rayCast then
				local clone4 = f_Katsuo.BoltExplosion:Clone()
				clone4.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Position + rayCast.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0.5, 0)
				clone4.Parent = workspace._WorldOrigin
				VisualHelper:EmitAll(clone4)
				Util.Debris:AddItem(clone4, 1)
			end

			task.wait(0.125)
		end
	end)
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local root = player.Root
	local character = player.Character
	local player2 = player.Player

	if player.ShiftRoom then
		Util.Sound:Play("X_Reassembly_03", root.Position)
		EmitExplosion(root.CFrame)
	elseif player.Pulse then
		local dome = Dome({
			Stage = "FromPlayer",
			Player = localPlayer
		})

		if dome then
			dome:Pulse(Color3.fromRGB(170, 0, 255), 1, 0.16, 6, true)
		end
	elseif player.Aura then
		local auraActive = character:GetAttribute("AuraActive")

		if player.AURA_OFF then
			auraActive = player.AURA_OFF
		end

		character:SetAttribute("AuraActive", not auraActive)

		if auraActive then
			return
		end

		if root:FindFirstChild("AuraObject") then
			for _, descendant in root:GetDescendants() do
				if descendant.Name == "AuraObject" or descendant.Name == "AuraObject_" then
					descendant:Destroy()
				end
			end
		end

		local v = {}
		local total = 0
		local total2 = 0

		for _, part in domain_Katsuo.Aura:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local clone = part:Clone()
			clone.Name = "AuraObject"
			clone.Parent = character[part.Name]
			VisualHelper:SetEnableAll(clone, true)
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = clone.Parent
			weld.Parent = clone
			table.insert(v, clone)
		end

		for _, part in character:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			for _, child in domain_Katsuo.Aura.Particles:GetChildren() do
				local clone = child:Clone()
				clone.Name = "AuraObject_"
				clone.Enabled = true
				clone.Parent = part
				table.insert(v, clone)
			end
		end

		local ground = root.AuraObject.Ground
		ground.Parent = workspace.Terrain
		table.insert(v, ground)
		local flag = false
		local clone = domain_Katsuo.Aura.RockSmoke:Clone()
		clone.Parent = workspace.Terrain
		local v2 = Util.Sound:Play("CTRLFRT_CharacterIdle_Loop_01", root)
		local inCutscene = _G.InCutscene
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if inCutscene == _G.InCutscene then
				if _G.InCutscene then
					total = 0
					return
				end

				total2 += dt
				total += dt

				if not (character:GetAttribute("AuraActive") and character:IsDescendantOf(workspace)) then
					for _, emitter in v do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						else
							VisualHelper:SetEnableAll(emitter, false)
						end

						if v2 then
							Util.Sound:FadeOut(v2, 0.2)
						end

						emitter.Name = "#Ignore"
						Util.Debris:AddItem(emitter, 2)
					end

					heartbeatConnection:Disconnect()
					clone:Destroy()
				end

				local rayCast = MathHelper:RayCast(
					root.Position,
					Vector3.new(0, -root.Size.Y * 4),
					{ workspace.Map },
					Enum.RaycastFilterType.Include
				)

				if rayCast then
					ground.WorldPosition = rayCast.Position + createVector(0, 0.1, 0)

					if not flag then
						flag = true
						VisualHelper:SetEnableAll(ground, flag)
					end

					if total > 0.85 then
						total = 0
						local v3 = root.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
							0,
							0,
							math.random(10, 15)
						)
						local rayCast2 = MathHelper:RayCast(
							v3.Position,
							v3.UpVector * -5,
							{ workspace.Map },
							Enum.RaycastFilterType.Include
						)

						if not rayCast2 then
							return
						end

						clone.WorldPosition = rayCast2.Position
						VisualHelper:EmitAll(clone)
						local clone2 = domain_Katsuo.RockAura:Clone()
						clone2.Color = rayCast2.Instance.Color
						clone2.Material = rayCast2.Material
						clone2.Size *= 1.15 + math.random() * 0.85
						clone2.CFrame = CFrame.new(rayCast2.Position)
						clone2.Parent = workspace.Terrain
						local color = clone2.Color
						local material = clone2.Material
						local size = clone2.Size
						local cFrame = clone2.CFrame
						clone2.Size = createVector(0, 0, 0)
						VisualHelper:Tween(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
							Size = size * createVector(1.7, 0.3, 1.7),
							CFrame = clone2.CFrame * CFrame.new(0, size.Y * 0.3 / 2, 0)
						})
						task.wait(0.1)
						VisualHelper:Tween(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
							Size = size,
							CFrame = cFrame * CFrame.new(0, size.Y / 2, 0)
						})
						task.wait(0.225)
						local color2 = Color3.fromRGB(103, 144, 255)
						local neon = Enum.Material.Neon
						clone2.Color = color2
						clone2.Material = neon
						VisualHelper:Tween(clone2, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
							Size = size * createVector(1, 1, 1) * 1.55,
							CFrame = v3 * CFrame.new(0, size.Y * 1.55 / 2, 0)
						})
						task.wait(0.075)
						clone2.Color = color
						clone2.Material = material
						VisualHelper:Tween(clone2, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
							Size = size
						})
						VisualHelper:Tween(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
							CFrame = v3 * CFrame.new(0, math.random(2, 7), 0) * CFrame.Angles(
								math.random() * 3.141592653589793 / 2.5,
								math.random() * 3.141592653589793 / 2.5,
								math.random() * 3.141592653589793 / 2.5
							)
						})
						task.wait(0.35)
						VisualHelper:Tween(clone2, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							Position = clone2.Position + Vector3.new(
								math.random(-1, 1),
								math.random(3, 5),
								math.random(-1, 1)
							)
						})
						task.wait(2)
						clone2.CanCollide = true
						clone2.Anchored = false
						task.wait(0.3)
						VisualHelper:SetEnableAll(clone2, false)
						VisualHelper:Tween(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Size = createVector(0, 0, 0)
						})
						Util.Debris:AddItem(clone2, 0.5)
					end
				elseif flag then
					flag = false
					VisualHelper:SetEnableAll(ground, flag)
				end
			else
				for _, emitter in v do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = not _G.InCutscene
					else
						VisualHelper:SetEnableAll(emitter, not _G.InCutscene)
					end

					if _G.InCutscene then
						if v2 then
							Util.Sound:FadeOut(v2, 0.1)
							v2 = nil
						end
					elseif v2 == nil then
						v2 = Util.Sound:Play("CTRLFRT_CharacterIdle_Loop_01", root)
					end
				end

				inCutscene = _G.InCutscene
			end
		end)
	elseif player.Dagger then
		local dagger2 = player.Dagger

		if dagger2 == "Equip" then
			if player.Override then
				if player.CurrentMode == "Fist" then
					local model = Instance.new("Model")
					model.Name = character.Name .. "ControlFists"
					model.Parent = workspace._WorldOrigin

					local function HandleWinds(rootPart, flag: boolean?)
						local clone = z_Katsuo.Vault.DaggerWinds:Clone()
						clone.Orientation = Vector3.new(0, 0, flag and 0 or 180)

						if flag then
							rootPart = rootPart.RootPart or rootPart
						end

						clone.Parent = rootPart
						VisualHelper:Tween(clone, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
							Orientation = clone.Orientation + createVector(0, 1750, 0)
						})

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							VisualHelper:Tween(
								beam,
								TweenInfo.new(0.55 + math.random(3) * 0.055, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						Util.Debris:AddItem(clone, 1.5)
					end

					for k, C0 in {
						Left = CFrame.Angles(3.141592653589793, 0, 0),
						Right = CFrame.Angles(0, 0, -3.141592653589793)
					} do
						local clone = z_Katsuo.HandsHandle:Clone()
						clone.Name = `{k}HandleMode`
						clone.Weld.C0 = C0
						clone.Weld.Part1 = character[`{k}Hand`]
						clone.Parent = model
						HandleWinds(clone)
						VisualHelper:EmitAll(clone)

						for _, child in z_Katsuo.ArmGrids:GetChildren() do
							local clone2 = child:Clone()
							clone2.Name = "ArmGrid"
							clone2.Parent = model
							local weld = Instance.new("Weld")
							weld.Part0 = clone2
							weld.Part1 = character[`{k}{child.Name}`]
							weld.Parent = clone2
						end
					end

					return
				elseif workspace._WorldOrigin:FindFirstChild("ControlDaggers" .. character.Name) then
					return
				end
			elseif player.FromRoom or not player.CurrentMode or player.CurrentMode ~= "Dagger" then
				task.wait(0.1)
			else
				local cRFistToDagger = Util.Anims:Get(character, "CRFistToDagger")
				cRFistToDagger.Priority = Enum.AnimationPriority.Action4
				cRFistToDagger.Looped = false
				cRFistToDagger:Play()
				Util.Sound:Play("C_Daggers_Appear_Transformed_01", root)
				task.wait(0.45)
				local child = workspace._WorldOrigin:FindFirstChild(character.Name .. "ControlFists")

				if child then
					child:Destroy()
				end
			end

			local directions = player.Directions or { "Left", "Right" }
			local model = Instance.new("Model")
			model.Name = "ControlDaggers" .. character.Name
			model.Parent = workspace._WorldOrigin
			local upperTorso = root.Parent:FindFirstChild("UpperTorso")

			if upperTorso then
				upperTorso:GetPropertyChangedSignal("Transparency"):Connect(function()
					for _, child in model:GetChildren() do
						for _, part in child:GetChildren() do
							if part:IsA("BasePart") and part.Name ~= "RootPart" then
								part.Transparency = upperTorso.Transparency >= 1 and 1 or 0
							end
						end
					end
				end)
			end

			for _, direction in directions do
				local v = character[`{direction}Hand`]
				local child = domain_Katsuo:FindFirstChild((`Dagger{direction}`))
				local clone = dagger:Clone()
				clone.Name = `{direction}Dagger`
				clone.RootPart.Motor6D:Destroy()
				local clone2 = child.RootPart.RootPart:Clone()
				clone2.Part1 = clone.RootPart
				clone2.Part0 = v
				clone2.Parent = v
				clone.Destroying:Connect(function()
					clone2:Destroy()
				end)
				clone.Parent = model
				local cRDaggerAnim = Util.Anims:Get(clone, "CRDaggerAnim")
				cRDaggerAnim.Priority = Enum.AnimationPriority.Idle
				cRDaggerAnim.Looped = true
				cRDaggerAnim:Play()
				local highlight = Instance.new("Highlight")
				highlight.Adornee = clone
				highlight.FillTransparency = 0
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.fromRGB(14, 27, 47)
				highlight.Parent = clone
				VisualHelper:Tween(highlight, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
					FillTransparency = 1
				})
				task.spawn(function()
					local clone3 = domain_Katsuo.Vault.DaggerWinds:Clone()
					clone3.Parent = clone.RootPart
					VisualHelper:Tween(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
						Orientation = clone3.Orientation + createVector(0, 1750, 0)
					})

					for i, beam in clone3:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Enabled = true
						VisualHelper:Tween(beam, TweenInfo.new(0.55 + math.random(3) * 0.055, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end

					Util.Debris:AddItem(clone3, 1.5)
					VisualHelper:EmitAll(clone.RootPart)
					task.wait(0.7)
					highlight:Destroy()
				end)
			end
		elseif dagger2 == "Unequip" then
			local child = workspace._WorldOrigin:FindFirstChild("ControlDaggers" .. character.Name)
			local child2 = player.Override and not player.CurrentMode and workspace._WorldOrigin:FindFirstChild(character.Name .. "ControlFists")

			if child2 then
				child2:Destroy()
			end

			if child then
				child.Name = "Destroying"
				local v = player.Override and player.CurrentMode == "Fist" and true or false

				if player.CurrentMode and player.CurrentMode == "Fist" and not player.Override then
					local cRDaggerToFist = Util.Anims:Get(character, "CRDaggerToFist")
					cRDaggerToFist.Priority = Enum.AnimationPriority.Action4
					cRDaggerToFist.Looped = false
					cRDaggerToFist:Play()
					Util.Sound:Play("C_Daggers_Disappear_Transformed_01", root)
					task.wait(0.4666666666666667)
					Util.Sound:Play("C_HandsMode_Switch_01", root)
					v = true
				else
					local child3 = workspace._WorldOrigin:FindFirstChild(character.Name .. "ControlFists")

					if child3 then
						child3:Destroy()
					end
				end

				for i = 1, 2 do
					local child3 = child:FindFirstChild((`{i == 1 and "Left" or "Right"}Dagger`))

					if not child3 then
						continue
					end

					for _, part in pairs(child3:GetChildren()) do
						if part:IsA("BasePart") or part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end

					local v2 = child3
					task.spawn(function()
						local clone = domain_Katsuo.Vault.DaggerWinds:Clone()
						clone.Parent = v2.RootPart

						for i2, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							VisualHelper:Tween(
								beam,
								TweenInfo.new(0.55 + math.random(3) * 0.055, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						Util.Debris:AddItem(clone, 1.5)
						VisualHelper:EmitAll(v2.RootPart)
					end)
				end

				if v then
					local model = Instance.new("Model")
					model.Name = character.Name .. "ControlFists"
					model.Parent = workspace._WorldOrigin

					local function HandleWinds(rootPart, flag: boolean?)
						local clone = z_Katsuo.Vault.DaggerWinds:Clone()
						clone.Orientation = Vector3.new(0, 0, flag and 0 or 180)

						if flag then
							rootPart = rootPart.RootPart or rootPart
						end

						clone.Parent = rootPart
						VisualHelper:Tween(clone, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
							Orientation = clone.Orientation + createVector(0, 1750, 0)
						})

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							VisualHelper:Tween(
								beam,
								TweenInfo.new(0.55 + math.random(3) * 0.055, Enum.EasingStyle.Sine),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
						end

						Util.Debris:AddItem(clone, 1.5)
					end

					for k, C0 in {
						Left = CFrame.Angles(3.141592653589793, 0, 0),
						Right = CFrame.Angles(0, 0, -3.141592653589793)
					} do
						local clone = z_Katsuo.HandsHandle:Clone()
						clone.Name = `{k}HandleMode`
						clone.Weld.C0 = C0
						clone.Weld.Part1 = character[`{k}Hand`]
						clone.Parent = model
						HandleWinds(clone)
						VisualHelper:EmitAll(clone)

						for _, child3 in z_Katsuo.ArmGrids:GetChildren() do
							local clone2 = child3:Clone()
							clone2.Name = "ArmGrid"
							clone2.Parent = model
							local weld = Instance.new("Weld")
							weld.Part0 = clone2
							weld.Part1 = character[`{k}{child3.Name}`]
							weld.Parent = clone2
						end
					end
				end

				task.wait(2)
				child:Destroy()
			end
		end
	else
		local duration = player.Duration

		if not duration then
			return
		end

		local random = Random.new()
		local lastTime = tick()
		local model = Instance.new("Model", workspace._WorldOrigin)
		Util.Debris:AddItem(model, 15)
		local model2 = Instance.new("Model", model)
		Util.Sound:Play("CTRLFRT_Z_Activate_CloseToPlayer_01", root.Position)
		local cRRoomOpeningStart = Util.Anims:Get(character, "CRRoomOpeningStart")
		cRRoomOpeningStart.Looped = false
		cRRoomOpeningStart.Priority = Enum.AnimationPriority.Action3
		cRRoomOpeningStart:Play()
		local cRRoomOpeningLoop = Util.Anims:Get(character, "CRRoomOpeningLoop")
		cRRoomOpeningLoop.Looped = true
		cRRoomOpeningLoop.Priority = Enum.AnimationPriority.Action
		cRRoomOpeningLoop:Play()
		local clone = domain_Katsuo.EndFloorStarCollide:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 100000, 0)
		clone.Parent = model2
		local clone2 = domain_Katsuo.DarkNeonRotation:Clone()
		clone2:ScaleTo(clone2:GetScale() + 0.8)
		clone2.Main.Weld.Part0 = root
		clone2.Parent = model2
		local clone3 = domain_Katsuo.DoubleNeonEye:Clone()
		clone3.Weld.Part0 = character.Head
		clone3.Name = VisualHelper:BuildUniqueName(character, "Double-Neon-Eye")
		clone3.Parent = model2
		local clone4 = domain_Katsuo.ShaderScreen:Clone()
		clone4.Image.ImageTransparency = 1
		clone4.Name = VisualHelper:BuildUniqueName(character, "Shader-Screen")
		local parent

		if player.Player == game.Players.LocalPlayer then
			parent = player.Player:FindFirstChild("PlayerGui") or model
		else
			parent = model
		end

		clone4.Parent = parent
		VisualHelper:Tween(clone4.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.8
		})
		VisualHelper:SetEnableAll(clone3, true)
		local main = clone.BeamAura.Beams.Main
		main.Enabled = true
		local thread = task.spawn(function()
			while true do
				for _, texture in Textures.Aura do
					main.Texture = texture
					task.wait(0.016666666666666666)
				end
			end
		end)
		local clone5 = domain_Katsuo.StarCollide:Clone()
		clone5.Weld.Part0 = root
		clone5.Parent = model2
		local clone6 = domain_Katsuo.FloorStarCollide:Clone()
		clone6.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		clone6.Parent = model2
		local groundRayCast = MathHelper:GroundRayCast(character)

		if not groundRayCast then
			clone6.Smokes:Destroy()
			clone6.SmokesToggle:Destroy()
			clone.Smokes:Destroy()
		end

		UIPromptAnimation(player2)
		VisualHelper:EmitAll(clone5)
		Util.Debris:AddItem(clone5, 2)
		VisualHelper:EmitAll(clone6)
		VisualHelper:SetEnableAll(clone6.Init.Toggle, true)
		VisualHelper:SetEnableAll(clone5, true, true)

		if groundRayCast then
			VisualHelper:SetEnableAll(clone6.SmokesToggle, true)
		end

		local circleBeam = clone6.CircleBeam
		VisualHelper:Tween(circleBeam, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = circleBeam.Position + createVector(0, 5, 0)
		})

		for _, child in circleBeam.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = 0,
				Width1 = 0
			})
		end

		local trails = clone6.Trails
		VisualHelper:Tween(trails, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
			Orientation = trails.Orientation + createVector(0, 550, 0)
		})

		for _, child in trails:GetChildren() do
			VisualHelper:Tween(child, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
				Position = child.Position * 0.3
			})
		end

		VisualHelper:SetEnableAll(clone6.Storm, true)
		VisualHelper:EmitAll(clone6.Storm)

		for _, child in clone6.Storm:GetChildren() do
			VisualHelper:Tween(
				child,
				TweenInfo.new(random:NextNumber(2, 3.5), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = child.Orientation + Vector3.new(0, 360 * (child.Name == "Mid" and -1 or 1))
				}
			)
		end

		local circle = clone6.Circle
		circle.Main.ManualWeld:Destroy()
		circle.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(circle, 5)
		VisualHelper:SetEnableAll(circle.Main.Init.Toggle, true)
		VisualHelper:TweenScale(circle, TweenInfo.new(1.5, Enum.EasingStyle.Sine), circle:GetScale() + 0.1)

		for _, child in circle.Main.CircleWinds.Beams:GetChildren() do
			child.Enabled = true
			local brightness = child.Brightness
			child.Brightness = 0
			VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
			local v2 = child
			task.delay(0.2, function()
				VisualHelper:Tween(v2, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			end)

			if child.Name ~= "Beam0" then
				VisualHelper:Tween(child, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Width0 = child.Width0 / 2,
					Width1 = child.Width0 / 2
				})
			end
		end

		local superCircle = clone6.SuperCircle
		superCircle.Main.ManualWeld:Destroy()
		superCircle.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(superCircle, 5)
		VisualHelper:TweenScale(superCircle, TweenInfo.new(0.3, Enum.EasingStyle.Sine), superCircle:GetScale() + 1.2)

		for _, child in superCircle.Main.CircleWinds.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Util.Debris:AddItem(clone6, 4)
		local stormBeam = clone6.StormBeam
		stormBeam:PivotTo(clone6.CFrame)
		local scale = stormBeam:GetScale()
		stormBeam:ScaleTo(scale - 0.15)
		VisualHelper:TweenScale(stormBeam, TweenInfo.new(0.65, Enum.EasingStyle.Sine), scale + 0.05)

		for _, child in stormBeam.Main:GetChildren() do
			local beam = child.Beam
			beam.Brightness *= 2.75
			beam.TextureSpeed *= -1
			beam.Enabled = true
			local v2 = (child:GetAttribute("Time") or 0.3) + 0.4
			local v3 = createVector(0, 1, 0) * ((child:GetAttribute("Orientation") or 0) * -1.65)
			VisualHelper:Tween(child, TweenInfo.new(v2 + 0.1, Enum.EasingStyle.Sine), {
				Orientation = child.Orientation + v3
			})
			VisualHelper:Tween(beam, TweenInfo.new(v2, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		task.wait(0.3)
		local clone7 = domain_Katsuo.EndStarCollide:Clone()
		clone7.Weld.Part0 = root
		clone7.Parent = model2
		VisualHelper:SetEnableAll(clone7, true, true)
		VisualHelper:SetEnableAll(clone7.Init.Sinal, true)
		VisualHelper:EmitAll(clone7.Init)
		local clone8 = domain_Katsuo.CameraEffects:Clone()
		clone8.Name = "{" .. player.Player.Name .. "}-{Camera-Effects}"
		clone8.Parent = currentCamera

		if player.Player == game.Players.LocalPlayer then
			VisualHelper:SetEnableAll(clone8, true)
			VisualHelper:EmitAll(clone8)
		else
			VisualHelper:SetEnableAll(clone8, false)
		end

		local engaged = clone8.UI.Engaged
		engaged.Particle.Enabled = false
		local loading = clone8.UI.Loading
		task.delay(0.85, function()
			if player.Player == game.Players.LocalPlayer then
				engaged.Particle:Emit(1)
				engaged.Particle.Enabled = true
				loading:Destroy()
			end
		end)
		local clone9 = domain_Katsuo.BoltExplosion:Clone()
		clone9.Parent = model
		local v2 = nil
		local total = 0
		local total2 = 0
		local children = domain_Katsuo.Rocks:GetChildren()
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt
			clone8.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.25) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone.BigTrailBolt.Orientation += Vector3.new(0, 650 * dt)

			if v2 or total < 0.1 then
				return
			end

			total = 0
			local v3 = CFrame.new(root.Position) * CFrame.Angles(0, math.rad((math.random(360))), 0) * CFrame.new(
				0,
				0,
				-math.random(15, 22)
			)
			local rayCast = MathHelper:RayCast(v3.Position, v3.UpVector * -10, { character, workspace._WorldOrigin })

			if rayCast then
				local clone10 = children[math.random(#children)]:Clone()
				clone10.Position = rayCast.Position
				clone10.Orientation = Vector3.new(math.random(360), math.random(360), math.random(360))
				clone10.Color = rayCast.Instance.Color
				clone10.Size *= math.random(1, 2)
				clone10.Material = rayCast.Instance.Material
				clone10.Parent = model
				rocks:ApplyCollision(clone10, nil, true)
				local clone11 = domain_Katsuo.Vault.RockBack:Clone()
				clone11.Parent = clone10
				VisualHelper:EmitAll(clone11)
				local clone12 = domain_Katsuo.RockSmoke:Clone()
				clone12.CFrame = CFrame.lookAt(rayCast.Position, rayCast.Normal + rayCast.Position) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				clone12.Parent = model

				for _, child in clone12.Main:GetChildren() do
					VisualHelper:Emit(child, ColorSequence.new(clone10.Color))
				end

				Util.Debris:AddItem(clone12, 1.5)
				local v4 = 0.8 + math.random(5) * 0.1
				VisualHelper:Tween(clone10, TweenInfo.new(v4), {
					Transparency = 0.5,
					Position = clone10.Position + Vector3.new(0, math.random(5, 18)),
					Size = createVector(0, 0, 0),
					Orientation = clone10.Orientation + Vector3.new(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
				})
				Util.Debris:AddItem(clone10, v4)
				Rocks:AirRocks(
					clone10.CFrame,
					createVector(2, 0.2, 2),
					false,
					60,
					0.2,
					0.3,
					2,
					clone10.Color,
					clone10.Material
				)
				Rocks:AirRocks(
					clone10.CFrame,
					createVector(1, 1, 1) * math.random(2),
					false,
					math.random(35, 75),
					0.1,
					0.2,
					15,
					clone10.Color,
					clone10.Material
				)
			end

			total2 += 55
			local v4 = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(total2 + math.random(-90, 90)), 0) * CFrame.new(
				0,
				0,
				-math.random(20, 45)
			)
			local rayCast2 = MathHelper:RayCast(v4.Position, v4.UpVector * -10, { character, workspace._WorldOrigin })

			if not rayCast2 then
				return
			end

			clone9.CFrame = CFrame.new(rayCast2.Position + createVector(0, 0.05, 0))
			VisualHelper:EmitAll(clone9)
		end)
		task.wait(0.1)

		if groundRayCast then
			VisualHelper:SetEnableAll(clone6.SmokesToggle, false)
		end

		VisualHelper:SetEnableAll(clone5, false, true)
		VisualHelper:SetEnableAll(clone6.Storm, false)
		VisualHelper:SetEnableAll(circle.Main.Init.Toggle, false)
		VisualHelper:SetEnableAll(clone6.Init.Toggle, false)
		clone5.Init.Sinal:Destroy()
		local clone10 = domain_Katsuo.BallNeon:Clone()
		clone10.CFrame = root.CFrame
		clone10.Transparency = 0.9
		clone10.Color = Color3.fromRGB(35, 94, 255)
		clone10.Size = createVector(1.5, 1.5, 1.5)
		clone10.Parent = model
		VisualHelper:Tween(clone10, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
			Size = createVector(12, 12, 12),
			Transparency = 1
		})
		Util.Debris:AddItem(clone10, 0.18)
		local clone11 = domain_Katsuo.FloorSpawn:Clone()
		clone11.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		clone11.Parent = model

		if not MathHelper:GroundRayCast(character) then
			clone11.SmokeRotation:Destroy()
		end

		Util.Debris:AddItem(clone11, 2.15)
		VisualHelper:Tween(clone11.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Orientation = clone11.CircleWinds.Orientation + createVector(0, 180, 0)
		})
		VisualHelper:EmitAll(clone11)
		clone11.PointLight.Enabled = true
		VisualHelper:Tween(clone11.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 0
		})

		for _, child in clone11.CircleWinds:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Util.Debris:AddItem(clone2, 2)
		clone2.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

		for i, child in clone2.Main.Layers:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			local v3 = child.Name == "NeonLayer"
			local v4 = v3 and random:NextNumber(0.4, 0.6) or random:NextNumber(0.18, 0.3)
			VisualHelper:Tween(child, TweenInfo.new(v4, Enum.EasingStyle.Linear), {
				Orientation = child.Orientation + Vector3.new(0, 700 * (i % 2 == 0 and -1 or 1))
			})

			if v3 then
				VisualHelper:Tween(beam, TweenInfo.new(v4, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			else
				VisualHelper:Tween(beam, TweenInfo.new(v4, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end
		end

		clone.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		VisualHelper:EmitAll(clone)
		VisualHelper:SetEnableAll(clone.Init.Toggle, true)
		VisualHelper:Tween(clone.Ball.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(clone.Ball.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Scale = clone.Ball.Mesh.Scale * 1.3
		})
		clone.StormBall.CFrame = root.CFrame * CFrame.new(0, 5, 0)
		VisualHelper:Tween(clone.StormBall, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			CFrame = clone.StormBall.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
		})
		VisualHelper:Tween(clone.StormBall.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(clone.StormBall.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Scale = clone.StormBall.Mesh.Scale * 1.3
		})
		local circleBeam2 = clone.CircleBeam
		VisualHelper:Tween(circleBeam2, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Position = circleBeam2.Position + createVector(0, 5, 0)
		})

		for _, child in circleBeam2.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = 0,
				Width1 = 0
			})
		end

		for _, child in clone.Beams:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			local brightness = beam.Brightness * 1.15
			beam.Brightness = 0
			VisualHelper:Tween(beam, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
			VisualHelper:Tween(
				child,
				TweenInfo.new(random:NextNumber(0.2, 0.4), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = child.Orientation + Vector3.new(0, 360 * math.sign(beam.TextureSpeed))
				}
			)
		end

		local circleBeam22 = clone.CircleBeam2
		VisualHelper:Tween(circleBeam22, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
			Position = circleBeam22.Position + createVector(0, 17, 0)
		})

		for _, child in circleBeam22.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = 0,
				Width1 = 0
			})
		end

		local trails2 = clone.Trails
		VisualHelper:Tween(trails2, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
			Orientation = trails2.Orientation + createVector(0, 550, 0)
		})

		for _, child in trails2:GetChildren() do
			VisualHelper:Tween(child, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
				Position = child.Position * 0.45
			})
		end

		local thread2 = task.spawn(function()
			while true do
				for i = -1, 1, 2 do
					local clone12 = clone.TrailBoltTemplate:Clone()
					clone12.Name = "Ignore"
					clone12.Orientation = createVector(0, 360, 0) * -i
					clone12.Parent = clone
					local point = clone12.Point
					point.Trail.Enabled = true
					VisualHelper:Tween(point, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						Position = point.Position * 1.3
					})
					VisualHelper:Tween(clone12, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						Orientation = clone12.Orientation + Vector3.new(0, i * 500),
						Position = clone12.Position + Vector3.new(0, math.random(5, 15))
					})
					Util.Debris:AddItem(clone12, 1)
					task.wait(0.15)
				end

				local clone12 = clone.TrailBoltTemplate:Clone()
				clone12.Name = "Ignore"
				local point = clone12.Point
				local trail = point.Trail
				point.Position *= 1.5
				point.Point1.Position = createVector(0, 5, 0)
				trail.Lifetime *= 0.3
				trail.Brightness *= 0.5
				trail.Enabled = true
				clone12.Parent = clone
				VisualHelper:Tween(point, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Position = point.Position * 0.5
				})
				VisualHelper:Tween(clone12, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					Orientation = clone12.Orientation + createVector(0, 1200, 0),
					Position = clone12.Position + Vector3.new(0, math.random(15, 20))
				})
				Util.Debris:AddItem(clone12, 1)
			end
		end)
		task.spawn(function()
			for _ = 1, 10 do
				local number = random:NextNumber(0.2, 0.5)
				local worldCFrame = clone7.Init.WorldCFrame
				local clone12 = domain_Katsuo.Vault.TrailSpecs:Clone()
				clone12.Parent = workspace.Terrain
				clone12.CFrame = worldCFrame
				Util.Debris:AddItem(clone12, number + 0.5)
				local position = worldCFrame.Position
				local v3 = CFrame.new(worldCFrame.Position) * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					0,
					(math.rad((math.random(-90, 90))))
				) * CFrame.new(0, math.random(15, 35), 0).Position
				local magnitude = (position - v3).Magnitude
				local cframe = CFrame.lookAt(position, v3)
				local v8 = cframe * CFrame.new(math.random(-35, 35), math.random(-35, 35), -magnitude * 0.25).Position
				local v9 = cframe * CFrame.new(math.random(-35, 35), math.random(-35, 35), -magnitude * 0.75).Position
				VisualHelper:TweenNumberValue(1, TweenInfo.new(number, Enum.EasingStyle.Sine), function(p: number)
					clone12.Position = MathHelper:CubicBezier(p, position, v8, v9, v3)
				end)
				task.wait(0.03)
			end
		end)
		VisualHelper:SetEnableAll(clone.Storm, true)
		VisualHelper:EmitAll(clone.Storm)

		for _, child in clone.Storm:GetChildren() do
			VisualHelper:Tween(
				child,
				TweenInfo.new(random:NextNumber(2, 3.5), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
				{
					Orientation = child.Orientation + Vector3.new(0, 360 * (child.Name == "Mid" and -1 or 1))
				}
			)
		end

		local circle2 = clone.Circle
		circle2.Main.ManualWeld:Destroy()
		circle2.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(circle2, 5)
		VisualHelper:TweenScale(circle2, TweenInfo.new(1.5, Enum.EasingStyle.Sine), circle2:GetScale() + 1.1)
		VisualHelper:SetEnableAll(circle2.Main.Init.Toggle, true)
		task.delay(0.5, function()
			VisualHelper:SetEnableAll(circle2.Main.Init.Toggle, false)
		end)

		for _, child in circle2.Main.CircleWinds.Beams:GetChildren() do
			child.Enabled = true
			local brightness = child.Brightness
			child.Brightness = 0
			VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
			local v3 = child
			task.delay(0.2, function()
				VisualHelper:Tween(v3, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			end)

			if child.Name ~= "Beam0" then
				VisualHelper:Tween(child, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Width0 = child.Width0 / 2,
					Width1 = child.Width0 / 2
				})
			end
		end

		local superCircle2 = clone.SuperCircle
		superCircle2.Main.ManualWeld:Destroy()
		superCircle2.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(superCircle2, 5)
		VisualHelper:TweenScale(superCircle2, TweenInfo.new(0.3, Enum.EasingStyle.Sine), superCircle2:GetScale() + 1.2)

		for _, child in superCircle2.Main.CircleWinds.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(child, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		local endCircle = clone.EndCircle
		endCircle.Main.ManualWeld:Destroy()
		endCircle.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(endCircle, 5)
		VisualHelper:TweenScale(endCircle, TweenInfo.new(0.6, Enum.EasingStyle.Sine), endCircle:GetScale() + 4.7)

		for _, child in endCircle.Main.CircleWinds.Beams:GetChildren() do
			child.Enabled = true
			VisualHelper:Tween(
				child,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.3),
				{
					Width0 = 0,
					Width1 = 0,
					Brightness = 0
				}
			)
		end

		Util.Debris:AddItem(clone, 4)
		local stormBeam2 = clone.StormBeam
		stormBeam2:PivotTo(clone.CFrame)
		local scale2 = stormBeam2:GetScale()
		stormBeam2:ScaleTo(scale2 - 0.15)
		VisualHelper:TweenScale(stormBeam2, TweenInfo.new(0.65, Enum.EasingStyle.Sine), scale2 + 0.05)

		for _, child in stormBeam2.Main:GetChildren() do
			local beam = child.Beam
			beam.Brightness *= 2.75
			beam.TextureSpeed *= -1
			beam.Enabled = true
			local v3 = (child:GetAttribute("Time") or 0.3) + 0.4
			local v4 = createVector(0, 1, 0) * ((child:GetAttribute("Orientation") or 0) * -1.65)
			VisualHelper:Tween(child, TweenInfo.new(v3 + 0.1, Enum.EasingStyle.Sine), {
				Orientation = child.Orientation + v4
			})
			VisualHelper:Tween(beam, TweenInfo.new(v3, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		Util.Debris:AddItem(clone, 4)

		for _, attachment in clone.StormBeamPattern.Main:GetChildren() do
			if not attachment:IsA("Attachment") then
				continue
			end

			local beam = attachment.Beam
			beam.Brightness *= 0.5
			beam.Enabled = true
			VisualHelper:Tween(attachment, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Orientation = attachment.Orientation + createVector(0, 45, 0)
			})
			VisualHelper:Tween(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Width0 = beam.Width0 * 0.5,
				Width1 = beam.Width1 * 0.5
			})
		end

		for _, child in clone.BeamAura.Beams:GetChildren() do
			child.Enabled = true
			local brightness = child.Brightness
			child.Brightness = 0
			VisualHelper:Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Brightness = brightness
			})
			VisualHelper:Tween(child, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Width0 = child.Width0 * 1.15,
				Width1 = child.Width1 * 1.15
			})
		end

		task.spawn(function()
			local clone12 = domain_Katsuo.Vault.BoltCollide:Clone()
			clone12.Parent = workspace.Terrain

			for i = 1, 25 do
				local v3 = CFrame.new(root.Position - createVector(0, 2.8, 0)) * CFrame.Angles(
					0,
					math.rad(i * 25 + math.random(-60, 60)),
					0
				)
				local worldPosition = v3 * CFrame.new(0, 0, 10).Position
				local v5 = v3 * CFrame.new(0, 0, 20 + math.random(2, 10)).Position
				local rayCast = MathHelper:RayCast(v5, CFrame.new(v5).UpVector * -5, { character, model })

				if not rayCast then
					continue
				end

				local position = rayCast.Position
				local magnitude = (worldPosition - position).Magnitude
				local cframe = CFrame.lookAt(worldPosition, position)
				local v6 = cframe * CFrame.new(
					math.random(-4, 4),
					math.random(2, 8) + (i % 4 == 0 and 15 or 0),
					-magnitude * 0.25
				).Position
				local v7 = cframe * CFrame.new(math.random(-4, 4), math.random(2, 8), -magnitude * 0.75).Position
				local clone13 = domain_Katsuo.Vault.NeonTrail:Clone()
				clone13.Parent = workspace.Terrain
				clone13.WorldPosition = worldPosition
				Util.Debris:AddItem(clone13, 3)
				local worldPosition2 = worldPosition
				local v12 = i
				local v13 = rayCast
				task.spawn(function()
					local v14 = math.random(8, 20)

					for i2 = 1, v14 do
						local cubicBezier = MathHelper:CubicBezier(i2 / v14, worldPosition2, v6, v7, position)
						VisualHelper:Tween(clone13, TweenInfo.new(0.01, Enum.EasingStyle.Sine), {
							WorldPosition = cubicBezier + cubicBezier.Unit * (1 + math.noise(
								cubicBezier.X * 0.1,
								cubicBezier.Z * 0.1,
								v12 * 0.1
							)) + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 0.6
						})
						RunService.PreSimulation:Wait()

						if not (i2 == v14 and v12 % 2 == 0) then
							continue
						end

						local clone14 = domain_Katsuo.SingleSpark:Clone()
						clone14.Main.Trail.Lifetime = 0.05
						clone14.CFrame = CFrame.new(cubicBezier + createVector(0, 0.3, 0)) * CFrame.Angles(
							math.rad((random:NextNumber(-45, 45))),
							0,
							(math.rad((random:NextNumber(-45, 45))))
						)
						clone14.Parent = model
						clone14.AssemblyLinearVelocity = clone14.CFrame.UpVector * -random:NextNumber(25, 45)
						clone14.AssemblyAngularVelocity = Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						VisualHelper:EmitAll(clone14.Main)
						VisualHelper:Tween(clone14.Main.PointLight, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {
							Brightness = 0
						})
						Util.Debris:AddItem(clone14, 3)
						clone12.CFrame = CFrame.lookAt(v13.Position, v13.Position + v13.Normal) * CFrame.new(
							0,
							0,
							-0.05
						)
						VisualHelper:EmitAll(clone12)
					end
				end)
				task.wait(0.035)
			end

			Util.Debris:AddItem(clone12, 2)
		end)
		task.spawn(function()
			local cFrame = root.CFrame

			for _ = 1, 3 do
				local clone12 = domain_Katsuo.CosmicWaves:Clone()
				clone12:PivotTo(cFrame)
				clone12.Parent = model
				VisualHelper:TweenScale(clone12, TweenInfo.new(0.3, Enum.EasingStyle.Sine), clone12:GetScale() + 0.6)
				VisualHelper:Tween(clone12.PrimaryPart, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
					CFrame = clone12:GetPivot() * CFrame.new(0, 20, 0)
				})

				for _, child in clone12.Main.CircleWinds.Beams:GetChildren() do
					child.Enabled = true
					VisualHelper:Tween(child, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Width0 = 3,
						Width1 = 3,
						Brightness = 0
					})
				end

				Util.Debris:AddItem(clone12, 0.7)
				local clone13 = domain_Katsuo.CosmicWaves:Clone()
				clone13:PivotTo(cFrame * CFrame.new(0, -3, 0))
				clone13:ScaleTo(clone13:GetScale() + 1.45)
				clone13.Parent = model
				VisualHelper:Tween(clone13.PrimaryPart, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					CFrame = clone13:GetPivot() * CFrame.new(0, 7, 0)
				})

				for _, child in clone13.Main.CircleWinds.Beams:GetChildren() do
					child.Enabled = true
					child.Width0 /= 2
					child.Width1 /= 2
					VisualHelper:Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						Width0 = 0,
						Width1 = 0,
						Brightness = 0
					})
				end

				Util.Debris:AddItem(clone13, 0.5)
				task.wait(0.3)
			end
		end)

		while tick() - lastTime < duration do
			task.wait(0.03333333333333333)
		end

		if cRRoomOpeningLoop then
			cRRoomOpeningLoop:Stop()
		end

		local cRRoomOpeningEnd = Util.Anims:Get(character, "CRRoomOpeningEnd")
		cRRoomOpeningEnd.Looped = false
		cRRoomOpeningEnd.Priority = Enum.AnimationPriority.Action4
		cRRoomOpeningEnd:Play()
		Util.Debris:AddItem(clone9, 3)
		VisualHelper:Tween(clone.BigTrailBolt.Point, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = createVector(0, 0, 0)
		})
		v2 = true
		VisualHelper:SetEnableAll(clone8.UI, false)
		task.delay(1, function()
			task.cancel(thread)
		end)

		for _, child in clone.BeamAura.Beams:GetChildren() do
			if child.Name == "Back" then
				VisualHelper:Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			else
				VisualHelper:Tween(child, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			end
		end

		task.cancel(thread2)

		for _, child in clone.Beams:GetChildren() do
			VisualHelper:Tween(child.Beam, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end

		clone7.Init.Sinal:Destroy()
		VisualHelper:SetEnableAll(clone7, false, true)
		Util.Debris:AddItem(clone7, 3)
		VisualHelper:SetEnableAll(clone.Init.Toggle, false)
		VisualHelper:SetEnableAll(clone.Storm, false)
		local v3 = VisualHelper:FindByUniqueName(character, "Shader-Screen", player2:FindFirstChild("PlayerGui"))

		if v3 then
			v3.Name = "Ignore"
			VisualHelper:Tween(v3.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				ImageTransparency = 1
			})
			Util.Debris:AddItem(v3, 0.5)
		end

		local v4 = VisualHelper:FindByUniqueName(character, "Double-Neon-Eye", model2)

		if v4 then
			v4.Name = "Ignore"
			VisualHelper:SetEnableAll(v4, false)
			Util.Debris:AddItem(v4, 1)
		end

		for _, child in domain_Katsuo.CameraComplement:GetChildren() do
			local clone_2 = child:Clone()
			clone_2.Parent = clone8
		end

		VisualHelper:SetEnableAll(clone8, false)
		task.wait(1)
		renderSteppedConnection:Disconnect()
		clone8:Destroy()
	end
end