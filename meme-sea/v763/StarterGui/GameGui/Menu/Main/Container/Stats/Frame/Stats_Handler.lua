local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local Setting = require(moduleScript:WaitForChild("Setting"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local Jumpscare = require(moduleScript:WaitForChild("Jumpscare"))
local FadeModule = require(modules:WaitForChild("FadeModule"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local playerGui = localPlayer:WaitForChild("PlayerGui", 60)
local meleeLevel = playerData:WaitForChild("MeleeLevel")
local defenseLevel = playerData:WaitForChild("DefenseLevel")
local swordLevel = playerData:WaitForChild("SwordLevel")
local memePowerLevel = playerData:WaitForChild("MemePowerLevel")
local skillPoint = playerData:WaitForChild("SkillPoint")
playerData:WaitForChild("Country")
local maxLevel = Setting.Setting.MaxLevel
local flag = false
local renderSteppedConnection = nil
local statsFunction = otherEvent.MainEvents:WaitForChild("StatsFunction")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local admin_GiveMoney = otherEvent.MiscEvents:WaitForChild("Admin_GiveMoney")
local parent = script.Parent.Parent.Parent.Parent
local parent2 = parent.Parent
local _ = parent.HeadBar.Close
local parent3 = script.Parent
local parent4 = parent3.Parent
local skillPoints = parent3.SkillPoints
local list = parent3.List
local sword = list.Sword
local melee = list.Melee
local health = list.Health
local power = list.Power
local skillPoint2 = parent3.SkillPoints.SkillPoint_Frame.SkillPoint
local refundFrame = parent3.RefundFrame
local upgradeFrame = parent3.UpgradeFrame
local amount_Frame = upgradeFrame.Amount_Frame
local inputFrame = amount_Frame.InputFrame
local stats = amount_Frame.Stats
local _ = amount_Frame.Min
local max = amount_Frame.Max
local slideFrame = amount_Frame.SlideFrame
local button = amount_Frame.UpgradeFrame.Button
local button2 = amount_Frame.CloseFrame.Button
local input = inputFrame.Input
local clickSound = sound_Effect:WaitForChild("ClickSound")
local upgrade = sound_Effect:WaitForChild("Upgrade")
local error = sound_Effect:WaitForChild("Error")
local touchEnabled = UserInputService.TouchEnabled == true

local function ShowSword()
	if maxLevel <= swordLevel.Value then
		if localPlayer:GetAttribute("TH") then
			sword.StatValue.Text = `เลเวล {swordLevel.Value} (สูงสุด)`
		else
			sword.StatValue.Text = `Lv. {swordLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		sword.StatValue.Text = `เลเวล {swordLevel.Value}`
	else
		sword.StatValue.Text = `Lv. {swordLevel.Value}`
	end
end

local function ShowMelee()
	if maxLevel <= meleeLevel.Value then
		if localPlayer:GetAttribute("TH") then
			melee.StatValue.Text = `เลเวล {meleeLevel.Value} (สูงสุด)`
		else
			melee.StatValue.Text = `Lv. {meleeLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		melee.StatValue.Text = `เลเวล {meleeLevel.Value}`
	else
		melee.StatValue.Text = `Lv. {meleeLevel.Value}`
	end
end

local function ShowDefense()
	if maxLevel <= defenseLevel.Value then
		if localPlayer:GetAttribute("TH") then
			health.StatValue.Text = `เลเวล {defenseLevel.Value} (สูงสุด)`
		else
			health.StatValue.Text = `Lv. {defenseLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		health.StatValue.Text = `เลเวล {defenseLevel.Value}`
	else
		health.StatValue.Text = `Lv. {defenseLevel.Value}`
	end
end

local function ShowPower()
	if maxLevel <= memePowerLevel.Value then
		if localPlayer:GetAttribute("TH") then
			power.StatValue.Text = `เลเวล {memePowerLevel.Value} (สูงสุด)`
		else
			power.StatValue.Text = `Lv. {memePowerLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		power.StatValue.Text = `เลเวล {memePowerLevel.Value}`
	else
		power.StatValue.Text = `Lv. {memePowerLevel.Value}`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0) and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name
end

function ActiveRefundFrame(p)
	if p == true and refundFrame.Visible == false and upgradeFrame.Visible == false then
		refundFrame.Visible = true
		FadeModule.FadeIn(refundFrame, 0.25)
	elseif p == false and refundFrame.Visible == true then
		FadeModule.FadeOut(refundFrame, 0.25)
		task.wait(0.25)
		refundFrame.Visible = false
	end
end

function ActiveUpgradeFrame(p)
	if p == true and upgradeFrame.Visible == false and refundFrame.Visible == false then
		upgradeFrame.Visible = true
		FadeModule.FadeIn(upgradeFrame, 0.25)
		local number = Abbreviate.GetNumber(input.Text)
		local child = playerData:FindFirstChild(stats.Value)

		if number and child then
			if tonumber(max.Text) < number then
				input.Text = math.clamp(tonumber(max.Text), 1, (tonumber(max.Text)))
			end

			local X = UserInputService:GetMouseLocation().X
			local X2 = slideFrame.AbsoluteSize.X
			local v = math.floor(1 + number * math.clamp((X - slideFrame.AbsolutePosition.X) / X2, 0, 1))
			local v2

			if number and child then
				if maxLevel - child.Value <= 1 or skillPoint.Value <= 1 then
					if maxLevel < number + child.Value then
						v2 = math.clamp(
							math.clamp(v, 0, child.Value) / math.clamp(tonumber(max.Text), 1, child.Value),
							0,
							1
						)
					else
						if skillPoint.Value < number then
						end

						v2 = math.clamp(
							math.clamp(v, 0, skillPoint.Value) / math.clamp(tonumber(max.Text), 1, skillPoint.Value),
							0,
							1
						)
					end
				elseif maxLevel < number + child.Value then
					v2 = math.clamp(
						math.clamp(v - 1, 0, child.Value) / (math.clamp(tonumber(max.Text), 1, child.Value) - 1),
						0,
						1
					)
				else
					if skillPoint.Value < number then
					end

					v2 = math.clamp(
						math.clamp(v - 1, 0, skillPoint.Value) / (math.clamp(tonumber(max.Text), 1, skillPoint.Value) - 1),
						0,
						1
					)
				end
			else
				v2 = math.clamp(
					math.clamp(v - 1, 0, maxLevel) / (math.clamp(tonumber(max.Text), 1, maxLevel) - 1),
					0,
					1
				)
			end

			if slideFrame.Slide.Position ~= UDim2.new(
				math.clamp(v2, 0, 1),
				0,
				slideFrame.Slide.Position.Y.Scale,
				slideFrame.Slide.Position.Y.Offset
			) then
				TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
					Position = UDim2.new(
						math.clamp(v2, 0, 1),
						0,
						slideFrame.Slide.Position.Y.Scale,
						slideFrame.Slide.Position.Y.Offset
					)
				}):Play()
			end

			if slideFrame.Bar.Size ~= UDim2.new(math.clamp(v2 + 0.035, 0, 1), 0, 1, 0) then
				TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
					Size = UDim2.new(math.clamp(v2 + 0.035, 0, 1), 0, 1, 0)
				}):Play()
			end
		end
	elseif p == false and upgradeFrame.Visible == true then
		FadeModule.FadeOut(upgradeFrame, 0.25)
		task.wait(0.25)
		upgradeFrame.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMaxPoints()
	local child = playerData:FindFirstChild(stats.Value)

	if child then
		max.Text = math.clamp(maxLevel - child.Value, 1, (math.clamp(skillPoint.Value, 1, maxLevel)))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowStatsPoint()
	if localPlayer:GetAttribute("TH") then
		skillPoints.Point.Text = `แต้มที่มีอยู่: {Abbreviate.Comma(skillPoint.Value)}`
	else
		skillPoints.Point.Text = `Available Points: {Abbreviate.Comma(skillPoint.Value)}`
	end
end

local function AddPoint(...)
	local v, v2 = ...
	local child = playerData:FindFirstChild(v)

	if child then
		v2.Activated:Connect(function()
			if maxLevel <= child.Value then
				error:Play()

				if localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ค่าพลังนี้ของคุณตันเรียบร้อยแล้ว!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "This stat has already reached the maximum level!",
						MessageColor = "Red"
					})
				end
			elseif skillPoint.Value <= 0 then
				error:Play()

				if localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "คุณมีแต้มไม่เพียงพอที่จะอัพเกรดค่าพลังนี้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "You don't have enough points to upgrade this stat!",
						MessageColor = "Red"
					})
				end
			else
				if upgradeFrame.Visible ~= false then
					ActiveUpgradeFrame(false)
					return
				end

				clickSound:Play()
				stats.Value = child.Name
				ShowMaxPoints() -- equivalent call inferred; original call site unknown
				ActiveUpgradeFrame(true)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartSliding(p)
	if flag == false then
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		flag = true
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if flag then
				local X = UserInputService:GetMouseLocation().X
				local X2 = p.AbsoluteSize.X
				local v = math.clamp((X - p.AbsolutePosition.X) / X2, 0, 1)
				local v2 = math.floor(tonumber(max.Text) * v + 1)

				if input.Text ~= math.clamp(v2, 1, (tonumber(max.Text))) then
					input.Text = math.clamp(v2, 1, (tonumber(max.Text)))
				end
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
	end
end

skillPoint2:GetPropertyChangedSignal("Text"):Connect(function()
	skillPoint2.Text = skillPoint2.Text:gsub("%D+", "")
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function ChangedAll()
	ShowSword()
	ShowMelee()
	ShowDefense()
	ShowPower()
	ShowStatsPoint() -- equivalent call inferred; original call site unknown
end

AddPoint("MeleeLevel", list.Melee.UpFrame.UpButton)
AddPoint("DefenseLevel", list.Health.UpFrame.UpButton)
AddPoint("SwordLevel", list.Sword.UpFrame.UpButton)
AddPoint("MemePowerLevel", list.Power.UpFrame.UpButton)
skillPoints.Refund.Activated:Connect(function()
	clickSound:Play()
	ActiveRefundFrame(true)
end)
refundFrame.Frame.CloseFrame.Button.Activated:Connect(function()
	clickSound:Play()
	ActiveRefundFrame(false)
end)
button2.Activated:Connect(function()
	clickSound:Play()
	ActiveUpgradeFrame(false)
end)
slideFrame.Slide.MouseButton1Down:Connect(function()
	StartSliding(slideFrame) -- equivalent call inferred; original call site unknown
end)
slideFrame.MouseButton1Down:Connect(function()
	StartSliding(slideFrame) -- equivalent call inferred; original call site unknown
end)
button.Activated:Connect(function()
	local amount = Abbreviate.GetNumber(input.Text) or 1
	local child = playerData:FindFirstChild(stats.Value)

	if amount and child then
		if maxLevel < amount + child.Value then
			input.Text = tonumber(max.Text)
		elseif skillPoint.Value < amount then
			input.Text = math.clamp(skillPoint.Value, 1, (tonumber(max.Text)))
		elseif amount < 1 then
			input.Text = 1
		end

		if amount <= skillPoint.Value then
			upgrade:Play()
			statsFunction:InvokeServer({
				Action = "UpgradeStats",
				Target = stats.Value,
				Amount = amount
			})
		elseif localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "คุณมีแต้มไม่เพียงพอที่จะอัพเกรด.",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "You don't have enough points to upgrade.",
				MessageColor = "Red"
			})
		end
	end

	ActiveUpgradeFrame(false)
end)
refundFrame.Frame.RefundFrame.Button.Activated:Connect(function()
	if not statsFunction:InvokeServer({
		Action = "ResetStats"
	}) then
		sound_Effect.Error:Play()
		return
	end

	ActiveRefundFrame(false)
	sound_Effect.Success2:Play()
end)
swordLevel.Changed:Connect(function()
	if OpeningThisFrame() and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name then
		ShowSword()
	end
end)
meleeLevel.Changed:Connect(function()
	if OpeningThisFrame() and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name then
		ShowMelee()
	end
end)
defenseLevel.Changed:Connect(function()
	if OpeningThisFrame() and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name then
		ShowDefense()
	end
end)
memePowerLevel.Changed:Connect(function()
	if OpeningThisFrame() and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name then
		ShowPower()
	end
end)
skillPoint.Changed:Connect(function()
	if OpeningThisFrame() and parent.AllMenu:GetAttribute("CurrentOpen") == parent4.Name then
		local child = upgradeFrame.Visible and playerData:FindFirstChild(stats.Value)

		if child then
			max.Text = math.clamp(maxLevel - child.Value, 1, (math.clamp(skillPoint.Value, 1, maxLevel)))
		end

		ShowStatsPoint() -- equivalent call inferred; original call site unknown
	end
end)

if touchEnabled then
	input:GetPropertyChangedSignal("Text"):Connect(function()
		input.Text = input.Text:gsub("%D+", "")
		local child = stats.Value and playerData:FindFirstChild(stats.Value)

		if child then
			local number = Abbreviate.GetNumber(input.Text)
			local v = nil

			if number then
				if number and child then
					if maxLevel - child.Value <= 1 or skillPoint.Value <= 1 then
						if number then
							v = math.clamp(
								math.clamp(number, 0, (tonumber(max.Text))) / math.clamp(
									tonumber(max.Text),
									1,
									(tonumber(max.Text))
								),
								0,
								1
							)
						else
							v = math.clamp(
								math.clamp(1, 0, (tonumber(max.Text))) / math.clamp(
									tonumber(max.Text),
									1,
									(tonumber(max.Text))
								),
								0,
								1
							)
						end
					elseif number then
						v = math.clamp(
							math.clamp(number - 1, 0, (tonumber(max.Text))) / (math.clamp(
								tonumber(max.Text),
								2,
								(tonumber(max.Text))
							) - 1),
							0,
							1
						)
					else
						v = math.clamp(
							math.clamp(0, 0, (tonumber(max.Text))) / (math.clamp(
								tonumber(max.Text),
								2,
								(tonumber(max.Text))
							) - 1),
							0,
							1
						)
					end
				end

				if slideFrame.Slide.Position ~= UDim2.new(
					math.clamp(v, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				) then
					TweenService:Create(
						slideFrame.Slide,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = UDim2.new(
								math.clamp(v, 0, 1),
								0,
								slideFrame.Slide.Position.Y.Scale,
								slideFrame.Slide.Position.Y.Offset
							)
						}
					):Play()
				end

				if slideFrame.Bar.Size ~= UDim2.new(math.clamp(v + 0.035, 0, 1), 0, 1, 0) then
					TweenService:Create(
						slideFrame.Bar,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = UDim2.new(math.clamp(v + 0.035, 0, 1), 0, 1, 0)
						}
					):Play()
				end
			end
		end
	end)
	input.FocusLost:Connect(function()
		local child = stats.Value and playerData:FindFirstChild(stats.Value)

		if child then
			local number = Abbreviate.GetNumber(input.Text)

			if number and child then
				if maxLevel - child.Value <= 1 or skillPoint.Value <= 1 then
					if maxLevel < number + child.Value then
						input.Text = tonumber(max.Text)
					elseif skillPoint.Value < number then
						input.Text = skillPoint.Value
					elseif number < 1 then
						input.Text = 1
					end
				elseif maxLevel < number + child.Value then
					input.Text = tonumber(max.Text)
				elseif skillPoint.Value < number then
					input.Text = skillPoint.Value
				elseif number < 1 then
					input.Text = 1
				end
			end
		end
	end)
else
	input:GetPropertyChangedSignal("Text"):Connect(function()
		input.Text = input.Text:gsub("%D+", "")
		local child = stats.Value and playerData:FindFirstChild(stats.Value)

		if child then
			local number = Abbreviate.GetNumber(input.Text)
			local v = nil

			if number then
				if number and child then
					if maxLevel - child.Value <= 1 or skillPoint.Value <= 1 then
						if maxLevel < number + child.Value then
							input.Text = tonumber(max.Text)
						elseif skillPoint.Value < number then
							input.Text = skillPoint.Value
						elseif number < 1 then
							input.Text = 1
						end

						if number then
							v = math.clamp(
								math.clamp(number, 0, (tonumber(max.Text))) / math.clamp(
									tonumber(max.Text),
									1,
									(tonumber(max.Text))
								),
								0,
								1
							)
						else
							v = math.clamp(
								math.clamp(1, 0, (tonumber(max.Text))) / math.clamp(
									tonumber(max.Text),
									1,
									(tonumber(max.Text))
								),
								0,
								1
							)
						end
					else
						if maxLevel < number + child.Value then
							input.Text = tonumber(max.Text)
						elseif skillPoint.Value < number then
							input.Text = skillPoint.Value
						elseif number < 1 then
							input.Text = 1
						end

						if number then
							v = math.clamp(
								math.clamp(number - 1, 0, (tonumber(max.Text))) / (math.clamp(
									tonumber(max.Text),
									2,
									(tonumber(max.Text))
								) - 1),
								0,
								1
							)
						else
							v = math.clamp(
								math.clamp(0, 0, (tonumber(max.Text))) / (math.clamp(
									tonumber(max.Text),
									2,
									(tonumber(max.Text))
								) - 1),
								0,
								1
							)
						end
					end
				end

				if slideFrame.Slide.Position ~= UDim2.new(
					math.clamp(v, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				) then
					TweenService:Create(
						slideFrame.Slide,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = UDim2.new(
								math.clamp(v, 0, 1),
								0,
								slideFrame.Slide.Position.Y.Scale,
								slideFrame.Slide.Position.Y.Offset
							)
						}
					):Play()
				end

				if slideFrame.Bar.Size ~= UDim2.new(math.clamp(v + 0.035, 0, 1), 0, 1, 0) then
					TweenService:Create(
						slideFrame.Bar,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = UDim2.new(math.clamp(v + 0.035, 0, 1), 0, 1, 0)
						}
					):Play()
				end
			end
		end
	end)
end

admin_GiveMoney.OnClientEvent:Connect(function(p: string)
	if p then
		if p then
			if p == "Rickroll" then
				local jumpscare

				if playerGui then
					jumpscare = playerGui:FindFirstChild("Jumpscare")
				end

				if jumpscare then
					local rickroll = jumpscare:FindFirstChild("Rickroll")

					if rickroll and localPlayer:GetAttribute("Jumpscaring") == nil then
						sound_Effect.RickRoll:Play()
						Jumpscare.SetJumpscare(localPlayer, rickroll)
					end
				end
			elseif p == "Scary" then
				local jumpscare

				if playerGui then
					jumpscare = playerGui:FindFirstChild("Jumpscare")
				end

				if jumpscare then
					local scary = jumpscare:FindFirstChild("Scary")

					if scary and localPlayer:GetAttribute("Jumpscaring") == nil then
						sound_Effect.Scary:Play()
						Jumpscare.SetJumpscare(localPlayer, scary)
					end
				end
			elseif p == "The Rock" then
				local jumpscare

				if playerGui then
					jumpscare = playerGui:FindFirstChild("Jumpscare")
				end

				if jumpscare then
					local theRock = jumpscare:FindFirstChild("The Rock")

					if theRock and localPlayer:GetAttribute("Jumpscaring") == nil then
						sound_Effect.Scare1:Play()
						Jumpscare.SetJumpscare(localPlayer, theRock)
					end
				end
			end
		end
	else
		local jumpscare

		if playerGui then
			jumpscare = playerGui:FindFirstChild("Jumpscare")
		end

		if jumpscare then
			local rickroll = jumpscare:FindFirstChild("Rickroll")

			if rickroll and localPlayer:GetAttribute("Jumpscaring") == nil then
				sound_Effect.RickRoll:Play()
				Jumpscare.SetJumpscare(localPlayer, rickroll)
			end
		end
	end
end)

local function CoolButton_Effect(button3)
	if button3:IsA("TextButton") then
		button3.MouseEnter:Connect(function()
			if button3.BackgroundTransparency ~= 0 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0
				}):Play()
			end
		end)
		button3.MouseLeave:Connect(function()
			if button3.BackgroundTransparency ~= 1 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()
			end
		end)
		button3.MouseButton1Up:Connect(function()
			if button3.BackgroundTransparency ~= 1 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()
			end
		end)
		button3.MouseButton1Down:Connect(function()
			if button3.BackgroundTransparency ~= 0 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0
				}):Play()
			end
		end)
	elseif button3:IsA("ImageButton") then
		button3.MouseEnter:Connect(function()
			if button3.ImageTransparency ~= 0 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0
				}):Play()
			end
		end)
		button3.MouseLeave:Connect(function()
			if button3.ImageTransparency ~= 1 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				}):Play()
			end
		end)
		button3.MouseButton1Up:Connect(function()
			if button3.ImageTransparency ~= 1 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				}):Play()
			end
		end)
		button3.MouseButton1Down:Connect(function()
			if button3.ImageTransparency ~= 0 then
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0
				}):Play()
			end
		end)
	end
end

for _, button3 in ipairs(CollectionService:GetTagged("Cool_Button")) do
	if button3:IsA("GuiButton") then
		CoolButton_Effect(button3)
	end
end

CollectionService:GetInstanceAddedSignal("Cool_Button"):Connect(CoolButton_Effect)

if touchEnabled then
	for _, uIStroke in ipairs(CollectionService:GetTagged("Reduce_UIStroke")) do
		if not uIStroke:IsA("UIStroke") then
			continue
		end

		if uIStroke.Thickness == 2 then
			uIStroke.Thickness = 1
		elseif uIStroke.Thickness == 1.75 then
			uIStroke.Thickness = 1
		elseif uIStroke.Thickness == 1.5 then
			uIStroke.Thickness = 1
		elseif uIStroke.Thickness == 1.25 then
			uIStroke.Thickness = 1
		elseif uIStroke.Thickness == 1 then
			uIStroke.Enabled = false
		end
	end
end

UserInputService.InputEnded:Connect(function(input2)
	if input2.UserInputType == Enum.UserInputType.MouseButton1 then
		if flag == true then
			flag = false

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	elseif input2.UserInputType == Enum.UserInputType.Touch and flag == true then
		flag = false

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
end)
guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == parent4.Name and action == "Open" then
		ChangedAll() -- equivalent call inferred; original call site unknown
	end
end)