local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CauldronClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local removeTable = require(ReplicatedStorage.Modules.UtilityAlec.removeTable)
local random = Random.new()
local v = nil
local v2 = {
	"rbxassetid://77900255607324",
	"rbxassetid://120388799209347",
	"rbxassetid://96276852797792",
	"rbxassetid://82863128121099",
	"rbxassetid://83430808613770"
}
local v3 = {
	"rbxassetid://97270795125658",
	"rbxassetid://111104685600007",
	"rbxassetid://93529160972452",
	"rbxassetid://114471693491175",
	"rbxassetid://81495219702881",
	"rbxassetid://82532731737256"
}
local heartbeatConnection = nil
local heartbeatConnections = {}
local positions = {}
local v4 = {
	Mandrake = "Mandrake Plant",
	["Stareweed Petal"] = "Stareweed Plant",
	["Moonflower Bulb"] = "Moonflower Plant",
	Dripleaf = "Dripleaf Plant",
	["Cave Vine Flower"] = "Cave Vine",
	Berry = "Berries"
}
local frames = {}

function DoExplosion(instance)
	local particlesBad = instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("ParticlesBad")

	if particlesBad then
		local children = particlesBad:GetChildren()
		local v5 = children[random:NextInteger(1, #children)]

		if not v5 then
			return
		end

		v.Main.Explode:Play()
		Client.Utility.RunParticles(v5)
	end

	task.spawn(function()
		if localPlayer.Character then
			local position = instance:GetPivot().Position

			if (localPlayer.Character:GetPivot().Position - position).Magnitude < 15 then
				Client.ToolModule.ApplyKnockback(instance.PrimaryPart, {
					Vertical = 20,
					Horizontal = 35
				})
			end
		end
	end)
end

function DoCooking(instance, value)
	local liquid = instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("Liquid")
	local v5 = value or 8

	if liquid then
		for _, emitter in pairs(liquid:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and string.sub(emitter.Name, 1, 4) == "Cook") then
				continue
			end

			local emitCount = emitter:GetAttribute("EmitCount") or 0
			local emitDuration = emitter:GetAttribute("EmitDuration") or 0

			if emitCount > 0 then
				emitter:Emit(emitCount)
			end

			if not (emitDuration > 0 or emitCount == 0 and emitDuration == 0) then
				continue
			end

			emitter.Enabled = true
			local v6 = emitter
			task.spawn(function()
				wait(v5)
				v6.Enabled = false
			end)
		end
	end
end

function AnimateCauldron(instance, instance2, cauldronParticles)
	local particlesGood = instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("ParticlesGood")

	if instance2 then
		cauldronParticles = instance2:GetAttribute("CauldronParticles") or cauldronParticles
	end

	if instance.Main:FindFirstChild("Default") then
		task.spawn(function()
			local clone = instance.Main:FindFirstChild("Default"):Clone()
			clone.Name = "ClonedSound"
			clone.Parent = instance.Main
			clone:Play()
			wait(4.5)

			if clone then
				clone:Destroy()
			end
		end)
	end

	local particlesDefault = instance.Functional:FindFirstChild("ParticlesDefault")

	if particlesDefault then
		Client.Utility.RunParticles(particlesDefault)
	end

	if particlesGood then
		task.delay(0.25, function()
			local child = cauldronParticles and particlesGood:FindFirstChild(cauldronParticles)

			if not child then
				local children = particlesGood:GetChildren()
				child = children[random:NextInteger(1, #children)]
			end

			if not child then
				return
			end

			Client.Utility.RunParticles(child)
		end)
	end
end

local v5 = nil
local v6 = {}

function CauldronClient.TakePotion(instance)
	if instance ~= v5 then
		return
	end

	instance:SetAttribute("FloatingPotion", nil)
	instance.PrimaryPart.Anchored = false
	v5 = nil
	local highlight = instance:FindFirstChildOfClass("Highlight")

	if highlight then
		highlight.Adornee = nil
		highlight:Destroy()
	end

	for _, trail in pairs(instance.PrimaryPart:GetChildren()) do
		if trail:IsA("Trail") then
			trail:Destroy()
		end
	end

	task.delay(3, function()
		SpawnNextPotion()
	end)
end

function FloatPotion(instance, cframe: CFrame)
	local v7 = 0
	local number = random:NextNumber()
	local number2 = random:NextNumber()
	Client.TweenModule.new(function(p)
		v7 = p * 4
	end, 3, "Quad"):Play()
	local total = 0
	local total2 = 0

	while instance:GetAttribute("FloatingPotion") do
		local v8 = cframe + Vector3.new(0, v7, 0)
		local v9 = 6.283185307179586 * (total * 4)
		local v10 = math.clamp((math.noise(number, total2 * 0.5) + 1) / 2, 0, 1) * 2 + 0.5
		local v11 = v8 * CFrame.Angles(0, math.rad(v9), 0) * CFrame.new(0, 0, -v10)
		local cframe2 = CFrame.new(v11.Position)
		local v12 = math.clamp(math.noise(number, total2), -0.5, 0.5) * 20
		local v13 = math.clamp(math.noise(number2, total2), -0.5, 0.5) * 20
		local v14 = total2 * 180
		instance:PivotTo(cframe2 * CFrame.Angles(math.rad(v12), 0, (math.rad(v13))) * CFrame.Angles(0, math.rad(v14), 0) + Vector3.new(
			0,
			math.clamp((math.noise(number, total2 * 0.75) + 1) / 2, 0, 1),
			0
		))
		local v15 = task.wait()
		total2 += v15
		total += v15 * (math.clamp((math.noise(number, total2) + 1) / 2, 0, 1) * 3.5 + 1)
	end
end

function SpawnNextPotion()
	print("spawn next potion?")

	while not (v and v.Parent) do
		task.wait(1)
	end

	if v5 and v5.Parent ~= workspace.Items then
		v5 = nil
	end

	if v5 then
		return
	end

	print("yes spawn next potion")
	local v7 = v
	local v8 = table.remove(v6, 1)

	if not (v8 and v8.Parent == game.ReplicatedStorage.TempStorage) then
		return
	end

	v5 = v8
	v8:SetAttribute("FloatingPotion", true)
	v8.PrimaryPart.Anchored = true
	v8.Parent = workspace.Items
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 17, 199)
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0.3
	highlight.Parent = v8
	highlight.Adornee = v8

	for _, child in pairs(game.ReplicatedStorage.Assets.Halloween.PotionTrail:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = v8.PrimaryPart
	end

	v8.PrimaryPart.Trail.Attachment0 = v8.PrimaryPart.Attachment1
	v8.PrimaryPart.Trail.Attachment1 = v8.PrimaryPart.Attachment2
	local v9 = v7:GetPivot() - createVector(0, 1, 0)
	FloatPotion(v8, v9)
end

function AddPotionToQueue(p, _)
	table.insert(v6, p)
	print("Added potion to queue", p)
	print("Queue:", v6)

	if not v5 then
		SpawnNextPotion()
	end
end

Client.Events.PotionMade:Connect(function(p, p2)
	AddPotionToQueue(p, p2)
end)

local function StartCloudLoop(cloud)
	local v7 = 1

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local now = tick()
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now2 = tick()

		if now2 - now >= 0.1 then
			now = now2
			v7 = v7 % #v2 + 1
			cloud.Image = v2[v7]
		end
	end)
end

local function StartIngredientBob(p, value: number)
	local position = p.Position
	local v7 = value or 0
	local RunService = game:GetService("RunService")
	local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		local v8 = math.sin(tick() * 1.6 + v7) * 0.1
		p.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale + v8, position.Y.Offset)
	end)
	table.insert(heartbeatConnections, heartbeatConnection2)
end

function CauldronClient.PlayFlare(p: number, p2)
	if not v then
		return
	end

	local main = v:FindFirstChild("Main")

	if not main then
		return
	end

	local flare = main:FindFirstChild("BillboardGui"):FindFirstChild("Cauldron"):FindFirstChild("Cloud"):FindFirstChild("Ingredient" .. p):FindFirstChild("Flare")
	flare.ImageColor3 = p2 or Color3.fromRGB(255, 213, 0)
	flare.Visible = true
	local v7 = 1
	local v8 = #v3 * 0.1
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < v8 do
			flare.Image = v3[v7]
			v7 = v7 % #v3 + 1
			task.wait(0.1)
		end

		flare.Visible = false
	end)
end

function CauldronClient.FadeOut()
	if not v then
		return
	end

	local main = v:FindFirstChild("Main")

	if not main then
		return
	end

	local billboardGui = main:FindFirstChild("BillboardGui")

	if not billboardGui then
		return
	end

	local cauldron = billboardGui:FindFirstChild("Cauldron")

	if not cauldron then
		return
	end

	local cloud = cauldron:FindFirstChild("Cloud")

	if not cloud then
		return
	end

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(cloud, tweenInfo, {
		ImageTransparency = 1
	}):Play()

	for i = 1, 3 do
		local child = cloud:FindFirstChild("Ingredient" .. i)

		if not child then
			continue
		end

		TweenService:Create(child, tweenInfo, {
			ImageTransparency = 1
		}):Play()
		local flare = child:FindFirstChild("Flare")

		if flare then
			TweenService:Create(flare, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end

		local tick2 = child:FindFirstChild("Tick")

		if tick2 then
			TweenService:Create(tick2, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end

		local quantity = child:FindFirstChild("Quantity")

		if not quantity then
			continue
		end

		TweenService:Create(quantity, tweenInfo, {
			TextTransparency = 1
		}):Play()
		TweenService:Create(quantity.UIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
	end

	for _, label in pairs(cloud:GetDescendants()) do
		if not (label:IsA("TextLabel") and label.Name == "Plus") then
			continue
		end

		TweenService:Create(label, tweenInfo, {
			TextTransparency = 1
		}):Play()
		local uIStroke = label:FindFirstChild("UIStroke")

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end
end

function CauldronClient.FadeIn()
	if not v then
		return
	end

	local main = v:FindFirstChild("Main")

	if not main then
		return
	end

	local billboardGui = main:FindFirstChild("BillboardGui")

	if not billboardGui then
		return
	end

	local cauldron = billboardGui:FindFirstChild("Cauldron")

	if not cauldron then
		return
	end

	local cloud = cauldron:FindFirstChild("Cloud")

	if not cloud then
		return
	end

	task.spawn(function()
		TweenService:Create(cloud, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0.55
		}):Play()
		task.wait(0.3)

		for i = 1, 3 do
			local child = cloud:FindFirstChild("Ingredient" .. i)

			if not child then
				continue
			end

			local position = positions[child] or child.Position
			child.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale + 0.3, position.Y.Offset)
			child.ImageTransparency = 1
			local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local tween = TweenService:Create(child, tweenInfo2, {
				Position = position
			})
			local tween2 = TweenService:Create(child, tweenInfo2, {
				ImageTransparency = 0
			})
			tween:Play()
			tween2:Play()
			local flare = child:FindFirstChild("Flare")

			if flare then
				flare.ImageTransparency = 0
				flare.Visible = false
			end

			local tick2 = child:FindFirstChild("Tick")

			if tick2 then
				tick2.ImageTransparency = 0
			end

			local quantity = child:FindFirstChild("Quantity")

			if quantity then
				quantity.TextTransparency = 0
				quantity.UIStroke.Transparency = 0
				quantity.UIStroke.Enabled = true
			end

			task.wait(0.15)
		end

		task.wait(0.1)
		local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, label in pairs(cloud:GetDescendants()) do
			if not (label:IsA("TextLabel") and label.Name == "Plus") then
				continue
			end

			TweenService:Create(label, tweenInfo2, {
				TextTransparency = 0
			}):Play()
			local uIStroke = label:FindFirstChild("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, tweenInfo2, {
					Transparency = 0
				}):Play()
			end
		end
	end)
end

function SetUpBillboard(instance)
	local main = instance:FindFirstChild("Main")

	if not main then
		return
	end

	local cauldron = main:FindFirstChild("BillboardGui"):FindFirstChild("Cauldron")

	if not cauldron then
		return
	end

	local cloud = cauldron:FindFirstChild("Cloud")

	if cloud then
		cloud.ImageTransparency = 1
		local ingredient1 = cloud:FindFirstChild("Ingredient1")
		local ingredient2 = cloud:FindFirstChild("Ingredient2")
		local ingredient3 = cloud:FindFirstChild("Ingredient3")

		if ingredient1 then
			positions[ingredient1] = ingredient1.Position
			ingredient1.ImageTransparency = 1
			local position = ingredient1.Position
			local RunService = game:GetService("RunService")
			local v7 = 0
			local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				local v8 = math.sin(tick() * 1.6 + v7) * 0.1
				ingredient1.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset,
					position.Y.Scale + v8,
					position.Y.Offset
				)
			end)
			table.insert(heartbeatConnections, heartbeatConnection2)
		end

		if ingredient2 then
			positions[ingredient2] = ingredient2.Position
			ingredient2.ImageTransparency = 1
			local position = ingredient2.Position
			local RunService = game:GetService("RunService")
			local v7 = 2.0734511513692637
			local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				local v8 = math.sin(tick() * 1.6 + v7) * 0.1
				ingredient2.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset,
					position.Y.Scale + v8,
					position.Y.Offset
				)
			end)
			table.insert(heartbeatConnections, heartbeatConnection2)
		end

		if ingredient3 then
			positions[ingredient3] = ingredient3.Position
			ingredient3.ImageTransparency = 1
			local position = ingredient3.Position
			local RunService = game:GetService("RunService")
			local v7 = 4.178318229274425
			local heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				local v8 = math.sin(tick() * 1.6 + v7) * 0.1
				ingredient3.Position = UDim2.new(
					position.X.Scale,
					position.X.Offset,
					position.Y.Scale + v8,
					position.Y.Offset
				)
			end)
			table.insert(heartbeatConnections, heartbeatConnection2)
		end

		for _, label in pairs(cloud:GetDescendants()) do
			if not (label:IsA("TextLabel") and label.Name == "Plus") then
				continue
			end

			label.TextTransparency = 1
			local uIStroke = label:FindFirstChild("UIStroke")

			if uIStroke then
				uIStroke.Transparency = 1
			end
		end

		StartCloudLoop(cloud)
		CauldronClient.FadeIn()
	end
end

Client.Events.HalloweenBoxPlanted:Connect(function(childName)
	local child = Client.Interface.CauldronList.Plantable:FindFirstChild(childName)

	if not child then
		return
	end

	child.TickLabel.Tick.Visible = true
end)
local v7 = {}

function AllComplete()
	task.spawn(function()
		for _ = 1, 1 do
			CauldronClient.PlayFlare(1, Color3.fromRGB(255, 128, 0))
			CauldronClient.PlayFlare(2, Color3.fromRGB(255, 128, 0))
			CauldronClient.PlayFlare(3, Color3.fromRGB(255, 128, 0))
			v.Main.CookingDone:Play()
			v.Main.HalloweenTreat:Play()
			wait(0.8)
		end

		CauldronClient.FadeOut()
		DoCooking(v, 2)
		wait(12)
		CauldronClient.FadeIn()
		v.Main.Transition:Play()
	end)
end

function RefreshIngredients(p, instance)
	if not instance or not instance.Parent or instance.Parent ~= p.Functional.Recipe then
		return
	end

	local spot = instance:GetAttribute("Spot") or table.find(v7[p], instance.Name)

	if not table.find(v7[p], instance.Name) then
		table.insert(v7[p], instance.Name)
		spot = table.find(v7[p], instance.Name)
	end

	if not spot or spot > 3 then
		return
	end

	local name = instance.Name
	local added = instance:GetAttribute("Added") or 0
	local required = instance:GetAttribute("Required") or 1
	local alreadyDone = instance:GetAttribute("AlreadyDone") or false
	local billboardGui = p.Main.BillboardGui

	if not billboardGui then
		return
	end

	local child = billboardGui.Cauldron.Cloud:FindFirstChild("Ingredient" .. spot)

	if not child then
		return
	end

	if required <= added and not alreadyDone then
		instance:SetAttribute("AlreadyDone", true)
		child.Quantity.Visible = false
		task.spawn(function()
			wait(0.15)

			if not p.Functional.Recipe:GetAttribute("Complete") then
				CauldronClient.PlayFlare(spot)
			end
		end)
	elseif not alreadyDone then
		local v8 = required - added

		if v8 == 1 then
			child.Quantity.Visible = false
		else
			child.Quantity.Text = "x" .. v8
			child.Quantity.Visible = true
		end
	end

	if Client.Databases.FairyPlants[v4[name] or name] and Client.Databases.FairyPlants[v4[name] or name].Ingredient then
		child.Image = Client.Databases.FairyPlants[v4[name] or name].Ingredient
	end

	if instance:GetAttribute("AlreadyDone") then
		child.ImageColor3 = Color3.fromRGB(0, 255, 0)
		child.Tick.Visible = true
	else
		child.ImageColor3 = Color3.fromRGB(255, 255, 255)
		child.Tick.Visible = false
	end

	for _, v8 in pairs(frames) do
		local flag = false

		for _, v9 in pairs(v7[p]) do
			if v9 == v8.Name or v4[v9] and v4[v9] == v8.Name then
				flag = true
			end
		end

		if flag then
			v8.BackgroundColor3 = Color3.fromRGB(17, 255, 0)
			v8.BackgroundTransparency = 0.5
		else
			v8.BackgroundTransparency = 1
		end
	end
end

function SetUpFolders(instance)
	local recipe = instance:WaitForChild("Functional"):WaitForChild("Recipe")
	recipe.AttributeChanged:Connect(function(p)
		if p == "Complete" and recipe:GetAttribute("Complete") then
			AllComplete()
		end
	end)

	for _, folder in pairs(recipe:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local v8 = folder
		folder.AttributeChanged:Connect(function()
			RefreshIngredients(instance, v8)
		end)
		RefreshIngredients(instance, folder)
	end

	recipe.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") then
			folder.AttributeChanged:Connect(function()
				RefreshIngredients(instance, folder)
			end)
			RefreshIngredients(instance, folder)
		end
	end)
	recipe.ChildRemoved:Connect(function(folder)
		if folder:IsA("Folder") then
			removeTable(v7[instance], folder.Name)
			RefreshIngredients(instance, folder)
		end
	end)
end

function DissolveItem(p, instance)
	if instance:GetAttribute("InCauldron") or not instance.Parent then
		return
	end

	local name = instance.Name

	if string.sub(name, 1, 7) == "Cooked " then
		name = string.sub(name, 8)
	end

	task.spawn(function()
		if p.Functional.Recipe:FindFirstChild(name) then
			AnimateCauldron(p, instance)
		else
			DoExplosion(p)
		end
	end)
	instance.Archivable = true
	local clone = instance:Clone()
	instance:SetAttribute("InCauldron", true)
	clone:SetAttribute("Destroyed", true)
	instance.Parent = game.ReplicatedStorage.TempStorage

	for k in pairs(clone:GetAttributes()) do
		clone:SetAttribute(k, nil)
	end

	clone:RemoveTag("Interaction")
	local tweenInfo = TweenInfo.new(0.1)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Color = Color3.fromRGB(85, 255, 127)
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("Decal") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.1, function()
		clone:Destroy()
	end)
	clone.Parent = workspace.Particles
	return function()
		task.delay(1, function()
			if instance.Parent then
				instance:SetAttribute("InCauldron", nil)
				instance.Parent = workspace.Items
			end
		end)
	end
end

Client.Events.DissolveItemInCauldron:Connect(function(p, p2, p3: number)
	DissolveItem(p2, p)

	if p3 then
		RecolourCauldron(p2, p3)
	end
end)

function RecolourCauldron(p, p2: number)
	local color = Color3.fromHSV(p2, 1, 1)
	p.Functional.Liquid.Color = color
end

function PlayerEnterCauldron(p)
	Client.Events.PlayerEnteredCauldron:FireServer()

	if p.Main:FindFirstChild("Splosh") then
		task.spawn(function()
			local clone = p.Main:FindFirstChild("Splosh"):Clone()
			clone.Name = "ClonedSound"
			clone.Parent = p.Main
			clone:Play()
			wait(4.5)

			if clone then
				clone:Destroy()
			end
		end)
	end

	local particlesDefault = p.Functional:FindFirstChild("ParticlesDefault")

	if particlesDefault then
		Client.Utility.RunParticles(particlesDefault)
	end
end

function CauldronClient.ToggleBook()
	Client.Sound.Play("PageTurn")
	local cauldronList = Client.Interface.CauldronList
	cauldronList.Visible = not cauldronList.Visible
end

function CauldronAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	v = instance
	v7[instance] = {}
	local v8 = 0
	local functional = instance:WaitForChild("Functional")
	functional:WaitForChild("Liquid")
	local itemTouchPart = functional:WaitForChild("ItemTouchPart")
	SetUpBillboard(instance)
	itemTouchPart.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not (parent and parent.Parent == workspace.Items) then
			return
		end

		local interaction = parent:GetAttribute("Interaction")

		if interaction == "Tool" then
			return
		end

		local v9 = interaction and DissolveItem(instance, parent)

		if v9 then
			local name = parent.Name

			if string.sub(name, 1, 7) == "Cooked " then
				name = string.sub(name, 8)
			end

			local v10

			if instance.Functional.Recipe:FindFirstChild(name) then
				v10 = random:NextNumber()
				RecolourCauldron(instance, v10)
			end

			local v11 = Client.Events.RequestPutItemInCauldron:InvokeServer(parent, instance, v10)

			if not (v11 and v11.Success) then
				v9()
			end
		end
	end)
	functional:WaitForChild("PlayerTouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent or (parent ~= localPlayer.Character or not (time() - v8 > 1)) then
			return
		end

		v8 = time()
		PlayerEnterCauldron(instance)
	end)
	task.spawn(function()
		SetUpFolders(instance)
	end)
	task.spawn(function()
		local v9 = {}

		for _, v10 in pairs(v2) do
			table.insert(v9, v10)
		end

		for _, v10 in pairs(v3) do
			table.insert(v9, v10)
		end

		UtilityAlec.preload(v9)
	end)
end

function CauldronClient.Init()
	local cauldronList = Client.Interface.CauldronList

	for _, frame in pairs(cauldronList.Plantable:GetChildren()) do
		if frame:IsA("Frame") then
			table.insert(frames, frame)
		end
	end

	for _, frame in pairs(cauldronList.NotPlantable:GetChildren()) do
		if frame:IsA("Frame") then
			table.insert(frames, frame)
		end
	end

	cauldronList.CloseButton.Activated:Connect(function()
		cauldronList.Visible = false
		Client.Sound.Play("CloseButton")
	end)
	Client.Utility.ForAllTagged("HalloweenCauldron", CauldronAdded)
end

return CauldronClient