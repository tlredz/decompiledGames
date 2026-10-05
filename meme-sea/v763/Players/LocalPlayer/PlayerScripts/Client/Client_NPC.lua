local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local enemyTemplate = ReplicatedStorage:WaitForChild("EnemyTemplate")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local enemy = animation_Folder:WaitForChild("Enemy")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
workspace:WaitForChild("Monster")
local skills = workspace:WaitForChild("Skills")
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local hitDamage = localPlayer:WaitForChild("PlayerData", 60):WaitForChild("HitDamage", 60)
local clientEnemy = miscEvents:WaitForChild("ClientEnemy")
local toggle = mainEvents:WaitForChild("Toggle")
local nPC_InfoGui = guiTemplate:WaitForChild("NPC_InfoGui", 15)
local raid_Mark = guiTemplate:WaitForChild("Raid_Mark", 15)
local eating = sound_Effect:WaitForChild("Eating")
local v = {}
local v2 = {
	["Evil Noob"] = function(instance, duration: number)
		local yellowBlade = instance:FindFirstChild("Yellow Blade")

		if yellowBlade then
			local handle = yellowBlade:FindFirstChild("Handle")
			local trail = handle and (handle.Position - currentCamera.CFrame.Position).Magnitude <= 1000 and handle:FindFirstChild("Trail")

			if trail then
				trail.Enabled = true
				task.delay(duration, function()
					if trail.Enabled then
						trail.Enabled = false
					end
				end)
			end
		end
	end
}

local function Set_States(humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end

local function Setup(parent)
	local child

	if parent:HasTag("Pet") then
		child = enemy:FindFirstChild(parent:GetAttribute("Type"))
	else
		child = enemy:FindFirstChild(parent.Name)
	end

	local humanoid = parent:WaitForChild("Humanoid", 15)
	local humanoidRootPart = parent:WaitForChild("HumanoidRootPart", 15)

	if v[parent] == nil then
		v[parent] = {}
	end

	if humanoid and humanoidRootPart and v[parent] then
		local animator = humanoid:FindFirstChild("Animator")
		Set_States(humanoid)

		if animator and child then
			local idle = child:FindFirstChild("Idle")
			local walk = child:FindFirstChild("Walk")
			local attack = child:FindFirstChild("Attack")
			local lastAttack = child:FindFirstChild("LastAttack")
			local left_Attack = child:FindFirstChild("Left_Attack")
			local right_Attack = child:FindFirstChild("Right_Attack")
			local left_Dash = child:FindFirstChild("Left_Dash")
			local right_Dash = child:FindFirstChild("Right_Dash")
			local jump = child:FindFirstChild("Jump")
			local normal_Jump = child:FindFirstChild("Normal_Jump")
			local track

			if idle then
				track = animator:LoadAnimation(idle)
			end

			local track2

			if walk then
				track2 = animator:LoadAnimation(walk)
			else
				track2 = nil
			end

			local track3

			if attack then
				track3 = animator:LoadAnimation(attack)
			else
				track3 = nil
			end

			local track4

			if lastAttack then
				track4 = animator:LoadAnimation(lastAttack)
			else
				track4 = nil
			end

			local track5

			if left_Attack then
				track5 = animator:LoadAnimation(left_Attack)
			else
				track5 = nil
			end

			local track6

			if right_Attack then
				track6 = animator:LoadAnimation(right_Attack)
			else
				track6 = nil
			end

			local track7

			if left_Dash then
				track7 = animator:LoadAnimation(left_Dash)
			else
				track7 = nil
			end

			local track8

			if right_Dash then
				track8 = animator:LoadAnimation(right_Dash)
			else
				track8 = nil
			end

			local track9

			if jump then
				track9 = animator:LoadAnimation(jump)
			else
				track9 = nil
			end

			local track10

			if normal_Jump then
				track10 = animator:LoadAnimation(normal_Jump)
			else
				track10 = nil
			end

			if idle and not track.IsPlaying then
				track:Play()
			end

			v[parent][#v[parent] + 1] = humanoid.Died:Connect(function()
				if v[parent] then
					for _, connection in ipairs(v[parent]) do
						if connection then
							connection:Disconnect()
						end
					end

					if v[parent] then
						v[parent] = nil
					end
				end
			end)

			if walk then
				v[parent][#v[parent] + 1] = humanoid.Running:Connect(function(p)
					if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						if p > 0 and humanoid.FloorMaterial ~= Enum.Material.Air and humanoid:GetState() ~= Enum.HumanoidStateType.FallingDown and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and not humanoid.Jump then
							if not track2.IsPlaying then
								track2:Play()
							end
						elseif track2.IsPlaying then
							track2:Stop()
						end
					end
				end)
			end

			if normal_Jump then
				v[parent][#v[parent] + 1] = humanoid.Jumping:Connect(function(p)
					if p then
						if track2.IsPlaying then
							track2:Stop()
						end

						if not track10.IsPlaying then
							track10:Play()
						end
					end
				end)
			end

			if jump then
				v[parent][#v[parent] + 1] = parent:GetAttributeChangedSignal("Last_Jump"):Connect(function()
					track9:Play()
					track9:AdjustSpeed(1.5)
				end)
			end

			if left_Dash and right_Dash then
				v[parent][#v[parent] + 1] = parent:GetAttributeChangedSignal("Dash_Direction"):Connect(function()
					if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						if parent:GetAttribute("Dash_Direction") == "Left" then
							track8:Play()
							track8:AdjustSpeed(2.5)
						else
							track7:Play()
							track7:AdjustSpeed(2.5)
						end
					end
				end)
			end

			if attack and lastAttack then
				v[parent][#v[parent] + 1] = parent:GetAttributeChangedSignal("LastAttack"):Connect(function()
					if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						if parent:GetAttribute("AttackPhase") < 4 then
							track3:Play()
						else
							track4:Play()
						end
					end
				end)
			elseif left_Attack and right_Attack and lastAttack then
				v[parent][#v[parent] + 1] = parent:GetAttributeChangedSignal("LastAttack"):Connect(function()
					if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						if parent:GetAttribute("AttackPhase") == 1 or parent:GetAttribute("AttackPhase") == 3 then
							if v2[parent.Name] then
								v2[parent.Name](parent, track5.Length)
							end

							track5:Play()
						elseif parent:GetAttribute("AttackPhase") == 2 then
							if v2[parent.Name] then
								v2[parent.Name](parent, track6.Length)
							end

							track6:Play()
						elseif parent:GetAttribute("AttackPhase") >= 4 then
							if v2[parent.Name] then
								v2[parent.Name](parent, track4.Length)
							end

							track4:Play()
						end
					end
				end)
			end

			if parent.Name == "Meme Beast" then
				local head = parent:WaitForChild("Head", 15)

				if head then
					local clone = nPC_InfoGui:Clone()
					clone.Enabled = true
					clone.Parent = head
					local frame = clone:FindFirstChild("Frame")
					local healthFrame

					if frame then
						healthFrame = frame:FindFirstChild("HealthFrame")
					else
						healthFrame = nil
					end

					local health

					if healthFrame then
						health = healthFrame:FindFirstChild("Health")
					else
						health = nil
					end

					local healthText

					if healthFrame then
						healthText = healthFrame:FindFirstChild("HealthText")
					else
						healthText = nil
					end

					if frame and healthFrame and health and healthText then
						v[parent][#v[parent] + 1] = humanoid.HealthChanged:Connect(function()
							if humanoid and humanoid.Parent and humanoid.Health > 0 then
								local health2 = math.floor(humanoid.Health)
								local maxHealth = math.floor(humanoid.MaxHealth)
								healthText.Text = `{Abbreviate.Comma(health2)} / {Abbreviate.Comma(maxHealth)}`

								if health2 / maxHealth < 0.25 then
									health.Bottom.UIGradient.Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(185, 22, 22)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 26, 26))
									})
									health.Top.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
								else
									health.Bottom.UIGradient.Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 134, 40)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(91, 255, 32))
									})
									health.Top.BackgroundColor3 = Color3.fromRGB(90, 255, 21)
								end

								if maxHealth <= health2 then
									healthFrame.Health.Size = UDim2.new(1, 0, 1, 0)
								else
									healthFrame.Health.Size = UDim2.new(health2 / maxHealth, 0, 1, 0)
								end
							end
						end)
					end
				end
			elseif parent:GetAttribute("Raid_Enemy") and localPlayer:GetAttribute("Raiding") and parent:HasTag((`Raid_{localPlayer:GetAttribute("Raiding")}`)) and not parent:FindFirstChild("Raid_Mark") then
				local clone = raid_Mark:Clone()
				clone.Adornee = humanoidRootPart
				clone.Enabled = true
				clone.Parent = parent
			end
		end
	end
end

local function Setup_Enemy(instance)
	if instance then
		if instance.Parent ~= enemyTemplate and instance:GetAttribute("ClientLoaded") == nil then
			instance:SetAttribute("ClientLoaded", true)
			coroutine.wrap(Setup)(instance)
		end
	else
		for _, v3 in ipairs(CollectionService:GetTagged("Enemy")) do
			if not (v3.Parent ~= enemyTemplate and v3:GetAttribute("ClientLoaded") == nil) then
				continue
			end

			v3:SetAttribute("ClientLoaded", true)
			coroutine.wrap(Setup)(v3)
		end
	end
end

local function Client_Enemy(p, p2: string, data)
	if p2 == "Knockback" then
		local target_RootPart = data.Target_RootPart
		local type = data.Type or "Normal_Knockback"

		if type == "Last_Knockback" then
			local enemy_RootPart = data.Enemy_RootPart

			if target_RootPart and target_RootPart.Parent then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "Last_Knockback"
				bodyVelocity.MaxForce = createVector(100000, 0, 100000)
				bodyVelocity.Velocity = Vector3.new(
					enemy_RootPart.CFrame.LookVector.X,
					0,
					enemy_RootPart.CFrame.LookVector.Z
				) * 125
				bodyVelocity.Parent = target_RootPart
				Debris:AddItem(bodyVelocity, 0.05)
			end
		elseif type == "Normal_Knockback" then
			local enemy_RootPart = data.Enemy_RootPart

			if target_RootPart and target_RootPart.Parent then
				target_RootPart:ApplyImpulse(Vector3.new(
					enemy_RootPart.CFrame.LookVector.X,
					0,
					enemy_RootPart.CFrame.LookVector.Z
				) * 150)
			end
		elseif type == "Custom_Knockback" then
			local knockback = data.Knockback
			local knockback_Name = data.Knockback_Name
			local duration_Phase = data.Duration_Phase

			if knockback and target_RootPart and target_RootPart.Parent and (currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 2000 then
				local v3 = knockback.Clear_BV and true or false
				local name = knockback_Name or knockback.Name
				local velocity = knockback.Velocity
				local duration = knockback.Duration

				if v3 then
					Generate.ClearBV(target_RootPart, name)
				end

				local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

				if rootAttachment then
					local child = target_RootPart:FindFirstChild(name)

					if child or not velocity or not duration or target_RootPart:GetAttribute("No_Knockback") then
						if child then
							child:SetAttribute("LastTime", tick())
						end
					else
						local hitbox = data.Hitbox
						local v5 = not knockback.Ignore_Hitbox
						local invincible = knockback.Invincible or nil
						local v6 = knockback.Respect_Duration and true or false
						local maxForce = not knockback.MaxForce and 1000000 or knockback.MaxForce
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
						linearVelocity.Name = name
						linearVelocity.MaxForce = maxForce
						linearVelocity.Attachment0 = rootAttachment
						linearVelocity.VectorVelocity = velocity
						linearVelocity:SetAttribute("LastTime", tick())
						linearVelocity.Parent = target_RootPart

						if true_Invincible then
							linearVelocity:SetAttribute("Invincible", true)
						end

						coroutine.wrap(function()
							local v8

							if duration_Phase and not v6 then
								v8 = duration_Phase
							else
								v8 = duration
							end

							if v5 then
								repeat
									task.wait(0.1)
								until v8 <= tick() - linearVelocity:GetAttribute("LastTime") or not (linearVelocity and linearVelocity.Parent and hitbox and hitbox.Parent)
							else
								repeat
									task.wait(0.1)
								until v8 <= tick() - linearVelocity:GetAttribute("LastTime") or not (linearVelocity and linearVelocity.Parent)
							end

							if linearVelocity and linearVelocity.Parent then
								linearVelocity:Destroy()
							end
						end)()
					end
				else
					local child = target_RootPart:FindFirstChild(name)

					if child or not velocity or not duration or target_RootPart:GetAttribute("No_Knockback") then
						if child then
							child:SetAttribute("LastTime", tick())
						end
					else
						local hitbox = data.Hitbox
						local v5 = not knockback.Ignore_Hitbox
						local invincible = knockback.Invincible or nil
						local v6 = knockback.Respect_Duration and true or false
						local v7 = not knockback.MaxForce and 1000000 or knockback.MaxForce
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
						bodyVelocity.Name = name
						bodyVelocity.MaxForce = createVector(1, 1, 1) * v7
						bodyVelocity.Velocity = velocity
						bodyVelocity.Parent = target_RootPart
						bodyVelocity:SetAttribute("LastTime", tick())

						if true_Invincible then
							bodyVelocity:SetAttribute("Invincible", true)
						end

						local more_Delay = data.More_Delay or 0

						if duration_Phase and not v6 then
							duration = duration_Phase + more_Delay
						end

						coroutine.wrap(function()
							if v5 then
								repeat
									task.wait(0.1)
									local v8 = tick() - bodyVelocity:GetAttribute("LastTime")
								until duration <= v8 or not (bodyVelocity and bodyVelocity.Parent and hitbox and hitbox.Parent)
							else
								repeat
									task.wait(0.1)
									local v8 = tick() - bodyVelocity:GetAttribute("LastTime")
								until duration <= v8 or not (bodyVelocity and bodyVelocity.Parent)
							end

							if bodyVelocity and bodyVelocity.Parent then
								bodyVelocity:Destroy()
							end
						end)()
					end
				end
			end
		elseif type == "Clear_Knockback" then
			local knockback_Name = data.Knockback_Name
			local child = knockback_Name and target_RootPart:FindFirstChild(knockback_Name)

			if child then
				child:Destroy()
			end
		end
	elseif p2 == "BodyPosition" then
		local target_RootPart = data.Target_RootPart
		local type = data.Type or "Custom_BodyPosition"
		local duration_Phase = data.Duration_Phase

		if type == "Custom_BodyPosition" then
			local bodyPosition = data.BodyPosition
			local bodyPosition_Name = data.BodyPosition_Name

			if bodyPosition and target_RootPart and target_RootPart.Parent and (currentCamera.CFrame.Position - target_RootPart.Position).Magnitude <= 2000 then
				local type2 = bodyPosition.Type
				local v3 = bodyPosition.Clear_BV and true or false
				local position = bodyPosition.Position

				if data.Weapon and data.Action and data.Releaser_Id and bodyPosition.Middle then
					local child = skills:FindFirstChild((`{data.Weapon}_{data.Action}_{data.Releaser_Id}`))

					if child then
						local hitbox = child:FindFirstChild("Hitbox")

						if hitbox then
							position = hitbox:FindFirstChild("AP_Attachment") or position
						end
					end
				end

				local duration = bodyPosition.Duration

				if v3 then
					Generate.ClearBV(target_RootPart, bodyPosition_Name)
				end

				if type2 == "Body_Position_Reverse" then
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
								local v4 = bodyPosition.Respect_Duration and true or false
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
								humanoidRootPart.CFrame = CFrame.new(
									humanoidRootPart.Position,
									humanoidRootPart.Position + target_RootPart.CFrame.LookVector
								)

								if true_Invincible then
									bodyPosition2:SetAttribute("Invincible", true)
								end

								if duration_Phase then
									if v4 then
										duration_Phase = duration
									end
								else
									duration_Phase = duration
								end

								coroutine.wrap(function()
									repeat
										task.wait(0.1)
										local v5 = tick() - bodyPosition2:GetAttribute("LastTime")
									until duration_Phase <= v5 or not (bodyPosition2 and bodyPosition2.Parent)

									if bodyPosition2 and bodyPosition2.Parent then
										bodyPosition2:Destroy()
									end
								end)()
							end
						end
					end
				else
					local child = target_RootPart:FindFirstChild(bodyPosition_Name)

					if child or not position or not duration or not type2 or target_RootPart:GetAttribute("No_Knockback") then
						if child then
							child:SetAttribute("LastTime", tick())
						end
					else
						local hitbox = data.Hitbox

						if type2 == "Align_Position" then
							local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

							if rootAttachment then
								local v4 = not bodyPosition.Ignore_Hitbox
								local v5 = bodyPosition.Respect_Duration and true or false
								local responsiveness = bodyPosition.Responsiveness or 10
								local applyAtCenterOfMass = bodyPosition.ApplyAtCenterOfMass and true or false
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
								alignPosition.ApplyAtCenterOfMass = applyAtCenterOfMass
								alignPosition.Responsiveness = responsiveness
								alignPosition.Attachment0 = rootAttachment
								alignPosition.Attachment1 = position
								alignPosition.Parent = target_RootPart
								alignPosition:SetAttribute("LastTime", tick())

								if true_Invincible then
									alignPosition:SetAttribute("Invincible", true)
								end

								if duration_Phase then
									if v5 then
										duration_Phase = duration
									end
								else
									duration_Phase = duration
								end

								coroutine.wrap(function()
									if v4 then
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
						elseif type2 == "StartEnd_Align" then
							local rootAttachment = target_RootPart:FindFirstChild("RootAttachment")

							if data.Weapon and data.Action and data.Releaser_Id then
								local child2 = skills:FindFirstChild((`{data.Weapon}_{data.Action}_{data.Releaser_Id}`))
								position = child2 and {
									Start = child2:FindFirstChild("Start"),
									End = child2:FindFirstChild("End")
								} or position
							end

							if rootAttachment and typeof(position) == "table" then
								local v4 = not bodyPosition.Ignore_Hitbox
								local v5 = bodyPosition.Respect_Duration and true or false
								local responsiveness = bodyPosition.Responsiveness or 10
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
										if v5 then
											duration_Phase = duration
										end
									else
										duration_Phase = duration
									end

									coroutine.wrap(function()
										if v4 then
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
						elseif type2 == "Body_Position" then
							local P = bodyPosition.P or 10000
							local v4 = not bodyPosition.Ignore_Hitbox
							local invincible = bodyPosition.Invincible or nil
							local v5 = bodyPosition.Respect_Duration and true or false
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
								if v5 then
									duration_Phase = duration
								end
							else
								duration_Phase = duration
							end

							coroutine.wrap(function()
								if v4 then
									repeat
										task.wait(0.1)
										local v6 = tick() - bodyPosition2:GetAttribute("LastTime")
									until duration_Phase <= v6 or not (bodyPosition2 and bodyPosition2.Parent and hitbox and hitbox.Parent)
								else
									repeat
										task.wait(0.1)
										local v6 = tick() - bodyPosition2:GetAttribute("LastTime")
									until duration_Phase <= v6 or not (bodyPosition2 and bodyPosition2.Parent)
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
	elseif p2 == "Body_Velocity" then
		local target_RootPart = data.Target_RootPart

		if data.Type == "Holding_BV" then
			local duration = data.Duration

			if target_RootPart:FindFirstChild("Holding_BV") == nil then
				Generate.ClearBV(target_RootPart)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "Holding_BV"
				bodyVelocity.MaxForce = createVector(100000, 0, 100000)
				bodyVelocity.P = 500000
				bodyVelocity.Velocity = Vector3.new()
				bodyVelocity.Parent = target_RootPart
				Debris:AddItem(bodyVelocity, duration)
			end
		end
	elseif p2 == "Play_Animation" then
		local animator = data.Animator
		local animation_Name = data.Animation_Name

		if animator and animation_Name and (animator.Parent.Parent.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
			local child = enemy:FindFirstChild(p.Name)
			local child2

			if child and child:FindFirstChild(animation_Name) then
				child2 = child:FindFirstChild(animation_Name)
			end

			local track

			if child2 then
				track = animator:LoadAnimation(child2)
			end

			if track then
				track:Play()
			end
		end
	elseif p2 == "Play_CustomAnimation" then
		local animator = data.Animator
		local animation = data.Animation
		local rootPart = data.RootPart

		if animator and animation and (animator.Parent.Parent.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
			if animation.Name == "Eating" and rootPart then
				PlaySound.PlaySound_RootPart(rootPart, eating)
			end

			animator:LoadAnimation(animation):Play()
		end
	elseif p2 == "Stop_Animation" then
		local animator = data.Animator
		local animation_Name = data.Animation_Name

		if animator and animation_Name then
			for _, v3 in ipairs(animator:GetPlayingAnimationTracks()) do
				if v3.Name == animation_Name then
					v3:Stop()
				end
			end
		end
	end
end

local function Client_Animation(p: string, value)
	if p == "Weapon_Animation" then
		local animator = value.Animator
		local folder = value.Folder
		local weapon = value.Weapon
		local animation_Name = value.Animation_Name
		local child = animator and folder and animation_Folder:FindFirstChild(folder)

		if child then
			local child2 = child:FindFirstChild(weapon)

			if child2 and (animator.Parent.Parent.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
				local child3 = child2:FindFirstChild(animation_Name) or nil
				local v3

				if child3 then
					v3 = animator:LoadAnimation(child3)
				end

				v3:Play()
			end
		end
	elseif p == "Play_SkillAnimation" then
		local animator = value.Animator
		local itemType = value.ItemType
		local itemName = value.ItemName
		local skill = value.Skill
		local animation_Name = value.Animation_Name

		if animator and itemType and itemName and skill and animation_Name then
			local child = skill_Animation:FindFirstChild(itemType)
			local child2

			if child then
				child2 = child:FindFirstChild(itemName)
			end

			local child3

			if child2 then
				child3 = child2:FindFirstChild(skill)
			end

			local child4

			if child3 then
				child4 = child3:FindFirstChild(animation_Name)
			end

			if child4 and (animator.Parent.Parent.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				animator:LoadAnimation(child4):Play()
			end
		end
	elseif p == "Stop_Animation" then
		local animator = value.Animator
		local animation_Name = value.Animation_Name

		if animator and animation_Name then
			for _, v3 in ipairs(animator:GetPlayingAnimationTracks()) do
				if v3.Name == animation_Name then
					v3:Stop()
				end
			end
		end
	elseif p == "Damage_Counter" and hitDamage then
		hitDamage.Value += value or 0
	end
end

CollectionService:GetInstanceAddedSignal("Enemy"):Connect(Setup_Enemy)
CollectionService:GetInstanceAddedSignal("Pet"):Connect(Setup_Enemy)
clientEnemy.OnClientEvent:Connect(Client_Enemy)
toggle.OnClientEvent:Connect(Client_Animation)
Setup_Enemy()