_G.Cooldowns = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function _G.ClearBv(instance)
	for _, child in pairs(instance:GetChildren()) do
		if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity")) then
			continue
		end

		if child:GetAttribute("DontClear") then
			continue
		end

		child:Destroy()
	end
end

function _G.ClearBvDragon(instance)
	for _, child in pairs(instance:GetChildren()) do
		if not ((child:IsA("BodyVelocity") or child:IsA("BodyGyro")) and (child.Name == "BodyVelocity" or child.Name == "BodyGyro")) then
			continue
		end

		child:Destroy()
	end
end

function _G.SoundInstance(data)
	local parent = data.Parent or nil

	if not parent or data.Clone then
		return
	end

	local soundId = data.SoundId or ""
	local debris = data.Debris or 1
	local rollOffMinDistance = data.RollOffMinDistance or 10
	local rollOffMaxDistance = data.RollOffMaxDistance or 750

	if not data.RollOffMode then
		local _ = Enum.RollOffMode.InverseTapered
	end

	local volume = data.Volume or 1
	local sound = Instance.new("Sound")
	sound.Volume = volume
	sound.RollOffMinDistance = rollOffMinDistance
	sound.RollOffMaxDistance = rollOffMaxDistance
	sound.SoundId = soundId
	sound.Parent = parent
	sound:Play()
	_G.PU:Dust(sound, debris)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local MobileInteract = require(ReplicatedStorage.Chest.Assets.Modules.MobileInteract)
local TaskManager = require(ReplicatedStorage.Chest.Assets.Modules.TaskManager)
local MouseLockModule = require(ReplicatedStorage.Chest.Modules.MouseLockModule)
local mouseLockInit = MouseLockModule.Init()
shared.MouseLockInit = mouseLockInit
local maid = TaskManager.new()
local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.Character
localPlayer:FindFirstChild("PlayerStats")
local guiObject = nil

function IsSelectType()
	if not (_G.IsMobile and _G.CheckSettingClient(localPlayer, "Setting_SkillButtonStyle")) then
		return
	end

	if _G.CheckSettingClient(localPlayer, "Setting_SkillControl") then
		return true
	end
end

function ConvertToSkillKey(instance)
	if instance.Name == "Button" then
		return instance.Parent.Name, "Legacy"
	end

	return instance.Name:gsub("Skill", ""), "Modern"
end

function UpdateMobile()
	if not UserInputService.TouchEnabled then
		return
	end

	localPlayer.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame")
	maid:DoCleaning()

	local function SetupSkillButton(button)
		if not (button:IsA("ImageButton") and string.find(button.Name, "Skill") and button.Name:gsub("Skill", "")) then
			return
		end

		maid:GiveTask(button.MouseButton1Down:Connect(function()
			if not IsSelectType() then
				return
			end

			guiObject = button

			if not ActivateSkill({
				UserInputType = Enum.UserInputType.Touch,
				UserInputState = Enum.UserInputState.Begin,
				Position = UserInputService:GetMouseLocation()
			}) then
				guiObject = nil
			end
		end))
		maid:GiveTask(button.MouseButton1Click:Connect(function()
			if IsSelectType() then
				return
			end

			if guiObject == button then
				if guiObject then
					guiObject.SelectLabel.Visible = false
				end

				guiObject = nil
			else
				if guiObject then
					guiObject.SelectLabel.Visible = false
				end

				guiObject = button
				guiObject.SelectLabel.Visible = true
			end
		end))
	end

	for _, v2 in ipairs({ "DFFrame", "FSFrame", "SWFrame" }) do
		local v3 = MobileInteract[v2]

		if not (v3 and typeof(v3) == "Instance") then
			continue
		end

		for _, child in pairs(v3:GetChildren()) do
			SetupSkillButton(child)
		end

		maid:GiveTask(v3.ChildAdded:Connect(SetupSkillButton))
	end
end

local v2 = {}
local v3 = nil
local character, playerStats

repeat
	wait()
	character = localPlayer.Character
	playerStats = localPlayer:FindFirstChild("PlayerStats")
until character and playerStats and localPlayer:FindFirstChild("DataLoaded")

local thread = nil

function _G.ConquerorCooldown(_)
	if thread then
		task.cancel(thread)
	end

	thread = task.spawn(function()
		_G.ConquerorDB = nil
		local value = playerStats.ArmamentColor.Value
		_G.ArmamentColorUpdateClient(value)
		character:SetAttribute("Conqueror", true)
		task.wait(_G.ConquerorCDClient)
		character:SetAttribute("Conqueror", nil)
		_G.ConquerorDB = true
	end)
end

local lastTime = tick()
local lastTime2 = tick()
local lastTime3 = tick()
local lastTime4 = tick()
game:GetService("RunService")
local skillCooldown = localPlayer.PlayerGui:WaitForChild("SkillCooldown")
script:WaitForChild("Data")
local SkillReqData = require(script.Data.Fruit:WaitForChild("SkillReqData"))
local SkillNameData = require(script.Data.Fruit:WaitForChild("SkillNameData"))
local SkillNameData_ThaiVer = require(script.Data.Fruit:WaitForChild("SkillNameData_ThaiVer"))
local SkillReqData_Sword = require(script.Data.Sword:WaitForChild("SkillReqData_Sword"))
local SkillNameData_Sword = require(script.Data.Sword:WaitForChild("SkillNameData_Sword"))
local SkillNameData_Sword_Thaiver = require(script.Data.Sword:WaitForChild("SkillNameData_Sword_Thaiver"))
local SkillReqData_FS = require(script.Data.FightStyle:WaitForChild("SkillReqData_FS"))
local SkillNameData_FS = require(script.Data.FightStyle:WaitForChild("SkillNameData_FS"))
local SkillNameData_FS_ThaiVer = require(script.Data.FightStyle:WaitForChild("SkillNameData_FS_ThaiVer"))
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local Requirement = require(ReplicatedStorage.Chest.Modules.Requirement)
ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown.Event:Connect(function(p, p2, duration)
	skillCooldown[p .. "Frame"][p2].Frame.Frame.Size = UDim2.new(0.73, 0, 0.85, 0)
	game.TweenService:Create(
		skillCooldown[p .. "Frame"][p2].Frame.Frame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, 0, 0.85, 0)
		}
	):Play()

	if not _G.IsMobile then
		return
	end

	MobileInteract[`{p}FrameCooldown`](p2, duration)
end)

function UpdateCooldownFrame()
	local dFName = localPlayer.PlayerStats:WaitForChild("DFName", 25)

	if script.FruitSkills:FindFirstChild(dFName.Value .. "_Client") then
		local module = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits[dFName.Value .. "_Data"])

		for k, v4 in pairs(module) do
			local v5 = k:sub(2, #k)

			if not (string.lower(v5) == "respawn" and tick() - lastTime < v4) then
				continue
			end

			local v6 = k:sub(1, 1)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", v6, v4)
		end
	end
end

function UpdateCooldownFrame_DF()
	local dFName = localPlayer.PlayerStats:WaitForChild("DFName", 25)

	if script.FruitSkills:FindFirstChild(dFName.Value .. "_Client") then
		local module = require(ReplicatedStorage.Chest.Modules.SkillData.Fruits[dFName.Value .. "_Data"])

		for k, v4 in pairs(module) do
			local v5 = k:sub(2, #k)

			if not (string.lower(v5) == "respawn" and tick() - lastTime2 < v4) then
				continue
			end

			local v6 = k:sub(1, 1)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("DF", v6, v4)
		end
	end
end

function UpdateCooldownFrame_FS()
	local fightingStyle = localPlayer.PlayerStats:WaitForChild("FightingStyle", 25)

	if script.FightingStyleSkills:FindFirstChild(fightingStyle.Value .. "_Client") then
		local module = require(ReplicatedStorage.Chest.Modules.SkillData.Styles[fightingStyle.Value .. "_Data"])

		for k, v4 in pairs(module) do
			local v5 = k:sub(2, #k)

			if not (string.lower(v5) == "respawn" and tick() - lastTime3 < v4) then
				continue
			end

			local v6 = k:sub(1, 1)
			ReplicatedStorage.Chest.Remotes.Bindables.MoveCooldown:Fire("FS", v6, v4)
		end
	end
end

function DisableSkillCooldownFrames()
	for _, frame in pairs(skillCooldown:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		for _, frame2 in pairs(frame:GetChildren()) do
			if frame2:IsA("Frame") then
				frame2.Visible = false
			end
		end
	end

	if _G.IsMobile then
		MobileInteract.VisibleAllSkillFrame(false)
	end
end

local changedConnection = nil

function MeterFunc(instance)
	if changedConnection and changedConnection.Connected then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	local power = instance:FindFirstChild("Power")

	if power then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateBar(p)
			local v4 = math.clamp(power.Value / power.MaxValue, 0, 1) * 0.99

			if p then
				skillCooldown.Meters.Frame.Line.Size = UDim2.new(v4, 0, 0.85, 0)
			else
				TweenService:Create(skillCooldown.Meters.Frame.Line, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = UDim2.new(v4, 0, 0.85, 0)
				}):Play()
			end
		end

		UpdateBar(true) -- equivalent call inferred; original call site unknown
		changedConnection = power.Changed:Connect(function()
			wait()
			UpdateBar()
		end)
	end
end

function UpdateSkillsFrame(p)
	local v4 = p or character:FindFirstChildOfClass("Tool")

	if not v4 then
		return
	end

	local v5 = SkillReqData[v4.Name] or SkillReqData_Sword[v4.Name] or SkillReqData_FS[v4.Name]

	if not v5 then
		return
	end

	local v6 = script.FruitSkills:FindFirstChild(v4.Name .. "_Client") or script.SwordSkills:FindFirstChild(v4.Name .. "_Client") or script.FightingStyleSkills:FindFirstChild(v4.Name .. "_Client")

	if not v6 then
		return
	end

	DisableSkillCooldownFrames()
	local name = v4.Name:sub(1, #v4.Name / 2)
	local v7 = SkillNameData
	local v8 = SkillNameData_ThaiVer
	local v9, v10

	if v6:IsDescendantOf(script.SwordSkills) then
		name = v4.Name:gsub("%s+", "")
		v7 = SkillNameData_Sword
		v8 = SkillNameData_Sword_Thaiver
		v9 = "SW"
		v10 = "sword"
	else
		v9 = "DF"
		v10 = "DF"
	end

	if v6:IsDescendantOf(script.FightingStyleSkills) then
		name = v4.Name
		v7 = SkillNameData_FS
		v8 = SkillNameData_FS_ThaiVer
		v9 = "FS"
		v10 = "Melee"
	end

	local v11 = Requirement[v4.Name]

	for k, v12 in pairs(v5) do
		local v13 = k:sub(1, 1)
		local child = skillCooldown[v9 .. "Frame"]:FindFirstChild(v13)

		if not (child and (string.lower((string.sub(k, 2, #k))) ~= "awake" or _G.CheckAwakeClient(
			localPlayer,
			name .. v13
		))) then
			continue
		end

		if v12 <= localPlayer.PlayerStats[v10].Value then
			skillCooldown[v9 .. "Frame"][v13].Locked.Visible = false
		else
			skillCooldown[v9 .. "Frame"][v13].Locked.Visible = true
		end

		skillCooldown[v9 .. "Frame"][v13].Locked.SkillsRequire.Text = "[" .. v12 .. "]"

		if k == "B" and v4.Name == "GumGum" and localPlayer.PlayerStats.GumGear4Th.Value ~= "Snakeman" then
			skillCooldown[v9 .. "Frame"][v13].Locked.Visible = true
		end

		local v14 = _G.CheckAwakeClient(localPlayer, name .. v13)
		local v15 = v7[v4.Name] and v7[v4.Name][v13]

		if v14 and v7[v4.Name] and v7[v4.Name][v13 .. "Awake"] then
			v15 = v7[v4.Name] and v7[v4.Name][v13 .. "Awake"]
		end

		if localPlayer.PlayerStats.Language.Value == "TH" then
			v15 = v8[v4.Name] and v8[v4.Name][k]

			if v14 and v8[v4.Name] and v8[v4.Name][k .. "Awake"] then
				v15 = v8[v4.Name] and v8[v4.Name][k .. "Awake"]
			end
		end

		if (character:FindFirstChild("Phoenix_Model") or character:FindFirstChild("MammothModel") or character:FindFirstChild("Allosaurus") or character:FindFirstChild("Pteranodon_KL") or character:FindFirstChild("Tree_KL") or character:FindFirstChild("Demon_KL") or character:FindFirstChild("Brachiosaurus") or character:FindFirstChild("Spinosaurus")) and v7[v4.Name .. "Second"] and v7[v4.Name .. "Second"][v13] then
			if v14 and v7[v4.Name .. "Second"] and v7[v4.Name .. "Second"][v13 .. "Awake"] then
				v15 = v7[v4.Name .. "Second"] and v7[v4.Name .. "Second"][v13 .. "Awake"]
			else
				v15 = v7[v4.Name .. "Second"][v13]
			end

			if localPlayer.PlayerStats.Language.Value == "TH" then
				if v14 and v8[v4.Name .. "Second"] and v8[v4.Name .. "Second"][k .. "Awake"] then
					v15 = v8[v4.Name .. "Second"] and v8[v4.Name .. "Second"][k .. "Awake"]
				else
					v15 = v8[v4.Name .. "Second"][v13]
				end
			end
		end

		if v4.Name == "GumGum" and character:FindFirstChild("SecondForm") and character:FindFirstChild("ThirdForm") then
			if character.SecondForm.Value then
				v15 = v7[v4.Name][v13 .. "Second"]

				if localPlayer.PlayerStats.Language.Value == "TH" then
					v15 = v8[v4.Name][v13 .. "Second"]
				end
			elseif character.ThirdForm.Value then
				v15 = v7[v4.Name][v13 .. "Third"]

				if localPlayer.PlayerStats.Language.Value == "TH" then
					v15 = v8[v4.Name][v13 .. "Third"]
				end
			else
				v15 = v7[v4.Name][v13]

				if localPlayer.PlayerStats.Language.Value == "TH" then
					v15 = v8[v4.Name][v13]
				end
			end
		end

		local diable = character:FindFirstChild("Diable")

		if diable and diable.Value == true and v7[v4.Name][v13 .. "Azure"] then
			v15 = v7[v4.Name][v13 .. "Azure"]

			if localPlayer.PlayerStats.Language.Value == "TH" then
				v15 = v8[v4.Name][v13 .. "Azure"]
			end
		end

		if character:FindFirstChild("ToyTrex") and v7[v4.Name][v13 .. "Rex"] then
			v15 = v7[v4.Name][v13 .. "Rex"]

			if localPlayer.PlayerStats.Language.Value == "TH" then
				v15 = v8[v4.Name][v13 .. "Rex"]
			end
		end

		skillCooldown[v9 .. "Frame"][v13].SkillsNames.Text = v15 or "N/A"

		if v11 and v11[v13] and not v11[v13](localPlayer) then
			child.Visible = nil
		else
			child.Visible = true
		end
	end

	if skillCooldown[v9 .. "Frame"]:FindFirstChild("Power") then
		skillCooldown[v9 .. "Frame"].Power.Visible = false
		local v12 = SkillNameData_FS[v4.Name]

		if v12 and v12.Power then
			skillCooldown[v9 .. "Frame"].Power.Visible = true
			skillCooldown[v9 .. "Frame"].Power.SkillsNames.Text = v12.Power
		end

		local v13 = SkillNameData[v4.Name]

		if v13 and v13.Power then
			skillCooldown[v9 .. "Frame"].Power.Visible = true
			skillCooldown[v9 .. "Frame"].Power.SkillsNames.Text = v13.Power
		end

		local v14 = SkillNameData_Sword[v4.Name]

		if v14 and v14.Power then
			skillCooldown[v9 .. "Frame"].Power.Visible = true
			skillCooldown[v9 .. "Frame"].Power.SkillsNames.Text = v14.Power
		end
	end

	local v12 = skillCooldown[v9 .. "Frame"]
	v12.Visible = nil
	v12.Position = UDim2.fromScale(1, 0.565)
	TweenService:Create(v12, TweenInfo.new(0.15), {
		Position = UDim2.fromScale(0.828, 0.565)
	}):Play()

	if _G.CheckSettingClient(localPlayer, "Setting_SkillButtonStyle") and _G.IsMobile then
		MobileInteract[`{v9}FrameUpdateRequirementSkills`](v4.Name, v5)
	else
		v12.Visible = true
	end

	if CustomNames[name] then
		name = CustomNames[name]
	end

	local v13 = character:FindFirstChild(name .. "Passives") or character:FindFirstChild(name .. "_Passives") or character:FindFirstChild(v4.Name .. "_Passives")

	if v13 then
		skillCooldown.Meters.Position = UDim2.fromScale(1.1, 0.56)
		skillCooldown.Meters.Visible = true
		TweenService:Create(skillCooldown.Meters, TweenInfo.new(0.15), {
			Position = UDim2.fromScale(0.914, 0.56)
		}):Play()
		MeterFunc(v13)
	end

	local v14 = skillCooldown[v9 .. "Frame"].AbsolutePosition.Y + skillCooldown[v9 .. "Frame"].AbsoluteSize.Y - skillCooldown[v9 .. "Frame"].UIListLayout.AbsoluteContentSize.Y
	skillCooldown.Meters.Position = UDim2.new(
		skillCooldown.Meters.Position.X.Scale,
		skillCooldown.Meters.Position.X.Offset,
		0,
		v14
	)
	local flag = true

	for _, image in pairs(skillCooldown.DFFrame:GetChildren()) do
		if not image:IsA("ImageLabel") or image.Visible then
			continue
		end

		flag = nil
	end

	if flag then
		skillCooldown.DFFrame.E.Position = UDim2.new(-0.149, 0, -0.20899999999999996, 0)
	else
		skillCooldown.DFFrame.E.Position = UDim2.new(-0.149, 0, 0.007, 0)
	end
end

function SetupCharacter()
	if changedConnection and changedConnection.Connected then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	skillCooldown.Meters.Visible = nil

	for _, frame in pairs(skillCooldown.DFFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	for _, frame in pairs(skillCooldown.SWFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	for _, frame in pairs(skillCooldown.FSFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	character.ChildAdded:Connect(function(tool)
		task.wait()

		if not tool:IsA("Tool") then
			return
		end

		UpdateSkillsFrame(tool)
	end)
	character.ChildRemoved:Connect(function(tool)
		task.wait()

		if not tool:IsA("Tool") then
			return
		end

		skillCooldown.Meters.Visible = nil

		if changedConnection and changedConnection.Connected then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		for _, frame in pairs(skillCooldown.DFFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		for _, frame in pairs(skillCooldown.SWFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		for _, frame in pairs(skillCooldown.FSFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		if _G.IsMobile then
			MobileInteract.VisibleAllSkillFrame(nil)
		end

		if guiObject then
			guiObject.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

			if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
				guiObject.SelectLabel.Visible = false
			end

			guiObject = nil
		end

		local v4 = script.FruitSkills:FindFirstChild(tool.Name .. "_Client") or script.SwordSkills:FindFirstChild(tool.Name .. "_Client")

		if not v4 then
			return
		end

		local module = require(v4)

		if module.Untransform then
			module.Untransform()
		end
	end)
	lastTime = tick()
	lastTime2 = tick()
	lastTime3 = tick()
	UpdateCooldownFrame_DF()
	UpdateCooldownFrame_FS()
	task.spawn(function()
		wait()

		if localPlayer.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or localPlayer.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT" then
			_G.ConquerorCooldown(localPlayer)
		end
	end)
end

function DebugSkill(player, p, p2, value, p3)
	warn("[[CLIENT]] >>>", p3)

	if _G.Cooldowns[p .. p2] then
		local v4 = value or 1
		task.spawn(function()
			for _, folder in pairs(player.Character:GetChildren()) do
				if folder:IsA("Folder") and folder.Name == "TotalDoing" then
					folder:Destroy()
				end
			end
		end)
		task.spawn(function()
			wait(v4)
			_G.Cooldowns[p .. p2] = nil
		end)
	end
end

SetupCharacter(character)
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	SetupCharacter(character)
end)
local v4 = {
	"SkillZ",
	"SkillX",
	"SkillC",
	"SkillV",
	"SkillB",
	"SkillE"
}

function IsInSkillButton(p)
	local position = p.Position
	local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)

	for _, v5 in ipairs(guiObjectsAtPosition) do
		if table.find(v4, v5.Name) then
			return true
		end
	end
end

function ActivateSkill(data, _)
	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	local v5 = script.FruitSkills:FindFirstChild(tool.Name .. "_Client") or script.SwordSkills:FindFirstChild(tool.Name .. "_Client") or script.FightingStyleSkills:FindFirstChild(tool.Name .. "_Client")

	if not v5 then
		return
	end

	local v6 = "DFName"
	local v7 = "DF"

	if v5:IsDescendantOf(script.SwordSkills) then
		if localPlayer.PlayerStats.SwordName.Value ~= tool.Name then
			return
		end

		v7 = "SW"
		v6 = "SwordName"
	elseif v5:IsDescendantOf(script.FruitSkills) then
		if localPlayer.PlayerStats.DFName.Value ~= tool.Name then
			return
		end

		v7 = "DF"
		v6 = "DFName"
	elseif v5:IsDescendantOf(script.FightingStyleSkills) then
		if localPlayer.PlayerStats.FightingStyle.Value ~= tool.Name then
			return
		end

		v7 = "FS"
		v6 = "FightingStyle"
	end

	local v8 = tostring(data.KeyCode):gsub("Enum.KeyCode.", "")
	v2[v7] = v2[v7] or {}
	local v9

	if data.KeyCode == Enum.KeyCode.Z or data.KeyCode == Enum.KeyCode.ButtonX then
		v9 = "Z"
	elseif data.KeyCode == Enum.KeyCode.X or data.KeyCode == Enum.KeyCode.ButtonY then
		v9 = "X"
	elseif data.KeyCode == Enum.KeyCode.C or data.KeyCode == Enum.KeyCode.ButtonB then
		v9 = "C"
	elseif data.KeyCode == Enum.KeyCode.V or data.KeyCode == Enum.KeyCode.ButtonL2 then
		v9 = "V"
	elseif data.KeyCode == Enum.KeyCode.B or data.KeyCode == Enum.KeyCode.ButtonR2 then
		v9 = "B"
	elseif data.KeyCode == Enum.KeyCode.E or data.KeyCode == Enum.KeyCode.DPadRight then
		v9 = "E"
	else
		v9 = v8
	end

	local v10 = data.UserInputType == Enum.UserInputType.MouseButton1 and "M1" or v9
	local v11 = ReplicatedStorage.Chest.Modules.SkillData.Fruits:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Rods:FindFirstChild(tool.Name .. "_Data")

	if not v11 then
		return
	end

	local module = require(v11)
	local v12 = data.KeyCode == Enum.KeyCode.ButtonR2 and not module.B and "M1" or v10
	local v13 = nil

	if data.UserInputType == Enum.UserInputType.Touch and data.UserInputState == Enum.UserInputState.Begin then
		local function Available()
			local v14 = IsSelectType()

			if (v14 or IsInSkillButton(data)) and not v14 then
				return
			end

			return true
		end

		if guiObject and not _G.IsInSticks(data) then
			local v14 = IsSelectType()

			if not (v14 or IsInSkillButton(data)) or v14 then
				v12 = ConvertToSkillKey(guiObject)
				v3 = ConvertToSkillKey(guiObject)

				if character:FindFirstChild("TotalDoing") then
					v13 = true
				end
			elseif not (guiObject or _G.IsInSticks(data)) then
				lastTime4 = tick()
			end
		elseif not (guiObject or _G.IsInSticks(data)) then
			lastTime4 = tick()
		end
	end

	if module[v12 .. "Require"] then
		local v14 = v7 == "SW" and "sword" or v7 == "FS" and "Melee" or "DF"

		if localPlayer.PlayerStats[v14].Value < module[v12 .. "Require"] then
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire(
				"Stats Require",
				{ v14, v12, module[v12 .. "Require"] }
			)
			return
		end
	end

	if module[v12 .. "Respawn"] then
		if v7 == "DF" and tick() - lastTime2 < module[v12 .. "Respawn"] or v7 == "FS" and tick() - lastTime3 < module[v12 .. "Respawn"] then
			return
		end
	end

	local v14 = v6 and Requirement[localPlayer.PlayerStats[v6].Value]

	if v14 and v14[v12] and not v14[v12](localPlayer) then
		return
	end

	local module2 = require(v5)
	local cooldownGroup

	if guiObject then
		cooldownGroup = guiObject:FindFirstChild("CooldownGroup")
	end

	if not module2[v12] then
		return true
	end

	local isEnabled = mouseLockInit:IsEnabled()
	local v16 = guiObject
	local flag

	if not v2[v7][v12] then
		v2[v7][v12] = true

		if not isEnabled and IsSelectType() then
			mouseLockInit:ToggleShiftLock(true)
		end

		if cooldownGroup then
			cooldownGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
			cooldownGroup.BackgroundTransparency = 0.5
		end

		if guiObject and (guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel")) then
			guiObject.SelectLabel.Visible = false
		end

		flag = true
	end

	local success, result = pcall(function()
		module2[v12]()
	end)
	v2[v7][v12] = nil

	if flag then
		if not isEnabled and IsSelectType() then
			mouseLockInit:ToggleShiftLock(false)
		end

		if cooldownGroup then
			cooldownGroup.BackgroundTransparency = 1
		end
	end

	if not success then
		DebugSkill(localPlayer, v7, v12, module[v12], result)
	end

	if v13 then
		return true
	end

	if v16 ~= guiObject then
		return
	end

	if guiObject then
		guiObject.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
			guiObject.SelectLabel.Visible = false
		end
	end

	guiObject = nil
	v3 = nil
	return true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) or (humanoid.Health <= 0 or humanoid.WalkSpeed == 0) then
		return
	end

	if humanoidRootPart.Anchored then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	if not tool:GetAttribute("Fish") then
		ActivateSkill(input, gameProcessed)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 or input.UserInputType == Enum.UserInputType.Touch then
		local mainGui = localPlayer.PlayerGui.MainGui
		local DialogueModule = require(mainGui.Dialogue.DialogueModule)
		DialogueModule.Init("Fish Interaction")
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	local keyCode = input.KeyCode
	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	local v5 = script.FruitSkills:FindFirstChild(tool.Name .. "_Client") or script.SwordSkills:FindFirstChild(tool.Name .. "_Client") or script.FightingStyleSkills:FindFirstChild(tool.Name .. "_Client")

	if not v5 then
		return
	end

	local v6

	if v5:IsDescendantOf(script.SwordSkills) then
		if localPlayer.PlayerStats.SwordName.Value ~= tool.Name then
			return
		end

		v6 = "SW"
	else
		v6 = "DF"
	end

	if v5:IsDescendantOf(script.FruitSkills) then
		if localPlayer.PlayerStats.DFName.Value ~= tool.Name then
			return
		end

		v6 = "DF"
	end

	if v5:IsDescendantOf(script.FightingStyleSkills) then
		if localPlayer.PlayerStats.FightingStyle.Value ~= tool.Name then
			return
		end

		v6 = "FS"
	end

	local v7 = tostring(keyCode):gsub("Enum.KeyCode.", "")
	local v8

	if input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.ButtonX then
		v8 = "Z"
	elseif input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.ButtonY then
		v8 = "X"
	elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonB then
		v8 = "C"
	elseif input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.ButtonL2 then
		v8 = "V"
	elseif input.KeyCode == Enum.KeyCode.B or input.KeyCode == Enum.KeyCode.ButtonR2 then
		v8 = "B"
	elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.DPadRight then
		v8 = "E"
	else
		v8 = v7
	end

	local v9 = input.UserInputType == Enum.UserInputType.MouseButton1 and "M1" or v8
	local v10 = input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.End and "M1" or v9
	local v11 = ReplicatedStorage.Chest.Modules.SkillData.Fruits:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(tool.Name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Rods:FindFirstChild(tool.Name .. "_Data")

	if not v11 then
		return
	end

	local module = require(v11)

	if module[v10 .. "Respawn"] then
		if v6 == "DF" and tick() - lastTime2 < module[v10 .. "Respawn"] or v6 == "FS" and tick() - lastTime3 < module[v10 .. "Respawn"] then
			return
		end
	end

	local v12 = input.KeyCode == Enum.KeyCode.ButtonR2 and not module.E and "M1" or v10

	if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.End then
		if v3 then
			v12 = v3
		elseif not guiObject and not _G.IsInSticks(input) and not gameProcessed and tick() - lastTime4 <= 0.15 then
			local module2 = require(v5)

			if module2.M1 then
				local success, result = pcall(function()
					module2.M1()
				end)

				if not success then
					DebugSkill(localPlayer, v6, v12, module.M1, result)
				end
			end

			return
		end
	end

	local module2 = require(v5)

	if module2[v12] then
		module2.Deactive(v12)
	end
end)

for _, button in pairs(skillCooldown:GetDescendants()) do
	if not (button.Name == "Button" and button:IsA("TextButton")) then
		continue
	end

	local v5 = button
	button.MouseButton1Click:Connect(function()
		if guiObject == v5 then
			if guiObject then
				guiObject.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end

			guiObject = nil
		else
			if guiObject then
				guiObject.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end

			guiObject = v5
			guiObject.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		end
	end)
end

local v5 = {
	AT1 = true,
	AT2 = true,
	AT3 = true,
	AT4 = true,
	HumanAT1 = true,
	HumanAT2 = true,
	HumanAT3 = true,
	HumanAT4 = true,
	Attack1 = true,
	Attack2 = true,
	Attack3 = true,
	Attack4 = true,
	Combat1 = true,
	Combat2 = true,
	Combat3 = true,
	Combat4 = true
}
local class = {}

function class.__index(_, p)
	return class[p]
end

function class.__newindex(_, value, p)
	if value == "ForceResetCooldown" and p then
		for k, v6 in pairs(class) do
			if type(v6) == "boolean" then
				class[k] = nil
			end
		end
	else
		class[value] = p

		if value == "RACEAWAKEN" or value == "SHIPSKILL" then
			return
		end

		if p then
			local v6 = value:sub(1, 2)
			local v7 = value:gsub(v6, "")

			if not (skillCooldown:FindFirstChild(v6 .. "Frame") and skillCooldown[v6 .. "Frame"]:FindFirstChild(v7)) then
				return
			end

			skillCooldown[v6 .. "Frame"][v7].Frame.Frame.Size = UDim2.new(0.73, 0, 0.85, 0)

			if character:FindFirstChild("Humanoid") then
				for _, v8 in pairs(character.Humanoid:GetPlayingAnimationTracks()) do
					if v8.Name == "Animation" then
						v8:Stop()
					elseif string.find(v8.Name, "AnimationF") or string.find(v8.Name, "AnimationL") or string.find(
						v8.Name,
						"AnimationR"
					) then
						v8:Stop()
					elseif v5[v8.Name] then
						v8:Stop()
					end
				end
			end
		end
	end
end

setmetatable(_G.Cooldowns, class)

function _G.IsEquiping(childName)
	if character:FindFirstChild(childName) and character[childName]:IsA("Tool") then
		return true
	end
end

task.spawn(function()
	repeat
		wait()
	until localPlayer:FindFirstChild("PlayerStats")

	local playerStats2 = localPlayer.PlayerStats
	playerStats2:WaitForChild("DFName").Changed:Connect(function()
		lastTime2 = tick()
		UpdateCooldownFrame_DF()
	end)
	playerStats2:WaitForChild("FightingStyle").Changed:Connect(function()
		lastTime3 = tick()
		UpdateCooldownFrame_FS()
	end)
	playerStats2:WaitForChild("Misc").Changed:Connect(function()
		UpdateSkillsFrame()
	end)
	playerStats2:WaitForChild("DF").Changed:Connect(function()
		UpdateSkillsFrame()
	end)
	playerStats2:WaitForChild("Language").Changed:Connect(function()
		UpdateSkillsFrame()
	end)
	game.ReplicatedStorage.Chest.Remotes.Events.SkillName.OnClientEvent:Connect(function()
		UpdateSkillsFrame()
	end)
end)
workspace:WaitForChild("Effects").ChildAdded:Connect(function(child)
	if child:GetAttribute("NoAutoDelete") then
		return
	end

	task.wait(300)

	if child:IsDescendantOf(workspace.Effects) then
		child:Destroy()
	end
end)
task.spawn(UpdateMobile)