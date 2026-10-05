local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "TimeTrial/SinMove",
	Ancestors = { Workspace },
	Extensions = nil
})

function v:Construct()
	self.Trove = Trove.new()
end

function v:UpdatePositions(p)
	if localPlayer.GameplayPaused then
		return
	end

	local all = v:GetAll()
	local instances = table.create(#all)
	local positions = table.create(#all)

	for _, v2 in all do
		if not v2.Active then
			continue
		end

		table.insert(instances, v2.Instance)
		table.insert(positions, v2:GetPosition(p))
	end

	workspace:BulkMoveTo(instances, positions, Enum.BulkMoveMode.FireCFrameChanged)
end

function v:GetPosition(_)
	return self.RootCFrame * CFrame.new(self.Instance:GetAttribute("MoveVector") * math.sin(tick() / self.Instance:GetAttribute("MoveTime") * 3.141592653589793))
end

function v:Start()
	if not self.Instance then
		return
	end

	if not self.RootCFrame then
		self.RootCFrame = self.Instance:GetPivot()
	end

	self.Active = true
end

function v:Stop()
	self.Active = false
	self.Trove:Clean()
end

RunService.Stepped:Connect(function(_, dt)
	v:UpdatePositions(dt)
end)
return v