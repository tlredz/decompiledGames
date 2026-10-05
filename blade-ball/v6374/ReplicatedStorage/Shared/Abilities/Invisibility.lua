local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local v2 = require3(ReplicatedStorage2.Shared.FastUtils)
require3("@game/ReplicatedStorage/Types/Templates")
local v3 = {}

local function invisPoof(instance)
	local clone, v4

	if v3[instance] then
		clone = script.MaxInvisPoof:Clone()
		v4 = 60
	else
		clone = script.InvisPoof:Clone()
		v4 = 40
	end

	clone.Parent = instance:FindFirstChild("RootAttachment", true)
	local poof = clone.Poof
	poof.Parent = clone.Parent
	Debris:AddItem(clone, 3.5)
	Debris:AddItem(poof, 3)
	clone:Emit(v4)
	poof:Play()
end

local v4 = {}
setmetatable(v4, {
	__mode = "k"
})

local function startInvisibility(folder)
	if folder:GetAttribute("IsInvisible") then
		return
	end

	folder:SetAttribute("IsInvisible", true)
	local v5 = v4[folder]

	if not v5 then
		v5 = {}
		v4[folder] = v5
	end

	task.defer(function()
		for _, child in workspace.Balls:GetChildren() do
			if child.GetTargetCharacter:Invoke() == folder then
				child.Retarget:Invoke()
			end
		end
	end)
	task.defer(invisPoof, folder)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			v2.fastTween(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			})
			v5[descendant] = descendant.Transparency
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
			descendant.Enabled = false
			v5[descendant] = descendant.Enabled
		elseif descendant:IsA("Light") then
			v2.fastTween(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0
			})
			v5[descendant] = descendant.Brightness
		end
	end
end

local function stopInvisibility(instance)
	if not instance:GetAttribute("IsInvisible") then
		return
	end

	instance:SetAttribute("IsInvisible", nil)
	local v5 = v4[instance]

	if not v5 then
		return
	end

	task.defer(invisPoof, instance)
	local instance2, v6 = next(v5)

	while instance2 do
		v5[instance2] = nil

		if instance2:IsA("BasePart") or instance2:IsA("Decal") then
			v2.fastTween(instance2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = v6 or 0
			})
			instance2, v6 = next(v5)
		elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Trail") or instance2:IsA("Beam") then
			if v6 ~= nil then
				instance2.Enabled = v6
				instance2, v6 = next(v5)
			end
		elseif instance2:IsA("Light") then
			if v6 ~= nil then
				v2.fastTween(instance2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = v6
				})
				instance2, v6 = next(v5)
			end
		else
			instance2, v6 = next(v5)
		end
	end
end

if RunService:IsServer() then
	v.AddTargetFilter(script.InvisibilityTargetFilter)
	workspace.ShowdownActive.Changed:Connect(function()
		if workspace.ShowdownActive.Value then
			for _, child in workspace.Alive:GetChildren() do
				stopInvisibility(child)
			end
		end
	end)
end

local Invisibility = {}
Invisibility.cooldown = 35
Invisibility.cooldownReductionPerUpgrade = 2.9166666666666665
Invisibility.iconId = "rbxassetid://14032499286"

function Invisibility.canBeUsed(_)
	return not workspace.ShowdownActive.Value
end

function Invisibility.serverActivationAsync(p, p2)
	v3[p.character] = p.upgradeLevel >= 2
	startInvisibility(p.character)

	local function cleanup()
		stopInvisibility(p.character)
		v3[p.character] = nil
	end

	task.delay(3, cleanup)
	p2.addCleaner(cleanup)
end

return Invisibility