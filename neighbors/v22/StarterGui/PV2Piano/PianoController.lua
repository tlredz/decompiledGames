local Signal = require(script.Signal)
local PianoController = {}
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local controls = nil
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local clone = nil
local clone2 = nil
local clone3 = nil
PianoController.Active = false
PianoController.Piano = nil
PianoController.Transposition = 0
PianoController.Volume = 1
PianoController.Velocity = 1
PianoController.SoundFont = 1
PianoController.Sustain = true
PianoController.ShiftLock = false
PianoController.Device = "Desktop"
PianoController._LETTER_NOTE_MAP = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
PianoController._LETTER_88_MAP = "trewq0987654321yuiopasdfghj"
PianoController._LETTER_VELOCITY_MAP = "1234567890qwertyuiopasdfghjklzxc"
PianoController._VELOCITY_CURVES = nil
PianoController._activeQueue = false
PianoController._soundQueue = {}
PianoController._keyDownLookup = {
	[localPlayer] = {}
}
PianoController._keyboardPressConnection = nil
PianoController._keyboardReleaseConnection = nil
PianoController._preloadedSoundFonts = {}
PianoController.NotePressed = Signal.new()
PianoController.NoteReleased = Signal.new()
PianoController.SustainToggled = Signal.new()
PianoController.KeyPressed = Signal.new()
PianoController.KeyReleased = Signal.new()
PianoController.SustainChanged = Signal.new()
PianoController.ShiftLockChanged = Signal.new()
PianoController.TranspositionChanged = Signal.new()
PianoController.VolumeChanged = Signal.new()
PianoController.VelocityChanged = Signal.new()
PianoController.SoundFontChanged = Signal.new()
PianoController.CameraChanged = Signal.new()
PianoController.Activated = Signal.new()
PianoController.Deactivated = Signal.new()
PianoController.DeviceChanged = Signal.new()

function PianoController:_startSoundQueue()
	if self._activeQueue then
		warn("[PianoController]: Attempted to start queue when already active")
		return
	end

	self._activeQueue = true
	task.spawn(function()
		while self._activeQueue do
			if #self._soundQueue == 0 then
				self:_stopSoundQueue()
				break
			end

			local v6 = #self._soundQueue - clone3.MaxSounds
			local v7 = RunService.Heartbeat:Wait()
			local v8 = 1

			for i, v9 in ipairs(self._soundQueue) do
				if v6 > 0 then
					self._soundQueue[i] = nil
					v9:Destroy()
					v6 -= 1
				elseif v9.State == "Destroying" then
					self._soundQueue[i] = nil
				else
					if v9.State == "Active" then
						if not self._keyDownLookup[v9.Source] then
							v9:Destroy()
							continue
						end

						if v9.Sustained or self._keyDownLookup[v9.Source][v9.Index] then
							v9.Lifetime += v7

							if v9.Lifetime >= v9.MaxLifetime then
								v9:Fade()
							end

							if clone3.PlayServerOrigin and typeof(v9.Origin) == "Instance" and v9.Origin:IsA("BasePart") then
								v9.Sound.Volume = v9.Volume / ((v9.Origin.Position - currentCamera.CFrame.Position).Magnitude / clone3.OriginInverseMultiplier)
							end
						else
							v9:Fade()
						end
					end

					if v8 ~= i then
						self._soundQueue[v8] = v9
						self._soundQueue[i] = nil
					end

					v8 += 1
				end
			end
		end
	end)
end

function PianoController:_stopSoundQueue()
	if not self._activeQueue then
		warn("[PianoController]: Attempted to stop queue when already inactive")
		return
	end

	self._activeQueue = false

	for _, v6 in ipairs(self._soundQueue) do
		v6:Destroy()
	end

	table.clear(self._soundQueue)
end

function PianoController:PlayNoteSound(p, p2, p3, p4, p5, p6, p7, p8)
	local part = p2 or nil

	if clone3.PlayServerOrigin and typeof(part) == "Instance" and part:IsA("BasePart") then
		p5 *= clone3.OriginSoundMultiplier
	end

	if type(p7) ~= "table" then
		p7 = v2[p7]
	end

	local v6 = p8 == nil or p8
	local v7 = v5.new(p, part, p3, p4, p5, p6, p7, v6)

	if clone3.PlayServerOrigin and typeof(v7.Origin) == "Instance" and v7.Origin:IsA("BasePart") then
		v7.Sound.Volume = v7.Volume / ((v7.Origin.Position - currentCamera.CFrame.Position).Magnitude / clone3.OriginInverseMultiplier)
	end

	v7:Play()
	table.insert(self._soundQueue, v7)

	if not self._activeQueue then
		self:_startSoundQueue()
	end

	return v7
end

function PianoController:PressClientKey(p, p2, p3, p4, p5, p6, sustain)
	local v6 = p3 or self.Transposition or 0
	local v7 = p4 or self.Volume or 1
	local v8 = p5 or self.Velocity or 1
	local v9 = p6 or self.SoundFont or v.DEFAULT_SOUNDFONT

	if sustain == nil then
		sustain = self.Sustain
	end

	self._keyDownLookup[localPlayer][p] = true

	if clone3.PlayClientSounds then
		PianoController:PlayNoteSound(localPlayer, nil, p, p2 + v6, v7, v8, v9, sustain)
	end

	self.KeyPressed:Fire(p, p2, v6, v7, v8, v9, sustain)
	self.NotePressed:Fire(localPlayer, self.Piano, p, p2, v6, v7, v8, v9, sustain)
end

function PianoController:ReleaseClientKey(p)
	self._keyDownLookup[localPlayer][p] = nil
	self.KeyReleased:Fire(p)
	self.NoteReleased:Fire(localPlayer, self.Piano, p)
end

function PianoController:ToggleSustain(sustain, p)
	if sustain ~= nil and self.Sustain == sustain then
		return
	end

	if sustain == nil then
		sustain = not self.Sustain
	end

	self.Sustain = sustain

	for _, v6 in ipairs(self._soundQueue) do
		if v6.Source == localPlayer then
			v6.Sustained = self.Sustain
		end
	end

	self.SustainToggled:Fire(localPlayer, self.Piano, self.Sustain, p)
	self.SustainChanged:Fire(self.Sustain, p)
end

function PianoController:_pressServerKey(p2, p3, p4, p5, p6, p7, p8, p9, p10)
	local v6 = v3[p3]
	local origin

	if v6 then
		origin = v6.Origin
	end

	self._keyDownLookup[p2][p4] = true

	if clone3.PlayServerSounds then
		PianoController:PlayNoteSound(p2, origin, p4, p5 + p6, p7, p8, p9, p10)
	end

	self.NotePressed:Fire(p2, p3, p4, p5, p6, p7, p8, p9, p10)
end

function PianoController:_releaseServerKey(p2, p3, p4)
	self._keyDownLookup[p2][p4] = nil
	self.NoteReleased:Fire(p2, p3, p4)
end

function PianoController:_toggleServerSustain(p2, p3, sustained, p4)
	for _, v6 in ipairs(self._soundQueue) do
		if v6.Source == p2 then
			v6.Sustained = sustained
		end
	end

	self.SustainToggled:Fire(p2, p3, sustained, p4)
end

function PianoController:ChangeTransposition(p, p2)
	local transposition = self.Transposition
	self.Transposition = math.clamp(p + self.Transposition * (p2 and 0 or 1), v.MIN_TRANSPOSITION, v.MAX_TRANSPOSITION)
	self.TranspositionChanged:Fire(self.Transposition, self.Transposition - transposition)
end

function PianoController:ChangeVolume(p, p2)
	local volume = self.Volume
	self.Volume = math.clamp(p + self.Volume * (p2 and 0 or 1), v.MIN_VOLUME, v.MAX_VOLUME)
	self.VolumeChanged:Fire(self.Volume, self.Volume - volume)
end

function PianoController:ChangeVelocity(p, p2)
	local velocity = self.Velocity
	self.Velocity = math.clamp(p + self.Velocity * (p2 and 0 or 1), v.MIN_VELOCITY, v.MAX_VELOCITY)
	self.VelocityChanged:Fire(self.Velocity, self.Velocity - velocity)
end

function PianoController:ChangeSoundFont(DEFAULT_SOUNDFONT)
	if DEFAULT_SOUNDFONT == self.SoundFont then
		return
	end

	if not v2[DEFAULT_SOUNDFONT] then
		DEFAULT_SOUNDFONT = v.DEFAULT_SOUNDFONT
	end

	self.SoundFont = DEFAULT_SOUNDFONT
	self.SoundFontChanged:Fire(self.SoundFont)
end

function PianoController:ToggleShiftLock(shiftLock)
	if self.ShiftLock == shiftLock then
		return
	end

	if shiftLock == nil then
		shiftLock = not self.ShiftLock
	end

	self.ShiftLock = shiftLock
	self.ShiftLockChanged:Fire(self.ShiftLock)
end

function PianoController:ChangeCamera(value, p)
	if not self.Piano then
		return
	end

	local v6 = v3[self.Piano]

	if not v6.Camera then
		return
	end

	local camera = v6.Camera

	if type(camera) == "table" then
		self.Camera = p and math.clamp(value, 1, #camera) or (self.Camera + value - 1) % #camera + 1
		camera = camera[self.Camera]
	end

	v4:Play(currentCamera, tweenInfo, {
		CFrame = camera.CFrame
	})
	self.CameraChanged:Fire(self.Camera, camera.CFrame)
end

function PianoController:_connectKeyboardInput()
	if self._keyboardPressConnection or self._keyboardReleaseConnection then
		warn("[PianoController]: Attempted to connect to keyboard twice, disconnecting old connections")
		self:_disconnectKeyboardInput()
	end

	self._keyboardPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or gameProcessed or not self.Active then
			return
		end

		local keyCode = input.KeyCode
		local value = input.KeyCode.Value

		if value >= 48 and value <= 57 or value >= 97 and value <= 122 then
			if input:IsModifierKeyDown(2) and clone2.MIDIVelocity then
				local v6 = string.find(self._LETTER_VELOCITY_MAP, string.char(value), 1, true)

				if not v6 then
					return
				end

				self:ChangeVelocity(self._VELOCITY_CURVES[clone2.MIDICurve](v6), true)
			else
				local v6

				if input:IsModifierKeyDown(1) and clone2.MIDI88 then
					local v7 = string.find(self._LETTER_88_MAP, string.char(value), 1, true)

					if not v7 then
						return
					end

					v6 = (v7 <= 15 and 1 - v7 or 61 + v7 - 15) + (input:IsModifierKeyDown(0) and 1 or 0) * (self.ShiftLock and -1 or 1) + (self.ShiftLock and 1 or 0)
				else
					v6 = string.find(self._LETTER_NOTE_MAP, string.char(value), 1, true) + (input:IsModifierKeyDown(0) and 1 or 0) * (self.ShiftLock and -1 or 1) + (self.ShiftLock and 1 or 0)

					if not v6 then
						return
					end
				end

				self:PressClientKey(
					keyCode,
					v6,
					self.Transposition,
					self.Volume,
					self.Velocity,
					self.SoundFont,
					self.Sustain
				)
			end
		elseif keyCode == clone.Sustain and clone2.EnableSustainHotkey or keyCode == clone.ToggleSustain then
			self:ToggleSustain(nil, true)
		elseif keyCode == clone.ToggleShiftLock and clone2.EnableShiftLockHotkey then
			self:ToggleShiftLock()
		elseif keyCode == clone.TranspositionUp then
			self:ChangeTransposition(1)
		elseif keyCode == clone.TranspositionDown then
			self:ChangeTransposition(-1)
		elseif keyCode == clone.VolumeUp then
			self:ChangeVolume(0.1)
		elseif keyCode == clone.VolumeDown then
			self:ChangeVolume(-0.1)
		elseif keyCode == clone.ChangeCamera then
			self:ChangeCamera(1)
		elseif keyCode == clone.Exit then
			self:Deactivate()
		end
	end)
	self._keyboardReleaseConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or gameProcessed or not self.Active then
			return
		end

		local keyCode = input.KeyCode
		local value = input.KeyCode.Value

		if value >= 48 and value <= 57 or value >= 97 and value <= 122 then
			self:ReleaseClientKey(keyCode)
		elseif keyCode == clone.Sustain and clone2.EnableSustainHotkey then
			self:ToggleSustain(nil, false)
		end
	end)
end

function PianoController:_disconnectKeyboardInput()
	if self._keyboardPressConnection then
		self._keyboardPressConnection:Disconnect()
	end

	if self._keyboardReleaseConnection then
		self._keyboardReleaseConnection:Disconnect()
	end

	self._keyboardPressConnection = nil
	self._keyboardReleaseConnection = nil
end

function PianoController.AnimateKeyDown(_, p, p2, ...)
	if p == localPlayer and not clone3.PlayClientEffects or p ~= localPlayer and not clone3.PlayServerEffects then
		return
	end

	local v6 = v3[p2]

	if v6 and v6.AnimateKeyDown then
		v6.AnimateKeyDown(p, ...)
	end
end

function PianoController.AnimateKeyUp(_, p, p2, ...)
	if p == localPlayer and not clone3.PlayClientEffects or p ~= localPlayer and not clone3.PlayServerEffects then
		return
	end

	local v6 = v3[p2]

	if v6 and v6.AnimateKeyUp then
		v6.AnimateKeyUp(p, ...)
	end
end

function PianoController.AnimateSustainDown(_, p, p2, ...)
	if p == localPlayer and not clone3.PlayClientEffects or p ~= localPlayer and not clone3.PlayServerEffects then
		return
	end

	local v6 = v3[p2]

	if v6 and v6.AnimateSustainDown then
		v6.AnimateSustainDown(p, ...)
	end
end

function PianoController.AnimateSustainUp(_, p, p2, ...)
	if p == localPlayer and not clone3.PlayClientEffects or p ~= localPlayer and not clone3.PlayServerEffects then
		return
	end

	local v6 = v3[p2]

	if v6 and v6.AnimateSustainUp then
		v6.AnimateSustainUp(p, ...)
	end
end

function PianoController:Activate(piano)
	if self.Active then
		warn("[PianoController]: Attempted to activate while already active")
		return
	end

	self.Active = true
	self.Piano = piano
	controls:Disable()

	if localPlayer.Character then
		local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
		humanoid:UnequipTools()

		if humanoid then
			humanoid.JumpPower = 0
		end
	end

	self:_connectKeyboardInput()

	if self.Piano then
		self:ChangeCamera(1, true)
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	self.Activated:Fire(piano)

	if v3[piano].DefaultSoundFont then
		self:ChangeSoundFont(v3[piano].DefaultSoundFont)
	end

	if clone3.DisableCapturesHotkey then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)
	end

	script.Parent:SetAttribute("Visible", true)
	ProximityPromptService.Enabled = false
	localPlayer:SetAttribute("MutePianoTEMP", localPlayer:GetAttribute("MutePiano"))
	localPlayer:SetAttribute("MutePiano", false)
	localPlayer:SetAttribute("OnPiano", true)
end

function PianoController:Deactivate()
	if not self.Active then
		return
	end

	self.Active = false
	self.Piano = nil
	currentCamera.CameraType = Enum.CameraType.Custom
	self:_disconnectKeyboardInput()
	controls:Enable()

	if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
		local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
		local StarterPlayer = game:GetService("StarterPlayer")
		humanoid.JumpPower = StarterPlayer.CharacterJumpPower

		if humanoid and humanoid.Sit then
			humanoid.Sit = false
		end
	end

	self.Deactivated:Fire()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, true)
	script.Parent:SetAttribute("Visible", false)
	ProximityPromptService.Enabled = true
	localPlayer:SetAttribute("MutePiano", localPlayer:GetAttribute("MutePianoTEMP"))
	localPlayer:SetAttribute("MutePianoTEMP", nil)
	localPlayer:SetAttribute("OnPiano", nil)
end

function PianoController:ChangeDevice(device)
	if device ~= "Mobile" and device ~= "Desktop" then
		return
	end

	self.Device = device
	self.DeviceChanged:Fire(device)
end

function PianoController:PreloadSoundFont(p2)
	if self._preloadedSoundFonts[p2] then
		return
	end

	self._preloadedSoundFonts[p2] = true
	local v6 = v2[p2]

	if not v6 then
		return
	end

	task.spawn(function()
		local v7 = {}

		for _, assetId in ipairs(v6.AssetIds) do
			local sound = Instance.new("Sound")
			sound.SoundGroup = game.SoundService.Piano
			sound.SoundId = "https://roblox.com/asset/?id=" .. assetId
			sound.Parent = script
			table.insert(v7, sound)
		end

		ContentProvider:PreloadAsync(v7)

		for _, v8 in ipairs(v7) do
			v8:Destroy()
		end
	end)
end

function PianoController:_yield(p, p2)
	local v6 = p + p2 / 1000 - workspace:GetServerTimeNow()

	if v6 > 0 then
		task.wait(v6)
	end
end

function PianoController:Init()
	local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	controls = PlayerModule:GetControls()
	local DefaultSettings = require(script.DefaultSettings)
	v = DefaultSettings
	local SoundFonts = require(script.SoundFonts)
	v2 = SoundFonts
	local PianoModules = require(script.PianoModules)
	v3 = PianoModules
	local Tween = require(script.Tween)
	v4 = Tween
	local Note = require(script.Note)
	v5 = Note
	self.SoundFont = v.DEFAULT_SOUNDFONT
	self._VELOCITY_CURVES = v.DEFAULT_VELOCITY_CURVES

	for _, v6 in ipairs(Players:GetPlayers()) do
		self._keyDownLookup[v6] = {}
	end

	Players.PlayerAdded:Connect(function(player)
		self._keyDownLookup[player] = {}
	end)
	Players.PlayerRemoving:Connect(function(player)
		self._keyDownLookup[player] = nil
	end)
	clone = table.clone(v.DEFAULT_KEYBINDS)
	clone2 = table.clone(v.DEFAULT_PIANO_SETTINGS)
	clone3 = table.clone(v.DEFAULT_GAME_SETTINGS)
	PianoController.Keybinds = clone
	PianoController.PianoSettings = clone2
	PianoController.GameSettings = clone3
end

function PianoController:Start()
	local pianoEvent = script.Parent:WaitForChild("PianoEvent")
	pianoEvent.OnClientEvent:Connect(function(model, p, p2, p3, p4, p5)
		if typeof(model) == "Instance" and model:IsA("Model") then
			if p then
				self:Activate(model)
			else
				self:Deactivate()
			end
		else
			if clone3.DelayNoteEvents then
				self:_yield(p2, clone3.EventDelay)
			end

			if p3 == true then
				local v6, v7, v8, v9, v10, v11 = string.unpack("bbffBB", p5)
				self:_pressServerKey(model, p, p4, v6, v7, v8, v9, v10, v11 == 1)
			elseif p3 == false then
				self:_releaseServerKey(model, p, p4)
			elseif p3 == nil then
				self:_toggleServerSustain(model, p, p4, p5)
			end
		end
	end)
	localPlayer.CharacterRemoving:Connect(function()
		self:Deactivate()
	end)
	self.KeyPressed:Connect(function(p, p2, p3, p4, p5, p6, p7)
		if self.Active and self.Piano then
			local v6 = string.pack("bbffBB", p2, p3, p4, p5, p6, p7 and 1 or 0)
			pianoEvent:FireServer(workspace:GetServerTimeNow(), true, p, v6)
		end
	end)
	self.KeyReleased:Connect(function(p)
		if self.Active and self.Piano then
			pianoEvent:FireServer(workspace:GetServerTimeNow(), false, p)
		end
	end)
	self.SustainChanged:Connect(function(p, p2)
		if self.Active and self.Piano then
			pianoEvent:FireServer(workspace:GetServerTimeNow(), nil, p, p2)
		end
	end)
	PianoController.NotePressed:Connect(function(p, p2, p3, p4, p5, p6, p7, p8, p9)
		if p2 == nil then
			return
		end

		self:PreloadSoundFont(p8)
		self:AnimateKeyDown(p, p2, p3, p4, p5, p6, p7, p8, p9)
	end)
	PianoController.NoteReleased:Connect(function(p, p2, p3)
		if p2 == nil then
			return
		end

		self:AnimateKeyUp(p, p2, p3)
	end)
	PianoController.SustainToggled:Connect(function(p, p2, p3, p4)
		if p2 == nil then
			return
		end

		if p4 ~= false then
			self:AnimateSustainDown(p, p2, p3, p4)
		elseif false == false then
			self:AnimateSustainUp(p, p2, p3)
		end
	end)
	PianoController.SoundFontChanged:Connect(function(p)
		self:PreloadSoundFont(p)
	end)
end

return PianoController