game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Controllers.WorldBrainrotController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EggrotCandyCage/Break")
TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In)
TweenInfo.new(0.8, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
return table.freeze({
	Start = function(_, p)
		local maid = Trove.new()
		local v = {}
		local v2 = ReplicatorClient.get("EggrotHunt/Brainrots")

		local function onRendered(p2: string)
			local v3 = p[p2]

			if not (v3 and v3.prompt) then
				return
			end

			local v4 = v2:TryIndex({ "brainrots", p2 })

			if v4 and v4.caged then
				v3.prompt.Enabled = false
			end
		end

		maid:Add(remoteEvent.OnClientEvent:Connect(function(p2: string, cframe: CFrame, cframe2: CFrame)
			SoundController:PlaySound("Sounds.Events.Easter.CageBreak", cframe.Position, false)
			local v3 = p[p2]

			if v3 and v3.prompt then
				v3.prompt.Enabled = true
			end

			local pivot = nil
			local v4 = nil
			local lastTime = os.clock()
			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				local v5 = p[p2]

				if not (v5 and v5.model) then
					return
				end

				if not pivot then
					pivot = v5.model:GetPivot()
					v4 = cframe2
				end

				local v6 = math.clamp((os.clock() - lastTime) / 0.8, 0, 1)
				local value = TweenService:GetValue(v6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
				v5.model:PivotTo(pivot:Lerp(v4, value))

				if v6 >= 1 and postSimulationConnection then
					postSimulationConnection:Disconnect()
					postSimulationConnection = nil
				end
			end)
			maid:Add(function()
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
				end
			end)
		end))

		local function cleanup()
			maid:Destroy()
			table.clear(v)
		end

		return cleanup, onRendered
	end
})