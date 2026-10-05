local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
local Signal = require(packages.Signal)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedDataHelper)
local SharedKeeperEnchant = require(modules.SharedKeeperEnchant)
require(modules.library.rods)
require(modules.library.fish)
require(modules.library.rods.enchants)
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers.HudController)
require(legacyControllers.InventoryController)
require(legacyControllers.PlayerController)
local v = Component.new({
	Tag = "AltarPillar",
	Ancestors = { workspace }
})
v.PillarUpdate = Signal.new()
Signal.new()

function v:Construct()
	self.trove = Trove.new()
end

function v:Update()
	v.PillarUpdate:Fire()
end

function v:Start()
	if not self.Instance:GetAttribute("OriginalPivot") then
		self.Instance:GetAttributeChangedSignal("OriginalPivot"):Wait()
	end

	self.trove:Add(self.Instance:GetAttributeChangedSignal("Active"):Connect(function()
		self:Update()
	end))
	local v2 = 0
	local now = 0
	local v3 = math.random() * 3.141592653589793
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		local primaryPart = self.Instance.PrimaryPart

		if not primaryPart or (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).Magnitude > 256 and tick() - now < 0.25 then
			return
		end

		local pivot = self.Instance:GetPivot()
		local smoothDamp, v5 = TweenService:SmoothDamp(
			pivot,
			self.Instance:GetAttribute("OriginalPivot") + (self.Instance:GetAttribute("Active") and Vector3.new(
				0,
				math.sin(time() / 2 + v3) * 2 + 17,
				0
			) or createVector(0, 0, 0)),
			v2,
			1,
			nil,
			tick() - now
		)
		now = tick()
		v2 = v5
		local magnitude = (pivot.Position - smoothDamp.Position).Magnitude

		if 0.1 * dt < magnitude then
			self.Instance:PivotTo(smoothDamp)
		end
	end))
	self.trove:Add(workspace:GetAttributeChangedSignal("PowerBurstActive"):Connect(function()
		if workspace:GetAttribute("PowerBurstActive") then
			self.Instance:SetAttribute("Active", SharedKeeperEnchant.IsPillarActive(Players.LocalPlayer, self.Instance))
		else
			self.Instance:SetAttribute("Active", false)
		end
	end))

	if workspace:GetAttribute("PowerBurstActive") then
		self.Instance:SetAttribute("Active", SharedKeeperEnchant.IsPillarActive(Players.LocalPlayer, self.Instance))
	end

	self:Update()
end

function v.Stop(p)
	p.trove:Clean()
end

return v