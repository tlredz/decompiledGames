local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local tween = Util.Tween
local Extend = require(ReplicatedStorage.EffectContainer.Dough.Util.Arms.Extend)
local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()
	local count = 0

	for _, _ in pairs(object.Pool) do
		count += 1
	end

	for _, v2 in pairs(object.Pool) do
		if v2.Finished then
			if v2.Indicator then
				v2.Indicator:SetAttribute("Disengage", true)
				v2.Indicator:SetAttribute("ArmActive", false)
			end

			v2.Arm:Destroy()
			object:remove(v2)
		else
			v2.UpdateDelta = math.min(v2.UpdateDelta, p)

			if now - v2.LastUpdate >= math.clamp(v2.UpdateDelta * (count / 25), v2.UpdateDelta, 0.1) then
				local v3 = now - v2.Start
				local v4 = v2.CurrentLoop == v2.Repetitions
				local flag = false
				local v5 = nil
				local v6

				if v3 - v2.ExtendDuration - v2.FreezeDuration - v2.RetractDuration > 0 then
					v6 = v5 and 1 or 0
					flag = true
				elseif v3 - v2.ExtendDuration - v2.FreezeDuration > 0 then
					v5 = false
					local v7 = math.min(1, (v3 - v2.ExtendDuration - v2.FreezeDuration) / v2.RetractDuration)
					v6 = tween.ease[v4 and "inout" or "in"][v4 and "circ" or "quad"](v7, 1, -1, 1)
					v2.CalledExtend = false

					if not v2.CalledRetract then
						v2.Arm.Events.Retract:Fire()
						v2.CalledRetract = true
					end
				elseif v3 - v2.ExtendDuration > 0 then
					math.min(1, (v3 - v2.ExtendDuration) / v2.FreezeDuration)
					v6 = 1
				else
					v5 = true
					local v7 = math.min(1, v3 / v2.ExtendDuration)
					v6 = tween.ease.out[v4 and "quint" or "quad"](v7, 0, 1, 1)
					v2.CalledRetract = false

					if not v2.CalledExtend then
						v2.Arm.Events.Extend:Fire()
						v2.CalledExtend = true
					end
				end

				if v5 == false and v4 then
					local shrinkAlpha = v2.ShrinkAlpha

					if shrinkAlpha <= 1 - v6 then
						local v7 = math.min(1, (1 - v6 - shrinkAlpha) / (1 - shrinkAlpha))
						local quad = tween.ease["in"].quad(v7, 0, 1, 1)

						if not v2.OriginalWidth then
							v2.OriginalWidth = v2.Arm.Width
						end

						if not v2.Arm.FastMode then
							v2.Arm.Width = tween.point(v2.OriginalWidth, 0, quad)
						end
					end
				end

				v2.Arm:extend(v6)
				v2.Arm:update(now - v2.LastUpdate)

				if flag then
					local v7 = v3 - v2.ExtendDuration - v2.FreezeDuration - v2.RetractDuration

					if v4 then
						v2.Finished = now - v7
					elseif v2.CurrentLoop < v2.Repetitions then
						v2.Start = now - v7
						v2.CurrentLoop += 1
					end
				end

				v2.LastUpdate = now
			end
		end
	end
end)
return function(data)
	local random = Random.new()
	local cFrame = data.CFrame
	local root = data.Root or data.Anchor
	local scale = data.Scale or Vector2.new(1, 10)
	local indicator = data.Indicator
	local updateDelta = data.UpdateDelta or data.FastMode and 0.041666666666666664 or 0.022222222222222223
	local extendDuration = data.ExtendDuration or 0.5
	local retractDuration = data.RetractDuration or 0.5
	local freezeDuration = data.FreezeDuration or 0
	local shrinkAlpha = data.ShrinkAlpha or 0.85
	local repetitions = math.abs((math.floor(data.Repeat or 0)))
	local startAlpha = data.RandomStartAlpha and random:NextNumber(0, 0.5) or data.StartAlpha or 0
	local buso = data.Buso

	if typeof(buso) == "Color3" and data.BusoPart and data.BusoPart:IsDescendantOf(workspace) then
		buso = data.BusoPart.Color
	end

	if indicator then
		indicator:SetAttribute("Position", cFrame.p)
		indicator:SetAttribute("Goal", cFrame * Vector3.new(0, 0, -scale.Y))
		indicator:SetAttribute("ArmActive", true)
	end

	local onExtend

	if data.OnExtend then
		onExtend = data.OnExtend
	else
		onExtend = nil
	end

	local onRetract

	if data.OnRetract then
		onRetract = data.OnRetract
	else
		onRetract = nil
	end

	v:add({
		Indicator = indicator,
		Arm = Extend.new({
			FastMode = data.FastMode,
			Side = data.Side,
			Buso = buso,
			CFrame = cFrame,
			Anchor = root,
			Width = scale.X,
			Length = scale.Y,
			OnExtend = function(p)
				if onExtend then
					onExtend(p, extendDuration)
				end
			end,
			OnRetract = function(p)
				if onRetract then
					onRetract(p, retractDuration)
				end
			end,
			StartAlpha = startAlpha
		}),
		ExtendDuration = extendDuration,
		RetractDuration = retractDuration,
		FreezeDuration = freezeDuration,
		CurrentLoop = 0,
		Repetitions = repetitions,
		ShrinkAlpha = shrinkAlpha,
		Start = tick() - extendDuration * startAlpha,
		UpdateDelta = updateDelta,
		LastUpdate = 0
	})
end