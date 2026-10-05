local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Remotes = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Remotes"))
local Platform = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Util"):WaitForChild("Platform"))
local ClientPerformanceController = {}

function ClientPerformanceController.FrameworkInit() end

function ClientPerformanceController.FrameworkStart()
	Remotes.connect("BeginLogStats", function(p: number)
		local count = 0
		local v = {
			"ContactsCount",
			"DataReceiveKbps",
			"DataSendKbps",
			"HeartbeatTimeMs",
			"InstanceCount",
			"MovingPrimitivesCount",
			"PhysicsReceiveKbps",
			"PhysicsSendKbps",
			"PhysicsStepTimeMs",
			"PrimitivesCount"
		}

		while p > 0 do
			count += 1
			local FPS = 1 / RunService.PreRender:Wait()
			local v3 = {
				Second = count,
				Total = Stats:GetTotalMemoryUsageMb()
			}

			for _, v4 in Enum.DeveloperMemoryTag:GetEnumItems() do
				local memoryUsageMbForTag = Stats:GetMemoryUsageMbForTag(v4)
				v3[v4.Name] = memoryUsageMbForTag
			end

			for _, v4 in v do
				v3[v4] = Stats[v4]
			end

			v3.FPS = FPS
			Remotes.fireServer("LogStats", v3, Platform.Mode)
			p -= 1
			task.wait(1)
		end
	end)
	Remotes.connect("BeginLogMemory", function(p: number)
		while p > 0 do
			local memoryUsageMbForTagsByName = {
				Total = Stats:GetTotalMemoryUsageMb()
			}

			for _, v in Enum.DeveloperMemoryTag:GetEnumItems() do
				local memoryUsageMbForTag = Stats:GetMemoryUsageMbForTag(v)
				memoryUsageMbForTagsByName[v.Name] = memoryUsageMbForTag
			end

			Remotes.fireServer("LogMemory", memoryUsageMbForTagsByName, Platform.Mode)
			p -= 1
			task.wait(1)
		end
	end)
end

return ClientPerformanceController