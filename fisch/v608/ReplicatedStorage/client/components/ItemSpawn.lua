local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local Timer = require(packages:WaitForChild("Timer"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local Bestiary = require(ReplicatedStorage.shared.modules.Bestiary)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local localPlayer = Players.LocalPlayer
local cache = legacyLocalPlayerData.fetch():WaitForChild("Cache")
local mined = cache:WaitForChild("Mined")
local collectedItems = cache:WaitForChild("CollectedItems")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers:WaitForChild("NotificationController"))
local remoteFunction = Net:RemoteFunction("ItemSpawnCollect")
local v = Component.new({
	Tag = "ItemSpawn"
})

function v:SetState(enabled: boolean?, _: boolean?, flag2: boolean?)
	self.enabled = enabled

	if flag2 == true then
		for k, part in self.parts do
			k.Transparency = part
		end

		for k, _ in self.lights do
			k.Enabled = true
		end
	else
		for k, part in self.parts do
			k.Transparency = enabled == false and 1 or part
		end

		for k, _ in self.lights do
			k.Enabled = enabled
		end
	end

	self.Instance.Root.Prompt.Enabled = enabled
end

function v:Construct()
	self.enabled = false
	self.item = self.Instance:GetAttribute("ItemName")
	self.respawnInterval = self.Instance:GetAttribute("RespawnInterval")
	self.trove = Trove.new()
	self.timer = Timer.new(1)
	self.trove:Add(self.timer, "Destroy")
	self.parts = {}
	self.lights = {}

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			self.parts[descendant] = descendant.Transparency
		elseif descendant:IsA("PointLight") then
			self.lights[descendant] = true
		end
	end
end

function v:Start()
	self.trove:Add(self.timer.Tick:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local child = collectedItems:FindFirstChild(self.item)
		local v2 = not child and "0.0" or child.Value or "0.0"

		if not self.respawnInterval and child then
			self:SetState(false)
			return
		end

		if not (serverTimeNow - tonumber(string.split(v2, ".")[2]) >= self.respawnInterval) then
			self:SetState(false)
			return
		end

		if self.Instance:GetAttribute("RequiredWeather") and not SharedWeather.IsActive(self.Instance:GetAttribute("RequiredWeather")) then
			self:SetState(false)
			return
		end

		if self.Instance:GetAttribute("RequiredOre") and not mined:FindFirstChild(self.Instance:GetAttribute("RequiredOre")) then
			self:SetState(false, nil, true)
			return
		end

		if self.Instance:GetAttribute("RequiredEvent") and self.Instance:GetAttribute("RequiredEvent") == "Avalanche" and not workspace:GetAttribute("Avalanche") then
			self:SetState(false)
			return
		end

		local limitedAmount = self.Instance:GetAttribute("LimitedAmount")

		if not limitedAmount then
			self:SetState(true)
		elseif limitedAmount <= DataController.CountItem(self.item, nil, limitedAmount) and (not fish[self.item] or Bestiary:IsFishDiscovered(
			localPlayer,
			self.item,
			false
		)) then
			self:SetState(false)
		else
			self:SetState(true)
		end
	end))
	self.timer:Start()
	self.trove:Add(self.Instance:WaitForChild("Root"):WaitForChild("Prompt").Triggered:Connect(function()
		if self.Instance:GetAttribute("RequiredWeather") and not SharedWeather.IsActive(self.Instance:GetAttribute("RequiredWeather")) then
			NotificationController:Notify(
				`This item can only be collected during the {self.Instance:GetAttribute("RequiredWeather")}!`,
				3
			)
			return
		end

		self:SetState(remoteFunction:InvokeServer(self.Instance.Name) ~= true)
	end))
	self:SetState(false, true)
end

function v.Stop(p)
	p.trove:Destroy()
end

return v