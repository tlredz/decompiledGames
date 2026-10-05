local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
require(ReplicatedStorage.Shared.EventTypes)
local Glitch = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.Synchronizer)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("EventService/Glitch/HoleEffect")
local _ = script.Name
local maid = Trove.new()

function Glitch.OnStart(_)
	Random.new()
	ReplicatedStorage:SetAttribute("GlitchEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("GlitchEvent", nil)
	end)
	CycleController:Update()
	SoundController:UpdateOST()
end

function Glitch.OnStop(_)
	maid:Destroy()
end

function Glitch.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
		local animalRootPart = ClientEventUtils.getAnimalRootPart(p)

		if not animalRootPart then
			return
		end

		local clone = script.Hole:Clone()
		local animalCFrame = ClientEventUtils.getAnimalCFrame(p)
		clone:PivotTo(CFrame.new(animalCFrame.X, -9.782 + clone.Size.Y * 0.5, animalCFrame.Z + clone.Size.Z * 0.5))
		clone.Parent = workspace
		task.spawn(function()
			SoundController:PlaySound("Sounds.Events.Glitch.Hole", clone:GetPivot().Position)
		end)
		local pivot = animalRootPart:GetPivot()
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function(_)
			debug.profilebegin("Glitch:Hole")
			local v = workspace:GetServerTimeNow() - p2
			local v2

			if v < 0.15 then
				v2 = 0
			elseif v < 1 then
				v2 = -MathUtils.simulateGravity((math.clamp((v - 0.15) / 0.85, 0, 1)))
			else
				v2 = MathUtils.simulateGravity(0.4) - MathUtils.simulateGravity(math.clamp((v - 1) / 0.5, 0, 1) * 0.4)
			end

			if v >= 1.5 then
				postSimulationConnection:Disconnect()
				clone:Destroy()
			elseif v >= 1 then
				VFX.disable(clone)
			end

			animalRootPart:PivotTo(pivot + Vector3.new(0, v2, 0))
			debug.profileend()
		end)
	end)
end

return Glitch