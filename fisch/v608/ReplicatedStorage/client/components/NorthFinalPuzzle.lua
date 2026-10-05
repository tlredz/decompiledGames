local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local Net = require(packages:WaitForChild("Net"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local _ = Players.LocalPlayer
legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("NorthFinalPuzzleFinished")
local remoteFunction = Net:RemoteFunction("NorthFinalPuzzleService/RequestState")
local remoteEvent = Net:RemoteEvent("NorthFinalPuzzleService/UpdateState")
local remoteEvent2 = Net:RemoteEvent("NorthFinalPuzzleService/Place")
local v = Component.new({
	Tag = "NorthFinalPuzzle"
})

function v:Update(items, flag: boolean?)
	if not items then
		return
	end

	local total = 0

	for k, item in items do
		self.list[k] = item
		total += item == true and 1 or 0
	end

	local finished = total >= 4

	for _, child in self.Instance:WaitForChild("Shards"):GetChildren() do
		local fish = child:WaitForChild("Fish")
		local prompt = child:WaitForChild("handle"):WaitForChild("Prompt")
		prompt.Enabled = not self.list[child.Name]

		for _, part in fish:GetChildren() do
			if part:IsA("BasePart") then
				part.Transparency = self.list[child.Name] == true and 0 or 1
			end
		end
	end

	for _, child in self.Instance:WaitForChild("Beacons"):GetChildren() do
		for _, descendant in child:WaitForChild("Root"):GetDescendants() do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
				descendant.Enabled = self.list[child.Name]
			end
		end
	end

	for _, folder in self.Instance:WaitForChild("Braziers"):GetChildren() do
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Sound") then
				local v3 = self.list[folder.Name]

				if v3 == true and not descendant.IsPlaying then
					descendant:Play()
				elseif v3 == false and descendant.IsPlaying then
					descendant:Stop()
				end
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
				descendant.Enabled = self.list[folder.Name]
			end
		end
	end

	self.finished = finished

	if flag == true and finished == true then
		for _, child in self.Instance:WaitForChild("Beacons"):GetChildren() do
			for _, beam in child:WaitForChild("Root"):GetDescendants() do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end
		end

		local storm = self.Instance:WaitForChild("Storm")
		local scale = storm:WaitForChild("Scale")
		local changedConnection = scale.Changed:Connect(function()
			storm:ScaleTo(scale.Value)
		end)
		TweenService:Create(scale, TweenInfo.new(10, Enum.EasingStyle.Linear), {
			Value = 0.01
		}):Play()
		task.wait(11)

		for _, child in self.Instance:WaitForChild("Beacons"):GetChildren() do
			for _, beam in child:WaitForChild("Root"):GetDescendants() do
				if beam:IsA("Beam") then
					beam.Enabled = false
				end
			end
		end

		storm:Destroy()
		changedConnection:Disconnect()
	else
		local storm = finished == true and self.Instance:WaitForChild("Storm", 20)

		if storm then
			storm:Destroy()
		end
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.finished = false
	self.list = {}
end

function v:Start()
	local prompt = self.Instance:WaitForChild("Shards"):WaitForChild("Blue"):WaitForChild("handle"):WaitForChild("Prompt")
	local prompt2 = self.Instance:WaitForChild("Shards"):WaitForChild("Red"):WaitForChild("handle"):WaitForChild("Prompt")
	local prompt3 = self.Instance:WaitForChild("Shards"):WaitForChild("Green"):WaitForChild("handle"):WaitForChild("Prompt")
	local prompt4 = self.Instance:WaitForChild("Shards"):WaitForChild("Yellow"):WaitForChild("handle"):WaitForChild("Prompt")
	self.trove:Add(prompt.Triggered:Connect(function()
		remoteEvent2:FireServer("Blue")
	end))
	self.trove:Add(prompt2.Triggered:Connect(function()
		remoteEvent2:FireServer("Red")
	end))
	self.trove:Add(prompt3.Triggered:Connect(function()
		remoteEvent2:FireServer("Green")
	end))
	self.trove:Add(prompt4.Triggered:Connect(function()
		remoteEvent2:FireServer("Yellow")
	end))
	self:Update(remoteFunction:InvokeServer())
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p)
		if self.finished == true then
			return
		end

		self:Update(p, true)
	end))
end

function v:Stop()
	self.trove:Destroy()
end

return v