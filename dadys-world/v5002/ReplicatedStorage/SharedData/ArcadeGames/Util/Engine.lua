local Engine = {}
Engine.__index = Engine
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Menu = require(script.Parent:WaitForChild("Menu"))
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local Signal = require(ReplicatedStorage.SharedUtils.Signal)
local colorCorrection = Lighting:FindFirstChild("ColorCorrection")

if not colorCorrection then
	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Parent = Lighting
end

function Engine:ClearObjects()
	self.Parent:ClearAllChildren()
end

function Engine:Start()
	self:HideAllMenus()
	self:ClearObjects()
	self.Disconnected = false

	if not self.ConnectionMaid then
		self.ConnectionMaid = Maid.new()
	end

	self.Score = 0
end

function Engine:IncreaseScore(value)
	self.Score = (self.Score or 0) + (value or 1)
end

function Engine:tick(p2)
	if not self.AllowTick then
		return
	end

	for k, _object in pairs(self._objects) do
		local v2 = _object:tick(p2)

		if _object.CanEndGame then
			if v2 == -1 then
				return -1
			end
		elseif _object.Destroyed then
			table.remove(self._objects, k)
		end
	end

	return 1
end

function Engine.AddConnection(p, p2)
	if p.ConnectionMaid then
		p.ConnectionMaid:GiveTask(p2)
	end
end

function Engine:Disconnect()
	if self.Disconnected then
		return
	end

	self.Disconnected = true

	if self.ConnectionMaid then
		self.ConnectionMaid:Destroy()
		self.ConnectionMaid = nil
	end
end

function Engine:Stop()
	self._objects = {}
	self:Disconnect()
end

function Engine:Destroy()
	self.Destroyed = true
	self:Disconnect()
	self.Parent:ClearAllChildren()
	colorCorrection.Saturation = 0
	self.SurfaceGui.Enabled = false
end

function Engine:ShowMenu(p2)
	for k, v2 in pairs(self.Menus) do
		local v3 = k == p2
		v2:SetVisible(v3)

		if v3 and v2.Params.OnOpen then
			v2.Params.OnOpen(self, v2)
		end
	end
end

function Engine:HideAllMenus()
	self:ShowMenu(nil)
end

function Engine.AddMenu(p, childName, options)
	if p.Menus[childName] then
		return
	end

	local child = p.MenuFrames:FindFirstChild(childName)

	if not child then
		return
	end

	p.Menus[childName] = Menu.new(child, options or {}, p)
end

function Engine:RunMenuOption(callback, p2)
	if self._menuBusy then
		return
	end

	self._menuBusy = true
	local success, result = pcall(callback, p2)
	self._menuBusy = false

	if not success then
		warn("[ArcadeEngine] menu option errored: ", result)
	end
end

function Engine:AddObject(p2)
	self._objects[#self._objects + 1] = p2
end

function Engine:GetSound(childName: string)
	local surfaceGui = self.SurfaceGui

	if not surfaceGui then
		print("Surfacegui is destroyed")
		return
	end

	local sound = surfaceGui:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		return sound
	end

	print("No sound with name: " .. tostring(childName) .. " found!", surfaceGui)
end

function Engine:PlaySound(p: string)
	local sound = self:GetSound(p)

	if sound and sound:IsA("Sound") then
		sound:Play()
	end
end

function Engine:PlaySoundOneShot(p: string)
	local sound = self:GetSound(p)

	if not (sound and sound:IsA("Sound")) then
		return
	end

	local surfaceGui = self.SurfaceGui
	local clone = sound:Clone()
	clone.Name ..= "_temp"
	clone.Parent = surfaceGui
	clone:Play()
	Debris:AddItem(clone, 10)
end

function Engine.StopSound(p, childName: string)
	local surfaceGui = p.SurfaceGui

	if not surfaceGui then
		print("Surfacegui is destroyed")
		return
	end

	local sound = surfaceGui:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound:Stop()
	else
		print("No sound with name: " .. tostring(childName) .. " found!")
	end
end

function Engine.SetSoundVolume(p, childName, volume)
	local surfaceGui = p.SurfaceGui

	if not surfaceGui then
		print("Surfacegui is destroyed")
		return
	end

	local sound = surfaceGui:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound.Volume = volume
	else
		print("No sound with name: " .. tostring(childName) .. " found!")
	end
end

function Engine.BindMusicMute(p, list)
	local surfaceGui = p.SurfaceGui

	if not surfaceGui then
		return
	end

	local sounds = {}

	for _, childName in ipairs(list) do
		local sound = surfaceGui:FindFirstChild(childName)

		if sound and sound:IsA("Sound") then
			sounds[#sounds + 1] = sound
		end
	end

	if #sounds == 0 then
		return
	end

	for _, soundGroup in ipairs(CollectionService:GetTagged("MusicSource")) do
		if not soundGroup:IsA("SoundGroup") then
			continue
		end

		for _, v2 in ipairs(sounds) do
			v2.SoundGroup = soundGroup
		end

		return
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "ArcadeMusicBus"
	soundGroup.Parent = surfaceGui

	for _, v2 in ipairs(sounds) do
		v2.SoundGroup = soundGroup
	end

	local playerData = ReplicatedStorage:FindFirstChild("PlayerData")
	local child = playerData and playerData:FindFirstChild((tostring(Players.LocalPlayer.UserId)))
	local musicToggle = child and child:FindFirstChild("MusicToggle")

	if not musicToggle then
		warn("[Arcade] BindMusicMute: no MusicSource SoundGroup or MusicToggle found — arcade music will not follow Mute Music")
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply()
		soundGroup.Volume = musicToggle.Value and 0 or 1
	end

	apply() -- equivalent call inferred; original call site unknown
	local valueChangedConnection = musicToggle:GetPropertyChangedSignal("Value"):Connect(apply)
	soundGroup.Destroying:Connect(function()
		valueChangedConnection:Disconnect()
	end)
end

function Engine:SetAllowTick(p2)
	self.AllowTick = p2 == true
end

function Engine.SendShutdownSignal(p, ...)
	if p.Destroyed then
		return
	end

	p.ShutdownSignal:Fire(...)
end

function Engine.FetchLeaderboard(p)
	return p.Leaderboard and p.Leaderboard:Pull()
end

function Engine:SetLeaderboard(leaderboard)
	self.Leaderboard = leaderboard
end

function Engine.new(surfaceGui, screenGui)
	local object = setmetatable({}, Engine)
	object._id = tick()
	object._objects = {}
	object.Menus = {}
	object.ConnectionMaid = nil
	object._menuBusy = false
	object.ColorCorrection = colorCorrection
	object.Destroyed = false
	object.Disconnected = true
	object.AllowTick = true
	object.SurfaceGui = surfaceGui
	object.ScreenGui = screenGui
	object.MenuFrames = surfaceGui:WaitForChild("Menus", 10)
	local viewportFrame = surfaceGui:WaitForChild("ViewportFrame", 10)

	if not (object.MenuFrames and viewportFrame) then
		warn("[Engine] .new: SurfaceGui missing Menus/ViewportFrame — cannot build arcade")
		return nil
	end

	viewportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	object.Parent = viewportFrame:WaitForChild("WorldModel", 10)

	if not object.Parent then
		warn("[Engine] .new: ViewportFrame missing WorldModel — cannot build arcade")
		return nil
	end

	object.ShutdownSignal = Signal.new()
	object.Leaderboard = nil
	return object
end

return Engine