require(game.ReplicatedStorage.DungeonShared)
local RunService = game:GetService("RunService")
RunService:IsServer()
local Maid = require(game.ReplicatedStorage.Util.Maid)
local RunService2 = game:GetService("RunService")
local isClient = RunService2:IsClient()
local Util = require(game.ReplicatedStorage.DungeonShared.MapComponents.Util)
local Component = require(game.ReplicatedStorage.Modules.Component)
local new = Component.new
local v = {
	Tag = "DungeonProp_GasVentProp2",
	Ancestors = { workspace.Map },
	Extensions = 0
}
local BaseMapComponent = require(script.Parent.BaseMapComponent)
v.Extensions = { BaseMapComponent }
local v2 = new(v)

function v2:Start()
	self.Maid = Maid.new()
	assert(self.Maid)
	local v3 = assert(self.Instance)
	local cylinder009 = v3:WaitForChild("Cylinder.009", 60)

	if not cylinder009 then
		return
	end

	local cylinder016 = v3:FindFirstChild("Cylinder.016")
	local cframe = CFrame.Angles(0, 0, 0)

	if not cylinder016 then
		cylinder016 = v3:FindFirstChild("Cylinder.015")
		cframe = CFrame.Angles(0, 1.5707963267948966, 0)

		if not cylinder016 then
			return
		end
	end

	if isClient then
		local v4 = 0

		local function updateBeam(instance)
			local beamBody = instance:FindFirstChild("BeamBody")
			local beamStart = instance:FindFirstChild("BeamStart")
			local beamEnd = beamStart:FindFirstChild("BeamEnd")
			local beamBody2 = beamEnd:FindFirstChild("BeamBody")

			if beamBody2 then
				beamBody2:Destroy()
			end

			if beamBody and beamStart and beamEnd then
				beamEnd.CFrame = beamStart.CFrame * CFrame.new(0, 0, -v4 * 80)
			end
		end

		Util.handleAttribute(v3, "Speed", function(value)
			v4 = value or 0

			if v4 > 0.05 then
				if not self.VentBeam then
					self.VentBeam = script.VentBeam:Clone()
					self.VentBeam.Parent = cylinder009
					self.VentBeam:PivotTo(cylinder016.CFrame * cframe * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
						0,
						0,
						-50
					))
				end

				task.spawn(updateBeam, self.VentBeam)
			elseif self.VentBeam then
				self.VentBeam:Destroy()
				self.VentBeam = nil
			end
		end)
		local weld = cylinder009:FindFirstChildOfClass("Weld")

		if weld then
			weld:Destroy()
		end

		local motor6D = Instance.new("Motor6D", cylinder016)
		motor6D.Name = "PropMotor2"
		motor6D.C0 = cylinder016.CFrame:Inverse() * cylinder009.CFrame
		motor6D.Part0 = cylinder016
		motor6D.Part1 = cylinder009
		local maid = self.Maid
		local RunService3 = game:GetService("RunService")
		maid:GiveTask(RunService3.Heartbeat:Connect(function(dt)
			motor6D.C0 *= CFrame.Angles(1.5707963267948966 * dt * v4, 0, 0)
		end))
	else
		self.Instance:SetAttribute("Speed", 0)
	end
end

function v2:Stop()
	if self.Maid then
		self.Maid:DoCleaning()
		self.Maid = nil
	end
end

return v2