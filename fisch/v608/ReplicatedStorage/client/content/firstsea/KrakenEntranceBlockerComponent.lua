local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = ReplicatedStorage.client.components
local krakenPuzzleClockComponent = script.Parent:WaitForChild("KrakenPuzzleClockComponent", 10)
local module = require(krakenPuzzleClockComponent)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local v = {
	["1"] = "Purple",
	["2"] = "Yellow",
	["3"] = "Black",
	["4"] = "Blue"
}
local remoteFunction = Net:RemoteFunction("GetDoorState")
local v2 = Component.new({
	Tag = "KrakenEntranceBlocker"
})

function v2:UpdateLights(p)
	local lights = self.Instance:WaitForChild("Lights")
	local v3 = true

	for k, childName in v do
		if not p[k] then
			if self.opened == true then
				p[k] = true
			else
				v3 = false
			end
		end

		local child = lights:WaitForChild(childName)
		child.Material = p[k] ~= nil and Enum.Material.Neon or Enum.Material.SmoothPlastic
		local pointLight = child:WaitForChild("PointLight")
		pointLight.Enabled = p[k] ~= nil
	end

	self:UnlockDoor(v3)
end

function v2:UnlockDoor(flag: boolean)
	for _, part in self.Instance:WaitForChild("Structure"):GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = not flag
		part.CanQuery = not flag
		part.CanTouch = not flag
		part.Transparency = flag == true and 1 or 0
	end
end

function v2:Construct()
	local doorKrakenPuzzleDoor1 = legacyLocalPlayerData.fetch():WaitForChild("Cache"):FindFirstChild("Door.KrakenPuzzleDoor1")
	self.trove = Trove.new()
	self.default = {}
	self.opened = doorKrakenPuzzleDoor1 ~= nil

	if self.opened == false then
		self.opened = remoteFunction:InvokeServer("KrakenPuzzleDoor1")
	end
end

function v2:Start()
	self:UpdateLights((module.RequestList()))
	self.trove:Add(module.ClockCompleted:Connect(function(p)
		self:UpdateLights(p)
	end))
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2