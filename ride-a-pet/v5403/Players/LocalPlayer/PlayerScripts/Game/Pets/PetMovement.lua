local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local PetRenderer = require(script.Parent:WaitForChild("PetRenderer"))

local function SeedFor(value)
	local v = 0

	for i = 1, #value do
		v = (v * 31 + string.byte(value, i)) % 2147483647
	end

	return v
end

local function PointOnPlot(instance, random)
	local v = math.max(instance.Size.X / 2 - 3, 0.5)
	local v2 = instance.Size.Z / 2
	local v3 = -v2 + 19.5
	local v4 = v2 - 3

	if v4 - 1 < v3 then
		v3 = v4 - 1
	end

	local cframe = CFrame.new(
		(random:NextNumber() - 0.5) * (v * 2),
		instance.Size.Y / 2,
		v3 + random:NextNumber() * (v4 - v3)
	)
	return (instance.CFrame * cframe).Position
end

local function EraOpening(p, p2, p3)
	local random = Random.new(p2 + p3 * 104729)
	return PointOnPlot(p, random), random:NextInteger(5, 15)
end

local function SolvePet(p, wanderSeed, wanderSpeed, p2)
	local v = math.floor(p2 / 60)
	local validUntil = (v + 1) * 60
	local startTime = v * 60
	local random = Random.new(wanderSeed + v * 104729)
	local v4 = PointOnPlot(p, random)
	local integer = random:NextInteger(5, 15)
	local v5 = v + 1
	local random2 = Random.new(wanderSeed + v5 * 104729)
	local target = PointOnPlot(p, random2)
	local integer2 = random2:NextInteger(5, 15)
	local random3 = Random.new(wanderSeed + v * 7919)
	local count = 0

	while true do
		local integer3 = random3:NextInteger(1, 3)

		if validUntil - startTime <= integer3 + 0.4 then
			break
		end

		if p2 < startTime + integer3 then
			return {
				Moving = false,
				Leg = count,
				Position = v4,
				Height = integer,
				ValidUntil = startTime + integer3
			}
		end

		local startTime2 = startTime + integer3
		count += 1
		local target2 = PointOnPlot(p, random3)
		integer = random3:NextInteger(5, 15)
		local duration = math.clamp((target2 - v4).Magnitude / math.max(wanderSpeed, 0.1), 0.4, 2.6)

		if p2 < startTime2 + duration then
			return {
				Moving = true,
				Leg = count,
				From = v4,
				Target = target2,
				Height = integer,
				StartTime = startTime2,
				Duration = duration,
				ValidUntil = startTime2 + duration
			}
		end

		startTime = startTime2 + duration
		v4 = target2
	end

	local duration2 = math.max(validUntil - startTime, 0.1)
	return {
		Moving = true,
		Leg = count + 1,
		From = v4,
		Target = target,
		Height = integer2,
		StartTime = startTime,
		Duration = duration2,
		ValidUntil = validUntil
	}
end

local function EraSpeed(data, p, p2)
	if not (data.SpeedReference and data.BirthTime) then
		return data.MoveSpeed or 6
	end

	local v = os.time() - (p - p2 * 60) / 0.5
	local stateFrom = PetAging.StateFrom(data.BirthTime, v, data)

	if not (data.BaseWeight and PetAging.WeightFor(data.BaseWeight, stateFrom)) then
		local _ = PetAging.WeightStandardKG
	end

	return data.SpeedReference
end

local v = {}
Players.PlayerRemoving:Connect(function(player)
	v[player.UserId] = nil
end)

local function BaseplateFor(ownerUserId)
	local playerByUserId = Players:GetPlayerByUserId(ownerUserId)
	local v2 = v[ownerUserId]

	if playerByUserId and v2 and v2.Plot.Parent == workspace:FindFirstChild("Plots") and v2.Owner.Parent == v2.Data and v2.Data.Parent == v2.Plot and v2.Owner.Value == playerByUserId and v2.Baseplate.Parent == v2.Plot then
		return v2.Baseplate
	end

	v[ownerUserId] = nil
	local plot = playerByUserId and General:GetPlot(playerByUserId)
	local baseplate = plot and plot:FindFirstChild("Baseplate")
	local data = plot and plot:FindFirstChild("Data")
	local owner = data and data:FindFirstChild("Owner")

	if baseplate and owner then
		v[ownerUserId] = {
			Plot = plot,
			Data = data,
			Owner = owner,
			Baseplate = baseplate
		}
	end

	return baseplate
end

local ProximityPromptService = game:GetService("ProximityPromptService")
local v2 = {
	RidePrompt = true,
	Ride = true,
	Feed = true,
	NameTagPrompt = true
}
local v3 = {}
ProximityPromptService.PromptShown:Connect(function(p)
	if v2[p.Name] then
		v3[p] = true
	end
end)
ProximityPromptService.PromptHidden:Connect(function(p)
	v3[p] = nil
end)

local function IsHeld(p)
	local model = p.Model

	if model:GetAttribute("NamingHold") == true then
		return true
	end

	for k in v3 do
		if k.Parent then
			if k:IsDescendantOf(model) then
				return true
			end
		else
			v3[k] = nil
		end
	end

	return false
end

local now = os.clock()
RunService.Heartbeat:Connect(function()
	local now2 = os.clock()
	local v4 = now2 - now
	now = now2
	local serverTimeNow = workspace:GetServerTimeNow()
	local v5 = {}

	for _, v6 in pairs(PetRenderer.GetAll()) do
		if not (v6.Model and v6.Model.Parent) then
			continue
		end

		local ownerUserId = v6.OwnerUserId

		if IsHeld(v6) then
			PetRenderer.PauseMove(ownerUserId, v6.PetKey)
			v6.FreezeOffset = (v6.FreezeOffset or 0) + v4
		else
			if v6.Paused then
				PetRenderer.ResumeMove(ownerUserId, v6.PetKey)
			end

			local at = (serverTimeNow - (v6.FreezeOffset or 0)) * 0.5

			if v5[ownerUserId] == nil then
				v5[ownerUserId] = BaseplateFor(ownerUserId) or false
			end

			local baseplate = v5[ownerUserId]

			if baseplate then
				local wanderSeed = v6.WanderSeed

				if not wanderSeed then
					local petKey = v6.PetKey
					wanderSeed = 0

					for i = 1, #petKey do
						wanderSeed = (wanderSeed * 31 + string.byte(petKey, i)) % 2147483647
					end

					v6.WanderSeed = wanderSeed
				end

				local v9 = math.floor(at / 60)

				if v6.WanderEra ~= v9 then
					v6.WanderEra = v9
					v6.WanderSpeed = EraSpeed(v6, at, v9)
				end

				local wanderSolution = v6.WanderSolution
				local wanderSpeed = v6.WanderSpeed or 6

				if not wanderSolution or at < wanderSolution.At or wanderSolution.State.ValidUntil <= at or wanderSolution.Era ~= v9 or wanderSolution.Seed ~= wanderSeed or wanderSolution.Speed ~= wanderSpeed or wanderSolution.Baseplate ~= baseplate or wanderSolution.CFrame ~= baseplate.CFrame or wanderSolution.Size ~= baseplate.Size then
					wanderSolution = {
						At = at,
						Era = v9,
						Seed = wanderSeed,
						Speed = wanderSpeed,
						Baseplate = baseplate,
						CFrame = baseplate.CFrame,
						Size = baseplate.Size,
						State = SolvePet(baseplate, wanderSeed, wanderSpeed, at)
					}
					v6.WanderSolution = wanderSolution
				end

				local state = wanderSolution.State

				if state.Leg ~= v6.WanderLeg then
					v6.WanderLeg = state.Leg
					local flyHeight = v6.FlyHeight or state.Height

					if state.Moving then
						local v10 = math.clamp(at - state.StartTime, 0, state.Duration)
						local v11 = not (state.Duration > 0) and 1 or v10 / state.Duration or 1
						v6.FlyHeight = flyHeight + (state.Height - flyHeight) * v11
						PetRenderer.SnapTo(ownerUserId, v6.PetKey, state.From:Lerp(state.Target, v11))
						v6.FlyHeight = state.Height
						PetRenderer.MoveTo(ownerUserId, v6.PetKey, state.Target, (state.Duration - v10) / 0.5)
					else
						v6.FlyHeight = state.Height
						PetRenderer.SnapTo(ownerUserId, v6.PetKey, state.Position)
					end
				end
			end
		end
	end
end)