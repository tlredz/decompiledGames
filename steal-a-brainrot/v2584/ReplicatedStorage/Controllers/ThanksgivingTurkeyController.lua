local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("ThanksgivingTurkeyService/UpdateAnimation")
local remoteEvent2 = Net:RemoteEvent("ThanksgivingTurkeyService/UpdateHealthBar")
local remoteEvent3 = Net:RemoteEvent("ThanksgivingTurkeyService/PlayAnimation")
local remoteEvent4 = Net:RemoteEvent("ThanksgivingTurkeyService/Despawn")
local remoteEvent5 = Net:RemoteEvent("ThanksgivingTurkeyService/Spawn")
local maid = Trove.new()
local instant = 10
local v = instant
local clone = nil
return {
	Start = function(_)
		local function updateHealthBar()
			if clone then
				clone.Progress.Label.Text = `{v}/{instant}`
				clone.Enabled = v > 0
				local v2 = v / instant
				Spr.target(clone.Progress.Fill, 1, 5, {
					Size = UDim2.fromScale(v2, 1)
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateOverheadVisibility(p: string)
			local v2 = AnimalController:GetAnimals()[p]

			if v2 then
				local animalOverhead = v2.AnimalModel:FindFirstChild("AnimalOverhead", true)

				if animalOverhead and animalOverhead:IsA("BillboardGui") then
					animalOverhead.Enabled = v <= 0 or clone == nil
				end
			end
		end

		remoteEvent5.OnClientEvent:Connect(function(p: string)
			maid:Clean()
			local clone_2 = maid:Clone(script.VFX)
			clone_2.Parent = workspace
			instant = FFlags:GetInstant("ThanksgivingTurkeyService/Health", 10)
			local v2 = 5

			while not AnimalController:GetAnimals()[p] and v2 > 0 do
				v2 -= task.wait()
			end

			local v3 = AnimalController:GetAnimals()[p]

			if v3 then
				clone = maid:Clone(script.HealthBar)
				assert(clone)
				clone.Parent = v3.AnimalModel:FindFirstChild("OVERHEAD_ATTACHMENT", true) or v3.AnimalModel.PrimaryPart
				updateHealthBar()
				updateOverheadVisibility(p) -- equivalent call inferred; original call site unknown
				maid:Add(function()
					clone = nil
				end)
			end
		end)
		remoteEvent4.OnClientEvent:Connect(function(p: string)
			maid:Clean()
			updateOverheadVisibility(p) -- equivalent call inferred; original call site unknown
			v = 10
		end)
		remoteEvent2.OnClientEvent:Connect(function(p: string, p2)
			v = p2
			updateHealthBar()
			updateOverheadVisibility(p) -- equivalent call inferred; original call site unknown
		end)
		remoteEvent3.OnClientEvent:Connect(function(p: string, childName: string?)
			local v2 = AnimalController:GetAnimals()[p]

			if not v2 then
				return
			end

			local animationController = v2.AnimalModel.AnimationController
			local animator = animationController.Animator or Instance.new("Animator", animationController)
			local child = childName and script.Animations:FindFirstChild(childName)

			if child then
				local track = animator:LoadAnimation(child)
				track.Looped = false
				track:Play()
				track:AdjustSpeed(child:GetAttribute("Speed") or 1)
				v2.Collector:Add(function()
					if track then
						track:Stop(0)
						track:Destroy()
					end
				end)
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(p: string, childName: string?)
			local v2 = AnimalController:GetAnimals()[p]

			if not v2 then
				return
			end

			local animationController = v2.AnimalModel.AnimationController
			local animator = animationController.Animator or Instance.new("Animator", animationController)
			local child = childName and script.Animations:FindFirstChild(childName)

			if child then
				local track = animator:LoadAnimation(child)
				track:Play()
				track:AdjustSpeed(child:GetAttribute("Speed") or 1)

				if v2.TurkeyTrack then
					v2.TurkeyTrack:Stop(0)
					v2.TurkeyTrack:Destroy()
				end

				v2.TurkeyTrack = track
				v2.Collector:Add(function()
					if v2.TurkeyTrack then
						v2.TurkeyTrack:Stop(0)
						v2.TurkeyTrack:Destroy()
					end
				end)
			elseif v2.TurkeyTrack then
				v2.TurkeyTrack:Stop(0)
				v2.TurkeyTrack:Destroy()
			end
		end)
	end
}