local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local random = Random.new()
local v = {
	["金币"] = script:WaitForChild("金币图标"),
	["钻石"] = script:WaitForChild("钻石图标")
}
local v2 = {
	["金币"] = script:WaitForChild("金币音效"),
	["钻石"] = script:WaitForChild("钻石音效")
}
local bop = script:WaitForChild("bop")

local function tween(p, p2, p3)
	local tween2 = TweenService:Create(p, p2, p3)
	tween2:Play()
	return tween2
end

local function quad(p)
	return p * p
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function bezier(p, p2, p3, p4)
	return p2:Lerp(p3, p):Lerp(p3:Lerp(p4, p), p)
end

local function getAbsoluteCenter(instance)
	local v3 = instance.AbsolutePosition + instance.AbsoluteSize / 2
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")
	local currentCamera = workspace.CurrentCamera

	if not (screenGui and currentCamera) then
		return v3
	end

	local absoluteSize = screenGui.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return v3
	end

	local v4 = v3 - screenGui.AbsolutePosition
	local viewportSize = currentCamera.ViewportSize
	return Vector2.new(v4.X / absoluteSize.X * viewportSize.X, v4.Y / absoluteSize.Y * viewportSize.Y)
end

local function bopSnd(p: number, sfxTemplate)
	local clone = sfxTemplate:Clone()
	clone.PlaybackSpeed = 0.8 + 0.3999999999999999 * p
	clone.Parent = script
	clone:Play()
	game.Debris:AddItem(clone, (math.max(clone.TimeLength / clone.PlaybackSpeed, 2)))
end

local function bop2(parent, target: Vector2, playState)
	local now = os.clock()

	if now - playState.lastBopTime >= 0.08 then
		playState.lastBopTime = now
		local clone = bop:Clone()
		clone.Position = UDim2.fromOffset(target.X, target.Y)
		clone.BackgroundTransparency = 0.5
		clone.Visible = true
		clone.Parent = parent
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.2, 0.2)
		}):Play()
		game.Debris:AddItem(clone, 0.5)
	end

	playState.coinCounter += 1

	if now - playState.lastSfxTime >= 0.15 then
		playState.lastSfxTime = now
		bopSnd(playState.coinCounter / playState.coinTotal, playState.sfxTemplate)
	end

	if playState.onLand then
		playState.onLand(playState.coinCounter, playState.coinTotal)
	end

	if playState.coinCounter >= playState.coinTotal and playState.onFinished and not playState.finished then
		playState.finished = true
		playState.onFinished()
	end
end

local v3 = {}
local renderSteppedConnection = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getEffectGui()
	if v4 and v4.Parent then
		return v4
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CurrencyFlightEffects"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	local Players = game:GetService("Players")
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	v4 = screenGui
	return screenGui
end

local function updateCoins(p: number)
	for i = #v3, 1, -1 do
		local v5 = v3[i]
		v5.elapsed += p
		local v6 = v5.elapsed >= v5.scatterDuration + v5.flyDuration

		if not v5.coin.Parent or v6 then
			table.remove(v3, i)
			v5.coin:Destroy()
			bop2(v5.parent, v5.target, v5.playState)
		else
			local v7

			if v5.elapsed < v5.scatterDuration then
				local value = TweenService:GetValue(
					v5.elapsed / v5.scatterDuration,
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.Out
				)
				v7 = v5.start:Lerp(v5.scatter, value)
			else
				local v8 = math.clamp((v5.elapsed - v5.scatterDuration) / v5.flyDuration, 0, 1)
				local v9 = v8 * v8
				local scatter = v5.scatter
				local control = v5.control
				local target = v5.target
				v7 = scatter:Lerp(control, v9):Lerp(control:Lerp(target, v9), v9)
			end

			v5.coin.Position = UDim2.fromOffset(v7.X, v7.Y)
		end
	end

	if #v3 == 0 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function emitCoin(effectGui, point: Vector2, absoluteCenter: Vector2, playState)
	local clone = playState.iconTemplate:Clone()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local unitVector = random:NextUnitVector()
	local scatter = point + Vector2.new(unitVector.X, unitVector.Y) * viewportSize.Y * 0.5
	clone.Position = UDim2.fromOffset(point.X, point.Y)
	clone.Visible = true
	clone.Parent = effectGui
	table.insert(v3, {
		coin = clone,
		parent = effectGui,
		playState = playState,
		start = point,
		scatter = scatter,
		target = absoluteCenter,
		control = (point + absoluteCenter) * 0.5 + (scatter - point) * 2,
		elapsed = 0,
		scatterDuration = 1.5 + random:NextNumber(-0.2, 0.2),
		flyDuration = math.clamp(
			(scatter - absoluteCenter).Magnitude / math.max(viewportSize.X, 1) + random:NextNumber(-0.2, 0.2),
			0.2,
			1.2
		)
	})
end

return {
	play = function(p: number, p2: string, p3, onLand, onFinished, p4)
		local coinTotal = math.clamp(math.floor(p), 0, (math.min(32, 64 - #v3)))
		local effectGui = getEffectGui() -- equivalent call inferred; original call site unknown
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local start = p4 and getAbsoluteCenter(p4) or viewportSize / 2
		local absoluteCenter = getAbsoluteCenter(p3)
		local playState = {
			coinCounter = 0,
			coinTotal = coinTotal,
			onLand = onLand,
			onFinished = onFinished,
			finished = false,
			lastSfxTime = 0,
			lastBopTime = 0,
			iconTemplate = v[p2] or v["金币"],
			sfxTemplate = v2[p2] or v2["金币"]
		}

		if coinTotal <= 0 then
			if playState.onFinished then
				playState.finished = true
				playState.onFinished()
			end
		else
			for _ = 1, coinTotal do
				emitCoin(effectGui, start, absoluteCenter, playState)
			end

			if not renderSteppedConnection then
				renderSteppedConnection = RunService.RenderStepped:Connect(updateCoins)
			end
		end
	end
}