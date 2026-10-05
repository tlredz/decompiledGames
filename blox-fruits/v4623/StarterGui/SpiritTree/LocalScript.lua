local v = {
	Rip = {
		Image = "rbxassetid://118983292018902",
		Gradient = script.Parent.BarContainer.TopProgress.Bar.UIGradient.Color,
		Glint = script.Parent.BarContainer.TopProgress.Bar.ImageLabel.ImageColor3,
		Flat = Color3.fromRGB(165, 62, 255)
	},
	Red = {
		Image = "rbxassetid://113072026424771",
		Gradient = script.Parent.BarContainer.BottomProgress.Bar.UIGradient.Color,
		Glint = script.Parent.BarContainer.BottomProgress.Bar.ImageLabel.ImageColor3,
		Flat = Color3.fromRGB(221, 0, 4)
	}
}
local spiritTree = game.ReplicatedStorage.Remotes:WaitForChild("SpiritTree", 999999)
local ripEventBillboard = workspace.RipEventBillboard
local redEventBillboard = workspace.RedEventBillboard
local numberValue = Instance.new("NumberValue")
local v2 = script.Parent.BarContainer.AbsoluteSize.Y + 4
local GuiService = game:GetService("GuiService")
numberValue.Value = v2 - GuiService:GetGuiInset().Y
script.Parent.BarContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	local v3 = numberValue
	local v4 = script.Parent.BarContainer.AbsoluteSize.Y + 4
	local GuiService2 = game:GetService("GuiService")
	v3.Value = v4 - GuiService2:GetGuiInset().Y
end)
script.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if script.Parent.Enabled then
		numberValue.Parent = game.ReplicatedStorage.Notification
	else
		numberValue.Parent = nil
	end
end)
ripEventBillboard.BillboardGui.Enabled = false
redEventBillboard.BillboardGui.Enabled = false
pcall(workspace.Destroy, workspace.Map["Oni Realm"]:FindFirstChild("BillboardGui", true))
pcall(workspace.Destroy, workspace.Map["Celestial Domain"]:FindFirstChild("BillboardGui", true))
local v3 = {}
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
local v4 = {
	"NextRegistration",
	"NextStart",
	"NextEnd",
	"RegistrationEnabled",
	"EventActive"
}

local function UpdateSTATE()
	if spiritTree:GetAttribute("EventActive") == nil then
		return
	end

	local color = Color3.fromRGB(0, 0, 0)
	local color2 = Color3.fromRGB(255, 255, 255)
	local v5 = v[spiritTree:GetAttribute("Faction")]
	local v6 = v[spiritTree:GetAttribute("Faction") == "Red" and "Rip" or "Red"]
	script.Parent.BarContainer.TopProgress.Bar.UIGradient.Color = v5.Gradient
	script.Parent.BarContainer.TopProgress.Bar.ImageLabel.ImageColor3 = v5.Glint
	script.Parent.BarContainer.Background.Image = v5.Image
	script.Parent.BarContainer.BottomProgress.Bar.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, v6.Flat:Lerp(color, 0.7)),
		ColorSequenceKeypoint.new(0.098, v6.Flat:Lerp(color, 0.5)),
		ColorSequenceKeypoint.new(0.208, v6.Flat:Lerp(color, 0.3)),
		ColorSequenceKeypoint.new(0.576, v6.Flat:Lerp(color, 0)),
		ColorSequenceKeypoint.new(0.612, v6.Flat:Lerp(color2, 0.1)),
		ColorSequenceKeypoint.new(0.675, v6.Flat:Lerp(color2, 0.3)),
		ColorSequenceKeypoint.new(1, v6.Flat:Lerp(color2, 0.3))
	})
	script.Parent.BarContainer.BottomProgress.TextLabel.Text = (spiritTree:GetAttribute("Faction") == "Red" and "RIP" or "RED") .. " ARMY"
	script.Parent.BarContainer.BottomProgress.Bar.ImageLabel.ImageColor3 = v6.Glint
	local attributesByAttributeName = {}

	for _, attributeName in pairs(v4) do
		attributesByAttributeName[attributeName] = spiritTree:GetAttribute(attributeName)
	end

	local v7 = v3
	v3 = attributesByAttributeName
	maid:DoCleaning()

	if not v3.EventActive then
		script.Parent.Enabled = false
		return
	end

	script.Parent.Enabled = true
	maid:GiveTask(task.spawn(function()
		while task.wait(0.03333333333333333) do
			local v8 = v3.NextEnd - os.time()
			local v9 = math.floor(v8 / 60)
			local v10 = math.floor(v8 - v9 * 60)
			script.Parent.BarContainer.TextLabel.Text = "Remaining: " .. v9 .. ":" .. (v10 < 10 and "0" or "") .. v10
		end
	end))

	local function UpdateEnemyProgress()
		local v8 = spiritTree:GetAttribute("EnemiesRemaining") / spiritTree:GetAttribute("TotalEnemies")
		local TweenService = game:GetService("TweenService")
		TweenService:Create(script.Parent.BarContainer.BottomProgress.Bar, TweenInfo.new(v7.EventActive and 0.2 or 0), {
			Position = UDim2.fromScale(v8 - 1, 0)
		}):Play()
	end

	maid:GiveTask(spiritTree:GetAttributeChangedSignal("EnemiesRemaining"):Connect(UpdateEnemyProgress))
	UpdateEnemyProgress()
	v7.EventActive = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatSeconds(p)
	local v5 = math.floor(p / 60)
	local v6 = p % 60
	return string.format("%d:%02d", v5, v6)
end

local v5 = {
	Rip = false,
	Red = false
}

local function getBBG(childName)
	local child = workspace.NPCs:FindFirstChild(childName)
	local questBBG = child and child:FindFirstChild("HumanoidRootPart") and child.HumanoidRootPart:FindFirstChild("QuestBBG")

	if questBBG then
		return questBBG
	end
end

task.spawn(function()
	while task.wait(0.05) do
		if not v5.Rip then
			local v6 = v5
			local ripFamilyRecruiter = workspace.NPCs:FindFirstChild("Rip Family Recruiter")
			v6.Rip = ripFamilyRecruiter and ripFamilyRecruiter:FindFirstChild("HumanoidRootPart") and ripFamilyRecruiter.HumanoidRootPart:FindFirstChild("QuestBBG") or nil
		end

		if not v5.Red then
			local v6 = v5
			local redArmyRecruiter = workspace.NPCs:FindFirstChild("Red Army Recruiter")
			v6.Red = redArmyRecruiter and redArmyRecruiter:FindFirstChild("HumanoidRootPart") and redArmyRecruiter.HumanoidRootPart:FindFirstChild("QuestBBG") or nil
		end

		if spiritTree:GetAttribute("EventActive") then
			redEventBillboard.BillboardGui.Enabled = false
			ripEventBillboard.BillboardGui.Enabled = false

			if v5.Rip then
				v5.Rip.Enabled = true
			end

			if v5.Red then
				v5.Red.Enabled = true
			end
		elseif spiritTree:GetAttribute("NextStart") then
			local v6 = math.round(spiritTree:GetAttribute("NextStart") - os.time())
			local textLabel = ripEventBillboard.BillboardGui.TextLabel
			textLabel.Text = FormatSeconds(v6)
			local textLabel2 = redEventBillboard.BillboardGui.TextLabel
			textLabel2.Text = FormatSeconds(v6)
			redEventBillboard.BillboardGui.Enabled = spiritTree:GetAttribute("Faction") == "Red"
			ripEventBillboard.BillboardGui.Enabled = not redEventBillboard.BillboardGui.Enabled

			if v5.Red then
				v5.Red.Enabled = ripEventBillboard.BillboardGui.Enabled
			end

			if v5.Rip then
				v5.Rip.Enabled = redEventBillboard.BillboardGui.Enabled
			end
		end
	end
end)
spiritTree:GetAttributeChangedSignal("TreeHealth"):Connect(function()
	local treeHealth = spiritTree:GetAttribute("TreeHealth")
	local TweenService = game:GetService("TweenService")
	TweenService:Create(script.Parent.BarContainer.TopProgress.Bar, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(treeHealth - 1, 0)
	}):Play()
end)

for _, v6 in pairs(v4) do
	spiritTree:GetAttributeChangedSignal(v6):Connect(UpdateSTATE)
end

if spiritTree:GetAttribute("EventActive") ~= nil then
	UpdateSTATE()
end

local function ShakeModel(child, p: number, p2: number)
	if not child.PrimaryPart then
		for _, part in pairs(child:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			child.PrimaryPart = part
			break
		end
	end

	local primaryPart = child.PrimaryPart
	local cFrame = primaryPart.CFrame
	local total = 0
	task.spawn(function()
		while total < p2 do
			total += task.wait(0.06666666666666667)
			local v6 = p * (1 - total / p2)
			child:SetPrimaryPartCFrame(cFrame + Vector3.new(
				(math.random() - 0.5) * 2 * v6,
				0,
				(math.random() - 0.5) * 2 * v6
			))
		end

		primaryPart.CFrame = cFrame
	end)
end

local healthChangedConnection = nil

local function MonitorTree(spiritTree2)
	if not (spiritTree2 and spiritTree2.Name == "Spirit Tree") then
		return
	end

	if healthChangedConnection then
		healthChangedConnection:Disconnect()
		healthChangedConnection = nil
	end

	local humanoid = spiritTree2:WaitForChild("Humanoid", 5)

	if not humanoid then
		return
	end

	local now = os.clock()
	local health = humanoid.Health

	local function UpdateHealth()
		if humanoid.Health < health and now < os.clock() then
			local v6 = {
				"03",
				"08",
				"11",
				"12",
				"23"
			}
			local Sound = require(game.ReplicatedStorage.Util.Sound)
			Sound:Play("BF_TreeFight_Tree_Damage_" .. v6[math.random(1, #v6)], spiritTree2.PrimaryPart.CFrame, 30, 1, 3)
			now = os.clock() + 0.3
			local v7 = (spiritTree:GetAttribute("Faction") == "Red" and "Red" or "Rip") .. "Tree"

			for _, child in pairs(workspace.Map:GetChildren()) do
				if child.Name == v7 then
					ShakeModel(child, 3, 0.2)
				end
			end
		end

		health = humanoid.Health
	end

	UpdateHealth()
	healthChangedConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health == 0 then
			healthChangedConnection:Disconnect()
			healthChangedConnection = nil
		end

		UpdateHealth()
	end)
end

workspace:WaitForChild("Enemies").ChildAdded:Connect(MonitorTree)
MonitorTree(workspace.Enemies:FindFirstChild("Spirit Tree"))
local children = { workspace.Map["Oni Realm"], workspace.Map["Celestial Domain"] }

for _, child in pairs(workspace.Map:GetChildren()) do
	if child.Name == "RedTree" or child.Name == "RipTree" then
		table.insert(children, child)
	end
end

for _, folder in pairs(children) do
	local Maid2 = require(game.ReplicatedStorage.Util.Maid)
	local v6 = Maid2.new()
	local v7 = {}

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local HSV, _, v8 = part.Color:ToHSV()
		v7[part] = { part.Color, Color3.fromHSV(HSV, 0, v8):Lerp(Color3.fromRGB(0, 0, 0), 0.3) }
	end

	local thread = nil
	local v8 = 1

	local function Desaturate(p)
		local v10 = p and 1 or 0
		local v11 = p and 1 or -1

		if v8 == v10 then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		thread = task.spawn(function()
			while v8 ~= v10 do
				v8 = math.clamp(v8 + v11 * task.wait(0.1), 0, 1)

				for k, v12 in pairs(v7) do
					k.Color = v12[2]:Lerp(v12[1], v8)
				end
			end

			thread = nil
		end)
	end

	local maid2 = v6
	local v10 = folder
	local v11 = v7
	local Desaturate2 = Desaturate

	local function UpdateState()
		maid2:DoCleaning()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v12 = nil
		local v13 = nil

		for k, min in pairs(v10:GetAttributes()) do
			if not (k:match("^GrayscaleStack%d+Min$") and typeof(min) == "number") then
				continue
			end

			local v15 = k:gsub("Min", "Max")
			local attribute = v10:GetAttribute(v15)

			if not attribute then
				return
			end

			local v16 = {
				Min = min,
				Max = attribute
			}

			if v16.Max < serverTimeNow then
				v10:SetAttribute(k, nil)
				v10:SetAttribute(v15, nil)
				return
			else
				v12 = math.min(v12 or v16.Min, v16.Min)
				v13 = math.max(v13 or v16.Max, v16.Max)
			end
		end

		if v12 then
			if v12 <= serverTimeNow then
				maid2:GiveTask(task.delay(v13 - serverTimeNow, function()
					if v8 == 1 then
						return
					end

					if thread then
						task.cancel(thread)
						thread = nil
					end

					local v14 = 1
					local v15 = 1
					thread = task.spawn(function()
						while v8 ~= v14 do
							v8 = math.clamp(v8 + v15 * task.wait(0.1), 0, 1)

							for k, v16 in pairs(v11) do
								k.Color = v16[2]:Lerp(v16[1], v8)
							end
						end

						thread = nil
					end)
				end))
				return
			end

			if v12 < 1e999 then
				maid2:GiveTask(task.delay(v12 - serverTimeNow, function()
					Desaturate2()
				end))
				return
			end
		end

		if v8 == 1 then
			return
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		local v14 = 1
		local v15 = 1
		thread = task.spawn(function()
			while v8 ~= v14 do
				v8 = math.clamp(v8 + v15 * task.wait(0.1), 0, 1)

				for k, v16 in pairs(v11) do
					k.Color = v16[2]:Lerp(v16[1], v8)
				end
			end

			thread = nil
		end)
	end

	folder.AttributeChanged:Connect(UpdateState)
	UpdateState()
end