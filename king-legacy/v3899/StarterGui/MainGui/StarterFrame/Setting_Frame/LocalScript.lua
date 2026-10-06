local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local setting_FastMode = parent.Frame.Setting_FastMode
local _ = parent.Frame.Setting_Language
local setting_Music = parent.Frame.Setting_Music
local setting_PVP = parent.Frame.Setting_PVP
local setting_DamageText = parent.Frame.Setting_DamageText
local setting_AutoPvpOff = parent.Frame.Setting_AutoPvpOff
local setting_DodgeText = parent.Frame.Setting_DodgeText
local setting_ComboText = parent.Frame.Setting_ComboText
local setting_JumpText = parent.Frame.Setting_JumpText
local setting_AllyEffects = parent.Frame.Setting_AllyEffects
local setting_CameraShake = parent.Frame.Setting_CameraShake
local setting_AutoSetSpawn = parent.Frame.Setting_AutoSetSpawn
local setting_HideAcc = parent.Frame.Setting_HideAcc
local setting_HideAllEffects = parent.Frame.Setting_HideAllEffects
local setting_SkillButtonStyle = parent.Frame.Setting_SkillButtonStyle
local setting_SkillControl = parent.Frame.Setting_SkillControl
local setting_RetroUI = parent.Frame.Setting_RetroUI
local setting_HideHair = parent.Frame.Setting_HideHair
local setting_HideRaceAppearance = parent.Frame.Setting_HideRaceAppearance
local v = true
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
localPlayer:GetMouse()
local frame = parent:WaitForChild("Frame")
local uIGridLayout = frame:WaitForChild("UIGridLayout")

function UpdateGrid()
	uIGridLayout.CellSize = UDim2.new(
		0,
		(frame.AbsoluteSize.X - frame.ScrollBarThickness) * 1,
		0,
		(frame.AbsoluteSize.Y - frame.ScrollBarThickness) * 0.2
	)
	frame.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end

function ShowSetting_SkillControl()
	if setting_SkillButtonStyle.Visible then
		setting_SkillControl.Visible = true
		_G.ShineGui({
			Parent = setting_SkillControl,
			ZIndex = 7
		})
	end
end

frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateGrid()
end)
task.delay(1, function()
	UpdateGrid()
end)

function ButtonUpdate(instance, p)
	local textLabel = instance:FindFirstChild("TextLabel")
	local circle = instance:FindFirstChild("Circle")

	if p == "On" then
		if textLabel then
			TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			}):Play()
			TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()

			if instance.Parent == setting_PVP then
				if localPlayer.PlayerStats.Language.Value == "TH" then
					textLabel.Text = "เปิด PvP"
				else
					textLabel.Text = "Enable PvP"
				end
			elseif instance.Parent == setting_SkillControl then
				textLabel.Position = UDim2.new(0.35, 0, 0.5, 0)

				if circle then
					TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
						Position = UDim2.new(0.8, 0, 0.5, 0)
					}):Play()
				end

				if localPlayer.PlayerStats.Language.Value == "TH" then
					textLabel.Text = "ลาก"
				else
					textLabel.Text = "Drag"
				end
			else
				textLabel.Position = UDim2.new(0.35, 0, 0.5, 0)

				if circle then
					TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
						Position = UDim2.new(0.8, 0, 0.5, 0)
					}):Play()
				end

				if localPlayer.PlayerStats.Language.Value == "TH" then
					textLabel.Text = "เปิด"
				else
					textLabel.Text = "On"
				end
			end
		end
	elseif p == "Off" and textLabel then
		TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			BackgroundColor3 = Color3.fromRGB(111, 111, 111)
		}):Play()
		TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			TextColor3 = Color3.fromRGB(193, 193, 193)
		}):Play()

		if instance.Parent == setting_PVP then
			if localPlayer.PlayerStats.Language.Value == "TH" then
				textLabel.Text = "เปิด PvP"
			else
				textLabel.Text = "Enable PvP"
			end
		elseif instance.Parent == setting_SkillControl then
			if circle then
				TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					Position = UDim2.new(0.2, 0, 0.5, 0)
				}):Play()
			end

			textLabel.Position = UDim2.new(0.65, 0, 0.5, 0)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				textLabel.Text = "เลือก"
			else
				textLabel.Text = "Select"
			end
		else
			if circle then
				TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					Position = UDim2.new(0.2, 0, 0.5, 0)
				}):Play()
			end

			textLabel.Position = UDim2.new(0.65, 0, 0.5, 0)

			if localPlayer.PlayerStats.Language.Value == "TH" then
				textLabel.Text = "ปิด"
			else
				textLabel.Text = "Off"
			end
		end
	end
end

local fastMode = workspace.sfx_is.FastMode
local _ = workspace.PlayerCharacters
local v2 = true
setting_FastMode.Menu.MouseButton1Click:Connect(function()
	if not v2 then
		return
	end

	v2 = false
	fastMode.Value = true
	_G.RenderDist1 = 750
	ButtonUpdate(setting_FastMode.Menu, "On")
	task.spawn(function()
		_G.ClickFrameEffect()
	end)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5035769082",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = parent
	sound:Play()
	game.Lighting.GlobalShadows = false
	spawn(function()
		local clone = game.ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone.TextColor3 = Color3.fromRGB(0, 255, 0)
		clone.TextStrokeTransparency = 0
		clone.TextTransparency = 0
		clone:SetAttribute("DebrisTime", 25)
		clone.Parent = localPlayer.PlayerGui.Popup.Frame
		local v3 = localPlayer.PlayerStats.Language.Value == "TH" and "กำลังประมวลผล (" or "Render Working ("
		local count = 0
		local count2 = 0

		for _, descendant in pairs(workspace.Island:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Material ~= Enum.Material.ForceField and descendant.Name ~= "FruitModelShowcase" then
				descendant.Material = Enum.Material.SmoothPlastic
				count2 += 1
				count += 1
				clone.Text = v3 .. count2 .. ")"
				clone:SetAttribute("DebrisTime", 2)
			elseif descendant:IsA("Texture") then
				descendant:Destroy()
			end

			if not (count >= 25) then
				continue
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
			count = 0
		end

		wait(1)

		if clone then
			clone.Text = "Render Completed!"
			clone:SetAttribute("DebrisTime", 2)
		end

		wait(3)
	end)
	spawn(function()
		local count = 0

		for _, descendant in pairs(game.ReplicatedStorage.MAP:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Material = Enum.Material.SmoothPlastic
				count += 1
			elseif descendant:IsA("Texture") then
				descendant:Destroy()
			end
		end

		if count >= 25 then
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
		end
	end)
end)

repeat
	wait(0.1)
until localPlayer:FindFirstChild("PlayerStats")

local playerStats = localPlayer:WaitForChild("PlayerStats", 30)
playerStats:WaitForChild("Music", 30)
local musicVolume = playerStats:WaitForChild("MusicVolume", 30)
local flag = nil

function UpdateMusicVolume()
	local v3 = math.clamp(math.floor(musicVolume.Value / 2 / 0.05) * 0.05, 0, 0.95)
	setting_Music.Frame.Menu.Position = UDim2.new(v3, 0, 0.5, 0)
	setting_Music.Frame.VolumeFrame.UIGradient.Offset = Vector2.new(v3 - 0.5, 0)
	local addVolume = workspace.sfx_is.Music_Area:GetAttribute("AddVolume") or 1
	workspace.sfx_is.Music_Area.Volume = musicVolume.Value * addVolume
end

local v3 = nil
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
setting_Music.Frame.Menu.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		flag = true

		while flag do
			local v4 = (localPlayer:GetMouse().X - setting_Music.Frame.AbsolutePosition.X) / setting_Music.Frame.AbsoluteSize.X
			local v5 = math.clamp(v4, 0, 1)
			local v6 = math.floor(v5 / 0.05) * 0.05 * 2
			local v7 = math.clamp(math.floor(v5 / 0.05) * 0.05, 0, 0.95)

			if v4 ~= v3 then
				v3 = v4
				local uDim = UDim2.new(v7, 0, 0.5, 0)
				UDim2.new(v7, 0, 1, 0)
				TweenService:Create(setting_Music.Frame.Menu, tweenInfo, {
					Position = uDim
				}):Play()
				TweenService:Create(setting_Music.Frame.VolumeFrame.UIGradient, tweenInfo, {
					Offset = Vector2.new(v7 - 0.45, 0)
				}):Play()
				local addVolume = workspace.sfx_is.Music_Area:GetAttribute("AddVolume") or 1
				workspace.sfx_is.Music_Area.Volume = v6 * addVolume
			end

			if parent.Parent.Parent.BaseFrame.ButtonFrame.Setting_Button.Visible or parent.Parent.Parent.BaseFrameOG.ButtonFrame.Setting_Button.Visible then
				task.wait(0.02)
			else
				break
			end
		end

		script.Remote:InvokeServer("Music Volume", {
			Volume = workspace.sfx_is.Music_Area.Volume
		})
	end
end)
UpdateMusicVolume()
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		flag = nil
	end
end)
setting_Music.Frame.Menu.MouseButton1Up:Connect(function()
	flag = nil
end)
local v4 = true
setting_PVP.Menu.MouseButton1Click:Connect(function()
	if not v4 or not v or localPlayer.PlayerStats.PVP.Value then
		return
	end

	v4 = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)
	local _ = localPlayer.PlayerStats.Language.Value == "TH"

	if not localPlayer.PlayerStats.PVP.Value then
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("PVPON")
	end

	spawn(function()
		wait(0.3)
		v4 = true
	end)
end)
setting_DamageText.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "DamageText") then
		if _G.CheckSettingClient(localPlayer, "DamageText") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("DamageTextOff")
			ButtonUpdate(setting_DamageText.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("DamageTextOn")
		ButtonUpdate(setting_DamageText.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_AutoPvpOff.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "AutoPvpOff") then
		if _G.CheckSettingClient(localPlayer, "AutoPvpOff") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("AutoPvpOff_Off")
			ButtonUpdate(setting_AutoPvpOff.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("AutoPvpOff_On")
		ButtonUpdate(setting_AutoPvpOff.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_DodgeText.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_DodgeText") then
		if _G.CheckSettingClient(localPlayer, "Setting_DodgeText") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_DodgeText_Off")
			ButtonUpdate(setting_DodgeText.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_DodgeText_On")
		ButtonUpdate(setting_DodgeText.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_ComboText.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_ComboText") then
		if _G.CheckSettingClient(localPlayer, "Setting_ComboText") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_ComboText_Off")
			ButtonUpdate(setting_ComboText.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_ComboText_On")
		ButtonUpdate(setting_ComboText.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_JumpText.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_JumpText") then
		if _G.CheckSettingClient(localPlayer, "Setting_JumpText") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_JumpText_Off")
			ButtonUpdate(setting_JumpText.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_JumpText_On")
		ButtonUpdate(setting_JumpText.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_AllyEffects.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_AllyEffects") then
		if _G.CheckSettingClient(localPlayer, "Setting_AllyEffects") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_AllyEffects_Off")
			ButtonUpdate(setting_AllyEffects.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_AllyEffects_On")
		ButtonUpdate(setting_AllyEffects.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_HideAllEffects.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_HideAllEffects") then
		if _G.CheckSettingClient(localPlayer, "Setting_HideAllEffects") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_HideAllEffects_Off")
			ButtonUpdate(setting_HideAllEffects.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_HideAllEffects_On")
		ButtonUpdate(setting_HideAllEffects.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_RetroUI.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_RetroUI") then
		if _G.CheckSettingClient(localPlayer, "Setting_RetroUI") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_RetroUI_Off")
			ButtonUpdate(setting_RetroUI.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_RetroUI_On")
		ButtonUpdate(setting_RetroUI.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_HideHair.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_HideHair") then
		if _G.CheckSettingClient(localPlayer, "Setting_HideHair") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_HideHair_Off")
			ButtonUpdate(setting_HideHair.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_HideHair_On")
		ButtonUpdate(setting_HideHair.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_HideRaceAppearance.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_HideRaceAppearance") then
		if _G.CheckSettingClient(localPlayer, "Setting_HideRaceAppearance") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_HideRaceAppearance_Off")
			ButtonUpdate(setting_HideRaceAppearance.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_HideRaceAppearance_On")
		ButtonUpdate(setting_HideRaceAppearance.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_CameraShake.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_CameraShake") then
		if _G.CheckSettingClient(localPlayer, "Setting_CameraShake") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_CameraShake_Off")
			ButtonUpdate(setting_CameraShake.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_CameraShake_On")
		ButtonUpdate(setting_CameraShake.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_AutoSetSpawn.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_AutoSetSpawn") then
		if _G.CheckSettingClient(localPlayer, "Setting_AutoSetSpawn") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_AutoSetSpawn_Off")
			ButtonUpdate(setting_AutoSetSpawn.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_AutoSetSpawn_On")
		ButtonUpdate(setting_AutoSetSpawn.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_HideAcc.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_HideAcc") then
		if _G.CheckSettingClient(localPlayer, "Setting_HideAcc") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_HideAcc_Off")
			ButtonUpdate(setting_HideAcc.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_HideAcc_On")
		ButtonUpdate(setting_HideAcc.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_SkillButtonStyle.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_SkillButtonStyle") then
		if _G.CheckSettingClient(localPlayer, "Setting_SkillButtonStyle") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_SkillButtonStyle_Off")
			ButtonUpdate(setting_SkillButtonStyle.Menu, "Off")
			setting_SkillControl.Visible = nil
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_SkillButtonStyle_On")
		ButtonUpdate(setting_SkillButtonStyle.Menu, "On")
		ShowSetting_SkillControl()
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)
setting_SkillControl.Menu.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if _G.CheckSettingClient(localPlayer, "Setting_SkillControl") then
		if _G.CheckSettingClient(localPlayer, "Setting_SkillControl") then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://5035769082",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			script.Remote:InvokeServer("Setting_SkillControl_Off")
			ButtonUpdate(setting_SkillControl.Menu, "Off")
		end
	else
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		script.Remote:InvokeServer("Setting_SkillControl_On")
		ButtonUpdate(setting_SkillControl.Menu, "On")
	end

	spawn(function()
		wait(0.3)
		v = true
	end)
end)

function Update()
	if _G.IsMobile then
		warn("Show Settings")
		setting_SkillButtonStyle.Visible = true
	end

	if localPlayer.PlayerStats.PVP.Value then
		ButtonUpdate(setting_PVP.Menu, "Off")
	else
		ButtonUpdate(setting_PVP.Menu, "On")
	end

	if fastMode.Value then
		ButtonUpdate(setting_FastMode.Menu, "On")
	else
		ButtonUpdate(setting_FastMode.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "DamageText") then
		ButtonUpdate(setting_DamageText.Menu, "On")
	else
		ButtonUpdate(setting_DamageText.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "AutoPvpOff") then
		ButtonUpdate(setting_AutoPvpOff.Menu, "On")
	else
		ButtonUpdate(setting_AutoPvpOff.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_DodgeText") then
		ButtonUpdate(setting_DodgeText.Menu, "On")
	else
		ButtonUpdate(setting_DodgeText.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_ComboText") then
		ButtonUpdate(setting_ComboText.Menu, "On")
	else
		ButtonUpdate(setting_ComboText.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_JumpText") then
		ButtonUpdate(setting_JumpText.Menu, "On")
	else
		ButtonUpdate(setting_JumpText.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_AllyEffects") then
		ButtonUpdate(setting_AllyEffects.Menu, "On")
	else
		ButtonUpdate(setting_AllyEffects.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_HideAllEffects") then
		ButtonUpdate(setting_HideAllEffects.Menu, "On")
	else
		ButtonUpdate(setting_HideAllEffects.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_SkillButtonStyle") then
		ButtonUpdate(setting_SkillButtonStyle.Menu, "On")

		if setting_SkillButtonStyle.Visible then
			ShowSetting_SkillControl()
		end
	else
		ButtonUpdate(setting_SkillButtonStyle.Menu, "Off")
		setting_SkillControl.Visible = nil
	end

	if _G.CheckSettingClient(localPlayer, "Setting_SkillControl") then
		ButtonUpdate(setting_SkillControl.Menu, "On")
	else
		ButtonUpdate(setting_SkillControl.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_RetroUI") then
		ButtonUpdate(setting_RetroUI.Menu, "On")
	else
		ButtonUpdate(setting_RetroUI.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_HideHair") then
		ButtonUpdate(setting_HideHair.Menu, "On")
	else
		ButtonUpdate(setting_HideHair.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_HideRaceAppearance") then
		ButtonUpdate(setting_HideRaceAppearance.Menu, "On")
	else
		ButtonUpdate(setting_HideRaceAppearance.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_CameraShake") then
		ButtonUpdate(setting_CameraShake.Menu, "On")
	else
		ButtonUpdate(setting_CameraShake.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_AutoSetSpawn") then
		ButtonUpdate(setting_AutoSetSpawn.Menu, "On")
	else
		ButtonUpdate(setting_AutoSetSpawn.Menu, "Off")
	end

	if _G.CheckSettingClient(localPlayer, "Setting_HideAcc") then
		ButtonUpdate(setting_HideAcc.Menu, "On")
	else
		ButtonUpdate(setting_HideAcc.Menu, "Off")
	end
end

task.delay(5, function()
	Update()
end)
game.ReplicatedStorage.Chest.Remotes.Events.UpdateSetting.OnClientEvent:Connect(function()
	Update()
end)
playerStats:WaitForChild("PVP", 60).Changed:Connect(function()
	Update()
end)
parent.Close.MouseButton1Click:Connect(function()
	_G.ButtonClicked()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
end)
parent.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	parent.Close.Size = UDim2.new(0.15, 0, 0.15, 0)
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.22499999999999998, 0, 0.22499999999999998, 0)
	}):Play()
end)
parent.Close.MouseLeave:Connect(function()
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.15, 0, 0.15, 0)
	}):Play()
end)