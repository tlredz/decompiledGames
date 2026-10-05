local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Trove)
local module = require("./NotificationController")
local module2 = require("./SettingsController")
local localPlayer = game.Players.LocalPlayer
return {
	Start = function(_)
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local v = 0
		local lastTime = os.clock()
		local count = 0

		local function GetFPS()
			count += 1

			if os.clock() - lastTime >= 1 then
				v = math.floor(count / (os.clock() - lastTime))
				count = 0
				lastTime = os.clock()
			end
		end

		task.wait(2)
		local heartbeatConnection = RunService.Heartbeat:Connect(GetFPS)
		task.wait(10)
		heartbeatConnection:Disconnect()
		print(("Client started with %s fps"):format((tostring(v))))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateLighting()
			Lighting.GlobalShadows = module2:GetSettingValue("shadowsEnabled")
			local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")

			if clouds then
				clouds.Enabled = module2:GetSettingValue("cloudsEnabled")
			end
		end

		module2:GetSettingChangedSignal("shadowsEnabled"):Connect(updateLighting)
		module2:GetSettingChangedSignal("cloudsEnabled"):Connect(updateLighting)
		updateLighting() -- equivalent call inferred; original call site unknown

		if v <= 35 and not RunService:IsStudio() and module2:GetSettingValue("autoPerformance") and module2:GetSettingValue("shownVfx") == "All" then
			module2:EditSetting("shownVfx", "HideAll")
			module2:EditSetting("shadowsEnabled", false)
			module2:EditSetting("cloudsEnabled", false)
			module2:EditSetting("windShake", false)
			module2:EditSetting("showRain", false)
			module2:EditSetting("showCatchFlags", false)
			module:Notify(
				"We identified low FPS, we turned on some optimization settings, you can turn it off in the menu",
				5
			)
		end

		if GuiService.ReducedMotionEnabled and not module2:GetSettingValue("photosensitiveMode") then
			print("Automatically enabled Photosensitive Mode because client prefered reduced motion")
			module2:EditSetting("photosensitiveMode", true)
		end

		local effects = {}

		local function setEnabled(effect, enabled)
			if effect:IsA("Beam") then
				if effect.Name == "TutorialBeam" then
					return
				end

				effect.Enabled = enabled
			elseif effect:IsA("Trail") then
				effect.Enabled = enabled
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = enabled
			end
		end

		local function update(emitter)
			local settingValue = module2:GetSettingValue("shownVfx")

			if settingValue == "HideAll" then
				emitter.Enabled = false
			elseif settingValue == "LocalOnly" then
				emitter.Enabled = emitter:IsDescendantOf(localPlayer.Character or localPlayer) or emitter:IsDescendantOf(workspace:WaitForChild("world")) or emitter:IsDescendantOf(workspace:WaitForChild("zones")) or emitter:FindFirstAncestor(localPlayer.Name) ~= nil
			else
				emitter.Enabled = true
			end

			if emitter:IsA("ParticleEmitter") and not emitter.Enabled then
				emitter:Clear()
			end
		end

		local function watchInstance(effect)
			if (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) and not effect:HasTag("IgnorePerformance") and effect.Enabled == true and not table.find(
				effects,
				effect
			) then
				update(effect)
				table.insert(effects, effect)
				local ancestryChangedConnection = nil
				ancestryChangedConnection = effect.AncestryChanged:Connect(function()
					if not effect:IsDescendantOf(workspace) then
						ancestryChangedConnection:Disconnect()
						local index = table.find(effects, effect)

						if index then
							table.remove(effects, index)
						end
					end
				end)
			end
		end

		for _, descendant in workspace:GetDescendants() do
			watchInstance(descendant)
		end

		workspace.DescendantAdded:Connect(function(effect)
			if (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) and not effect:HasTag("IgnorePerformance") and effect.Enabled == true then
				watchInstance(effect)
			end
		end)
		module2:GetSettingChangedSignal("shownVfx"):Connect(function()
			for _, v2 in effects do
				update(v2)
			end
		end)

		local function setSimonVisible(enabled: boolean)
			for _, folder in CollectionService:GetTagged("NewNpc") do
				if folder:GetAttribute("NpcType") ~= "Simon" then
					continue
				end

				for _, descendant in folder:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.LocalTransparencyModifier = enabled and 0 or 1
					elseif descendant:IsA("ProximityPrompt") then
						descendant.MaxActivationDistance = enabled and 7 or 0
					elseif descendant:IsA("Highlight") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
						descendant.Enabled = enabled
					end
				end
			end
		end

		local renderSteppedConnection = nil
		local total = 0
		Net:RemoteEvent("LightCheck", 1e999).OnClientEvent:Connect(function(p)
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			if not p then
				return
			end

			local raycastParams = RaycastParams.new()
			raycastParams.RespectCanCollide = true
			raycastParams.IgnoreWater = false
			raycastParams.CollisionGroup = "Players"
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				local moonDirection = Lighting:GetMoonDirection()

				if moonDirection.Y < 0 then
					total = 0
					return
				end

				local sky = Lighting:FindFirstChildOfClass("Sky")
				local moonAngularSize = sky and sky.MoonAngularSize or 6
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")
				local hitbox = tool and tool:FindFirstChild("Hitbox")

				if character and tool and hitbox and hitbox:IsA("BasePart") then
					local v2 = table.create(7)
					table.insert(v2, hitbox.CFrame)

					for _, v3 in Enum.NormalId:GetEnumItems() do
						table.insert(v2, hitbox.CFrame * CFrame.new(hitbox.Size / 2 * Vector3.FromNormalId(v3)))
						table.insert(v2, hitbox.CFrame * CFrame.new(hitbox.Size / 2 * -Vector3.FromNormalId(v3)))
					end

					for _, v3 in v2 do
						if not (moonAngularSize < math.deg(((v3.Position - workspace.CurrentCamera.CFrame.Position).Unit:Angle(moonDirection)))) then
							continue
						end

						total = 0
						return
					end

					if workspace:Raycast(workspace.CurrentCamera.CFrame.Position, moonDirection * 4096, raycastParams) then
						total = 0
						return
					end

					total += dt

					if total > 1 then
						if renderSteppedConnection then
							renderSteppedConnection:Disconnect()
							renderSteppedConnection = nil
						end

						setSimonVisible(false)
						local currentCamera = workspace.CurrentCamera
						currentCamera.CameraType = Enum.CameraType.Scriptable
						local module3 = require("./PlayerController")
						module3:ToggleControls(false)
						local module4 = require("./HudController")
						local hud = module4:GetHud()
						hud.Enabled = false
						local module5 = require("./HudController")
						local deviceInsetGui = module5:GetDeviceInsetGui()
						deviceInsetGui.Enabled = false
						local module6 = require("./HudController")
						local backpackGui = module6:GetBackpackGui()
						backpackGui.Enabled = false
						character:SetAttribute("LBCutscene1", 0)
						character:SetAttribute("LBCutscene2", 0)
						local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)

						for _, descendant in tool:GetDescendants() do
							if descendant:IsA("BasePart") then
								if descendant:HasTag("ColorPulse") then
									descendant:RemoveTag("ColorPulse")
								end

								TweenService:Create(descendant, tweenInfo, {
									Transparency = 1
								}):Play()
							elseif descendant:IsA("ParticleEmitter") then
								descendant.Enabled = false
							end
						end

						task.wait(3)
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Brightness = 0
						colorCorrectionEffect.Parent = Lighting
						local moonDirection2 = Lighting:GetMoonDirection()
						TweenService:Create(
							currentCamera,
							TweenInfo.new(6, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								CFrame = CFrame.lookAlong(
									currentCamera.CFrame.Position,
									moonDirection2,
									createVector(0, 1, 0)
								) * CFrame.new(0, 0, -256),
								FieldOfView = 20
							}
						):Play()
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Brightness = 1
							}
						):Play()
						task.wait(4)
						local screenGui = Instance.new("ScreenGui")
						screenGui.ClipToDeviceSafeArea = false
						screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
						screenGui.ScreenInsets = Enum.ScreenInsets.None
						screenGui.ResetOnSpawn = false
						screenGui.DisplayOrder = 999999999
						screenGui.Name = "fadeOverlay"
						local frame = Instance.new("Frame")
						frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						frame.BackgroundTransparency = 1
						frame.Size = UDim2.fromScale(1, 1)
						frame.Parent = screenGui
						local module7 = require("./HudController")
						screenGui.Parent = module7:GetPlayerGui()
						TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Linear), {
							BackgroundTransparency = 0
						}):Play()
						local GuiService2 = game:GetService("GuiService")
						GuiService2:SetGameplayPausedNotificationEnabled(false)
						task.wait(2)
						Net:Invoke("LightCheckResult", moonDirection2)
						local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
						local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
						local track

						if animator then
							track = animator:LoadAnimation(ReplicatedStorage.resources.animations.player.lbidle)
							track.Priority = Enum.AnimationPriority.Action4
							track:Play()
						end

						local moonDirection3 = Lighting:GetMoonDirection()
						currentCamera.CFrame = CFrame.lookAlong(
							createVector(-1191.512, 217.654, -39794.73),
							moonDirection3,
							createVector(0, 1, 0)
						)
						currentCamera.Focus = currentCamera.CFrame
						currentCamera.FieldOfView = 10
						local clone = script.Sound:Clone()
						clone.Parent = game:GetService("SoundService")
						local ContentProvider = game:GetService("ContentProvider")
						ContentProvider:PreloadAsync({ clone })
						clone:Play()

						if not clone.IsLoaded then
							clone.Loaded:Wait()
							clone.TimePosition = 0
						end

						task.wait(3)
						local moonDirection4 = Lighting:GetMoonDirection()
						currentCamera.CFrame = CFrame.lookAlong(
							createVector(-1191.512, 217.654, -39794.73),
							moonDirection4,
							createVector(0, 1, 0)
						)
						currentCamera.Focus = CFrame.new(-1347.301, 132.394, -39937.691)
						TweenService:Create(frame, TweenInfo.new(5, Enum.EasingStyle.Quart), {
							BackgroundTransparency = 1
						}):Play()
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(5, Enum.EasingStyle.Quart), {
							Brightness = 0
						}):Play()
						TweenService:Create(currentCamera, TweenInfo.new(10, Enum.EasingStyle.Quart), {
							FieldOfView = 40
						}):Play()
						task.wait(7)
						TweenService:Create(
							currentCamera,
							TweenInfo.new(4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
							{
								CFrame = CFrame.new(-1325.116, 128.321, -39885.023) * CFrame.fromOrientation(
									0.047106436511326955,
									0.5074893866023912,
									0
								)
							}
						):Play()
						task.wait(5)
						local module8 = require("./PlayerController")
						module8:ToggleControls(true)
						character:SetAttribute("LBCutscene2", nil)
						UserInputService.JumpRequest:Wait()
						character:SetAttribute("LBCutscene1", nil)
						setSimonVisible(true)
						local module9 = require("./HudController")
						local hud_2 = module9:GetHud()
						hud_2.Enabled = true
						local module10 = require("./HudController")
						local deviceInsetGui_2 = module10:GetDeviceInsetGui()
						deviceInsetGui_2.Enabled = true
						local module11 = require("./HudController")
						local backpackGui_2 = module11:GetBackpackGui()
						backpackGui_2.Enabled = true
						currentCamera.CameraType = Enum.CameraType.Custom
						currentCamera.FieldOfView = 70
						currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")

						if track then
							track:Stop()
						end

						TweenService:Create(clone, TweenInfo.new(5, Enum.EasingStyle.Linear), {
							Volume = 0
						}):Play()
						task.wait(5)
						clone:Destroy()
						screenGui:Destroy()
					end
				else
					total = 0
				end
			end)
		end)
	end
}