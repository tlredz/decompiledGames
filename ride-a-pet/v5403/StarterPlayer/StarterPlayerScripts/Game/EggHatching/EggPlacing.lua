local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local gameServices = replicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local ForgeVFX = require(replicatedStorage:WaitForChild("Services"):WaitForChild("ForgeVFX"))
local services = game.ReplicatedStorage:WaitForChild("Services")
local Audio = require(services:WaitForChild("Audio"))
local EggLuckBillboard = require(gameServices:WaitForChild("EggLuckBillboard"))
local PetRigService = require(gameServices:WaitForChild("PetRigService"))
local General2 = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local SoundService = game:GetService("SoundService")
local HatchLuck = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("HatchLuck"))
local game2 = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local eggPlaced = game2:WaitForChild("EggPlaced")
local assets = replicatedStorage:WaitForChild("Assets")
local eggs = assets:WaitForChild("Eggs")
local prompts = assets:WaitForChild("Prompts")
local billboards = assets:WaitForChild("Billboards")
local rarityGradients = assets:WaitForChild("RarityGradients")
local Eggs = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local Mutations = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local placing = assets:WaitForChild("Effects"):WaitForChild("Placing")
local planting = assets:WaitForChild("Effects"):WaitForChild("Planting")
local SFX = game.SoundService:WaitForChild("SFX")
ForgeVFX.init()
local game3 = SFX:WaitForChild("Game")
task.spawn(function()
	local eggPlants = { planting, placing }
	local eggPlant = game3:FindFirstChild("EggPlant")

	if eggPlant then
		table.insert(eggPlants, eggPlant)
	end

	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync(eggPlants)
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnerLuckMultiplier(owner)
	local savedData = owner and owner:FindFirstChild("SavedData")
	local hatchUpgrades = savedData and savedData:FindFirstChild("HatchUpgrades")
	return HatchLuck.GetMultiplierFor(owner, hatchUpgrades and hatchUpgrades.Value or 0)
end

local function BillboardHost(instance)
	local eggLuck = instance:FindFirstChild("EggLuck", true)

	if eggLuck then
		return eggLuck.Parent
	end

	return instance:FindFirstChild("Handle") or instance.PrimaryPart or instance:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
end

local function WatchOwnerLuck(instance)
	task.spawn(function()
		local function Restamp()
			local plot = General:GetPlot(instance)
			local eggs2 = plot and plot:FindFirstChild("Eggs")

			if not eggs2 then
				return
			end

			local ownerLuckMultiplier = GetOwnerLuckMultiplier(instance) -- equivalent call inferred; original call site unknown

			for _, child in eggs2:GetChildren() do
				local model = child
				pcall(function()
					local parent = model:IsA("Model")

					if parent then
						local v3 = model
						local eggLuck = v3:FindFirstChild("EggLuck", true)

						if eggLuck then
							parent = eggLuck.Parent
						else
							parent = v3:FindFirstChild("Handle") or v3.PrimaryPart or v3:FindFirstChildWhichIsA(
								"BasePart",
								true
							)
						end
					end

					if parent then
						EggLuckBillboard.Attach(parent, model.Name, ownerLuckMultiplier)
					end
				end)
			end
		end

		instance:WaitForChild("SavedData"):WaitForChild("HatchUpgrades").Changed:Connect(Restamp)
		instance:GetAttributeChangedSignal(HatchLuck.SettingAttribute):Connect(Restamp)

		while instance.Parent do
			task.wait(3)
			Restamp()
		end
	end)
end

for _, v in Players:GetPlayers() do
	local v2 = v
	task.spawn(function()
		local function Restamp()
			local plot = General:GetPlot(v2)
			local eggs2 = plot and plot:FindFirstChild("Eggs")

			if not eggs2 then
				return
			end

			local ownerLuckMultiplier = GetOwnerLuckMultiplier(v2) -- equivalent call inferred; original call site unknown

			for i, child in eggs2:GetChildren() do
				local model = child
				pcall(function()
					local parent = model:IsA("Model")

					if parent then
						local v5 = model
						local eggLuck = v5:FindFirstChild("EggLuck", true)

						if eggLuck then
							parent = eggLuck.Parent
						else
							parent = v5:FindFirstChild("Handle") or v5.PrimaryPart or v5:FindFirstChildWhichIsA(
								"BasePart",
								true
							)
						end
					end

					if parent then
						EggLuckBillboard.Attach(parent, model.Name, ownerLuckMultiplier)
					end
				end)
			end
		end

		v2:WaitForChild("SavedData"):WaitForChild("HatchUpgrades").Changed:Connect(Restamp)
		v2:GetAttributeChangedSignal(HatchLuck.SettingAttribute):Connect(Restamp)

		while v2.Parent do
			task.wait(3)
			Restamp()
		end
	end)
end

Players.PlayerAdded:Connect(WatchOwnerLuck)
local v = {}
local v2 = {}
local nowsByEggKey = {}
local v3 = {}
local v4 = {}
game2:WaitForChild("Hatch").OnClientEvent:Connect(function(p)
	local eggKey

	if typeof(p) == "table" then
		eggKey = p.EggKey
	else
		eggKey = false
	end

	if eggKey ~= nil then
		nowsByEggKey[eggKey] = os.clock()
		v2[eggKey] = nil
		v[eggKey] = nil
	end
end)

function PlaceEgg(data)
	local owner = data.Owner
	local eggName = data.EggName
	local coordinate = data.Coordinate
	local upCFrame = data.UpCFrame
	local placeTime = data.PlaceTime
	local eggKey = data.EggKey

	if data.Planted and owner ~= localPlayer and localPlayer:GetAttribute("NoNest") ~= true or (not owner or not owner.Parent or nowsByEggKey[eggKey]) then
		return
	end

	if not Eggs[eggName] then
		warn(string.format("[PlaceEgg] unknown egg config: %s", (tostring(eggName))))
		return
	end

	if eggKey ~= nil and v[eggKey] then
		return
	end

	local v5 = {}

	if eggKey ~= nil then
		v[eggKey] = v5
	end

	local lastTime = os.clock()
	local flag = false
	local child = nil
	local eggs2 = nil

	while owner.Parent and (eggKey == nil or v[eggKey] == v5) do
		child = eggs:FindFirstChild(eggName)
		local plot = General:GetPlot(owner)
		eggs2 = plot and plot:FindFirstChild("Eggs")
		local hatchingUI = prompts:FindFirstChild("Hatch") and prompts:FindFirstChild("SkipGrowth") and prompts:FindFirstChild("SkipGrowthAll") and billboards:FindFirstChild("HatchingUI")

		if child and eggs2 and hatchingUI then
			break
		end

		local v6 = os.clock() - lastTime

		if not flag and v6 >= 10 then
			warn(string.format(
				"[PlaceEgg] waiting for template/plot for %s's %s; will retry until available",
				owner.Name,
				eggName
			))
			flag = true
		end

		task.wait(v6 < 10 and 0.25 or 1)
	end

	local v6 = not owner.Parent

	if not v6 then
		if eggKey == nil then
			v6 = false
		else
			v6 = v[eggKey] ~= v5
		end
	end

	if eggKey ~= nil and v[eggKey] == v5 then
		v[eggKey] = nil
	end

	if v6 or not (child and eggs2) then
		return
	end

	if flag then
		warn(string.format("[PlaceEgg] resources resolved after %.0fs; drawing %s", os.clock() - lastTime, eggName))
	end

	if eggKey ~= nil then
		for _, child2 in eggs2:GetChildren() do
			if child2:GetAttribute("EggKey") ~= eggKey then
				continue
			end

			if child2:GetAttribute("EggBuildComplete") == true then
				local eggData = child2:FindFirstChild("EggData")
				local placeTime2 = eggData and eggData:FindFirstChild("PlaceTime")

				if placeTime2 then
					placeTime2.Value = placeTime
				end

				local weight = eggData and eggData:FindFirstChild("Weight")

				if weight then
					weight.Value = tonumber(data.Weight) or weight.Value
				end

				local sizeMultiplier = eggData and eggData:FindFirstChild("SizeMultiplier")

				if sizeMultiplier and data.SizeMultiplier ~= nil then
					sizeMultiplier.Value = data.SizeMultiplier
				end

				if Mutations.FactorFor(data.Mutation) > Mutations.FactorFor(child2:GetAttribute("Mutation")) then
					child2:SetAttribute("Mutation", data.Mutation)
				end

				return
			else
				child2:Destroy()
			end
		end
	end

	local clone = child:Clone()
	local model = Instance.new("Model")
	v4[eggKey] = model
	model.Name = eggName

	for _, child2 in clone:GetChildren() do
		child2.Parent = model
	end

	clone:Destroy()
	local handle = model:FindFirstChild("Handle") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)

	if handle then
		model.PrimaryPart = handle

		for _, part in model:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = part.Transparency < 1
		end

		local vector2 = nil
		local vector3 = nil

		for _, part in model:GetDescendants() do
			if not (part:IsA("BasePart") and part.Transparency < 1) then
				continue
			end

			local v7 = part.Position - part.Size / 2
			local v8 = part.Position + part.Size / 2

			if vector2 then
				vector2 = Vector3.new(math.min(vector2.X, v7.X), math.min(vector2.Y, v7.Y), (math.min(vector2.Z, v7.Z))) or v7
			else
				vector2 = v7
			end

			if vector3 then
				vector3 = Vector3.new(math.max(vector3.X, v8.X), math.max(vector3.Y, v8.Y), (math.max(vector3.Z, v8.Z))) or v8
			else
				vector3 = v8
			end
		end

		if vector2 then
			local vector4 = Vector3.new((vector2.X + vector3.X) / 2, vector2.Y, (vector2.Z + vector3.Z) / 2)

			if (vector4 - handle.Position).Magnitude > 0.5 then
				handle.PivotOffset = handle.CFrame:ToObjectSpace(CFrame.new(vector4))
			end
		end

		model:SetAttribute("EggKey", eggKey)
		model:SetAttribute("OwnerUserId", owner.UserId)
		model:SetAttribute("Mutation", data.Mutation)

		if tonumber(data.VisualGrowFrom) then
			model:SetAttribute("VisualGrowFrom", (tonumber(data.VisualGrowFrom)))
		end

		if data.FlatGrow == true then
			model:SetAttribute("FlatGrow", true)
		end

		model.Parent = eggs2
		local weight = tonumber(data.Weight) or 1
		local v7 = weight <= 0 and 1 or weight

		if tonumber(data.VisualGrowFrom) then
			model:ScaleTo(0.75 * (1 + (tonumber(data.SizeMultiplier) or 0)) * General2.WorldEggScaleFor(v7))
		else
			model:ScaleTo(0.75 * General2.WorldEggScaleFor(v7))
		end

		model:PivotTo(coordinate)
		local boundingBox, v8 = model:GetBoundingBox()
		local v9 = coordinate + Vector3.new(
			0,
			coordinate.Y - (boundingBox.Position.Y - v8.Y / 2) + (not data.Planted and 0.05 or 0.05 - v8.Y * 0.14),
			0
		)

		if upCFrame then
			local v10 = data.Planted and 9 or 3
			local v11 = data.Planted and 0.18 or 0.1
			local v12 = data.Planted and Enum.EasingDirection.In or Enum.EasingDirection.Out
			local v13 = v9 * CFrame.new(0, v10, 0)
			model:PivotTo(v13)
			local instances = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function Suppress(descendant)
				if (descendant:IsA("ProximityPrompt") or descendant:IsA("BillboardGui")) and descendant.Enabled then
					descendant.Enabled = false
					table.insert(instances, descendant)
				end
			end

			for _, descendant in model:GetDescendants() do
				Suppress(descendant) -- equivalent call inferred; original call site unknown
			end

			local descendantAddedConnection = model.DescendantAdded:Connect(function(descendant)
				task.defer(Suppress, descendant)
			end)
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = v13
			cFrameValue.Changed:Connect(function(cframe)
				model:PivotTo(cframe)
			end)
			local tween = TweenService:Create(cFrameValue, TweenInfo.new(v11, Enum.EasingStyle.Quad, v12), {
				Value = v9
			})
			tween:Play()
			tween.Completed:Connect(function()
				cFrameValue:Destroy()
				descendantAddedConnection:Disconnect()

				for _, v14 in instances do
					if v14.Parent then
						v14.Enabled = true
					end
				end

				local clone2 = (data.Planted and planting or placing):Clone()

				if data.Planted then
					local v14 = math.clamp(General2.WorldEggScaleFor(v7) / General2.WorldEggScaleFor(0.9), 1, 2.5)

					if v14 > 1 then
						clone2.Size *= v14

						for _, emitter in clone2:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local numberSequenceKeypoints = {}

							for _, keypoint in emitter.Size.Keypoints do
								table.insert(
									numberSequenceKeypoints,
									NumberSequenceKeypoint.new(
										keypoint.Time,
										keypoint.Value * v14,
										keypoint.Envelope * v14
									)
								)
							end

							emitter.Size = NumberSequence.new(numberSequenceKeypoints)
						end
					end
				end

				clone2.CFrame = clone2.CFrame.Rotation + coordinate.Position
				clone2.CanCollide = false
				clone2.Parent = workspace
				ForgeVFX.emit(clone2)
				local eggPlant = data.Planted and game3:FindFirstChild("EggPlant")

				if eggPlant then
					eggPlant:Play()
				end

				task.delay(6, function()
					clone2:Destroy()
				end)
			end)
		else
			model:PivotTo(v9)
		end

		local parent = model:FindFirstChild("EggData")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "EggData"
			parent.Parent = model
		end

		local v11 = parent:FindFirstChild("PlaceTime")

		if not v11 then
			v11 = Instance.new("NumberValue")
			v11.Name = "PlaceTime"
			v11.Parent = parent
		end

		local v12 = parent:FindFirstChild("Weight")

		if not v12 then
			v12 = Instance.new("NumberValue")
			v12.Name = "Weight"
			v12.Parent = parent
		end

		local v13 = parent:FindFirstChild("SizeMultiplier")

		if not v13 then
			v13 = Instance.new("NumberValue")
			v13.Name = "SizeMultiplier"
			v13.Parent = parent
		end

		v11.Value = placeTime
		v12.Value = data.Weight or 1
		v13.Value = data.SizeMultiplier or 0
		PetRigService.ApplyMutationAura(model, model:GetAttribute("Mutation"), PetRigService.EggAuraBoost(model))
		model:GetAttributeChangedSignal("Mutation"):Connect(function()
			if model.Parent then
				PetRigService.ApplyMutationAura(
					model,
					model:GetAttribute("Mutation"),
					PetRigService.EggAuraBoost(model)
				)
			end
		end)

		if typeof(data.SpawnMutation) == "string" then
			model:SetAttribute("SpawnMutation", data.SpawnMutation)
			model:AddTag("SpawnMutationCarrier")
		end

		local clone2 = prompts:WaitForChild("Hatch"):Clone()
		clone2.RequiresLineOfSight = false
		local v14 = nil
		local v15 = {}
		local connections = {}
		local v16 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function DisconnectFill()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
		end

		local function CopyEggFill()
			if not v14 then
				return
			end

			local v17 = nil

			for _, highlight in model:GetDescendants() do
				if not (highlight:IsA("Highlight") and highlight ~= v14 and highlight.Enabled and (highlight.Adornee == nil or highlight.Adornee == model or highlight.Adornee:IsDescendantOf(model))) then
					continue
				end

				if not (not v17 or highlight.FillTransparency < v17.FillTransparency) then
					continue
				end

				v17 = highlight
			end

			v14.FillColor = v17 and v17.FillColor or Color3.new(1, 1, 1)
			v14.FillTransparency = v17 and v17.FillTransparency or 1
		end

		local function WatchEggFill()
			DisconnectFill() -- equivalent call inferred; original call site unknown

			if not v14 then
				return
			end

			for _, highlight in model:GetDescendants() do
				if not (highlight:IsA("Highlight") and highlight ~= v14) then
					continue
				end

				for _, propertyName in {
					"FillColor",
					"FillTransparency",
					"Enabled",
					"Adornee"
				} do
					table.insert(connections, highlight:GetPropertyChangedSignal(propertyName):Connect(CopyEggFill))
				end
			end

			CopyEggFill()
		end

		local function RefreshEggPromptOutline()
			local v17 = false

			for k in v15 do
				if not (k.Enabled and k:IsDescendantOf(model)) then
					continue
				end

				v17 = true
				break
			end

			if v17 and model.Parent and not v16 then
				if not v14 then
					local highlight = Instance.new("Highlight")
					highlight.Name = "HatchPromptOutline"
					highlight.Adornee = model
					highlight.FillTransparency = 1
					highlight.OutlineColor = Color3.new(1, 1, 1)
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					v14 = highlight
					highlight.Parent = model
					WatchEggFill()
				end
			elseif v14 then
				DisconnectFill() -- equivalent call inferred; original call site unknown
				v14:Destroy()
				v14 = nil
			end
		end

		model.DescendantAdded:Connect(function(highlight)
			if highlight:IsA("Highlight") and highlight ~= v14 then
				WatchEggFill()
			end
		end)
		model.DescendantRemoving:Connect(function(highlight)
			if highlight:IsA("Highlight") and highlight ~= v14 then
				task.defer(function()
					if not v16 then
						WatchEggFill()
					end
				end)
			end
		end)
		model.Destroying:Connect(function()
			v16 = true
			DisconnectFill() -- equivalent call inferred; original call site unknown
		end)

		local function BindEggPromptOutline(clone3)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function Hide()
				v15[clone3] = nil
				RefreshEggPromptOutline()
			end

			clone3.PromptShown:Connect(function()
				if model.Parent and clone3.Enabled then
					v15[clone3] = true
					RefreshEggPromptOutline()
				end
			end)
			clone3.PromptHidden:Connect(Hide)
			clone3.Destroying:Connect(Hide)
			clone3:GetPropertyChangedSignal("Enabled"):Connect(function()
				if not clone3.Enabled then
					Hide() -- equivalent call inferred; original call site unknown
				end
			end)
			clone3.AncestryChanged:Connect(function()
				if not clone3:IsDescendantOf(model) then
					Hide() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		BindEggPromptOutline(clone2)
		clone2.Parent = handle
		local clone3 = prompts:WaitForChild("SkipGrowth"):Clone()
		clone3.RequiresLineOfSight = false
		BindEggPromptOutline(clone3)
		clone3.Parent = handle
		local clone4 = prompts:WaitForChild("SkipGrowthAll"):Clone()
		clone4.RequiresLineOfSight = false
		BindEggPromptOutline(clone4)
		clone4.Parent = handle
		local clone5 = billboards:WaitForChild("HatchingUI"):Clone()
		local eggName2 = clone5:WaitForChild("EggName")
		eggName2.Text = eggName
		local rarity = Eggs[eggName] and Eggs[eggName].Rarity

		if rarity and rarity ~= "Common" then
			local child2 = rarityGradients and rarityGradients:FindFirstChild(rarity)

			if child2 then
				local clone6 = child2:Clone()
				clone6.Name = rarity
				clone6.Parent = eggName2
			else
				warn(string.format("EggPlacing: no gradient asset for rarity %q", (tostring(rarity))))
			end
		end

		clone5.Parent = handle
		EggLuckBillboard.Attach(handle, eggName, GetOwnerLuckMultiplier(owner))

		if data.Premium and not tonumber(data.VisualGrowFrom) then
			local v17 = (1 + (data.SizeMultiplier or 0)) * General2.WorldEggScaleFor(tonumber(data.Weight) or 1)
			local v18 = (General2.PremiumEggStartScale or 0.5) * v17
			local v19 = 1.5 * v17
			model:AddTag("GrowthIntro")
			model:ScaleTo(v18)
			local SFX2 = SoundService:FindFirstChild("SFX")
			local game4 = SFX2 and SFX2:FindFirstChild("Game")
			local growing = game4 and game4:FindFirstChild("Growing")

			if growing and model.PrimaryPart then
				Audio:PlayOn(growing, model.PrimaryPart)
			end

			task.spawn(function()
				local lastTime2 = os.clock()

				while model.Parent do
					local v20 = math.clamp((os.clock() - lastTime2) / 1, 0, 1)
					local v22 = 1 - (1 - v20) ^ 2
					pcall(function()
						model:ScaleTo(v18 + (v19 - v18) * v22)
					end)

					if v20 >= 1 then
						break
					else
						task.wait()
					end
				end

				if model.Parent then
					model:RemoveTag("GrowthIntro")
				end
			end)
		end

		if nowsByEggKey[eggKey] or not owner.Parent then
			model:Destroy()
		else
			model:SetAttribute("EggBuildComplete", true)
		end
	else
		warn("[PlaceEgg] egg has no part to pivot on: " .. eggName)
		model:Destroy()
	end
end

local place = prompts:WaitForChild("Place")
local plots = workspace:WaitForChild("Plots")
local v5 = {}
local v6 = nil

local function RefreshNestPrompt(parent)
	local parent2 = parent.Parent
	local parent3 = parent2 and parent2.Parent
	local v7

	if parent3 == nil or parent3:GetAttribute("NestsOwnerLoaded") ~= localPlayer.UserId or parent:GetAttribute("Unlocked") ~= true then
		v7 = false
	else
		v7 = not parent:GetAttribute("Occupied") and v6 ~= nil
	end

	local parent4 = v5[parent]

	if v7 then
		if not parent4 then
			local model = parent:FindFirstChild("Model")

			if not model then
				return
			end

			local boundingBox, v9 = model:GetBoundingBox()
			parent4 = Instance.new("Part")
			parent4.Name = "PlacePromptAnchor"
			parent4.Anchored = true
			parent4.CanCollide = false
			parent4.CanQuery = false
			parent4.CanTouch = false
			parent4.Transparency = 1
			parent4.Size = createVector(1, 1, 1)
			parent4.CFrame = CFrame.new(boundingBox.Position + Vector3.new(0, v9.Y / 2, 0))
			local clone = place:Clone()
			clone.Enabled = true
			clone.Triggered:Connect(function()
				Audio:PlayAtPosition(game3:WaitForChild("EggPlacing"), parent4.Position)
				eggPlaced:FireServer({
					NestId = parent.Name
				})
			end)
			clone.Parent = parent4
			parent4.Parent = parent
			v5[parent] = parent4
		end

		local proximityPrompt = parent4:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.ObjectText = v6.Name
		end
	elseif parent4 then
		v5[parent] = nil
		parent4:Destroy()
	end
end

local function RefreshAllPrompts()
	for _, child in plots:GetChildren() do
		local nests = child:FindFirstChild("Nests")

		if not nests then
			continue
		end

		for _, child2 in nests:GetChildren() do
			RefreshNestPrompt(child2)
		end
	end
end

local function WatchNest(child)
	child:GetAttributeChangedSignal("Unlocked"):Connect(function()
		RefreshNestPrompt(child)
	end)
	child:GetAttributeChangedSignal("Occupied"):Connect(function()
		RefreshNestPrompt(child)
	end)
	RefreshNestPrompt(child)
end

local function WatchPlot(instance)
	local nests = instance:WaitForChild("Nests", 15)

	if not nests then
		return
	end

	instance:GetAttributeChangedSignal("NestsOwnerLoaded"):Connect(RefreshAllPrompts)
	nests.ChildAdded:Connect(WatchNest)

	for _, child in nests:GetChildren() do
		WatchNest(child)
	end
end

for _, child in plots:GetChildren() do
	task.spawn(WatchPlot, child)
end

plots.ChildAdded:Connect(function(child)
	task.spawn(WatchPlot, child)
end)

local function WatchCharacter(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function Update()
		local tool = instance:FindFirstChildOfClass("Tool")

		if not (tool and tool:HasTag("Egg")) then
			tool = nil
		end

		v6 = tool
		RefreshAllPrompts()
	end

	instance.ChildAdded:Connect(Update)
	instance.ChildRemoved:Connect(Update)
	Update() -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(WatchCharacter)

if localPlayer.Character then
	local character = localPlayer.Character

	local function Update()
		local tool = character:FindFirstChildOfClass("Tool")

		if not (tool and tool:HasTag("Egg")) then
			tool = nil
		end

		v6 = tool
		RefreshAllPrompts()
	end

	character.ChildAdded:Connect(Update)
	character.ChildRemoved:Connect(Update)
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and tool:HasTag("Egg") then
		v6 = tool
	else
		v6 = nil
	end

	RefreshAllPrompts()
end

local function QueuePlacement(p)
	if type(p) ~= "table" or type(p.EggKey) ~= "string" or nowsByEggKey[p.EggKey] then
		return
	end

	local eggKey = p.EggKey
	v2[eggKey] = p

	if v3[eggKey] then
		return
	end

	v3[eggKey] = true
	task.spawn(function()
		local success, result = pcall(PlaceEgg, p)
		v3[eggKey] = nil

		if not success then
			v[eggKey] = nil
			local v7 = v4[eggKey]

			if v7 then
				v7:Destroy()
			end

			warn("[PlaceEgg] will retry " .. eggKey .. ": " .. tostring(result))
		end

		v4[eggKey] = nil
	end)
end

local now = -1e999
local v7 = nil
local v8 = nil

local function PrintListed(data)
	local count = 0
	local v9 = {}

	for _ in pairs(data.EggKeys) do
		count += 1
	end

	for _, placement in data.Placements do
		if type(placement) == "table" then
			table.insert(v9, tostring(placement.EggName) .. "@" .. tostring(placement.NestId))
		end
	end

	table.sort(v9)
	local v10 = count .. ":" .. table.concat(v9, ", ")

	if v10 ~= v7 then
		v7 = v10
		local v11 = count - #v9
		print(string.format(
			"[PlaceEgg] server lists %d saved egg(s) on your plot%s%s",
			count,
			#v9 > 0 and ": " .. table.concat(v9, ", ") or "",
			v11 > 0 and string.format(" (%d with nowhere to show)", v11) or ""
		))
	end

	if not v8 and localPlayer:GetAttribute("LastSessionUnsaved") == true then
		v8 = true
		print("[PlaceEgg] your last session ended before its final save landed, anything placed or hatched right before leaving may not have been kept")
	end
end

local function AuditOwnEggs(items)
	if not localPlayer.Parent then
		return
	end

	local plot = General:GetPlot(localPlayer)
	local eggs2 = plot and plot:FindFirstChild("Eggs")
	local v9 = {}

	if eggs2 then
		for _, child in eggs2:GetChildren() do
			if child:GetAttribute("EggBuildComplete") == true then
				v9[child:GetAttribute("EggKey")] = true
			end
		end
	end

	local v10 = {}
	local count = 0

	for _, item in items do
		local eggKey

		if type(item) == "table" then
			eggKey = item.EggKey
		else
			eggKey = false
		end

		if type(eggKey) ~= "string" or v9[eggKey] then
			continue
		end

		local v11 = nowsByEggKey[eggKey]
		local v12

		if v11 then
			v12 = os.clock() - v11 > 30 and "hatched" or nil
		else
			v12 = v[eggKey] and "waiting" or v3[eggKey] and "building" or eggs2 and "missing" or "noplot"
		end

		if not v12 then
			continue
		end

		v10[eggKey] = v12
		count += 1
	end

	if count == 0 then
		return
	end

	local v11 = {}

	for k, v12 in pairs(v10) do
		table.insert(v11, k .. " (" .. v12 .. ")")
	end

	warn(string.format("[PlaceEgg] %d saved egg(s) the server lists are not shown: %s", count, table.concat(v11, ", ")))

	if os.clock() - now < 60 then
		return
	end

	now = os.clock()
	local reportPlotEggs = game2:FindFirstChild("ReportPlotEggs")

	if reportPlotEggs then
		reportPlotEggs:FireServer(v10)
	end
end

eggPlaced.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	if data.Snapshot == true then
		if not data.Owner or type(data.EggKeys) ~= "table" or type(data.Placements) ~= "table" then
			return
		end

		for k, v9 in pairs(v2) do
			if v9.Owner ~= data.Owner or data.EggKeys[k] then
				continue
			end

			v2[k] = nil
			v[k] = nil
			local v10 = k
			task.delay(10, function()
				if v2[v10] then
					return
				end

				local plot = General:GetPlot(data.Owner)
				local eggs2 = plot and plot:FindFirstChild("Eggs")

				if eggs2 then
					for i, child in eggs2:GetChildren() do
						if child:GetAttribute("EggKey") == v10 then
							child:Destroy()
						end
					end
				end
			end)
		end

		for _, placement in data.Placements do
			QueuePlacement(placement)
		end

		if data.Owner == localPlayer then
			PrintListed(data)
			task.delay(5, AuditOwnEggs, data.Placements)
		end
	else
		QueuePlacement(data)
	end
end)
task.spawn(function()
	local requestPlotEggs = game2:WaitForChild("RequestPlotEggs")
	requestPlotEggs:FireServer(true)

	while localPlayer.Parent do
		task.wait(15)
		requestPlotEggs:FireServer(false)

		for k, v9 in pairs(v2) do
			if not nowsByEggKey[k] then
				QueuePlacement(v9)
			end
		end
	end
end)
Players.PlayerRemoving:Connect(function(player)
	for k, v9 in pairs(v2) do
		if v9.Owner ~= player then
			continue
		end

		v2[k] = nil
		v[k] = nil
	end

	local plots2 = workspace:FindFirstChild("Plots")

	if not plots2 then
		return
	end

	for _, child in plots2:GetChildren() do
		local eggs2 = child:FindFirstChild("Eggs")

		if not eggs2 then
			continue
		end

		for _, child2 in eggs2:GetChildren() do
			if child2:GetAttribute("OwnerUserId") == player.UserId then
				child2:Destroy()
			end
		end
	end
end)
local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function MyVariant()
	return localPlayer:GetAttribute("NoNest") == true
end

local function TargetPosition()
	if GamepadUI.UsingGamepad() and GamepadUI.GameplayBlocked() then
		return nil
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()

	if string.find(UserInputService:GetLastInputType().Name, "Gamepad") then
		mouseLocation = currentCamera.ViewportSize / 2
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = {}

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	local plot = General:GetPlot(localPlayer)
	local eggs2 = plot and plot:FindFirstChild("Eggs")

	if eggs2 then
		table.insert(filterDescendantsInstances, eggs2)
	end

	local pets = plot and plot:FindFirstChild("Pets")

	if pets then
		table.insert(filterDescendantsInstances, pets)
	end

	local nests = plot and plot:FindFirstChild("Nests")

	if nests then
		table.insert(filterDescendantsInstances, nests)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 1000,
		raycastParams
	)
	return raycastResult and raycastResult.Position or nil
end

local function HookTool(tool)
	if not (tool:IsA("Tool") and tool:HasTag("Egg")) or tool:GetAttribute("PlantHooked") then
		return
	end

	tool:SetAttribute("PlantHooked", true)
	tool.Activated:Connect(function()
		local HatchInteraction = require(script.Parent.HatchInteraction)

		if HatchInteraction.Target(nil, true) or localPlayer:GetAttribute("NoNest") ~= true then
			return
		end

		local plantPosition = TargetPosition()

		if plantPosition then
			eggPlaced:FireServer({
				PlantPosition = plantPosition
			})
		end
	end)
end

local ContextActionService = game:GetService("ContextActionService")
local v9 = false

local function OnPadPlant(_, p)
	if GamepadUI.GameplayBlocked() or p ~= Enum.UserInputState.Begin or localPlayer:GetAttribute("NoNest") ~= true then
		return Enum.ContextActionResult.Pass
	end

	local plantPosition = TargetPosition()

	if plantPosition then
		eggPlaced:FireServer({
			PlantPosition = plantPosition
		})
	end

	return Enum.ContextActionResult.Sink
end

local function RefreshPadBind()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local myVariant = MyVariant() -- equivalent call inferred; original call site unknown

	if myVariant then
		if tool == nil then
			myVariant = false
		else
			myVariant = tool:HasTag("Egg")
		end
	end

	if myVariant and not v9 then
		v9 = true
		ContextActionService:BindAction("NoNestPlantEgg", OnPadPlant, false, Enum.KeyCode.ButtonX)
	elseif not myVariant and v9 then
		v9 = false
		ContextActionService:UnbindAction("NoNestPlantEgg")
	end
end

local function WatchTools(character)
	if not character then
		return
	end

	character.ChildAdded:Connect(function(child)
		HookTool(child)
		RefreshPadBind()
	end)
	character.ChildRemoved:Connect(RefreshPadBind)

	for _, child in character:GetChildren() do
		HookTool(child)
	end

	RefreshPadBind()
end

WatchTools(localPlayer.Character)
localPlayer.CharacterAdded:Connect(WatchTools)
localPlayer:GetAttributeChangedSignal("NoNest"):Connect(RefreshPadBind)
local gameMessages = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Reusable"):WaitForChild("GameMessages")
local Handler = require(gameMessages:WaitForChild("Handler"))
local buttonX = Enum.KeyCode.ButtonX
local v10 = nil
local v11 = nil

local function ShowPlantHand()
	if v10 then
		return
	end

	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if not baseplate then
		return
	end

	local part = Instance.new("Part")
	part.Name = "PlantHintAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = baseplate.Position + Vector3.new(0, baseplate.Size.Y / 2 + 1, 0)
	part.Parent = workspace
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PlantHintHand"
	billboardGui.Size = UDim2.fromScale(7, 7)
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.ResetOnSpawn = false
	billboardGui.StudsOffset = createVector(0, 4.5, 0)
	billboardGui.Adornee = part
	billboardGui.Parent = part
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Hand"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://92534278124110"
	imageLabel.Rotation = 180
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = billboardGui
	local tween = TweenService:Create(
		billboardGui,
		TweenInfo.new(0.84, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			StudsOffset = createVector(0, 2, 0)
		}
	)
	tween:Play()
	v10 = part
	v11 = tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HidePlantHand()
	if v11 then
		v11:Cancel()
	end

	if v10 then
		v10:Destroy()
	end

	v10 = nil
	v11 = nil
end

local function OnOwnPlot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if not (humanoidRootPart and baseplate) then
		return false
	end

	local pointToObjectSpace = baseplate.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	return math.abs(pointToObjectSpace.X) <= baseplate.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= baseplate.Size.Z / 2
end

local function HoldingEgg()
	local character = localPlayer.Character

	if not character then
		return false
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and tool:HasTag("Egg") then
			return true
		end
	end

	return false
end

local GamepadGlyphs = require(replicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadGlyphs"))

local function HintText()
	local device = localPlayer:GetAttribute("Device")

	if device ~= "Console" then
		return (device == "Mobile" and "Tap" or "Click") .. " Anywhere In Your Plot To Place Egg", nil
	end

	local v12, v13 = GamepadGlyphs.For(buttonX)

	if v12 then
		return "Anywhere In Your Plot To Place Egg", v12
	end

	return string.format("Press %s Anywhere In Your Plot To Place Egg", v13 or GamepadGlyphs.Text(buttonX)), nil
end

task.spawn(function()
	local v12 = nil

	while true do
		task.wait(0.25)
		local v13

		if localPlayer:GetAttribute("NeedsPlantHint") == true and localPlayer:GetAttribute("TutorialActive") ~= true then
			v13 = MyVariant() and HoldingEgg()
		else
			v13 = false
		end

		if v13 then
			if not v12 then
				local v14
				v12, v14 = HintText()
				Handler:PinMessage(v12, v14)
			end

			ShowPlantHand()
		elseif v12 then
			Handler:UnpinMessage(v12)
			v12 = nil
			HidePlantHand() -- equivalent call inferred; original call site unknown
		end
	end
end)

local function WatchHiddenNests(folder)
	local object = setmetatable({}, {
		__mode = "k"
	})

	local function IsNestDescendant(instance)
		local parent = instance.Parent

		while parent and parent ~= folder do
			if parent.Name == "Nests" and parent.Parent and parent.Parent.Parent == folder then
				return true
			else
				parent = parent.Parent
			end
		end

		return false
	end

	local function Conceal(descendant)
		if object[descendant] or not IsNestDescendant(descendant) then
			return
		end

		local v12

		if descendant:IsA("BasePart") then
			v12 = {
				LocalTransparencyModifier = 1,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false
			}
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			v12 = {
				Transparency = 1
			}
		elseif descendant:IsA("ProximityPrompt") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Highlight") then
			v12 = {
				Enabled = false
			}
		else
			v12 = nil
		end

		if not v12 then
			return
		end

		object[descendant] = true

		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end

		for propertyName, v13 in pairs(v12) do
			descendant[propertyName] = v13
			local v14 = propertyName
			local v15 = v13
			descendant:GetPropertyChangedSignal(propertyName):Connect(function()
				if IsNestDescendant(descendant) and descendant[v14] ~= v15 then
					descendant[v14] = v15
				end
			end)
		end
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(Conceal)

	for _, descendant in folder:GetDescendants() do
		Conceal(descendant)
	end

	return descendantAddedConnection
end

task.spawn(function()
	while localPlayer:GetAttribute("NoNest") == nil do
		localPlayer:GetAttributeChangedSignal("NoNest"):Wait()
	end

	-- equivalent call inferred; original call site unknown
	if not MyVariant() then
		return
	end

	WatchHiddenNests(workspace:WaitForChild("Plots"))
end)