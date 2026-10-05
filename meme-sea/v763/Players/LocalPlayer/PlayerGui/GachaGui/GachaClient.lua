local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
ReplicatedStorage:WaitForChild("Modules")
local gacha = otherEvent:WaitForChild("MainEvents"):WaitForChild("Gacha")
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local ColorTable = require(moduleScript:WaitForChild("ColorTable"))
local GachaChance = require(moduleScript:WaitForChild("GachaChance"))
require(moduleScript:WaitForChild("Translate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local rarity = ItemInfo.Rarity
local icon = ItemInfo.Icon
local item = ColorTable.Item
local _ = ColorTable.EquipBoarder
local _ = ColorTable.ToolBoarder
local _ = ColorTable.Gradient
local power = rarity.Power
local gacha2 = GachaChance.Gacha
local parent = script.Parent
local gachaFrame = parent:WaitForChild("GachaFrame")
local rollFrame = gachaFrame:WaitForChild("RollFrame")
local currentPhase = gachaFrame:WaitForChild("CurrentPhase")
gachaFrame:WaitForChild("CurrenItem")
local container = rollFrame:WaitForChild("Container")
rollFrame:WaitForChild("Indicator")
local meow = sound_Effect:WaitForChild("Meow")
local honk = sound_Effect:WaitForChild("Honk")
local gachaSound = sound_Effect:WaitForChild("GachaSound")
local touchEnabled = UserInputService.TouchEnabled == true
local template = script:WaitForChild("Template")

if touchEnabled then
	template.ItemName.UIStroke.Thickness = 1
end

gacha.OnClientEvent:Connect(function(data)
	local nPC_Name = data.NPC_Name
	local chosen_Power = data.Chosen_Power
	local gacha_Time = data.Gacha_Time
	local started_Gacha = data.Started_Gacha
	local type = data.Type
	local phase = data.Phase or 1
	local chance = data.Chance

	if type == "Triple" then
		Reroll_Gacha(chosen_Power, nPC_Name, gacha_Time, started_Gacha, 25, phase, 3)

		if CheckIfAlive(localPlayer.Character) then
			Gacha_Notification(chosen_Power, chance)
		end

		if nPC_Name == "Floppa Gacha" then
			meow:Play()
		else
			honk:Play()
		end

		if not (phase >= 3) then
			ClearContainer()
			return
		end
	elseif type == "Decuple" then
		Reroll_Gacha(chosen_Power, nPC_Name, gacha_Time, started_Gacha, 20, phase, 10)

		if CheckIfAlive(localPlayer.Character) then
			Gacha_Notification(chosen_Power, chance)
		end

		if nPC_Name == "Floppa Gacha" then
			meow:Play()
		else
			honk:Play()
		end

		if not (phase >= 10) then
			ClearContainer()
			return
		end
	else
		Reroll_Gacha(chosen_Power, nPC_Name, gacha_Time, started_Gacha, 30, phase, 1)

		if CheckIfAlive(localPlayer.Character) then
			Gacha_Notification(chosen_Power, chance)
		end

		if nPC_Name == "Floppa Gacha" then
			meow:Play()
		else
			honk:Play()
		end
	end

	task.wait(0.5)
	parent.Enabled = false
	ClearContainer()
end)

function Reroll_Gacha(p, _, p2, p3, p4, p5, p6)
	if parent.Enabled == false then
		parent.Enabled = true
	end

	local integer = Random.new():NextInteger(15, p4 - 5)

	if localPlayer:GetAttribute("TH") then
		currentPhase.Text = `กำลังสุ่มกาชา ({p5}/{p6})`
	else
		currentPhase.Text = `Rolling Gacha ({p5}/{p6})`
	end

	for i = 1, p4 do
		local name

		if i == integer then
			name = p
		else
			local v2 = {}

			for k, v3 in pairs(gacha2) do
				for _ = 1, v3 * 4 do
					table.insert(v2, k)
				end
			end

			name = v2[Random.new():NextInteger(1, #v2)]
		end

		local clone = template:Clone()
		clone.Name = name
		clone.ItemName.Text = clone.Name
		clone.ItemName.UIStroke.Color = item[power[clone.Name]]
		clone.BackgroundColor3 = item[power[clone.Name]]
		clone.Icon.Image = icon[clone.Name]
		clone.Icon.ImageColor3 = Color3.fromRGB(235, 233, 227)
		clone.Board.ImageColor3 = item[power[clone.Name]]
		clone.Visible = true
		clone.Parent = container
	end

	container.Position = UDim2.new(0, 0, 0.5, 0)
	local scale = template.Size.X.Scale
	local scale2 = container.UIListLayout.Padding.Scale
	local v = 0.5 - scale / 2
	local v2 = -scale - scale2
	local v3 = v + (integer - 1) * v2
	local number = Random.new():NextNumber(-scale / 2, scale / 2)
	local v4 = v3 + number
	local v5 = 0

	while workspace:GetServerTimeNow() - p3 < p2 do
		local v6 = (workspace:GetServerTimeNow() - p3) / p2
		local v7 = tweenGraph(v6, 2)
		local lerped = lerp(0, v4, v7)
		local v8 = math.abs((math.floor((lerped + number) / scale))) + 1

		if v8 ~= v5 then
			gachaSound:Play()
			v5 = v8
		end

		container.Position = UDim2.new(lerped, 0, 0.5, 0)

		if v6 >= 1 then
			break
		else
			RunService.Heartbeat:Wait()
		end
	end
end

function calculateDistance(p, p2)
	local v = p.X - p2.X
	local v2 = p.Y - p2.Y
	return (math.sqrt(v * v + v2 * v2))
end

function getClosestGui(p)
	local v = 10
	local v2 = nil

	for _, frame in ipairs(container:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local v3 = calculateDistance(p.AbsolutePosition, frame.AbsolutePosition)

		if not (v3 < v) then
			continue
		end

		v2 = frame
		v = v3
	end

	return v2
end

function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

function Gacha_Notification(p, p2)
	if localPlayer:GetAttribute("TH") then
		if power[p] == "Common" then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = `คุณสุ่มได้ {TextColor(`&lt;{p}&gt;`, "111,171,255")} ({p2}%)`
			})
		elseif power[p] == "Uncommon" then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = `คุณสุ่มได้ {TextColor(`&lt;{p}&gt;`, "121,255,106")} ({p2}%)`
			})
		elseif power[p] == "Rare" then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = `คุณสุ่มได้ {TextColor(`&lt;{p}&gt;`, "186,91,234")} ({p2}%)`
			})
		elseif power[p] == "Legendary" then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = `ยินดีด้วย! คุณสุ่มได้ {TextColor(`&lt;{p}&gt;`, "240,49,55")} ({p2}%)`,
				Duration = 4
			})
		end
	elseif power[p] == "Common" then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = `You rolled {TextColor(`&lt;{p}&gt;`, "111,171,255")} ({p2}%)`
		})
	elseif power[p] == "Uncommon" then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = `You rolled {TextColor(`&lt;{p}&gt;`, "121,255,106")} ({p2}%)`
		})
	elseif power[p] == "Rare" then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = `You rolled {TextColor(`&lt;{p}&gt;`, "186,91,234")} ({p2}%)`
		})
	elseif power[p] == "Legendary" then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = `Congratulations! You rolled {TextColor(`&lt;{p}&gt;`, "240,49,55")} ({p2}%)`,
			Duration = 4
		})
	end
end

function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

function ClearContainer()
	for _, frame in ipairs(container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function tweenGraph(value, p)
	return 1 - (1 - math.clamp(value, 0, 1)) ^ p
end