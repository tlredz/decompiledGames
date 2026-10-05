local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EggCity/EggBurst")
local models = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid)
	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

return table.freeze({
	Start = function(_)
		local maid = Trove.new()

		for i = 1, 4 do
			local model = script:FindFirstChild((`Egg{i}`))

			if model and model:IsA("Model") then
				models[i] = model
			end
		end

		maid:Add(Observers.observeTag("EggCityEgg", function(part)
			local maid2 = Trove.new()
			local parent = part.Parent

			if not parent then
				return nil
			end

			local variant = parent:GetAttribute("Variant") or 1
			local v = models[variant] or models[1]

			if not v then
				return nil
			end

			local clone = maid2:Clone(v)
			clone:ScaleTo(parent:GetAttribute("Scale") or 1)
			clone.Parent = workspace
			local weld = Instance.new("Weld")
			weld.Part0 = clone.PrimaryPart
			weld.Part1 = part
			weld.C0 = clone.PrimaryPart.PivotOffset
			weld.Parent = clone.PrimaryPart
			local animator = clone.AnimationController.Animator
			local track = loadAnimation(animator, script.EggIdle, maid2) -- equivalent call inferred; original call site unknown
			track.Priority = Enum.AnimationPriority.Idle
			track.Looped = true
			track:Play()
			local track2 = loadAnimation(animator, script.EggWalk, maid2) -- equivalent call inferred; original call site unknown
			track2.Priority = Enum.AnimationPriority.Action
			track2.Looped = true
			maid2:Add(Observers.observeAttribute(parent, "Moving", function(p)
				if p then
					track2:Play(0.2, 1, 2)
				else
					track2:Stop()
				end

				return nil
			end))
			return maid2:WrapClean()
		end, { workspace }))
		maid:Add(remoteEvent.OnClientEvent:Connect(function(value: string)
			if type(value) ~= "string" then
				return
			end

			ClientEventUtils.playBurst(script.Burst, value, { ReplicatedStorage.Sounds.Events.Easter.Hit })
		end))
		return function()
			maid:Destroy()
		end
	end
})