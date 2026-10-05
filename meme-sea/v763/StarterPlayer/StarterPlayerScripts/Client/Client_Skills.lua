local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("TweenService")
game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
game:GetService("RunService")
game:GetService("Teams")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
workspace:WaitForChild("Character")
workspace:WaitForChild("Monster")
workspace:WaitForChild("Skills")
local visuals = workspace:WaitForChild("Visuals")
assets:WaitForChild("Skills")
local weapon_Effects = assets:WaitForChild("Weapon_Effects")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
require(moduleScript:WaitForChild("Generate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local clientBossSkills = skillEvents:WaitForChild("ClientBossSkills")
local client_Skills = skillEvents:WaitForChild("Client_Skills")
local client_Commands = miscEvents:WaitForChild("Client_Commands")
local modulesByName = {}

for _, moduleScript2 in pairs(script:GetDescendants()) do
	if not moduleScript2:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript2.Name
	local module = require(moduleScript2)
	modulesByName[name] = module
end

client_Skills.OnClientEvent:Connect(function(p: string, p2: string, p3: string, p4: string, p5)
	if p == "Clients_Skill" then
		if modulesByName[p2] and modulesByName[p2][p3][p4] then
			modulesByName[p2][p3][p4](p2, p3, p4, p5)
		end
	elseif p == "Weapon_Effect" then
		local weapon = p2.Weapon
		local rootPart = p2.RootPart
		Weapon_AttackEffect(weapon, rootPart)
	end
end)
clientBossSkills.OnClientEvent:Connect(function(value, p: string, p2)
	if typeof(value) == "Instance" then
		if modulesByName[value.Name] and modulesByName[value.Name][p] then
			modulesByName[value.Name][p](value, p, p2)
		end
	elseif typeof(value) == "string" and modulesByName[value] and modulesByName[value][p] then
		modulesByName[value][p](value, p, p2)
	end
end)
client_Commands.OnClientEvent:Connect(function(p: string, hitbox_Transparency)
	if p == "Hitbox_Transparency" then
		Setting.Setting.Hitbox_Transparency = hitbox_Transparency
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

function Weapon_AttackEffect(p, part)
	if p and part and part.Parent then
		local _ = localPlayer.Character
		local slashEffect = part.Parent.Name ~= "Meme Beast" and (currentCamera.CFrame.Position - part.Position).Magnitude <= 500 and weapon_Effects[p]:FindFirstChild("SlashEffect")

		if slashEffect then
			local clone = slashEffect:Clone()
			clone.Parent = visuals
			Debris:AddItem(clone, 2)

			if CheckIfAlive(part.Parent) then
				clone.Anchored = false
				local weld = Instance.new("Weld")
				weld.Part0 = clone
				weld.Part1 = part
				weld.Parent = clone
			else
				clone.CFrame = part.CFrame
				clone.Anchored = true
			end

			local pc = clone:FindFirstChild("Pc")
			local base = clone:FindFirstChild("Base")

			if pc and base then
				for _, emitter in ipairs(pc:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(7)
					end
				end

				for _, emitter in ipairs(base:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(7)
					end
				end
			else
				local emitting = clone:FindFirstChild("Emitting")

				if emitting then
					for _, emitter in ipairs(emitting:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(2.5)
						end
					end
				end
			end
		end
	end
end