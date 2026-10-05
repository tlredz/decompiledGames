local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local iceFischArcade = require(ReplicatedStorage.client.modules.iceFischArcade)
local v = Component.new({
	Tag = "ArcadeMachine"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local iceFischArcade2 = p.Instance:FindFirstChild("IceFischArcade")

	if iceFischArcade2 then
		for _, sound in iceFischArcade2:GetDescendants() do
			if sound:IsA("Sound") then
				sound:Destroy()
			end
		end
	end

	local proximityPrompt = p.Instance:WaitForChild("Parts"):WaitForChild("ProximityPrompt")
	p.trove:Add(proximityPrompt.Triggered:Connect(function()
		iceFischArcade.open(p.Instance)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v