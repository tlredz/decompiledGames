local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local localPlayer = Players.LocalPlayer
local NightIllumination = {}
local v = nil
local v2 = {}
local v3 = {}
local flag = false
task.spawn(function()
	local Utility = require(ReplicatedStorage.CAM.Global.Utility)
	local Clans = require(ReplicatedStorage.CAM.Clans)
	local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
	local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
	local data = Utility.GetData(localPlayer)

	while data == nil do
		task.wait(1)
		data = Utility.GetData(localPlayer)
	end

	local clan = data:WaitForChild("Clan", 10)
	local inventory = data:FindFirstChild("Inventory")
	local stats

	if not (inventory == nil or inventory:FindFirstChild("Accessories") == nil) then
		stats = inventory.Accessories:FindFirstChild("Stats") or nil
	end

	if clan == nil or stats == nil then
		return
	end

	local function evaluate()
		flag = false

		if not Clans.HasPassive(clan.Value, "Maskful Sight") then
			return
		end

		for _, v4 in Character_info_provider.getEquippedAccessoryStats(localPlayer) do
			local item = Items[v4]

			if not (item ~= nil and item.IsMask) then
				continue
			end

			flag = true
			break
		end
	end

	clan.Changed:Connect(evaluate)

	for _, valueBase in stats:GetChildren() do
		if valueBase:IsA("ValueBase") then
			valueBase.Changed:Connect(evaluate)
		end
	end

	stats.ChildAdded:Connect(function(valueBase)
		if valueBase:IsA("ValueBase") then
			valueBase.Changed:Connect(evaluate)
			evaluate()
		end
	end)
	evaluate()
end)

local function getIllumination()
	local v4 = math.max(0, PlayerStatResolver.GetStat(localPlayer, "Illumination") or 0) + 1

	if flag then
		return v4 * 1.5
	end

	return v4
end

local function deriveNight(day)
	return {
		Ambient = Color3.new(
			math.min(1, day.Ambient.R + 0.0784313725490196),
			math.min(1, day.Ambient.G + 0.0784313725490196),
			(math.min(1, day.Ambient.B + 0.0784313725490196))
		),
		ExposureCompensation = day.ExposureCompensation + 0.85
	}
end

local function computeTarget(config)
	local v4 = config.AlwaysNight == true or DayAndNightHandler.IsEnabled() and DayAndNightHandler.IsNight()
	local night

	if v4 then
		night = config.Night or config.Day and deriveNight(config.Day)
	else
		night = config.Day
	end

	if night == nil then
		return nil, nil, nil, nil
	end

	local v5

	if v4 then
		local v6 = math.max(0, PlayerStatResolver.GetStat(localPlayer, "Illumination") or 0) + 1

		if flag then
			v6 *= 1.5
		end

		v5 = v6 - 1
	else
		v5 = 0
	end

	local color = Color3.new(
		math.min(1, night.Ambient.R + v5 * 0.0392156862745098),
		math.min(1, night.Ambient.G + v5 * 0.0392156862745098),
		(math.min(1, night.Ambient.B + v5 * 0.0392156862745098))
	)
	local density = night.Density or v4 and 0.6 or 0.4

	for _, v6 in v2 do
		density += v6
	end

	local v6 = math.clamp(density - v5 * 0.275, 0.325, 1)
	local offset = night.Offset or v4 and 0.4 or 0.236

	if v4 then
		offset = math.min(1, offset + math.clamp(v5, 0, 1) * 0.6)
	end

	return color, night.ExposureCompensation + v5 * 0.35, v6, offset
end

local function update(state)
	if v ~= state then
		return
	end

	local v4, v5, v6, v7 = computeTarget(state.config)

	if v4 == nil or v5 == nil then
		return
	end

	if next(v3) == nil and (v4 ~= state.lastAmbient or v5 ~= state.lastExposure) then
		state.lastAmbient = v4
		state.lastExposure = v5

		if state.tween ~= nil then
			state.tween:Cancel()
		end

		local tween = TweenService:Create(Lighting, TweenInfo.new(2), {
			Ambient = v4,
			ExposureCompensation = v5
		})
		state.tween = tween
		tween:Play()
	end

	if v6 ~= nil and v6 ~= state.lastDensity or v7 ~= nil and v7 ~= state.lastOffset then
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		if atmosphere ~= nil then
			state.lastDensity = v6
			state.lastOffset = v7

			if state.atmosphereTween ~= nil then
				state.atmosphereTween:Cancel()
			end

			local tween = TweenService:Create(atmosphere, TweenInfo.new(2), {
				Density = v6,
				Offset = v7
			})
			state.atmosphereTween = tween
			tween:Play()
		end
	end
end

function NightIllumination.Start(config)
	NightIllumination.Stop()
	local v4 = {
		config = config
	}
	v = v4
	v4.detach = PlayerStatResolver.Attach(localPlayer, "Illumination", function()
		update(v4)
	end)
	v4.loop = task.spawn(function()
		while v == v4 do
			update(v4)
			task.wait(0.5)
		end
	end)
end

function NightIllumination.Hold(p: string)
	v3[p] = true

	if v ~= nil and v.tween ~= nil then
		v.tween:Cancel()
	end
end

function NightIllumination.Release(p: string)
	if v3[p] == nil then
		return
	end

	v3[p] = nil

	if next(v3) == nil and v ~= nil then
		v.lastAmbient = nil
		v.lastExposure = nil
		update(v)
	end
end

function NightIllumination.SetDensityBonus(p: string, p2: number?)
	v2[p] = p2
end

function NightIllumination.Stop()
	local v4 = v

	if v4 == nil then
		return
	end

	v = nil

	if v4.detach ~= nil then
		v4.detach()
	end

	if v4.loop ~= nil then
		task.cancel(v4.loop)
	end

	if v4.tween ~= nil then
		v4.tween:Cancel()
	end

	if v4.atmosphereTween ~= nil then
		v4.atmosphereTween:Cancel()
	end
end

return NightIllumination