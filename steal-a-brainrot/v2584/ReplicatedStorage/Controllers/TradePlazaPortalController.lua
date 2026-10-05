local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local TradePlazaPartitions = require(ReplicatedStorage.Shared.TradePlazaPartitions)
require(ReplicatedStorage.Shared.Updates)
local remoteEvent = Net:RemoteEvent("TradePlazaPortalService/Teleport")
local localPlayer = Players.LocalPlayer
local v = false
local v2 = false
local v3 = {}
local cframe = CFrame.new(0, -100000, 0)

local function canUsePortal()
	if not v then
		return false
	end

	if ServerData.IsJumpLTMServer() then
		return true
	end

	return not (ServerData.IsTradePlaza() or ServerData.IsDuelsServer() or ServerData.IsTsunamiServer() or ServerData.IsNewPlayersServer())
end

local function refreshAll()
	for k in v3 do
		k()
	end
end

local function meetsPartitionRequirement(p: string)
	local v4 = Synchronizer:Get(localPlayer)

	if not v4 then
		return false
	end

	local generation = v4:Get("Generation") or 0
	local podiumsHaveOGBrainrot = TradePlazaPartitions.podiumsHaveOGBrainrot(v4:Get("AnimalPodiums"))
	return TradePlazaPartitions.meetsRequirement(p, generation, podiumsHaveOGBrainrot)
end

local function canSelectPartition()
	return ServerData.TradePlazaProPlaceId ~= 0 and meetsPartitionRequirement("Pro")
end

return {
	Start = function(_)
		task.spawn(function()
			local v4 = Synchronizer:Wait(localPlayer)

			if not v4 then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				v = (v4:Get("Rebirth") or 0) >= 1

				for k in v3 do
					k()
				end
			end

			v4:OnChanged("Rebirth", update)
			update() -- equivalent call inferred; original call site unknown
		end)
		v2 = ReplicatedStorage:GetAttribute("3RoadsEvent") == true
		ReplicatedStorage:GetAttributeChangedSignal("3RoadsEvent"):Connect(function()
			v2 = ReplicatedStorage:GetAttribute("3RoadsEvent") == true

			for k in v3 do
				k()
			end
		end)
		Observers.observeTag("TradePlazaPortal", function(model)
			if not model:IsA("Model") then
				return
			end

			local maid = Trove.new()
			local pivot = model:GetPivot()

			local function apply()
				local v4

				if v2 then
					v4 = pivot + createVector(-20, 0, 0)
				else
					v4 = pivot
				end

				if canUsePortal() then
					model:PivotTo(v4)
				else
					model:PivotTo(v4 * cframe)
				end
			end

			v3[apply] = true
			maid:Add(function()
				v3[apply] = nil

				if model.Parent then
					pcall(function()
						model:PivotTo(pivot)
					end)
				end
			end)

			if v2 then
				pivot += createVector(-20, 0, 0)
			end

			if canUsePortal() then
				model:PivotTo(pivot)
			else
				model:PivotTo(pivot * cframe)
			end

			return function()
				maid:Destroy()
			end
		end)
		Observers.observeTag("TradePlazaPortalPrompt", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return
			end

			local maid = Trove.new()
			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

			-- equivalent calls inferred from this helper; original call sites unknown
			local function apply()
				proximityPrompt.Enabled = canUsePortal()
			end

			maid:Add(proximityPrompt.Triggered:Connect(function()
				if not canUsePortal() or ConfirmationController:IsInPrompt() then
					return
				end

				local v4

				if ServerData.TradePlazaProPlaceId == 0 then
					v4 = false
				else
					v4 = meetsPartitionRequirement("Pro")
				end

				if v4 then
					local v8 = ConfirmationController:ShowTradePlazaJoin({
						Normal = true,
						Pro = true,
						OG = ServerData.TradePlazaOgPlaceId ~= 0 and meetsPartitionRequirement("OG")
					}, 300)

					if not v8 then
						return
					end

					remoteEvent:FireServer(v8)
				else
					if not ConfirmationController:Show(
						"Are you sure you want to join the <font color=\"rgb(64, 156, 255)\">Trade Plaza</font>?",
						300,
						"JoinCancel"
					) then
						return
					end

					remoteEvent:FireServer("Normal")
				end
			end))
			v3[apply] = true
			maid:Add(function()
				v3[apply] = nil
			end)
			apply() -- equivalent call inferred; original call site unknown
			return function()
				maid:Destroy()
			end
		end)
	end
}