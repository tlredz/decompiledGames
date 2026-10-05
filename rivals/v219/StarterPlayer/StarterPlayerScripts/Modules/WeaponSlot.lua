local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local VoteBanFrame = require(Players.LocalPlayer.PlayerScripts.Modules.VoteBanFrame)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local weaponSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("WeaponSlot")
local WeaponSlot = {}
WeaponSlot.__index = WeaponSlot

function WeaponSlot.new(name, weaponData)
	local self = setmetatable({}, WeaponSlot)
	self.PlayBanFrameSound = Signal.new()
	self.Name = name
	self.WeaponData = weaponData
	self.Frame = weaponSlot:Clone()
	self._destroyed = false
	self._vote_ban_frame = nil
	self:_Init()
	return self
end

function WeaponSlot.DisableButton(p)
	p.Frame.Button.Interactable = false
end

function WeaponSlot.ToggleBanned(p, duration, p2)
	p.Frame.Button.Icon.ClipsDescendants = true
	p.Frame.Button.Title.Visible = false
	local v = VoteBanFrame.new(p.Frame.Button, UDim2.new(0.75, 0, 0.75, 0))
	v.CreateSound:Connect(function(...)
		p.PlayBanFrameSound:Fire(...)
	end)
	task.delay(duration, v.Play, v, p2, true)
end

function WeaponSlot.HideName(p)
	p.Frame.Button.Title.Text = "???"
end

function WeaponSlot.Lock(p)
	p.Frame.Button.Locked.Visible = true
	p.Frame.Button.Title.TextTransparency = 0.5
	p.Frame.Button.Icon.Picture.ImageColor3 = Color3.fromRGB(0, 0, 0)
	p.Frame.Button.Icon.Picture.ImageTransparency = 0.5
end

function WeaponSlot:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self.PlayBanFrameSound:Destroy()

	if self._vote_ban_frame then
		self._vote_ban_frame:Destroy()
	end

	pcall(function()
		self.Frame:Destroy()
	end)
end

function WeaponSlot:_Setup()
	self.Frame.Button.Title.Text = self.Name
	self.Frame.Button.Icon.Picture.Image = self.WeaponData and ItemLibrary:GetViewModelImageFromWeaponData(self.WeaponData) or ItemLibrary:GetViewModelImage(self.Name) or ""
	WeaponStatusHandler:ApplyItemStatusToBackground(
		self.Frame.Button.Background,
		self.Frame.Button.Background.UIStroke,
		ItemLibrary.Items[self.Name].Status
	)
end

function WeaponSlot:_Init()
	self.Frame.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_Setup()
	ButtonEffect:Add(self.Frame.Button)
end

return WeaponSlot