local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local General2 = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local PetRenderer = require(script.Parent:WaitForChild("Pets"):WaitForChild("PetRenderer"))
local growthIndicator = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("GrowthIndicator")
local game2 = SoundService:WaitForChild("SFX"):WaitForChild("Game")
local typeWriter = game2:WaitForChild("TypeWriter")
local growing = game2:WaitForChild("Growing")
local main = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
local typewriter = main:WaitForChild("Typewriter")

local function EggSizeBoost(instance)
	local eggData = instance:FindFirstChild("EggData")
	local sizeMultiplier = eggData and eggData:FindFirstChild("SizeMultiplier")
	local weight = eggData and eggData:FindFirstChild("Weight")
	local worldEggScaleFor = General2.WorldEggScaleFor(weight and tonumber(weight.Value) or 1)
	local v = worldEggScaleFor <= 0 and 1 or worldEggScaleFor
	return (1 + (sizeMultiplier and sizeMultiplier.Value or 0)) * v
end

typewriter.Visible = false

while localPlayer:GetAttribute("OfflineSeconds") == nil do
	localPlayer.AttributeChanged:Wait()
end

local offlineSeconds = tonumber(localPlayer:GetAttribute("OfflineSeconds")) or 0

if RunService:IsStudio() then
	offlineSeconds = math.max(offlineSeconds, 10800)
elseif offlineSeconds < 10800 then
	return
end

local v = {}
local v2 = {}
local v3 = true

local function CapturePet(state)
	if not v3 or v[state] or state.OwnerUserId ~= localPlayer.UserId then
		return
	end

	if not (tonumber(state.BirthTime) and state.BaseWeight) then
		return
	end

	local weightFor = PetAging.WeightFor(state.BaseWeight, 1)
	local oldScale = (state.BaseScale or 1) * (weightFor / 10)
	local combinedFactor = Mutations.CombinedFactor(state.Mutation, state.SpawnMutation)
	local oldIncome = math.floor(math.floor((state.BaseIncome or 0) * (weightFor / PetAging.WeightStandardKG)) * combinedFactor)
	state.GrowthIntro = true
	v[state] = {
		OldScale = oldScale,
		OldIncome = oldIncome,
		MutationFactor = combinedFactor
	}

	if state.SpeedBillboard then
		state.SpeedBillboard.Enabled = false
	end

	pcall(function()
		state.Model:ScaleTo((math.max(oldScale, (state.BaseScale or 1) * 0.01)))
	end)

	if state.Billboard then
		state.Billboard.Income.Text = "$" .. PetRenderer.FormatCash(oldIncome) .. "/s"
	end
end

local function CaptureEgg(model)
	if not v3 or v2[model] or not model:IsA("Model") then
		return false
	end

	local eggData = model:FindFirstChild("EggData")
	local placeTime = eggData and eggData:FindFirstChild("PlaceTime")
	local egg = Eggs[model.Name]

	if not placeTime or placeTime.Value <= 0 or not (egg and egg.GrowthTime) then
		return false
	end

	local v4 = workspace:GetServerTimeNow() - placeTime.Value - offlineSeconds
	local weight = eggData:FindFirstChild("Weight")
	local growthTimeFor = General2.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1)
	local oldScale = (0.75 + 0.75 * (growthTimeFor > 0 and math.clamp(v4 / growthTimeFor, 0, 1) or 1)) * EggSizeBoost(model)
	model:AddTag("GrowthIntro")
	v2[model] = {
		OldScale = oldScale
	}
	pcall(function()
		model:ScaleTo(oldScale)
	end)
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CaptureEggWhenReady(child)
	task.spawn(function()
		for _ = 1, 20 do
			if v3 and not CaptureEgg(child) then
				task.wait(0.1)
			else
				break
			end
		end
	end)
end

PetRenderer.Added.Event:Connect(function(p, p2)
	if not v3 or p ~= localPlayer.UserId then
		return
	end

	local v4 = PetRenderer.Get(p, p2)

	if v4 then
		CapturePet(v4)
	end
end)

for _, v4 in pairs(PetRenderer.GetAll()) do
	CapturePet(v4)
end

task.spawn(function()
	local plot = General:GetPlot(localPlayer)
	local v4 = os.clock() + 10

	while not plot and os.clock() < v4 do
		task.wait(0.25)
		plot = General:GetPlot(localPlayer)
	end

	local eggs = plot and plot:FindFirstChild("Eggs")

	if not eggs then
		return
	end

	eggs.ChildAdded:Connect(CaptureEggWhenReady)

	for _, child in eggs:GetChildren() do
		CaptureEggWhenReady(child) -- equivalent call inferred; original call site unknown
	end
end)
task.wait(3)
v3 = false

if next(v) == nil and next(v2) == nil then
	return
end

local offlineEarnings = main:FindFirstChild("OfflineEarnings")

if offlineEarnings then
	while offlineEarnings.Visible do
		offlineEarnings:GetPropertyChangedSignal("Visible"):Wait()
	end
end

local text = typewriter.Text
local uIStroke = typewriter:FindFirstChildOfClass("UIStroke")
local transparency2 = not uIStroke and 0 or uIStroke.Transparency or 0
local textTransparency = typewriter.TextTransparency
local child = typewriter.Parent and typewriter.Parent:FindFirstChild(typewriter.Name .. "_Shadow")
local uIStroke2 = child and child:FindFirstChildOfClass("UIStroke")
local transparency = uIStroke2 and uIStroke2.Transparency or 0
local textTransparency2 = not child and 0 or child.TextTransparency or 0
local currentCamera = workspace.CurrentCamera
local fieldOfView = not currentCamera and 70 or currentCamera.FieldOfView or 70
local v7 = currentCamera and TweenService:Create(
	currentCamera,
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{
		FieldOfView = fieldOfView + 20
	}
)

if v7 then
	v7:Play()
end

typewriter.MaxVisibleGraphemes = 0

if child then
	child.MaxVisibleGraphemes = 0
end

typewriter.Visible = true
typeWriter:Play()
local v8 = utf8.len(text) or #text
local lastTime = os.clock()

while true do
	local v9 = math.clamp((os.clock() - lastTime) / 0.3, 0, 1)
	local maxVisibleGraphemes = math.floor(v8 * v9)
	typewriter.MaxVisibleGraphemes = maxVisibleGraphemes

	if child then
		child.MaxVisibleGraphemes = maxVisibleGraphemes
	end

	if v9 >= 1 then
		typewriter.MaxVisibleGraphemes = -1

		if child then
			child.MaxVisibleGraphemes = -1
		end

		for k, v11 in pairs(v) do
			local newAge = k.BirthTime and PetAging.StateFrom(k.BirthTime, nil, k) or tonumber(k.Model:GetAttribute("Age")) or 1
			local v13 = k.BaseWeight and PetAging.WeightFor(k.BaseWeight, newAge) or tonumber(k.Model:GetAttribute("Weight")) or 10
			v11.NewAge = newAge
			v11.NewScale = (k.BaseScale or 1) * (v13 / 10)
			v11.NewIncome = math.floor(math.floor((k.BaseIncome or 0) * (v13 / PetAging.WeightStandardKG)) * Mutations.CombinedFactor(
				k.Mutation,
				k.SpawnMutation
			))

			if not k.Model.PrimaryPart then
				continue
			end

			local clone = growthIndicator:Clone()
			clone.Multiplier.Text = "Age: 1"
			clone.Adornee = k.Model.PrimaryPart
			clone.Parent = k.Model.PrimaryPart
			v11.Indicator = clone
			v11.IndicatorBaseSize = clone.Size
		end

		for k, v11 in pairs(v2) do
			local eggData = k:FindFirstChild("EggData")
			local placeTime = eggData and eggData:FindFirstChild("PlaceTime")
			local egg = Eggs[k.Name]
			local v12 = placeTime and workspace:GetServerTimeNow() - placeTime.Value or 0
			local weight = eggData and eggData:FindFirstChild("Weight")
			local v13 = not egg and 0 or General2.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1) or 0
			v11.NewScale = (0.75 + 0.75 * (v13 > 0 and math.clamp(v12 / v13, 0, 1) or 1)) * EggSizeBoost(k)
		end

		if v7 and v7.PlaybackState == Enum.PlaybackState.Playing then
			v7.Completed:Wait()
		end

		growing:Play()

		if currentCamera then
			TweenService:Create(currentCamera, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = fieldOfView
			}):Play()
		end

		local lastTime2 = os.clock()

		while true do
			local v11 = math.clamp((os.clock() - lastTime2) / 2, 0, 1)
			local v12 = 1 - (1 - v11) ^ 2

			for k, v13 in pairs(v) do
				if not k.Model.Parent then
					continue
				end

				local v15 = k
				local v16 = v13.OldScale + (v13.NewScale - v13.OldScale) * v12
				pcall(function()
					v15.Model:ScaleTo((math.max(v16, (v15.BaseScale or 1) * 0.01)))
				end)

				if k.Billboard then
					local v17 = math.floor(v13.OldIncome + (v13.NewIncome - v13.OldIncome) * v12)
					local income = k.Billboard:FindFirstChild("Income")

					if income then
						income.Text = "$" .. PetRenderer.FormatCash(v17) .. "/s"
					end
				end

				pcall(PetRenderer.RefreshSpeedBillboard, k)
				local indicator = v13.Indicator

				if not indicator then
					continue
				end

				local v17 = 1 - (1 - math.clamp(v11 * 2, 0, 1)) ^ 2
				local v18 = (v13.OldScale + (v13.NewScale - v13.OldScale) * v17) / math.max(v13.OldScale, 0.001)
				local v19 = math.floor(1 + ((v13.NewAge or 1) - 1) * v17 + 0.5)
				local multiplier = indicator:FindFirstChild("Multiplier")

				if multiplier then
					multiplier.Text = "Age: " .. v19
				end

				local v20 = math.clamp(1 + (v18 - 1) * 1 / 4, 1, 2)
				local indicatorBaseSize = v13.IndicatorBaseSize
				indicator.Size = UDim2.new(
					indicatorBaseSize.X.Scale * v20,
					indicatorBaseSize.X.Offset * v20,
					indicatorBaseSize.Y.Scale * v20,
					indicatorBaseSize.Y.Offset * v20
				)
			end

			for k, v13 in pairs(v2) do
				if not k.Parent then
					continue
				end

				local v15 = k
				local v16 = v13.OldScale + (v13.NewScale - v13.OldScale) * v12
				pcall(function()
					v15:ScaleTo(v16)
				end)
			end

			if v11 >= 1 then
				growing:Stop()
				task.spawn(function()
					task.wait(0)
					local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					for _, v13 in pairs(v) do
						if not v13.Indicator then
							continue
						end

						for _, descendant in v13.Indicator:GetDescendants() do
							if descendant:IsA("TextLabel") then
								TweenService:Create(descendant, tweenInfo, {
									TextTransparency = 1,
									TextStrokeTransparency = 1
								}):Play()
							elseif descendant:IsA("UIStroke") then
								TweenService:Create(descendant, tweenInfo, {
									Transparency = 1
								}):Play()
							end
						end
					end

					task.wait(0.5)

					for _, v13 in pairs(v) do
						if not v13.Indicator then
							continue
						end

						v13.Indicator:Destroy()
						v13.Indicator = nil
					end
				end)

				for k in pairs(v) do
					k.GrowthIntro = nil
					local income = k.Billboard and k.DisplayIncome and k.Billboard:FindFirstChild("Income")

					if income then
						income.Text = "$" .. PetRenderer.FormatCash(k.DisplayIncome) .. "/s"
					end

					if not k.SpeedBillboard then
						continue
					end

					k.SpeedBillboard.Enabled = true
					pcall(PetRenderer.RefreshSpeedBillboard, k)
				end

				for k in pairs(v2) do
					if k.Parent then
						k:RemoveTag("GrowthIntro")
					end
				end

				if typewriter.Parent then
					child = typewriter.Parent:FindFirstChild(typewriter.Name .. "_Shadow") or child
				end

				local uIStroke3 = child and child:FindFirstChildOfClass("UIStroke")
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(typewriter, tweenInfo, {
					TextTransparency = 1
				})
				tween:Play()

				if uIStroke then
					TweenService:Create(uIStroke, tweenInfo, {
						Transparency = 1
					}):Play()
				end

				if child then
					TweenService:Create(child, tweenInfo, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}):Play()
				end

				if uIStroke3 then
					TweenService:Create(uIStroke3, tweenInfo, {
						Transparency = 1
					}):Play()
				end

				tween.Completed:Wait()
				typewriter.Visible = false
				typewriter.TextTransparency = textTransparency

				if uIStroke then
					uIStroke.Transparency = transparency2
				end

				if child then
					child.TextTransparency = textTransparency2
					child.TextStrokeTransparency = 1
				end

				if uIStroke3 then
					uIStroke3.Transparency = transparency
				end

				if currentCamera then
					currentCamera.FieldOfView = fieldOfView
				end

				return
			else
				RunService.RenderStepped:Wait()
			end
		end
	else
		RunService.RenderStepped:Wait()
	end
end