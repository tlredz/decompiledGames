local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
game:GetService("TweenService")
game:GetService("SoundService")
game:GetService("ProximityPromptService")
game:GetService("MarketplaceService")
game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = ReplicatedStorage.shared.modules
require(shared.Monetization)
require(packages.Input)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
require(packages.Promise)
local Replion = require(packages.Replion)
require(packages.Signal)
require(ReplicatedStorage.client.legacyControllers.Shop.GiftController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local RodSkins = require(modules.RodSkins)
local playerDataReplicator = DataController.PlayerDataReplicator
local v = Replion.Client:WaitReplion("LimitedStockItems")

repeat
	task.wait()
until v:Get("Loaded") == true

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local ViewportModule = require(ReplicatedStorage.client.modules.ViewportModule)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local main = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shop"):WaitForChild("Products"):WaitForChild("Views"):WaitForChild("Main")
local limitedItems = main:WaitForChild("LimitedItems")
limitedItems:WaitForChild("Products")
local fetched = legacyLocalPlayerData.fetch()
local rods = playerDataReplicator

if rods then
	rods = playerDataReplicator.Data and playerDataReplicator.Data.Rods
end

local LimitedController = {
	Objects = {},
	Connections = {},
	Trove = Trove.new()
}

local function ConvertFormat(p)
	return string.format("%02i", p)
end

local function AttachToViewPort(parent, instance)
	local camera = Instance.new("Camera", parent)
	instance.Parent = parent
	parent.CurrentCamera = camera
	parent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	local v2 = ViewportModule.new(parent, camera)
	local boundingBox, _ = instance:GetBoundingBox()
	v2:SetModel(instance)
	local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
	local fitDistance = v2:GetFitDistance(boundingBox.Position)
	camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance * 0.7)
end

function LimitedController.CheckIfHasSkin(_, p)
	return Net:RemoteFunction("RodSkinService/HasSkin"):InvokeServer(p)
end

function convertToDHMS(p: number)
	local v2 = (p - p % 60) / 60
	local v3 = p - v2 * 60
	local v4 = (v2 - v2 % 60) / 60
	local v5 = v2 - v4 * 60
	local v6 = (v4 - v4 % 24) / 24
	local v7 = v4 - v6 * 24
	return string.format("%02i", v6) .. ":" .. string.format("%02i", v7) .. ":" .. string.format("%02i", v5) .. ":" .. string.format(
		"%02i",
		v3
	)
end

function LimitedController:BuildLimitedSlot(_: string, _, _: string) end

function LimitedController.Start(_)
	local function CharacterAdded(_)
		playerGui = localPlayer:WaitForChild("PlayerGui")
		main = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shop"):WaitForChild("Products"):WaitForChild("Views"):WaitForChild("Main")
		limitedItems = main:WaitForChild("LimitedItems")
		fetched = legacyLocalPlayerData.fetch()
		rods = playerDataReplicator and playerDataReplicator.Data and playerDataReplicator.Data.Rods

		if LimitedController.Objects[localPlayer] then
			for _, v2 in pairs(LimitedController.Objects[localPlayer]) do
				v2:Destroy()
			end
		end

		if LimitedController.Connections[localPlayer] then
			for _, connection in pairs(LimitedController.Connections[localPlayer]) do
				connection:Disconnect()
			end
		end

		LimitedController.Trove:Clean()
		LimitedController.Objects[localPlayer] = {}
		LimitedController.Connections[localPlayer] = {}

		for k, skin in pairs(RodSkins.Skins) do
			if skin.DevProduct then
				LimitedController:BuildLimitedSlot(k, skin, skin.TargetRod)
			end
		end
	end

	CharacterAdded(localPlayer.Character or localPlayer.CharacterAdded:Wait())
	localPlayer.CharacterAdded:Connect(CharacterAdded)
end

return LimitedController