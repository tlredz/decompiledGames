local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local remoteEvent = Net:RemoteEvent("UpdateArchivesPillarState", -1)
local v = Component.new({
	Tag = "ArchivesPillar"
})

function v:Tick(_: number)
	local localPlayer = Players.LocalPlayer

	if not self.Instance then
		return
	end

	local itemRoot = self.Instance:FindFirstChild("ItemRoot")

	if not itemRoot then
		return
	end

	local prompt = itemRoot:FindFirstChild("Prompt")

	if not prompt then
		return
	end

	if self.placedItem == true then
		prompt.Enabled = false
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	prompt.Enabled = tool.Name == self.Instance:GetAttribute("RequiredItem")
end

function v:Construct()
	self.trove = Trove.new()
end

function v:Start()
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2)
		if p ~= self.Instance.Name then
			return
		end

		self.placedItem = p2.PlacedItem
		local prompt = self.Instance:WaitForChild("Root"):WaitForChild("Prompt")
		prompt.Enabled = p2.PlacedItem == true
	end))
	local prompt = self.Instance:WaitForChild("ItemRoot"):WaitForChild("Prompt")
	local prompt2 = self.Instance:WaitForChild("Root"):WaitForChild("Prompt")
	self.trove:Add(prompt.Triggered:Connect(function()
		remoteEvent:FireServer("PlaceItem", self.Instance.Name)
	end))
	self.trove:Add(prompt2.Triggered:Connect(function()
		remoteEvent:FireServer("Rotate", self.Instance.Name)
	end))
	self.trove:Add(RunService.RenderStepped:Connect(function(...)
		self:Tick(...)
	end))
	remoteEvent:FireServer("RequestState", self.Instance.Name)
end

function v.Stop(p)
	p.trove:Destroy()
end

return v