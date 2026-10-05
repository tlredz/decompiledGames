local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("GuiTemplate")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local SetText = require(moduleScript:WaitForChild("SetText"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local Jumpscare = require(moduleScript:WaitForChild("Jumpscare"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
localPlayer:WaitForChild("Cooldown", 60)
local playerGui = localPlayer:WaitForChild("PlayerGui", 60)
local money = playerData:WaitForChild("Money")
local dropMoney = mainEvents:WaitForChild("DropMoney")
local parent = script.Parent
local parent2 = parent.Parent.Parent.Parent
local amout_Frame = parent.Amout_Frame
local drop_Frame = parent.Drop_Frame
local textbox = parent.Input_Frame.Textbox
local v = UserInputService.TouchEnabled and true or false
local v2 = {
	K = 1000,
	M = 1000000,
	B = 1000000000,
	T = 1000000000000,
	QA = 1000000000000000,
	QI = 1e18,
	SX = 1e21
}

local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function SetColor_State(drop, p: string)
	if p == "Normal" then
		drop.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		drop.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		drop.DropTitle.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		drop.Colour.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Cooldown" then
		drop.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		drop.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		drop.DropTitle.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		drop.Colour.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	end
end

local function StartCooldown()
	script:SetAttribute("DropMoneyCD", tick())
	drop_Frame.Drop.Active = false
	SetColor_State(drop_Frame.Drop, "Cooldown")

	while tick() - script:GetAttribute("DropMoneyCD") < 10 do
		if localPlayer:GetAttribute("TH") then
			drop_Frame.Drop.DropTitle.Text = `{Abbreviate.Format(10 - (tick() - script:GetAttribute("DropMoneyCD")), 1)} วินาที`
		else
			drop_Frame.Drop.DropTitle.Text = `{Abbreviate.Format(10 - (tick() - script:GetAttribute("DropMoneyCD")), 1)}s`
		end

		task.wait(0.1)
	end

	SetColor_State(drop_Frame.Drop, "Normal")
	drop_Frame.Drop.Active = true

	if localPlayer:GetAttribute("TH") then
		drop_Frame.Drop.DropTitle.Text = "ยืนยัน"
	else
		drop_Frame.Drop.DropTitle.Text = "Confirm"
	end
end

local function DropMoney()
	local realInput = script:GetAttribute("RealInput")
	local number = Abbreviate.GetNumber(realInput)

	if number and number > 0 then
		if number < 9e18 then
			if number <= money.Value then
				if localPlayer:GetAttribute("Trading") then
					if localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "ไม่สามารถทิ้งเงินระหว่างการเทรดได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "Unable to drop money while trading!",
							MessageColor = "Red"
						})
					end
				elseif dropMoney:InvokeServer(number) == true then
					if localPlayer:GetAttribute("TH") then
						local setText = SetText.SetText
						local formatted = `${Abbreviate.Comma(number)}`
						local v7

						if formatted then
							v7 = `<font color="rgb(100,255,100)">{formatted}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `ถุงเงินจำนวน {v7} ถูกเพิ่มลงในกระเป๋าของคุณแล้ว.`
						})
					else
						local setText = SetText.SetText
						local formatted = `${Abbreviate.Comma(number)}`
						local v7

						if formatted then
							v7 = `<font color="rgb(100,255,100)">{formatted}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `Added {v7} Money Bag to your backpack.`
						})
					end

					StartCooldown()
				end
			elseif localPlayer:GetAttribute("TH") then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "เงินของคุณไม่เพียงพอ!",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "Not enough money!",
					MessageColor = "Red"
				})
			end
		else
			drop_Frame.Drop.Active = false
			sound_Effect.Scare1:Play()
			local theRock = playerGui.Jumpscare:FindFirstChild("The Rock")

			if theRock and localPlayer:GetAttribute("Jumpscaring") == nil then
				Jumpscare.SetJumpscare(localPlayer, theRock)
			end

			drop_Frame.Drop.Active = true
		end
	elseif localPlayer:GetAttribute("TH") then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = "โปรดใส่จำนวนให้ถูกต้อง!",
			MessageColor = "Red"
		})
	else
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = "Please enter the correct amount!",
			MessageColor = "Red"
		})
	end
end

local function AbrevToNumber(value: string)
	local v3 = string.gsub(value, ",", "")
	local v4 = string.gsub(v3, "%d+", "")
	local v5

	if string.upper(v4) == "QA" or string.upper(v4) == "QI" or string.upper(v4) == "SX" and v2[string.upper(v4)] then
		v5 = v2[string.upper(v4)]
	end

	if v5 then
		local v6 = string.gsub(v3, "%D", "")

		if v6 then
			return v6 * v5
		end
	else
		local v6, v7 = string.match(v3, "(.*)(%a)$")
		local v8 = v6 and v7 and v2[string.upper(v7)]

		if v8 then
			return (tonumber(v6 * v8))
		end
	end

	return (tonumber(v3))
end

textbox:GetPropertyChangedSignal("Text"):Connect(function()
	if textbox.Text == "" then
		script:SetAttribute("RealInput", 0)
		amout_Frame.Visible = false
	else
		local success, result = pcall(AbrevToNumber, textbox.Text)
		local v3

		if success and result then
			v3 = Abbreviate.GetNumber(result)
		end

		if v3 then
			if v3 > 0 and v3 < 9e18 then
				script:SetAttribute("RealInput", v3)
				amout_Frame.Money_Display.Input.Text = `${Abbreviate.Comma(v3)}`
			else
				if not (v3 > 0 and v3 >= 9e18) then
					amout_Frame.Visible = false
					return
				end

				script:SetAttribute("RealInput", v3)

				if localPlayer:GetAttribute("TH") then
					amout_Frame.Money_Display.Input.Text = "ไร้ที่สิ้นสุด"
				else
					amout_Frame.Money_Display.Input.Text = "Infinity"
				end
			end

			amout_Frame.Visible = true
		end
	end
end)
drop_Frame.Drop.Activated:Connect(DropMoney)
local uIStroke = v and amout_Frame.Money_Display.Input:FindFirstChild("UIStroke")

if uIStroke then
	uIStroke.Enabled = false
end