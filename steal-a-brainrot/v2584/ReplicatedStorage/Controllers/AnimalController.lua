local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Observers = require(packages.Observers)
local Synchronizer = require(packages.Synchronizer)
local Signal = require(packages.Signal)
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimalClient = require(classes.AnimalClient)
local v = {}
local localPlayer = Players.LocalPlayer
local fireServer = Instance.new("RemoteEvent").FireServer
local remoteEvent = Net:RemoteEvent("09e66d0e-a7a7-4ae6-bda3-7e169e20894f")
local AnimalController = {
	OnAnimalSpawn = Signal.new(),
	OnAnimalDestroyed = Signal.new(),
	OnFollowingChanged = Signal.new(),
	HasAnimalMovingToBase = function(_, _: string)
		for _, v2 in pairs(v) do
			local instance = v2.Instance
			local primaryPart = instance and instance.PrimaryPart
			local promptAttachment = primaryPart and primaryPart:FindFirstChild("PromptAttachment")
			local proximityPrompt = promptAttachment and promptAttachment:FindFirstChild("ProximityPrompt")

			if proximityPrompt and proximityPrompt:GetAttribute("TargetPlayer") == localPlayer.UserId then
				return v2
			end
		end
	end,
	HasAnimal = function(_, p: string, value: number?)
		local v3 = Synchronizer:Get(localPlayer)

		if not v3 then
			return false
		end

		local count = 0
		local result = {}

		for k, v4 in v3:Get("AnimalPodiums") do
			if not (v4 ~= "Empty" and v4.Index == p) then
				continue
			end

			count += 1
			table.insert(result, k)
		end

		return (value or 1) <= count, result
	end,
	GetAnimals = function(_)
		return v
	end
}

function AnimalController.Start(_)
	Observers.observeTag("Animal", function(p)
		local v2 = AnimalClient.new(p)
		local UID = v2:GetUID()
		v[UID] = v2
		v2.Collector:Add(Observers.observeTag("AnimalPurchasePrompt", function(p2)
			return Observers.observeAttribute(p2, "TargetPlayer", function(p3)
				AnimalController.OnFollowingChanged:Fire(v2.Index, v2.UID, p3)
				return nil
			end)
		end, { v2.Instance }))
		AnimalController.OnAnimalSpawn:Fire(v2)
		return function()
			local UID2 = v2.UID
			v2:Destroy()
			v[UID2] = nil
			AnimalController.OnAnimalDestroyed:Fire(UID2)
		end
	end)
	Observers.observeTag("AnimalPurchasePrompt", function(instance)
		local maid = Trove.new()

		local function updateVisibility()
			instance.Enabled = instance:GetAttribute("TargetPlayer") ~= localPlayer.UserId and not instance:GetAttribute("Disabled")
		end

		maid:Add(instance:GetAttributeChangedSignal("TargetPlayer"):Connect(updateVisibility))
		maid:Add(instance:GetAttributeChangedSignal("Disabled"):Connect(updateVisibility))
		local enabled

		if instance:GetAttribute("TargetPlayer") == localPlayer.UserId then
			enabled = false
		else
			enabled = not instance:GetAttribute("Disabled")
		end

		instance.Enabled = enabled
		local UID = instance:GetAttribute("UID")
		maid:Add(instance.Triggered:Connect(function()
			fireServer(remoteEvent, workspace:GetServerTimeNow() + 219, "84ff105c-ca6f-487f-a69d-9499001a1af0", UID)
			remoteEvent:FireServer(workspace:GetServerTimeNow() + 219, "f2778935-0b31-401b-b9ef-9b27994fa22c", UID)
		end))
		return function()
			maid:Destroy()
		end
	end)
end

return AnimalController