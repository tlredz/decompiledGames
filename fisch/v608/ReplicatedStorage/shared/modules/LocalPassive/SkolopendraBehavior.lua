local SkolopendraBehavior = {}
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
game:GetService("Lighting")
game:GetService("GuiService")
local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.client.legacyControllers.LightingController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
DataController = DataController.PlayerDataReplicator
local remoteEvent = Net:RemoteEvent("Skolopendra/Damage")
local module = require("./PassiveHandler")
local UI = script:WaitForChild("UI")
local sounds = script:WaitForChild("Sounds")
Random.new()

local function playHit(instance, parent, value: number?, value2: number?)
	local clone = instance:Clone()
	clone.Transparency = value2 or 0
	clone.Parent = parent
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(value or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Thickness = 0,
			Transparency = 1
		}
	)
	TweenService:Create(clone, TweenInfo.new(value or 0.5, Enum.EasingStyle.Quint), {
		BorderOffset = UDim.new(0.1, 0)
	}):Play()
	tween.Completed:Once(function()
		tween:Destroy()
		clone:Destroy()
	end)
	tween:Play()
end

function SkolopendraBehavior:Morph(_, object2)
	object2:Preload(script:GetChildren())

	if self.config.ForcedDarknessThreshold then
		object2.core.minigame.NoComplete = true
	end

	script.AudioSlop.AudioChannelMixer.WireOut.TargetInstance = SoundService:WaitForChild("AudioDeviceOutput")
	self.random = object2:GetRandom(6)
	self.nextDarkness = self.random:NextNumber(self.config.DarknessIntervalMin, self.config.DarknessIntervalMax)
	self.darknessActive = false
	self.darknessFullyActive = false
	self.darknessCount = 0
	self.darkreel = self.reelTrove:Add(UI.darkreel:Clone())
	self.darkreel_bar = self.darkreel.bar
	self.darkreel_pbar = self.darkreel.bar.playerbar
	self.darkreel_progress = self.darkreel.bar.progress
	self.darkreel_bg = self.darkreel.bg
	self.darkreel_silouettes = self.darkreel:QueryDescendants("UIStroke#silouhette")
	self.darkreel_bg.BackgroundTransparency = 1
	self.darkreel_progress.stroke.Transparency = 1
	self.darkreel_progress.bar.BackgroundTransparency = 1

	for _, darkreel_silouette in ipairs(self.darkreel_silouettes) do
		darkreel_silouette.Enabled = false
	end

	self.darkreel.Parent = object2.reel
	self._barSpeedModifier = object2:CreateModifier("barMoveSpeed", "multiply")
	self._barSpeedModifier2 = object2:CreateModifier("accel", "multiply")
	local music = SoundService:WaitForChild("music")
	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	self.reelTrove:Add(function()
		if self.darknessActive then
			self:EndDarkness(object2)
		end
	end)
	self.reelTrove:Add(object2.OnBarBounce:Connect(function(p, p2)
		if self.darknessActive and math.abs(p2) > 0.2 then
			if p then
				playHit(UI.bar_righthit, self.darkreel_bar, 0.5, math.abs(p2))
				playHit(UI.pbar_righthit, self.darkreel_pbar, 0.25, math.abs(p2))
			else
				playHit(UI.bar_lefthit, self.darkreel_bar, 0.5, math.abs(p2))
				playHit(UI.pbar_lefthit, self.darkreel_pbar, 0.25, math.abs(p2))
			end
		end
	end))
	self.reelTrove:Add(object2.OnBarDirectionChange:Connect(function(p)
		if self.darknessActive then
			if p > 0 then
				playHit(UI.pbar_righthit, self.darkreel_pbar)
			else
				playHit(UI.pbar_lefthit, self.darkreel_pbar)
			end
		end
	end))
	self.reelTrove:Add(function()
		TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
		}):Play()
		local tween = TweenService:Create(sounds.Music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Once(function()
			sounds.Music:Stop()
		end)
		tween:Play()
	end)
	self.reelTrove:Add(self.current.OnReady:Once(function()
		sounds.Music.Volume = 0.75
		sounds.Music:Play()
	end))
end

function SkolopendraBehavior:FlashWarning(_, flag: boolean)
	local clone

	if flag then
		clone = UI.warnright:Clone()
	else
		clone = UI.warnleft:Clone()
	end

	clone.BackgroundTransparency = 0
	clone.exclamation.TextTransparency = 0

	if flag then
		sounds.AlertRight.TimePosition = 0
		sounds.AlertRight:Play()
	else
		sounds.AlertLeft.TimePosition = 0
		sounds.AlertLeft:Play()
	end

	clone.Size = UDim2.fromScale(0.5, 1)
	TweenService:Create(
		clone,
		TweenInfo.new(self.config.SlashWarnTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{
			BackgroundTransparency = 1
		}
	):Play()
	TweenService:Create(
		clone.exclamation,
		TweenInfo.new(self.config.SlashWarnTime * 1.5, Enum.EasingStyle.Exponential),
		{
			Position = UDim2.fromScale(flag and 0.25 or 0.75, 0.5)
		}
	):Play()
	TweenService:Create(
		clone.exclamation,
		TweenInfo.new(self.config.SlashWarnTime * 1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{
			TextTransparency = 1
		}
	):Play()
	clone.Parent = self.darkreel
	task.delay(self.config.SlashWarnTime * 2, function()
		clone:Destroy()
	end)
end

function SkolopendraBehavior:GetLossPenalties(p2)
	local v = p2.progress / 100
	return
		math.lerp(self.config.SlashProgressLossMin, self.config.SlashProgressLossMax, v),
		(math.lerp(self.config.SlashDamageMin, self.config.SlashDamageMax, v))
end

function SkolopendraBehavior:RunSlash(object2)
	for _, darkreel_silouette in ipairs(self.darkreel_silouettes) do
		darkreel_silouette.Enabled = true
	end

	local v = self.random:NextInteger(0, 1) == 1
	self:FlashWarning(object2, v)
	task.wait(self.config.SlashWarnTime)
	local clone = UI.slash:Clone()

	if v then
		clone.AnchorPoint = Vector2.new(1, 0.5)
		clone.Position = UDim2.fromScale(1, 0.5)
	end

	clone.Parent = self.darkreel
	local tween = TweenService:Create(clone.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Offset = Vector2.new(0, 1)
	})
	tween.Completed:Once(function()
		clone:Destroy()
		tween:Destroy()
	end)
	tween:Play()
	local v2

	if v then
		v2 = object2.barPosition + object2.barSize * 0.5 > 0.6
	else
		v2 = object2.barPosition - object2.barSize * 0.5 < 0.4
	end

	if v2 then
		local lossPenalties, v3 = self:GetLossPenalties(object2)
		remoteEvent:FireServer(v3)
		local v4 = assert(self._progressLock)
		v4.Value -= lossPenalties
		object2.perfect = false
		fx:PlaySound(sounds.Impact, object2.reel, true)
		fx:PlaySound(sounds.SliceHit, object2.reel, true)

		if not SettingsController:GetSettingValue("photosensitiveMode") then
			self.darkreel_bg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			TweenService:Create(self.darkreel_bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				BackgroundColor3 = Color3.new()
			}):Play()
		end

		self.darkreel_progress.Visible = true
		self.darkreel_progress.bar.BackgroundTransparency = 0
		self.darkreel_progress.stroke.Transparency = 0

		if object2.barSize >= 0.5 then
			object2:AddModifier("barSize", "add", (math.min(0.4 - object2.barSize, -self.config.SlashControlLoss)))
		else
			object2:AddModifier("barSize", "add", -math.min(self.config.SlashControlLoss, self.current.barSize / 2))
		end

		TweenService:Create(self.darkreel_progress.bar, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(self.darkreel_progress.stroke, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	else
		fx:PlaySound(sounds.Slice, object2.reel, true)
		fx:PlaySound(sounds.Slice2, object2.reel, true)
	end

	task.wait(0.5)
end

function SkolopendraBehavior:StartDarkness(object2)
	if self.darknessActive then
		warn("Darkness already active")
		return
	end

	if not object2.active then
		return
	end

	self.darknessActive = true
	self.darknessCount += 1
	self.nextDarkness += self.random:NextNumber(self.config.DarknessIntervalMin, self.config.DarknessIntervalMax)
	fx:PlaySound(sounds.DarknessStart, object2.reel, true)

	if self._progressLock then
		self._progressLock:Destroy()
		self._progressLock = nil
	end

	local progress = object2.progress

	if self.darknessCount == 1 and self.config.ForcedDarknessThreshold and self.config.ForcedDarknessThreshold < progress then
		progress = self.config.ForcedDarknessThreshold
	end

	self._progressLock = object2:CreateModifier("progress", "force_final")
	local assert_2 = assert(self._progressLock)
	assert_2.Value = progress
	object2.progressLocked = true
	object2.core.ui.CameraFOV_Enabled = false
	object2.logicPaused = true
	object2.core.minigame.Disabled = true
	object2.core.minigame.NoComplete = true
	object2.core.fish:PauseMovement()
	TweenService:Create(self.darkreel_bg, TweenInfo.new(self.config.DarknessFadeTime, Enum.EasingStyle.Quart), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(self.config.DarknessFadeTime, Enum.EasingStyle.Quint), {
		FieldOfView = 40
	}):Play()
	self._barSpeedModifier.Value = 2
	self._barSpeedModifier2.Value = 3
	playHit(UI.bar_lefthit, self.darkreel_bar, self.config.DarknessFadeTime * 2)
	playHit(UI.bar_righthit, self.darkreel_bar, self.config.DarknessFadeTime * 2)
	playHit(UI.pbar_lefthit, self.darkreel_pbar, self.config.DarknessFadeTime * 4)
	playHit(UI.pbar_righthit, self.darkreel_pbar, self.config.DarknessFadeTime * 4)
	task.delay(self.config.DarknessFadeTime, function()
		if not object2.active then
			return
		end

		self.darknessFullyActive = true

		for _ = 1, self.config.SlashCount do
			task.wait(self.random:NextNumber(self.config.SlashIntervalMin, self.config.SlashIntervalMax) * math.map(
				object2.progress,
				0,
				100,
				1,
				0.25
			))

			if not object2.active then
				return
			end

			self:RunSlash(object2)
		end

		if not object2.active then
			return
		end

		self:EndDarkness(object2)
	end)
end

function SkolopendraBehavior:EndDarkness(object)
	if not self.darknessActive then
		warn("Darkness not active")
		return
	end

	self.darknessActive = false
	self.darknessFullyActive = false
	object.progressLocked = false
	object.core.ui.CameraFOV_Enabled = true
	object.core.fish:ResumeMovement()

	for _, darkreel_silouette in ipairs(self.darkreel_silouettes) do
		darkreel_silouette.Enabled = false
	end

	self._barSpeedModifier.Value = 1
	self._barSpeedModifier2.Value = 1
	TweenService:Create(self.darkreel_bg, TweenInfo.new(self.config.DarknessFadeTime, Enum.EasingStyle.Quart), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(self.config.DarknessFadeTime, Enum.EasingStyle.Quint), {
		FieldOfView = 70
	}):Play()

	if object.active then
		local value = assert(self._progressLock).Value
		local force_final = object._active_modifiers.progress.force_final
		local index = force_final and table.find(force_final, self._progressLock)

		if index then
			table.remove(force_final, index)
		end

		self._progressLock:Destroy()
		self._progressLock = nil
		object:Update(0)
		local progress = object.progress

		if value ~= progress then
			object:AddProgress((value - progress) / object.trueprogressefficiency)
			object:Update(0)
		end

		object.core.minigame.Disabled = false
		object.core.minigame.NoComplete = false
		object.logicPaused = false
	end
end

function SkolopendraBehavior:TickLogic_Rod(state, p: number)
	if self.darknessFullyActive then
		state.fishPosition = state.barPosition
	end

	if self.darknessActive then
		if state.progress <= 0 then
			self:EndDarkness(state)
		end
	else
		self.nextDarkness -= p

		if self.nextDarkness <= 0 or self.darknessCount == 0 and self.config.ForcedDarknessThreshold and state.progress >= self.config.ForcedDarknessThreshold then
			self:StartDarkness(state)
		end
	end
end

function SkolopendraBehavior.TickRender_Rod(data, p, _: number)
	if data.darknessActive then
		data.darkreel_pbar.Position = p.reel_playerbar.Position
		data.darkreel_pbar.Size = p.reel_playerbar.Size
		data.darkreel_pbar.Rotation = p.reel_playerbar.Rotation
		data.darkreel_progress.bar.Size = p.reel_progress.bar.Size
	end
end

setmetatable(SkolopendraBehavior, module)
return SkolopendraBehavior