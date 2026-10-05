local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("EmoteVFXRotate", function(instance)
	local studs = instance:GetAttribute("Studs") or 1
	local studsChangedConnection = instance:GetAttributeChangedSignal("Studs"):Connect(function()
		studs = instance:GetAttribute("Studs") or 1
	end)
	local isA = instance:IsA("BasePart")
	local isA2 = instance:IsA("Weld")
	local property = instance:GetAttribute("Property") or "C0"
	local axis = instance:GetAttribute("Axis") or "Y"
	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		local cframe

		if axis == "Z" then
			cframe = CFrame.Angles(0, 0, studs * dt)
		else
			cframe = CFrame.Angles(0, studs * dt, 0)
		end

		if isA then
			for _, instance2 in instance:GetJoints() do
				if instance2:IsA("Weld") or instance2:IsA("Motor6D") then
					instance2.C0 *= cframe
				else
					warn(instance2.ClassName, "not found")
				end
			end
		elseif isA2 then
			instance[property] *= cframe
		else
			instance.CFrame *= cframe
		end
	end)
	return function()
		studsChangedConnection:Disconnect()
		postSimulationConnection:Disconnect()
	end
end, { workspace })