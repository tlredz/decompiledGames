local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
local mined = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("Mined")
local remoteEvent = Net:RemoteEvent("MiningService/UpdateOreState")
local v = Component.new({
	Tag = "Ore"
})

function v:SetProgress(progress: number, flag: boolean?)
	self.progress = progress
	local health = self.health

	if self.progress == self.health then
		local colliders = self.Instance:FindFirstChild("Colliders")

		if colliders then
			for _, child in colliders:GetChildren() do
				child.CanCollide = false
			end
		end
	end

	if flag == true then
	end

	local v2 = math.clamp(self.progress / health, 0, 1)

	for k, ore in self.ores do
		k.Size = ore.Sizes[1]:Lerp(ore.Sizes[2], v2)
		k.Position = ore.Positions[1]:Lerp(ore.Positions[2], v2)
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.ores = {}
	self.health = self.Instance:GetAttribute("Health")
	self.progress = 0

	while #self.Instance:WaitForChild("Ore"):GetChildren() ~= self.Instance:GetAttribute("AmountOfOre") do
		task.wait()
	end

	for _, part in self.Instance:WaitForChild("Ore"):GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local v2 = {
			Sizes = { part.Size, part.Size + (part:GetAttribute("IncrementSize") or createVector(0, 0, 0)) },
			Positions = {
				part.Position,
				part.Position + (part:GetAttribute("IncrementPosition") or createVector(0, 0, 0))
			}
		}
		self.ores[part] = v2
	end
end

function v:Start()
	if mined:FindFirstChild(self.Instance.Name) then
		self:SetProgress(self.health, true)
	else
		self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
			if self.Instance.Name ~= p then
				return
			end

			self:SetProgress(p2)
		end))
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v