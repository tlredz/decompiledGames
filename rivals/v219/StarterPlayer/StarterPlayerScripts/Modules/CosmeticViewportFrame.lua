local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("StaticModel"):WaitForChild("StaticViewModel"))
local ViewportCameras = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewportCameras"))
local cosmeticViewportFrame = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticViewportFrame")
local wrap = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("Wrap")
local charms = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Charms")
local CosmeticViewportFrame = {}
CosmeticViewportFrame.__index = CosmeticViewportFrame

function CosmeticViewportFrame.new(name, isLocked)
	local self = setmetatable({}, CosmeticViewportFrame)
	self.Name = name
	self.Info = CosmeticLibrary.Cosmetics[self.Name]
	self.IsLocked = isLocked
	self.Frame = cosmeticViewportFrame:Clone()
	self:_Init()
	return self
end

function CosmeticViewportFrame.ZoomOut(p)
	p.Frame.Size = UDim2.new(
		p.Frame.Size.X.Scale * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.X.Offset * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.Y.Scale * ViewportCameras.ZOOM_OUT_FACTOR,
		p.Frame.Size.Y.Offset * ViewportCameras.ZOOM_OUT_FACTOR
	)
	local frame = p.Frame
	local charmZoomedOut

	if p.Info.Type == "Charm" then
		charmZoomedOut = ViewportCameras.CharmZoomedOut
	elseif p.Info.Type == "Wrap" then
		charmZoomedOut = ViewportCameras.WrapZoomedOut
	else
		charmZoomedOut = p.Frame.CurrentCamera
	end

	frame.CurrentCamera = charmZoomedOut
end

function CosmeticViewportFrame:Destroy()
	self.Frame:Destroy()
end

function CosmeticViewportFrame._SetupSeasonRankCharm(p, p2)
	if #p.Name < 8 or string.sub(p.Name, 1, 7) ~= "Season " then
		return
	end

	local v = tonumber((string.sub(p.Name, 8)))

	if not v then
		return
	end

	local name = SeasonLibrary.SeasonsByVersion[v].Name
	local seasonInfo, v2 = PlayerDataUtility:GetSeasonInfo(PlayerDataController, name)
	SeasonLibrary:FormatSeasonRankCharm(p2, name, seasonInfo, v2)
end

function CosmeticViewportFrame:_Setup()
	self.Frame.ImageColor3 = self.IsLocked and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	self.Frame.ImageTransparency = self.IsLocked and 0.5 or 0

	if self.Name ~= "NONE_COSMETIC" and self.Name ~= "RANDOM_COSMETIC" then
		if self.Info.Type == "Charm" then
			local clone = charms[self.Name]:Clone()
			clone.PrimaryPart = clone.Primary
			clone:PivotTo(CFrame.identity)
			clone.Hook:Destroy()
			clone.Parent = self.Frame
			task.defer(self._SetupSeasonRankCharm, self, clone)
			self.Frame.CurrentCamera = ViewportCameras.Charm
		elseif self.Info.Type == "Wrap" then
			local clone = wrap:Clone()
			clone:PivotTo(CFrame.identity)
			clone.Parent = self.Frame
			WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), {
				Name = self.Name
			})
			self.Frame.CurrentCamera = ViewportCameras.Wrap
		end
	end
end

function CosmeticViewportFrame:_Init()
	self:_Setup()
end

return CosmeticViewportFrame