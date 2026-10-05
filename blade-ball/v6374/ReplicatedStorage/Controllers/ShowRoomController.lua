local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.LimitedSwordEvent)
require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Common.MarketplaceService)
require3(ReplicatedStorage2.Controllers.GiftingController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v4 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local v8 = require3(ReplicatedStorage2.Shared.JumpModifiers)
require3(ReplicatedStorage2.Packages.Net)
local v9 = require3(ReplicatedStorage2.ServerInfo)
local v10 = require3(script.ShowRoomUtility)
local v11 = nil
local remotes = ReplicatedStorage2.Remotes
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local currentCamera = workspace.CurrentCamera
ReplicatedStorage2.Misc:FindFirstChild("LimitedSwordShowRoom")
local ShowRoomController = {}
ShowRoomController.ShowRooms = {}
ShowRoomController.ShowRoomOpened = v2.new()
ShowRoomController.ShowRoomClosed = v2.new()

function ShowRoomController:Get(p2)
	if not ReplicatedStorage2.FeaturesToggle.LimitedSwords.Value then
		return
	end

	local info = v11[p2]

	if not info then
		warn((`ShowRoom {p2} not found`))
		return
	end

	local showRoom = self.ShowRooms[p2]

	if showRoom then
		return showRoom
	end

	local clone = info.Template:Clone()
	clone.Parent = ReplicatedStorage2.Misc

	if typeof(info.BeforeInit) == "function" then
		info.BeforeInit(clone)
	end

	local v13 = {
		Instance = clone,
		Trove = v.new(),
		Info = info
	}
	self.ShowRooms[p2] = v13

	if typeof(info.AfterInit) == "function" then
		info.AfterInit(v13)
	end

	return v13
end

function ShowRoomController:Update()
	local showRoom = self.ShowRoom
	local v12 = showRoom ~= nil

	if not self.IgnoreCamera then
		local v13 = currentCamera
		local cameraType

		if v12 then
			cameraType = Enum.CameraType.Scriptable
		else
			cameraType = Enum.CameraType.Custom
		end

		v13.CameraType = cameraType

		if showRoom then
			currentCamera.CFrame = v10:GetCameraCFrameFor(currentCamera, showRoom.Instance)
			return
		end

		local character = localPlayer.Character

		if character then
			currentCamera.CameraSubject = character:FindFirstChildWhichIsA("Humanoid")
		end
	end
end

function ShowRoomController:Open(UI, p, ignoreCamera, p2)
	if not ReplicatedStorage2.FeaturesToggle.LimitedSwords.Value then
		return
	end

	local character = localPlayer.Character

	if character and character:IsDescendantOf(workspace.Alive) then
		return
	end

	self:Close()
	self.ShowRoomOpened:Fire(p)
	local showRoom = self:Get(p)

	if not showRoom then
		warn((`ShowRoom {p} not found`))
		return
	end

	local trove = showRoom.Trove
	local instance = showRoom.Instance
	local info = showRoom.Info
	instance.Parent = currentCamera
	self._cameraCFrame = currentCamera.CFrame
	currentCamera.CameraType = Enum.CameraType.Scriptable

	if typeof(info.BeforeShow) == "function" then
		info.BeforeShow(showRoom)
	end

	self.ShowRoom = showRoom
	self.UI = UI
	self.IgnoreCamera = ignoreCamera
	local cameraCFrameFor

	if ignoreCamera then
		cameraCFrameFor = nil
	else
		cameraCFrameFor = v10:GetCameraCFrameFor(currentCamera, instance)
		currentCamera.CFrame = cameraCFrameFor
	end

	playerGui.announcer.Enabled = false
	local touchGui = playerGui:FindFirstChild("TouchGui")

	if touchGui then
		touchGui.Enabled = false
	end

	v3:Hide("ShowRoom")
	task.defer(v5, Enum.CoreGuiType.Chat, v9.isTestGame() and UI == "AFKWorld")
	task.defer(v5, Enum.CoreGuiType.PlayerList, false)

	if v9.isRankedLobbyServer() then
		playerGui.RankedSelection.Enabled = false
	end

	if UI and not (v6:IsOpen(UI) or p2) then
		v6:CloseCurrent(true)
	end

	local character2 = localPlayer.Character

	if character2 then
		v7:SetModifierFor(character2, "ShowRoom", v7.Utils.MinDebuff(character2, 0), v7.Priority.ADD)
		v8:SetModifierFor(character2, "ShowRoom", v8.Utils.MinDebuff(character2, 0), v8.Priority.ADD)
	end

	if not ignoreCamera then
		trove:Add(currentCamera.Changed:Connect(function()
			if currentCamera.CameraType ~= Enum.CameraType.Scriptable or currentCamera.CFrame ~= cameraCFrameFor then
				self:Update()
			end
		end))
	end

	if UI then
		trove:Add(v6:OnGuiClose(UI, function()
			trove:Add(task.delay(0.2, function()
				if not v6:IsOpen("GiftingUI") then
					self:Close()
				end
			end))
		end))
	end

	if v9.isRankedLobbyServer() or v9.isDuelLobbyServer() then
		local character3 = localPlayer.Character

		if character3 then
			trove:Add(character3.AncestryChanged:Once(function()
				if not v6:IsOpen("GiftingUI") then
					v6:Unlock("GiftingUI", true)
					v6:Close("GiftingUI")
				end

				self:Close()
			end))
		end
	else
		self._lastAFKStatus = remotes.getAFKStatus:InvokeServer()

		if not self._lastAFKStatus then
			remotes.ChangedAfkMode:FireServer(true)
		end
	end

	if UI then
		v6:Open(UI, true, p2)
		v6:Lock(UI, true)
		v4.IsUICovered:SetTag("Showroom", true)
	end

	if typeof(info.AfterShow) == "function" then
		info.AfterShow(showRoom)
	end

	self:Update()
end

function ShowRoomController:Close()
	if self._lastAFKStatus ~= nil then
		remotes.ChangedAfkMode:FireServer(self._lastAFKStatus)
		self._lastAFKStatus = nil
	end

	local showRoom = self.ShowRoom

	if not showRoom then
		return
	end

	showRoom.Trove:Destroy()
	v6:Unlock("Battlepass", true)
	v6:Close("Battlepass", true)
	local _cameraCFrame = self._cameraCFrame

	if _cameraCFrame then
		currentCamera.CFrame = _cameraCFrame
		self._cameraCFrame = nil
	end

	local _ = localPlayer.Character
	local character = localPlayer.Character

	if character then
		v7:RemoveModifierFor(character, "ShowRoom")
		v8:RemoveModifierFor(character, "ShowRoom")
	end

	showRoom.Instance.Parent = ReplicatedStorage2.Misc
	playerGui.announcer.Enabled = true
	local touchGui = playerGui:FindFirstChild("TouchGui")

	if touchGui then
		touchGui.Enabled = true
	end

	v3:Show("ShowRoom")
	v5(Enum.CoreGuiType.PlayerList, true)
	v5(Enum.CoreGuiType.Chat, true)

	if v9.isRankedLobbyServer() then
		playerGui.RankedSelection.Enabled = true
	end

	local UI = self.UI

	if UI then
		v4.IsUICovered:SetTag("Showroom", false)
		v6:Unlock(UI, true)
		v6:Close(UI, true)
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = character and character:FindFirstChildWhichIsA("Humanoid")
	self.UI = nil
	self.ShowRoom = nil
	self.IgnoreCamera = nil
	self.ShowRoomClosed:Fire(showRoom)
	self:Update()
end

function ShowRoomController.Init(_)
	v11 = require3(script.ShowRooms)
end

return ShowRoomController