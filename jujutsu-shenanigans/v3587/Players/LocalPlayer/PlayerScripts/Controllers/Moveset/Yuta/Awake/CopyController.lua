local Knit = require(game.ReplicatedStorage.Knit.Knit)
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local ListData = require(replicatedStorage.Modules.ListData)
ListData = ListData.MoveList
local KeybindIcons = require(replicatedStorage.Modules.KeybindIcons)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "CopyController"
})
controller.SelectRemote = nil

function controller.SelectWheel(_, childName)
	if not controller.SelectRemote then
		return
	end

	local copyWheel = localPlayer.PlayerGui:FindFirstChild("CopyWheel")

	if not copyWheel then
		return
	end

	local child = copyWheel.Wheel:FindFirstChild(childName)

	if child and child.Visible then
		controller.SelectRemote:FireServer(child:GetAttribute("Name"))
	end
end

function controller.KnitStart(_)
	local v4 = {
		Shrine = Color3.fromRGB(255, 155, 155),
		Doors = Color3.fromRGB(170, 255, 127),
		Limitless = Color3.fromRGB(170, 255, 255),
		["10 Shadows"] = Color3.fromRGB(120, 120, 120),
		Adaptation = Color3.fromRGB(255, 255, 255),
		Transfiguration = Color3.fromRGB(255, 170, 255),
		Blood = Color3.fromRGB(170, 75, 75),
		["Boogie Woogie"] = Color3.fromRGB(170, 255, 255),
		["Black Mucus"] = Color3.fromRGB(170, 255, 127),
		Execution = Color3.fromRGB(115, 99, 77),
		Mass = Color3.fromRGB(170, 170, 255),
		Dismantle = Color3.fromRGB(255, 85, 0),
		Clairvoyance = Color3.fromRGB(255, 235, 235),
		Puppets = Color3.fromRGB(225, 10, 75),
		Projection = Color3.fromRGB(128, 126, 255),
		Ratio = Color3.fromRGB(94, 191, 255),
		Kamehameha = Color3.fromRGB(255, 21, 52),
		["Hand Sword"] = Color3.fromRGB(167, 125, 203),
		["Bird Control"] = Color3.fromRGB(35, 40, 80),
		Plants = Color3.fromRGB(172, 203, 163),
		["Granite Blast"] = Color3.fromRGB(170, 255, 255),
		Roaches = Color3.fromRGB(101, 35, 44)
	}
	local color = Color3.new(0, 0, 0)
	local v5 = {
		Start = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.CursedSpeechStart, humanoidRootPart, game.SoundService.Effect)
		end,
		MouthSpeech = function(p)
			local clone = utils.Yuta.RikaHandTrail.CSVfx:Clone()
			clone.Parent = p.Head
			clone.CursedSpeech:Emit(1)
			clone.L.Ring:Emit(2)
			clone.R.Ring:Emit(2)
			clone.M.Ring:Emit(2)
			Debris:AddItem(clone, 4)
		end,
		MouthGlitch = function(p)
			local cSVfx = p.Head:FindFirstChild("CSVfx")

			if cSVfx then
				cSVfx.M.Glitch:Emit(10)
			end
		end,
		DontMove = function(p)
			if (workspace.CurrentCamera.CFrame.Position - p.Head.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local clone = utils.Misc.Items.Voice:Clone()
			local model = Instance.new("Model")
			Debris:AddItem(model, 0.2)
			clone.Parent = model
			model:ScaleTo(1.8)
			clone.Anchored = false
			local motor6D = Instance.new("Motor6D")
			motor6D.Parent = clone
			motor6D.Part0 = p.Head
			motor6D.Part1 = clone
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in clone:GetChildren() do
				if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "WindCircle") then
					continue
				end

				emitter.LockedToPart = true
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			v2:PlaySound(sounds.Misc.Items.Voice, p.HumanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuta.VoiceDontMove, p.HumanoidRootPart, game.SoundService.Voice)
		end,
		PromptWheel = function(list, selectRemote)
			local DISTANCE_THRESHOLD = 0.5
			local clone = replicatedStorage.Utils.Yuta.CopyWheel:Clone()
			controller.SelectRemote = selectRemote
			local wheel = clone.Wheel
			wheel.Size = UDim2.new(0.1, 150, 0.1, 150)
			local v6 = 0
			local copy = localPlayer.Character.Moveset:FindFirstChild("Copy", true)
			local v7 = {}
			local v8 = list[5]

			if v8 then
				v7[1] = v8
			end

			local v9 = list[6]

			if v9 then
				v7[2] = v9
			end

			local v10 = list[7]

			if v10 then
				v7[3] = v10
			end

			local v11 = list[8]

			if v11 then
				v7[4] = v11
			end

			if #v7 == 0 then
				wheel.Switch.Visible = false
			end

			local v12 = nil
			local v13 = nil
			local total = 1

			local function loadButtons(p)
				v12 = p
				v13 = nil
				v6 = 0
				total = 1

				for _, button in wheel:GetChildren() do
					if not button:IsA("TextButton") then
						continue
					end

					button.SelectionStroke.Enabled = false
					local child = replicatedStorage.Keybind.Combat:FindFirstChild("Skill " .. button.Name)
					local lastInput = v3.LastInput or "Keyboard"
					local child2 = child:FindFirstChild((lastInput == "Xbox" or lastInput == "Playstation") and "Gamepad" or lastInput)
					button.Key.Text = child2 and `[ {KeybindIcons:GetTextForKeyCode(child2)} ]` or ""
					local name = tonumber(button.Name)
					local v14 = p[name]

					if v14 then
						button.Visible = true

						if v6 < name then
							v6 = name
						end

						button:SetAttribute("Name", v14[1])
						local value = v14[2]
						local lastUse = v14[3]

						if copy:GetAttribute("Tip") == v14[1] then
							value = copy.Value
							lastUse = copy:GetAttribute("LastUse")
						end

						button:SetAttribute("Cooldown", value)
						button:SetAttribute("LastUsed", lastUse)
						button.Text = v14[1]
						button.BackgroundColor3 = v4[v14[1]] or color
						button.MouseEnter:Connect(function()
							v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
						end)
						local v15 = v14
						button.MouseButton1Click:Connect(function()
							v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
							selectRemote:FireServer(v15[1])
						end)
					else
						button.Visible = false
					end
				end
			end

			loadButtons(list)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function swapPage()
				local v14 = v12 == list and v7 or list

				if #v14 ~= 0 then
					loadButtons(v14)
				end
			end

			wheel.Switch.MouseButton1Click:Connect(swapPage)
			selectRemote.OnClientEvent:Connect(function(p)
				if p == "Swap" then
					swapPage() -- equivalent call inferred; original call site unknown
				end
			end)
			clone.Parent = localPlayer.PlayerGui
			clone.Enabled = true
			v2:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
			TweenService:Create(wheel, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = UDim2.new(0.2, 150, 0.2, 150)
			}):Play()
			selectRemote.AncestryChanged:Once(function()
				clone:Destroy()
			end)
			local v14 = workspace.CurrentCamera.ViewportSize / 2
			local viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				v14 = workspace.CurrentCamera.ViewportSize / 2
			end)
			local GuiService = game:GetService("GuiService")
			local guiInset = GuiService:GetGuiInset()
			local magnitude = wheel.Switch.AbsoluteSize.Magnitude
			local v15 = false
			local flag = nil

			while clone.Parent do
				total += task.wait()

				if total >= 1 then
					total = 0

					for _, button in wheel:GetChildren() do
						if not (button:IsA("TextButton") and button.Visible) then
							continue
						end

						local serverTimeNow = workspace:GetServerTimeNow()
						local lastUsed = button:GetAttribute("LastUsed")
						local cooldown = button:GetAttribute("Cooldown")
						local name = button:GetAttribute("Name")
						local v16 = serverTimeNow - lastUsed

						if v16 < cooldown then
							button.Text = `{name} [{math.floor(cooldown - v16)}]`
						else
							button.Text = `{name}`
						end
					end
				end

				if v15 or not (v13 and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
					Enum.UserInputType.Gamepad1,
					Enum.KeyCode.ButtonA
				))) then
					local position = nil
					local child

					if UserInputService.TouchEnabled then
						if position and not (position.Magnitude < DISTANCE_THRESHOLD) then
							child = wheel:FindFirstChild((math.clamp(
								math.floor(((math.deg((math.atan2(-position.Y, position.X))) + 90) % 360 + 45) / 90) % 4 + 1,
								1,
								v6
							)))

							if child and child.Visible then
								if v13 then
									if v13 ~= child then
										v13.SelectionStroke.Enabled = false
										flag = true
										v13 = child
										child.SelectionStroke.Enabled = true
									end
								else
									flag = true
									v13 = child
									child.SelectionStroke.Enabled = true
								end
							end
						end
					elseif UserInputService.GamepadEnabled then
						local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

						for _, v17 in gamepadState do
							if v17.KeyCode ~= Enum.KeyCode.Thumbstick2 then
								continue
							end

							position = v17.Position
							break
						end

						if position and not (position.Magnitude < DISTANCE_THRESHOLD) then
							child = wheel:FindFirstChild((math.clamp(
								math.floor(((math.deg((math.atan2(-position.Y, position.X))) + 90) % 360 + 45) / 90) % 4 + 1,
								1,
								v6
							)))

							if child and child.Visible then
								if v13 then
									if v13 ~= child then
										v13.SelectionStroke.Enabled = false
										flag = true
										v13 = child
										child.SelectionStroke.Enabled = true
									end
								else
									flag = true
									v13 = child
									child.SelectionStroke.Enabled = true
								end
							end
						end
					else
						local v16 = v14 - (Vector2.new(mouse.X, mouse.Y) + guiInset)

						if v16.Magnitude < magnitude then
							v15 = true
						else
							local unit = v16.Unit
							position = Vector2.new(-unit.X, unit.Y)
							v15 = false

							if position and not (position.Magnitude < DISTANCE_THRESHOLD) then
								child = wheel:FindFirstChild((math.clamp(
									math.floor(((math.deg((math.atan2(-position.Y, position.X))) + 90) % 360 + 45) / 90) % 4 + 1,
									1,
									v6
								)))

								if child and child.Visible then
									if v13 then
										if v13 ~= child then
											v13.SelectionStroke.Enabled = false
											flag = true
											v13 = child
											child.SelectionStroke.Enabled = true
										end
									else
										flag = true
										v13 = child
										child.SelectionStroke.Enabled = true
									end
								end
							end
						end
					end
				else
					if flag then
						v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						flag = false
					end

					selectRemote:FireServer(v13:GetAttribute("Name"))
				end
			end

			controller.SelectRemote = nil
			viewportSizeChangedConnection:Disconnect()
		end
	}
	CopyService.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	CopyService = Knit.GetService("CopyService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller