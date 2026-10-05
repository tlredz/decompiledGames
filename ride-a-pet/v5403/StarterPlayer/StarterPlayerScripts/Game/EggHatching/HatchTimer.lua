local createVector = vector.create
local Players = game:GetService("Players")
local replicatedStorage = game.ReplicatedStorage
local services = replicatedStorage:WaitForChild("Services")
local Audio = require(services:WaitForChild("Audio"))
local gameServices = replicatedStorage:WaitForChild("GameServices")
local String = require(services:WaitForChild("String"))
local General = require(gameServices:WaitForChild("General"))
local DayNight = require(gameServices:WaitForChild("DayNight"))
local Eggs = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local General2 = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local localPlayer = Players.LocalPlayer
local game2 = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local SoundService = game:GetService("SoundService")

local function GetSizeBoost(instance)
	local eggData = instance:FindFirstChild("EggData")
	local sizeMultiplier = eggData and eggData:FindFirstChild("SizeMultiplier")
	local weight = eggData and eggData:FindFirstChild("Weight")
	local worldEggScaleFor = General2.WorldEggScaleFor(weight and tonumber(weight.Value) or 1)
	local v = worldEggScaleFor <= 0 and 1 or worldEggScaleFor
	return (1 + (sizeMultiplier and sizeMultiplier.Value or 0)) * v
end

local function AnimateSkipGrowth(child)
	local scale = child:GetScale()
	local v = 1.5 * GetSizeBoost(child)

	if v <= scale then
		return
	end

	child:AddTag("GrowthIntro")
	local SFX = SoundService:FindFirstChild("SFX")
	local game3 = SFX and SFX:FindFirstChild("Game")
	local growing = game3 and game3:FindFirstChild("Growing")
	local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

	if growing and primaryPart then
		Audio:PlayOn(growing, primaryPart)
	end

	task.spawn(function()
		local lastTime = os.clock()

		while child.Parent do
			local v2 = math.clamp((os.clock() - lastTime) / 1, 0, 1)
			local v4 = 1 - (1 - v2) ^ 2
			pcall(function()
				child:ScaleTo(scale + (v - scale) * v4)
			end)

			if v2 >= 1 then
				break
			else
				task.wait()
			end
		end

		if child.Parent then
			child:RemoveTag("GrowthIntro")
		end
	end)
end

game2:WaitForChild("SkipGrowth").OnClientEvent:Connect(function(p)
	local owner = p.Owner
	local eggKey = p.EggKey
	local plot = General:GetPlot(owner)
	local eggs = plot and plot:FindFirstChild("Eggs")

	if not eggs then
		return
	end

	for _, child in eggs:GetChildren() do
		if child:GetAttribute("EggKey") ~= eggKey then
			continue
		end

		local eggData = child:FindFirstChild("EggData")
		local placeTime = eggData and eggData:FindFirstChild("PlaceTime")
		local egg = Eggs[child.Name]

		if not (placeTime and egg) then
			break
		end

		local weight = eggData:FindFirstChild("Weight")
		placeTime.Value -= General2.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1)
		AnimateSkipGrowth(child)
		break
	end
end)
local v = {}

local function UpdateTimer(instance, p)
	local second = not (p > 0) and -1 or math.floor(p) or -1
	local v3 = v[instance]

	if v3 and v3.Second == second and instance.Text == v3.Text then
		return
	end

	local text = p <= 0 and "Ready" or String:ConvertToUnits(p)

	if not v3 then
		instance.Destroying:Once(function()
			v[instance] = nil
		end)
	end

	v[instance] = {
		Second = second,
		Text = text
	}

	if instance.Text ~= text then
		instance.Text = text
	end
end

local v2 = {}

local function ScaleBillboard(instance, Y, value, value2)
	if not instance then
		return
	end

	local size = v2[instance]

	if not size then
		size = instance.Size
		v2[instance] = size
		instance.Destroying:Once(function()
			v2[instance] = nil
		end)
	end

	local v3 = math.min(1 + (math.clamp(Y / 7, 1, 10) - 1) * (value or 1), value2 or 10)
	local uDim = UDim2.new(size.X.Scale * v3, size.X.Offset * v3, size.Y.Scale * v3, size.Y.Offset * v3)

	if instance.Size ~= uDim then
		instance.Size = uDim
	end
end

local v3 = 0
local v4 = {}
local v5 = {}

while true do
	local v6 = v3 + task.wait()
	local v7 = v6 >= 0.1
	v3 = v7 and 0 or v6
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		continue
	end

	if v7 then
		table.clear(v4)

		for _, v8 in Players:GetPlayers() do
			local plot = General:GetPlot(v8)

			if not plot then
				continue
			end

			local eggs = plot:FindFirstChild("Eggs")

			if not eggs then
				continue
			end

			local children = eggs:GetChildren()

			for _, v9 in children do
				local primaryPart = v9.PrimaryPart

				if not primaryPart then
					continue
				end

				local eggData = v9:FindFirstChild("EggData")

				if not eggData then
					continue
				end

				local placeTime = eggData:FindFirstChild("PlaceTime")

				if not placeTime then
					continue
				end

				local egg = Eggs[v9.Name]

				if not egg then
					continue
				end

				local weight = eggData:FindFirstChild("Weight")
				local growthTimeFor = General2.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1)
				local hatchingUI = primaryPart:FindFirstChild("HatchingUI")
				local skipGrowth = primaryPart:FindFirstChild("SkipGrowth")
				local skipGrowthAll = primaryPart:FindFirstChild("SkipGrowthAll")
				local hatch = primaryPart:FindFirstChild("Hatch")
				local timer = hatchingUI and hatchingUI:FindFirstChild("Timer")

				if not (hatchingUI and skipGrowth and skipGrowthAll and hatch) then
					continue
				end

				if not timer or placeTime.Value <= 0 then
					continue
				end

				local flatGrow = v9:GetAttribute("FlatGrow") == true
				local v10 = flatGrow and workspace:GetServerTimeNow() - placeTime.Value or DayNight.GrowthElapsed(placeTime.Value)
				local v11 = growthTimeFor - v10

				if v8 == localPlayer and localPlayer:GetAttribute("TutorialHatchLocked") == true then
					local tutorialLockedEggKey = localPlayer:GetAttribute("TutorialLockedEggKey")

					if tutorialLockedEggKey == nil or tutorialLockedEggKey == v9:GetAttribute("EggKey") then
						hatchingUI.Enabled = false
						hatch:SetAttribute("HatchPromptAvailable", false)
						skipGrowth.Enabled = false
						skipGrowthAll.Enabled = false
						local v12 = growthTimeFor > 0 and math.clamp(v10 / growthTimeFor, 0, 1) or 1
						local visualGrowFrom = tonumber(v9:GetAttribute("VisualGrowFrom"))

						if visualGrowFrom and visualGrowFrom > 0 and visualGrowFrom < 1 then
							v12 = math.clamp((v12 - visualGrowFrom) / (1 - visualGrowFrom), 0, 1)
						end

						local v13 = (0.75 + 0.75 * v12) * GetSizeBoost(v9)

						if v7 and not v9:HasTag("Skipped") and not v9:HasTag("GrowthIntro") and not v9:HasTag("LanternBoosting") and v9:GetScale() ~= v13 then
							v9:ScaleTo(v13)
						end

						continue
					end
				end

				local v12 = v5[v9]

				if not v12 then
					local v13 = v9
					v9.Destroying:Once(function()
						v5[v13] = nil
					end)
				end

				if v7 or not v12 then
					local boundingBox, v13 = v9:GetBoundingBox()
					v12 = math.min(18, (math.max(7, math.max(v13.X, v13.Y, v13.Z) * 0.6 + 8)))

					for _, v14 in { hatch, skipGrowth, skipGrowthAll } do
						if v14:GetAttribute("MaxHorizontalActivationDistance") ~= v12 then
							v14:SetAttribute("MaxHorizontalActivationDistance", v12)
						end
					end

					v5[v9] = v12
					local v14 = boundingBox.Position.Y - v13.Y / 2
					local v15 = math.max(primaryPart.Position.Y - v14, 0)
					local v16 = math.clamp(boundingBox.Position.Y + v13.Y / 2 - primaryPart.Position.Y - 4, 0, 6)

					if math.abs(hatchingUI.StudsOffsetWorldSpace.Y - v16) > 0.05 then
						hatchingUI.StudsOffsetWorldSpace = Vector3.new(0, v16, 0)
					end

					ScaleBillboard(hatchingUI, v13.Y)
					local eggLuck = primaryPart:FindFirstChild("EggLuck")
					ScaleBillboard(eggLuck, v13.Y, 0.35, 2)
					local currentCamera = workspace.CurrentCamera
					local magnitude = ((humanoidRootPart.Position - primaryPart.Position) * createVector(1, 0, 1)).Magnitude
					local v17 = math.max(v12 * 2 + 10, v12 + v15 + 12) + 32

					if currentCamera and magnitude <= v17 then
						local worldToViewportPoint = currentCamera:WorldToViewportPoint(primaryPart.Position)
						local worldToViewportPoint2 = currentCamera:WorldToViewportPoint(primaryPart.Position + Vector3.new(
							0,
							v16,
							0
						))
						local v18 = hatchingUI.AbsoluteSize.Y / 2
						local v19

						if v11 > 0 and localPlayer:GetAttribute("TutorialActive") ~= true then
							v19 = #children > 1
						else
							v19 = false
						end

						local v20

						if v19 then
							local v21 = worldToViewportPoint2.Y - v18 - 60 - worldToViewportPoint.Y
							v20 = {
								[skipGrowth] = Vector2.new(0, -v21),
								[skipGrowthAll] = Vector2.new(0, -(v21 - 70)),
								[hatch] = Vector2.new(0, -v21)
							}
						else
							local v21 = worldToViewportPoint2.Y + v18
							local v22

							if eggLuck and eggLuck.Enabled then
								v22 = (v21 + (currentCamera:WorldToViewportPoint(primaryPart.Position + currentCamera.CFrame.UpVector * eggLuck.StudsOffset.Y).Y - eggLuck.AbsoluteSize.Y / 2)) / 2 - worldToViewportPoint.Y
							else
								v22 = math.max(v21 + 60 - worldToViewportPoint.Y, 0)
							end

							local vector2 = Vector2.new(0, -v22)
							v20 = {
								[skipGrowth] = vector2,
								[skipGrowthAll] = vector2,
								[hatch] = vector2
							}
						end

						for k, uIOffset in v20 do
							if (k.UIOffset - uIOffset).Magnitude > 1 then
								k.UIOffset = uIOffset
							end
						end
					end

					local maxActivationDistance = v12 + v15 + (localPlayer:GetAttribute("IsRiding") == true and 12 or 0)

					if hatch.MaxActivationDistance ~= maxActivationDistance then
						skipGrowth.MaxActivationDistance = maxActivationDistance
						skipGrowthAll.MaxActivationDistance = maxActivationDistance
						hatch.MaxActivationDistance = maxActivationDistance
					end
				end

				if v9:HasTag("Hatching") then
					hatchingUI.Enabled = false
					skipGrowth.Enabled = false
					skipGrowthAll.Enabled = false
					hatch:SetAttribute("HatchPromptAvailable", false)
				else
					local v13 = (humanoidRootPart.Position - primaryPart.Position) * createVector(1, 0, 1)
					local v14 = v13.Magnitude <= v12
					hatchingUI.Enabled = v13.Magnitude < v12 * 2 + 10

					if v11 > 0 then
						local tutorialActive = localPlayer:GetAttribute("TutorialActive") == true
						skipGrowth.Enabled = v14 and not tutorialActive
						skipGrowthAll.Enabled = v14 and not tutorialActive and #children > 1
						UpdateTimer(timer, v11)
						table.insert(v4, {
							Label = timer,
							PlaceTime = placeTime,
							Total = growthTimeFor,
							FlatGrow = flatGrow
						})
						hatch:SetAttribute("HatchPromptAvailable", false)
					else
						if v14 then
							if localPlayer == v8 then
								v14 = os.clock() >= (v9:GetAttribute("HatchRequestUntil") or 0)
							else
								v14 = false
							end
						end

						hatch:SetAttribute("HatchPromptAvailable", v14)
						skipGrowth.Enabled = false
						skipGrowthAll.Enabled = false

						if timer.Text ~= "Ready" then
							timer.Text = "Ready"
						end
					end

					local v15 = growthTimeFor > 0 and math.clamp(v10 / growthTimeFor, 0, 1) or 1
					local visualGrowFrom = tonumber(v9:GetAttribute("VisualGrowFrom"))

					if visualGrowFrom and visualGrowFrom > 0 and visualGrowFrom < 1 then
						v15 = math.clamp((v15 - visualGrowFrom) / (1 - visualGrowFrom), 0, 1)
					end

					local v16 = (0.75 + 0.75 * v15) * GetSizeBoost(v9)

					if v7 and not v9:HasTag("Skipped") and not v9:HasTag("GrowthIntro") and not v9:HasTag("LanternBoosting") and v9:GetScale() ~= v16 then
						v9:ScaleTo(v16)
					end
				end
			end
		end
	else
		for _, v8 in v4 do
			if not v8.Label.Parent then
				continue
			end

			local v9 = v8.FlatGrow and workspace:GetServerTimeNow() - v8.PlaceTime.Value or DayNight.GrowthElapsed(v8.PlaceTime.Value)
			local v10 = v8.Total - v9
			UpdateTimer(v8.Label, v10)
		end
	end
end