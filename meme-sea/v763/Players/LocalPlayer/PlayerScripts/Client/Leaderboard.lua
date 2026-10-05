local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local assets = ReplicatedStorage:WaitForChild("Assets")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local nPC_Storage = ReplicatedStorage:WaitForChild("NPC_Storage")
local nPCs = workspace:WaitForChild("NPCs")
local island = workspace:WaitForChild("Island")
local leaderboard = workspace:WaitForChild("Leaderboard")
local floppaIsland = island:WaitForChild("FloppaIsland")
local dummies = leaderboard:WaitForChild("Dummies")
local dummies2 = assets:WaitForChild("Dummies")
local leaderboard_Dummy = assets:WaitForChild("Leaderboard_Dummy")
local location = leaderboard:WaitForChild("Location")
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
require(moduleScript:WaitForChild("Generate"))
local leaderboard2 = otherEvent.MainEvents:WaitForChild("Leaderboard")
local dummyBounty = dummies2:WaitForChild("DummyBounty")
local dummyGem = dummies2:WaitForChild("DummyGem")
local dummyMoney = dummies2:WaitForChild("DummyMoney")
local dummyHonor = dummies2:WaitForChild("DummyHonor")
local leaderboardTemplate = guiTemplate:WaitForChild("LeaderboardTemplate")
local money = workspace.Leaderboard.Money
local gem = workspace.Leaderboard.Gem
local bounty = workspace.Leaderboard.Bounty
local honor = workspace.Leaderboard.Honor
local pop = workspace.Leaderboard.Pop
local selectors = {}
table.insert(selectors, money.Model.ScoreBlock.SurfaceGui.Selector)
table.insert(selectors, gem.Model.ScoreBlock.SurfaceGui.Selector)
table.insert(selectors, bounty.Model.ScoreBlock.SurfaceGui.Selector)
table.insert(selectors, honor.Model.ScoreBlock.SurfaceGui.Selector)
table.insert(selectors, pop.Model.ScoreBlock.SurfaceGui.Selector)
local country = localPlayer:WaitForChild("PlayerData", 60):WaitForChild("Country")
local children = {}
local clones = {}

for _, child in ipairs(animation_Folder.Leaderbaord:GetChildren()) do
	if not table.find(children, child) then
		table.insert(children, child)
	end
end

local v = {
	Bounty = Color3.fromRGB(190, 32, 32),
	Gem = Color3.fromRGB(159, 27, 235),
	Money = Color3.fromRGB(92, 213, 48),
	Honor = Color3.fromRGB(36, 141, 250),
	Pop = Color3.fromRGB(205, 122, 241)
}

function GetItemFrame(childName, childName2)
	local child = workspace.Leaderboard:FindFirstChild(childName).Model.ScoreBlock.SurfaceGui.Frame.List.ListContent:FindFirstChild(childName2)

	if child then
		return child
	end
end

function MakeList(childName)
	local child = workspace.Leaderboard:FindFirstChild(childName)
	local showing = child.Model.ScoreBlock.SurfaceGui.Selector:GetAttribute("Showing") or "Global"
	local v2 = child.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent[showing]
	child.Model.ScoreBlock.SurfaceGui.Frame.List.CanvasSize = UDim2.new(0, 0, 0, v2.UIListLayout.AbsoluteContentSize.Y)

	if #v2:GetChildren() > 6 and v2.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Top then
		v2.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	elseif #v2:GetChildren() <= 6 and v2.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
		v2.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckAlive_Character(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCollisionGroup(part)
	if part:IsA("BasePart") then
		part.CollisionGroup = "Player"
	end
end

local setCollisionGroupRecursive

setCollisionGroupRecursive = function(child)
	setCollisionGroup(child) -- equivalent call inferred; original call site unknown

	for _, child2 in ipairs(child:GetChildren()) do
		setCollisionGroupRecursive(child2)
	end
end

local function resetCollisionGroup(part)
	if part and part:IsA("BasePart") then
		part.CollisionGroup = "Default"
	end
end

function DisableCollide(instance)
	setCollisionGroup(instance) -- equivalent call inferred; original call site unknown

	for _, child in ipairs(instance:GetChildren()) do
		setCollisionGroupRecursive(child)
	end

	instance.DescendantAdded:Connect(setCollisionGroup)
	instance.DescendantRemoving:Connect(resetCollisionGroup)
end

function AddVelocity(instance)
	for _, part in ipairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part == instance.PrimaryPart then
			part.CanCollide = false
			part.Anchored = true
		else
			local bodyPosition = Instance.new("BodyPosition", part)
			bodyPosition.Position = part.Position
			bodyPosition.MaxForce = createVector(1e999, 1e999, 1e999)
			local bodyGyro = Instance.new("BodyGyro", part)
			bodyGyro.CFrame = part.CFrame
			bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
			part.CanCollide = false
			part.Anchored = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayAnimation_Dummy(humanoid)
	local animator = humanoid and humanoid:FindFirstChild("Animator")

	if animator then
		local track = animator:LoadAnimation(children[math.random(1, #children)])

		if not track.IsPlaying then
			track:Play()
		end
	end
end

function Setup_TopPlayers(p, p2, p3)
	if p == 1 or p == "1" then
		local key = tostring(p2.key)
		local child = dummies:FindFirstChild((`Dummy{p3}`))
		local dummy1 = child and child:FindFirstChild("Dummy1")

		if dummy1 then
			local humanoid = dummy1:FindFirstChild("Humanoid")

			if key and humanoid then
				local humanoidDescriptionFromUserId = nil
				local nameFromUserIdAsync = nil
				local success, result = pcall(function()
					humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(key)
					nameFromUserIdAsync = Players:GetNameFromUserIdAsync(key)
				end)
				PlayAnimation_Dummy(humanoid) -- equivalent call inferred; original call site unknown

				if success then
					if humanoidDescriptionFromUserId then
						humanoid:ApplyDescription(humanoidDescriptionFromUserId)
					end

					if nameFromUserIdAsync then
						if dummy1.Head:FindFirstChild("First") == nil then
							local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("First"):Clone()
							clone.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Parent = dummy1.Head
							clone.Enabled = true
						else
							local first = dummy1.Head:FindFirstChild("First") and dummy1.Head:FindFirstChild("First")

							if first then
								first.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
								first.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							end
						end
					elseif dummy1.Head:FindFirstChild("First") == nil then
						local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("First"):Clone()
						clone.Textlabel.Text = `[#{p}] - {key}`
						clone.Textlabel.Stroke.Text = `[#{p}] - {key}`
						clone.Parent = dummy1.Head
						clone.Enabled = true
					else
						local first = dummy1.Head:FindFirstChild("First") and dummy1.Head:FindFirstChild("First")

						if first then
							first.Textlabel.Text = `[#{p}] - {key}`
							first.Textlabel.Stroke.Text = `[#{p}] - {key}`
						end
					end
				else
					warn(result)
				end
			end
		end
	elseif p == 2 or p == "2" then
		local key = tostring(p2.key)
		local child = dummies:FindFirstChild((`Dummy{p3}`))
		local dummy2 = child and child:FindFirstChild("Dummy2")

		if dummy2 then
			local humanoid = dummy2:FindFirstChild("Humanoid")

			if key and humanoid then
				local humanoidDescriptionFromUserId = nil
				local nameFromUserIdAsync = nil
				local success, result = pcall(function()
					humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(key)
					nameFromUserIdAsync = Players:GetNameFromUserIdAsync(key)
				end)
				PlayAnimation_Dummy(humanoid) -- equivalent call inferred; original call site unknown

				if success then
					if humanoidDescriptionFromUserId then
						humanoid:ApplyDescription(humanoidDescriptionFromUserId)
					end

					if nameFromUserIdAsync then
						if dummy2.Head:FindFirstChild("Second") == nil then
							local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("Second"):Clone()
							clone.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Parent = dummy2.Head
							clone.Enabled = true
						else
							local second = dummy2.Head:FindFirstChild("Second") and dummy2.Head:FindFirstChild("Second")

							if second then
								second.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
								second.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							end
						end
					elseif dummy2.Head:FindFirstChild("Second") == nil then
						local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("Second"):Clone()
						clone.Textlabel.Text = `[#{p}] - {key}`
						clone.Textlabel.Stroke.Text = `[#{p}] - {key}`
						clone.Parent = dummy2.Head
						clone.Enabled = true
					else
						local second = dummy2.Head:FindFirstChild("Second") and dummy2.Head:FindFirstChild("Second")

						if second then
							second.Textlabel.Text = `[#{p}] - {key}`
							second.Textlabel.Stroke.Text = `[#{p}] - {key}`
						end
					end
				else
					warn(result)
				end
			end
		end
	elseif p == 3 or p == "3" then
		local key = tostring(p2.key)
		local child = dummies:FindFirstChild((`Dummy{p3}`))
		local dummy3 = child and child:FindFirstChild("Dummy3")

		if dummy3 then
			local humanoid = dummy3:FindFirstChild("Humanoid")

			if key and humanoid then
				local humanoidDescriptionFromUserId = nil
				local nameFromUserIdAsync = nil
				local success, result = pcall(function()
					humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(key)
					nameFromUserIdAsync = Players:GetNameFromUserIdAsync(key)
				end)
				PlayAnimation_Dummy(humanoid) -- equivalent call inferred; original call site unknown

				if success then
					if humanoidDescriptionFromUserId then
						humanoid:ApplyDescription(humanoidDescriptionFromUserId)
					end

					if nameFromUserIdAsync then
						if dummy3.Head:FindFirstChild("Third") == nil then
							local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("Third"):Clone()
							clone.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							clone.Parent = dummy3.Head
							clone.Enabled = true
						else
							local third = dummy3.Head:FindFirstChild("Third") and dummy3.Head:FindFirstChild("Third")

							if third then
								third.Textlabel.Text = `[#{p}] - {nameFromUserIdAsync}`
								third.Textlabel.Stroke.Text = `[#{p}] - {nameFromUserIdAsync}`
							end
						end
					elseif dummy3.Head:FindFirstChild("Third") == nil then
						local clone = ReplicatedStorage.GuiTemplate:FindFirstChild("Third"):Clone()
						clone.Textlabel.Text = `[#{p}] - {key}`
						clone.Textlabel.Stroke.Text = `[#{p}] - {key}`
						clone.Parent = dummy3.Head
						clone.Enabled = true
					else
						local third = dummy3.Head:FindFirstChild("Third") and dummy3.Head:FindFirstChild("Third")

						if third then
							third.Textlabel.Text = `[#{p}] - {key}`
							third.Textlabel.Stroke.Text = `[#{p}] - {key}`
						end
					end
				else
					warn(result)
				end
			end
		end
	end
end

function Clearboard(p: string)
	if p == "Global" then
		for _, image in ipairs(money.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(gem.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(bounty.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(honor.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(pop.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end
	else
		for _, image in ipairs(money.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(gem.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(bounty.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(honor.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end

		for _, image in ipairs(pop.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end
	end
end

function Setup_Distance()
	local tagged = CollectionService:GetTagged("NPC")

	for _, v2 in ipairs(tagged) do
		if not (v2 and v2.Parent) then
			continue
		end

		v2:SetAttribute("Old_Parent", v2.Parent.Name)
		v2:SetAttribute("LastTime", os.time())
	end

	local tagged2 = CollectionService:GetTagged("Power_Model")

	for _, v2 in ipairs(tagged2) do
		if not (v2 and v2.Parent) then
			continue
		end

		v2:SetAttribute("Old_Parent", v2.Parent.Parent.Name)
		v2:SetAttribute("LastTime", os.time())
	end

	while task.wait(3) do
		if NPC_InRange(location, 500) then
			for _, v2 in ipairs(clones) do
				if v2.Parent == dummies then
					continue
				end

				v2.Parent = dummies

				if #leaderboard_Dummy:GetChildren() == 0 then
					script:SetAttribute("LastTime", os.time())
				end
			end
		else
			for _, v2 in ipairs(clones) do
				if not (v2.Parent ~= leaderboard_Dummy and os.time() - script:GetAttribute("LastTime") >= 30) then
					continue
				end

				v2.Parent = leaderboard_Dummy

				if #dummies:GetChildren() == 0 then
					script:SetAttribute("LastTime", os.time())
				end
			end
		end

		local tagged3 = CollectionService:GetTagged("NPC")

		for _, v2 in ipairs(tagged3) do
			if NPC_InRange(v2.PrimaryPart, 1500) then
				if not v2:IsDescendantOf(nPCs) then
					v2.Parent = nPCs:FindFirstChild(v2:GetAttribute("Old_Parent")) or nPCs
					v2:SetAttribute("LastTime", os.time())
				end
			elseif v2:IsDescendantOf(nPCs) and os.time() - v2:GetAttribute("LastTime") >= 30 and CheckAlive_Character(localPlayer.Character) then
				v2.Parent = nPC_Storage
				v2:SetAttribute("LastTime", os.time())
			end
		end

		local tagged4 = CollectionService:GetTagged("Power_Model")

		for _, v2 in ipairs(tagged4) do
			if NPC_InRange(v2, 1000) then
				if not v2:IsDescendantOf(floppaIsland) then
					v2.Parent = floppaIsland:FindFirstChild(v2:GetAttribute("Old_Parent")).Powers or floppaIsland
					v2:SetAttribute("LastTime", os.time())
				end
			elseif v2:IsDescendantOf(floppaIsland) and os.time() - v2:GetAttribute("LastTime") >= 30 and CheckAlive_Character(localPlayer.Character) then
				v2.Parent = nPC_Storage
				v2:SetAttribute("LastTime", os.time())
			end
		end
	end
end

function NPC_InRange(instance, p: number)
	if instance and instance.Parent then
		if instance:IsA("Model") then
			local primaryPart = instance.PrimaryPart

			if primaryPart and (currentCamera.CFrame.Position - primaryPart.Position).Magnitude <= p then
				return true
			end
		elseif instance:IsA("BasePart") and (currentCamera.CFrame.Position - instance.Position).Magnitude <= p then
			return true
		end
	end
end

function SetUpDummy()
	script:SetAttribute("LastTime", os.time())
	local clone = dummyMoney:Clone()
	clone.Parent = dummies

	if not table.find(clones, clone) then
		table.insert(clones, clone)
	end

	local clone2 = dummyGem:Clone()
	clone2.Parent = dummies

	if not table.find(clones, clone2) then
		table.insert(clones, clone2)
	end

	local clone3 = dummyBounty:Clone()
	clone3.Parent = dummies

	if not table.find(clones, clone3) then
		table.insert(clones, clone3)
	end

	local clone4 = dummyHonor:Clone()
	clone4.Parent = dummies

	if not table.find(clones, clone4) then
		table.insert(clones, clone4)
	end

	for _, child in ipairs(clone:GetChildren()) do
		DisableCollide(child)
		AddVelocity(child)
	end

	for _, child in ipairs(clone2:GetChildren()) do
		DisableCollide(child)
		AddVelocity(child)
	end

	for _, child in ipairs(clone3:GetChildren()) do
		DisableCollide(child)
		AddVelocity(child)
	end

	for _, child in ipairs(clone4:GetChildren()) do
		DisableCollide(child)
		AddVelocity(child)
	end
end

function SetUpPage(list, p, p2, p3)
	for i, v2 in ipairs(list) do
		local key = v2.key
		local value = v2.value
		local nameFromUserIdAsync = nil
		local success, _ = pcall(function()
			nameFromUserIdAsync = Players:GetNameFromUserIdAsync(key)
		end)

		if not (value > 0) then
			continue
		end

		local clone = leaderboardTemplate:Clone()
		clone.LayoutOrder = i
		clone.Frame.Top.Value = tonumber(i)
		clone.Frame.Number.Text = i .. ")"

		if p == "Pop" then
			clone.Frame.Value.Text = Abbreviate.Comma(value)
		else
			clone.Frame.Value.Text = Abbreviate.ShowNum(value)
		end

		if success and nameFromUserIdAsync then
			clone.Name = nameFromUserIdAsync

			if p2 == "Country" then
				clone.Frame.Username.Text = `{nameFromUserIdAsync} {country.Value}`
			elseif p2 == "Global" then
				if p3 and p3[key] then
					clone.Frame.Username.Text = `{nameFromUserIdAsync} {p3[key]}`
				else
					clone.Frame.Username.Text = `{nameFromUserIdAsync} 🇺🇸`
				end
			else
				clone.Frame.Username.Text = `{nameFromUserIdAsync} 🇺🇸`
			end
		else
			if p2 == "Country" then
				clone.Frame.Username.Text = `UserId = {key} {country.Value}`
			elseif p2 == "Global" then
				if p3 and p3[key] then
					clone.Frame.Username.Text = `UserId = {key} {p3[key]}`
				else
					clone.Frame.Username.Text = `UserId = {key} 🇺🇸`
				end
			else
				clone.Frame.Username.Text = `UserId = {key} 🇺🇸`
			end

			clone.Name = key
		end

		clone.Parent = GetItemFrame(p, p2)
		MakeList(p)

		if p2 == "Global" and p ~= "Pop" and (i == 1 or i == 2 or i == 3) then
			Setup_TopPlayers(i, v2, p)
		end
	end
end

function PageChanged(instance)
	if instance:GetAttribute("Showing") == "Country" then
		instance.Country.BackgroundColor3 = v[instance.Parent.Parent.Parent.Parent.Name]
		instance.Country.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		instance.Global.BackgroundColor3 = Color3.fromRGB(225, 242, 238)
		instance.Global.TextLabel.TextColor3 = v[instance.Parent.Parent.Parent.Parent.Name]
		instance.Parent.Frame.List.ListContent.Global.Visible = false
		instance.Parent.Frame.List.ListContent.Country.Visible = true
		local parent = instance.Parent.Parent.Parent.Parent
		local country2 = parent.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Country
		parent.Model.ScoreBlock.SurfaceGui.Frame.List.CanvasSize = UDim2.new(
			0,
			0,
			0,
			country2.UIListLayout.AbsoluteContentSize.Y
		)

		if #country2:GetChildren() > 6 and country2.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Top then
			country2.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		elseif #country2:GetChildren() <= 6 and country2.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
			country2.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end
	elseif instance:GetAttribute("Showing") == "Global" then
		instance.Global.BackgroundColor3 = v[instance.Parent.Parent.Parent.Parent.Name]
		instance.Global.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		instance.Country.BackgroundColor3 = Color3.fromRGB(225, 242, 238)
		instance.Country.TextLabel.TextColor3 = v[instance.Parent.Parent.Parent.Parent.Name]
		instance.Parent.Frame.List.ListContent.Country.Visible = false
		instance.Parent.Frame.List.ListContent.Global.Visible = true
		local parent = instance.Parent.Parent.Parent.Parent
		local global = parent.Model.ScoreBlock.SurfaceGui.Frame.List.ListContent.Global
		parent.Model.ScoreBlock.SurfaceGui.Frame.List.CanvasSize = UDim2.new(
			0,
			0,
			0,
			global.UIListLayout.AbsoluteContentSize.Y
		)

		if #global:GetChildren() > 6 and global.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Top then
			global.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		elseif #global:GetChildren() <= 6 and global.UIListLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
			global.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end
	end
end

SetUpDummy()
leaderboard2.OnClientEvent:Connect(function(data)
	local global_Money = data.Global_Money
	local global_Gem = data.Global_Gem
	local global_Bounty = data.Global_Bounty
	local global_Honor = data.Global_Honor
	local global_Pop = data.Global_Pop
	local country_Money = data.Country_Money
	local country_Gem = data.Country_Gem
	local country_Bounty = data.Country_Bounty
	local country_Honor = data.Country_Honor
	local country_Pop = data.Country_Pop
	local country_Data = data.Country_Data

	if global_Money and global_Gem and global_Bounty and global_Honor and global_Pop then
		Clearboard("Global")
		SetUpPage(global_Money, "Money", "Global", country_Data)
		SetUpPage(global_Gem, "Gem", "Global", country_Data)
		SetUpPage(global_Bounty, "Bounty", "Global", country_Data)
		SetUpPage(global_Honor, "Honor", "Global", country_Data)
		SetUpPage(global_Pop, "Pop", "Global", country_Data)
	end

	if country_Money and country_Gem and country_Bounty and country_Honor and country_Pop then
		Clearboard("Country")
		SetUpPage(country_Money, "Money", "Country")
		SetUpPage(country_Gem, "Gem", "Country")
		SetUpPage(country_Bounty, "Bounty", "Country")
		SetUpPage(country_Honor, "Honor", "Country")
		SetUpPage(country_Pop, "Pop", "Country")
	end
end)

for _, frame in ipairs(selectors) do
	if not frame:IsA("Frame") then
		continue
	end

	local v2 = frame
	frame:GetAttributeChangedSignal("Showing"):Connect(function()
		PageChanged(v2)
	end)

	for _, button in ipairs(frame:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		local v3 = frame
		local v4 = button
		button.Activated:Connect(function()
			v3:SetAttribute("Showing", v4.Name)
		end)
	end
end

task.spawn(Setup_Distance)