local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local character = require(ReplicatedStorage.shared.modules:WaitForChild("character"))
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local maid = Trove.new()
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local treasureMap = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Treasure Map")
local main = treasureMap:WaitForChild("Main")
local coordinatesLabel = main:WaitForChild("TreasureMapImage"):WaitForChild("CoordinatesLabel")
local coordinatesText = main:WaitForChild("TreasureMapImage"):WaitForChild("CoordinatesText")
character.PS(localPlayer)
local handle = script.Parent:WaitForChild("Handle")
parent:WaitForChild("link")
local itemFromLink, v = DataController.getItemFromLink(parent)
local flag = false
local clone = nil

local function updateCoordinatesUI()
	if not (itemFromLink and itemFromLink.sub) then
		return
	end

	if itemFromLink.sub.Repaired then
		coordinatesLabel.Text = "X " .. itemFromLink.sub.x .. ", Y " .. itemFromLink.sub.y .. ", Z " .. itemFromLink.sub.z
		coordinatesText.Text = FischUtils.GetZoneName((Vector3.new(
			itemFromLink.sub.x,
			itemFromLink.sub.y,
			itemFromLink.sub.z
		)))
		flag = true
	else
		coordinatesLabel.Text = "X " .. itemFromLink.sub.x .. ", Y ??, Z ??"
		coordinatesText.Text = "Coordinates"
	end
end

maid:Add(DataController.InventoryReplicator:Listen({ "Inventory" }, function(_, p)
	if p[v] or p.Inventory and p.Inventory[v] then
		itemFromLink, v = DataController.getItemFromLink(parent)

		if itemFromLink and v then
			updateCoordinatesUI()
		end
	end
end))
maid:AttachToInstance(script)
local v2 = main.GroupTransparency > 0
local total = 0
parent.Equipped:Connect(function()
	if FischUtils.IsTradePlaza() then
		ReplicatedStorage.events.anno_localthought:Fire("This map doesn't seem to work here...")
		return
	end

	v2 = main.GroupTransparency > 0
	total = 1

	if parent.Parent:FindFirstChild("HumanoidRootPart") and game.Players:FindFirstChild(parent.Parent.Name) then
		itemFromLink, v = DataController.getItemFromLink(parent)

		if itemFromLink and v then
			updateCoordinatesUI()
			treasureMap.Enabled = true
		end

		if not clone then
			clone = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):WaitForChild("TreasurePointer"):Clone()
			maid:Add(RunService.RenderStepped:Connect(function(dt)
				if parent.Parent ~= localPlayer.Character then
					return
				end

				if flag then
					local vector = Vector3.new(itemFromLink.sub.x, itemFromLink.sub.y, itemFromLink.sub.z)
					clone:PivotTo(CFrame.lookAt(handle.Position, vector) * CFrame.new(0, 0, -5))
					clone.LocalTransparencyModifier = 0
				else
					clone.LocalTransparencyModifier = 1
				end

				if handle.AssemblyLinearVelocity.Magnitude > 8 then
					total = 0

					if not v2 then
						v2 = true
						TweenService:Create(main, TweenInfo.new(0.5), {
							GroupTransparency = 0.85
						}):Play()
					end
				else
					total += dt

					if total > 1 and v2 then
						v2 = false
						TweenService:Create(main, TweenInfo.new(1), {
							GroupTransparency = 0
						}):Play()
					end
				end
			end))
			clone.Parent = parent
		end
	end
end)
parent.Unequipped:Connect(function()
	treasureMap.Enabled = false
end)