local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("StupidStep", 1e999)
local v = Component.new({
	Tag = "StupidStep",
	Ancestors = { Players.LocalPlayer.PlayerGui:WaitForChild("over") }
})

function v.Construct(p)
	p.Instance.Activated:Connect(function()
		if p.Instance.Parent.Name == "prompt" then
			if p.Instance.Name == "deny" then
				p.Instance.Parent:Destroy()
			else
				remoteEvent:FireServer()
			end
		else
			if p.Instance.Parent.Name == "deny" then
			end

			p.Instance.Parent:Destroy()
		end
	end)
end

return v