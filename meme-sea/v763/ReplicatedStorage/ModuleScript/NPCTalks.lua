local NPCTalks = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
game:GetService("Debris")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local nPCTemplates = guiTemplate:WaitForChild("NPCTemplates")
local toolGuiTemplates = guiTemplate:WaitForChild("ToolGuiTemplates")
local Setting = require(moduleScript:WaitForChild("Setting"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
require(moduleScript:WaitForChild("SetText"))
local AnimateUI = require(modules:WaitForChild("AnimateUI"))
local FadeModule = require(modules:WaitForChild("FadeModule"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local buyItem = Setting.Setting.BuyItem
local modules2 = otherEvent.MainEvents:WaitForChild("Modules")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local connections = {}
local touchEnabled = UserInputService.TouchEnabled == true
local v = {
	Upgrade_Quest = UDim2.new(0.95, 0, 0.6, 0),
	Set_BedPoint = UDim2.new(0.95, 0, 0.55, 0),
	Race_Reroll = UDim2.new(0.95, 0, 0.425, 0),
	FightingStyle_Teacher = UDim2.new(0.95, 0, 0.55, 0),
	Ability_Teacher = UDim2.new(0.95, 0, 0.75, 0),
	Reroll_Race = UDim2.new(0.95, 0, 0.4, 0),
	Awakening_Orb = UDim2.new(0.95, 0, 0.55, 0),
	Quest_Scroll = UDim2.new(0.95, 0, 0.25, 0),
	Eatable_Power = UDim2.new(0.95, 0, 0.25, 0),
	Change_Team = UDim2.new(0.95, 0, 0.6, 0),
	Pvp_Boosts = UDim2.new(0.95, 0, 0.6, 0)
}
local v2 = {
	Maxwell = "rbxassetid://12260379286",
	Baller = "rbxassetid://15802330567",
	Doge = "rbxassetid://183981477",
	Hanger = "rbxassetid://12877692138",
	Cheems = "rbxassetid://9901957687",
	["Smiling Cat"] = "rbxassetid://7536997478",
	Gravestone = "rbxassetid://1299973474",
	["Ohio Popcat"] = "rbxassetid://10821256327",
	MrBeast = "rbxassetid://12002991666",
	["Meme Man"] = "rbxassetid://14087237103",
	["Giga Chad"] = "rbxassetid://12983238850",
	["Aura Master"] = "rbxassetid://10794755567",
	["Nugget Man"] = "rbxassetid://16621462339",
	["Watermelon Man"] = "rbxassetid://16026861774",
	["Boat Spawner"] = "rbxassetid://16071359253",
	["Halved Sorcerer"] = "rbxassetid://15741240453",
	["Floppa Gacha"] = "rbxassetid://9681119698",
	["Doge Gacha"] = "rbxassetid://11773909193",
	["The Bed"] = "rbxassetid://12872445142",
	Popcat = "rbxassetid://14711256781",
	["Floppa Recruiter"] = "rbxassetid://10794755567",
	["Cheems Recruiter"] = "rbxassetid://15576924826",
	["PvP Buff Expert"] = "rbxassetid://289801709"
}

function NPCTalks.StartTalking(childName, data)
	if childName == "Spawn_Boat" then
		local interacter = data.Interacter
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Spawn_Boat") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_BoatSpawner(
					interacter,
					nPCTemplates.Boat_Spawner,
					"Spawn_Boat",
					npcGui_Folder,
					true,
					"Boat Spawner",
					"rbxassetid://16071359253"
				)
			end
		end
	elseif childName == "Quest_Scroll" then
		local interacter = data.Interacter
		local tool = data.Tool

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local character = interacter.Character

			if playerGui and character then
				local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

				if npcGui_Folder and npcGui_Folder:FindFirstChild("Quest_Scroll") == nil and #npcGui_Folder:GetChildren() == 0 and tool:IsDescendantOf(character) then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					ToolActive_Prompt(
						interacter,
						character,
						toolGuiTemplates.Normal_Tool,
						"Quest_Scroll",
						npcGui_Folder,
						true,
						tool.Name,
						tool
					)
				end
			end
		end
	elseif childName == "Awakening_Orb" then
		local interacter = data.Interacter
		local tool = data.Tool

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local character = interacter.Character

			if playerGui and character then
				local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

				if npcGui_Folder and npcGui_Folder:FindFirstChild("Awakening_Orb") == nil and #npcGui_Folder:GetChildren() == 0 and tool:IsDescendantOf(character) then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					ToolActive_Prompt(
						interacter,
						character,
						toolGuiTemplates.Normal_Tool,
						"Awakening_Orb",
						npcGui_Folder,
						true,
						tool.Name,
						tool,
						"Evolve"
					)
				end
			end
		end
	elseif childName == "Eatable_Power" then
		local interacter = data.Interacter
		local tool = data.Tool

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local character = interacter.Character

			if playerGui and character then
				local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

				if npcGui_Folder and npcGui_Folder:FindFirstChild("Eatable_Power") == nil and #npcGui_Folder:GetChildren() == 0 and tool:IsDescendantOf(character) then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					ToolActive_Prompt(
						interacter,
						character,
						toolGuiTemplates.Normal_Tool,
						"Eatable_Power",
						npcGui_Folder,
						true,
						tool.Name,
						tool,
						"Eat"
					)
				end
			end
		end
	elseif childName == "Money_Bag" then
		local interacter = data.Interacter
		local tool = data.Tool

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local character = interacter.Character
			local npcGui_Folder = playerGui and character and playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder then
				local owner = tool:GetAttribute("Owner")

				if npcGui_Folder:FindFirstChild("Money_Bag") == nil and #npcGui_Folder:GetChildren() == 0 and tool:IsDescendantOf(character) and owner then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					MoneyBag_Prompt(
						interacter,
						character,
						toolGuiTemplates.Money_Bag,
						"Money_Bag",
						npcGui_Folder,
						owner,
						tool
					)
				end
			end
		end
	elseif childName == "Storage_Item" then
		local interacter = data.Interacter
		local tool = data.Tool

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local character = interacter.Character

			if playerGui and character then
				local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

				if npcGui_Folder and npcGui_Folder:FindFirstChild("Storage_Item") == nil and #npcGui_Folder:GetChildren() == 0 and tool:IsDescendantOf(character) then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					StorageItem_Prompt(
						interacter,
						character,
						toolGuiTemplates.Storage_Item,
						"Storage_Item",
						npcGui_Folder,
						tool
					)
				end
			end
		end
	elseif childName == "Weapon_Seller" then
		local interacter = data.Interacter
		local nPCName = data.NPCName

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local npcGui_Folder = playerGui and playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder then
				local v3 = buyItem[nPCName]

				if npcGui_Folder:FindFirstChild("Weapon_Seller") == nil and #npcGui_Folder:GetChildren() == 0 and v3 then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					NPCPrompt_ItemPurchase(
						interacter,
						nPCTemplates.Weapon_Seller,
						"Weapon_Seller",
						npcGui_Folder,
						true,
						nPCName,
						v2[nPCName]
					)
				end
			end
		end
	elseif childName == "FightingStyle_Teacher" then
		local interacter = data.Interacter
		local nPCName = data.NPCName

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local npcGui_Folder = playerGui and playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder then
				local v3 = buyItem[nPCName]

				if npcGui_Folder:FindFirstChild("FightingStyle_Teacher") == nil and #npcGui_Folder:GetChildren() == 0 and v3 then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					NPCPrompt_TwoOptions(
						interacter,
						nPCTemplates.NPC_Talk,
						"FightingStyle_Teacher",
						npcGui_Folder,
						true,
						nPCName,
						"Learn",
						nil,
						v2[nPCName]
					)
				end
			end
		end
	elseif childName == "Change_Team" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Change_Team") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_TwoOptions(
					interacter,
					nPCTemplates.NPC_Talk,
					"Change_Team",
					npcGui_Folder,
					true,
					nPCName,
					"Yeah",
					"No way!",
					v2[nPCName]
				)
			end
		end
	elseif childName == "Pvp_Boosts" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Pvp_Boosts") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_BountyBoosts(
					interacter,
					nPCTemplates.NPC_Talk,
					"Pvp_Boosts",
					npcGui_Folder,
					true,
					nPCName,
					"That's cool!",
					"Close",
					v2[nPCName]
				)
			end
		end
	elseif childName == "Ability_Teacher" then
		local interacter = data.Interacter
		local nPCName = data.NPCName

		if interacter then
			local playerGui = interacter:FindFirstChild("PlayerGui")
			local npcGui_Folder = playerGui and playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder then
				local v3 = buyItem[nPCName]

				if npcGui_Folder:FindFirstChild("Ability_Teacher") == nil and #npcGui_Folder:GetChildren() == 0 and v3 then
					guiEvents.GuiEvent:Fire({
						MenuName = "Menu",
						Action = "Close"
					})
					Clear_Connection()
					table.clear(connections)
					local v4 = nPCName == "Giga Chad" and "You're creepy" or nPCName == "Ohio Floppa" and "No way!" or "No, thanks."
					NPCPrompt_TwoOptions(
						interacter,
						nPCTemplates.NPC_Talk,
						"Ability_Teacher",
						npcGui_Folder,
						true,
						nPCName,
						"Learn",
						v4,
						v2[nPCName]
					)
				end
			end
		end
	elseif childName == "Set_BedPoint" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Set_BedPoint") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_TwoOptions(
					interacter,
					nPCTemplates.NPC_Talk,
					"Set_BedPoint",
					npcGui_Folder,
					true,
					nPCName,
					"Yeah",
					nil,
					"rbxassetid://12872445142"
				)
			end
		end
	elseif childName == "Reroll_Race" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Reroll_Race") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_TwoOptions(
					interacter,
					nPCTemplates.NPC_Talk,
					"Reroll_Race",
					npcGui_Folder,
					true,
					nPCName,
					"Of course",
					nil,
					v2[nPCName]
				)
			end
		end
	elseif childName == "Reroll_Color" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Reroll_Color") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_RerollColor(
					interacter,
					nPCTemplates.Reroll_Color,
					"Reroll_Color",
					npcGui_Folder,
					true,
					nPCName,
					"Reroll",
					v2[nPCName]
				)
			end
		end
	elseif childName == "Random_Power" then
		local interacter = data.Interacter
		local nPCName = data.NPCName
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")
			local gachaGui = playerGui:FindFirstChild("GachaGui")

			if npcGui_Folder and gachaGui and npcGui_Folder:FindFirstChild("Random_Power") == nil and #npcGui_Folder:GetChildren() == 0 and gachaGui.Enabled == false then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_RandomPower(
					interacter,
					nPCTemplates.Random_Power,
					"Random_Power",
					npcGui_Folder,
					true,
					nPCName,
					nil,
					v2[nPCName]
				)
			end
		end
	elseif childName == "Upgrade_Quest" then
		local interacter = data.Interacter
		local playerGui = interacter and interacter:FindFirstChild("PlayerGui")

		if playerGui then
			local npcGui_Folder = playerGui:FindFirstChild("NpcGui_Folder")

			if npcGui_Folder and npcGui_Folder:FindFirstChild("Upgrade_Quest") == nil and #npcGui_Folder:GetChildren() == 0 then
				guiEvents.GuiEvent:Fire({
					MenuName = "Menu",
					Action = "Close"
				})
				Clear_Connection()
				table.clear(connections)
				NPCPrompt_TwoOptions(
					interacter,
					nPCTemplates.NPC_Talk,
					"Upgrade_Quest",
					npcGui_Folder,
					true,
					"Popcat",
					"Purchase",
					nil,
					"rbxassetid://14711256781"
				)
			end
		end
	end
end

function NPCPrompt_TwoOptions(instance, instance2, name: string, parent, flag: boolean, p: string, text: string, text2: string, image: string)
	local text3 = name == "Set_BedPoint" and "The Bed" or p
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text3
	end

	if v[name] then
		clone.Background.Title.Size = v[name]
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v4 = Setting.Setting.Message[text3]

	if v4 then
		if instance:GetAttribute("TH") then
			if text then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = Translate[text]
			end

			if text2 then
				clone.Background.Frame.CloseFrame.Close.TextLabel.Text = Translate[text2]
			end

			if v4.Title_TH then
				title_TH = v4.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		else
			if text then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = text
			end

			if text2 then
				clone.Background.Frame.CloseFrame.Close.TextLabel.Text = text2
			end

			if v4.Title then
				title_TH = v4.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.ConfirmFrame.Confirm.Activated:Connect(function()
		clone.Background.Frame.ConfirmFrame.Confirm.Active = false
		Clear_Connection()
		modules2:FireServer(name, p)
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function NPCPrompt_BountyBoosts(player, instance, name: string, parent, flag: boolean, text: string, text2: string, text3: string, image: string)
	local clone = instance:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if v[name] then
		clone.Background.Title.Size = v[name]
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = not (player and player.Character) and 0 or player.Character:GetAttribute("PvpDamage_Boost")
	local v4 = not (player and player.Character) and 0 or player.Character:GetAttribute("PvpDefense_Boost")
	local v5 = {
		Title = `Bounty and Fame will increase your damage and defense in PvP every 100,000 points! Your current PvP buffs are {TextColor(`+{math.floor((MultiplytoPercent(v3)))}% Damage`, "255,100,100")} and {TextColor(`+{math.floor((MultiplytoPercent(v4)))}% Defense`, "255,100,100")}`,
		Title_TH = `ค่าหัวและเกียรติยศสามารถเพิ่มดาเมจและพลังป้องกันให้คุณได้ในการ Pvp คุณสามารถล่าผู้เล่นเพื่อให้บัฟของคุณเพื่มขึ้นได้ทุกๆ 100,000 ค่าหัว/เกียรติยศ ตอนนี้บัฟที่คุณจะได้รับในการ Pvp คือ {TextColor(`+{math.floor((MultiplytoPercent(v3)))}% ดาเมจ`, "255,100,100")} และ {TextColor(`+{math.floor((MultiplytoPercent(v4)))}% พลังป้องกัน`, "255,100,100")}`
	}

	if v5 then
		if player:GetAttribute("TH") then
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = Translate[text2]
			end

			if text3 then
				clone.Background.Frame.CloseFrame.Close.TextLabel.Text = Translate[text3]
			end

			if v5.Title_TH then
				title_TH = v5.Title_TH
				clone.Background.Title.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
			end
		else
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = text2
			end

			if text3 then
				clone.Background.Frame.CloseFrame.Close.TextLabel.Text = text3
			end

			if v5.Title then
				title_TH = v5.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.ConfirmFrame.Confirm.Activated:Connect(function()
		clone.Background.Frame.ConfirmFrame.Confirm.Active = false
		Clear_Connection()
		PlaySound.PlaySound(player, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(player, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function NPCPrompt_ItemPurchase(instance, instance2, name: string, parent, flag: boolean, text: string, image: string)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[text]

	if v3 then
		if instance:GetAttribute("TH") then
			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end

			if text == "Cheems" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "ตกลง"
			elseif text == "Smiling Cat" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "ได้เลย"
				clone.Background.Title.Size = UDim2.new(0.95, 0, 0.4, 0)
			elseif text == "Meme Man" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "แลกเปลี่ยน"
			end
		else
			if v3.Title then
				title_TH = v3.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end

			if text == "Cheems" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "Okay"
			elseif text == "Smiling Cat" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "I'll take it"
				clone.Background.Title.Size = UDim2.new(0.95, 0, 0.4, 0)
			elseif text == "Meme Man" then
				clone.Background.Frame.BuyFrame.Buy.TextLabel.Text = "Trade"
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.BuyFrame.Buy.Activated:Connect(function()
		clone.Background.Frame.BuyFrame.Buy.Active = false
		Clear_Connection()
		modules2:FireServer(name, text)
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function NPCPrompt_BoatSpawner(instance, instance2, name: string, parent, flag: boolean, text: string, image: string)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	clone.Background.CloseFrame.Close.ImageTransparency = 1
	clone.Background.CloseFrame.Close.Title.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[name]

	if v3 then
		if instance:GetAttribute("TH") then
			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		elseif v3.Title then
			title_TH = v3.Title
			clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close, tweenInfo, {
		ImageTransparency = 0.5
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close.Title, tweenInfo, {
		ImageTransparency = 0.25
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.FloppaFrame.Floppa.Activated:Connect(function()
		clone.Background.Frame.FloppaFrame.Floppa.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Boat_Name = "Floppa"
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.DogeFrame.Doge.Activated:Connect(function()
		clone.Background.Frame.DogeFrame.Doge.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Boat_Name = "Doge"
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.CheemsFrame.Cheems.Activated:Connect(function()
		clone.Background.Frame.CheemsFrame.Cheems.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Boat_Name = "Cheems"
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.MoreFrame.More.Activated:Connect(function()
		guiEvents.GuiEvent:Fire({
			MenuName = "BoatList",
			Action = "Open"
		})
		clone.Background.Frame.MoreFrame.More.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.CloseFrame.Close.Activated:Connect(function()
		clone.Background.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function NPCPrompt_RerollColor(instance, instance2, name: string, parent, flag: boolean, text: string, text2: string, image: string)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[text]

	if v3 then
		if instance:GetAttribute("TH") then
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = Translate[text2]
			end

			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		else
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = text2
			end

			if v3.Title then
				title_TH = v3.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.ConfirmFrame.Confirm.Activated:Connect(function()
		clone.Background.Frame.ConfirmFrame.Confirm.Active = false
		Clear_Connection()
		modules2:FireServer(name, text)
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.IndexFrame.Index.Activated:Connect(function()
		guiEvents.GuiEvent:Fire({
			MenuName = "IndexColor",
			Action = "Open"
		})
		clone.Background.Frame.IndexFrame.Index.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function NPCPrompt_RandomPower(instance, instance2, name: string, parent, flag: boolean, text: string, text2: string, image: string)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.CloseFrame.Close.ImageTransparency = 1
	clone.Background.CloseFrame.Close.Title.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.Profile.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if image then
		clone.Background.Profile.Image = image
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[text]

	if v3 then
		if instance:GetAttribute("TH") then
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = Translate[text2]
			end

			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		else
			if text2 then
				clone.Background.Frame.ConfirmFrame.Confirm.TextLabel.Text = text2
			end

			if v3.Title then
				title_TH = v3.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Profile, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close, tweenInfo, {
		ImageTransparency = 0.5
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close.Title, tweenInfo, {
		ImageTransparency = 0.25
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.CloseFrame.Close.Activated:Connect(function()
		clone.Background.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.ConfirmFrame.Confirm.Activated:Connect(function()
		clone.Background.Frame.ConfirmFrame.Confirm.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Type = "Once",
			GachaType = text == "Floppa Gacha" and "Money" or "Gem",
			NPCName = text
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.TripleFrame.Triple.Activated:Connect(function()
		clone.Background.Frame.TripleFrame.Triple.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Type = "Triple",
			GachaType = text == "Floppa Gacha" and "Money" or "Gem",
			NPCName = text
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.DecupleFrame.Decuple.Activated:Connect(function()
		clone.Background.Frame.DecupleFrame.Decuple.Active = false
		Clear_Connection()
		modules2:FireServer(name, {
			Type = "Decuple",
			GachaType = text == "Floppa Gacha" and "Money" or "Gem",
			NPCName = text
		})
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.IndexFrame.Index.Activated:Connect(function()
		guiEvents.GuiEvent:Fire({
			MenuName = "GachaChances",
			Action = "Open"
		})
		clone.Background.Frame.IndexFrame.Index.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
end

function StorageItem_Prompt(instance, ancestor, instance2, name: string, parent, instance3)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	clone.Background.NPC_Name.Text = instance3.Name
	local title_TH = nil
	clone.Background.Title.Text = ""

	if instance:GetAttribute("TH") then
		clone.Background.Title.Size = UDim2.new(0.95, 0, 0.2, 0)
	elseif v[name] then
		clone.Background.Title.Size = v[name]
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[name]

	if v3 then
		if instance:GetAttribute("TH") then
			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		elseif v3.Title then
			title_TH = v3.Title
			clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.DropFrame.Drop.Activated:Connect(function()
		clone.Background.Frame.DropFrame.Drop.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Drop",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Backspace then
			clone.Background.Frame.DropFrame.Drop.Active = false
			Clear_Connection()
			PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
			CloseUi(clone)
			modules2:FireServer(name, {
				Action = "Drop",
				Tool = instance3
			})
		end
	end)
	connections[#connections + 1] = clone.Background.Frame.StoreFrame.Store.Activated:Connect(function()
		clone.Background.Frame.StoreFrame.Store.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Store",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = instance3:GetPropertyChangedSignal("Parent"):Connect(function()
		if not instance3:IsDescendantOf(ancestor) then
			Clear_Connection()
			CloseUi(clone)
		end
	end)
end

function MoneyBag_Prompt(instance, ancestor, instance2, name: string, parent, _: string, instance3)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if instance:GetAttribute("TH") then
		clone.Background.NPC_Name.Text = `{Translate["Money Bag"]}ของ {instance3:GetAttribute("Owner")}`
	else
		clone.Background.NPC_Name.Text = `{instance3:GetAttribute("Owner")}'s Money Bag`
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = {
		Title = `There is <font color="rgb(100,235,100)">${Abbreviate.Comma(instance3:GetAttribute("Amount"))}</font> inside this money bag. What do you wish to do with it?`,
		Title_TH = `ถุงเงินใบนี้มีเงิน <font color="rgb(100,235,100)">${Abbreviate.Comma(instance3:GetAttribute("Amount"))}</font> บรรจุอยู่ข้างใน. คุณต้องการที่จะทำอะไรกับมันดีล่ะ?`
	}

	if v3 then
		if instance:GetAttribute("TH") then
			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		elseif v3.Title then
			title_TH = v3.Title
			clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	connections[#connections + 1] = instance3:GetPropertyChangedSignal("Parent"):Connect(function()
		if not instance3:IsDescendantOf(ancestor) then
			Clear_Connection()
			CloseUi(clone)
		end
	end)
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.Frame.CloseFrame.Close.Activated:Connect(function()
		clone.Background.Frame.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Backspace then
			clone.Background.Frame.DropFrame.Drop.Active = false
			Clear_Connection()
			PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
			CloseUi(clone)
			modules2:FireServer(name, {
				Action = "Drop",
				Tool = instance3
			})
		end
	end)
	connections[#connections + 1] = clone.Background.Frame.DropFrame.Drop.Activated:Connect(function()
		clone.Background.Frame.DropFrame.Drop.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Drop",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = clone.Background.Frame.UseFrame.Use.Activated:Connect(function()
		clone.Background.Frame.UseFrame.Use.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Use",
			Tool = instance3
		})
	end)
end

function ToolActive_Prompt(instance, ancestor, instance2, name: string, parent, flag: boolean, text: string, instance3, text2: string)
	local clone = instance2:Clone()
	clone.Name = name
	clone.Parent = parent
	clone.Background.Size = UDim2.new(0.2, 0, 0.1, 0)
	clone.Background.ImageTransparency = 1
	clone.Background.CloseFrame.Close.ImageTransparency = 1
	clone.Background.CloseFrame.Close.Title.ImageTransparency = 1
	clone.Background.NPC_Name.TextTransparency = 1
	clone.Background.Board.ImageTransparency = 1
	local title_TH = nil
	clone.Background.Title.Text = ""

	if flag then
		clone.Background.NPC_Name.Text = text
	end

	if instance:GetAttribute("TH") then
		clone.Background.Title.Size = UDim2.new(0.95, 0, 0.2, 0)
	elseif v[name] then
		clone.Background.Title.Size = v[name]
	end

	if touchEnabled then
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Enabled = false
		end
	else
		local uIStroke = clone.Background.NPC_Name:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1
		end
	end

	local v3 = Setting.Setting.Message[clone.Name]

	if v3 then
		if instance:GetAttribute("TH") then
			if text2 then
				clone.Background.Frame.UseFrame.Use.TextLabel.Text = Translate[text2]
			end

			if v3.Title_TH then
				title_TH = v3.Title_TH
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		else
			if text2 then
				clone.Background.Frame.UseFrame.Use.TextLabel.Text = text2
			end

			if v3.Title then
				title_TH = v3.Title
				clone.Background.Title.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
			end
		end
	end

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		guiButton.ImageTransparency = 1
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.TextTransparency = 1
		end
	end

	clone.Enabled = true
	local tween = TweenService:Create(clone.Background, tweenInfo, {
		Size = UDim2.new(0.39, 0, 0.225, 0),
		ImageTransparency = 0.25
	})
	tween:Play()
	TweenService:Create(clone.Background.NPC_Name, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.NPC_Name.UIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Background.Board, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close, tweenInfo, {
		ImageTransparency = 0.5
	}):Play()
	TweenService:Create(clone.Background.CloseFrame.Close.Title, tweenInfo, {
		ImageTransparency = 0.25
	}):Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(clone.Background, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.625, 0)
	})
	tween2:Play()
	tween2.Completed:Wait()
	AnimateUI.typeWrite(clone.Background.Title, title_TH, true)

	for _, frame in ipairs(clone.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
		end
	end

	connections[#connections + 1] = clone.Background.CloseFrame.Close.Activated:Connect(function()
		clone.Background.CloseFrame.Close.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
	end)
	connections[#connections + 1] = clone.Background.Frame.DropFrame.Drop.Activated:Connect(function()
		clone.Background.Frame.DropFrame.Drop.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Drop",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Backspace then
			clone.Background.Frame.DropFrame.Drop.Active = false
			Clear_Connection()
			PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
			CloseUi(clone)
			modules2:FireServer(name, {
				Action = "Drop",
				Tool = instance3
			})
		end
	end)
	connections[#connections + 1] = clone.Background.Frame.StoreFrame.Store.Activated:Connect(function()
		clone.Background.Frame.StoreFrame.Store.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Store",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = clone.Background.Frame.UseFrame.Use.Activated:Connect(function()
		clone.Background.Frame.UseFrame.Use.Active = false
		Clear_Connection()
		PlaySound.PlaySound(instance, ReplicatedStorage.Sound_Effect.ClickSound)
		CloseUi(clone)
		modules2:FireServer(name, {
			Action = "Use",
			Tool = instance3
		})
	end)
	connections[#connections + 1] = instance3:GetPropertyChangedSignal("Parent"):Connect(function()
		if not instance3:IsDescendantOf(ancestor) then
			Clear_Connection()
			CloseUi(clone)
		end
	end)
end

function Disconnect(connection)
	if connection then
		connection:Disconnect()
	end
end

function Clear_Connection()
	for _, connection in ipairs(connections) do
		Disconnect(connection)
	end
end

function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

function MultiplytoPercent(p)
	return p * 100 - 100
end

function CloseUi(instance)
	for _, frame in ipairs(instance.Background.Frame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local guiButton = frame:FindFirstChildWhichIsA("GuiButton")

		if not guiButton then
			continue
		end

		TweenService:Create(guiButton, tweenInfo, {
			ImageTransparency = 1
		}):Play()
		local textLabel = guiButton:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
		end
	end

	task.wait(0.25)
	local tween = TweenService:Create(
		instance.Background,
		TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0.5, 0, 0.7, 0)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(instance.Background, tweenInfo, {
		Size = UDim2.new(0.2, 0, 0.1, 0)
	})
	tween2:Play()
	FadeModule.FadeOut(instance.Background, 0.25)
	tween2.Completed:Wait()

	if instance then
		instance:Destroy()
	end
end

return NPCTalks