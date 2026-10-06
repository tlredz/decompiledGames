local localPlayer = game.Players.LocalPlayer

repeat
	wait()
until localPlayer:FindFirstChild("PlayerStats") and localPlayer:FindFirstChild("DataLoaded") and localPlayer.Character

local playerStats = localPlayer:WaitForChild("PlayerStats")
local v = true
local character = localPlayer.Character

if not character then
	repeat
		wait()
		character = localPlayer.Character
	until character
end

localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
end)
local parent = script.Parent
local parent2 = script.Parent.Parent.Parent.Parent.Parent.Parent
local baseFrame = parent2.BaseFrame
local baseFrameOG = parent2.BaseFrameOG
local starterFrame = parent2.StarterFrame
local buttonFrame = baseFrame.ButtonFrame
local buttonFrame2 = baseFrameOG.ButtonFrame
local PeoUtils = require(game.ReplicatedStorage.Chest.Modules.PeoUtils)

function Check()
	local humanoid = character:WaitForChild("Humanoid")

	if playerStats.Language.Value == "US" then
		task.spawn(function()
			for _, label in pairs(parent2.StarterFrame.Setting_Frame.Frame:GetDescendants()) do
				if not (label:IsA("TextLabel") and label.Parent.Name == "Menu" and label.Parent.Parent.Name ~= "Setting_PVP") then
					continue
				end

				if label.TextColor3 == Color3.fromRGB(255, 255, 255) then
					label.Text = "On"
				elseif label.TextColor3 == Color3.fromRGB(193, 193, 193) then
					label.Text = "Off"
				end
			end
		end)
		parent.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		parent.TextLabel.Text = "US"
		baseFrame.Frame.ExpFrame.ExpText.Text = "Exp " .. _G.Suffix(playerStats.exp.Value) .. "/" .. _G.Suffix(playerStats.expneed.Value)
		baseFrame.Frame.HealthFrame.HealthText.Text = "Health " .. _G.Suffix_Comma(humanoid.Health) .. "/" .. _G.Suffix_Comma(humanoid.MaxHealth)
		baseFrame.Frame.Lvl.Text = playerStats.lvl.Value

		if playerStats.lvl.Value >= _G.LevelMaxClient then
			baseFrame.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
			baseFrameOG.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
		end

		baseFrameOG.Frame.ExpFrame.ExpText.Text = "Exp " .. _G.Suffix(playerStats.exp.Value) .. "/" .. _G.Suffix(playerStats.expneed.Value)
		baseFrameOG.Frame.HealthFrame.HealthText.Text = "Health " .. _G.Suffix_Comma(humanoid.Health) .. "/" .. _G.Suffix_Comma(humanoid.MaxHealth)
		baseFrameOG.Frame.Lvl.Text = playerStats.lvl.Value
		starterFrame.Inventory_Frame.Collectible.TextLabel.Text = "Collectible"
		starterFrame.Inventory_Frame.Accessories.TextLabel.Text = "Accessories"
		starterFrame.Inventory_Frame.Fruits.TextLabel.Text = "Fruits"
		starterFrame.Inventory_Frame.Material.TextLabel.Text = "Materials"
		starterFrame.Inventory_Frame.Swords.TextLabel.Text = "Swords"
		starterFrame.StatsFrame.StatsText.Text = "Stats"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Defense.ValueName.Text = "Health"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Fruit.ValueName.Text = "Fruit"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Melee.ValueName.Text = "Melee"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Sword.ValueName.Text = "Sword"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Armament.ValueName.Text = "Armament"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.SkyJump.ValueName.Text = "Sky Jump"
		starterFrame.StatsFrame.SkyJumpGuide.Description.Text = "<b>Sky Jump</b> lets you jump multiple times in the air. <br />The number of jumps you can perform <br /><stroke color=\"#00A2FF\" joins=\"miter\" thickness=\"2\" transparency=\"0.25\">increases by 1 for every 50 levels you gain.</stroke>"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Sword.ValueNum.Text = "Lv. " .. (playerStats.sword.Value < _G.LevelMaxClient and playerStats.sword.Value or playerStats.sword.Value .. " (MAX)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Melee.ValueNum.Text = "Lv. " .. (playerStats.Melee.Value < _G.LevelMaxClient and playerStats.Melee.Value or playerStats.Melee.Value .. " (MAX)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Fruit.ValueNum.Text = "Lv. " .. (playerStats.DF.Value < _G.LevelMaxClient and playerStats.DF.Value or playerStats.DF.Value .. " (MAX)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Defense.ValueNum.Text = "Lv. " .. (playerStats.Defense.Value < _G.LevelMaxClient and playerStats.Defense.Value or playerStats.Defense.Value .. " (MAX)")
		starterFrame.StatsFrame.StatsPage.PointsFrame.PointText.Text = " Points: " .. playerStats.Points.Value
		starterFrame.Battlepass_Frame.TopicFrame.TopicName.Text = "Legacypass SS2"

		if starterFrame.Battlepass_Frame.EasterEggFrame.Visible then
			starterFrame.Battlepass_Frame.TopicFrame.TopicName.Text = "Easter Pass"
		end

		starterFrame.Battlepass_Frame.BTPFrame.ConfirmFrame.NameText.Text = "Are you sure you want unlock the battlepass for 3,499 gems"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.UnlockFrame.TextLabel.Text = "OR"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.UnlockFrame.UnlockGem.Text = "3,499 GEMS"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.FreeLabel.Text = "FREE"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.GoldLabel.Text = "GOLD"
		starterFrame.Battlepass_Frame.BTPFrame.ButtonFrame.ClaimAll.TextLabel.Text = "CLAIM ALL"
		starterFrame.Battlepass_Frame.BTPFrame.ButtonFrame.Close.TextLabel.Text = "CLOSE"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.ClaimAll.TextLabel.Text = "CLAIM ALL"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.Index.TextLabel.Text = "EGG INDEX"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.Close.TextLabel.Text = "CLOSE"
		starterFrame.Battlepass_Frame.EasterEggFrame.TextLabel.Text = "Eggs spawn randomly across the map every 1-2 minutes. Hunt them down to gain EXP and unlock exclusive limited rewards!"
		starterFrame.Gacha_Frame.OpenAll.Text = "OPEN ALL"
		starterFrame.Gacha_Frame.OpenAll.Outline.Text = "OPEN ALL"
		starterFrame.Gacha_Frame.SkipLabel.Text = "SKIP"
		starterFrame.Gacha_Frame.OpenAll.Outline.Text = "SKIP"
		starterFrame.Gacha_Frame.ContinueLabel.Text = "CLICK TO CONTINUE"
		starterFrame.Gacha_Frame.ContinueLabel.Outline.Text = "CLICK TO CONTINUE"
		starterFrame.Gacha_Frame.Frame["10Key"].Text = "CLAIM 10"
		starterFrame.Gacha_Frame.Frame["1Key"].Text = "CLAIM 1"
		starterFrame.Gacha_Frame.Frame.View10Key.Text = "VIEW"
		starterFrame.Gacha_Frame.Frame.ViewFrame.Text1.Text = "UPCOMING REWARDS"
		starterFrame.Gacha_Frame.Frame.ViewFrame.Text2.Text = "Rewards are fixed and guaranteed"
		starterFrame.AllyFrame.TopicFrame.TopicName.Text = "Allies"
		starterFrame.DropBoostFrame.TopicFrame.TopicName.Text = "Drop Boost"
		starterFrame.FightingStyleFrame.TopicFrame.TopicName.Text = "Fighting Styles"
		starterFrame.HomeFrame.TopicFrame.TopicName.Text = "Home"
		starterFrame.MapFrame.TopicFrame.TopicName.Text = "Map"
		starterFrame.Setting_Frame.TopicFrame.TopicName.Text = "Settings"
		starterFrame.TradeFrame.TopicFrame.TopicName.Text = "Trade"
		starterFrame.Setting_Frame.Frame.Setting_FastMode.TextName.Text = "Fast Mode"
		starterFrame.Setting_Frame.Frame.Setting_FastMode.TextInfo.Text = "Disable Materials (Recommended for Mobile)"
		starterFrame.Setting_Frame.Frame.Setting_Music.TextName.Text = "Music"
		starterFrame.Setting_Frame.Frame.Setting_Music.TextInfo.Text = "Adjust music volume."
		starterFrame.Setting_Frame.Frame.Setting_DamageText.TextName.Text = "Damage Text"
		starterFrame.Setting_Frame.Frame.Setting_DamageText.TextInfo.Text = "Display damage text on target."
		starterFrame.Setting_Frame.Frame.Setting_AutoPvpOff.TextName.Text = "Auto PvP Off"
		starterFrame.Setting_Frame.Frame.Setting_AutoPvpOff.TextInfo.Text = "Disable PvP for 40 minutes <font color='#ff0000'>after death</font>."
		starterFrame.Setting_Frame.Frame.Setting_PVP.TextName.Text = "PvP"
		starterFrame.Setting_Frame.Frame.Setting_PVP.TextInfo.Text = "Enables PvP back after dying In Combat."
		starterFrame.Setting_Frame.Frame.Setting_PVP.Menu.TextLabel.Text = "Enable PvP"
		starterFrame.Setting_Frame.Frame.Setting_HideAcc.TextName.Text = "Hide Accessory"
		starterFrame.Setting_Frame.Frame.Setting_HideAcc.TextInfo.Text = "Hide every accessory except the bullitus."
		starterFrame.Setting_Frame.Frame.Setting_RetroUI.TextName.Text = "Legacy Health Bar"
		starterFrame.Setting_Frame.Frame.Setting_RetroUI.TextInfo.Text = "Choose between the Original UI or the New UI."
		starterFrame.Setting_Frame.Frame.Setting_DodgeText.TextName.Text = "Dodge Text"
		starterFrame.Setting_Frame.Frame.Setting_DodgeText.TextInfo.Text = "Display dodge information on your screen."
		starterFrame.Setting_Frame.Frame.Setting_JumpText.TextName.Text = "Jump Text"
		starterFrame.Setting_Frame.Frame.Setting_JumpText.TextInfo.Text = "Display jumps left on your screen."
		starterFrame.Setting_Frame.Frame.Setting_ComboText.TextName.Text = "Combo Text"
		starterFrame.Setting_Frame.Frame.Setting_ComboText.TextInfo.Text = "Display damage & hits on your screen."
		starterFrame.Setting_Frame.Frame.Setting_AllyEffects.TextName.Text = "Allies Effects"
		starterFrame.Setting_Frame.Frame.Setting_AllyEffects.TextInfo.Text = "Allies effects. Disable if you are lagging."
		starterFrame.Setting_Frame.Frame.Setting_HideAllEffects.TextName.Text = "Hide All Effects (Except you)"
		starterFrame.Setting_Frame.Frame.Setting_HideAllEffects.TextInfo.Text = "Be careful! You won’t know or see all of the enemy’s attacks"
		starterFrame.Setting_Frame.Frame.Setting_HideHair.TextName.Text = "Hide Hair"
		starterFrame.Setting_Frame.Frame.Setting_HideHair.TextInfo.Text = "Automatically hides your Roblox Avatar’s hair when transforming"
		starterFrame.Setting_Frame.Frame.Setting_Language.TextName.Text = "Language"
		starterFrame.Setting_Frame.Frame.Setting_Language.TextInfo.Text = "This function supports only Thai language."
		starterFrame.Setting_Frame.Frame.Setting_CameraShake.TextName.Text = "Camera Shake"
		starterFrame.Setting_Frame.Frame.Setting_CameraShake.TextInfo.Text = "Disable it if you feel dizzy."
		starterFrame.Setting_Frame.Frame.Setting_AutoSetSpawn.TextName.Text = "Auto Set Spawn"
		starterFrame.Setting_Frame.Frame.Setting_AutoSetSpawn.TextInfo.Text = "Automatically saves the closest spawn point."
		starterFrame.Setting_Frame.Frame.Setting_SkillButtonStyle.TextName.Text = "Modern Buttons"
		starterFrame.Setting_Frame.Frame.Setting_SkillButtonStyle.TextInfo.Text = "Enable the new Skill UI style."
		starterFrame.Setting_Frame.Frame.Setting_SkillControl.TextName.Text = "Skill Controls"
		starterFrame.Setting_Frame.Frame.Setting_SkillControl.TextInfo.Text = "Choose how skills are activated: Select or Tap."
		buttonFrame.AllyButton.TextLabel.Text = "Ally"
		buttonFrame.ShopButton.TextLabel.Text = "Shop"
		buttonFrame.CrewButton.TextLabel.Text = "Crew"
		buttonFrame.InventoryButton.TextLabel.Text = "Inventory"
		buttonFrame.StatsButton.TextLabel.Text = "Stats"
		buttonFrame.Setting_Button.TextLabel.Text = "Settings"
		buttonFrame.Trade_Button.TextLabel.Text = "Trade"
		buttonFrame.MapButton.TextLabel.Text = "Map"
		buttonFrame.Battlepass_Button.TextLabel.Text = "Battlepass"
		buttonFrame2.AllyButton.TextLabel.Text = "Ally"
		buttonFrame2.ShopButton.TextLabel.Text = "Shop"
		buttonFrame2.CrewButton.TextLabel.Text = "Crew"
		buttonFrame2.InventoryButton.TextLabel.Text = "Inventory"
		buttonFrame2.StatsButton.TextLabel.Text = "Stats"
		buttonFrame2.Setting_Button.TextLabel.Text = "Settings"
		buttonFrame2.Trade_Button.TextLabel.Text = "Trade"
		buttonFrame2.MapButton.TextLabel.Text = "Map"
		buttonFrame2.Battlepass_Button.TextLabel.Text = "Battlepass"
		starterFrame.ShopFrame.GiftFrame.Buy.Text = "Buy"
		starterFrame.ShopFrame.GiftFrame.Cancel.Text = "Cancel"
		starterFrame.ShopFrame.GiftFrame.Gift.Text = "Gift"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.Bonus1.Text = "Bonus <font color=\"#55ff00\">+15%</font> when you purchase gems or money"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.Bonus2.Text = "Bonus<font color=\"#55ff00\"> +20%</font> Exp"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.TextName.Text = "PREMIUM (Benefit)"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.TypeName.Text = "ROBLOX PREMIUM - MONTHLY"
		starterFrame.ShopFrame.ScrollingFrame.MoneyFrame.TypeName.Text = "($) MONEY"
		starterFrame.ShopFrame.ScrollingFrame.ExpFrame.TypeName.Text = "2x EXP BOOSTS - SAVE ON EXIT"
		starterFrame.ShopFrame.ScrollingFrame.GamepassFrame.TypeName.Text = "GAME PASSES PERMANENT"
		starterFrame.ShopFrame.ScrollingFrame.GemFrame.TypeName.Text = "(G) GEM"
		starterFrame.ShopFrame.ScrollingFrame.PermanentFruitFrame.TypeName.Text = "<font size=\"10\"></font>PERMANENT FRUITS"
		starterFrame.ShopFrame.ScrollingFrame.SpecialFrame.TypeName.Text = "PRODUCTS"
		starterFrame.ShopFrame.ScrollingFrame.Permanent.TypeName.Text = "<font size=\"10\"></font> PERMANENT FRUIT <font color=\"#55ff00\">(Fruit will be stored)</font>"
		parent2.QuestFrame.QuestBoard.TextFrame.ExpInfo.ExpInfo.Text = "If your level is over 200 levels above a quest, the Exp reward will be reduced to 1."
	elseif playerStats.Language.Value == "TH" then
		task.spawn(function()
			for _, label in pairs(parent2.StarterFrame.Setting_Frame.Frame:GetDescendants()) do
				if not (label:IsA("TextLabel") and label.Parent.Name == "Menu" and label.Parent.Parent.Name ~= "Setting_PVP") then
					continue
				end

				if label.TextColor3 == Color3.fromRGB(255, 255, 255) then
					label.Text = "เปิด"
				elseif label.TextColor3 == Color3.fromRGB(193, 193, 193) then
					label.Text = "ปิด"
				end
			end
		end)
		parent.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		parent.TextLabel.Text = "ไทย"
		baseFrame.Frame.ExpFrame.ExpText.Text = "ประสบการณ์ " .. _G.Suffix(playerStats.exp.Value) .. "/" .. _G.Suffix(playerStats.expneed.Value)
		baseFrame.Frame.HealthFrame.HealthText.Text = "พลังชีวิต " .. _G.Suffix(humanoid.Health) .. "/" .. _G.Suffix(humanoid.MaxHealth)
		baseFrame.Frame.Lvl.Text = playerStats.lvl.Value

		if playerStats.lvl.Value >= _G.LevelMaxClient then
			baseFrame.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
		end

		baseFrameOG.Frame.ExpFrame.ExpText.Text = "ประสบการณ์ " .. _G.Suffix(playerStats.exp.Value) .. "/" .. _G.Suffix(playerStats.expneed.Value)
		baseFrameOG.Frame.HealthFrame.HealthText.Text = "พลังชีวิต " .. _G.Suffix(humanoid.Health) .. "/" .. _G.Suffix(humanoid.MaxHealth)
		baseFrameOG.Frame.Lvl.Text = playerStats.lvl.Value

		if playerStats.lvl.Value >= _G.LevelMaxClient then
			baseFrameOG.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
		end

		starterFrame.Inventory_Frame.Collectible.TextLabel.Text = "ของสะสม"
		starterFrame.Inventory_Frame.Accessories.TextLabel.Text = "เครื่องประดับ"
		starterFrame.Inventory_Frame.Fruits.TextLabel.Text = "ผลไม้"
		starterFrame.Inventory_Frame.Material.TextLabel.Text = "วัสดุ"
		starterFrame.Inventory_Frame.Swords.TextLabel.Text = "ดาบ"
		starterFrame.StatsFrame.StatsText.Text = "ค่าพลัง"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Defense.ValueName.Text = "พลังชีวิต"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Fruit.ValueName.Text = "พลังผลไม้"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Melee.ValueName.Text = "พลังต่อสู้"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Sword.ValueName.Text = "พลังดาบ"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Armament.ValueName.Text = "เสริมเกราะ"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.SkyJump.ValueName.Text = "เหินเวหา"
		starterFrame.StatsFrame.SkyJumpGuide.Description.Text = "<b>Sky Jump</b> ทำให้คุณกระโดดได้หลายครั้งกลางอากาศ. <br />จำนวนครั้งในการกระโดด คุณสามารถเพิ่มระดับ<br /><stroke color=\"#00A2FF\" joins=\"miter\" thickness=\"2\" transparency=\"0.25\">ทีละ 1 ทุกๆครั้งที่เลเวล 50.</stroke>"
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Sword.ValueNum.Text = "เวล. " .. (playerStats.sword.Value < _G.LevelMaxClient and playerStats.sword.Value or playerStats.sword.Value .. "(สูงสุด)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Melee.ValueNum.Text = "เวล. " .. (playerStats.Melee.Value < _G.LevelMaxClient and playerStats.Melee.Value or playerStats.Melee.Value .. "(สูงสุด)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Fruit.ValueNum.Text = "เวล. " .. (playerStats.DF.Value < _G.LevelMaxClient and playerStats.DF.Value or playerStats.DF.Value .. "(สูงสุด)")
		starterFrame.StatsFrame.StatsPage.ScrollingFrame.Defense.ValueNum.Text = "เวล. " .. (playerStats.Defense.Value < _G.LevelMaxClient and playerStats.Defense.Value or playerStats.Defense.Value .. "(สูงสุด)")
		starterFrame.StatsFrame.StatsPage.PointsFrame.PointText.Text = "พ้อย: " .. playerStats.Points.Value
		starterFrame.Battlepass_Frame.TopicFrame.TopicName.Text = "เลกาซี่พาส SS2"

		if starterFrame.Battlepass_Frame.EasterEggFrame.Visible then
			starterFrame.Battlepass_Frame.TopicFrame.TopicName.Text = "อีสเตอร์พาส"
		end

		starterFrame.Battlepass_Frame.BTPFrame.ConfirmFrame.NameText.Text = "คุณแน่ใจหรือไม่ว่าต้องการปลดล็อค แบทเทิลพาส ด้วย 3,499 มณี"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.UnlockFrame.TextLabel.Text = "หรือ"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.UnlockFrame.UnlockGem.Text = "3,499 มณี"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.FreeLabel.Text = "ฟรี"
		starterFrame.Battlepass_Frame.BTPFrame.Grid.GoldLabel.Text = "ทอง"
		starterFrame.Battlepass_Frame.BTPFrame.ButtonFrame.ClaimAll.TextLabel.Text = "รับทั้งหมด"
		starterFrame.Battlepass_Frame.BTPFrame.ButtonFrame.Close.TextLabel.Text = "ปิด"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.ClaimAll.TextLabel.Text = "รับทั้งหมด"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.Index.TextLabel.Text = "บันทึกไข่"
		starterFrame.Battlepass_Frame.EasterEggFrame.ButtonFrame.Close.TextLabel.Text = "ปิด"
		starterFrame.Battlepass_Frame.EasterEggFrame.TextLabel.Text = "ไข่จะสุ่มเกิดทั่วแมพทุกๆ 1-2 นาที ออกตามหาเพื่อสะสม EXP และปลดล็อครางวัล Limited ก่อนใคร!"
		starterFrame.Gacha_Frame.OpenAll.Text = "เปิดทั้งหมด"
		starterFrame.Gacha_Frame.OpenAll.Outline.Text = "เปิดทั้งหมด"
		starterFrame.Gacha_Frame.SkipLabel.Text = "ข้าม"
		starterFrame.Gacha_Frame.OpenAll.Outline.Text = "ข้าม"
		starterFrame.Gacha_Frame.ContinueLabel.Text = "กดเพื่อไปต่อ"
		starterFrame.Gacha_Frame.ContinueLabel.Outline.Text = "กดเพื่อไปต่อ"
		starterFrame.Gacha_Frame.Frame["10Key"].Text = "ใช้ 10"
		starterFrame.Gacha_Frame.Frame["1Key"].Text = "ใช้ 1"
		starterFrame.Gacha_Frame.Frame.View10Key.Text = "สปอย"
		starterFrame.Gacha_Frame.Frame.ViewFrame.Text1.Text = "รางวัลที่จะได้รับ"
		starterFrame.Gacha_Frame.Frame.ViewFrame.Text2.Text = "รางวัลถูกกำหนดไว้แน่นอนและการันตี"
		starterFrame.AllyFrame.TopicFrame.TopicName.Text = "พันธมิตร"
		starterFrame.DropBoostFrame.TopicFrame.TopicName.Text = "เพิ่มอัตราดรอป"
		starterFrame.FightingStyleFrame.TopicFrame.TopicName.Text = "รูปแบบต่อสู้"
		starterFrame.HomeFrame.TopicFrame.TopicName.Text = "บ้าน"
		starterFrame.MapFrame.TopicFrame.TopicName.Text = "แผนที่"
		starterFrame.Setting_Frame.TopicFrame.TopicName.Text = "ตั้งค่า"
		starterFrame.TradeFrame.TopicFrame.TopicName.Text = "เทรด"
		starterFrame.Setting_Frame.Frame.Setting_FastMode.TextName.Text = "โหมดภาพต่ำ"
		starterFrame.Setting_Frame.Frame.Setting_FastMode.TextInfo.Text = "ลบพื้นผิววัสดุทั้งหมด. (แนะนำสำหรับมือถือ)"
		starterFrame.Setting_Frame.Frame.Setting_Music.TextName.Text = "เพลง"
		starterFrame.Setting_Frame.Frame.Setting_Music.TextInfo.Text = "ปรับระดับเสียงเพลง"
		starterFrame.Setting_Frame.Frame.Setting_DamageText.TextName.Text = "แสดงความเสียหาย"
		starterFrame.Setting_Frame.Frame.Setting_DamageText.TextInfo.Text = "ข้อความแสดงความเสียหายบนเป้าหมาย"
		starterFrame.Setting_Frame.Frame.Setting_AutoPvpOff.TextName.Text = "ปิด PvP อัตโนมัติ"
		starterFrame.Setting_Frame.Frame.Setting_AutoPvpOff.TextInfo.Text = "ปิดใช้งาน PvP เป็นเวลา 40 นาที<font color='#ff0000'>หลังจากเสียชีวิต</font>"
		starterFrame.Setting_Frame.Frame.Setting_PVP.TextName.Text = "PvP"
		starterFrame.Setting_Frame.Frame.Setting_PVP.TextInfo.Text = "เปิด PvP กลับหลังจากตายในการต่อสู้"
		starterFrame.Setting_Frame.Frame.Setting_PVP.Menu.TextLabel.Text = "เปิด PvP"
		starterFrame.Setting_Frame.Frame.Setting_HideAcc.TextName.Text = "ซ่อนเครื่องประดับ"
		starterFrame.Setting_Frame.Frame.Setting_HideAcc.TextInfo.Text = "ซ่อนอุปกรณ์เสริมทั้งหมดยกเว้นฟองสบู่"
		starterFrame.Setting_Frame.Frame.Setting_RetroUI.TextName.Text = "แถบเลือดดั้งเดิม"
		starterFrame.Setting_Frame.Frame.Setting_RetroUI.TextInfo.Text = "เลือกใช้ระหว่าง UI ดั้งเดิม หรือ UI แบบใหม่"
		starterFrame.Setting_Frame.Frame.Setting_DodgeText.TextName.Text = "ข้อความหลบหลีก"
		starterFrame.Setting_Frame.Frame.Setting_DodgeText.TextInfo.Text = "แสดงข้อความหลบหลีกบนหน้าจอของคุณ"
		starterFrame.Setting_Frame.Frame.Setting_JumpText.TextName.Text = "ข้อความกระโดด"
		starterFrame.Setting_Frame.Frame.Setting_JumpText.TextInfo.Text = "แสดงข้อความกระโดดบนหน้าจอของคุณ"
		starterFrame.Setting_Frame.Frame.Setting_ComboText.TextName.Text = "ข้อความคอมโบ"
		starterFrame.Setting_Frame.Frame.Setting_ComboText.TextInfo.Text = "แสดงความเสียหายบนหน้าจอของคุณ"
		starterFrame.Setting_Frame.Frame.Setting_AllyEffects.TextName.Text = "เอฟเฟกต์พันธมิตร"
		starterFrame.Setting_Frame.Frame.Setting_AllyEffects.TextInfo.Text = "เอฟเฟกต์พันธมิตร เปิดมันถ้าคุณรู้สึกแลค"
		starterFrame.Setting_Frame.Frame.Setting_HideAllEffects.TextName.Text = "ซ่อนเอฟเฟกต์ทั้งหมด (ยกเว้นคุณ)"
		starterFrame.Setting_Frame.Frame.Setting_HideAllEffects.TextInfo.Text = "โปรดระวัง! คุณจะไม่รู้และไม่เห็นการโจมตีของศัตรู!!"
		starterFrame.Setting_Frame.Frame.Setting_HideHair.TextName.Text = "ซ่อนผม"
		starterFrame.Setting_Frame.Frame.Setting_HideHair.TextInfo.Text = "ซ่อนผมของ Roblox Avatar อัตโนมัติเมื่อเข้าสู่ร่างแปลงร่าง"
		starterFrame.Setting_Frame.Frame.Setting_Language.TextName.Text = "ภาษา"
		starterFrame.Setting_Frame.Frame.Setting_Language.TextInfo.Text = "ฟังก์ชันนี้รองรับภาษาไทยเท่านั้น"
		starterFrame.Setting_Frame.Frame.Setting_CameraShake.TextName.Text = "จอสั่น"
		starterFrame.Setting_Frame.Frame.Setting_CameraShake.TextInfo.Text = "ปิดการใช้งานหากคุณรู้สึกเวียนหัว"
		starterFrame.Setting_Frame.Frame.Setting_AutoSetSpawn.TextName.Text = "บันทึกจุดเกิดอัตโนมัติ"
		starterFrame.Setting_Frame.Frame.Setting_AutoSetSpawn.TextInfo.Text = "บันทึกจุดเกิดที่ใกล้ที่สุดโดยอัตโนมัติ"
		starterFrame.Setting_Frame.Frame.Setting_SkillButtonStyle.TextName.Text = "ปุ่มแบบโมเดิร์น"
		starterFrame.Setting_Frame.Frame.Setting_SkillButtonStyle.TextInfo.Text = "เปิดใช้งานปุ่มสกิลแบบใหม่."
		starterFrame.Setting_Frame.Frame.Setting_SkillControl.TextName.Text = "การควบคุมสกิล"
		starterFrame.Setting_Frame.Frame.Setting_SkillControl.TextInfo.Text = "รูปแบบวิธีใช้งานสกิล: เลือก หรือ แตะ"
		buttonFrame.AllyButton.TextLabel.Text = "กลุ่มพันธมิตร"
		buttonFrame.ShopButton.TextLabel.Text = "ร้านค้า"
		buttonFrame.CrewButton.TextLabel.Text = "แคลน"
		buttonFrame.InventoryButton.TextLabel.Text = "กระเป๋า"
		buttonFrame.StatsButton.TextLabel.Text = "ค่าพลัง"
		buttonFrame.Setting_Button.TextLabel.Text = "ตั้งค่า"
		buttonFrame.Trade_Button.TextLabel.Text = "แลกเปลี่ยน"
		buttonFrame.MapButton.TextLabel.Text = "แผนที่"
		buttonFrame.Battlepass_Button.TextLabel.Text = "แบทเทิลพาส"
		buttonFrame2.AllyButton.TextLabel.Text = "กลุ่มพันธมิตร"
		buttonFrame2.ShopButton.TextLabel.Text = "ร้านค้า"
		buttonFrame2.CrewButton.TextLabel.Text = "แคลน"
		buttonFrame2.InventoryButton.TextLabel.Text = "กระเป๋า"
		buttonFrame2.StatsButton.TextLabel.Text = "ค่าพลัง"
		buttonFrame2.Setting_Button.TextLabel.Text = "ตั้งค่า"
		buttonFrame2.Trade_Button.TextLabel.Text = "แลกเปลี่ยน"
		buttonFrame2.MapButton.TextLabel.Text = "แผนที่"
		buttonFrame2.Battlepass_Button.TextLabel.Text = "แบทเทิลพาส"
		starterFrame.ShopFrame.GiftFrame.Buy.Text = "ซื้อ"
		starterFrame.ShopFrame.GiftFrame.Cancel.Text = "ยกเลิก"
		starterFrame.ShopFrame.GiftFrame.Gift.Text = "ส่งของขวัญ"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.Bonus1.Text = "โบนัสเพิ่ม <font color=\"#55ff00\">+15%</font> เมื่อซื้อเงินหรือมณี"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.Bonus2.Text = "โบนัสเพิ่ม <font color=\"#55ff00\">+20%</font> ค่าประสบการณ์"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.Frame.Premium.TextName.Text = "พรีเมี่ยม (ประโยชน์)"
		starterFrame.ShopFrame.ScrollingFrame.PremiumFrame.TypeName.Text = "Roblox พรีเมี่ยม - รายเดือน"
		starterFrame.ShopFrame.ScrollingFrame.MoneyFrame.TypeName.Text = "($) เงิน"
		starterFrame.ShopFrame.ScrollingFrame.ExpFrame.TypeName.Text = "บูส x2 ค่าประสบการณ์ - เซฟเมื่อออกเกม"
		starterFrame.ShopFrame.ScrollingFrame.GamepassFrame.TypeName.Text = "เกมพาสถาวร"
		starterFrame.ShopFrame.ScrollingFrame.GemFrame.TypeName.Text = "(G) มณี"
		starterFrame.ShopFrame.ScrollingFrame.PermanentFruitFrame.TypeName.Text = "<font size=\"10\"></font>ผลไม้ถาวร"
		starterFrame.ShopFrame.ScrollingFrame.SpecialFrame.TypeName.Text = "สินค้า"
		starterFrame.ShopFrame.ScrollingFrame.Permanent.TypeName.Text = "<font size=\"10\"></font> ผลถาวร <font color=\"#55ff00\">(ผลจะถูกเก็บเข้ากระเป๋าไว้)</font>"
		parent2.QuestFrame.QuestBoard.TextFrame.ExpInfo.ExpInfo.Text = "หากเลเวลของคุณต่างจาก เลเวลของภารกิจเกิน 200 ค่าประสบการณ์จะกลายเป็น 1"
	end
end

Check()
parent.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		_G.ClickFrameEffect()
	end)

	if playerStats.Language.Value == "US" then
		game.TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		}):Play()
		parent.TextLabel.Text = "ไทย"
		parent.Remote:InvokeServer("TH")
	elseif playerStats.Language.Value == "TH" then
		game.TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		}):Play()
		parent.TextLabel.Text = "US"
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5035769082",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		parent.Remote:InvokeServer("US")
	end

	Check()
	spawn(function()
		wait(1)
		v = true
	end)
end)
local LocalizationService = game:GetService("LocalizationService")
local success, result = pcall(function()
	return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer)
end)
localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("StarterFrame"):WaitForChild("Setting_Frame")
local parent3 = parent.Parent

if success and result == "TH" then
	parent3.Visible = true
else
	print("GetCountryRegionForPlayerAsync failed: " .. result)
end