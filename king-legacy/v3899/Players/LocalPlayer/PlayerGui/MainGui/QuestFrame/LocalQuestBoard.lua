local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
localPlayer:WaitForChild("CurrentQuest")
local QuestManager = require(ReplicatedStorage.Chest.Modules.QuestManager)
local questBoard = script.Parent.QuestBoard
local textFrame = questBoard.TextFrame
local expInfoButton = textFrame.ExpInfoButton
local expInfo = textFrame.ExpInfo
local questName = textFrame.QuestName
local questCount = textFrame.QuestCount
local battlepassExp = textFrame.Frame.BattlepassExp
local exp = textFrame.Frame.Exp
local money = textFrame.Frame.Money
local repeatFrame = script.Parent:WaitForChild("RepeatFrame")
local ProximityPromptService = game:GetService("ProximityPromptService")
local prompAlternative = script:WaitForChild("PrompAlternative")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local isTenFootInterface = GuiService:IsTenFootInterface()
local class = {}
local clonesByObj = {}
class.__index = class

function class:GetQuest()
	if self.Obj and QuestManager[self.Obj.Parent.Name] and QuestManager[self.Obj.Parent.Name].CustomPrompt then
		return { QuestManager[self.Obj.Parent.Name].Mob, QuestManager[self.Obj.Parent.Name].Ammount }
	end
end

function class:getClosetObject(p, _)
	return (p.Position - localPlayer.Character.PrimaryPart.Position).Magnitude
end

function class:Destroy()
	if self.Signal and typeof(self.Signal) == "RBXScriptConnection" then
		self.Signal:Disconnect()
		self.Signal = nil
	end

	table.clear(self)
	setmetatable(self, nil)
end

function class.Create(obj)
	if not (obj and obj.Parent) then
		return
	end

	local object = setmetatable({}, class)
	object.Obj = obj
	object.Quest = object:GetQuest() or nil

	if not object.Quest then
		return
	end

	local touchEnabled = UserInputService.TouchEnabled or nil
	local v = object.Quest[2]
	local questProgress = localPlayer:WaitForChild("QuestProgress")
	local clone = prompAlternative:Clone()
	clone.Name = obj.Parent.Name
	clone.Parent = object.Obj
	clone.Frame.Objective.Text = object.Quest[1]
	clone.Adornee = object.Obj.Parent
	clone.Enabled = true
	TweenService:Create(
		clone.Frame.Icon,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
		{
			Position = UDim2.new(0.2, 0, 0.45, 0)
		}
	):Play()
	clonesByObj[object.Obj] = clone

	if touchEnabled then
		object.Obj.Style = Enum.ProximityPromptStyle.Default
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSubGui()
		if clone and clone.Parent then
			clone.Frame.Goal.Text = `[{questProgress.Value}/{v}]`
		end

		if touchEnabled then
			object.Obj.ActionText = object.Quest[1]
			object.Obj.ObjectText = `[{questProgress.Value}/{v}]`
		end
	end

	UpdateSubGui() -- equivalent call inferred; original call site unknown
	object.Signal = questProgress.Changed:Connect(function()
		UpdateSubGui() -- equivalent call inferred; original call site unknown

		if object:getClosetObject(object.Obj.Parent, localPlayer) > 30 then
			return
		end

		clone.Enabled = false

		if touchEnabled then
			object.Obj.Style = Enum.ProximityPromptStyle.Custom
		end

		object:Destroy()
	end)
	return object
end

function CheckQuest()
	local value = localPlayer.CurrentQuest.Value

	if value == "" or not QuestManager[value] then
		if value == "" then
			questBoard.Bar.ProgressBar.Size = UDim2.new(0, 0, 1, 0)

			for _, part in pairs(workspace.SpawnItem:GetChildren()) do
				if not (part:IsA("MeshPart") or part:IsA("BasePart") and QuestManager[part.Name]) then
					continue
				end

				if part:FindFirstChild("LeePunggQuestTracker") then
					part.LeePunggQuestTracker:Destroy()
				end

				if part:IsA("MeshPart") then
					part.Transparency = 0
				end

				for _, descendant in pairs(part:GetDescendants()) do
					if descendant:IsA("Texture") or descendant:IsA("Decal") then
						descendant.Transparency = 1
					end

					if descendant:IsA("MeshPart") then
						descendant.Transparency = 0
					end
				end
			end

			if workspace.SpawnItem:FindFirstChild("Puzzle_Easy") then
				for _, descendant in pairs(workspace.SpawnItem.Puzzle_Easy:GetDescendants()) do
					if descendant:IsA("ProximityPrompt") then
						descendant.Enabled = true
					elseif descendant:IsA("BillboardGui") then
						descendant.Enabled = true
					elseif descendant:IsA("MeshPart") then
						if descendant.Name == "Puzzle" then
							descendant.Transparency = 1
						else
							if descendant.Parent:FindFirstChild("Art") and descendant.Parent.Art:IsA("BasePart") then
								descendant.Parent.Art.Transparency = 1
							end

							if descendant.Parent.Name == "Puzzle" or descendant.Parent.Parent.Name == "Puzzle" then
								descendant.Transparency = 1
							else
								descendant.Transparency = 0
							end
						end
					end
				end
			end

			for _, child in pairs(workspace.SpawnItem:GetChildren()) do
				if child:FindFirstChild("PromptQuest") then
					child.PromptQuest.Enabled = true
				end
			end

			for _, billboardGui in pairs(clonesByObj) do
				if billboardGui and billboardGui:IsA("BillboardGui") then
					billboardGui:Destroy()
				end
			end

			clonesByObj = {}

			for _, v in pairs(CollectionService:GetTagged("LoreQuest")) do
				print(v)
			end
		end

		if workspace:FindFirstChild("LeeQuestTracker") then
			workspace.LeeQuestTracker:Destroy()
		end

		questCount.Visible = false
		questBoard.Visible = false
	else
		repeatFrame.Visible = nil
		questCount.Visible = true
		questBoard.Visible = true
		battlepassExp.Visible = nil
		local value2 = localPlayer.QuestProgress.Value
		local interact = QuestManager[value].Interact or nil
		local ammount = QuestManager[value].Ammount
		local rewards = QuestManager[value].Rewards
		local value3 = localPlayer.PlayerStats.RealExpX2.Value or 1
		local value4 = localPlayer.PlayerStats.RealBeliX2.Value or 1
		local beli = rewards.beli
		local exp2 = rewards.exp
		local characterPassives = localPlayer.Character:FindFirstChild("CharacterPassives")

		if characterPassives then
			local increaseEXPDrop = characterPassives:FindFirstChild("IncreaseEXPDrop")
			local increaseMoneyDrop = characterPassives:FindFirstChild("IncreaseMoneyDrop")

			if increaseEXPDrop and increaseEXPDrop.Value > 0 then
				value3 += increaseEXPDrop.Value / 100
			end

			if increaseMoneyDrop and increaseMoneyDrop.Value > 0 then
				value4 += increaseMoneyDrop.Value / 100
			end
		end

		local v = math.floor(beli * value4)
		local v2 = math.floor(exp2 * value3)
		expInfoButton.Visible = false

		if localPlayer.PlayerStats.lvl.Value - QuestManager[value].Level > 200 then
			expInfo.QuestLevel.Text = "Quest Lvl. " .. QuestManager[value].Level
			expInfo.YourLevel.Text = "Lvl. " .. localPlayer.PlayerStats.lvl.Value
			expInfoButton.Visible = true
			v2 = 1
		end

		local v3 = value2 / QuestManager[value].Ammount
		game.TweenService:Create(
			questBoard.Bar.ProgressBar,
			TweenInfo.new(0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = UDim2.new(1 * v3, 0, 1, 0)
			}
		):Play()
		questName.Text = tostring(QuestManager[value].Mob)
		questCount.RichText = true
		questCount.Text = "> Progress <font color=\"#aaff00\"> (" .. value2 .. "/" .. QuestManager[value].Ammount .. ")</font>"
		money.Text = "$ " .. _G.Suffix_Comma(v)
		exp.Text = "Exp " .. _G.Suffix_Comma(v2)
		local value5 = localPlayer.PlayerStats.RealExpX2.Value
		local value6 = localPlayer.PlayerStats.RealBeliX2.Value
		local v4 = 0
		local v5 = 0
		local characterPassives2 = localPlayer.Character:FindFirstChild("CharacterPassives")

		if characterPassives2 then
			local increaseEXPDrop = characterPassives2:FindFirstChild("IncreaseEXPDrop")
			local increaseMoneyDrop = characterPassives2:FindFirstChild("IncreaseMoneyDrop")

			if increaseEXPDrop and increaseEXPDrop.Value > 0 then
				v4 = increaseEXPDrop.Value / 100
			end

			if increaseMoneyDrop and increaseMoneyDrop.Value > 0 then
				v5 = increaseMoneyDrop.Value / 100
			end
		end

		if value5 > 1 and not expInfoButton.Visible then
			exp.Text = "Exp " .. _G.Suffix_Comma(v2) .. " (" .. value5 + v4 .. "x)"
		end

		if value6 > 1 then
			money.Text = "$ " .. _G.Suffix_Comma(v) .. " (" .. value6 + v5 .. "x)"
		end

		if QuestManager[value].Rewards.BattlepassExp then
			battlepassExp.Visible = true
			battlepassExp.Text = "Pass Exp " .. _G.Suffix_Comma((math.floor(QuestManager[value].Rewards.BattlepassExp)))
		end

		local currentQuest = localPlayer.CurrentQuest
		local track = QuestManager[value].Track or nil
		local flag = nil

		if track then
			if workspace:FindFirstChild("LeeQuestTracker") then
				workspace.LeeQuestTracker:Destroy()
			end

			if not workspace:FindFirstChild("LeeQuestTracker") then
				local part = Instance.new("Part", workspace)
				part.Name = "LeeQuestTracker"
				part.Parent = workspace
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 1
				part.CFrame = track
				local clone = ReplicatedStorage.Chest.Gui.LeePunggQuestTracker:Clone()
				clone.Parent = part
				clone.Adornee = part
				clone.Enabled = true
			end
		end

		if interact and typeof(interact) == "table" then
			local type = interact.Type or nil
			local obstacle = interact.Obstacle or nil

			if type then
				if value2 <= 0 then
					for _, part in pairs(workspace.SpawnItem:GetChildren()) do
						if not (part:IsA("MeshPart") or part:IsA("BasePart")) or part.Name ~= currentQuest.Value or part:FindFirstChild("LeePunggQuestTracker") then
							continue
						end

						local clone = ReplicatedStorage.Chest.Gui.LeePunggQuestTracker:Clone()
						clone.Parent = part
						clone.Adornee = part
						clone.Enabled = true

						for _, descendant in pairs(part:GetDescendants()) do
							if descendant:IsA("Texture") or descendant:IsA("Decal") then
								descendant.Transparency = 0
							end
						end
					end
				end

				if type == "Walk" and obstacle and obstacle == "Reverse" then
					local playerScripts = localPlayer:WaitForChild("PlayerScripts")
					local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
					local controls = PlayerModule:GetControls()
					local playerStats = localPlayer:WaitForChild("PlayerStats")
					local humanoid = localPlayer.Character and localPlayer.Character:WaitForChild("Humanoid")
					local value7 = playerStats.Language.Value
					local v6 = nil

					function controls.moveFunction(p, p2, p3)
						if localPlayer.CurrentQuest.Value == "" then
							return
						end

						if not v6 and humanoid and humanoid.Parent and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
							v6 = true
							local v7 = value7 == "TH" and {
								"ข้ารู้สึกไม่ค่อยดีเลย...",
								"ใครก็ได้บอกข้าที..มันเกิดอะไรขึ้น!"
							} or { "Mister...I don't feel so good...", "Somebody please tell me...What's happening!" }
							local head = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")

							if head then
								local Chat = game:GetService("Chat")
								Chat:Chat(head, v7[math.random(#v7)])
							end

							task.spawn(function()
								task.wait(10)
								v6 = nil
							end)
						end

						localPlayer.Move(p, -p2, p3)
					end

					local thread = coroutine.create(function()
						while true do
							task.wait()

							if localPlayer.CurrentQuest.Value == "" or ammount <= localPlayer.QuestProgress.Value then
								break
							end
						end

						controls.moveFunction = localPlayer.Move
					end)
					coroutine.resume(thread)
				end
			end
		end

		for proximityPrompt, billboardGui in pairs(clonesByObj) do
			if not (proximityPrompt and proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Parent and proximityPrompt.Parent.Name ~= value) then
				continue
			end

			if billboardGui and billboardGui:IsA("BillboardGui") then
				billboardGui:Destroy()
			end

			flag = true
		end

		if flag then
			clonesByObj = {}
		end
	end
end

CheckQuest()
local flag = nil
questBoard.Close.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	questBoard.Visible = false
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})

	if localPlayer.CurrentQuest.Value ~= "" then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Current Quest Cancel")
		ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("CancelQuest", {})
	end

	task.delay(0.02, function()
		flag = nil
	end)
end)
questBoard.Close.MouseEnter:Connect(function()
	questBoard.Close.Size = UDim2.new(0.112, 0, 0.2, 0)
	TweenService:Create(questBoard.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.168, 0, 0.30000000000000004, 0)
	}):Play()
end)
questBoard.Close.MouseLeave:Connect(function()
	TweenService:Create(questBoard.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.112, 0, 0.2, 0)
	}):Play()
end)
expInfoButton.MouseEnter:Connect(function()
	expInfoButton.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	TweenService:Create(expInfoButton.ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		ImageColor3 = Color3.fromRGB(0, 0, 0)
	}):Play()
	expInfo.Visible = true
end)
expInfoButton.MouseLeave:Connect(function()
	TweenService:Create(expInfoButton.ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		ImageColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
	expInfo.Visible = false
end)
localPlayer.QuestProgress.Changed:Connect(function()
	CheckQuest()
end)
localPlayer.CurrentQuest.Changed:Connect(function()
	CheckQuest()
end)
questBoard:GetPropertyChangedSignal("Visible"):Connect(function()
	if questBoard.Visible then
		CheckQuest()
	end
end)
local v = nil
repeatFrame.Yes.MouseButton1Click:Connect(function()
	v = "Repeat"
end)
repeatFrame.No.MouseButton1Click:Connect(function()
	v = "Cancel"
end)

ReplicatedStorage.Chest.Remotes.Functions.QuestRepeat.OnClientInvoke = function()
	local lastTime = os.clock()
	v = nil
	repeatFrame.Visible = true
	repeatFrame.CircleFrame.TweenNumber.Value = 1
	repeatFrame.CircleFrame.Count.Text = 10

	while task.wait() do
		local text = math.max(10 - math.floor(os.clock() - lastTime), 0)
		local v3 = math.min(os.clock() - lastTime, 10) / 10
		repeatFrame.CircleFrame.TweenNumber.Value = 1 - v3
		repeatFrame.CircleFrame.Count.Text = text

		if os.clock() - lastTime > 10 or v then
			break
		end
	end

	repeatFrame.Visible = false

	if v == "Repeat" then
		return "Repeat"
	end
end

local v2 = false
local v3 = "Open"
local minimize = questBoard.Minimize
minimize.MouseButton1Click:Connect(function()
	if not v2 then
		v2 = true

		if v3 == "Open" then
			v3 = "Close"
			minimize.Text = ">"
			game.TweenService:Create(questBoard, TweenInfo.new(0.1), {
				Position = UDim2.new(-0.5, 0, 0.5, 0)
			}):Play()
		elseif v3 == "Close" then
			v3 = "Open"
			minimize.Text = "<"
			game.TweenService:Create(questBoard, TweenInfo.new(0.1), {
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}):Play()
		end

		spawn(function()
			wait(0.1)
			v2 = false
		end)
	end
end)
local v4 = false
local lastTime = tick()
minimize.MouseEnter:Connect(function()
	v4 = false
	minimize.TextLabel.Visible = true
	minimize.BackgroundTransparency = 0.5
	minimize.TextTransparency = 0
end)
minimize.MouseLeave:Connect(function()
	minimize.TextLabel.Visible = false
	lastTime = tick()

	if not v4 then
		v4 = true
		spawn(function()
			repeat
				wait(0.1)
			until tick() - lastTime > 3 or not v4

			if tick() - lastTime > 3 then
				game.TweenService:Create(minimize, TweenInfo.new(0.25), {
					BackgroundTransparency = 0.85,
					TextTransparency = 0.5
				}):Play()
				v4 = false
			end
		end)
	end
end)
ProximityPromptService.PromptShown:Connect(function(instance)
	local v5 = nil

	if UserInputService.TouchEnabled or isTenFootInterface then
		v5 = instance and instance.Parent ~= nil and QuestManager[instance.Parent.Name] and true or v5
	end

	if instance and instance.Parent ~= nil and (instance.Style == Enum.ProximityPromptStyle.Custom or v5) then
		if clonesByObj[instance] then
			return
		end

		if not instance:FindFirstChild(instance.Parent.Name) and localPlayer.CurrentQuest.Value == instance.Parent.Name then
			return class.Create(instance)
		end
	end
end)