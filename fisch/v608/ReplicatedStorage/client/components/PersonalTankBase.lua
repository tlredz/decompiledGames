local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
game:GetService("Players")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local aquariumController = ReplicatedStorage.client.legacyControllers.AquariumController
local FishRoamer = require(aquariumController.FishRoamer)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local module = require("@self/DeterministicRandom")
local remoteFunction = Net:RemoteFunction("PersonalAquarium/Tank/GetEncodedAquariumInfo")
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Tank/AddedFish")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/Tank/LostFish")
local remoteEvent3 = Net:RemoteEvent("PersonalAquarium/Tank/Refresh")

-- equivalent calls inferred from this helper; original call sites unknown
local function sortArrayByName(tanks)
	table.sort(tanks, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
end

local v = Component.new({
	Tag = "personal-tank-wrapper",
	Ancestors = { Workspace }
})

function v:Start()
	self.Trove = Trove.new()
	self.InternalMaps = {}
	self.InternalMaps.GuidToData = {}
	self.InternalMaps.GuidToModel = {}
	self.InternalMaps.GuidToRoamer = {}
	self.Tanks = {}
	task.wait(4.5)
	local descendants = self.Instance.Parent:GetDescendants()

	for _, descendant in descendants do
		if descendant:HasTag("personal-tank") then
			table.insert(self.Tanks, descendant)
		end
	end

	sortArrayByName(self.Tanks) -- equivalent call inferred; original call site unknown
	self.AquariumID = self.Instance:GetAttribute("AquariumID")
	self:_PopulateAsync()
	self.Trove:Add(remoteEvent.OnClientEvent:Connect(function(...)
		self:_AddFish(...)
	end))
	self.Trove:Add(remoteEvent2.OnClientEvent:Connect(function(...)
		self:_RemoveFish(...)
	end))
	self.Trove:Add(remoteEvent3.OnClientEvent:Connect(function(...)
		self:_Refresh(...)
	end))
	local count = 0
	local total = 0
	self.Trove:Add(RunService.RenderStepped:Connect(function(dt)
		total += dt
		count += 1

		if count == 1 then
			count = 0

			for _, v2 in self.InternalMaps.GuidToRoamer do
				v2:Update(total)
			end

			total = 0
		end
	end))
end

function v.Stop(p)
	p.Trove:Destroy()
end

function v:_GetRandomTankPart(p2: string)
	local v3 = module(p2, #self.Tanks)
	return self.Tanks[v3]
end

function v:_PopulateAsync()
	local jSONDecode = HttpService:JSONDecode((remoteFunction:InvokeServer(self.AquariumID)))

	for k, v3 in jSONDecode do
		self:_AddFish(self.AquariumID, k, v3)
	end
end

function v:_AddFish(p, p2, p3)
	if p ~= self.AquariumID or self.InternalMaps.GuidToData[p2] then
		return
	end

	self.InternalMaps.GuidToData[p2] = p3
	local folder = FishModel.Create({
		Name = p3.name,
		ItemData = p3.sub,
		ResizeArgs = {
			MaxSize = 14
		},
		CastShadow = false
	})

	if not folder then
		return
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part.Name == "Center"
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.AudioCanCollide = false
		part.CastShadow = false
	end

	self.Trove:Add(folder)
	self.InternalMaps.GuidToModel[p2] = folder
	local _GetRandomTankPart = self:_GetRandomTankPart(p2)
	folder.Parent = _GetRandomTankPart
	local v2 = FishRoamer.new(folder, _GetRandomTankPart)
	self.InternalMaps.GuidToRoamer[p2] = v2
end

function v:_RemoveFish(p2, p3)
	if p2 ~= self.AquariumID then
		return
	end

	if self.InternalMaps.GuidToData[p3] then
		self.InternalMaps.GuidToData[p3] = nil
	end

	if self.InternalMaps.GuidToModel[p3] then
		self.InternalMaps.GuidToModel[p3]:Destroy()
		self.InternalMaps.GuidToModel[p3] = nil
	end

	if self.InternalMaps.GuidToRoamer[p3] then
		if self.InternalMaps.GuidToRoamer[p3].Model then
			self.InternalMaps.GuidToRoamer[p3].Model:Destroy()
		end

		self.InternalMaps.GuidToRoamer[p3].Model = nil
		self.InternalMaps.GuidToRoamer[p3].Water = nil
		self.InternalMaps.GuidToRoamer[p3].PrimaryPart = nil
		self.InternalMaps.GuidToRoamer[p3] = nil
	end
end

function v:_Refresh(p)
	if p ~= self.AquariumID then
		return
	end

	for k, _ in self.InternalMaps.GuidToData do
		self:_RemoveFish(p, k)
	end

	self:_PopulateAsync()
end

return v