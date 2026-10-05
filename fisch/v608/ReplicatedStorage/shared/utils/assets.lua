local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Net = require(ReplicatedStorage.packages.Net)
local remoteFunction = Net:RemoteFunction("ResourceStream/Request", -1)
local isServer = RunService:IsServer()
RunService:IsClient()
local localPlayer = Players.LocalPlayer
local Assets = {}
local v = {
	fish = {},
	vessel = {},
	rod = {},
	skin = {},
	item = {},
	bobber = {},
	bait = {},
	halo = {},
	lantern = {},
	companion = {},
	potion = {},
	personalAquariumFurniture = {},
	weldAccessory = {}
}

local function checkCache(p: string, p2: string)
	if v[p] then
		return v[p][p2]
	end

	return nil
end

local function addCache(p: string, p2: string, p3)
	if not v[p] then
		v[p][p2] = {}
	end

	v[p][p2] = p3
end

function Assets.releaseAsset(p: string, p2: string)
	if isServer then
		warn("releaseAsset is only supported on the client.")
		return
	end

	if not v[p] then
		warn("releaseAsset could not complete as the requested assetType does not exist.")
		return
	end

	v[p][p2]:Destroy()
	v[p][p2] = nil
end

function Assets.isValidType(p: string)
	return v[p] ~= nil
end

function Assets.getAllOfType(p: string, _: string)
	return v[p]
end

function Assets.getImmediate(p: string, p2: string)
	local selected

	if v[p] then
		selected = v[p][p2]
	end

	return selected or nil
end

local v2 = {}

function Assets.cancelDownload(p: string, p2: string)
	if not (v2[p] and v2[p][p2]) then
		return
	end

	v2[p][p2] = nil
end

function Assets.getAsync(p: string, p2: string, value: number?)
	local selected

	if v[p] then
		selected = v[p][p2]
	end

	if selected then
		return selected
	end

	if isServer then
		return Assets.getImmediate(p, p2)
	end

	if not localPlayer:FindFirstChild("PlayerGui") then
		return
	end

	if not v2[p] then
		v2[p] = {}
	end

	local resourceStream = localPlayer.PlayerGui:FindFirstChild("resourceStream")
	local v4

	if resourceStream then
		if v2[p][p2] then
			local model = resourceStream:WaitForChild(`{p}_{p2}`, value or 300)

			if model then
				local v5

				if model:IsA("Model") then
					v5 = model
				else
					v5 = model
					model = model:FindFirstChildWhichIsA("Model")

					while not model and v5.Parent do
						v5.ChildAdded:Wait()
						model = v5:FindFirstChildWhichIsA("Model")
					end
				end

				while model and not model.PrimaryPart do
					model:GetPropertyChangedSignal("PrimaryPart"):Wait()
				end

				return v5
			else
				if RunService:IsStudio() then
					warn("stream gui failed to get model when waiting for existing download", p, p2)
				end

				return nil
			end
		else
			local model = resourceStream:FindFirstChild((`{p}_{p2}`))

			if model then
				if model:IsA("Model") then
					v4 = model
				else
					v4 = model
					model = model:FindFirstChildWhichIsA("Model")

					while not model and v4.Parent do
						v4.ChildAdded:Wait()
						model = v4:FindFirstChildWhichIsA("Model")
					end
				end

				while model and not model.PrimaryPart do
					model:GetPropertyChangedSignal("PrimaryPart"):Wait()
				end
			else
				v4 = model
			end
		end
	end

	if not v4 then
		v2[p][p2] = true
		v4 = remoteFunction:InvokeServer(p, p2)
		v2[p][p2] = nil
	end

	if not v4 then
		print("failed to get model", p, p2)
	end

	return v4
end

function Assets.getCloneAsync(p: string, p2: string, p3: number?)
	local async = Assets.getAsync(p, p2, p3)

	if async then
		return async:Clone()
	end

	return nil
end

function Assets.getCloneImmediate(p: string, p2: string)
	local immediate = Assets.getImmediate(p, p2)

	if immediate then
		return immediate:Clone()
	end

	return nil
end

if not isServer then
	return Assets
end

local ServerStorage = game:GetService("ServerStorage")
local v3 = game.GameId == 5750914919
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local personalAquariumFurniture = require(ReplicatedStorage.shared.modules.library.personalAquariumFurniture)
local items = require(ReplicatedStorage.shared.modules.library.items)
local vessels = require(ReplicatedStorage.shared.modules.vessels)

for _, child in ServerStorage.resources.fishModels:GetChildren() do
	local child2 = child:FindFirstChild(child.Name)
	local shiny = child:FindFirstChild("Shiny")
	v.fish[`Shiny_{child.Name}`] = shiny
	v.fish[child.Name] = child2
end

for k, v4 in fish do
	if not (typeof(v4) == "table" and v4.Rarity) then
		continue
	end

	if not v.fish[k] then
		local fish2 = v.fish
		local v5

		if v3 then
			v5 = v.fish.PLACEHOLDER
		else
			v5 = v.fish.Floppy
		end

		fish2[k] = v5
	end

	if v.fish[`Shiny_{k}`] then
		continue
	end

	local fish2 = v.fish
	local formatted = `Shiny_{k}`
	local v5

	if v3 then
		v5 = v.fish.Shiny_PLACEHOLDER
	else
		v5 = v.fish.Shiny_Floppy
	end

	fish2[formatted] = v5
end

for _, child in ServerStorage.resources.vessels:GetChildren() do
	v.vessel[child.Name] = child
end

for k in vessels.library do
	if v.vessel[k] then
		continue
	end

	local clone = v.vessel.Jetski:Clone()
	clone.Name = k
	clone.Parent = v.vessel.Jetski.Parent
	v.vessel[k] = clone
end

for _, child in ServerStorage.resources.rods:GetChildren() do
	v.rod[child.Name] = child
end

for k, rod in rods do
	if typeof(rod) ~= "table" or v.rod[k] then
		continue
	end

	local clone = v.rod["Flimsy Rod"]:Clone()
	local flimsyRod = clone:FindFirstChild("Flimsy Rod")
	flimsyRod.Name = k
	clone.Parent = ServerStorage.resources.rods
	v.rod[k] = clone
end

for _, child in ServerStorage.resources.rodSkins:GetChildren() do
	for _, child2 in child:GetChildren() do
		v.skin[child2.Name] = child2
	end
end

for _, child in ServerStorage.resources.itemModels:GetChildren() do
	v.item[child.Name] = child
end

for k, item in items.Items do
	if typeof(item) ~= "table" or not item.Rarity or v.item[k] then
		continue
	end

	local v4

	if v3 then
		v4 = v.item.PLACEHOLDER
	else
		v4 = v.item.NICOPLACEHOLDER
	end

	local clone = v4:Clone()
	clone.Name = k
	local model = clone:FindFirstChildWhichIsA("Model")

	if model then
		model.Name = k
	end

	clone:SetAttribute("PLACEHOLDER", true)
	clone.Parent = ServerStorage.resources.itemModels

	if game.GameId == 5750914919 then
		v.item[k] = clone
	end
end

for childName, bobber in bobbers.Bobbers do
	if bobber.OverrideModel then
		v.bobber[childName] = ServerStorage.resources.bobbers:FindFirstChild(bobber.OverrideModel)
	else
		v.bobber[childName] = ServerStorage.resources.bobbers:FindFirstChild(childName)
	end
end

for _, child in ServerStorage.resources.baitModels:GetChildren() do
	v.bait[child.Name] = child
end

for k, v4 in bait do
	if typeof(v4) ~= "table" or v.bait[k] then
		continue
	end

	v.bait[k] = v.bait.Worm
end

for _, child in ServerStorage.resources.halos:GetChildren() do
	v.halo[child.Name] = child
end

for _, child in ServerStorage.resources.lanterns:GetChildren() do
	v.lantern[child.Name] = child
end

local companions = ServerStorage.resources:FindFirstChild("companions")

if companions then
	for _, child in companions:GetChildren() do
		for _, child2 in child:GetChildren() do
			v.companion[`{child.Name}/{child2.Name}`] = child2
		end
	end
end

for _, child in ServerStorage.resources.potions:GetChildren() do
	for _, child2 in child:GetChildren() do
		v.potion[`{child.Name}/{child2.Name}`] = child2

		if child2.Name == "Tier1" then
			v.potion[child.Name] = child2
		end
	end
end

for childName, v4 in personalAquariumFurniture do
	if v4.OverrideModel then
		v.personalAquariumFurniture[childName] = ServerStorage.resources.personalAquariumFurniture:FindFirstChild(v4.OverrideModel)
	else
		v.personalAquariumFurniture[childName] = ServerStorage.resources.personalAquariumFurniture:FindFirstChild(childName)
	end
end

for _, child in ServerScriptService.server.legacyServices.PassiveService.Generic_WeldAccessory.Models:GetChildren() do
	v.weldAccessory[child.Name] = child
end

return Assets