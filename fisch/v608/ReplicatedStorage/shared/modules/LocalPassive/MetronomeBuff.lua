local createVector = vector.create
local MetronomeBuff = {}
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
game:GetService("Lighting")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage.packages.Trove)
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local remoteEvent = Net:RemoteEvent("MetronomeBuff/Input")
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local rodmusic = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("rodmusic")
local random = Random.new()

local function playSound(miss, playbackSpeed: number)
	local clone = miss:Clone()
	clone.PlaybackSpeed = playbackSpeed
	clone.Name = miss.Name .. "Clone"
	clone.Parent = script
	clone:Play()
	task.delay(miss.TimeLength * 2, function()
		clone:Destroy()
	end)
	return clone
end

local v = -1

function MetronomeBuff:GetCurrentBeat()
	local v2 = math.max(self.currentMusic.TimePosition - self.config.FixedMusicOffset, 0)
	local v3 = nil

	for _, bpmRegion in self.bpmRegions do
		if v2 < bpmRegion[1] then
			break
		else
			v3 = bpmRegion
		end
	end

	assert(v3, "No regions(?)")
	local v4 = (v2 - v3[1]) / v3[2]
	local v5 = v4 // 4

	if v5 ~= v then
		v = v5
	end

	return v4
end

function MetronomeBuff:GetCurrentMetronomeRotation()
	local v2 = self:GetCurrentBeat() * self.config.Speed
	return (1 - math.abs(v2 % 2 - 1)) * 180, math.floor(v2) % 2 == 1
end

function MetronomeBuff:LoadBPMRegions()
	local bpmRegions = table.create(#self.config.BPM)
	local v3 = 0
	local total = 0

	for k, v4 in self.config.BPM do
		local v5 = 60 / (self.config.BPM[k - 1] or v4)[2]
		local v6 = 60 / v4[2]
		total += v5 * self.config.BeatsPerMeasure * (v4[1] - v3)
		v3 = v4[1]
		bpmRegions[k] = { total, v6 }
	end

	self.bpmRegions = bpmRegions
end

function MetronomeBuff:LoadTargetRegions()
	local metronome = self.reel.Details.Metronome
	local clones = table.create(#self.config.Sections)

	for k, section in self.config.Sections do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = section.Asset
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Name = `Section{k}`
		imageLabel.ZIndex = -9
		imageLabel.Parent = metronome
		local clone = table.clone(section)
		clone.Section = imageLabel
		clone.Active = false
		clone.WasHit = false
		clones[k] = clone
	end

	self.targetRegions = clones
end

function MetronomeBuff:CreateHitBillboard(parent, duration: number)
	if not self.config then
		return
	end

	task.delay(duration, function()
		if not self.config then
			return
		end

		local clone = script.buffBillboard:Clone()
		clone.buffIcon.Image = self.config.BuffIcon
		clone.buffIcon.changeGlow.UIGradient.Color = self.config.BuffColor
		clone.buffIcon.UIScale.Scale = 1.5
		clone.buffIcon.ImageTransparency = 1
		clone.Enabled = true
		clone.buffIcon.changeGlow.Visible = not SettingsController:GetSettingValue("photosensitiveMode")
		clone.Parent = parent
		TweenService:Create(clone.buffIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(clone.buffIcon.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Scale = 1
		}):Play()
		TweenService:Create(clone.buffIcon.changeGlow, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(clone.buffIcon, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0.5, 0)
		}):Play()
		task.wait(0.25)
		TweenService:Create(clone.buffIcon, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}):Play()
		task.wait(1)
		clone:Destroy()
	end)
end

function MetronomeBuff:CreateHitVisual()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local clone = script.rangeVisual:Clone()
	local v2 = self.config.BuffRange * 2
	clone.Size = createVector(1, 1, 1)
	clone.CFrame = humanoidRootPart.CFrame
	local HSV = self.config.BuffColor.Keypoints[math.random(1, #self.config.BuffColor.Keypoints)].Value:ToHSV()
	clone.Color = Color3.fromHSV(HSV, 0.5, 1)
	clone.Parent = workspace.active.debrisfx
	TweenService:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Quint), {
		Size = Vector3.new(v2, v2, v2)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true), {
		Transparency = 0
	}):Play()
	task.delay(2.5, clone.Destroy, clone)

	for _, part in CollectionService:GetTagged("PlayerRoot") do
		if not part:IsA("BasePart") then
			continue
		end

		local magnitude = (part.Position - humanoidRootPart.Position).Magnitude

		if not (self.config.BuffRange < magnitude) then
			self:CreateHitBillboard(
				part,
				TweenService:GetValue(
					magnitude / self.config.BuffRange,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.In
				) * 2
			)
		end
	end
end

function MetronomeBuff:Morph(p, object2)
	self:LoadBPMRegions()
	self:LoadTargetRegions()
	local v2 = 4.8 / (self.config.MusicFactor * self.config.SectionCount)
	self.MetronomeDirectionChanged = self.reelTrove:Add(Signal.new())
	self.MetronomeHit = self.reelTrove:Add(Signal.new())
	self.currentMusic = rodmusic:WaitForChild(self.config.MusicName)
	self.controlBuffTimer = 1e999
	self._barSizeModifier = object2:CreateModifier("barSize", "add")
	self._progSpeedModifier = object2:CreateModifier("progressefficiency", "add")
	self._targetBarSize = 0
	self._barSizeVelocity = 0
	local count = 0
	local count2 = 0
	object2.BuildEndingData:Bind(function(p2)
		p2.Lullaby_HitCount = count
		p2.Lullaby_MissCount = count2
		return p2
	end)
	script.MusicFader.InWire.SourceInstance = self.currentMusic
	script.MusicFader.OutWire.TargetInstance = SoundService:WaitForChild("AudioDeviceOutput")
	TweenService:Create(script.MusicFader, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Volume = 0.5
	}):Play()
	local ticker = self.reel.Details.Metronome.Ticker
	self.reelTrove:Add(function()
		local tween = TweenService:Create(script.MusicFader, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Once(function()
			tween:Destroy()

			if script.MusicFader.Volume <= 0 then
				script.MusicFader.InWire.SourceInstance = nil
			end
		end)
		tween:Play()
	end)
	local v3 = nil
	self.reelTrove:Add(object2.OnRenderStep:Connect(function(p2: number)
		local currentMetronomeRotation, v4 = self:GetCurrentMetronomeRotation()
		ticker.Rotation = currentMetronomeRotation

		for _, targetRegion in self.targetRegions do
			local active

			if targetRegion.Start <= currentMetronomeRotation then
				active = currentMetronomeRotation <= targetRegion.End
			else
				active = false
			end

			if targetRegion.Active ~= active then
				targetRegion.WasHit = false
			end

			targetRegion.Active = active
			targetRegion.Section.ImageColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
		end

		self.controlBuffTimer -= p2

		if self.controlBuffTimer <= 0 then
			self._targetBarSize = self.config.BuffExpirationPenalty
		end

		local _barSizeModifier = self._barSizeModifier
		local v6 = self
		local smoothDamp, barSizeVelocity = TweenService:SmoothDamp(
			self._barSizeModifier.Value,
			self._targetBarSize,
			self._barSizeVelocity,
			0.25,
			nil,
			p2
		)
		_barSizeModifier.Value = smoothDamp
		v6._barSizeVelocity = barSizeVelocity

		if v4 ~= v3 then
			if v3 ~= nil then
				self.MetronomeDirectionChanged:Fire(v4)
				fx:PlaySound(script.Tick, self.reel, false)
			end

			v3 = v4
		end
	end))
	object2.OnBarDirectionChange:Connect(function(p2)
		if not object2.active or p2 < 0 or object2.isPaused or object2.logicPaused then
			return
		end

		local currentMetronomeRotation = self:GetCurrentMetronomeRotation()

		for _, targetRegion in self.targetRegions do
			local v4

			if targetRegion.Start <= currentMetronomeRotation then
				v4 = currentMetronomeRotation <= targetRegion.End
			else
				v4 = false
			end

			if not v4 then
				continue
			end

			if not targetRegion.WasHit then
				self.controlBuffTimer = self.config.ControlDuration
				self._targetBarSize = math.clamp(self._targetBarSize + self.config.ControlPerHit * v2, 0, 0.1)
				remoteEvent:FireServer(true)
				self.MetronomeHit:Fire(true)
				object2:AddProgress(self.config.ProgressPerHit * v2)
				count += 1
				self._progSpeedModifier.Value += self.config.ProgressSpeedPerHit * v2 / 100 * self.config.ProgressSpeedPerHitMultiply
				self:CreateHitVisual()
			end

			targetRegion.WasHit = true
			return
		end

		object2.fx:SpawnShake(p, 0.05, 0.25, 0.01, false)
		remoteEvent:FireServer(false)
		self.MetronomeHit:Fire(false)
		count2 += 1
		p.Details.Center.ImageColor3 = Color3.fromRGB(222, 104, 104)
		TweenService:Create(p.Details.Center, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			ImageColor3 = Color3.fromRGB(222, 222, 222)
		}):Play()
		object2:AddProgress(self.config.ProgressPerMiss)
		TweenService:Create(
			playSound(script.Miss, random:NextNumber(1.5, 2.5)),
			TweenInfo.new(0.3, Enum.EasingStyle.Linear),
			{
				PlaybackSpeed = 0.1
			}
		):Play()
	end)
	self.reelTrove:Add(ReplicatedStorage.events.debug_bpm.Event:Connect(function(BPM, fixedMusicOffset)
		self.config.BPM = BPM
		self.config.FixedMusicOffset = fixedMusicOffset
		self:LoadBPMRegions()
	end))
end

setmetatable(MetronomeBuff, module)
return MetronomeBuff