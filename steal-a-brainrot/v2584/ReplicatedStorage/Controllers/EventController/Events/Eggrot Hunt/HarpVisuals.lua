local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.WorldBrainrotController)
local Trove = require(ReplicatedStorage.Packages.Trove)
local remoteEvent = Net:RemoteEvent("EggrotHunt/HarpPlay")
return table.freeze({
	Start = function(_, p)
		local maid = Trove.new()
		maid:Add(remoteEvent.OnClientEvent:Connect(function(cframe: CFrame, p2: string?)
			SoundController:PlaySound("Sounds.Events.Easter.Harp", cframe.Position, false)

			if not p2 then
				return
			end

			local v = cframe + createVector(0, 100, 0)
			local cframe2 = CFrame.new(0, -10000, 0)
			local lastTime = os.clock()
			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				local v2 = p[p2]

				if v2 and v2.model then
					v2.model:PivotTo(cframe2)
				end

				if os.clock() - lastTime >= 4 and postSimulationConnection then
					postSimulationConnection:Disconnect()
					postSimulationConnection = nil
				end
			end)
			maid:Add(function()
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
				end
			end)
			task.wait(4)

			if postSimulationConnection then
				postSimulationConnection:Disconnect()
			end

			local lastTime2 = os.clock()
			local postSimulationConnection2 = nil
			postSimulationConnection2 = RunService.PostSimulation:Connect(function()
				local v2 = math.clamp((os.clock() - lastTime2) / 2, 0, 1)
				local v3 = 1 - (1 - v2) * (1 - v2)
				local v4 = p[p2]

				if v4 and v4.model then
					local lerped = v:Lerp(cframe, v3)
					v4.model:PivotTo(lerped)

					if v2 >= 1 and postSimulationConnection2 then
						postSimulationConnection2:Disconnect()
					end
				elseif v2 >= 1 and postSimulationConnection2 then
					postSimulationConnection2:Disconnect()
				end
			end)
			maid:Add(function()
				if postSimulationConnection2 then
					postSimulationConnection2:Disconnect()
				end
			end)
		end))
		return function()
			maid:Destroy()
		end
	end
})