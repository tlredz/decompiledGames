local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.packages.Signal)
local statuseffects = require(ReplicatedStorage.shared.modules.library.statuseffects)
local ReplicatorClient = require(ReplicatedStorage.client.modules.ReplicatorClient)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local DynamicString = require(ReplicatedStorage.shared.modules.DynamicString)
local RomanNumerals = require(ReplicatedStorage.shared.utils.RomanNumerals)
local LocalPassive = require(ReplicatedStorage.shared.modules.LocalPassive)
local statusEffects = ReplicatorClient.get("StatusEffects")
local statuses = HudController:GetSafeZone():WaitForChild("statuses")
local currentFrames = {}
local passive_sources = {}
local colorSequence = ColorSequence.new(Color3.new(1, 1, 1))
local StatusEffectsController = {
	CurrentFrames = currentFrames,
	_replicator = statusEffects,
	_passive_sources = passive_sources,
	StatusAdded = Signal.new(),
	StatusChanged = Signal.new(),
	StatusRemoved = Signal.new(),
	_FormatTimer = function(p: number)
		if p < 0 then
			return "00:00"
		end

		local v3 = {}
		local v4 = p // 86400
		local v5 = p // 3600 % 24
		local v6 = p // 60 % 60
		local v7 = p // 1 % 60

		if v4 > 0 then
			table.insert(v3, v4)
		end

		if v5 > 0 or v4 > 0 then
			if v4 > 0 then
				table.insert(v3, string.format("%02d", v5))
			else
				table.insert(v3, v5)
			end
		end

		table.insert(v3, string.format("%02d:%02d", v6, v7))
		return table.concat(v3, ":")
	end
}

function StatusEffectsController._UpdateTimer(p, p2: string)
	local v3 = currentFrames[p2]

	if not v3 then
		return
	end

	if not p.EndTime then
		v3.timer.Text = ""
		return
	end

	local v4 = p.EndTime - workspace:GetServerTimeNow()
	v3.timer.Text = StatusEffectsController._FormatTimer(v4)
end

function StatusEffectsController.UpdateStatus(p, p2: string)
	local statuseffect = statuseffects[p.Id]

	if not statuseffect then
		warn((`Unknown status effect id "{p.Id}"`))
		return nil
	end

	local v3 = currentFrames[p2]

	if not v3 then
		return StatusEffectsController.AddStatus(p, p2)
	end

	local data = p.Data

	if not data.StackNumeral then
		data = table.clone(data)
		data.StackNumeral = RomanNumerals:ToRoman(data.Stack or 1)
	end

	v3.Name = p.Id .. p2
	v3.icon.Image = statuseffect.Icon
	v3.displayName.Text = DynamicString:Format(statuseffect.NameFormat, data)
	v3.tooltip.Text = DynamicString:Format(statuseffect.DescriptionFormat, data)
	StatusEffectsController._UpdateTimer(p, p2)
	local colorSequence2 = typeof(statuseffect.MainColor) == "Color3" and ColorSequence.new(statuseffect.MainColor) or statuseffect.MainColor or colorSequence
	local colorSequence3 = typeof(statuseffect.IconColor) == "Color3" and ColorSequence.new(statuseffect.IconColor) or statuseffect.IconColor or colorSequence

	for _, v4 in v3:QueryDescendants("UIGradient") do
		if v4.Name == "IconGradient" then
			v4.Color = colorSequence3
		else
			v4.Color = colorSequence2
		end
	end

	if not v3:FindFirstChild("changeGlow") then
		return
	end

	v3.changeGlow.ImageTransparency = 0
	task.defer(function()
		if not v3:FindFirstChild("changeGlow") then
			return
		end

		TweenService:Create(v3.changeGlow, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
	end)
	StatusEffectsController.StatusChanged:Fire(p, p2)

	if not statuseffect.ClientFishingPassives then
		return v3
	end

	if not passive_sources[p2] then
		passive_sources[p2] = LocalPassive:GetSource((`Status_{p.Id}.{p2}`))
	end

	local object = DynamicString:ResolveObject(statuseffect.ClientFishingPassives, p.Data)
	passive_sources[p2]:SetActivePassives(object)
	return v3
end

function StatusEffectsController.AddStatus(p, p2: string)
	if not statuseffects[p.Id] then
		warn((`Unknown status effect id "{p.Id}"`))
		return
	end

	local clone = script.statusTemplate:Clone()
	currentFrames[p2] = clone
	StatusEffectsController.StatusAdded:Fire(p, p2)
	StatusEffectsController.UpdateStatus(p, p2)
	clone.Parent = statuses
	return clone
end

function StatusEffectsController.RemoveStatus(p: string)
	local v3 = passive_sources[p]

	if v3 then
		v3:Destroy()
		passive_sources[p] = nil
	end

	local v4 = currentFrames[p]

	if not v4 then
		return false
	end

	v4:Destroy()
	currentFrames[p] = nil
	StatusEffectsController.StatusRemoved:Fire(p)
	return true
end

function StatusEffectsController.HasStatusOfType(_, p: string)
	statusEffects:WaitForLoaded()

	for _, v3 in statusEffects.Data do
		if v3.Id == p then
			return true
		end
	end

	return false
end

function StatusEffectsController.GetStatusesOfType(_, p: string)
	statusEffects:WaitForLoaded()
	local result = {}

	for _, v3 in statusEffects.Data do
		if v3.Id == p then
			table.insert(result, v3)
		end
	end

	return result
end

function StatusEffectsController.GetAllStatuses(_)
	statusEffects:WaitForLoaded()
	local result = {}

	for _, v3 in statusEffects.Data do
		table.insert(result, v3)
	end

	return result
end

function StatusEffectsController.Start(_)
	statusEffects:WaitForLoaded()

	if statusEffects.Data then
		for k, v3 in statusEffects.Data do
			task.spawn(StatusEffectsController.AddStatus, v3, k)
		end
	end

	statusEffects:ListenRaw(function(p, p2)
		for k in p2 or p do
			if p[k] then
				StatusEffectsController.UpdateStatus(p[k], k)
			else
				StatusEffectsController.RemoveStatus(k)
			end
		end
	end)
	local now = 0
	RunService.RenderStepped:Connect(function()
		if not statusEffects.Data then
			return
		end

		if tick() - now >= 0.25 then
			now = tick()

			for k, v3 in statusEffects.Data do
				if v3.EndTime then
					StatusEffectsController._UpdateTimer(v3, k)
				end
			end
		end
	end)
end

return StatusEffectsController