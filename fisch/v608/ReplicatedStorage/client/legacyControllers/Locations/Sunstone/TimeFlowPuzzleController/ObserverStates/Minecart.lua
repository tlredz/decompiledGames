local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local State = require(packages.State)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local SharedTimeFlowPuzzle = require(modules.SharedTimeFlowPuzzle)
require("../Types")
local completionStateObjects = {
	CartStopped = State.new(false),
	GemCollected = State.new(false),
	LeverFlipped = State.new(false)
}
local anno_localthought = ReplicatedStorage.events.anno_localthought

-- equivalent calls inferred from this helper; original call sites unknown
local function hideGem(instance)
	for _, child in instance:GetChildren() do
		child.Transparency = 1
	end

	instance.Transparency = 1
end

local function observerCallback(data)
	local maid = Trove.new()
	local nodes = data.Nodes
	local minecart = data.Minecart
	local lever = data.Lever
	local gem = minecart.Gem
	local sound = minecart:FindFirstChildWhichIsA("Sound", true)
	sound:Play()
	local count = #nodes.NormalTrack:GetChildren()
	local count2 = #nodes.RunawayTrack:GetChildren()
	local v2 = {}
	local v3 = {}

	for i = 1, count do
		table.insert(v2, nodes.NormalTrack[tostring(i)])
	end

	for i = 1, count2 do
		table.insert(v3, nodes.RunawayTrack[tostring(i)])
	end

	local v4 = count
	local v5 = minecart:GetExtentsSize().Y / 2
	local v6 = nil
	local v7 = maid:Add(Instance.new("ProximityPrompt"))
	v7.ActionText = "Pull"
	v7.ObjectText = "Track Lever"
	v7.RequiresLineOfSight = false
	v7.Parent = lever:FindFirstChildWhichIsA("BasePart")
	v7.Triggered:Connect(function()
		if completionStateObjects.LeverFlipped:get() then
			anno_localthought:Fire("[Cooldown...]")
			return
		end

		completionStateObjects.LeverFlipped:set(true)
		v7.Enabled = false
		local main = lever:FindFirstChild("Main", true)

		if main then
			TweenService:Create(
				main.Weld,
				TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
				{
					C1 = CFrame.Angles(0, 0, -45)
				}
			):Play()
		end

		task.wait(1.5)
		task.defer(function()
			task.wait(1)
			completionStateObjects.LeverFlipped:set(false)

			if v7 then
				v7.Enabled = true
			end
		end)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getAmendedCFrame(cframe: CFrame)
		return cframe * CFrame.new(0, v5, 0)
	end

	local function onRunawayFinish()
		sound:Stop()

		for _, effect in minecart:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		if not completionStateObjects.CartStopped:get() then
			SharedTimeFlowPuzzle.Network.CartStopped:FireServer()
		end

		if completionStateObjects.GemCollected:get() then
			hideGem(gem) -- equivalent call inferred; original call site unknown
		else
			local v8 = maid:Add(Instance.new("ProximityPrompt"))
			v8.ObjectText = "The Cut Gem"
			v8.ActionText = "Collect"
			v8.RequiresLineOfSight = false
			v8.Parent = gem
			maid:Add(completionStateObjects.GemCollected:observe(function(p)
				if p == true then
					v8:Destroy()
					hideGem(gem) -- equivalent call inferred; original call site unknown
				end
			end))
			v8.Triggered:Connect(function()
				SharedTimeFlowPuzzle.Network.CollectCutGem:FireServer()
			end)
		end
	end

	local function startMinecart()
		local v8 = 1

		if minecart.PrimaryPart then
			minecart.PrimaryPart.CFrame = getAmendedCFrame(v2[count].CFrame)
		end

		local flag = false

		while true do
			local v9 = false

			for i = v4, count do
				if completionStateObjects.CartStopped:get() then
					v9 = true
					flag = true
					break
				else
					v9 = count == i and completionStateObjects.LeverFlipped:get() and true or v9

					if v9 then
						break
					end

					local _ = count < i + 1
					local v11 = v2[i]
					local v12

					if minecart:GetPivot().Y < v11.Position.Y then
						sound.PlaybackSpeed = 1
						v12 = v8 + 4
					else
						sound.PlaybackSpeed = 2
						v12 = v8 - 1
					end

					v8 = v12 < 0.5 and 0.5 or v12 < 2 and 2 or v12
					local v13 = v8 * 0.5
					local tweenInfo = TweenInfo.new(v13 / 2, Enum.EasingStyle.Linear)
					v6 = TweenService:Create(minecart.PrimaryPart, tweenInfo, {
						CFrame = getAmendedCFrame(v11.CFrame)
					})

					if not v6 then
						break
					end

					v6:Play()
					v6.Completed:Wait()
				end
			end

			if v9 then
				v6 = nil

				if flag then
					if minecart.PrimaryPart then
						minecart.PrimaryPart.CFrame = getAmendedCFrame(v3[count2].CFrame)
						onRunawayFinish()
						break
					end
				else
					anno_localthought:Fire("You hear a satisfying click as the cart changes direction.")
					local tweenInfo = TweenInfo.new(v8 * 0.5, Enum.EasingStyle.Linear)
					v6 = TweenService:Create(minecart.PrimaryPart, tweenInfo, {
						CFrame = getAmendedCFrame(v3[1].CFrame)
					})

					if v6 then
						v6:Play()
						v6.Completed:Wait()
					end

					local tweenInfo2 = TweenInfo.new(v8 * 0.5, Enum.EasingStyle.Linear)

					for i = 1, count2 - 1 do
						v6 = TweenService:Create(minecart.PrimaryPart, tweenInfo2, {
							CFrame = getAmendedCFrame(v3[i + 1].CFrame)
						})

						if not v6 then
							continue
						end

						v6:Play()
						v6.Completed:Wait()
					end

					onRunawayFinish()
				end

				break
			else
				v4 = 1
			end
		end
	end

	maid:Add(task.spawn(startMinecart))
	return function()
		maid:Destroy()

		if v6 then
			v6:Cancel()
		end
	end
end

return {
	ObserverCallback = observerCallback,
	CompletionStateObjects = completionStateObjects,
	Tag = SharedTimeFlowPuzzle.CollectionServiceTags.MinecartContainer
}