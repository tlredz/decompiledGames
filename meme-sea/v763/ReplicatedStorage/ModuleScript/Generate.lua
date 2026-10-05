-- failed to load script (decompiled with syntax error):
-- sNhWmrggoJroKOwUkxoHQHuYm:917: Expected identifier when parsing expression, got `Attacked_{

local createVector = vector.create
local Generate = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local modules = ReplicatedStorage:WaitForChild("Modules")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local instanceTemplate = assets:WaitForChild("InstanceTemplate")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local showEvents = otherEvent:WaitForChild("ShowEvents")
local soundEvents = otherEvent:WaitForChild("SoundEvents")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local visuals = workspace:WaitForChild("Visuals")
local skills = workspace:WaitForChild("Skills")
local SetText = require(moduleScript:WaitForChild("SetText"))
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local MonsterSettings = require(moduleScript:WaitForChild("MonsterSettings"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local RockScript = require(modules:WaitForChild("RockScript"))
local toggle = mainEvents:WaitForChild("Toggle")
local clientEnemy = miscEvents:WaitForChild("ClientEnemy")
local sendSound = soundEvents:WaitForChild("SendSound")
local show = showEvents:WaitForChild("Show")
local client_Skills = skillEvents:WaitForChild("Client_Skills")
local clientBossSkills = skillEvents:WaitForChild("ClientBossSkills")
local clientEffect = skillEvents:WaitForChild("ClientEffect")
local instinct = skillEvents:WaitForChild("Instinct")
local server_Hitbox = skillEvents:WaitForChild("Server_Hitbox")
local rarity = ItemInfo.Rarity
local broke_Cooldown = Setting.Setting.Instinct_Info.Broke_Cooldown
local inCombat_Timer = instanceTemplate:WaitForChild("InCombat_Timer")
local filterDescendantsInstances = { workspace.Island, workspace.Raids }

function Generate.Skill_Holding(parent)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyPosition.D = 100
	bodyPosition.Position = parent.Position
	bodyPosition.Parent = parent
	return bodyPosition
end

function Generate.TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

function Generate.Skill_Rotating(parent)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Parent = parent
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = parent:FindFirstChild("RootAttachment")
	alignOrientation.Responsiveness = 200
	return alignOrientation
end

function Generate.Generate_Ring(cFrame, p, p2, value, value2, p3, p4)
	local size = p or createVector(2.5, 0.1, 2.5)
	local size2 = p2 or createVector(10, 1, 10)
	local color = p3 or Color3.fromRGB(255, 255, 255)
	local material = p4 or Enum.Material.Neon
	local v6 = value or 0.25
	local transparency = value2 or 0
	local clone = visualFX.VFX.RingPart:Clone()
	clone.Anchored = true
	clone.CFrame = cFrame
	Debris:AddItem(clone, 2)
	local ring = clone:FindFirstChild("Ring")

	if ring then
		ring.Size = size
		ring.Color = color
		ring.Material = material
		ring.Transparency = transparency
		clone.Parent = visuals
		TweenService:Create(ring, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size2,
			Transparency = 1
		}):Play()
	end
end

function Generate.Generate_FlyingRing(cFrame, p, p2, value, value2, p3, p4)
	local size = p or createVector(2.5, 0.1, 2.5)
	local size2 = p2 or createVector(10, 1, 10)
	local color = p3 or Color3.fromRGB(255, 255, 255)
	local material = p4 or Enum.Material.Neon
	local v6 = value or 0.25
	local transparency = value2 or 0
	local clone = visualFX.VFX.FlyingRing:Clone()
	clone.Anchored = true
	clone.CFrame = cFrame
	Debris:AddItem(clone, 2)
	local ring = clone:FindFirstChild("Ring")

	if ring then
		ring.Size = size
		ring.Color = color
		ring.Material = material
		ring.Transparency = transparency
		clone.Parent = visuals
		TweenService:Create(ring, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size2,
			Transparency = 1
		}):Play()
	end
end

function Generate.Throwing_Rock(_, instance, data)
	local hitPart = data.HitPart
	local _ = data.Distance or 5
	local amount = data.Amount or 5
	local duration = data.Duration or 2
	local assembly = data.Assembly
	local canCollide = data.CanCollide ~= false
	local trailEnable = data.TrailEnable ~= false
	local rock_Duration = data.Rock_Duration or 0.2
	local left_Right = data.Left_Right
	local up_Down = data.Up_Down
	local front_Back = data.Front_Back
	local size_X = data.Size_X
	local size_Y = data.Size_Y
	local size_Z = data.Size_Z

	if instance and instance.Parent then
		local color

		if hitPart then
			color = hitPart.Color
		else
			color = Color3.fromRGB(255, 255, 255)
		end

		local material

		if hitPart then
			material = hitPart.Material
		else
			material = Enum.Material.Concrete
		end

		for _ = 1, amount do
			local v2 = math.random(left_Right.Min, left_Right.Max)
			local v3 = math.random(up_Down.Min, up_Down.Max)
			local v4 = math.random(front_Back.Min, front_Back.Max)
			local number = Random.new():NextNumber(size_X.Min, size_X.Max)
			local number2 = Random.new():NextNumber(size_Y.Min, size_Y.Max)
			local number3 = Random.new():NextNumber(size_Z.Min, size_Z.Max)
			local clone = visualFX.Rocks[`Rock{math.random(1, 3)}`]:Clone()
			clone.Size = Vector3.new(clone.Size.X * number, clone.Size.Y * number2, clone.Size.Z * number3)
			clone.CanCollide = canCollide
			clone.Color = color
			clone.Material = material

			if assembly then
				clone.CFrame = CFrame.new(instance.Position)
				clone.AssemblyLinearVelocity = Vector3.new(v2, v3, v4)
				clone.AssemblyAngularVelocity = Vector3.new(v2, v3, v4)
			else
				clone.CFrame = instance.CFrame * CFrame.Angles(math.rad(v2), 0, (math.rad(v4)))
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.P = 2500
				bodyVelocity.Velocity = clone.CFrame.UpVector * v3
				bodyVelocity.Parent = clone
				Debris:AddItem(bodyVelocity, rock_Duration)
			end

			clone.Parent = skills
			clone.CollisionGroup = "Player"
			clone.Start.Trail.Color = ColorSequence.new(color)
			clone.Start.Trail.Enabled = trailEnable
			Debris:AddItem(clone, duration)
			task.delay(duration - 1, function()
				if clone and clone.Parent then
					if clone.Start.Trail.Enabled then
						clone.Start.Trail.Enabled = false
					end

					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end)
		end
	end
end

function Generate.Aura_Training(instance, value: number)
	if instance:GetAttribute("Using_Aura") then
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		local playerData = playerFromCharacter and playerFromCharacter:FindFirstChild("PlayerData")

		if playerData then
			local auraExp = playerData:FindFirstChild("AuraExp")
			local auraMaxExp = playerData:FindFirstChild("AuraMaxExp")

			if auraExp and auraMaxExp and auraExp.Value < auraMaxExp.Value then
				auraExp.Value += value or 1
			end
		end
	end
end

function Generate.Instinct_Training(instance, value: number)
	if instance:GetAttribute("Using_Instinct") then
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		local playerData = playerFromCharacter and playerFromCharacter:FindFirstChild("PlayerData")

		if playerData then
			local dodgeExp = playerData:FindFirstChild("DodgeExp")
			local dodgeMaxExp = playerData:FindFirstChild("DodgeMaxExp")

			if dodgeExp and dodgeMaxExp and dodgeExp.Value < dodgeMaxExp.Value then
				dodgeExp.Value += value or 1
			end
		end
	end
end

function Generate.Check_Legit(instance, instance2, p, childName: string)
	local playerData = instance and instance:GetAttribute("LoadedData") and instance:FindFirstChild("PlayerData")

	if not playerData then
		return false
	end

	if p.Equipped_Needed then
		if (playerData.PowerEquip.Value == childName or playerData.SwordEquip.Value == childName or playerData.CombatEquip.Value == childName) and instance2:FindFirstChild(childName) then
			return true
		end
	elseif playerData.PowerEquip.Value == childName or playerData.SwordEquip.Value == childName or playerData.CombatEquip.Value == childName then
		return true
	end

	return false
end

function Generate.Check_Type(p: string)
	if rarity.Weapon[p] then
		return "Weapon"
	end

	if rarity.Power[p] then
		return "Power"
	end

	return "FightingStyle"
end

function Generate.Check_Target(instance, instance2, instance3, instance4, instance5, flag: boolean)
	if not (Generate.CheckExist(instance4) and Generate.CheckExist(instance5)) then
		return false
	end

	local summoner

	if instance5:HasTag("Pet") then
		summoner = instance5:GetAttribute("Summoner")
	else
		summoner = instance5.Name
	end

	if instance5:GetAttribute("Raid_Enemy") then
		if instance:GetAttribute("Raiding") and not instance5:HasTag((`Raid_{instance:GetAttribute("Raiding")}`)) then
			return true
		end

		if instance:GetAttribute("Raiding") == nil then
			return true
		end
	end

	if summoner == instance.Name then
		return true
	end

	if Generate.Check_Party(instance3) and instance3:FindFirstChild(summoner) then
		if flag then
			if instance:GetAttribute("TH") then
				SetText.SetText(instance, "CustomMessage", {
					Message = "คุณไม่สามารถโจมตีสมาชิกในปาร์ตี้ของคุณได้!",
					MessageColor = "Red"
				})
			else
				SetText.SetText(instance, "CustomMessage", {
					Message = "You can't attack your party members!",
					MessageColor = "Red"
				})
			end
		end

		return true
	else
		if instance2 then
			if instance4:GetAttribute("Safezone") or instance5:GetAttribute("Safezone") then
				if flag then
					if instance:GetAttribute("TH") then
						SetText.SetText(instance, "CustomMessage", {
							Message = "คุณไม่สามารถโจมตีผู้เล่นในเซฟโซนได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(instance, "CustomMessage", {
							Message = "You can't attack players in a safe zone!",
							MessageColor = "Red"
						})
					end
				end

				return true
			elseif instance2:GetAttribute("Raiding") or instance:GetAttribute("Raiding") then
				if flag then
					if instance:GetAttribute("TH") then
						SetText.SetText(instance, "CustomMessage", {
							Message = "คุณไม่สามารถโจมตีผู้เล่นในดันเจี้ยนได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(instance, "CustomMessage", {
							Message = "You can't attack players in the raid!",
							MessageColor = "Red"
						})
					end
				end

				return true
			elseif instance4:GetAttribute("PvpDisabled") or instance:GetAttribute("PvpDisabled") then
				if flag then
					if instance:GetAttribute("TH") then
						SetText.SetText(instance, "CustomMessage", {
							Message = [[
⚔️   Pvp ของคุณถูกปิดอยู่เป็นเวลา 10 นาที!   ⚔️ 
 💀   สามารถเปิดได้โดยการกดปุ่มหัวกะโหลกบนหน้าจอ!   💀]],
							MessageColor = "Red",
							CustomSize = UDim2.new(1, 0, 0.065, 6)
						})
					else
						SetText.SetText(instance, "CustomMessage", {
							Message = [[
⚔️   Your pvp is currently disabled for 10 minutes!   ⚔️ 
 💀   Enable it back by pressing the skull button!   💀]],
							MessageColor = "Red",
							CustomSize = UDim2.new(1, 0, 0.055, 6)
						})
					end
				end

				return true
			elseif instance5:GetAttribute("PvpDisabled") or instance2:GetAttribute("PvpDisabled") then
				if flag then
					if instance:GetAttribute("TH") then
						SetText.SetText(instance, "CustomMessage", {
							Message = "คุณไม่สามารถโจมตีผู้เล่นที่เพิ่งพ่ายแพ้จากการต่อสู้เมื่อครู่นี้ได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(instance, "CustomMessage", {
							Message = "You can't attack a player who just died recently!",
							MessageColor = "Red"
						})
					end
				end

				return true
			end
		end

		if instance2 and instance.Team == Teams.Cheems and instance2.Team == Teams.Cheems then
			if flag then
				if instance:GetAttribute("TH") then
					SetText.SetText(instance, "CustomMessage", {
						Message = "คุณไม่สามารถโจมตีผู้เล่นในทีมเดียวกันกับคุณได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(instance, "CustomMessage", {
						Message = "You can't attack players on the same team!",
						MessageColor = "Red"
					})
				end
			end

			return true
		end
	end

	return false
end

function Generate.Check_Teleport(p, instance, instance2, instance3, instance4)
	local humanoid = instance4:FindFirstChild("Humanoid")

	if humanoid and humanoid.Parent and humanoid.Sit == true then
		return false
	end

	if instance4.Name == instance3.Name or Generate.Check_Party(instance2) and instance2:FindFirstChild(instance4.Name) then
		return true
	end

	if instance and p.Team == Teams.Cheems and instance.Team == Teams.Cheems then
		return true
	end

	if not (Generate.CheckExist(instance3) and Generate.CheckExist(instance4) and instance) then
		return false
	end

	if not (instance4:GetAttribute("Safezone") or instance3:GetAttribute("PvpDisabled") or instance4:GetAttribute("PvpDisabled")) then
		return true
	end

	if instance:GetAttribute("Raiding") then
		if instance:GetAttribute("TH") then
			SetText.SetText(instance, "CustomMessage", {
				Message = "คุณไม่สามารถวาร์ประหว่างที่กำลังลงดันเจี้ยนอยู่ได้!",
				MessageColor = "Red"
			})
		else
			SetText.SetText(instance, "CustomMessage", {
				Message = "You can't teleport while raiding!",
				MessageColor = "Red"
			})
		end

		return false
	elseif instance4:GetAttribute("PvpDisabled") then
		if instance:GetAttribute("TH") then
			SetText.SetText(instance, "CustomMessage", {
				Message = [[
⚔️   Pvp ของคุณถูกปิดอยู่เป็นเวลา 10 นาที!   ⚔️ 
 💀   สามารถเปิดได้โดยการกดปุ่มหัวกะโหลกบนหน้าจอ!   💀]],
				MessageColor = "Red",
				CustomSize = UDim2.new(1, 0, 0.065, 6)
			})
		else
			SetText.SetText(instance, "CustomMessage", {
				Message = [[
⚔️   Your pvp is currently disabled for 10 minutes!   ⚔️ 
 💀   Enable it back by pressing the skull button!   💀]],
				MessageColor = "Red",
				CustomSize = UDim2.new(1, 0, 0.055, 6)
			})
		end

		return false
	elseif instance3:GetAttribute("PvpDisabled") then
		if instance:GetAttribute("TH") then
			SetText.SetText(instance, "CustomMessage", {
				Message = "เจ้าของประตูวาร์ปปิด Pvp ของเขาอยู่. คุณไม่สามารถวาร์ปได้ยกเว้นคุณจะอยู่ในปาร์ตี้ของเขา!",
				MessageColor = "Red"
			})
		else
			SetText.SetText(instance, "CustomMessage", {
				Message = "The Portal Owner has pvp disabled. You can't teleport unless you are in their party!",
				MessageColor = "Red"
			})
		end

		return false
	elseif instance4:GetAttribute("Safezone") then
		if instance:GetAttribute("TH") then
			SetText.SetText(instance, "CustomMessage", {
				Message = "คุณไม่สามารถวาร์ปในเซฟโซนได้ ยกเว้นคุณจะอยู่ในปาร์ตี้ของเขา!",
				MessageColor = "Red"
			})
		else
			SetText.SetText(instance, "CustomMessage", {
				Message = "You can't teleport in a safe zone unless you are in their party!",
				MessageColor = "Red"
			})
		end

		return false
	end

	return false
end

function Generate.Get_Cooldown(instance)
	if not (instance and instance.Parent) then
		return
	end

	for _, boolValue in ipairs(instance:GetChildren()) do
		if boolValue:IsA("BoolValue") and string.find(boolValue.Name, "Holding") then
			return true
		end
	end

	return false
end

function Generate.Add_Instance(name: string, parent, p: number, p2, p3)
	if Generate.CheckExist(parent) and not parent:FindFirstChild(name) then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = name
		boolValue.Parent = parent

		if p then
			Debris:AddItem(boolValue, p)
		end

		if p2 and p3 then
			boolValue:SetAttribute(p2, p3)
		end
	end
end

function Generate.Add_Instinct(name: string, parent, p: number)
	if Generate.CheckExist(parent) then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = name
		boolValue.Parent = parent

		if p then
			Debris:AddItem(boolValue, p)
		end
	end
end

function Generate.Hotkey_Frame(instance, childName: string, childName2: string, p: string)
	local playerGui = instance:FindFirstChild("PlayerGui")
	local child

	if playerGui and playerGui.Parent then
		child = playerGui:FindFirstChild(childName)
	end

	if child then
		local skill_Container = child:FindFirstChild("Skill_Container")
		local child2 = skill_Container and skill_Container:FindFirstChild(childName2)

		if child2 then
			if p == "Hotkey" then
				return child2
			end

			if p == "Cooldown" then
				local cooldown

				if child2 then
					cooldown = child2:FindFirstChild("Cooldown")
				end

				if cooldown then
					return cooldown
				end
			end
		end
	end
end

function Generate:Stunning(p: string, value: number, duration: number)
	if self and self.Parent then
		if p == "Add" then
			self.Value += value or 1
		elseif p == "Remove" then
			self.Value -= value or 1
		elseif p == "Not_Walkable" then
			local stun = self.Parent:FindFirstChild("Stun")

			if stun then
				self.WalkSpeed = 0
				stun.Value += value or 1
			end
		elseif p == "Walkable" then
			local stun = self.Parent:FindFirstChild("Stun")

			if stun then
				self.WalkSpeed = 30
				stun.Value -= value or 1
			end
		elseif p == "Anchored" then
			self.Anchored = true
		elseif p == "Unanchored" then
			self.Anchored = false
		elseif p == "Unspeed" then
			self:SetAttribute("Old_Speed", self.WalkSpeed)
			self.WalkSpeed = 0
		elseif p == "Speed" then
			if self:GetAttribute("Old_Speed") then
				self.WalkSpeed = self:GetAttribute("Old_Speed")
				self:SetAttribute("Old_Speed", nil)
			end
		elseif p == "Unjump" then
			self:SetAttribute("Old_Jump", self.JumpPower)
			self.JumpPower = 0
		elseif p == "Jump" then
			if self:GetAttribute("Old_Jump") then
				self.JumpPower = self:GetAttribute("Old_Jump")
				self:SetAttribute("Old_Jump", nil)
			end
		elseif p == "Duration" then
			self.Value += value
			task.delay(duration, function()
				self.Value -= value
			end)
		end
	end
end

function Generate.Add_Hit(instance, parent, p, parent2, parent3, value: number)
	if parent3 then
		local name

		if instance:HasTag("Pet") then
			name = parent.Name
		else
			name = instance.Name
		end

		if parent3:FindFirstChild(name) == nil then
			if p then
				for _, intValue in ipairs(parent3:GetChildren()) do
					if intValue:IsA("IntValue") then
						intValue:Destroy()
					end
				end
			end

			local intValue = Instance.new("IntValue")
			intValue.Name = name
			intValue.Value = value or 0
			intValue.Parent = parent3
		elseif parent3:FindFirstChild(name) then
			local child = parent3:FindFirstChild(name)

			if child then
				Increase_Damage(child, value)
			end
		end
	end

	if (parent:GetAttribute("Invisible") == nil or parent2:GetAttribute("Raid_Boss")) and Generate.CheckIfAlive(parent) and parent2:GetAttribute("Target") and parent2:GetAttribute("Target") ~= instance.Name then
		parent2:SetAttribute("Target", instance.Name)
	end

	if p then
		parent:SetAttribute("InCombat", workspace:GetServerTimeNow())
		parent2:SetAttribute("InCombat", workspace:GetServerTimeNow())
		local inCombat_Timer2 = parent2:FindFirstChild("InCombat_Timer")
		local inCombat_Timer3 = parent:FindFirstChild("InCombat_Timer")

		if not inCombat_Timer2 then
			local clone = inCombat_Timer:Clone()
			clone.Parent = parent2
			clone.Enabled = true
		end

		if not inCombat_Timer3 then
			local clone = inCombat_Timer:Clone()
			clone.Parent = parent
			clone.Enabled = true
		end
	end
end

function Generate.IsReady(instance)
	local v2 = true

	if not (instance and instance.Parent) then
		v2 = false
		return false
	end

	if instance:FindFirstChild("Stun") and instance:FindFirstChild("Stun").Value > 0 then
		v2 = false
	end

	return instance:FindFirstChild("Humanoid").Sit ~= true and v2
end

function Generate.Hit_Position(p, p2, p3)
	local raycastParams

	if typeof(p2) == "RaycastParams" then
		raycastParams = p2
	else
		raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {
			p2,
			workspace.Skills,
			workspace.Region,
			workspace.Visuals,
			workspace.Location,
			workspace.Sea,
			workspace.Leaderboard,
			workspace.CameraFolder,
			workspace.SpawningPower,
			workspace.Character,
			workspace.Monster
		}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	local raycastResult = workspace:Raycast(p.Origin, p.Direction * p3, raycastParams)

	if raycastResult then
		return raycastResult.Position
	end

	return p.Origin + p.Direction * p3
end

function Generate.Tool_Equipped(instance, childName: string)
	if instance and instance.Parent and instance:FindFirstChild(childName) then
		return true
	end

	return false
end

function Generate.ClearBV(model, p)
	if p then
		if Generate.CheckExist(model) then
			if model:IsA("Model") then
				local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					for _, child in ipairs(humanoidRootPart:GetChildren()) do
						if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity") or child:IsA("AlignPosition") or child:IsA("AlignOrientation")) then
							continue
						end

						if child.Name == p or child:GetAttribute("Invincible") then
							continue
						end

						child:Destroy()
					end
				end
			else
				for _, child in ipairs(model:GetChildren()) do
					if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity") or child:IsA("AlignPosition") or child:IsA("AlignOrientation")) then
						continue
					end

					if child.Name == p or child:GetAttribute("Invincible") then
						continue
					end

					child:Destroy()
				end
			end
		end
	elseif Generate.CheckExist(model) then
		if model:IsA("Model") then
			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				for _, child in ipairs(humanoidRootPart:GetChildren()) do
					if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity") or child:IsA("AlignPosition") or child:IsA("AlignOrientation")) then
						continue
					end

					if child:GetAttribute("Invincible") then
						continue
					end

					child:Destroy()
				end
			end
		else
			for _, child in ipairs(model:GetChildren()) do
				if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity") or child:IsA("AlignPosition") or child:IsA("AlignOrientation")) then
					continue
				end

				if child:GetAttribute("Invincible") then
					continue
				end

				child:Destroy()
			end
		end
	end
end

function Generate.CheckBV(model)
	local v2 = false

	if not Generate.CheckExist(model) then
		return false
	end

	if model:IsA("Model") then
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			for _, child in ipairs(humanoidRootPart:GetChildren()) do
				if (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity")) and not child:GetAttribute("Invincible") then
					return true
				end
			end

			return v2
		end
	else
		for _, child in ipairs(model:GetChildren()) do
			if (child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("LinearVelocity")) and not child:GetAttribute("Invincible") then
				return true
			end
		end
	end

	return v2
end

function Generate.Check_Party(p)
	if p and p.Parent then
		return true
	end

	return false
end

function Generate.CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

function Generate.CheckTool(instance)
	if instance and instance.Parent and instance:GetAttribute("Using") then
		return true
	end

	return false
end

function Generate.CheckExist(p)
	if p and p.Parent then
		return true
	end

	return false
end

function Generate.Play_SkillAnimation(animator, itemType: string, itemName: string, skill: string, animation_Name: string)
	if animator and animator.Parent then
		toggle:FireAllClients("Play_SkillAnimation", {
			Animator = animator,
			ItemType = itemType,
			ItemName = itemName,
			Skill = skill,
			Animation_Name = animation_Name
		})
	end
end

function Generate.Stop_Animation(animator, animation_Name: string)
	toggle:FireAllClients("Stop_Animation", {
		Animator = animator,
		Animation_Name = animation_Name
	})
end

function Generate:SetParticle()
	if self:IsA("ParticleEmitter") then
		if UserSettings().GameSettings.SavedQualityLevel == Enum.SavedQualitySetting.Automatic then
			if self:GetAttribute("True_Rate") then
				self.Rate = self:GetAttribute("True_Rate")
			end
		else
			local v2 = math.clamp(UserSettings().GameSettings.SavedQualityLevel.Value, 1, 10)

			if not self:GetAttribute("True_Rate") then
				self:SetAttribute("True_Rate", self.Rate)
			end

			self.Rate = (self:GetAttribute("True_Rate") or 10) * 10 / v2 or 5
		end
	end
end

function Generate.CheckInParent(instance, childName)
	if instance:FindFirstChild(childName) then
		return true
	end

	return false
end

function Generate.Generate_Rock(p, p2, p3, p4, p5, p6)
	RockScript.Ground(p, p2, p3, p4, p5, p6)
end

function Generate.Generate_Ground(p, p2, p3, p4, p5)
	RockScript.SpawnRock(p, p2, p3, p4, p5)
end

function Generate.Generate_FlyingRock(p, p2, p3, p4, p5, p6)
	RockScript.FlyingRock(p, p2, p3, p4, p5, p6)
end

function Generate.Client_Explosion(instance, p, instance2, p2, p3, p4, p5, data)
	`Attacked_{p3}_{p4}`

	if instance:GetAttribute("NoCooldown") then
		`Attacked_{p3}_{p4}_{tick()}`
	end

	local now = os.clock()
	local total = 0
	local flag = true
	local heartbeatConnection = nil
	local moving_Speed

	if data then
		moving_Speed = data.Moving_Speed
	else
		moving_Speed = nil
	end

	local rootPart_Position

	if data then
		rootPart_Position = data.RootPart_Position
	else
		rootPart_Position = nil
	end

	local mouse_Position

	if data then
		mouse_Position = data.Mouse_Position
	else
		mouse_Position = nil
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local now2 = os.clock()

		if now + p5 <= now2 or not Generate.CheckExist(instance2) or instance2:GetAttribute("Exploded") then
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			if not instance2:GetAttribute("Exploded") and moving_Speed then
				instance2.CFrame += CFrame.new(rootPart_Position, mouse_Position).LookVector * moving_Speed * dt
			end

			if total >= 0.02 or flag then
				if flag then
					flag = false
				end

				total = 0
				local partBoundsInBox = workspace:GetPartBoundsInBox(instance2.CFrame, instance2.Size, p2)

				if #partBoundsInBox > 0 then
					for _, part in ipairs(partBoundsInBox) do
						if not (part and part.Parent) then
							continue
						end

						local parent

						if part.Parent then
							parent = part.Parent
						end

						if parent == p or not (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation")) or instance2:GetAttribute("Exploded") then
							continue
						end

						local party = instance:FindFirstChild("Party")
						local v2

						if parent:HasTag("Pet") then
							v2 = Players:FindFirstChild(parent:GetAttribute("Summoner"))
						else
							v2 = Players:GetPlayerFromCharacter(parent)
						end

						if not Generate.Check_Target(instance, v2, party, p, parent) then
							instance2:SetAttribute("Exploded", true)
						end
					end
				end
			end
		end
	end)
end

function Generate.Client_Hitbox(instance, p, instance2, p2, p3, p4, p5, state)
	local now = os.clock()
	local total = 0
	local flag = true
	local heartbeatConnection = nil
	local v2 = ItemSettings[p3][p4]

	if v2 then
		local max_Loop

		if v2.Max_Loop then
			max_Loop = v2.Max_Loop
		end

		local thread = nil
		local loop

		if max_Loop and state and state.Loop then
			loop = state.Loop
		end

		local moving_Speed

		if state then
			moving_Speed = state.Moving_Speed
		end

		if state then
			local _ = state.Mouse_Position
		end

		local skill_Type

		if state and state.Skill_Type then
			skill_Type = state.Skill_Type
		else
			skill_Type = nil
		end

		local duration_Phase = v2.Duration_Phase or nil
		local hitbox_Duration = v2.Hitbox_Duration or nil
		local delayHitbox_Duration = v2.DelayHitbox_Duration or nil
		local isExplosion = v2.IsExplosion or nil
		local v3

		if moving_Speed and moving_Speed >= 400 or state.Spinning_Loop then
			v3 = 0.001
		elseif moving_Speed and moving_Speed >= 300 then
			v3 = 0.01
		elseif moving_Speed and moving_Speed >= 200 then
			v3 = 0.02
		elseif moving_Speed and moving_Speed >= 100 then
			v3 = 0.075
		else
			v3 = 0.1
		end

		local formatted = `Attacked_{p3}_{p4}`

		if delayHitbox_Duration then
			task.delay(delayHitbox_Duration, function()
				if instance2 and instance2.Parent then
					instance2:SetAttribute("Hitted", true)
				end
			end)
		end

		if loop and loop <= max_Loop then
			formatted = `Attacked_{p3}_{p4}_{loop}`
		elseif instance:GetAttribute("NoCooldown") then
			local now2 = tick()
			state.Current_Time = now2
			formatted = `Attacked_{p3}_{p4}_{now2}`
		end

		if duration_Phase then
			if isExplosion then
				state.Explosion_CFrame = instance2.CFrame
				server_Hitbox:FireServer(p, p3, p4, state)
			end
		else
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				local now2 = os.clock()

				if now + p5 <= now2 or not Generate.CheckExist(instance2) then
					if Generate.CheckExist(instance2) then
						instance2:Destroy()
					end

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end
				elseif v3 <= total or flag then
					if flag then
						flag = false
					end

					total = 0
					local partBoundsInBox = workspace:GetPartBoundsInBox(instance2.CFrame, instance2.Size, p2)

					if #partBoundsInBox > 0 then
						for _, v4 in ipairs(partBoundsInBox) do
							if not (v4 and v4.Parent) then
								continue
							end

							local parent

							if v4.Parent then
								parent = v4.Parent
							end

							local v5 = skill_Type ~= "Pillar" and skill_Type ~= "Prison" and skill_Type ~= "Heal_Prison" and skill_Type ~= "Dash" or not instance2:GetAttribute("Hitted")

							if not (Generate.CheckIfAlive(p) and parent ~= p and Generate.CheckIfAlive(parent) and v5) then
								continue
							end

							local attacks_Debounce = parent:FindFirstChild("Attacks_Debounce")

							if not (attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil) then
								continue
							end

							local party = instance:FindFirstChild("Party")
							local v6

							if parent:HasTag("Pet") then
								v6 = Players:FindFirstChild(parent:GetAttribute("Summoner"))
							else
								v6 = Players:GetPlayerFromCharacter(parent)
							end

							if Generate.Check_Target(instance, v6, party, p, parent) then
								continue
							end

							if state.Single_Target and Generate.CheckExist(instance2) then
								instance2:Destroy()
							end

							if skill_Type and (skill_Type == "Prison" or skill_Type == "Heal_Prison" or skill_Type == "Dash") then
								if hitbox_Duration then
									if not thread then
										thread = task.delay(hitbox_Duration, function()
											if instance2 and instance2.Parent then
												instance2:SetAttribute("Hitted", true)
											end
										end)
									end
								else
									instance2:SetAttribute("Hitted", true)
								end
							end

							server_Hitbox:FireServer(parent, p3, p4, state)
						end
					end
				end
			end)
		end
	end
end

if RunService:IsServer() then
	function Generate.Skill_Hitbox(instance, instance2, p, p2, p3, p4, action, p6, data)
		local v2 = ItemSettings[p4][action]

		if v2 then
			local v3 = not v2.Max_Phase and 1 or v2.Max_Phase
			local duration_Phase

			if v2.Duration_Phase then
				duration_Phase = v2.Duration_Phase
			else
				duration_Phase = nil
			end

			local cooldown = instance:FindFirstChild("Cooldown")

			if Generate.Check_Legit(instance, instance2, v2, p4) and duration_Phase and cooldown then
				local formatted = `Attacked_{p4}_{action}`

				if instance:GetAttribute("NoCooldown") then
					formatted = `Attacked_{p4}_{action}_{tick()}`
				end

				local max_Distance = v2.Max_Distance or 500
				local now = os.clock()
				local total = 0
				local flag = true
				local heartbeatConnection = nil
				local clone

				if v2.Knockback then
					clone = table.clone(v2.Knockback)
				end

				local clone2

				if v2.BodyPosition then
					clone2 = table.clone(v2.BodyPosition)
				end

				local v4 = v2.Drag_Position and true or nil
				local loop_CFrame = data.Loop_CFrame
				local loop_Tick = data.Loop_Tick
				local check_Type = Generate.Check_Type(p4)
				local v5 = (clone or clone2 or v4) and {} or nil
				local now2

				if loop_Tick then
					now2 = tick()
				else
					now2 = nil
				end

				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					total += dt
					local now3 = os.clock()

					if now + p6 <= now3 or v2.Holding_Skill and cooldown:FindFirstChild((`{check_Type}_{action}_Holding`)) == nil then
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						if v5 then
							table.clear(v5)
							v5 = nil
						end
					else
						if loop_CFrame and instance2 and instance2.Parent then
							local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart then
								p2 = humanoidRootPart.CFrame * loop_CFrame
							end
						else
							local humanoidRootPart = loop_Tick and instance2 and instance2.Parent and tick() - now2 <= 0.1 and instance2:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart then
								p2 = humanoidRootPart.CFrame * loop_Tick
							end
						end

						if total >= 0.1 or flag then
							if flag then
								flag = false
							end

							total = 0
							local partBoundsInBox = workspace:GetPartBoundsInBox(p2, p.Size, p3)

							if #partBoundsInBox > 0 then
								for _, v6 in ipairs(partBoundsInBox) do
									if not (v6 and v6.Parent) then
										continue
									end

									local parent

									if v6.Parent then
										parent = v6.Parent
									end

									if not (Generate.CheckIfAlive(instance2) and parent ~= instance2 and Generate.CheckIfAlive(parent)) then
										continue
									end

									local attacks_Debounce = parent:FindFirstChild("Attacks_Debounce")
									local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
									local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

									if not (attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil and attacks_Debounce:FindFirstChild((`{formatted}_Max`)) == nil) then
										continue
									end

									local cooldown2 = instance:FindFirstChild("Cooldown")

									if not cooldown2 then
										continue
									end

									if not (cooldown2:FindFirstChild((`{check_Type}_{action}`)) and v2.Holding_Skill == nil or v2.Holding_Skill and cooldown2:FindFirstChild((`{check_Type}_{action}_Holding`)) or instance:GetAttribute("NoCooldown")) then
										continue
									end

									if duration_Phase then
										Generate.Add_Instance(formatted, attacks_Debounce, duration_Phase)
									end

									local party = instance:FindFirstChild("Party")
									local playerFromCharacter

									if parent:HasTag("Pet") then
										playerFromCharacter = Players:FindFirstChild(parent:GetAttribute("Summoner"))
									else
										playerFromCharacter = Players:GetPlayerFromCharacter(parent)
									end

									if Generate.Check_Target(instance, playerFromCharacter, party, instance2, parent) then
										return
									end

									if parent:GetAttribute("GodMode") then
										Generate.Reflex(parent, "GodMode")
										return
									end

									local playerData = instance:FindFirstChild("PlayerData")
									local swordLevel

									if check_Type == "Weapon" then
										swordLevel = playerData:FindFirstChild("SwordLevel")
									elseif check_Type == "Power" then
										swordLevel = playerData:FindFirstChild("MemePowerLevel")
									else
										swordLevel = playerData:FindFirstChild("MeleeLevel")
									end

									local auraExp = playerData:FindFirstChild("AuraExp")
									local auraMaxExp = playerData:FindFirstChild("AuraMaxExp")
									local humanoid = parent:FindFirstChild("Humanoid")
									local stun = parent:FindFirstChild("Stun")
									local v7 = not parent:GetAttribute("Defense_Boost") and 1 or parent:GetAttribute("Defense_Boost")
									local v8 = not instance2:GetAttribute("Damage_Boost") and 1 or instance2:GetAttribute("Damage_Boost")
									local v9 = not instance2:GetAttribute((`{check_Type}_Boost`)) and 1 or instance2:GetAttribute((`{check_Type}_Boost`))
									local v10 = not (instance2:GetAttribute("PvpDamage_Boost") and playerFromCharacter) and 1 or instance2:GetAttribute("PvpDamage_Boost")
									local v11 = not parent:GetAttribute("PvpDefense_Boost") and 1 or parent:GetAttribute("PvpDefense_Boost")
									local v12 = (50 + swordLevel.Value) * v2.Damage * v8 * v9 * v10 / v7 / v11 / v3
									local skill_Type = v2.Skill_Type

									if parent:GetAttribute("ReverseMode") then
										if Generate.CheckIfAlive(instance2) then
											local humanoid2 = instance2:FindFirstChild("Humanoid")

											if humanoid2 and humanoid2.Parent then
												if instance2:GetAttribute("GodMode") then
													Generate.Reflex(instance2, "GodMode")
												elseif instance2:GetAttribute("ReverseMode") then
													Generate.Reflex(instance2, "ReverseMode")
												else
													Generate.Add_Hit(
														parent,
														humanoid,
														playerFromCharacter,
														instance2,
														humanoid2,
														v12
													)
													humanoid2:TakeDamage(v12)

													if playerFromCharacter then
														toggle:FireClient(playerFromCharacter, "Damage_Counter", v12)
													end

													local humanoidRootPart3 = instance2:FindFirstChild("HumanoidRootPart")

													if humanoidRootPart3 and humanoidRootPart3.Parent then
														sendSound:FireAllClients(
															humanoidRootPart3,
															"PlaySound_Character",
															{
																Folder = "Weapon_Sound",
																Enemy = "Card",
																Sound = "X_Hit"
															}
														)
													end
												end
											end
										end

										Generate.Reflex(parent, "ReverseMode")
										return
									else
										if parent:GetAttribute("Reflex") and not instance2:GetAttribute("Using_Aura") and check_Type ~= "Power" then
											Generate.Reflex(parent, "Reflex")
											return
										end

										if parent:GetAttribute("Using_Instinct") then
											local child = Players:FindFirstChild(parent.Name)
											local playerData2 = child and child:FindFirstChild("PlayerData")

											if playerData2 then
												local dodge = playerData2:FindFirstChild("Dodge")
												local maxDodge = playerData2:FindFirstChild("MaxDodge")

												if dodge and maxDodge then
													if Generate.Get_Cooldown(child:FindFirstChild("Cooldown")) or v2.Break_Instinct then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														parent:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													elseif dodge.Value > 0 then
														dodge.Value -= 1
														Generate.Instinct_Training(parent, 1)
														Generate.ShowDamage(
															parent,
															dodge.Value,
															"Dodge",
															maxDodge.Value
														)

														if dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
															Generate.Add_Instinct(
																"InstinctCD",
																child:FindFirstChild("Cooldown"),
																broke_Cooldown
															)
															parent:SetAttribute("Using_Instinct", nil)
															instinct:FireClient(child, "Instinct_Broke")
														end

														return
													elseif dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														parent:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													end
												end
											end
										end

										if humanoid and humanoidRootPart and humanoidRootPart2 then
											Generate.Add_Hit(
												instance,
												instance2,
												playerFromCharacter,
												parent,
												humanoid,
												v12
											)
											humanoid:TakeDamage(v12)
											toggle:FireClient(instance, "Damage_Counter", v12)

											if duration_Phase and v3 then
												local child = attacks_Debounce:FindFirstChild((`{formatted}_Count`))

												if child == nil then
													local duration = v2.Duration
													local intValue = Instance.new("IntValue")
													intValue.Name = `{formatted}_Count`
													intValue.Value = 1
													intValue.Parent = attacks_Debounce
													Debris:AddItem(intValue, duration)
												elseif child and child.Value < v3 then
													child.Value += 1

													if v3 <= child.Value and not instance:GetAttribute("NoCooldown") then
														if v2.MaxPhase_Cooldown then
														end

														local duration = v2.Duration
														Generate.Add_Instance(
															`{formatted}_Max`,
															attacks_Debounce,
															duration
														)
													end
												end
											end

											if monster:FindFirstChild(parent.Name) or parent:HasTag("Pet") then
												Generate.ShowDamage(parent, Abbreviate.Format_Comma(v12, 1))
											end

											if v2.Single_Target then
												client_Skills:FireAllClients("Clients_Skill", p4, action, "Destroy", {
													Releaser_Character = instance2,
													Releaser_Id = instance.UserId
												})
											end

											local clone3

											if v2.Knockback then
												clone3 = table.clone(v2.Knockback)
											end

											local clone4

											if v2.BodyPosition then
												clone4 = table.clone(v2.BodyPosition)
											end

											local v13 = v2.Drag_Position and true or nil
											local burning

											if v2.Burning then
												burning = v2.Burning
											end

											local fake_Burning

											if v2.Fake_Burning then
												fake_Burning = v2.Fake_Burning
											end

											local frozen

											if v2.Frozen then
												frozen = v2.Frozen
											end

											local mouse_Position

											if data then
												mouse_Position = data.Mouse_Position
											end

											local hit_Sound

											if data and data.Hit_Sound then
												hit_Sound = data.Hit_Sound
											end

											local weapon_Effect

											if data and data.Weapon_Effect then
												weapon_Effect = data.Weapon_Effect
											end

											local position

											if p2 then
												position = p2.Position
											end

											local parents = (clone3 or clone4 or v13) and {} or nil

											if clone3 then
												if v2.Up_Vector then
													clone3.Velocity = CFrame.new(
														humanoidRootPart2.Position,
														mouse_Position
													).UpVector * clone3.Velocity
												else
													clone3.Velocity = CFrame.new(
														humanoidRootPart2.Position,
														mouse_Position
													).LookVector * clone3.Velocity
												end
											end

											if v13 and p4 == "Bonk" and action == "Z" then
												local position2 = humanoidRootPart2.Position + CFrame.new(
													humanoidRootPart2.Position,
													mouse_Position
												).LookVector * v2.Moving_Speed

												if clone4 then
													clone4.Position = position2
												end
											end

											if clone4 and clone4.Distance and not clone4.Ignore_Default then
												if clone4.Use_MovingSpeed then
													local rootPart_Position = data.RootPart_Position

													if typeof(rootPart_Position) == "Vector3" and (rootPart_Position - humanoidRootPart.Position).Magnitude <= max_Distance * 2 then
														clone4.Position = rootPart_Position + CFrame.new(
															rootPart_Position,
															mouse_Position
														).LookVector * v2.Moving_Speed
													end
												else
													clone4.Position = humanoidRootPart2.Position + CFrame.new(
														humanoidRootPart2.Position,
														mouse_Position
													).LookVector * clone4.Distance
												end
											end

											if clone4 and clone4.Use_HitboxPosition and position and typeof(position) == "Vector3" and (position - humanoidRootPart.Position).Magnitude <= max_Distance then
												clone4.Position = position
											end

											if skill_Type then
												if skill_Type == "Prison" or skill_Type == "Heal_Prison" then
													client_Skills:FireAllClients(
														"Clients_Skill",
														p4,
														action,
														"Prison",
														{
															Releaser_Character = instance2,
															Releaser_Id = instance.UserId,
															Hit_Position = humanoidRootPart.Position
														}
													)

													if clone4 and not clone4.Ignore_Default and clone4 and humanoidRootPart then
														clone4.Position = humanoidRootPart.Position
													end

													local prison_Sound

													if data.Prison_Sound then
														prison_Sound = data.Prison_Sound
													end

													if prison_Sound then
														local v14 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
														task.spawn(
															Prison,
															skill_Type,
															instance,
															instance2,
															playerFromCharacter,
															parent,
															humanoidRootPart,
															humanoid,
															v12,
															v2,
															parents,
															p4,
															action,
															prison_Sound,
															v14
														)
													else
														task.spawn(
															Prison,
															skill_Type,
															instance,
															instance2,
															playerFromCharacter,
															parent,
															humanoidRootPart,
															humanoid,
															v12,
															v2,
															parents,
															p4,
															action
														)
													end
												elseif skill_Type == "Spinning" then
													task.spawn(
														Spinning,
														instance,
														instance2,
														playerFromCharacter,
														parent,
														humanoid,
														humanoidRootPart,
														v12,
														v2,
														p4,
														action
													)
												elseif skill_Type == "Enemy_Effect" then
													client_Skills:FireAllClients(
														"Clients_Skill",
														p4,
														action,
														"Hitted",
														{
															Releaser_Character = instance2,
															Releaser_Id = instance.UserId,
															Hit_Character = parent
														}
													)
												elseif skill_Type == "Coffin" then
													client_Skills:FireAllClients(
														"Clients_Skill",
														p4,
														action,
														"Coffin",
														{
															Releaser_Id = instance.UserId,
															Target_RootPart = humanoidRootPart
														}
													)

													if clone4 and humanoidRootPart then
														clone4.Position = humanoidRootPart.Position + CFrame.new(humanoidRootPart.Position).UpVector * v2.Dragging_Speed or 25
													end

													if v2.Prison then
														task.spawn(
															Prison,
															"Coffin",
															instance,
															instance2,
															playerFromCharacter,
															parent,
															humanoidRootPart,
															humanoid,
															v12,
															v2,
															parents,
															p4,
															action
														)
													else
														task.spawn(
															Coffin,
															instance,
															instance2,
															playerFromCharacter,
															parent,
															humanoid,
															v12,
															v2,
															p4,
															action
														)
													end
												elseif skill_Type == "Pillar" then
													client_Skills:FireAllClients(
														"Clients_Skill",
														p4,
														action,
														"Hitted",
														{
															Releaser_Character = instance2,
															Releaser_Id = instance.UserId,
															Target_RootPart = humanoidRootPart
														}
													)
													local v14 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
													task.spawn(
														Pillar,
														instance,
														instance2,
														playerFromCharacter,
														parent,
														humanoid,
														humanoidRootPart,
														v12,
														v2,
														p4,
														v14,
														action
													)
												elseif skill_Type == "Dragging" then
													if data.Drag_Sound then
														client_Skills:FireAllClients(
															"Clients_Skill",
															p4,
															action,
															"Hitted",
															{
																Releaser_Character = instance2,
																Releaser_Id = instance.UserId,
																Hit_Character = parent
															}
														)
													end

													task.spawn(Drag, instance, instance2, {
														AuraExp = auraExp,
														AuraMaxExp = auraMaxExp
													}, playerFromCharacter, parent, humanoid, humanoidRootPart, stun, humanoidRootPart2, cooldown2, check_Type, max_Distance, v12, v2, data, parents, p4, nil, action)
												elseif skill_Type == "Pulling" then
													if humanoidRootPart2 and humanoidRootPart2.Parent and humanoidRootPart and humanoidRootPart.Parent and clone4 and humanoidRootPart then
														clone4.Position = humanoidRootPart2.Position + CFrame.new(
															humanoidRootPart2.Position,
															humanoidRootPart2.Position + humanoidRootPart2.CFrame.LookVector
														).LookVector * clone4.Distance or 5
													end
												elseif skill_Type == "Dash" and clone4 and humanoidRootPart then
													clone4.Position = humanoidRootPart.Position
												end
											end

											if hit_Sound then
												sendSound:FireAllClients(humanoidRootPart, "PlaySound_Character", {
													Folder = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound",
													Enemy = p4,
													Sound = `{action}_Hit`
												})
											end

											if weapon_Effect then
												client_Skills:FireAllClients("Weapon_Effect", {
													Weapon = p4,
													RootPart = humanoidRootPart
												})
											end

											if frozen then
												if clone4 and humanoidRootPart then
													clone4.Position = humanoidRootPart.Position
												end

												if frozen and frozen.Freeze_Sound then
													local v14 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
													Freeze(
														instance,
														instance2,
														playerFromCharacter,
														parent,
														humanoid,
														humanoidRootPart,
														v12,
														frozen,
														p4,
														action,
														v14
													)
												else
													Freeze(
														instance,
														instance2,
														playerFromCharacter,
														parent,
														humanoid,
														humanoidRootPart,
														v12,
														frozen,
														p4,
														action
													)
												end
											end

											if burning or fake_Burning then
												task.spawn(
													Burn,
													instance,
													instance2,
													playerFromCharacter,
													parent,
													humanoid,
													humanoidRootPart,
													v12,
													burning,
													fake_Burning
												)
											end

											if duration_Phase then
												if clone4 and clone3 then
													if parents and not table.find(parents, parent) then
														if instance2:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
															auraExp.Value += 1
														end

														Generate.Aura_Training(parent, 1)
														table.insert(parents, parent)
													end

													if clone4.StunTime then
														Generate.Stunning(stun, "Duration", 1, clone4.StunTime)
													elseif clone3.StunTime then
														Generate.Stunning(stun, "Duration", 1, clone3.StunTime)
													end

													if not parent:GetAttribute("Anti_Knockback") then
														if parent:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
															Generate.Server_Position({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Duration_Phase = duration_Phase,
																BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																BodyPosition = clone4
															})
															Server_Knockback({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Duration_Phase = duration_Phase,
																Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																Knockback = clone3
															})
														else
															clientEnemy:FireAllClients(parent, "BodyPosition", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_BodyPosition",
																Duration_Phase = duration_Phase,
																BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																BodyPosition = clone4
															})
															clientEnemy:FireAllClients(parent, "Knockback", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_Knockback",
																Duration_Phase = duration_Phase,
																Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																Knockback = clone3
															})
														end
													end
												elseif clone4 then
													if parents and not table.find(parents, parent) then
														if instance2:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
															auraExp.Value += 1
														end

														Generate.Aura_Training(parent, 1)
														table.insert(parents, parent)
													end

													if clone4.StunTime then
														Generate.Stunning(stun, "Duration", 1, clone4.StunTime)
													end

													if not parent:GetAttribute("Anti_Knockback") then
														if clone4.Middle then
															if parent and parent.Parent and parent.Parent == monster and parent:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
																humanoidRootPart:SetNetworkOwner(instance)
															end

															clientEnemy:FireAllClients(parent, "BodyPosition", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Duration_Phase = duration_Phase,
																Type = "Custom_BodyPosition",
																Weapon = p4,
																Action = action,
																Releaser_Id = instance.UserId,
																BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																BodyPosition = clone4
															})
														elseif parent:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
															if clone4.Respect_Holding then
																Generate.Server_Position({
																	Hitbox = humanoidRootPart2,
																	Skill_Releaser = instance2,
																	Target_RootPart = humanoidRootPart,
																	Duration_Phase = duration_Phase,
																	ItemType = check_Type,
																	Action = action,
																	Cooldown_Folder = cooldown2,
																	BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																	BodyPosition = clone4
																})
															else
																Generate.Server_Position({
																	Hitbox = humanoidRootPart2,
																	Skill_Releaser = instance2,
																	Target_RootPart = humanoidRootPart,
																	Duration_Phase = duration_Phase,
																	BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																	BodyPosition = clone4
																})
															end
														elseif clone4.Respect_Holding then
															clientEnemy:FireAllClients(parent, "BodyPosition", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_BodyPosition",
																ItemType = check_Type,
																Action = action,
																Cooldown_Folder = cooldown2,
																Duration_Phase = duration_Phase,
																BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																BodyPosition = clone4
															})
														else
															clientEnemy:FireAllClients(parent, "BodyPosition", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_BodyPosition",
																Duration_Phase = duration_Phase,
																BodyPosition_Name = `BP_{p4}_{action}_{instance.UserId}`,
																BodyPosition = clone4
															})
														end
													end
												elseif clone3 then
													if parents and not table.find(parents, parent) then
														if instance2:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
															auraExp.Value += 1
														end

														Generate.Aura_Training(parent, 1)
														table.insert(parents, parent)
													end

													if clone3.StunTime then
														Generate.Stunning(stun, "Duration", 1, clone3.StunTime)
													end

													if not parent:GetAttribute("Anti_Knockback") then
														if parent:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
															if clone3.Respect_Holding then
																Server_Knockback({
																	Hitbox = humanoidRootPart2,
																	Skill_Releaser = instance2,
																	Target_RootPart = humanoidRootPart,
																	ItemType = check_Type,
																	Action = action,
																	Cooldown_Folder = cooldown2,
																	Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																	Duration_Phase = duration_Phase,
																	Knockback = clone3
																})
															else
																Server_Knockback({
																	Hitbox = humanoidRootPart2,
																	Skill_Releaser = instance2,
																	Target_RootPart = humanoidRootPart,
																	Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																	Duration_Phase = duration_Phase,
																	Knockback = clone3
																})
															end
														elseif clone3.Respect_Holding then
															clientEnemy:FireAllClients(parent, "Knockback", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_Knockback",
																ItemType = check_Type,
																Action = action,
																Cooldown_Folder = cooldown2,
																Duration_Phase = duration_Phase,
																Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																Knockback = clone3
															})
														else
															clientEnemy:FireAllClients(parent, "Knockback", {
																Hitbox = humanoidRootPart2,
																Skill_Releaser = instance2,
																Target_RootPart = humanoidRootPart,
																Type = "Custom_Knockback",
																Duration_Phase = duration_Phase,
																Knockback_Name = `BV_{p4}_{action}_{instance.UserId}`,
																Knockback = clone3
															})
														end
													end
												elseif parents and not table.find(parents, parent) then
													if instance2:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
														auraExp.Value += 1
													end

													Generate.Aura_Training(parent, 1)
													table.insert(parents, parent)
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end
		end
	end

	server_Hitbox.OnServerEvent:Connect(function(player, instance, p, action, data)
		local character = player.Character
		local v2 = ItemSettings[p][action]

		if v2 then
			local max_Loop

			if v2.Max_Loop then
				max_Loop = v2.Max_Loop
			end

			local loop

			if max_Loop and data and data.Loop then
				loop = data.Loop
			end

			local v3 = not v2.Max_Phase and 1 or v2.Max_Phase
			local duration_Phase

			if v2.Duration_Phase then
				duration_Phase = v2.Duration_Phase
			end

			if Generate.CheckIfAlive(character) and (instance ~= character or v2.IsExplosion) and Generate.CheckIfAlive(instance) and Generate.Check_Legit(
				player,
				character,
				v2,
				p
			) and (not duration_Phase or v2.IsExplosion) then
				if v2.IsExplosion then
					local check_Type = Generate.Check_Type(p)
					local cooldown = player:FindFirstChild("Cooldown")
					local attribute = character and character.Parent and cooldown and cooldown:FindFirstChild((`{check_Type}_{action}_MultiHit`)) and character:GetAttribute((`{check_Type}_{action}_Exploded`))

					if attribute then
						local explosion_CFrame = data.Explosion_CFrame

						if typeof(explosion_CFrame) == "CFrame" and attribute == CFrame.new(0, 0, 0) and (explosion_CFrame.Position - character.PrimaryPart.Position).Magnitude <= v2.Max_Distance then
							character:SetAttribute(`{check_Type}_{action}_Exploded`, explosion_CFrame)
						end
					end
				else
					local attacks_Debounce = instance:FindFirstChild("Attacks_Debounce")
					local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
					local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
					local formatted = `Attacked_{p}_{action}`

					if loop and loop <= max_Loop then
						formatted = `Attacked_{p}_{action}_{math.floor(loop)}`
					elseif player:GetAttribute("NoCooldown") then
						local current_Time = data.Current_Time

						if current_Time then
							formatted = `Attacked_{p}_{action}_{current_Time}`
						end
					end

					local max_Distance = v2.Max_Distance or 500

					if attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil and attacks_Debounce:FindFirstChild((`{formatted}_Max`)) == nil and (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= max_Distance then
						local check_Type = Generate.Check_Type(p)
						local cooldown = player:FindFirstChild("Cooldown")

						if cooldown then
							if v2.Special_MultiHit and not player:GetAttribute("NoCooldown") and cooldown:FindFirstChild((`{check_Type}_{action}_SpecialMultiHit`)) == nil and cooldown:FindFirstChild((`{check_Type}_{action}`)) then
								Generate.Add_Instance(
									`{check_Type}_{action}_SpecialMultiHit`,
									cooldown,
									v2.Duration - 1
								)
							end

							if cooldown:FindFirstChild((`{check_Type}_{action}`)) and v2.Holding_Skill == nil and v2.MultiHit_Skill == nil or v2.Holding_Skill and cooldown:FindFirstChild((`{check_Type}_{action}_Holding`)) or v2.MultiHit_Skill and cooldown:FindFirstChild((`{check_Type}_{action}_MultiHit`)) or player:GetAttribute("NoCooldown") then
								if duration_Phase then
									Generate.Add_Instance(formatted, attacks_Debounce, duration_Phase)
								else
									local cooldown2 = v2.Cooldown
									local v4 = not (character and character.Parent) and 1 or character:GetAttribute((`{check_Type}CD_Boost`))
									Generate.Add_Instance(formatted, attacks_Debounce, cooldown2 / v4)
								end

								local party = player:FindFirstChild("Party")
								local playerFromCharacter

								if instance:HasTag("Pet") then
									playerFromCharacter = Players:FindFirstChild(instance:GetAttribute("Summoner"))
								else
									playerFromCharacter = Players:GetPlayerFromCharacter(instance)
								end

								if Generate.Check_Target(player, playerFromCharacter, party, character, instance) then
									return
								end

								if instance:GetAttribute("GodMode") then
									Generate.Reflex(instance, "GodMode")
									return
								end

								local playerData = player:FindFirstChild("PlayerData")
								local swordLevel

								if check_Type == "Weapon" then
									swordLevel = playerData:FindFirstChild("SwordLevel")
								elseif check_Type == "Power" then
									swordLevel = playerData:FindFirstChild("MemePowerLevel")
								else
									swordLevel = playerData:FindFirstChild("MeleeLevel")
								end

								local auraExp = playerData:FindFirstChild("AuraExp")
								local auraMaxExp = playerData:FindFirstChild("AuraMaxExp")
								local humanoid = instance:FindFirstChild("Humanoid")
								local stun = instance:FindFirstChild("Stun")
								local v4 = not instance:GetAttribute("Defense_Boost") and 1 or instance:GetAttribute("Defense_Boost")
								local v5 = not character:GetAttribute("Damage_Boost") and 1 or character:GetAttribute("Damage_Boost")
								local v6 = not character:GetAttribute((`{check_Type}_Boost`)) and 1 or character:GetAttribute((`{check_Type}_Boost`))
								local v7 = not (character:GetAttribute("PvpDamage_Boost") and playerFromCharacter) and 1 or character:GetAttribute("PvpDamage_Boost")
								local v8 = not instance:GetAttribute("PvpDefense_Boost") and 1 or instance:GetAttribute("PvpDefense_Boost")
								local v9 = (50 + swordLevel.Value) * v2.Damage * v5 * v6 * v7 / v4 / v8 / v3
								local skill_Type = v2.Skill_Type

								if instance:GetAttribute("ReverseMode") then
									if Generate.CheckIfAlive(character) then
										local humanoid2 = character:FindFirstChild("Humanoid")

										if humanoid2 and humanoid2.Parent then
											if character:GetAttribute("GodMode") then
												Generate.Reflex(character, "GodMode")
											elseif character:GetAttribute("ReverseMode") then
												Generate.Reflex(character, "ReverseMode")
											else
												Generate.Add_Hit(
													instance,
													humanoid,
													playerFromCharacter,
													character,
													humanoid2,
													v9
												)
												humanoid2:TakeDamage(v9)

												if playerFromCharacter then
													toggle:FireClient(playerFromCharacter, "Damage_Counter", v9)
												end

												local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

												if humanoidRootPart3 and humanoidRootPart3.Parent then
													sendSound:FireAllClients(humanoidRootPart3, "PlaySound_Character", {
														Folder = "Weapon_Sound",
														Enemy = "Card",
														Sound = "X_Hit"
													})
												end
											end
										end
									end

									Generate.Reflex(instance, "ReverseMode")
								else
									if instance:GetAttribute("Reflex") and not character:GetAttribute("Using_Aura") and check_Type ~= "Power" then
										Generate.Reflex(instance, "Reflex")
										return
									end

									if instance:GetAttribute("Using_Instinct") then
										local child = Players:FindFirstChild(instance.Name)
										local playerData2 = child and child:FindFirstChild("PlayerData")

										if playerData2 then
											local dodge = playerData2:FindFirstChild("Dodge")
											local maxDodge = playerData2:FindFirstChild("MaxDodge")

											if dodge and maxDodge then
												if Generate.Get_Cooldown(child:FindFirstChild("Cooldown")) or v2.Break_Instinct then
													Generate.Add_Instinct(
														"InstinctCD",
														child:FindFirstChild("Cooldown"),
														broke_Cooldown
													)
													instance:SetAttribute("Using_Instinct", nil)
													instinct:FireClient(child, "Instinct_Broke")
												elseif dodge.Value > 0 then
													dodge.Value -= 1
													Generate.Instinct_Training(instance, 1)
													Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

													if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														instance:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													end

													return
												elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
													Generate.Add_Instinct(
														"InstinctCD",
														child:FindFirstChild("Cooldown"),
														broke_Cooldown
													)
													instance:SetAttribute("Using_Instinct", nil)
													instinct:FireClient(child, "Instinct_Broke")
												end
											end
										end
									end

									if humanoid and humanoidRootPart and humanoidRootPart2 then
										Generate.Add_Hit(player, character, playerFromCharacter, instance, humanoid, v9)
										humanoid:TakeDamage(v9)
										toggle:FireClient(player, "Damage_Counter", v9)

										if duration_Phase and v3 then
											local child = attacks_Debounce:FindFirstChild((`{formatted}_Count`))

											if child == nil then
												local duration = v2.Duration
												local intValue = Instance.new("IntValue")
												intValue.Name = `{formatted}_Count`
												intValue.Value = 1
												intValue.Parent = attacks_Debounce
												Debris:AddItem(intValue, duration)
											elseif child and child.Value < v3 then
												child.Value += 1

												if v3 <= child.Value and not player:GetAttribute("NoCooldown") then
													local duration = v2.Duration
													Generate.Add_Instance(`{formatted}_Max`, attacks_Debounce, duration)
												end
											end
										end

										if monster:FindFirstChild(instance.Name) or instance:HasTag("Pet") then
											Generate.ShowDamage(instance, Abbreviate.Format_Comma(v9, 1))
										end

										if v2.Single_Target then
											client_Skills:FireAllClients("Clients_Skill", p, action, "Destroy", {
												Releaser_Character = character,
												Releaser_Id = player.UserId
											})
										end

										local clone

										if v2.Knockback then
											clone = table.clone(v2.Knockback)
										end

										local clone2

										if v2.BodyPosition then
											clone2 = table.clone(v2.BodyPosition)
										end

										local v10 = v2.Drag_Position and true or nil
										local burning

										if v2.Burning then
											burning = v2.Burning
										end

										local fake_Burning

										if v2.Fake_Burning then
											fake_Burning = v2.Fake_Burning
										end

										local frozen

										if v2.Frozen then
											frozen = v2.Frozen
										end

										local mouse_Position

										if data then
											mouse_Position = data.Mouse_Position
										end

										local hit_Sound

										if data and data.Hit_Sound then
											hit_Sound = data.Hit_Sound
										end

										local weapon_Effect

										if data and data.Weapon_Effect then
											weapon_Effect = data.Weapon_Effect
										end

										local hitbox_Position

										if data then
											hitbox_Position = data.Hitbox_Position
										end

										local instances = (clone or clone2 or v10) and {} or nil

										if clone then
											if v2.Up_Vector then
												clone.Velocity = CFrame.new(humanoidRootPart2.Position, mouse_Position).UpVector * clone.Velocity
											else
												clone.Velocity = CFrame.new(humanoidRootPart2.Position, mouse_Position).LookVector * clone.Velocity
											end
										end

										if v10 and p == "Bonk" and action == "Z" then
											local position = humanoidRootPart2.Position + CFrame.new(
												humanoidRootPart2.Position,
												mouse_Position
											).LookVector * v2.Moving_Speed

											if clone2 then
												clone2.Position = position
											end
										end

										if clone2 and clone2.Distance and not clone2.Ignore_Default then
											if clone2.Use_MovingSpeed then
												local rootPart_Position = data.RootPart_Position

												if typeof(rootPart_Position) == "Vector3" and (rootPart_Position - humanoidRootPart.Position).Magnitude <= max_Distance * 2 then
													clone2.Position = rootPart_Position + CFrame.new(
														rootPart_Position,
														mouse_Position
													).LookVector * v2.Moving_Speed
												end
											else
												clone2.Position = humanoidRootPart2.Position + CFrame.new(
													humanoidRootPart2.Position,
													mouse_Position
												).LookVector * clone2.Distance
											end
										end

										if clone2 and clone2.Use_HitboxPosition and hitbox_Position and typeof(hitbox_Position) == "Vector3" and (hitbox_Position - humanoidRootPart.Position).Magnitude <= max_Distance then
											clone2.Position = hitbox_Position
										end

										if skill_Type then
											if skill_Type == "Prison" or skill_Type == "Heal_Prison" then
												client_Skills:FireAllClients("Clients_Skill", p, action, "Prison", {
													Releaser_Character = character,
													Releaser_Id = player.UserId,
													Hit_Position = humanoidRootPart.Position
												})

												if clone2 and not clone2.Ignore_Default and clone2 and humanoidRootPart then
													clone2.Position = humanoidRootPart.Position
												end

												local prison_Sound

												if data.Prison_Sound then
													prison_Sound = data.Prison_Sound
												end

												if prison_Sound then
													local v11 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
													task.spawn(
														Prison,
														skill_Type,
														player,
														character,
														playerFromCharacter,
														instance,
														humanoidRootPart,
														humanoid,
														v9,
														v2,
														instances,
														p,
														action,
														prison_Sound,
														v11
													)
												else
													task.spawn(
														Prison,
														skill_Type,
														player,
														character,
														playerFromCharacter,
														instance,
														humanoidRootPart,
														humanoid,
														v9,
														v2,
														instances,
														p,
														action
													)
												end
											elseif skill_Type == "Spinning" then
												task.spawn(
													Spinning,
													player,
													character,
													playerFromCharacter,
													instance,
													humanoid,
													humanoidRootPart,
													v9,
													v2,
													p,
													action
												)
											elseif skill_Type == "Enemy_Effect" then
												client_Skills:FireAllClients("Clients_Skill", p, action, "Hitted", {
													Releaser_Character = character,
													Releaser_Id = player.UserId,
													Hit_Character = instance
												})
											elseif skill_Type == "Coffin" then
												client_Skills:FireAllClients("Clients_Skill", p, action, "Coffin", {
													Releaser_Id = player.UserId,
													Target_RootPart = humanoidRootPart
												})

												if clone2 and humanoidRootPart then
													clone2.Position = humanoidRootPart.Position + CFrame.new(humanoidRootPart.Position).UpVector * v2.Dragging_Speed or 25
												end

												if v2.Prison then
													task.spawn(
														Prison,
														"Coffin",
														player,
														character,
														playerFromCharacter,
														instance,
														humanoidRootPart,
														humanoid,
														v9,
														v2,
														instances,
														p,
														action
													)
												else
													task.spawn(
														Coffin,
														player,
														character,
														playerFromCharacter,
														instance,
														humanoid,
														v9,
														v2,
														p,
														action
													)
												end
											elseif skill_Type == "Pillar" then
												client_Skills:FireAllClients("Clients_Skill", p, action, "Hitted", {
													Releaser_Character = character,
													Releaser_Id = player.UserId,
													Target_RootPart = humanoidRootPart
												})
												local v11 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
												task.spawn(
													Pillar,
													player,
													character,
													playerFromCharacter,
													instance,
													humanoid,
													humanoidRootPart,
													v9,
													v2,
													p,
													v11,
													action
												)
											elseif skill_Type == "Dragging" then
												if data.Drag_Sound then
													client_Skills:FireAllClients("Clients_Skill", p, action, "Hitted", {
														Releaser_Character = character,
														Releaser_Id = player.UserId,
														Hit_Character = instance
													})
												end

												task.spawn(Drag, player, character, {
													AuraExp = auraExp,
													AuraMaxExp = auraMaxExp
												}, playerFromCharacter, instance, humanoid, humanoidRootPart, stun, humanoidRootPart2, cooldown, check_Type, max_Distance, v9, v2, data, instances, p, nil, action)
											elseif skill_Type == "Pulling" then
												if humanoidRootPart2 and humanoidRootPart2.Parent and humanoidRootPart and humanoidRootPart.Parent and clone2 and humanoidRootPart then
													clone2.Position = humanoidRootPart2.Position + CFrame.new(
														humanoidRootPart2.Position,
														humanoidRootPart2.Position + humanoidRootPart2.CFrame.LookVector
													).LookVector * clone2.Distance or 5
												end
											elseif skill_Type == "Dash" and clone2 and humanoidRootPart then
												clone2.Position = humanoidRootPart.Position
											end
										end

										if hit_Sound then
											sendSound:FireAllClients(humanoidRootPart, "PlaySound_Character", {
												Folder = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound",
												Enemy = p,
												Sound = `{action}_Hit`
											})
										end

										if weapon_Effect then
											client_Skills:FireAllClients("Weapon_Effect", {
												Weapon = p,
												RootPart = humanoidRootPart
											})
										end

										if frozen then
											if clone2 and humanoidRootPart then
												clone2.Position = humanoidRootPart.Position
											end

											if frozen and frozen.Freeze_Sound then
												local v11 = check_Type == "Weapon" and "Weapon_Sound" or check_Type == "Power" and "Power_Sound" or "FightingStyle_Sound"
												Freeze(
													player,
													character,
													playerFromCharacter,
													instance,
													humanoid,
													humanoidRootPart,
													v9,
													frozen,
													p,
													action,
													v11
												)
											else
												Freeze(
													player,
													character,
													playerFromCharacter,
													instance,
													humanoid,
													humanoidRootPart,
													v9,
													frozen,
													p,
													action
												)
											end
										end

										if burning or fake_Burning then
											task.spawn(
												Burn,
												player,
												character,
												playerFromCharacter,
												instance,
												humanoid,
												humanoidRootPart,
												v9,
												burning,
												fake_Burning
											)
										end

										if duration_Phase then
											if clone2 and clone then
												if instances and not table.find(instances, instance) then
													if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
														auraExp.Value += 1
													end

													Generate.Aura_Training(instance, 1)
													table.insert(instances, instance)
												end

												if clone2.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone2.StunTime)
												elseif clone.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone.StunTime)
												end

												if not instance:GetAttribute("Anti_Knockback") then
													if instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														Generate.Server_Position({
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Duration_Phase = duration_Phase,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
														Server_Knockback({
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Duration_Phase = duration_Phase,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													else
														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															Duration_Phase = duration_Phase,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															Duration_Phase = duration_Phase,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													end
												end
											elseif clone2 then
												if instances and not table.find(instances, instance) then
													if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
														auraExp.Value += 1
													end

													Generate.Aura_Training(instance, 1)
													table.insert(instances, instance)
												end

												if clone2.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone2.StunTime)
												end

												if not instance:GetAttribute("Anti_Knockback") then
													if clone2.Middle then
														if instance and instance.Parent and instance.Parent == monster and instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
															humanoidRootPart:SetNetworkOwner(player)
														end

														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Duration_Phase = duration_Phase,
															Type = "Custom_BodyPosition",
															Weapon = p,
															Action = action,
															Releaser_Id = player.UserId,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													elseif instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														if clone2.Respect_Holding then
															Generate.Server_Position({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																Duration_Phase = duration_Phase,
																ItemType = check_Type,
																Action = action,
																Cooldown_Folder = cooldown,
																BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
																BodyPosition = clone2
															})
														else
															Generate.Server_Position({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																Duration_Phase = duration_Phase,
																BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
																BodyPosition = clone2
															})
														end
													elseif clone2.Respect_Holding then
														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															ItemType = check_Type,
															Action = action,
															Cooldown_Folder = cooldown,
															Duration_Phase = duration_Phase,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													else
														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															Duration_Phase = duration_Phase,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													end
												end
											elseif clone then
												if instances and not table.find(instances, instance) then
													if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
														auraExp.Value += 1
													end

													Generate.Aura_Training(instance, 1)
													table.insert(instances, instance)
												end

												if clone.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone.StunTime)
												end

												if not instance:GetAttribute("Anti_Knockback") then
													if instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														if clone.Respect_Holding then
															Server_Knockback({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																ItemType = check_Type,
																Action = action,
																Cooldown_Folder = cooldown,
																Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
																Duration_Phase = duration_Phase,
																Knockback = clone
															})
														else
															Server_Knockback({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
																Duration_Phase = duration_Phase,
																Knockback = clone
															})
														end
													elseif clone.Respect_Holding then
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															ItemType = check_Type,
															Action = action,
															Cooldown_Folder = cooldown,
															Duration_Phase = duration_Phase,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													else
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															Duration_Phase = duration_Phase,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													end
												end
											elseif instances and not table.find(instances, instance) then
												if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
													auraExp.Value += 1
												end

												Generate.Aura_Training(instance, 1)
												table.insert(instances, instance)
											end
										elseif clone2 and clone then
											if instances and not table.find(instances, instance) then
												if clone2.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone2.StunTime)
												end

												if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
													auraExp.Value += 1
												end

												Generate.Aura_Training(instance, 1)

												if not instance:GetAttribute("Anti_Knockback") then
													if instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														Generate.Server_Position({
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
														Server_Knockback({
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													else
														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													end
												end
											end
										elseif clone2 then
											if instances and not table.find(instances, instance) then
												if clone2.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone2.StunTime)
												end

												if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
													auraExp.Value += 1
												end

												Generate.Aura_Training(instance, 1)

												if not instance:GetAttribute("Anti_Knockback") then
													if clone2.Middle or skill_Type == "Pillar" then
														if instance and instance.Parent and instance.Parent == monster and instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
															humanoidRootPart:SetNetworkOwner(player)
														end

														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															Weapon = p,
															Action = action,
															Releaser_Id = player.UserId,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													elseif instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														Generate.Server_Position({
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													else
														clientEnemy:FireAllClients(instance, "BodyPosition", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_BodyPosition",
															Weapon = p,
															Action = action,
															Releaser_Id = player.UserId,
															BodyPosition_Name = `BP_{p}_{action}_{player.UserId}`,
															BodyPosition = clone2
														})
													end
												end
											end
										elseif clone then
											if instances and not table.find(instances, instance) then
												if clone.StunTime then
													Generate.Stunning(stun, "Duration", 1, clone.StunTime)
												end

												if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
													auraExp.Value += 1
												end

												Generate.Aura_Training(instance, 1)

												if not instance:GetAttribute("Anti_Knockback") then
													if instance:HasTag("Enemy") and not humanoidRootPart:GetNetworkOwner() then
														if clone.Sync_Hitbox then
															Server_Knockback({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																ItemType = check_Type,
																Action = action,
																Cooldown_Folder = cooldown,
																Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
																Knockback = clone
															})
														else
															Server_Knockback({
																Hitbox = humanoidRootPart2,
																Skill_Releaser = character,
																Target_RootPart = humanoidRootPart,
																Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
																Knockback = clone
															})
														end
													elseif clone.Sync_Hitbox then
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															ItemType = check_Type,
															Action = action,
															Cooldown_Folder = cooldown,
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													else
														clientEnemy:FireAllClients(instance, "Knockback", {
															Hitbox = humanoidRootPart2,
															Skill_Releaser = character,
															Target_RootPart = humanoidRootPart,
															Type = "Custom_Knockback",
															Knockback_Name = `BV_{p}_{action}_{player.UserId}`,
															Knockback = clone
														})
													end
												end
											end
										else
											if character:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
												auraExp.Value += 1
											end

											Generate.Aura_Training(instance, 1)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

function Generate:LoopHitbox_Monster(p, p2, enemy, action, p5, data)
	local monster2

	if data and data.Monster then
		monster2 = data.Monster
	else
		monster2 = nil
	end

	local v2 = not (data and data.Skill_Phase) and 1 or data.Skill_Phase
	local v3 = not (data and data.Max_Phase) and 1 or data.Max_Phase
	local knockback

	if data and data.Knockback then
		knockback = data.Knockback
	else
		knockback = nil
	end

	local bodyPosition

	if data and data.BodyPosition then
		bodyPosition = data.BodyPosition
	else
		bodyPosition = nil
	end

	local duration_Phase

	if data and data.Duration_Phase then
		duration_Phase = data.Duration_Phase
	else
		duration_Phase = nil
	end

	local hit_Sound

	if data and data.Hit_Sound then
		hit_Sound = data.Hit_Sound
	else
		hit_Sound = nil
	end

	local skill_Type

	if data and data.Skill_Type then
		skill_Type = data.Skill_Type
	else
		skill_Type = nil
	end

	local formatted = `Attacked_{enemy}_{action}_{v2}`

	if p2 == "Repeat" then
		local now = os.clock()
		local total = 0
		local flag = true
		local heartbeatConnection = nil
		local moving_Speed

		if data then
			moving_Speed = data.Moving_Speed
		else
			moving_Speed = nil
		end

		local rootPart_Position

		if data then
			rootPart_Position = data.RootPart_Position
		else
			rootPart_Position = nil
		end

		local targetRootPart_Position

		if data then
			targetRootPart_Position = data.TargetRootPart_Position
		else
			targetRootPart_Position = nil
		end

		local client_CFrame

		if data then
			client_CFrame = data.Client_CFrame
		else
			client_CFrame = nil
		end

		local parents = (knockback or bodyPosition) and {} or nil
		local break_Instinct

		if data then
			break_Instinct = data.Break_Instinct
		else
			break_Instinct = nil
		end

		local frozen

		if data and data.Frozen then
			frozen = data.Frozen
		else
			frozen = nil
		end

		local v4 = moving_Speed and moving_Speed >= 300 and 0.05 or 0.1

		if duration_Phase then
			if v2 == 1 then
				local _ = RunService.Heartbeat:Connect(function(dt)
					total += dt
					local now2 = os.clock()

					if now + p5 <= now2 or not Generate.CheckExist(self) then
						if self and self.Parent then
							self:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						if parents then
							table.clear(parents)
							parents = nil
						end
					else
						if moving_Speed then
							if client_CFrame then
								self.CFrame += CFrame.new(client_CFrame, targetRootPart_Position).LookVector * moving_Speed * dt
							else
								self.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt
							end
						end

						if v4 <= total or flag then
							if flag then
								flag = false
							end

							total = 0
							local partBoundsInBox = workspace:GetPartBoundsInBox(self.CFrame, self.Size, p)

							if #partBoundsInBox > 0 then
								for _, v5 in ipairs(partBoundsInBox) do
									if not (v5 and v5.Parent) then
										continue
									end

									local parent

									if v5.Parent then
										parent = v5.Parent
									end

									if not Generate.CheckIfAlive(parent) then
										continue
									end

									local attacks_Debounce = parent:FindFirstChild("Attacks_Debounce")

									if not (attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil) then
										continue
									end

									Generate.Add_Instance(formatted, attacks_Debounce, duration_Phase)
									local humanoid = parent:FindFirstChild("Humanoid")
									local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
									local stun = parent:FindFirstChild("Stun")

									if not (humanoid and humanoidRootPart) then
										continue
									end

									if parent:GetAttribute("GodMode") then
										Generate.Reflex(parent, "GodMode")
									elseif parent:GetAttribute("ReverseMode") then
										local humanoid2 = monster2:FindFirstChild("Humanoid")
										local v6 = MonsterSettings[enemy][action].Damage / v3

										if humanoid2 and humanoid2.Parent then
											if monster2:GetAttribute("GodMode") then
												Generate.Reflex(monster2, "GodMode")
											elseif monster2:GetAttribute("ReverseMode") then
												Generate.Reflex(monster2, "ReverseMode")
											else
												Generate.Add_Hit(parent, parent, nil, monster2, humanoid2, v6)
												humanoid2:TakeDamage(v6)
												local child = Players:FindFirstChild(parent.Name)

												if child then
													toggle:FireClient(child, "Damage_Counter", v6)
												end

												Generate.ShowDamage(monster2, Abbreviate.Format_Comma(v6, 1))
											end
										end

										Generate.Reflex(parent, "ReverseMode")
									else
										if parent:GetAttribute("Using_Instinct") then
											local child = Players:FindFirstChild(parent.Name)
											local playerData = child and child:FindFirstChild("PlayerData")

											if playerData then
												local dodge = playerData:FindFirstChild("Dodge")
												local maxDodge = playerData:FindFirstChild("MaxDodge")

												if dodge and maxDodge then
													if Generate.Get_Cooldown(child:FindFirstChild("Cooldown")) or break_Instinct then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														parent:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													elseif dodge.Value > 0 then
														dodge.Value -= 1
														Generate.Instinct_Training(parent, 1)
														Generate.ShowDamage(
															parent,
															dodge.Value,
															"Dodge",
															maxDodge.Value
														)

														if dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
															Generate.Add_Instinct(
																"InstinctCD",
																child:FindFirstChild("Cooldown"),
																broke_Cooldown
															)
															parent:SetAttribute("Using_Instinct", nil)
															instinct:FireClient(child, "Instinct_Broke")
														end

														continue
													elseif dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														parent:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													end
												end
											end
										end

										local v6 = not parent:GetAttribute("Defense_Boost") and 1 or parent:GetAttribute("Defense_Boost")
										local v7 = MonsterSettings[enemy][action].Damage / v6 / v3
										humanoid:TakeDamage(v7)

										if parent:HasTag("Pet") then
											Generate.ShowDamage(parent, Abbreviate.Format_Comma(v7, 1))
										end

										if skill_Type then
											if skill_Type == "Dragging" then
												task.spawn(
													Enemy_Drag,
													parent,
													humanoid,
													humanoidRootPart,
													stun,
													self,
													v7,
													enemy,
													action,
													formatted,
													data
												)
											elseif skill_Type == "Pulling" and monster2 then
												local humanoidRootPart2 = monster2:FindFirstChild("HumanoidRootPart")

												if humanoidRootPart2 and bodyPosition and humanoidRootPart then
													bodyPosition.Position = humanoidRootPart2.Position + CFrame.new(
														humanoidRootPart2.Position,
														targetRootPart_Position
													).LookVector * bodyPosition.Distance or 5
												end
											elseif skill_Type == "Enemy_Effect" then
												clientBossSkills:FireAllClients(enemy, `{action}_Hitted`, {
													Hit_Character = parent,
													Action = action
												})
											end
										end

										if hit_Sound then
											sendSound:FireAllClients(humanoidRootPart, "PlaySound_Character", {
												Folder = "Enemy",
												Enemy = enemy,
												Sound = `{action}_Hit`
											})
										end

										if not data.Not_Stun then
											Generate.Stunning(stun, "Duration", 1, 0.5)
										end

										if bodyPosition and knockback then
											if parents and not table.find(parents, parent) then
												if bodyPosition.StunTime then
													Generate.Stunning(stun, "Duration", 1, bodyPosition.StunTime)
												elseif knockback.StunTime then
													Generate.Stunning(stun, "Duration", 1, knockback.StunTime)
												end

												Generate.Aura_Training(parent, 1)
												table.insert(parents, parent)
											end

											if not parent:GetAttribute("Anti_Knockback") then
												clientEnemy:FireAllClients(parent, "BodyPosition", {
													Hitbox = self,
													Target_RootPart = humanoidRootPart,
													Type = "Custom_BodyPosition",
													Duration_Phase = duration_Phase,
													BodyPosition_Name = `BP_{formatted}`,
													BodyPosition = bodyPosition
												})
												clientEnemy:FireAllClients(parent, "Knockback", {
													Hitbox = self,
													Target_RootPart = humanoidRootPart,
													Type = "Custom_Knockback",
													Duration_Phase = duration_Phase,
													Knockback_Name = `BV_{formatted}`,
													Knockback = knockback
												})
											end
										elseif bodyPosition then
											if parents and not table.find(parents, parent) then
												if bodyPosition.StunTime then
													Generate.Stunning(stun, "Duration", 1, bodyPosition.StunTime)
												end

												Generate.Aura_Training(parent, 1)
												table.insert(parents, parent)
											end

											if not parent:GetAttribute("Anti_Knockback") then
												clientEnemy:FireAllClients(parent, "BodyPosition", {
													Hitbox = self,
													Target_RootPart = humanoidRootPart,
													Type = "Custom_BodyPosition",
													Duration_Phase = duration_Phase,
													BodyPosition_Name = `BP_{formatted}`,
													BodyPosition = bodyPosition
												})
											end
										elseif knockback then
											if parents and not table.find(parents, parent) then
												if knockback.StunTime then
													Generate.Stunning(stun, "Duration", 1, knockback.StunTime)
												end

												Generate.Aura_Training(parent, 1)
												table.insert(parents, parent)
											end

											if not parent:GetAttribute("Anti_Knockback") then
												clientEnemy:FireAllClients(parent, "Knockback", {
													Hitbox = self,
													Target_RootPart = humanoidRootPart,
													Type = "Custom_Knockback",
													Duration_Phase = duration_Phase,
													Knockback_Name = `BV_{formatted}`,
													Knockback = knockback
												})
											end
										end
									end
								end
							end
						end
					end
				end)
			end
		else
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				local now2 = os.clock()

				if now + p5 <= now2 or not Generate.CheckExist(self) then
					if self and self.Parent then
						self:Destroy()
					end

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					if parents then
						table.clear(parents)
						parents = nil
					end
				else
					if not self:GetAttribute("Hitted") and moving_Speed then
						if client_CFrame then
							self.CFrame += CFrame.new(client_CFrame, targetRootPart_Position).LookVector * moving_Speed * dt
						else
							self.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt
						end
					end

					if v4 <= total or flag then
						if flag then
							flag = false
						end

						total = 0
						local partBoundsInBox = workspace:GetPartBoundsInBox(self.CFrame, self.Size, p)

						if #partBoundsInBox > 0 then
							for _, v5 in ipairs(partBoundsInBox) do
								if not (v5 and v5.Parent) then
									continue
								end

								local parent

								if v5.Parent then
									parent = v5.Parent
								end

								if not Generate.CheckIfAlive(parent) then
									continue
								end

								local attacks_Debounce = parent:FindFirstChild("Attacks_Debounce")

								if not (attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil) then
									continue
								end

								Generate.Add_Instance(formatted, attacks_Debounce, p5)
								local humanoid = parent:FindFirstChild("Humanoid")
								local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
								local stun = parent:FindFirstChild("Stun")

								if not (humanoid and humanoidRootPart and stun) then
									continue
								end

								if parent:GetAttribute("GodMode") then
									Generate.Reflex(parent, "GodMode")
								elseif parent:GetAttribute("ReverseMode") then
									local humanoid2 = monster2:FindFirstChild("Humanoid")
									local v6 = MonsterSettings[enemy][action].Damage / v3

									if humanoid2 and humanoid2.Parent then
										if monster2:GetAttribute("GodMode") then
											Generate.Reflex(monster2, "GodMode")
										elseif monster2:GetAttribute("ReverseMode") then
											Generate.Reflex(monster2, "ReverseMode")
										else
											Generate.Add_Hit(parent, parent, nil, monster2, humanoid2, v6)
											humanoid2:TakeDamage(v6)
											local child = Players:FindFirstChild(parent.Name)

											if child then
												toggle:FireClient(child, "Damage_Counter", v6)
											end

											Generate.ShowDamage(monster2, Abbreviate.Format_Comma(v6, 1))
										end
									end

									Generate.Reflex(parent, "ReverseMode")
								else
									if parent:GetAttribute("Using_Instinct") then
										local child = Players:FindFirstChild(parent.Name)
										local playerData = child and child:FindFirstChild("PlayerData")

										if playerData then
											local dodge = playerData:FindFirstChild("Dodge")
											local maxDodge = playerData:FindFirstChild("MaxDodge")

											if dodge and maxDodge then
												if Generate.Get_Cooldown(child:FindFirstChild("Cooldown")) or break_Instinct then
													Generate.Add_Instinct(
														"InstinctCD",
														child:FindFirstChild("Cooldown"),
														broke_Cooldown
													)
													parent:SetAttribute("Using_Instinct", nil)
													instinct:FireClient(child, "Instinct_Broke")
												elseif dodge.Value > 0 then
													dodge.Value -= 1
													Generate.Instinct_Training(parent, 1)
													Generate.ShowDamage(parent, dodge.Value, "Dodge", maxDodge.Value)

													if dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
														Generate.Add_Instinct(
															"InstinctCD",
															child:FindFirstChild("Cooldown"),
															broke_Cooldown
														)
														parent:SetAttribute("Using_Instinct", nil)
														instinct:FireClient(child, "Instinct_Broke")
													end

													continue
												elseif dodge.Value <= 0 and parent:GetAttribute("Using_Instinct") then
													Generate.Add_Instinct(
														"InstinctCD",
														child:FindFirstChild("Cooldown"),
														broke_Cooldown
													)
													parent:SetAttribute("Using_Instinct", nil)
													instinct:FireClient(child, "Instinct_Broke")
												end
											end
										end
									end

									local v6 = not parent:GetAttribute("Defense_Boost") and 1 or parent:GetAttribute("Defense_Boost")
									local v7 = MonsterSettings[enemy][action].Damage / v6 / v3
									humanoid:TakeDamage(v7)

									if parent:HasTag("Pet") then
										Generate.ShowDamage(parent, Abbreviate.Format_Comma(v7, 1))
									end

									if hit_Sound then
										sendSound:FireAllClients(humanoidRootPart, "PlaySound_Character", {
											Folder = "Enemy",
											Enemy = enemy,
											Sound = `{action}_Hit`
										})
									end

									if skill_Type then
										if skill_Type == "Dragging" then
											task.spawn(
												Enemy_Drag,
												parent,
												humanoid,
												humanoidRootPart,
												stun,
												self,
												v7,
												enemy,
												action,
												formatted,
												data
											)
										elseif skill_Type == "Enemy_Effect" then
											clientBossSkills:FireAllClients(enemy, `{action}_Hitted`, {
												Hit_Character = parent,
												Action = action
											})
										elseif skill_Type == "Prison" then
											self:SetAttribute("Hitted", true)
											clientBossSkills:FireAllClients(enemy, `{action}_Prison`, {
												Hit_Character = parent,
												Action = action,
												Hit_Position = self.Position
											})

											if bodyPosition and self then
												bodyPosition.Position = self.Position
											end

											task.spawn(
												Enemy_Prison,
												skill_Type,
												parent,
												humanoid,
												humanoidRootPart,
												v7,
												action,
												formatted,
												data
											)
										end
									end

									if frozen then
										if bodyPosition and humanoidRootPart then
											bodyPosition.Position = humanoidRootPart.Position
										end

										local v8

										if frozen and frozen.Freeze_Sound then
											v8 = frozen.Freeze_Sound
										end

										Enemy_Freeze(parent, humanoidRootPart, action, enemy, frozen, v8)
									end

									if bodyPosition and knockback then
										if bodyPosition.StunTime then
											Generate.Stunning(stun, "Duration", 1, bodyPosition.StunTime)
										elseif knockback.StunTime then
											Generate.Stunning(stun, "Duration", 1, knockback.StunTime)
										end

										Generate.Aura_Training(parent, 1)

										if not parent:GetAttribute("Anti_Knockback") then
											clientEnemy:FireAllClients(parent, "BodyPosition", {
												Hitbox = self,
												Target_RootPart = humanoidRootPart,
												Type = "Custom_BodyPosition",
												Duration_Phase = duration_Phase,
												BodyPosition_Name = `BP_{formatted}`,
												BodyPosition = bodyPosition
											})
											clientEnemy:FireAllClients(parent, "Knockback", {
												Hitbox = self,
												Target_RootPart = humanoidRootPart,
												Type = "Custom_Knockback",
												Duration_Phase = duration_Phase,
												Knockback_Name = `BV_{formatted}`,
												Knockback = knockback
											})
										end
									elseif bodyPosition then
										if bodyPosition.StunTime then
											Generate.Stunning(stun, "Duration", 1, bodyPosition.StunTime)
										end

										Generate.Aura_Training(parent, 1)

										if not parent:GetAttribute("Anti_Knockback") then
											clientEnemy:FireAllClients(parent, "BodyPosition", {
												Hitbox = self,
												Target_RootPart = humanoidRootPart,
												Type = "Custom_BodyPosition",
												Duration_Phase = duration_Phase,
												BodyPosition_Name = `BP_{formatted}`,
												BodyPosition = bodyPosition
											})
										end
									elseif knockback then
										if knockback.StunTime then
											Generate.Stunning(stun, "Duration", 1, knockback.StunTime)
										end

										Generate.Aura_Training(parent, 1)

										if not parent:GetAttribute("Anti_Knockback") then
											clientEnemy:FireAllClients(parent, "Knockback", {
												Hitbox = self,
												Target_RootPart = humanoidRootPart,
												Type = "Custom_Knockback",
												Duration_Phase = duration_Phase,
												Knockback_Name = `BV_{formatted}`,
												Knockback = knockback
											})
										end
									end
								end
							end
						end
					end
				end
			end)
		end
	end
end

function Drag(player, instance, p, p2, instance2, object, object2, p3, hitbox, instance3, p5, p6, p7, data, p8, _, p9, folder, p11)
	local drag_Position = data.Drag_Position
	local dragging_Cooldown = data.Dragging_Cooldown
	local auraExp = p.AuraExp
	local auraMaxExp = p.AuraMaxExp

	for _ = 1, data.Max_Dragging do
		if not (Generate.CheckIfAlive(instance2) and Generate.CheckExist(hitbox) and instance3:FindFirstChild((`{p5}_{p11}_MultiHit`)) and (hitbox.Position - object2.Position).Magnitude <= p6) then
			break
		end

		if instance2:GetAttribute("GodMode") then
			Generate.Reflex(instance2, "GodMode")
		elseif instance2:GetAttribute("ReverseMode") then
			Generate.Reflex(instance2, "ReverseMode")
		else
			if instance2:GetAttribute("Using_Instinct") then
				local child = Players:FindFirstChild(instance2.Name)
				local playerData = child and child:FindFirstChild("PlayerData")

				if playerData then
					local dodge = playerData:FindFirstChild("Dodge")
					local maxDodge = playerData:FindFirstChild("MaxDodge")

					if dodge and maxDodge then
						if data.Break_Instinct then
							Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
							instance2:SetAttribute("Using_Instinct", nil)
							instinct:FireClient(child, "Instinct_Broke")
						elseif dodge.Value > 0 then
							dodge.Value -= 1
							Generate.Instinct_Training(instance2, 1)
							Generate.ShowDamage(instance2, dodge.Value, "Dodge", maxDodge.Value)

							if dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance2:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end

							continue
						elseif dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
							Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
							instance2:SetAttribute("Using_Instinct", nil)
							instinct:FireClient(child, "Instinct_Broke")
						end
					end
				end
			end

			local v2 = p7 / data.Max_Dragging or p7 / 10
			Generate.Add_Hit(player, instance, p2, instance2, object, v2)
			object:TakeDamage(v2)
			toggle:FireClient(player, "Damage_Counter", v2)

			if monster:FindFirstChild(instance2.Name) or instance2:HasTag("Pet") then
				Generate.ShowDamage(instance2, Abbreviate.Format_Comma(v2, 1))
			end

			if folder then
				sendSound:FireAllClients(object2, "PlaySound_Character", {
					Folder = folder,
					Enemy = p9,
					Sound = `{p11}_Hit`
				})
			end

			if p8.Drag_Effect then
				client_Skills:FireAllClients("Weapon_Effect", {
					Weapon = p9,
					RootPart = object2
				})
			end

			if drag_Position then
				if drag_Position.StunTime then
					Generate.Stunning(p3, "Duration", 1, drag_Position.StunTime)
				end

				if instance:GetAttribute("Using_Aura") and auraExp and auraExp.Value < auraMaxExp.Value then
					auraExp.Value += 1
				end

				Generate.Aura_Training(instance2, 1)

				if not instance2:GetAttribute("Anti_Knockback") then
					if instance2:HasTag("Enemy") and not object2:GetNetworkOwner() then
						Generate.Server_Position({
							Hitbox = hitbox,
							Skill_Releaser = instance,
							Target_RootPart = object2,
							Duration_Phase = dragging_Cooldown,
							BodyPosition_Name = `BP_{p9}_{p11}_{player.UserId}`,
							BodyPosition = drag_Position
						})
					else
						clientEnemy:FireAllClients(instance2, "BodyPosition", {
							Hitbox = hitbox,
							Skill_Releaser = instance,
							Target_RootPart = object2,
							Duration_Phase = dragging_Cooldown,
							Type = "Custom_BodyPosition",
							BodyPosition_Name = `BP_{p9}_{p11}_{player.UserId}`,
							BodyPosition = drag_Position
						})
					end
				end
			end

			task.wait(dragging_Cooldown)
		end
	end
end

function Enemy_Drag(instance, object, p, p2, p3, p4, weapon, action, p7, data)
	local drag_Position = data.Drag_Position
	local dragging_Cooldown = data.Dragging_Cooldown

	for _ = 1, data.Max_Dragging or 4 do
		if not (Generate.CheckIfAlive(instance) and Generate.CheckExist(p3)) then
			break
		end

		if instance:GetAttribute("GodMode") then
			Generate.Reflex(instance, "GodMode")
		elseif instance:GetAttribute("ReverseMode") then
			Generate.Reflex(instance, "ReverseMode")
		else
			if instance:GetAttribute("Using_Instinct") then
				local child = Players:FindFirstChild(instance.Name)
				local playerData = child and child:FindFirstChild("PlayerData")

				if playerData then
					local dodge = playerData:FindFirstChild("Dodge")
					local maxDodge = playerData:FindFirstChild("MaxDodge")

					if dodge and maxDodge then
						if dodge.Value > 0 then
							dodge.Value -= 1
							Generate.Instinct_Training(instance, 1)
							Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

							if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end

							continue
						elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
							Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
							instance:SetAttribute("Using_Instinct", nil)
							instinct:FireClient(child, "Instinct_Broke")
						end
					end
				end
			end

			object:TakeDamage(p4 / data.Max_Dragging or p4 / 10)

			if instance:HasTag("Pet") then
				Generate.ShowDamage(instance, Abbreviate.Format_Comma(p4, 1))
			end

			if data.Drag_Sound then
				clientBossSkills:FireAllClients(weapon, `{action}_Hitted`, {
					Hit_Character = instance,
					Action = action
				})
			end

			if data.Drag_Effect then
				client_Skills:FireAllClients("Weapon_Effect", {
					Weapon = weapon,
					RootPart = p
				})
			end

			if drag_Position then
				if drag_Position.StunTime then
					Generate.Stunning(p2, "Duration", 1, drag_Position.StunTime)
				end

				Generate.Aura_Training(instance, 1)

				if not instance:GetAttribute("Anti_Knockback") then
					clientEnemy:FireAllClients(instance, "BodyPosition", {
						Target_RootPart = p,
						Duration_Phase = dragging_Cooldown,
						Type = "Custom_BodyPosition",
						BodyPosition_Name = `BP_{p7}`,
						BodyPosition = drag_Position
					})
				end
			end

			task.wait(dragging_Cooldown)
		end
	end
end

function Enemy_Prison(p, instance, object, _, p2, _, _, p3)
	local prison = p3.Prison

	if p == "Prison" then
		for _ = 1, prison.Max_Prison do
			if not Generate.CheckIfAlive(instance) then
				break
			end

			if instance:GetAttribute("GodMode") then
				Generate.Reflex(instance, "GodMode")
			elseif instance:GetAttribute("ReverseMode") then
				Generate.Reflex(instance, "ReverseMode")
			else
				if instance:GetAttribute("Using_Instinct") then
					local child = Players:FindFirstChild(instance.Name)
					local playerData = child and child:FindFirstChild("PlayerData")

					if playerData then
						local dodge = playerData:FindFirstChild("Dodge")
						local maxDodge = playerData:FindFirstChild("MaxDodge")

						if dodge and maxDodge then
							if dodge.Value > 0 then
								dodge.Value -= 1
								Generate.Instinct_Training(instance, 1)
								Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

								if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
									Generate.Add_Instinct(
										"InstinctCD",
										child:FindFirstChild("Cooldown"),
										broke_Cooldown
									)
									instance:SetAttribute("Using_Instinct", nil)
									instinct:FireClient(child, "Instinct_Broke")
								end

								continue
							elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end
						end
					end
				end

				local v2 = p2 / prison.Prison_Divide or p2 / 10
				object:TakeDamage(v2)

				if instance:HasTag("Pet") then
					Generate.ShowDamage(instance, Abbreviate.Format_Comma(v2, 1))
				end

				task.wait(prison.Prison_Cooldown)
			end
		end
	end
end

function Enemy_Freeze(p, target_RootPart, p3, enemy, data, p5)
	if Generate.CheckIfAlive(p) then
		if data.Type == "Snow_Frozen" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Snow_Frozen",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		elseif data.Type == "Dough_Stunning" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Dough_Stunning",
				Target_RootPart = target_RootPart,
				Duration = data.Duration,
				Multiple_Hits = data.Multiple_Hits
			})
		elseif data.Type == "Moai_Stun" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Moai_Stun",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		elseif data.Type == "Stop_Card" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Stop_Card",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		else
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Frozen",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		end

		if p5 then
			sendSound:FireAllClients(target_RootPart, "PlaySound_Character", {
				Folder = "Enemy",
				Enemy = enemy,
				Sound = `{p3}_Hit`
			})
		end
	end
end

function Pillar(player, p, p2, instance, object, _, p3, p4, _, _, _)
	task.wait(p4.Delayed_Duration)

	if Generate.CheckIfAlive(instance) then
		if instance:GetAttribute("GodMode") then
			Generate.Reflex(instance, "GodMode")
			return
		end

		if instance:GetAttribute("ReverseMode") then
			Generate.Reflex(instance, "ReverseMode")
			return
		end

		if instance:GetAttribute("Using_Instinct") then
			local child = Players:FindFirstChild(instance.Name)
			local playerData = child and child:FindFirstChild("PlayerData")

			if playerData then
				local dodge = playerData:FindFirstChild("Dodge")
				local maxDodge = playerData:FindFirstChild("MaxDodge")

				if dodge and maxDodge then
					if dodge.Value > 0 then
						dodge.Value -= 1
						Generate.Instinct_Training(instance, 1)
						Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

						if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
							Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
							instance:SetAttribute("Using_Instinct", nil)
							instinct:FireClient(child, "Instinct_Broke")
						end

						return
					elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
						Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
						instance:SetAttribute("Using_Instinct", nil)
						instinct:FireClient(child, "Instinct_Broke")
					end
				end
			end
		end

		local v2 = p3 * 1.25
		Generate.Add_Hit(player, p, p2, instance, object, v2)
		object:TakeDamage(v2)
		toggle:FireClient(player, "Damage_Counter", v2)

		if monster:FindFirstChild(instance.Name) or instance:HasTag("Pet") then
			Generate.ShowDamage(instance, Abbreviate.Format_Comma(v2, 1))
		end
	end
end

function Coffin(player, p, p2, instance, object, p3, data, _, _)
	task.wait(data.Delayed_Duration)

	if Generate.CheckIfAlive(instance) then
		if instance:GetAttribute("GodMode") then
			Generate.Reflex(instance, "GodMode")
			return
		end

		if instance:GetAttribute("ReverseMode") then
			Generate.Reflex(instance, "ReverseMode")
			return
		end

		if instance:GetAttribute("Using_Instinct") then
			local child = Players:FindFirstChild(instance.Name)
			local playerData = child and child:FindFirstChild("PlayerData")

			if playerData then
				local dodge = playerData:FindFirstChild("Dodge")
				local maxDodge = playerData:FindFirstChild("MaxDodge")

				if dodge and maxDodge then
					if data.Break_Instinct then
						Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
						instance:SetAttribute("Using_Instinct", nil)
						instinct:FireClient(child, "Instinct_Broke")
					elseif dodge.Value > 0 then
						dodge.Value -= 1
						Generate.Instinct_Training(instance, 1)
						Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

						if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
							Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
							instance:SetAttribute("Using_Instinct", nil)
							instinct:FireClient(child, "Instinct_Broke")
						end

						return
					elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
						Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
						instance:SetAttribute("Using_Instinct", nil)
						instinct:FireClient(child, "Instinct_Broke")
					end
				end
			end
		end

		local v2 = p3 * data.Max_Phase
		Generate.Add_Hit(player, p, p2, instance, object, v2)
		object:TakeDamage(v2)
		toggle:FireClient(player, "Damage_Counter", v2)

		if monster:FindFirstChild(instance.Name) or instance:HasTag("Pet") then
			Generate.ShowDamage(instance, Abbreviate.Format_Comma(v2, 1))
		end
	end
end

function Spinning(player, p, p2, instance, object, p3, p4, data, _, _)
	for _ = 1, data.Spinning_Loop do
		if not (Generate.CheckIfAlive(instance) and Generate.CheckExist(p3)) then
			break
		end

		local v2 = p4 / data.Spin_Divide or p4 / 10
		Generate.Add_Hit(player, p, p2, instance, object, v2)
		object:TakeDamage(v2)
		toggle:FireClient(player, "Damage_Counter", v2)

		if monster:FindFirstChild(instance.Name) or instance:HasTag("Pet") then
			Generate.ShowDamage(instance, Abbreviate.Format_Comma(v2, 1))
		end

		task.wait(data.Spinning_Cooldown)
	end
end

function Prison(p, player, instance, p2, instance2, p3, object, p4, p5, list, enemy, p7, p8, folder)
	local prison = p5.Prison

	if p == "Heal_Prison" then
		for _ = 1, prison.Max_Prison do
			local humanoidRootPart

			if Generate.CheckIfAlive(instance) then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			end

			local humanoid

			if Generate.CheckIfAlive(instance) then
				humanoid = instance:FindFirstChild("Humanoid")
			end

			if not Generate.CheckIfAlive(instance2) then
				break
			end

			if instance2:GetAttribute("GodMode") then
				Generate.Reflex(instance2, "GodMode")
			elseif instance2:GetAttribute("ReverseMode") then
				Generate.Reflex(instance2, "ReverseMode")
			else
				if instance2:GetAttribute("Using_Instinct") then
					local child = Players:FindFirstChild(instance2.Name)
					local playerData = child and child:FindFirstChild("PlayerData")

					if playerData then
						local dodge = playerData:FindFirstChild("Dodge")
						local maxDodge = playerData:FindFirstChild("MaxDodge")

						if dodge and maxDodge then
							if prison.Break_Instinct then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance2:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							elseif dodge.Value > 0 then
								dodge.Value -= 1
								Generate.Instinct_Training(instance2, 1)
								Generate.ShowDamage(instance2, dodge.Value, "Dodge", maxDodge.Value)

								if dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
									Generate.Add_Instinct(
										"InstinctCD",
										child:FindFirstChild("Cooldown"),
										broke_Cooldown
									)
									instance2:SetAttribute("Using_Instinct", nil)
									instinct:FireClient(child, "Instinct_Broke")
								end

								continue
							elseif dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance2:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end
						end
					end
				end

				local v2 = p4 / prison.Prison_Divide or p4 / 10
				Generate.Add_Hit(player, instance, p2, instance2, object, v2)
				object:TakeDamage(v2)
				toggle:FireClient(player, "Damage_Counter", v2)

				if monster:FindFirstChild(instance2.Name) or instance2:HasTag("Pet") then
					Generate.ShowDamage(instance2, Abbreviate.Format_Comma(v2, 1))
				end

				if p == "Heal_Prison" and humanoidRootPart and humanoid then
					local heal = p5.Heal
					local v3 = humanoid.MaxHealth / heal
					humanoid.Health += v3
					Generate.ShowDamage(humanoidRootPart, Abbreviate.Format_Comma(v3, 1), "Heal")
				end

				if p8 then
					sendSound:FireAllClients(p3, "PlaySound_Character", {
						Folder = folder,
						Enemy = enemy,
						Sound = `{p7}_Hit`
					})
				end

				task.wait(prison.Prison_Cooldown)
			end
		end
	else
		for _ = 1, prison.Max_Prison do
			if not Generate.CheckIfAlive(instance2) then
				break
			end

			if instance2:GetAttribute("GodMode") then
				Generate.Reflex(instance2, "GodMode")
			elseif instance2:GetAttribute("ReverseMode") then
				Generate.Reflex(instance2, "ReverseMode")
			else
				if instance2:GetAttribute("Using_Instinct") then
					local child = Players:FindFirstChild(instance2.Name)
					local playerData = child and child:FindFirstChild("PlayerData")

					if playerData then
						local dodge = playerData:FindFirstChild("Dodge")
						local maxDodge = playerData:FindFirstChild("MaxDodge")

						if dodge and maxDodge then
							if prison.Break_Instinct then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance2:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							elseif dodge.Value > 0 then
								dodge.Value -= 1
								Generate.Instinct_Training(instance2, 1)
								Generate.ShowDamage(instance2, dodge.Value, "Dodge", maxDodge.Value)

								if dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
									Generate.Add_Instinct(
										"InstinctCD",
										child:FindFirstChild("Cooldown"),
										broke_Cooldown
									)
									instance2:SetAttribute("Using_Instinct", nil)
									instinct:FireClient(child, "Instinct_Broke")
								end

								continue
							elseif dodge.Value <= 0 and instance2:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance2:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end
						end
					end
				end

				local v2 = p4 / prison.Prison_Divide or p4 / 10
				Generate.Add_Hit(player, instance, p2, instance2, object, v2)
				object:TakeDamage(v2)
				toggle:FireClient(player, "Damage_Counter", v2)

				if monster:FindFirstChild(instance2.Name) or instance2:HasTag("Pet") then
					Generate.ShowDamage(instance2, Abbreviate.Format_Comma(v2, 1))
				end

				if p8 then
					sendSound:FireAllClients(p3, "PlaySound_Character", {
						Folder = folder,
						Enemy = enemy,
						Sound = `{p7}_Hit`
					})
				end

				task.wait(prison.Prison_Cooldown)
			end
		end
	end

	if list and #list > 0 then
		for _, v2 in ipairs(list) do
			if not Generate.CheckIfAlive(v2) then
				continue
			end

			local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			if v2:HasTag("Enemy") then
			end

			if humanoidRootPart:FindFirstChild((`BV_{enemy}_{p7}_{player.UserId}`)) then
				clientEnemy:FireAllClients(v2, "Knockback", {
					Target_RootPart = humanoidRootPart,
					Type = "Clear_Knockback",
					Knockback_Name = `BV_{enemy}_{p7}_{player.UserId}`
				})
			elseif humanoidRootPart:FindFirstChild((`BP_{enemy}_{p7}_{player.UserId}`)) then
				clientEnemy:FireAllClients(v2, "Knockback", {
					Target_RootPart = humanoidRootPart,
					Type = "Clear_Knockback",
					Knockback_Name = `BP_{enemy}_{p7}_{player.UserId}`
				})
			end
		end

		table.clear(list)
	end
end

function Freeze(_, _, _, p, _, target_RootPart, _, data, enemy, p4, folder)
	if Generate.CheckIfAlive(p) then
		if data.Type == "Snow_Frozen" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Snow_Frozen",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		elseif data.Type == "Dough_Stunning" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Dough_Stunning",
				Target_RootPart = target_RootPart,
				Duration = data.Duration,
				Multiple_Hits = data.Multiple_Hits
			})
		elseif data.Type == "Moai_Stun" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Moai_Stun",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		elseif data.Type == "Stop_Card" then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Stop_Card",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		else
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Frozen",
				Target_RootPart = target_RootPart,
				Duration = data.Duration
			})
		end

		if folder then
			sendSound:FireAllClients(target_RootPart, "PlaySound_Character", {
				Folder = folder,
				Enemy = enemy,
				Sound = `{p4}_Hit`
			})
		end
	end
end

function Burn(player, p, p2, instance, object, target_RootPart, p4, data, p5)
	if p5 then
		if Generate.CheckIfAlive(instance) then
			clientEffect:FireAllClients("Visual_Effect", {
				Type = "Burning",
				Target_RootPart = target_RootPart,
				Duration = p5.Duration
			})
		end
	else
		for i = 1, data.Burning_Times do
			if not Generate.CheckIfAlive(instance) then
				continue
			end

			if instance:GetAttribute("GodMode") then
				Generate.Reflex(instance, "GodMode")
			elseif instance:GetAttribute("ReverseMode") then
				Generate.Reflex(instance, "ReverseMode")
			else
				if instance:GetAttribute("Using_Instinct") then
					local child = Players:FindFirstChild(instance.Name)
					local playerData = child and child:FindFirstChild("PlayerData")

					if playerData then
						local dodge = playerData:FindFirstChild("Dodge")
						local maxDodge = playerData:FindFirstChild("MaxDodge")

						if dodge and maxDodge then
							if data.Break_Instinct then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							elseif dodge.Value > 0 then
								dodge.Value -= 1
								Generate.Instinct_Training(instance, 1)
								Generate.ShowDamage(instance, dodge.Value, "Dodge", maxDodge.Value)

								if dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
									Generate.Add_Instinct(
										"InstinctCD",
										child:FindFirstChild("Cooldown"),
										broke_Cooldown
									)
									instance:SetAttribute("Using_Instinct", nil)
									instinct:FireClient(child, "Instinct_Broke")
								end

								continue
							elseif dodge.Value <= 0 and instance:GetAttribute("Using_Instinct") then
								Generate.Add_Instinct("InstinctCD", child:FindFirstChild("Cooldown"), broke_Cooldown)
								instance:SetAttribute("Using_Instinct", nil)
								instinct:FireClient(child, "Instinct_Broke")
							end
						end
					end
				end

				if i == 1 then
					clientEffect:FireAllClients("Visual_Effect", {
						Type = "Burning",
						Target_RootPart = target_RootPart,
						Duration = data.Duration
					})
				end

				local v2 = p4 / data.Burning_Divide
				Generate.Add_Hit(player, p, p2, instance, object, v2)
				object:TakeDamage(v2)
				toggle:FireClient(player, "Damage_Counter", v2)

				if monster:FindFirstChild(instance.Name) or instance:HasTag("Pet") then
					Generate.ShowDamage(instance, Abbreviate.Format_Comma(v2, 1))
				end

				task.wait(data.Burning_Cooldown)
			end
		end
	end
end

function Generate.Teleport_Hitbox(instance, p, instance2, p2, p3, p4, p5, _, duration, data)
	local found_Location

	if data and data.Found_Location then
		found_Location = data.Found_Location
	else
		found_Location = nil
	end

	local teleport_CD

	if data and data.Teleport_CD then
		teleport_CD = data.Teleport_CD
	else
		teleport_CD = nil
	end

	local portal_Duration

	if data and data.Portal_Duration then
		portal_Duration = data.Portal_Duration
	else
		portal_Duration = nil
	end

	local userId = instance.UserId
	local formatted = `Teleported_{p4}_{p5}`

	if p3 == "Repeat" then
		local now = os.clock()
		local heartbeatConnection = nil
		local total = 0
		local flag = true
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local now2 = os.clock()

			if now + duration <= now2 or not Generate.CheckExist(instance2) then
				if instance2 then
					instance2:Destroy()
				end

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			elseif total >= 0.1 or flag then
				if flag then
					flag = false
				end

				total = 0
				local partBoundsInBox = workspace:GetPartBoundsInBox(instance2.CFrame, instance2.Size, p2)

				if #partBoundsInBox > 0 then
					for _, v2 in ipairs(partBoundsInBox) do
						if not (v2 and v2.Parent) then
							continue
						end

						local parent

						if v2.Parent then
							parent = v2.Parent
						end

						local attacks_Debounce

						if parent then
							attacks_Debounce = parent:FindFirstChild("Attacks_Debounce")
						end

						if not (Generate.CheckIfAlive(parent) and attacks_Debounce and attacks_Debounce:FindFirstChild(formatted) == nil) then
							continue
						end

						Generate.Add_Instance(formatted, attacks_Debounce, teleport_CD)
						local party = instance:FindFirstChild("Party")
						local v3

						if parent:HasTag("Pet") then
							v3 = Players:FindFirstChild(parent:GetAttribute("Summoner"))
						else
							v3 = Players:GetPlayerFromCharacter(parent)
						end

						if not Generate.Check_Teleport(instance, v3, party, p, parent) then
							continue
						end

						local humanoid = parent:FindFirstChild("Humanoid")
						local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

						if humanoid and humanoidRootPart then
							client_Skills:FireAllClients("Clients_Skill", p4, p5, "Release", {
								Type = "Enter",
								Target_RootPart = humanoidRootPart,
								New_Location = found_Location,
								Releaser_Id = userId,
								Duration = duration,
								Portal_Duration = portal_Duration
							})
						end
					end
				end
			end
		end)
	end
end

function Generate.Invisible(instance)
	if instance:GetAttribute("Using_Aura") then
		local auraColor_Folder = instance:FindFirstChild("AuraColor_Folder")

		for _, child in ipairs(auraColor_Folder:GetChildren()) do
			child:SetAttribute("Original_Transparency", child.Transparency)
			TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end

	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("MeshPart") and child.Transparency < 1 then
			child:SetAttribute("Original_Transparency", child.Transparency)
			TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()

			if child.Name == "Head" then
				local face = child:FindFirstChild("face")

				if face and face:IsA("Decal") then
					face:SetAttribute("Original_Transparency", face.Transparency)
					TweenService:Create(face, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end
		elseif child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")

			if handle then
				if handle.Transparency < 1 then
					handle:SetAttribute("Original_Transparency", handle.Transparency)
					TweenService:Create(handle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end

				for _, descendant in pairs(handle:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") or descendant:IsA("Decal") and descendant.Transparency < 1 then
						descendant:SetAttribute("Original_Transparency", descendant.Transparency)
						TweenService:Create(
							descendant,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Beam") or descendant:IsA("Trail") and descendant.Enabled then
						descendant.Enabled = false
					end
				end
			end
		end
	end
end

function Generate.Visible(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("MeshPart") and child:GetAttribute("Original_Transparency") then
			TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = child:GetAttribute("Original_Transparency")
			}):Play()
			child:SetAttribute("Original_Transparency", nil)

			if child.Name == "Head" then
				local face = child:FindFirstChild("face")

				if face and face:IsA("Decal") and face:GetAttribute("Original_Transparency") then
					TweenService:Create(face, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = face:GetAttribute("Original_Transparency")
					}):Play()
					face:SetAttribute("Original_Transparency", nil)
				end
			end
		elseif child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")

			if handle then
				if handle:GetAttribute("Original_Transparency") then
					TweenService:Create(handle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = handle:GetAttribute("Original_Transparency")
					}):Play()
					handle:SetAttribute("Original_Transparency", nil)
				end

				for _, descendant in pairs(handle:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") or descendant:IsA("Decal") and descendant:GetAttribute("Original_Transparency") then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = descendant:GetAttribute("Original_Transparency")
							}
						):Play()
						descendant:SetAttribute("Original_Transparency", nil)
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Beam") or descendant:IsA("Trail") and not descendant.Enabled then
						descendant.Enabled = true
					end
				end
			end
		end
	end

	if instance:GetAttribute("Using_Aura") then
		local auraColor_Folder = instance:FindFirstChild("AuraColor_Folder")

		for _, child in ipairs(auraColor_Folder:GetChildren()) do
			if child:GetAttribute("Original_Transparency") then
				if string.find(child.Name, "_AuraColor") then
					TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 0.85
					}):Play()
				else
					TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 0
					}):Play()
				end
			end

			child:SetAttribute("Original_Transparency", nil)
		end
	end
end

function Generate.Flying_Rock(instance, data)
	local destroyTime = data.DestroyTime
	local cooldown = data.Cooldown
	local loops = data.Loops
	local raycast = data.Raycast
	local duration = data.Duration
	local size_X = data.Size_X
	local size_Y = data.Size_Y
	local size_Z = data.Size_Z
	local left_Right = data.Left_Right
	local up_Down = data.Up_Down
	local front_Back = data.Front_Back
	local heartbeatConnection = nil
	local lastTime = tick()
	local lastTime2 = tick()
	local color = nil
	local material = nil
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if destroyTime <= tick() - lastTime or not (Generate.CheckExist(instance) and instance:GetAttribute("Flying_Rock")) then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		elseif cooldown <= tick() - lastTime2 then
			lastTime2 = tick()
			local raycastResult = workspace:Raycast(instance.Position + createVector(0, 3, 0), raycast, raycastParams)

			if raycastResult and raycastResult.Instance then
				if raycastResult.Instance.Color and raycastResult.Instance.Material then
					color = raycastResult.Instance.Color
					material = raycastResult.Instance.Material
				end

				for _ = 1, loops do
					local number = Random.new():NextNumber(size_X.Min, size_X.Max)
					local number2 = Random.new():NextNumber(size_Y.Min, size_Y.Max)
					local number3 = Random.new():NextNumber(size_Z.Min, size_Z.Max)
					local v4 = math.random(left_Right.Min, left_Right.Max)
					local v5 = math.random(up_Down.Min, up_Down.Max)
					local v6 = math.random(front_Back.Min, front_Back.Max)
					local part = Instance.new("Part")
					part.CanCollide = true
					part.Anchored = false
					part.Size = Vector3.new(number, number2, number3)
					part.Color = color
					part.Material = material
					part.Position = raycastResult.Position
					part.CollisionGroup = "Player"
					part.Parent = visuals
					part.AssemblyLinearVelocity = Vector3.new(v4, v5, v6)
					part.AssemblyAngularVelocity = Vector3.new(v4, v5, v6)
					task.delay(duration, function()
						local tween = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0),
								Transparency = 1
							}
						)
						tween:Play()
						tween.Completed:Wait()

						if part and part.Parent then
							part:Destroy()
						end
					end)
				end
			end
		end
	end)
end

function Server_Knockback(data)
	local target_RootPart = data.Target_RootPart
	local knockback = data.Knockback
	local knockback_Name = data.Knockback_Name

	if knockback and target_RootPart and target_RootPart.Parent then
		local v2 = knockback.Clear_BV and true or false
		local velocity = knockback.Velocity
		local duration = knockback.Duration
		local duration_Phase = data.Duration_Phase

		if v2 then
			Generate.ClearBV(target_RootPart, knockback_Name)
		end

		local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

		if rootAttachment then
			local child = target_RootPart:FindFirstChild(knockback_Name)

			if child or not velocity or not duration or target_RootPart:GetAttribute("No_Knockback") then
				if child then
					child:SetAttribute("LastTime", tick())
				end
			else
				local hitbox = data.Hitbox
				local v3 = not knockback.Ignore_Hitbox
				local invincible = knockback.Invincible or nil
				local v4 = knockback.Respect_Duration and true or false
				local true_Invincible = knockback.True_Invincible
				local sync_Hitbox = knockback.Sync_Hitbox

				if knockback.Respect_Holding then
					local itemType = data.ItemType
					local action = data.Action
					local cooldown_Folder = data.Cooldown_Folder

					if itemType and action and cooldown_Folder then
						hitbox = cooldown_Folder:FindFirstChild((`{itemType}_{action}_Holding`)) or hitbox
					end
				end

				if sync_Hitbox then
					local itemType = data.ItemType
					local action = data.Action
					local cooldown_Folder = data.Cooldown_Folder

					if itemType and action and cooldown_Folder then
						hitbox = cooldown_Folder:FindFirstChild((`{itemType}_{action}_MultiHit`)) or hitbox
					end
				end

				if invincible and not target_RootPart:GetAttribute("No_Knockback") then
					target_RootPart:SetAttribute("No_Knockback", true)
					task.delay(invincible, function()
						if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
							target_RootPart:SetAttribute("No_Knockback", nil)
						end
					end)
				end

				local linearVelocity = Instance.new("LinearVelocity")
				linearVelocity.Name = knockback_Name
				linearVelocity.MaxForce = 1000000
				linearVelocity.Attachment0 = rootAttachment
				linearVelocity.VectorVelocity = velocity
				linearVelocity.Parent = target_RootPart
				linearVelocity:SetAttribute("LastTime", tick())

				if true_Invincible then
					linearVelocity:SetAttribute("Invincible", true)
				end

				if duration_Phase then
					if v4 then
						duration_Phase = duration
					end
				else
					duration_Phase = duration
				end

				coroutine.wrap(function()
					if v3 then
						repeat
							task.wait(0.1)
							local v5 = tick() - linearVelocity:GetAttribute("LastTime")
						until duration_Phase <= v5 or not (linearVelocity and linearVelocity.Parent and hitbox and hitbox.Parent)
					else
						repeat
							task.wait(0.1)
							local v5 = tick() - linearVelocity:GetAttribute("LastTime")
						until duration_Phase <= v5 or not (linearVelocity and linearVelocity.Parent)
					end

					if linearVelocity and linearVelocity.Parent then
						linearVelocity:Destroy()
					end
				end)()
			end
		else
			local child = target_RootPart:FindFirstChild(knockback_Name)

			if child or not velocity or not duration or target_RootPart:GetAttribute("No_Knockback") then
				if child then
					child:SetAttribute("LastTime", tick())
				end
			else
				local hitbox = data.Hitbox
				local v3 = not knockback.Ignore_Hitbox
				local invincible = knockback.Invincible or nil
				local v4 = knockback.Respect_Duration and true or false
				local true_Invincible = knockback.True_Invincible
				local sync_Hitbox = knockback.Sync_Hitbox

				if knockback.Respect_Holding then
					local itemType = data.ItemType
					local action = data.Action
					local cooldown_Folder = data.Cooldown_Folder

					if itemType and action and cooldown_Folder then
						hitbox = cooldown_Folder:FindFirstChild((`{itemType}_{action}_Holding`)) or hitbox
					end
				end

				if sync_Hitbox then
					local itemType = data.ItemType
					local action = data.Action
					local cooldown_Folder = data.Cooldown_Folder

					if itemType and action and cooldown_Folder then
						hitbox = cooldown_Folder:FindFirstChild((`{itemType}_{action}_MultiHit`)) or hitbox
					end
				end

				if invincible and not target_RootPart:GetAttribute("No_Knockback") then
					target_RootPart:SetAttribute("No_Knockback", true)
					task.delay(invincible, function()
						if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
							target_RootPart:SetAttribute("No_Knockback", nil)
						end
					end)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = knockback_Name
				bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
				bodyVelocity.Velocity = velocity
				bodyVelocity.Parent = target_RootPart
				bodyVelocity:SetAttribute("LastTime", tick())

				if true_Invincible then
					bodyVelocity:SetAttribute("Invincible", true)
				end

				local more_Delay = data.More_Delay or 0

				if duration_Phase and not v4 then
					duration = duration_Phase + more_Delay
				end

				coroutine.wrap(function()
					if v3 then
						repeat
							task.wait(0.1)
							local v5 = tick() - bodyVelocity:GetAttribute("LastTime")
						until duration <= v5 or not (bodyVelocity and bodyVelocity.Parent and hitbox and hitbox.Parent)
					else
						repeat
							task.wait(0.1)
							local v5 = tick() - bodyVelocity:GetAttribute("LastTime")
						until duration <= v5 or not (bodyVelocity and bodyVelocity.Parent)
					end

					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity:Destroy()
					end
				end)()
			end
		end
	end
end

function Generate.Server_Position(data)
	local target_RootPart = data.Target_RootPart
	local bodyPosition = data.BodyPosition
	local bodyPosition_Name = data.BodyPosition_Name

	if bodyPosition and target_RootPart and target_RootPart.Parent then
		local type = bodyPosition.Type
		local v2 = bodyPosition.Clear_BV and true or false
		local duration = bodyPosition.Duration or 1
		local duration_Phase = data.Duration_Phase
		local position = bodyPosition.Position

		if v2 then
			Generate.ClearBV(target_RootPart, bodyPosition_Name)
		end

		if type == "Body_Position_Reverse" then
			local skill_Releaser = data.Skill_Releaser

			if Generate.CheckIfAlive(skill_Releaser) then
				local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

				if Generate.CheckExist(humanoidRootPart) and Generate.CheckExist(target_RootPart) then
					local child = humanoidRootPart:FindFirstChild(bodyPosition_Name)

					if child or not duration or target_RootPart:GetAttribute("No_Knockback") then
						if child then
							child:SetAttribute("LastTime", tick())
						end
					else
						local P = bodyPosition.P or 10000
						local invincible = bodyPosition.Invincible or nil
						local v3 = bodyPosition.Respect_Duration and true or false
						local true_Invincible = bodyPosition.True_Invincible

						if invincible and not target_RootPart:GetAttribute("No_Knockback") then
							target_RootPart:SetAttribute("No_Knockback", true)
							task.delay(invincible, function()
								if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
									target_RootPart:SetAttribute("No_Knockback", nil)
								end
							end)
						end

						local bodyPosition2 = Instance.new("BodyPosition")
						bodyPosition2.Name = bodyPosition_Name
						bodyPosition2.P = P
						bodyPosition2.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyPosition2.Position = target_RootPart.Position + target_RootPart.CFrame.LookVector * -bodyPosition.Distance or 5
						bodyPosition2.Parent = humanoidRootPart
						bodyPosition2:SetAttribute("LastTime", tick())

						if true_Invincible then
							bodyPosition2:SetAttribute("Invincible", true)
						end

						if duration_Phase then
							if v3 then
								duration_Phase = duration
							end
						else
							duration_Phase = duration
						end

						coroutine.wrap(function()
							repeat
								task.wait(0.1)
								local v4 = tick() - bodyPosition2:GetAttribute("LastTime")
							until duration_Phase <= v4 or not (bodyPosition2 and bodyPosition2.Parent)

							if bodyPosition2 and bodyPosition2.Parent then
								bodyPosition2:Destroy()
							end
						end)()
						humanoidRootPart.CFrame = CFrame.new(
							humanoidRootPart.Position,
							humanoidRootPart.Position + target_RootPart.CFrame.LookVector
						)
					end
				end
			end
		else
			local child = target_RootPart:FindFirstChild(bodyPosition_Name)

			if child or not position or not duration or not type or target_RootPart:GetAttribute("No_Knockback") then
				if child then
					child:SetAttribute("LastTime", tick())
				end
			else
				local hitbox = data.Hitbox

				if type == "Align_Position" then
					local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

					if rootAttachment then
						local v3 = not bodyPosition.Ignore_Hitbox
						local v4 = bodyPosition.Respect_Duration and true or false
						local responsiveness = bodyPosition.Responsiveness or 10
						local maxForce = bodyPosition.MaxForce or 1000000
						local invincible = bodyPosition.Invincible or nil
						local true_Invincible = bodyPosition.True_Invincible

						if invincible and not target_RootPart:GetAttribute("No_Knockback") then
							target_RootPart:SetAttribute("No_Knockback", true)
							task.delay(invincible, function()
								if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
									target_RootPart:SetAttribute("No_Knockback", nil)
								end
							end)
						end

						local alignPosition = Instance.new("AlignPosition")
						alignPosition.Name = bodyPosition_Name
						alignPosition.MaxForce = maxForce
						alignPosition.Responsiveness = responsiveness
						alignPosition.Attachment0 = rootAttachment
						alignPosition.Attachment1 = position
						alignPosition.Parent = target_RootPart
						alignPosition:SetAttribute("LastTime", tick())

						if true_Invincible then
							alignPosition:SetAttribute("Invincible", true)
						end

						if duration_Phase then
							if v4 then
								duration_Phase = duration
							end
						else
							duration_Phase = duration
						end

						coroutine.wrap(function()
							if v3 then
								repeat
									task.wait(0.1)
									local v5 = tick() - alignPosition:GetAttribute("LastTime")
								until duration_Phase <= v5 or not (alignPosition and alignPosition.Parent and hitbox and hitbox.Parent)
							else
								repeat
									task.wait(0.1)
									local v5 = tick() - alignPosition:GetAttribute("LastTime")
								until duration_Phase <= v5 or not (alignPosition and alignPosition.Parent)
							end

							if alignPosition and alignPosition.Parent then
								alignPosition:Destroy()
							end
						end)()
					end
				elseif type == "StartEnd_Align" then
					local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

					if rootAttachment and typeof(position) == "table" then
						local v3 = not bodyPosition.Ignore_Hitbox
						local v4 = bodyPosition.Respect_Duration and true or false
						local responsiveness = bodyPosition.Responsiveness or 10
						local applyAtCenterOfMass = bodyPosition.ApplyAtCenterOfMass and true or false
						local maxForce = bodyPosition.MaxForce or 1000000
						local invincible = bodyPosition.Invincible or nil
						local delayed = bodyPosition.Delayed or 1.5
						local start = position.Start
						local attachment = position.End

						if invincible and not target_RootPart:GetAttribute("No_Knockback") then
							target_RootPart:SetAttribute("No_Knockback", true)
							task.delay(invincible, function()
								if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
									target_RootPart:SetAttribute("No_Knockback", nil)
								end
							end)
						end

						if start and attachment then
							local alignPosition = Instance.new("AlignPosition")
							alignPosition.Name = bodyPosition_Name
							alignPosition.MaxForce = maxForce
							alignPosition.ApplyAtCenterOfMass = applyAtCenterOfMass
							alignPosition.Responsiveness = responsiveness
							alignPosition.Attachment0 = rootAttachment
							alignPosition.Attachment1 = start
							alignPosition.Parent = target_RootPart
							alignPosition:SetAttribute("Invincible", true)
							alignPosition:SetAttribute("LastTime", tick())
							task.delay(delayed, function()
								if alignPosition and alignPosition.Parent and attachment then
									alignPosition.Attachment1 = attachment
								end
							end)

							if duration_Phase then
								if v4 then
									duration_Phase = duration
								end
							else
								duration_Phase = duration
							end

							coroutine.wrap(function()
								if v3 then
									repeat
										task.wait(0.1)
										local v7 = tick() - alignPosition:GetAttribute("LastTime")
									until duration_Phase <= v7 or not (alignPosition and alignPosition.Parent and hitbox and hitbox.Parent)
								else
									repeat
										task.wait(0.1)
										local v7 = tick() - alignPosition:GetAttribute("LastTime")
									until duration_Phase <= v7 or not (alignPosition and alignPosition.Parent)
								end

								if alignPosition and alignPosition.Parent then
									alignPosition:Destroy()
								end
							end)()
						end
					end
				elseif type == "Body_Position" then
					local P = bodyPosition.P or 10000
					local v3 = not bodyPosition.Ignore_Hitbox
					local v4 = bodyPosition.Respect_Duration and true or false
					local invincible = bodyPosition.Invincible or nil
					local maxForce = bodyPosition.MaxForce or 1000000
					local true_Invincible = bodyPosition.True_Invincible

					if bodyPosition.Respect_Holding then
						local itemType = data.ItemType
						local action = data.Action
						local cooldown_Folder = data.Cooldown_Folder

						if itemType and action and cooldown_Folder then
							hitbox = cooldown_Folder:FindFirstChild((`{itemType}_{action}_Holding`)) or hitbox
						end
					end

					if invincible and not target_RootPart:GetAttribute("No_Knockback") then
						target_RootPart:SetAttribute("No_Knockback", true)
						task.delay(invincible, function()
							if target_RootPart and target_RootPart.Parent and target_RootPart:GetAttribute("No_Knockback") then
								target_RootPart:SetAttribute("No_Knockback", nil)
							end
						end)
					end

					local bodyPosition2 = Instance.new("BodyPosition")
					bodyPosition2.Name = bodyPosition_Name
					bodyPosition2.P = P
					bodyPosition2.MaxForce = createVector(1, 1, 1) * maxForce
					bodyPosition2.Position = position
					bodyPosition2.Parent = target_RootPart
					bodyPosition2:SetAttribute("LastTime", tick())

					if true_Invincible then
						bodyPosition2:SetAttribute("Invincible", true)
					end

					if bodyPosition.TurnBack then
						local skill_Releaser = data.Skill_Releaser

						if Generate.CheckIfAlive(skill_Releaser) then
							local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart and humanoidRootPart.Parent then
								target_RootPart.CFrame = CFrame.new(
									target_RootPart.Position,
									target_RootPart.Position + -humanoidRootPart.CFrame.LookVector
								)
							end
						end
					end

					if duration_Phase then
						if v4 then
							duration_Phase = duration
						end
					else
						duration_Phase = duration
					end

					coroutine.wrap(function()
						if v3 then
							repeat
								task.wait(0.1)
								local v5 = tick() - bodyPosition2:GetAttribute("LastTime")
							until duration_Phase <= v5 or not (bodyPosition2 and bodyPosition2.Parent and hitbox and hitbox.Parent)
						else
							repeat
								task.wait(0.1)
								local v5 = tick() - bodyPosition2:GetAttribute("LastTime")
							until duration_Phase <= v5 or not (bodyPosition2 and bodyPosition2.Parent)
						end

						if bodyPosition2 and bodyPosition2.Parent then
							bodyPosition2:Destroy()
						end
					end)()
				end
			end
		end
	end
end

function Clear_Knockback(p)
	local target_RootPart = p.Target_RootPart
	local knockback_Name = p.Knockback_Name
	local child = knockback_Name and target_RootPart:FindFirstChild(knockback_Name)

	if child then
		child:Destroy()
	end
end

function Generate.Reflex(target_Character, value)
	clientEffect:FireAllClients("Visual_Effect", {
		Type = value or "Reflex",
		Target_Character = target_Character
	})
end

function Generate.ShowDamage(p, p2, p3, p4)
	show:FireAllClients(p, p2, p3, p4)
end

function Increase_Damage(state, value: number)
	if state and state.Parent then
		state.Value += value or 0
	end
end

return Generate