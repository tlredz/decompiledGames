local createVector = vector.create
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local head = parent:WaitForChild("Head")
local v = {}
local v2 = {}

local function teleportToPart(instance)
	if not humanoid.RootPart then
		return
	end

	local position = instance.Position
	local vector2 = Vector3.new(
		instance.CFrame.LookVector.X,
		humanoid.RootPart.CFrame.LookVector.Y,
		instance.CFrame.LookVector.Z
	)
	local v3 = vector2.Magnitude < 0.001 and createVector(0, 0, -1) or vector2
	local v4 = position + Vector3.new(0, humanoid.HipHeight, 0)
	local cframe = CFrame.lookAt(v4, v4 + v3)
	parent:PivotTo(cframe)
	print(cframe)
end

local function addDisplayParts(p: string, folder)
	if not folder then
		return
	end

	local v3 = {}
	table.insert(v3, folder)

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter")) then
			continue
		end

		table.insert(v3, descendant)
	end

	if p == "Knife" then
		v = {}
		v = v3
	elseif p == "Gun" then
		v2 = {}
		v2 = v3
	end
end

local displayRefKnife = parent:FindFirstChild("DisplayRefKnife")
local displayRefGun = parent:FindFirstChild("DisplayRefGun")

if displayRefKnife then
	addDisplayParts("Knife", displayRefKnife.Value)
end

if displayRefGun then
	addDisplayParts("Gun", displayRefGun.Value)
end

parent.ChildAdded:Connect(function(child)
	if child.Name == "DisplayRefKnife" then
		addDisplayParts("Knife", child.Value)
	elseif child.Name == "DisplayRefGun" then
		addDisplayParts("Gun", child.Value)
	end
end)
head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
	local localTransparencyModifier = head.LocalTransparencyModifier

	if localTransparencyModifier < 1 and localTransparencyModifier > 0 then
		return
	end

	for _, instance in v do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		elseif instance:IsA("Decal") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		elseif instance:IsA("ParticleEmitter") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	for _, instance in v2 do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		elseif instance:IsA("Decal") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		elseif instance:IsA("ParticleEmitter") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end)
remotes:WaitForChild("Gameplay"):WaitForChild("TeleportToPart").OnClientEvent:Connect(teleportToPart)
local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Icon = ""
game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
	if child:HasTag("Weapon_Gun") then
		child.Destroying:Once(function()
			local mouse = game.Players.LocalPlayer:GetMouse()
			mouse.Icon = ""
		end)
	end
end)