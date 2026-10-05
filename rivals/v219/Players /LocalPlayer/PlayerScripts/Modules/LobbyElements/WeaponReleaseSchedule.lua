local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.MatchmakingCountdown)
local Notifications = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Notifications)
local LooseWeaponDisplay = require(Players.LocalPlayer.PlayerScripts.Modules.LooseWeaponDisplay)
local SendChat = require(Players.LocalPlayer.PlayerScripts.Modules.Functions.SendChat)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._loose_weapon_displays = {}
	self._celebration_hash = 0
	self._celebration_queued = false
	self:_Init()
	return self
end

function object:GetLastReleasedWeapon()
	local _, v = ShopLibrary:GetUpcomingWeapon()
	local v2 = v and v - 1 or #ShopLibrary.OwnableWeaponReleaseSchedule
	return ShopLibrary.OwnableWeaponReleaseSchedule[v2], v2
end

function object:Refresh(p)
	local upcomingWeapon = ShopLibrary:GetUpcomingWeapon()
	local lastReleasedWeapon = self:GetLastReleasedWeapon()
	local v = not upcomingWeapon or ShopLibrary:GetTimeUntilWeaponRelease(lastReleasedWeapon) > -259200
	local v2 = v and lastReleasedWeapon or upcomingWeapon or lastReleasedWeapon

	for _, _loose_weapon_display in pairs(self._loose_weapon_displays) do
		_loose_weapon_display:SetLocked(not v)

		if _loose_weapon_display.CurrentWeapon ~= v2 then
			_loose_weapon_display:ChangeWeapon(v2)
		end

		if v then
			_loose_weapon_display:SetProximityPromptData("NEW WEAPON", "View")
		else
			local v3 = _loose_weapon_display
			_loose_weapon_display:SetProximityPromptData("COMING SOON", function()
				if v3.CurrentWeapon then
					return (Utility:TimeFormat2(ShopLibrary:GetTimeUntilWeaponRelease(v3.CurrentWeapon)))
				end

				return ""
			end)
		end
	end

	if p and v then
		task.delay(3, self._PlayCelebration, self)
	end
end

function object:Update(p2)
	for _, _loose_weapon_display in pairs(self._loose_weapon_displays) do
		_loose_weapon_display:Update(p2)
	end
end

function object:_EnableParticles(enabled)
	for k in pairs(self._loose_weapon_displays) do
		if enabled then
			Utility:PlayParticles(k.Particles.Emit)
			Utility:CreateSound("rbxassetid://120776960987657", 0.75, 1, k.Particles, true, 15)
			Utility:CreateSound("rbxassetid://75616400922980", 1, 1, k.Particles, true, 15)
		end

		for _, child in pairs(k.Particles.Attachment:GetChildren()) do
			child.Enabled = enabled
		end
	end
end

function object:_PlayCelebration()
	if TeleportService:GetTeleportSetting("PlayedWeaponReleaseCelebration") then
		return
	end

	if not FighterController.LocalFighter or FighterController.LocalFighter:Get("IsInDuel") or FighterController.LocalFighter:Get("IsInShootingRange") or MatchmakingCountdown:IsVisible() then
		self._celebration_queued = true
		return
	end

	TeleportService:SetTeleportSetting("PlayedWeaponReleaseCelebration", true)
	self._celebration_queued = false
	self._celebration_hash += 1
	local _celebration_hash = self._celebration_hash
	self:_EnableParticles(true)
	task.delay(10, function()
		if self._celebration_hash ~= _celebration_hash then
			return
		end

		self:_EnableParticles(false)
	end)
	return true
end

function object:_RefreshLoop()
	while true do
		local upcomingWeapon = ShopLibrary:GetUpcomingWeapon()

		if not upcomingWeapon then
			break
		end

		wait(ShopLibrary:GetTimeUntilWeaponRelease(upcomingWeapon))
		self:Refresh()
		self:_PlayCelebration()
		task.defer(SendChat, {
			Text = "[SERVER] A new weapon has been officially released - The <font weight=\"900\">" .. upcomingWeapon .. "</font>! Check out the Weapons page to learn more!",
			Color = Color3.fromRGB(100, 255, 50)
		})
		task.defer(Notifications.Play, Notifications, "New Weapon", "The " .. upcomingWeapon .. " has released!", {
			Name = upcomingWeapon
		}, nil, nil, "rbxassetid://128960987577700")
		wait(259200)
		self:Refresh()
	end
end

function object:_ModelAdded(instance)
	self._loose_weapon_displays[instance] = LooseWeaponDisplay.new(instance:WaitForChild("LooseWeaponDisplay"))
	self:Refresh()
end

function object:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function play_queued_celebration()
		if self._celebration_queued then
			self:_PlayCelebration()
		end
	end

	MatchmakingCountdown.VisibilityChanged:Connect(play_queued_celebration)
	v:GetDataChangedSignal("IsInShootingRange"):Connect(play_queued_celebration)
	v:GetDataChangedSignal("IsInDuel"):Connect(play_queued_celebration)
	play_queued_celebration() -- equivalent call inferred; original call site unknown
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyWeaponReleaseSchedule"):Connect(function(p)
		self:_ModelAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyWeaponReleaseSchedule")) do
		task.defer(self._ModelAdded, self, v)
	end

	self:Refresh(true)
	task.defer(self._HookLocalFighter, self)
	task.defer(self._RefreshLoop, self)
end

return object._new()