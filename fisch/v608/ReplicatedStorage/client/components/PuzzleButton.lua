local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local remoteFunction = Net:RemoteFunction("PuzzleButtonService/RequestState")
local remoteEvent = Net:RemoteEvent("PuzzleButtonService/UpdateState")
local v = {
	[false] = Color3.fromRGB(152, 23, 23),
	[true] = Color3.fromRGB(0, 255, 0)
}
local v2 = Component.new({
	Tag = "PuzzleButton"
})

function v2:SetState(flag: boolean)
	local prompt = self.Instance:WaitForChild("Button"):WaitForChild("Prompt")
	prompt.Enabled = not flag
	local button = self.Instance:WaitForChild("Button")
	button.Color = v[flag]
end

function v2:Construct()
	self.trove = Trove.new()
end

function v2:Start()
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p, p2)
		if p ~= self.Instance.Name then
			return
		end

		self:SetState(p2)
	end))
	local prompt = self.Instance:WaitForChild("Button"):WaitForChild("Prompt")
	self.trove:Add(prompt.Triggered:Connect(function()
		remoteEvent:FireServer(self.Instance.Name)
	end))
	self:SetState(remoteFunction:InvokeServer(self.Instance.Name))
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2