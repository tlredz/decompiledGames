local CooldownModule = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local cooldownAssets = ReplicatedStorage:WaitForChild("GuiTemplate"):WaitForChild("CooldownAssets")
require(moduleScript:WaitForChild("Setting"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
local linear = Enum.EasingStyle.Linear
local inOut = Enum.EasingDirection.InOut
local flag = false
local flag2 = false

if UserInputService.TouchEnabled == true then
	flag = true
elseif UserInputService.GamepadEnabled then
	flag2 = true
end

local function SetCooldown(instance, p, instance2)
	if instance:GetAttribute("Cooldown") and ItemSettings[instance2:GetAttribute("Tool")] then
		if not p.Visible then
			p.Visible = true
		end

		local cooldown = ItemSettings[instance2:GetAttribute("Tool")][instance.Name].Cooldown or 5
		local v = localPlayer:GetAttribute("NoCooldown") and 0.1 or cooldown
		local character = localPlayer.Character
		local v2 = not character and 1 or character:GetAttribute((`{instance2.Name}CD_Boost`))
		local tween = TweenService:Create(p, TweenInfo.new(v / v2, linear, inOut), {
			Size = UDim2.new(0, 0, 1, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		p.Visible = false
		p.Size = UDim2.new(1, 0, 1, 0)
		instance:SetAttribute("Cooldown", false)
	end
end

function CooldownModule.SetCooldown(object, p, p2)
	SetCooldown(object, p, p2)
	object:GetAttributeChangedSignal("Cooldown"):Connect(function()
		SetCooldown(object, p, p2)
	end)
end

function CooldownModule.SetCooldown_Bar(p: string, duration: number, text: string, parent, flag3: boolean, flag4: boolean)
	local child = cooldownAssets:FindFirstChild((`{p}_Template`))

	if child and not (localPlayer:GetAttribute("No_CooldownBar") or parent:FindFirstChild(child.Name)) then
		local clone = child:Clone()
		clone.Cooldown.Size = UDim2.new(1, 0, 1, 0)
		clone.TitleText.Text = text
		clone.Parent = parent
		clone.Visible = true

		if flag then
			clone.UiStroke.Thickness = 2.5
			clone.FullStroke.UiStroke.Thickness = 1
		end

		if flag3 and p ~= "Flight" then
			clone.TitleText.Size = UDim2.new(1, 0, 1.3, 1)
			clone.TitleText.FontFace = Font.fromId(12187607287, Enum.FontWeight.SemiBold)
		end

		if flag4 then
			Debris:AddItem(clone, duration * 2)
			local lastTime = tick()
			local size = clone.Cooldown.Size
			local v = 0
			local count = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(_)
				count += 1

				if clone and clone.Parent then
					if count % 10 == 0 then
						v = tick() - lastTime
						local v2 = math.min(v / duration, 1)
						clone.Cooldown.Size = size:Lerp(UDim2.new(0, 0, 1, 0), v2)

						if v2 >= 1 then
							if clone and clone.Parent then
								clone:Destroy()
							end

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						end
					end
				else
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					if clone and clone.Parent then
						clone:Destroy()
					end
				end
			end)
		else
			Debris:AddItem(clone, duration)
			TweenService:Create(clone.Cooldown, TweenInfo.new(duration, linear, inOut), {
				Size = UDim2.new(0, 0, 1, 0)
			}):Play()
		end
	end
end

function CooldownModule.Enable_SkillGui(instance, text: string, childName: string)
	if instance and instance.Parent then
		local playerGui = instance:FindFirstChild("PlayerGui")

		if playerGui and playerGui.Parent and (childName == "Weapon" or childName == "FightingStyle" or childName == "Power") then
			local child = playerGui:FindFirstChild(childName)

			if child and child.Parent then
				if not child.Enabled then
					child.Enabled = true
				end

				if child:GetAttribute("Tool") ~= text then
					child:SetAttribute("Tool", text)
					child.Item_Name.Text = text
					local skill_Container = child:FindFirstChild("Skill_Container")
					local itemSetting = ItemSettings[text]

					if skill_Container and itemSetting then
						for _, image in ipairs(skill_Container:GetChildren()) do
							if not image:IsA("ImageLabel") then
								continue
							end

							local v = itemSetting[image.Name]

							if v then
								if not image.Visible then
									image.Visible = true
								end

								if flag then
									local mobileButton = image:FindFirstChild("MobileButton")

									if mobileButton and not mobileButton.Visible then
										mobileButton.Visible = true
									end
								end

								if flag2 then
									local xbox_Button = image:FindFirstChild("Xbox_Button")

									if xbox_Button and not xbox_Button.Visible then
										xbox_Button.Visible = true
									end

									image.Skill_Name.Text = `{v.Name}`
								else
									image.Skill_Name.Text = `{v.Name} [{image.Name}]`
								end
							elseif image.Visible then
								image.Visible = false

								if flag then
									local mobileButton = image:FindFirstChild("MobileButton")

									if mobileButton and mobileButton.Visible then
										mobileButton.Visible = false
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function CooldownModule.Disable_SkillGui(instance, p: string, childName: string)
	if instance and instance.Parent then
		local playerGui = instance:FindFirstChild("PlayerGui")

		if playerGui and playerGui.Parent and (childName == "Weapon" or childName == "FightingStyle" or childName == "Power") then
			local child = playerGui:FindFirstChild(childName)

			if child and child.Parent and child:GetAttribute("Tool") == p and child.Enabled then
				child.Enabled = false
			end
		end
	end
end

return CooldownModule