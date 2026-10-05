local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local v = nil
local v2 = nil
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function handleRequires()
	local Janitor = require(ReplicatedStorage.Packages.Janitor)
	v = Janitor
	local Remotes = require(ReplicatedStorage.Packages.Remotes)
	v2 = Remotes
	local DevToolsController = require(ReplicatedStorage.Modules.Client.Dev.DevToolsController)
	v3 = DevToolsController
end

return {
	Name = "recordPerformanceCSV",
	Aliases = {},
	Description = "Get record the FPS of the local client over time",
	Group = "Utility",
	Args = {
		{
			Type = "number",
			Name = "Seconds",
			Description = "number of seconds to record for"
		}
	},
	ClientRun = function(_, p: number)
		handleRequires() -- equivalent call inferred; original call site unknown
		local v4 = {
			Enum.DeveloperMemoryTag.Animation,
			Enum.DeveloperMemoryTag.GeometryCSG,
			Enum.DeveloperMemoryTag.GraphicsMeshParts,
			Enum.DeveloperMemoryTag.GraphicsParticles,
			Enum.DeveloperMemoryTag.GraphicsParts,
			Enum.DeveloperMemoryTag.GraphicsSolidModels,
			Enum.DeveloperMemoryTag.GraphicsSpatialHash,
			Enum.DeveloperMemoryTag.GraphicsTerrain,
			Enum.DeveloperMemoryTag.GraphicsTexture,
			Enum.DeveloperMemoryTag.GraphicsTextureCharacter,
			Enum.DeveloperMemoryTag.Gui,
			Enum.DeveloperMemoryTag.HttpCache,
			Enum.DeveloperMemoryTag.Instances,
			Enum.DeveloperMemoryTag.Internal,
			Enum.DeveloperMemoryTag.LuaHeap,
			Enum.DeveloperMemoryTag.Navigation,
			Enum.DeveloperMemoryTag.PhysicsCollision,
			Enum.DeveloperMemoryTag.PhysicsParts,
			Enum.DeveloperMemoryTag.Script,
			Enum.DeveloperMemoryTag.Signals,
			Enum.DeveloperMemoryTag.Sounds,
			Enum.DeveloperMemoryTag.StreamingSounds,
			Enum.DeveloperMemoryTag.TerrainVoxels
		}
		local v5 = "Seconds,FPS,TotalMemory,"

		for _, v6 in v4 do
			v5 ..= v6.Name .. "(mb),"
		end

		local v6 = v5
		v6 ..= "ContactsCount,"
		v6 ..= "DataReceiveKbps,"
		v6 ..= "DataSendKbps,"
		v6 ..= "HeartbeatTimeMs,"
		v6 ..= "InstanceCount,"
		v6 ..= "MovingPrimitivesCount,"
		v6 ..= "PhysicsReceiveKbps,"
		v6 ..= "PhysicsSendKbps,"
		v6 ..= "PhysicsStepTimeMs,"
		v6 ..= "PrimitivesCount,"
		v6 ..= "\n"
		local count = 0
		local v7 = v.new()
		task.spawn(function()
			while task.wait(1) do
				if p < count then
					v7:Destroy()
					v3.ShowString(v6)
					break
				else
					local v8 = 1 / RunService.PreRender:Wait()
					v6 ..= tostring(count) .. "," .. tostring(v8) .. ","
					local totalMemoryUsageMb = Stats:GetTotalMemoryUsageMb()
					v6 ..= totalMemoryUsageMb .. ","

					for _, v9 in v4 do
						local memoryUsageMbForTag = Stats:GetMemoryUsageMbForTag(v9)
						v6 ..= memoryUsageMbForTag .. ","
					end

					v6 ..= tostring(Stats.ContactsCount) .. ","
					v6 ..= tostring(Stats.DataReceiveKbps) .. ","
					v6 ..= tostring(Stats.DataSendKbps) .. ","
					v6 ..= tostring(Stats.HeartbeatTimeMs) .. ","
					v6 ..= tostring(Stats.InstanceCount) .. ","
					v6 ..= tostring(Stats.MovingPrimitivesCount) .. ","
					v6 ..= tostring(Stats.PhysicsReceiveKbps) .. ","
					v6 ..= tostring(Stats.PhysicsSendKbps) .. ","
					v6 ..= tostring(Stats.PhysicsStepTimeMs) .. ","
					v6 ..= tostring(Stats.PrimitivesCount) .. ","
					v6 ..= "\n"
					count += 1
				end
			end
		end)
		return "Recording FPS for " .. p .. " seconds"
	end
}