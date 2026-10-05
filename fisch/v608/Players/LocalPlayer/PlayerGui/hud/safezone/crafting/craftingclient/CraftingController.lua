local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WorldController = require(ReplicatedStorage.client.legacyControllers.WorldController)

if WorldController:GetCurrentWorldIndex() ~= "Sea 1" then
	return false
end

local localPlayer = Players.LocalPlayer
local crafting = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("crafting")
local preview = crafting:WaitForChild("preview")
local items = crafting:WaitForChild("items")
local modules = ReplicatedStorage.shared.modules
local rodCrafting = workspace:WaitForChild("RodCrafting", 1e999)
local prompt = rodCrafting:WaitForChild("InteractPart"):WaitForChild("prompt")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local recipes = legacyLocalPlayerData.fetch():WaitForChild("Recipes")
local fish = require(modules:WaitForChild("library"):WaitForChild("fish"))
local recipes2 = require(modules:WaitForChild("library"):WaitForChild("recipes"))
local rods = require(modules:WaitForChild("library"):WaitForChild("rods"))
local items2 = require(modules:WaitForChild("library"):WaitForChild("items"))
local bobbers = require(modules:WaitForChild("fishing"):WaitForChild("bobbers"))
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local vessels = require(modules:WaitForChild("vessels"))
local fx = require(modules:WaitForChild("fx"))
local animatedgradient = require(modules:WaitForChild("fx"):WaitForChild("animatedgradient"))
local ViewportModule = require(game.ReplicatedStorage.client.modules.ViewportModule)
local mutations = require(modules:WaitForChild("fishing"):WaitForChild("mutations"))
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local ConfirmationController = require(ReplicatedStorage.client.legacyControllers.ConfirmationController)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local assets = require(ReplicatedStorage.shared.utils.assets)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("RodCrafting/TrackRecipe", -1)
local remoteEvent2 = Net:RemoteEvent("RodCrafting/UntrackRecipe", -1)
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local fetched = legacyLocalPlayerData.fetch()
local playerDataReplicator = DataController.PlayerDataReplicator
local v = nil
local v2 = nil
local CraftingController = {}

function comma_value(value)
	repeat
		local v3
		value, v3 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v3
	until k == 0

	return value
end

function CraftingController.hasRecipe(childName)
	if not recipes2[childName] then
		warn("Attempted to find a nil recipe:", childName)
		return false
	end

	if recipes:FindFirstChild(childName) then
		return true
	end

	return false
end

function CraftingController.HasItem(p, mutation)
	return DataController.CountItem(p, {
		Mutation = mutation
	}, nil, true)
end

function CraftingController.CloneCharacter()
	local character = localPlayer.Character
	local clone

	if character then
		character.Archivable = true
		clone = character:Clone()
		character.Archivable = false
	end

	return clone
end

function CraftingController:CreateIngredientViewport(childName, p, mutation)
	local icon

	if fish[childName] then
		icon = fish[childName].Icon
	elseif items2.Items[childName] and items2.Items[childName].Icon then
		icon = items2.Items[childName].Icon
	else
		icon = assets.getAsync("item", childName):WaitForChild(childName):Clone()
	end

	if typeof(icon) == "Instance" then
		local camera = Instance.new("Camera")
		camera.Parent = self:WaitForChild("ViewportFrame")
		icon.Parent = self:WaitForChild("ViewportFrame")
		local v3 = ViewportModule.new(self:WaitForChild("ViewportFrame"), camera)
		local boundingBox, _ = icon:GetBoundingBox()
		v3:SetModel(icon)
		local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
		local v4 = not p.ViewportSizeOffset and 1 or p.ViewportSizeOffset
		local v5 = v3:GetFitDistance(boundingBox.Position) * v4

		if mutation then
			if mutation == "Mythical" then
				for _, part in pairs(icon:GetDescendants()) do
					if not (part:IsA("BasePart") and part.Transparency ~= 1 and part.Name ~= "Eyes") then
						continue
					end

					local HSV, _, v6 = part.Color:ToHSV()
					part.Color = Color3.fromHSV(HSV, 0, (math.clamp(v6 + 0.25, 0, 1)))
				end

				local v6 = animatedgradient.new(animatedgradient._presets.Rainbow, true)
				v6.Rotation = 90
				v6.Parent = self:WaitForChild("ViewportFrame")
			else
				mutations:MutateModel(icon, mutation, {
					Name = childName,
					Mutation = mutation
				})
			end
		end

		camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v5)
		local viewportFrame = self:WaitForChild("ViewportFrame")
		viewportFrame.CurrentCamera = camera
		self.ImageLabel.Image = ""
	elseif typeof(icon) == "string" then
		self.ImageLabel.Image = icon
		self.ViewportFrame.Visible = false
	else
		self.ViewportFrame.Visible = false
		self.Image = "rbxassetid://12905962634"
	end
end

function CraftingController.ShowTooltip(instance)
	for _, image in pairs(preview:WaitForChild("list"):GetChildren()) do
		if not (image ~= instance and image:IsA("ImageLabel") and image.Visible == true and image.tooltip.Visible == true) then
			continue
		end

		image.tooltip.Visible = false
	end

	if instance then
		if instance.tooltip.Visible == true then
			instance.tooltip.Visible = false
			return
		end

		if instance:GetAttribute("Mutation") then
			if mutations.Mutations[instance:GetAttribute("Mutation")] then
				local mutation = mutations.Mutations[instance:GetAttribute("Mutation")]
				instance.tooltip.Text = "<font color='#" .. mutation.Color:ToHex() .. "'>" .. instance:GetAttribute("Mutation") .. "</font> " .. instance.Name
			else
				instance.tooltip.Text = instance:GetAttribute("Mutation") .. " " .. instance.Name
			end
		else
			instance.tooltip.Text = instance.Name
		end

		instance.tooltip.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTrackButton()
	if not v or v == "" then
		preview.Track.Visible = false
	elseif QuestShared:IsStarted(localPlayer, (`Recipe/{v}`)) then
		preview.Track.Text = "Untrack"
	else
		preview.Track.Text = "Track"
	end
end

function CraftingController.SelectRecipe(p)
	local recipe = recipes2[p]

	if recipe then
		v = p

		if CraftingController.hasRecipe(p) then
			if preview.itempreview.ViewportFrame:FindFirstChildWhichIsA("WorldModel") then
				preview.itempreview.ViewportFrame:FindFirstChildWhichIsA("WorldModel"):Destroy()
			end

			if recipe.Type == "Rod" then
				local rod = rods[recipe.Output]

				if not rod then
					warn("Failed to find rod " .. recipe.Output .. " in rodlibrary")
					return
				end

				local rodtitle = preview.itempreview:FindFirstChild("rodtitle")
				rodtitle.Text = "[" .. recipe.Output .. "]"
				local rodtitle_2 = preview.itempreview:FindFirstChild("rodtitle")
				rodtitle_2.TextColor3 = rod.Color
				local type = preview.itempreview:FindFirstChild("type")
				type.Text = recipe.Type

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel"):Destroy()
				end

				for _, image in pairs(preview:WaitForChild("list"):GetChildren()) do
					if image:IsA("ImageLabel") and image.Visible == true then
						image:Destroy()
					end
				end

				for i, item in ipairs(recipe.Items) do
					local name = item[1]
					local v4 = item[2]
					local v5 = item[3] or nil
					local v6 = items2.Items[name] or fish[name]

					if v6 then
						local hasItem = CraftingController.HasItem(name, v5)
						local clone = preview:WaitForChild("list"):WaitForChild("ItemTemplate"):Clone()
						clone.Name = name
						clone.LayoutOrder = i
						clone.amount.Text = math.min(hasItem, v4) .. "/" .. v4
						clone.amount.TextColor3 = v4 <= math.min(hasItem, v4) and Color3.fromRGB(73, 239, 32) or Color3.fromRGB(
							255,
							255,
							255
						)
						task.spawn(CraftingController.CreateIngredientViewport, clone, name, v6, v5)

						if v5 then
							clone:SetAttribute("Mutation", v5)
						end

						clone.Visible = true
						clone.Parent = preview:WaitForChild("list")
						clone.Click.Activated:Connect(function()
							CraftingController.ShowTooltip(clone)
						end)
					else
						warn("Failed to find recipe item " .. name .. " in itemlibrary/fishlibrary")
					end
				end

				local worldModel = Instance.new("WorldModel")
				worldModel.Parent = preview.itempreview.ViewportFrame
				local camera = Instance.new("Camera")
				camera.Parent = preview.itempreview.ViewportFrame
				preview.itempreview.ViewportFrame.CurrentCamera = camera
				preview.itempreview.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
				preview.itempreview.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
				local character = CraftingController.CloneCharacter()

				if character then
					character.HumanoidRootPart.Anchored = true

					for _, child in pairs(character:GetChildren()) do
						if child:IsA("Tool") then
							child:Destroy()
						elseif child:IsA("Model") and child.Name == "RodBodyModel" then
							child:Destroy()
						end
					end

					for _, child in pairs(character:GetChildren()) do
						if child:IsA("BaseScript") then
							child.Enabled = false
							child:Destroy()
						elseif child:IsA("BasePart") then
							child.CanCollide = false
							child.CanQuery = false
							child.CanTouch = false
						end
					end

					character:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, 2.6179938779914944, 0))
					local tool = Instance.new("Tool")
					tool.Name = "DisplayRod"
					tool.CanBeDropped = false
					tool.RequiresHandle = false
					local clone = assets.getAsync("rod", recipe.Output):FindFirstChildWhichIsA("Model"):Clone()

					if clone.PrimaryPart ~= nil then
						clone.PrimaryPart = clone:FindFirstChild("handle")
					end

					for _, child in pairs(clone:GetChildren()) do
						child.Parent = tool
					end

					tool.Parent = character
					clone:Destroy()
					local handle = tool:FindFirstChild("handle")

					if handle:FindFirstChild("WeldToArm") then
						handle:FindFirstChild("WeldToArm"):Destroy()
					end

					local motor6D = Instance.new("Motor6D")
					motor6D.Name = "WeldToArm"
					motor6D.Parent = handle
					motor6D.Part0 = character:FindFirstChild("Right Arm")
					motor6D.Part1 = handle
					motor6D.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
						-1.5707963267948966,
						-3.141592653589793,
						0
					)
					character.Parent = workspace
					local track = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(ReplicatedStorage.resources.animations.fishing.throw)
					track.Priority = Enum.AnimationPriority.Action4
					track.Looped = true
					track:Play()
					track:AdjustSpeed(0.5)
					character.Parent = worldModel
					camera.FieldOfView = 20
					camera.CFrame = CFrame.new(0, 1, 25) * CFrame.Angles(-0.08726646259971647, 0, 0)
				end

				preview.itempreview.ViewportFrame.ImageColor3 = Color3.new(1, 1, 1)
				preview.stats.Luck.Text = "Luck: " .. tostring(rod.Luck) .. "%"
				preview.stats.LureSpeed.Text = "Lure Speed: " .. tostring(100 - rod.LureSpeed) .. "%"
				preview.stats.Control.Text = "Control: " .. rod.Control
				preview.stats.Strength.Text = "Max Kg: " .. tostring(rod.Strength) .. "kg"
				preview.stats.Resilience.Text = "Resilience: " .. tostring(rod.Resilience) .. "%"

				if v2 then
					v2:Cancel()
				end

				preview.itempreview.description.Text = rod.Description
				preview.itempreview.description.MaxVisibleGraphemes = 0
				v2 = TweenService:Create(preview.itempreview.description, tweenInfo2, {
					MaxVisibleGraphemes = #rod.Description
				})
				v2:Play()
				preview.Craft.locked.Visible = false
				preview.Craft.crafted.Visible = false
				preview.Track.Visible = true
				updateTrackButton() -- equivalent call inferred; original call site unknown
				local v3, _ = ReplicatedStorage:WaitForChild("events"):WaitForChild("CanCraft"):InvokeServer(recipe.Output)

				if v3 then
					preview.Craft.locked.Visible = false
				end

				if recipe.Cost then
					local v4 = (recipe.Currency or "C$") == "Bells" and "Bells" or "C$"
					preview.Cost.Text = comma_value(recipe.Cost) .. " " .. v4
				else
					preview.Cost.Text = ""
				end

				if playerDataReplicator.Data.Rods[recipe.Output] then
					preview.Craft.locked.Visible = false
					preview.Craft.crafted.Visible = true
					preview.Track.Visible = false
				end
			elseif recipe.Type == "Bobber" then
				local bobber = bobbers.Bobbers[recipe.Output]

				if not bobber then
					warn("Failed to find bobber " .. recipe.Output .. " in bobbers")
					return
				end

				local rarity = rarities.Rarities[bobber.Rarity]
				preview.itempreview.rodtitle.Text = "[" .. recipe.Output .. "]"
				preview.itempreview.rodtitle.TextColor3 = rarity.Color
				preview.itempreview.type.Text = recipe.Type
				animatedgradient.clearold(preview.itempreview.rodtitle)

				if rarity.ColorGradient then
					preview.itempreview.rodtitle.TextColor3 = Color3.new(1, 1, 1)
					local new = animatedgradient.new(rarity.ColorGradient)
					new.Parent = preview.itempreview.rodtitle
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel"):Destroy()
				end

				for _, image in pairs(preview:WaitForChild("list"):GetChildren()) do
					if image:IsA("ImageLabel") and image.Visible == true then
						image:Destroy()
					end
				end

				for i, item in ipairs(recipe.Items) do
					local name = item[1]
					local v4 = item[2]
					local v5 = item[3] or nil
					local v6 = items2.Items[name] or fish[name]

					if v6 then
						local hasItem = CraftingController.HasItem(name, v5)
						local clone = preview:WaitForChild("list"):WaitForChild("ItemTemplate"):Clone()
						clone.Name = name
						clone.LayoutOrder = i
						clone.amount.Text = math.min(hasItem, v4) .. "/" .. v4
						clone.amount.TextColor3 = v4 <= math.min(hasItem, v4) and Color3.fromRGB(73, 239, 32) or Color3.fromRGB(
							255,
							255,
							255
						)
						task.spawn(CraftingController.CreateIngredientViewport, clone, name, v6, v5)

						if v5 then
							clone:SetAttribute("Mutation", v5)
						end

						clone.Visible = true
						clone.Parent = preview:WaitForChild("list")
						clone.Click.Activated:Connect(function()
							CraftingController.ShowTooltip(clone)
						end)
					else
						warn("Failed to find recipe item " .. name .. " in itemlibrary/fishlibrary")
					end
				end

				local camera = Instance.new("Camera")
				camera.FieldOfView = 60
				camera.Parent = preview.itempreview.ViewportFrame
				preview.itempreview.ViewportFrame.CurrentCamera = camera
				preview.itempreview.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
				preview.itempreview.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
				local clone = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("bobbers"):FindFirstChild(recipe.Output):Clone()
				clone.PrimaryPart.Anchored = true
				clone.Parent = preview.itempreview.ViewportFrame
				local v3 = ViewportModule.new(preview.itempreview.ViewportFrame, camera)
				local boundingBox, _ = clone:GetBoundingBox()
				v3:SetModel(clone)
				local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
				local fitDistance = v3:GetFitDistance(boundingBox.Position)
				camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance)
				preview.stats.Luck.Text = ""
				preview.stats.LureSpeed.Text = ""
				preview.stats.Control.Text = ""
				preview.stats.Strength.Text = ""
				preview.stats.Resilience.Text = ""

				if v2 then
					v2:Cancel()
				end

				preview.itempreview.description.Text = ""
				preview.Craft.locked.Visible = false
				preview.Craft.crafted.Visible = false
				preview.Track.Visible = true
				updateTrackButton() -- equivalent call inferred; original call site unknown
				local v4, _ = ReplicatedStorage:WaitForChild("events"):WaitForChild("CanCraft"):InvokeServer(recipe.Output)

				if v4 then
					preview.Craft.locked.Visible = false
				end

				if fetched:WaitForChild("Stats"):WaitForChild("bobber"):FindFirstChild(recipe.Output) then
					preview.Craft.locked.Visible = false
					preview.Craft.crafted.Visible = true
					preview.Track.Visible = false
				end
			elseif recipe.Type == "Boat" then
				if not vessels.library[recipe.Output] then
					warn("Failed to find boat " .. recipe.Output .. " in vessels")
					return
				end

				local rodtitle_3 = preview.itempreview:FindFirstChild("rodtitle")
				rodtitle_3.Text = "[" .. recipe.Output .. "]"
				local rodtitle_4 = preview.itempreview:FindFirstChild("rodtitle")
				rodtitle_4.TextColor3 = Color3.new(1, 1, 1)
				local type_2 = preview.itempreview:FindFirstChild("type")
				type_2.Text = recipe.Type

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
				end

				if preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel") then
					preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel"):Destroy()
				end

				for _, image in pairs(preview:WaitForChild("list"):GetChildren()) do
					if image:IsA("ImageLabel") and image.Visible == true then
						image:Destroy()
					end
				end

				for i, item in ipairs(recipe.Items) do
					local name = item[1]
					local v4 = item[2]
					local v5 = item[3] or nil
					local v6 = items2.Items[name] or fish[name]

					if v6 then
						local hasItem = CraftingController.HasItem(name, v5)
						local clone = preview:WaitForChild("list"):WaitForChild("ItemTemplate"):Clone()
						clone.Name = name
						clone.LayoutOrder = i
						clone.amount.Text = math.min(hasItem, v4) .. "/" .. v4
						clone.amount.TextColor3 = v4 <= math.min(hasItem, v4) and Color3.fromRGB(73, 239, 32) or Color3.fromRGB(
							255,
							255,
							255
						)
						task.spawn(CraftingController.CreateIngredientViewport, clone, name, v6, v5)

						if v5 then
							clone:SetAttribute("Mutation", v5)
						end

						clone.Visible = true
						clone.Parent = preview:WaitForChild("list")
						clone.Click.Activated:Connect(function()
							CraftingController.ShowTooltip(clone)
						end)
					else
						warn("Failed to find recipe item " .. name .. " in itemlibrary/fishlibrary")
					end
				end

				if ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels"):FindFirstChild(recipe.Output) then
					local camera = Instance.new("Camera")
					camera.Parent = preview.itempreview.ViewportFrame
					preview.itempreview.ViewportFrame.CurrentCamera = camera
					local clone = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels")[recipe.Output]:Clone()
					clone:FindFirstChild("PlanePart"):Destroy()
					clone.Parent = preview.itempreview.ViewportFrame
					local boundingBox, v3 = clone:GetBoundingBox()
					local v4 = clone.PrimaryPart.Position - boundingBox.Position
					clone:PivotTo(clone.PrimaryPart.CFrame - clone.PrimaryPart.CFrame.Position + v4)
					local v5 = v3.Magnitude * 0.6
					camera.CFrame = CFrame.lookAt(
						createVector(1, 1, 1) * v5,
						createVector(0, 0, 0),
						createVector(0, 1, 0)
					)
				end

				preview.stats.Luck.Text = "Steering: " .. tostring((math.round(vessels.library[recipe.Output].TurningSpeed * 100))) .. "°"
				preview.stats.LureSpeed.Text = "Speed: " .. vessels.library[recipe.Output].MaxSpeed .. "S/ps"
				preview.stats.Control.Text = "Acceleration: " .. tostring(vessels.library[recipe.Output].Accel) .. "S/ps"
				preview.stats.Strength.Text = ""
				preview.stats.Resilience.Text = ""

				if v2 then
					v2:Cancel()
				end

				preview.itempreview.description.Text = ""
				preview.Craft.locked.Visible = false
				preview.Craft.crafted.Visible = false
				preview.Track.Visible = true
				updateTrackButton() -- equivalent call inferred; original call site unknown
				local v3, _ = ReplicatedStorage:WaitForChild("events"):WaitForChild("CanCraft"):InvokeServer(recipe.Output)

				if v3 then
					preview.Craft.locked.Visible = false
				end

				if fetched:WaitForChild("Boats"):FindFirstChild(recipe.Output) then
					preview.Craft.locked.Visible = false
					preview.Craft.crafted.Visible = true
					preview.Track.Visible = false
				end
			end
		else
			if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera") then
				preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera"):Destroy()
			end

			if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model") then
				preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
			end

			if preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel") then
				preview.itempreview.ViewportFrame:FindFirstChildOfClass("WorldModel"):Destroy()
			end

			local rodtitle_5 = preview.itempreview:FindFirstChild("rodtitle")
			rodtitle_5.Text = "[???]"
			local rodtitle_6 = preview.itempreview:FindFirstChild("rodtitle")
			rodtitle_6.TextColor3 = Color3.new(1, 1, 1)
			local type_3 = preview.itempreview:FindFirstChild("type")
			type_3.Text = recipe.Hint
			preview.stats.Luck.Text = ""
			preview.stats.LureSpeed.Text = ""
			preview.stats.Control.Text = ""
			preview.stats.Strength.Text = ""
			preview.stats.Resilience.Text = ""

			if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera") then
				preview.itempreview.ViewportFrame:FindFirstChildOfClass("Camera"):Destroy()
			end

			if preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model") then
				preview.itempreview.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
			end

			for _, image in pairs(preview:WaitForChild("list"):GetChildren()) do
				if image:IsA("ImageLabel") and image.Visible == true then
					image:Destroy()
				end
			end

			preview.Craft.locked.Visible = true
			preview.Craft.crafted.Visible = false
			preview.Track.Visible = false
			preview.itempreview.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = preview.itempreview.ViewportFrame
			local camera = Instance.new("Camera")
			camera.Parent = preview.itempreview.ViewportFrame
			preview.itempreview.ViewportFrame.CurrentCamera = camera
			preview.itempreview.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
			preview.itempreview.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
			local character = CraftingController.CloneCharacter()

			if character then
				character.HumanoidRootPart.Anchored = true

				for _, child in pairs(character:GetChildren()) do
					if child:IsA("Tool") then
						child:Destroy()
					elseif child:IsA("Model") and child.Name == "RodBodyModel" then
						child:Destroy()
					end
				end

				for _, child in pairs(character:GetChildren()) do
					if child:IsA("BaseScript") then
						child.Enabled = false
						child:Destroy()
					elseif child:IsA("BasePart") then
						child.CanCollide = false
						child.CanQuery = false
						child.CanTouch = false
					end
				end

				character:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, 2.6179938779914944, 0))
				local tool = Instance.new("Tool")
				tool.Name = "DisplayRod"
				tool.CanBeDropped = false
				tool.RequiresHandle = false
				local clone = assets.getAsync("rod", recipe.Output):FindFirstChildWhichIsA("Model"):Clone()

				if clone.PrimaryPart ~= nil then
					clone.PrimaryPart = clone:FindFirstChild("handle")
				end

				for _, child in pairs(clone:GetChildren()) do
					child.Parent = tool
				end

				tool.Parent = character
				clone:Destroy()
				local handle = tool:FindFirstChild("handle")

				if handle:FindFirstChild("WeldToArm") then
					handle:FindFirstChild("WeldToArm"):Destroy()
				end

				local motor6D = Instance.new("Motor6D")
				motor6D.Name = "WeldToArm"
				motor6D.Parent = handle
				motor6D.Part0 = character:FindFirstChild("Right Arm")
				motor6D.Part1 = handle
				motor6D.C0 = CFrame.new(-0.151, -1.013, -0.25) * CFrame.Angles(
					-1.5707963267948966,
					-3.141592653589793,
					0
				)
				character.Parent = workspace
				local track = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(ReplicatedStorage.resources.animations.fishing.throw)
				track.Priority = Enum.AnimationPriority.Action4
				track.Looped = true
				track:Play()
				track:AdjustSpeed(0.5)
				character.Parent = worldModel
				camera.FieldOfView = 20
				camera.CFrame = CFrame.new(0, 1, 25) * CFrame.Angles(-0.08726646259971647, 0, 0)
			end
		end
	else
		warn("Failed to find recipe " .. p .. " in recipelibrary")
	end
end

function CraftingController.SwapCategory(childName)
	local v3 = not (childName and items:FindFirstChild(childName)) and "Rods" or childName
	local child = items:FindFirstChild(v3)

	for _, scrollingFrame in pairs(items:GetChildren()) do
		if scrollingFrame:IsA("ScrollingFrame") and scrollingFrame ~= child then
			scrollingFrame.Visible = false
		end
	end

	child.Visible = true
	crafting.rodtitle.Text = "Crafting [" .. v3 .. "]"
end

function CraftingController.SetupGui()
	CraftingController.SwapCategory("Rods")

	for _, scrollingFrame in pairs(crafting.items:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		for _, button in pairs(scrollingFrame:GetChildren()) do
			if button:IsA("ImageButton") and button.Visible == true then
				button:Destroy()
			end
		end
	end

	for _, recipe in pairs(recipes2) do
		if fetched:WaitForChild("Recipes"):FindFirstChild(recipe.Name) then
			local clone = crafting:WaitForChild("items"):WaitForChild("TemplateUnlocked"):Clone()
			clone.Name = recipe.Name
			clone.LayoutOrder = recipe.Order
			clone.outputtitle.Text = recipe.Output
			clone.Visible = true

			if recipe.Type == "Rod" then
				if rods[recipe.Output] then
					clone.outputtitle.TextColor3 = rods[recipe.Output].Color

					if rods[recipe.Output].Icon then
						clone.rodIcon.Image = rods[recipe.Output].Icon
						clone.rodIcon.Visible = true
					else
						local camera = Instance.new("Camera")
						camera.Parent = clone.ViewportFrame
						clone.ViewportFrame.CurrentCamera = camera
						clone.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
						clone.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
						local clone2 = assets.getAsync("rod", recipe.Output):FindFirstChildWhichIsA("Model"):Clone()
						clone2.Parent = clone.ViewportFrame
						camera.FieldOfView = 35
						camera.CFrame = clone2.PrimaryPart.CFrame * CFrame.new(8, 2, 0) * CFrame.Angles(
							0,
							1.5707963267948966,
							0.2792526803190927
						)
						clone.ViewportFrame.Visible = true
					end
				end

				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Rods")
			elseif recipe.Type == "Bobber" then
				if bobbers.Bobbers[recipe.Output] then
					local rarity = rarities.Rarities[bobbers.Bobbers[recipe.Output].Rarity]
					clone.outputtitle.TextColor3 = rarity.Color

					if rarity.ColorGradient then
						clone.outputtitle.TextColor3 = Color3.new(1, 1, 1)
						local new = animatedgradient.new(rarity.ColorGradient)
						new.Parent = clone.outputtitle
					end

					local camera = Instance.new("Camera")
					camera.FieldOfView = 60
					camera.Parent = clone.ViewportFrame
					clone.ViewportFrame.CurrentCamera = camera
					clone.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
					clone.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
					local clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("bobbers"):FindFirstChild(recipe.Output):Clone()
					clone2.PrimaryPart.Anchored = true
					clone2.Parent = clone.ViewportFrame
					local v3 = ViewportModule.new(clone.ViewportFrame, camera)
					local boundingBox, _ = clone2:GetBoundingBox()
					v3:SetModel(clone2)
					local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
					local fitDistance = v3:GetFitDistance(boundingBox.Position)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance)
				end

				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Bobbers")
			elseif recipe.Type == "Boat" then
				if ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels"):FindFirstChild(recipe.Output) then
					local camera = Instance.new("Camera")
					camera.Parent = clone.ViewportFrame
					clone.ViewportFrame.CurrentCamera = camera
					local clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels")[recipe.Output]:Clone()
					clone2:FindFirstChild("PlanePart"):Destroy()
					clone2.Parent = clone.ViewportFrame
					local boundingBox, v3 = clone2:GetBoundingBox()
					local v4 = clone2.PrimaryPart.Position - boundingBox.Position
					clone2:PivotTo(clone2.PrimaryPart.CFrame - clone2.PrimaryPart.CFrame.Position + v4)
					local v5 = v3.Magnitude * 0.6
					camera.CFrame = CFrame.lookAt(
						createVector(1, 1, 1) * v5,
						createVector(0, 0, 0),
						createVector(0, 1, 0)
					)
				end

				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Boats")
			end

			clone.MouseEnter:Connect(function()
				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
					crafting.activesounds,
					true
				)
			end)
			clone.MouseButton1Down:Connect(function()
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, crafting.activesounds, false)
			end)
			clone.MouseButton1Up:Connect(function()
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, crafting.activesounds, false)
			end)
			local v3 = recipe
			clone.Activated:Connect(function()
				CraftingController.SelectRecipe(v3.Name)
			end)
		else
			local clone = crafting:WaitForChild("items"):WaitForChild("TemplateLocked"):Clone()
			clone.Name = recipe.Name
			clone.LayoutOrder = recipe.Order + 10000
			clone.Visible = true

			if recipe.Type == "Rod" then
				if rods[recipe.Output] then
					if rods[recipe.Output].Icon then
						clone.rodIcon.Image = rods[recipe.Output].Icon
						clone.rodIcon.Visible = true
					else
						local camera = Instance.new("Camera")
						camera.Parent = clone.ViewportFrame
						clone.ViewportFrame.CurrentCamera = camera
						clone.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
						clone.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
						local clone2 = assets.getAsync("rod", recipe.Output):FindFirstChildWhichIsA("Model"):Clone()
						clone2.Parent = clone.ViewportFrame
						camera.FieldOfView = 35
						camera.CFrame = clone2.PrimaryPart.CFrame * CFrame.new(8, 2, 0) * CFrame.Angles(
							0,
							1.5707963267948966,
							0.2792526803190927
						)
						clone.ViewportFrame.Visible = true
					end
				end

				clone.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Rods")
			elseif recipe.Type == "Bobber" then
				if bobbers.Bobbers[recipe.Output] then
					if bobbers.Bobbers[recipe.Output].Rarity == "Exotic" then
						clone.outputtitle.TextColor3 = Color3.new(1, 1, 1)
						local new_2 = animatedgradient.new(animatedgradient._presets.Rainbow)
						new_2.Parent = clone.outputtitle
					elseif bobbers.Bobbers[recipe.Output].Rarity == "Secret" then
						clone.outputtitle.TextColor3 = Color3.new(1, 1, 1)
						local new_3 = animatedgradient.new(animatedgradient._presets.Secret)
						new_3.Parent = clone.outputtitle
					end

					local camera = Instance.new("Camera")
					camera.FieldOfView = 60
					camera.Parent = clone.ViewportFrame
					clone.ViewportFrame.CurrentCamera = camera
					clone.ViewportFrame.Ambient = Color3.fromRGB(211, 211, 211)
					clone.ViewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
					local clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("bobbers"):FindFirstChild(recipe.Output):Clone()
					clone2.PrimaryPart.Anchored = true
					clone2.Parent = clone.ViewportFrame
					local v3 = ViewportModule.new(clone.ViewportFrame, camera)
					local boundingBox, _ = clone2:GetBoundingBox()
					v3:SetModel(clone2)
					local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
					local fitDistance = v3:GetFitDistance(boundingBox.Position)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance)
				end

				clone.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Bobbers")
			elseif recipe.Type == "Boat" then
				if ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels"):FindFirstChild(recipe.Output) then
					local camera = Instance.new("Camera")
					camera.Parent = clone.ViewportFrame
					clone.ViewportFrame.CurrentCamera = camera
					local clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("vessels")[recipe.Output]:Clone()
					clone2:FindFirstChild("PlanePart"):Destroy()
					clone2.Parent = clone.ViewportFrame
					local boundingBox, v3 = clone2:GetBoundingBox()
					local v4 = clone2.PrimaryPart.Position - boundingBox.Position
					clone2:PivotTo(clone2.PrimaryPart.CFrame - clone2.PrimaryPart.CFrame.Position + v4)
					local v5 = v3.Magnitude * 0.6
					camera.CFrame = CFrame.lookAt(
						createVector(1, 1, 1) * v5,
						createVector(0, 0, 0),
						createVector(0, 1, 0)
					)
				end

				clone.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)
				clone.Parent = crafting:WaitForChild("items"):WaitForChild("Boats")
			end

			clone.MouseEnter:Connect(function()
				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
					crafting.activesounds,
					true
				)
			end)
			clone.MouseButton1Down:Connect(function()
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, crafting.activesounds, false)
			end)
			clone.MouseButton1Up:Connect(function()
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, crafting.activesounds, false)
			end)
			local v3 = recipe
			clone.Activated:Connect(function()
				CraftingController.SelectRecipe(v3.Name)
			end)
		end
	end

	if v then
		CraftingController.SelectRecipe(v)
	end
end

function CraftingController.OnCraftingSuccess(p)
	CraftingController.ToggleGui(false)
	local recipe = recipes2[p]

	if recipe then
		script:WaitForChild("Craft"):Play()
		rodCrafting:WaitForChild("AnvilPart"):WaitForChild("Attachment"):WaitForChild("Strike"):Emit(5)
		rodCrafting:WaitForChild("AnvilPart"):WaitForChild("Attachment"):WaitForChild("Debris"):Emit(Random.new():NextInteger(
			6,
			7
		))

		if recipe.Type == "Rod" then
			local async = assets.getAsync("rod", recipe.Output)
			local asyncModel = async and async:FindFirstChildWhichIsA("Model")

			if asyncModel then
				local clone = asyncModel:Clone()
				clone.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
				clone:PivotTo(rodCrafting.AnvilPart:GetPivot() * CFrame.Angles(
					0,
					0.7853981633974483,
					1.5707963267948966
				) * CFrame.new(0, -2, 0))
				clone.Name = "CraftingResult"

				for _, part in pairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end

				clone.Parent = workspace.active.debrisfx
				task.wait(2)

				for _, descendant in pairs(clone:GetDescendants()) do
					if (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) and descendant.Transparency ~= 1 then
						TweenService:Create(descendant, tweenInfo, {
							Transparency = 1
						}):Play()
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") then
						descendant.Enabled = false
					end
				end

				task.delay(tweenInfo.Time, function()
					if clone then
						clone:Destroy()
					end
				end)
			end
		end
	else
		warn("Failed to find recipe " .. p .. " in recipelibrary")
	end
end

function CraftingController.ToggleGui(visible)
	local v3 = crafting

	if visible == nil or not visible then
		visible = not crafting.Visible
	end

	v3.Visible = visible

	if crafting.Visible then
		CraftingController.SetupGui()
	end
end

function CraftingController.PromptTriggered()
	CraftingController.ToggleGui(true)
end

crafting:WaitForChild("Close").Activated:Connect(function()
	CraftingController.ToggleGui(false)
end)

local function SetupButtonBToClose()
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage2.client.legacyControllers:WaitForChild("InputController")):Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean)
		if not (flag ~= true and p == Enum.KeyCode.ButtonB and crafting.Visible == true) then
			return
		end

		CraftingController.ToggleGui(false)
	end)
end

task.spawn(SetupButtonBToClose)
local flag = false
preview:WaitForChild("Craft").Activated:Connect(function()
	if v then
		if flag then
			return
		end

		flag = true
		local v3 = ConfirmationController.new({
			header = "Craft?",
			text = "Are you sure you want to craft this item? This process will consume the required materials.",
			options = {
				{
					text = "No",
					color = Color3.fromRGB(255, 120, 122)
				},
				{
					text = "Yes"
				}
			}
		})
		flag = false

		if v3 == 1 then
			return
		end

		local v4, v5 = ReplicatedStorage:WaitForChild("events"):WaitForChild("AttemptCraft"):InvokeServer(v)

		if v4 then
			coroutine.wrap(CraftingController.OnCraftingSuccess)(v)
		elseif preview:WaitForChild("Craft"):WaitForChild("crafted").Visible == false then
			script:WaitForChild("Fail"):Play()

			if typeof(v5) == "table" then
				ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthoughtbig"):Fire("<font color='rgb(191,54,54)'>Failed to craft <b>" .. v .. "</b>!</font>")

				for _, item in ipairs(v5) do
					local v6 = item[1]
					local v7 = item[2]
					ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought"):Fire("<font color='rgb(191,54,54)'>You need <b>×" .. tostring(v7) .. "</b> more <b>" .. v6 .. "</b>!</font>")
				end
			end
		elseif typeof(v5) == "string" then
			ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthoughtbig"):Fire("<font color='rgb(191,54,54)'>You already crafted <b>" .. v .. "</b>!</font>")
		end

		CraftingController.SelectRecipe(v)
	end
end)
preview:WaitForChild("Craft").MouseEnter:Connect(function()
	fx:PlaySound(
		ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
		crafting.activesounds,
		true
	)
end)
preview:WaitForChild("Craft").MouseButton1Down:Connect(function()
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, crafting.activesounds, false)
end)
preview:WaitForChild("Craft").MouseButton1Up:Connect(function()
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, crafting.activesounds, false)
end)

for _, button in pairs(crafting:WaitForChild("sections"):GetChildren()) do
	if not button:IsA("ImageButton") then
		continue
	end

	local v3 = button
	button.Activated:Connect(function()
		CraftingController.SwapCategory(v3.Name)
	end)
end

prompt.Triggered:Connect(CraftingController.PromptTriggered)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		CraftingController.ShowTooltip()
	end
end)
preview.Track.Activated:Connect(function()
	if not v or v == "" then
		return
	end

	if QuestShared:IsStarted(localPlayer, (`Recipe/{v}`)) then
		remoteEvent2:FireServer(v)
		return
	end

	print("requesting track", v)
	remoteEvent:FireServer(v)
end)
local questActive = legacyLocalPlayerData.fetch():WaitForChild("QuestActive")
questActive.ChildAdded:Connect(function(child)
	if v and child.Name == `Recipe/{v}` then
		updateTrackButton() -- equivalent call inferred; original call site unknown
	end
end)
questActive.ChildRemoved:Connect(function(child)
	if v and child.Name == `Recipe/{v}` then
		updateTrackButton() -- equivalent call inferred; original call site unknown
	end
end)
updateTrackButton() -- equivalent call inferred; original call site unknown
return CraftingController