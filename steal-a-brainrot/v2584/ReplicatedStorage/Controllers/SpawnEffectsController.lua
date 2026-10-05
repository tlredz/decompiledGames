local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
return {
	Start = function(_)
		Net:RemoteEvent("GameService/SpawnEffect").OnClientEvent:Connect(function(p: string, _: number, p2: number, cFrame: CFrame?)
			if not cFrame then
				local start = workspace.Road:FindFirstChild("Start")
				cFrame = start and start.CFrame or script.RoadStartBase.CFrame
			end

			assert(cFrame)
			local effect = BrainrotAssets.getEffect(p)

			if not effect then
				return
			end

			local clone = effect:Clone()
			local clone2 = script.RoadStartBase:Clone()
			clone2.Parent = clone
			clone.PrimaryPart = clone2
			clone:PivotTo(cFrame)
			clone.PrimaryPart = nil
			clone2:Destroy()
			clone.Parent = workspace
			VFX.emit(clone)

			for _, sound in clone:GetDescendants() do
				if sound:IsA("Sound") then
					sound:Play()
				end
			end

			task.wait(p2 + 5)
			clone:Destroy()
		end)
	end
}