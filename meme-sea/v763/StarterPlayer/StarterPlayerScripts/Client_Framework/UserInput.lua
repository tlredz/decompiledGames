local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
localPlayer:SetAttribute("LastInput", tick())
local mouse = localPlayer:GetMouse()
mouse.TargetFilter = workspace.Region
local v = nil
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local skillEvents = ReplicatedStorage:WaitForChild("OtherEvent"):WaitForChild("SkillEvents")
local cooldown = localPlayer:WaitForChild("Cooldown", 60)
local fightingStyle_Animation = animation_Folder:WaitForChild("FightingStyle_Animation")
local weapon_Animation = animation_Folder:WaitForChild("Weapon_Animation")
local mobile_Skills = skillEvents:WaitForChild("Mobile_Skills")
require(moduleScript:WaitForChild("ItemSettings"))
local Cooldown_Module = require(moduleScript:WaitForChild("Cooldown_Module"))
require(moduleScript:WaitForChild("Generate"))
local v2 = {
	[Enum.KeyCode.ButtonX] = "Z",
	[Enum.KeyCode.ButtonY] = "X",
	[Enum.KeyCode.ButtonB] = "C",
	[Enum.KeyCode.ButtonL2] = "V",
	[Enum.KeyCode.DPadRight] = "F"
}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character
}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local _ = UserInputService.GamepadEnabled
local modulesByName = {}
local v3 = {
	"Z",
	"X",
	"C",
	"V",
	"F"
}

for _, moduleScript2 in pairs(script:GetDescendants()) do
	if not moduleScript2:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript2.Name
	local module = require(moduleScript2)
	modulesByName[name] = module
end

local function Equipped(instance)
	if instance:HasTag("Weapon") then
		Cooldown_Module.Enable_SkillGui(Players:GetPlayerFromCharacter(instance.Parent), instance.Name, "Weapon")
		Setup_Animation(instance, "Equip")
	elseif instance:HasTag("FightingStyle") then
		Cooldown_Module.Enable_SkillGui(Players:GetPlayerFromCharacter(instance.Parent), instance.Name, "FightingStyle")
		Setup_Animation(instance, "Equip")
	elseif instance:HasTag("Power") then
		Cooldown_Module.Enable_SkillGui(Players:GetPlayerFromCharacter(instance.Parent), instance.Name, "Power")
		Setup_Animation(instance, "Equip")
	end
end

local function Unequipped(instance)
	if instance:HasTag("Weapon") then
		if instance.Parent and instance.Parent.Parent and instance.Parent.Parent:IsA("Player") then
			Cooldown_Module.Disable_SkillGui(instance.Parent.Parent, instance.Name, "Weapon")
			Setup_Animation(instance, "Unequip")
			local v4 = Get_Holding()
			local v5 = modulesByName[instance.Name] and modulesByName[instance.Name][v4]

			if v5 then
				local _ = v5.Release and v5.Release(
					localPlayer,
					mouse,
					HitPosition(raycastParams, 1000),
					instance,
					"Weapon",
					v4,
					nil,
					_G.MobileMouse
				)
			end
		end
	elseif instance:HasTag("FightingStyle") then
		if instance.Parent and instance.Parent.Parent and instance.Parent.Parent:IsA("Player") then
			Cooldown_Module.Disable_SkillGui(instance.Parent.Parent, instance.Name, "FightingStyle")
			Setup_Animation(instance, "Unequip")
			local v4 = Get_Holding()
			local v5 = modulesByName[instance.Name] and modulesByName[instance.Name][v4]

			if v5 then
				local _ = v5.Release and v5.Release(
					localPlayer,
					mouse,
					HitPosition(raycastParams, 1000),
					instance,
					"FightingStyle",
					v4,
					nil,
					_G.MobileMouse
				)
			end
		end
	elseif instance:HasTag("Power") and instance.Parent and instance.Parent.Parent and instance.Parent.Parent:IsA("Player") then
		Cooldown_Module.Disable_SkillGui(instance.Parent.Parent, instance.Name, "Power")
		Setup_Animation(instance, "Unequip")
		local v4 = Get_Holding()
		local v5 = modulesByName[instance.Name] and modulesByName[instance.Name][v4]

		if v5 then
			local _ = v5.Release and v5.Release(
				localPlayer,
				mouse,
				HitPosition(raycastParams, 1000),
				instance,
				"Power",
				v4,
				nil,
				_G.MobileMouse
			)
		end
	end
end

local function Setup_Item(data)
	if data then
		data.Equipped:Connect(function()
			if localPlayer.Character and localPlayer.Character.Parent and data.Parent == localPlayer.Character then
				Equipped(data)
			end
		end)
		data.Unequipped:Connect(function()
			Unequipped(data)
		end)
	end
end

local function Input_Begin(p, p2, p3)
	local character = localPlayer.Character
	local tool

	if character and character.Parent then
		tool = character:FindFirstChildOfClass("Tool")
	end

	if character and tool then
		local v4

		if p2 or localPlayer:GetAttribute("IsConsole") then
			v4 = modulesByName[tool.Name] and modulesByName[tool.Name][p]
		else
			v4 = modulesByName[tool.Name] and (modulesByName[tool.Name][p.KeyCode.Name] or modulesByName[tool.Name][p.UserInputType.Name])
		end

		if v4 and tick() - localPlayer:GetAttribute("LastInput") >= 0.1 then
			localPlayer:SetAttribute("LastInput", tick())
			v = tool

			if tool:HasTag("Weapon") then
				if p2 then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Weapon",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Weapon",
						p
					)
				else
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Weapon",
						p.KeyCode.Name
					)
				end
			elseif tool:HasTag("FightingStyle") then
				if p2 then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"FightingStyle",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"FightingStyle",
						p
					)
				else
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"FightingStyle",
						p.KeyCode.Name
					)
				end
			elseif tool:HasTag("Power") then
				if p2 then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Power",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Power",
						p
					)
				else
					local _ = v4.Hold and v4.Hold(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						tool,
						"Power",
						p.KeyCode.Name
					)
				end
			end
		end
	end
end

local function Input_End(p, p2, p3)
	local character = localPlayer.Character

	if character and character.Parent and v then
		local v4

		if p2 or localPlayer:GetAttribute("IsConsole") then
			v4 = modulesByName[v.Name] and modulesByName[v.Name][p]
		else
			v4 = modulesByName[v.Name] and (modulesByName[v.Name][p.KeyCode.Name] or modulesByName[v.Name][p.UserInputType.Name])
		end

		if v4 then
			if v:HasTag("Weapon") then
				if p2 then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Weapon",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Weapon",
						p
					)
				else
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Weapon",
						p.KeyCode.Name
					)
				end
			elseif v:HasTag("FightingStyle") then
				if p2 then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"FightingStyle",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"FightingStyle",
						p
					)
				else
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"FightingStyle",
						p.KeyCode.Name
					)
				end
			elseif v:HasTag("Power") then
				if p2 then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Power",
						p,
						p3,
						_G.MobileMouse
					)
				elseif localPlayer:GetAttribute("IsConsole") then
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Power",
						p
					)
				else
					local _ = v4.Release and v4.Release(
						localPlayer,
						mouse,
						HitPosition(raycastParams, 1000),
						v,
						"Power",
						p.KeyCode.Name
					)
				end
			end
		end
	end
end

for _, v4 in ipairs(CollectionService:GetTagged("Weapon")) do
	Setup_Item(v4)
end

for _, v4 in ipairs(CollectionService:GetTagged("FightingStyle")) do
	Setup_Item(v4)
end

for _, v4 in ipairs(CollectionService:GetTagged("Power")) do
	Setup_Item(v4)
end

CollectionService:GetInstanceAddedSignal("Weapon"):Connect(Setup_Item)
CollectionService:GetInstanceAddedSignal("FightingStyle"):Connect(Setup_Item)
CollectionService:GetInstanceAddedSignal("Power"):Connect(Setup_Item)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed or localPlayer:GetAttribute("IsConsole") then
		if localPlayer:GetAttribute("IsConsole") then
			local v4 = v2[input.KeyCode]

			if v4 and table.find(v3, v4) then
				Input_Begin(v4)
			end
		elseif not gameProcessed and table.find(v3, input.KeyCode.Name) then
			Input_Begin(input)
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed or localPlayer:GetAttribute("IsConsole") then
		if localPlayer:GetAttribute("IsConsole") then
			local v4 = v2[input.KeyCode]

			if v4 and table.find(v3, v4) then
				Input_End(v4)
			end
		elseif not gameProcessed and table.find(v3, input.KeyCode.Name) then
			Input_End(input)
		end
	end
end)
mobile_Skills.Event:Connect(function(p: string, p2, p3)
	if p == "Begin" then
		Input_Begin(p2, true, p3)
	elseif p == "End" then
		Input_End(p2, true, p3)
	end
end)

function Setup_Animation(instance, p: string)
	if p == "Equip" then
		local v4 = weapon_Animation:FindFirstChild(instance.Name) or fightingStyle_Animation:FindFirstChild(instance.Name)
		local idle = v4 and v4:FindFirstChild("Idle")

		if idle then
			local playerFromCharacter = Players:GetPlayerFromCharacter(instance.Parent)
			local character = playerFromCharacter and playerFromCharacter.Character

			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				local animator = humanoid and humanoid:FindFirstChild("Animator")

				if animator then
					animator:LoadAnimation(idle):Play()
					instance:SetAttribute("Idle_Animation", true)
				end
			end
		end
	elseif instance:GetAttribute("Idle_Animation") then
		local parent = instance.Parent and instance.Parent.Parent:IsA("Player") and instance.Parent.Parent
		local character = parent and parent.Character

		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local animator = humanoid and humanoid:FindFirstChild("Animator")

			if animator then
				for _, v4 in ipairs(animator:GetPlayingAnimationTracks()) do
					if v4.Name == "Idle" then
						v4:Stop()
					end
				end

				instance:SetAttribute("Idle_Animation", nil)
			end
		end
	end
end

function Get_Holding()
	for _, boolValue in ipairs(cooldown:GetChildren()) do
		if not boolValue:IsA("BoolValue") then
			continue
		end

		local v4 = string.match(boolValue.Name, "Z", #boolValue.Name - 8) or string.match(
			boolValue.Name,
			"X",
			#boolValue.Name - 8
		) or string.match(boolValue.Name, "C", #boolValue.Name - 8) or string.match(
			boolValue.Name,
			"V",
			#boolValue.Name - 8
		) or string.match(boolValue.Name, "F", #boolValue.Name - 8)

		if v4 then
			return v4
		end
	end
end

function HitPosition(p, value)
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * (value or 1000),
		p
	)

	if raycastResult then
		return raycastResult.Position
	end

	return viewportPointToRay.Origin + viewportPointToRay.Direction * (value or 1000)
end

return {}