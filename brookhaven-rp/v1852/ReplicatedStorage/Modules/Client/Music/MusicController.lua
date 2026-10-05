local MusicController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MusicPlayerController = require(script.Parent.MusicPlayerController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local MusicABTestController = require(ReplicatedStorage.Modules.Client.Music.MusicABTestController)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = nil
local v2 = nil
MusicController.paused = false
MusicController.currentTracks = {}

local function LoadSoundIfNotLoadedYet(instance)
	if instance:GetAttribute("OriginalID") then
		if Platform.IsMobile() and instance:GetAttribute("DontLoadOnMobile") then
			instance:SetAttribute("OriginalID", nil)
		else
			instance.SoundId = instance:GetAttribute("OriginalID")
			instance:SetAttribute("OriginalID", nil)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyLazyLoad(instance)
	instance:SetAttribute("OriginalID", instance.SoundId)
	instance.SoundId = ""
end

function MusicController.IsAnyMusicPlaying()
	return #MusicController.currentTracks > 0
end

function MusicController.SetVolume(instance, p: number?, tweenInfo)
	if typeof(tweenInfo) == "number" then
		tweenInfo = TweenInfo.new(tweenInfo, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end

	TweenService:Create(instance, tweenInfo or TweenInfo.new(0.01), {
		Volume = p or instance:GetAttribute("OriginalVolume")
	}):Play()
end

local v3 = {}

function MusicController:Pause(tweenInfo)
	if typeof(tweenInfo) == "number" then
		tweenInfo = TweenInfo.new(tweenInfo, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end

	if self then
		if tweenInfo then
			local tween = TweenService:Create(self, tweenInfo, {
				Volume = 0
			})
			v3[self] = tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					self:Pause()
					ApplyLazyLoad(self) -- equivalent call inferred; original call site unknown
					v3[self] = nil
				end
			end)
			tween:Play()
		else
			self:Pause()
			ApplyLazyLoad(self) -- equivalent call inferred; original call site unknown
		end
	else
		MusicController.paused = true

		for _, currentTrack in MusicController.currentTracks do
			currentTrack:Pause()
		end
	end
end

function MusicController:Resume(tweenInfo)
	if typeof(tweenInfo) == "number" then
		tweenInfo = TweenInfo.new(tweenInfo, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end

	if v3[self] then
		v3[self]:Disconnect()
		v3[self] = nil
	end

	if self then
		LoadSoundIfNotLoadedYet(self)

		if tweenInfo and not self.Playing then
			self.Volume = 0
		end

		TweenService:Create(self, tweenInfo or TweenInfo.new(0.01), {
			Volume = self:GetAttribute("OriginalVolume")
		}):Play()
		self:Resume()
	else
		MusicController.paused = false

		for _, currentTrack in MusicController.currentTracks do
			LoadSoundIfNotLoadedYet(currentTrack)
			currentTrack:Resume()
		end
	end
end

function MusicController:Play(tweenInfo)
	if typeof(tweenInfo) == "number" then
		tweenInfo = TweenInfo.new(tweenInfo, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	end

	table.insert(MusicController.currentTracks, self)

	if MusicController.paused then
		self.Playing = false
		return
	end

	LoadSoundIfNotLoadedYet(self)

	if self.Playing then
		return
	end

	self:Play()

	if tweenInfo then
		self.Volume = 0
		TweenService:Create(self, tweenInfo, {
			Volume = self:GetAttribute("OriginalVolume")
		}):Play()
	end
end

function MusicController.SetActivationSource(p: string, p2)
	v = p2
	v2 = p
end

function MusicController.GetActivationSource()
	return v, v2
end

function MusicController.OpenMusicMenu(p: string, p2, p3: string?, instance)
	if PanelController.IsOpen("MainGUIHandler", "MainAudio") then
		MusicPlayerController.ResetMusicContext()
		PanelController.Close("MainGUIHandler", "MainAudio")
	else
		MusicController.SetActivationSource(p, p2)
		local expect = MusicABTestController.ShouldRunABTest():expect()
		ABTest.GetExperimentVariable("music-purchase-flow", "prompt-on-button-interact"):timeout(3):andThen(function(flag: boolean)
			if flag and expect and not UnlockableController.IsFeatureUnlocked(v.id, Gamepasses.MUSIC_UNLOCKED) then
				GamepassController.Show(
					Gamepasses.MUSIC_UNLOCKED,
					nil,
					p,
					nil,
					v,
					nil,
					p,
					instance and instance.Name,
					function()
						if instance ~= nil and instance.Parent == nil or PanelController.IsOpen(
							"MainGUIHandler",
							"MainAudio"
						) then
							return
						end

						if p3 then
							MusicPlayerController.SetMusicContext(p3, instance)
						else
							MusicPlayerController.ResetMusicContext()
						end

						PanelController.Open("MainGUIHandler", "MainAudio")
						MusicController.SetAudioUISize()
					end
				)
				return
			end

			if p3 then
				MusicPlayerController.SetMusicContext(p3, instance)
			else
				MusicPlayerController.ResetMusicContext()
			end

			PanelController.Open("MainGUIHandler", "MainAudio")
			MusicController.SetAudioUISize()
		end):catch(warn)
	end
end

function MusicController.SetAudioUISize()
	local scrollingFrame = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("MainAudio").Catalog.Container.ScrollingFrame
	local total = 0

	for _, frame in scrollingFrame:GetChildren() do
		if not (frame:IsA("Frame") and frame.Visible) then
			continue
		end

		if frame:FindFirstChild("UIGridLayout") then
			total += frame.UIGridLayout.AbsoluteContentSize.Y
		else
			total += frame.AbsoluteSize.Y
		end
	end

	local v4 = total * 1.02
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, v4)
end

function MusicController.CloseMusicMenu()
	PanelController.Close("MainGUIHandler", "MainAudio")
end

function MusicController:Stop(tweenInfo)
	if typeof(tweenInfo) == "number" then
		tweenInfo = TweenInfo.new(tweenInfo, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end

	local index = table.find(MusicController.currentTracks, self)

	if index then
		if tweenInfo and self.Playing then
			local tween = TweenService:Create(self, tweenInfo, {
				Volume = 0
			})
			tween:Play()
			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					self:Stop()
				end
			end)
		elseif self.Playing then
			self:Stop()
		end

		table.remove(MusicController.currentTracks, index)
	end
end

local v4 = {}

function MusicController.EnableSettingsUI(p: string)
	v4[p] = true
	PanelController.Open("MainGUIHandler", "MusicSettingsFrame")
end

function MusicController.DisableSettingsUI(p: string)
	v4[p] = nil

	for _, v5 in v4 do
		if v5 then
			return
		end
	end

	PanelController.Close("MainGUIHandler", "MusicSettingsFrame")
end

function MusicController.FrameworkInit() end

function MusicController.FrameworkStart()
	Remotes.connect("ClientMusic", function(p, p2, ...)
		assert(MusicController[p], "Invalid call type for ClientMusic event: " .. p)
		MusicController[p](p2, ...)
	end)
end

return MusicController