local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ViewportCameras = require(Players.LocalPlayer.PlayerScripts.Modules.ViewportCameras)
local emoteViewportFrame = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EmoteViewportFrame")
local emoteDummy = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("EmoteDummy")
local emotes = ReplicatedStorage.Modules.Emotes
local EmoteViewportFrame = {}
EmoteViewportFrame.__index = EmoteViewportFrame

function EmoteViewportFrame.new(name, value)
	assert(CosmeticLibrary.Cosmetics[name].Type == "Emote")
	local self = setmetatable({}, EmoteViewportFrame)
	self.Name = name
	self.Frame = emoteViewportFrame:Clone()
	self.EmoteGlow = self.Frame.EmoteGlow
	self._destroyed = false
	self._world_model = self.Frame.WorldModel
	self._playing_emotes_hash = 0
	self._dummy = nil
	self._last_emote = nil
	self._fade_speed = self.Name == "MISSING_EMOTE" and 1e999 or value or 1
	self._is_locked = false
	self:_Init()
	return self
end

function EmoteViewportFrame.SetParent(p, parent)
	p.Frame.Parent = parent
	p.EmoteGlow.Parent = parent
end

function EmoteViewportFrame:SetLocked(is_locked)
	self._is_locked = is_locked
	self.Frame.ImageColor3 = self._is_locked and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	self.Frame.ImageTransparency = self:_GetImageTransparency()
end

function EmoteViewportFrame.HideShadow(p)
	p.EmoteGlow.Visible = false
end

function EmoteViewportFrame.ZoomOut(p)
	local size = p.Frame.Size
	p.Frame.Size = UDim2.new(
		p.Frame.Size.X.Scale * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.X.Offset * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.Y.Scale * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.Y.Offset * ViewportCameras.ZOOM_OUT_FACTOR
	)
	p.Frame.Position = UDim2.new(
		p.Frame.Position.X.Scale,
		p.Frame.Position.X.Offset,
		p.Frame.Position.Y.Scale - size.Y.Scale * 0.5 + p.Frame.Size.Y.Scale * 0.5,
		p.Frame.Position.Y.Offset - size.Y.Offset * 0.5 + p.Frame.Size.Y.Offset * 0.5
	)
	p.Frame.CurrentCamera = ViewportCameras.EmoteZoomedOut
end

function EmoteViewportFrame:Destroy()
	self._destroyed = true
	self._playing_emotes_hash += 1
	self.Frame:Destroy()
	self:_Clear()
end

function EmoteViewportFrame:_GetImageTransparency()
	if self._is_locked then
		return 0.5
	end

	return 0
end

function EmoteViewportFrame:_IsActuallyVisible()
	if not (self.Frame:IsDescendantOf(workspace) or Players.LocalPlayer:FindFirstChild("PlayerGui") and self.Frame:IsDescendantOf(Players.LocalPlayer.PlayerGui)) then
		return false
	end

	local frame = self.Frame

	while frame and not frame:IsA("LayerCollector") do
		frame = frame.Parent
	end

	if not (frame and frame.Enabled) then
		return false
	end

	local frame2 = self.Frame

	while frame2.Visible do
		frame2 = frame2.Parent

		if frame2 == frame then
			return true
		end
	end

	return false
end

function EmoteViewportFrame:_Clear()
	if self._dummy then
		self._dummy:Destroy()
		self._dummy = nil
	end

	if self._last_emote then
		self._last_emote:Destroy()
		self._last_emote = nil
	end
end

function EmoteViewportFrame:_PlayEmote()
	if self._destroyed then
		return
	end

	self._playing_emotes_hash += 1
	local _playing_emotes_hash = self._playing_emotes_hash
	self:_Clear()

	while not self:_IsActuallyVisible() do
		wait(1)

		if self._playing_emotes_hash ~= _playing_emotes_hash then
			return
		end
	end

	while true do
		local lastTime = tick()
		self._dummy = emoteDummy:Clone()
		self._dummy:PivotTo(CosmeticLibrary.Cosmetics[self.Name].ViewportCFrameOffset)
		self._dummy.Parent = self._world_model
		Utility:RenderstepForLoop(0, 100, 4 * self._fade_speed, function(p)
			if self._playing_emotes_hash ~= _playing_emotes_hash then
				return true
			end

			local v = (p / 100) ^ 3
			self.Frame.ImageTransparency = 1 + (self:_GetImageTransparency() - 1) * v
			self.EmoteGlow.ImageTransparency = 1 + -0.5 * v
		end)

		if self._playing_emotes_hash ~= _playing_emotes_hash then
			break
		end

		if self._dummy:FindFirstChild("Humanoid") then
			local module = require(emotes[self.Name])
			self._last_emote = module.new(self._dummy.Humanoid)
			task.defer(self._last_emote.Simulate, self._last_emote)
			self._last_emote.Destroying:Wait()
		end

		Utility:RenderstepForLoop(0, 100, 4 * self._fade_speed, function(p)
			if self._playing_emotes_hash ~= _playing_emotes_hash then
				return true
			end

			local v = 1 - (1 - p / 100) ^ 3
			self.Frame.ImageTransparency = self:_GetImageTransparency() + (1 - self:_GetImageTransparency()) * v
			self.EmoteGlow.ImageTransparency = 0.5 + 0.5 * v
		end)

		if self._playing_emotes_hash ~= _playing_emotes_hash then
			break
		end

		self:_Clear()
		wait(1 - (tick() - lastTime))

		if self._playing_emotes_hash ~= _playing_emotes_hash then
			break
		end
	end
end

function EmoteViewportFrame:_Setup()
	self.Frame.CurrentCamera = ViewportCameras.Emote
end

function EmoteViewportFrame:_Init()
	self.Frame.AncestryChanged:Connect(function()
		self:_PlayEmote()
	end)
	self:_Setup()
	task.spawn(self._PlayEmote, self)
end

return EmoteViewportFrame