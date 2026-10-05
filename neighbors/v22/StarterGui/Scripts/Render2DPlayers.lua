local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _2DifierBillboard = ReplicatedStorage.Assets.UI["2DifierBillboard"]
local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.Character
local playerGui = localPlayer:WaitForChild("PlayerGui")
local _2DPlayers = ReplicatedStorage.Assets.UI["2DPlayers"]
local _2DPlayers2 = playerGui:WaitForChild("2DPlayers")
game:GetService("RunService")

function invisCharacter(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("MeshPart") or descendant:IsA("BasePart") or descendant:IsA("Part") or descendant:IsA("UnionOperation") or descendant:IsA("Decal")) then
			continue
		end

		if not (descendant.Name ~= "HumanoidRootPart" and descendant.Parent.Name ~= "LocalRagdollCollision") then
			continue
		end

		if p then
			descendant.Transparency = 1
		elseif descendant:GetAttribute("OGTransparency") then
			descendant.Transparency = descendant:GetAttribute("OGTransparency")
		else
			descendant.Transparency = 0
		end
	end
end

function chrClone(instance, instance2)
	if instance == nil then
		error("Character from billboard not found !")
		return
	end

	instance.Archivable = true
	local clone = instance:Clone()

	for _, descendant in pairs(clone:GetDescendants()) do
		if not (descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant.Name == "LocalRagdollCollision" or descendant:IsA("Sound") or descendant:IsA("RemoteEvent")) then
			continue
		end

		descendant:Destroy()
	end

	clone:SetPrimaryPartCFrame(CFrame.new(0, 3.15, 0) * CFrame.fromOrientation(0, 1.5707963267948966, 0))
	clone.Parent = instance2:WaitForChild("ViewportFrame")
	clone.PrimaryPart.Anchored = true
	invisCharacter(clone, false)
end

for _, child in pairs(_2DPlayers:GetChildren()) do
	if child.Value == nil then
		continue
	end

	local clone = _2DifierBillboard:Clone()
	clone.Name = child.Name
	clone.Adornee = child.Value:FindFirstChild("HumanoidRootPart")
	clone.Parent = _2DPlayers2
	clone.Enabled = true
end

_2DPlayers.ChildAdded:Connect(function(child)
	if child.Value ~= nil then
		local clone = _2DifierBillboard:Clone()
		clone.Name = child.Name
		clone.Adornee = child.Value:FindFirstChild("HumanoidRootPart")
		clone.Parent = _2DPlayers2
		clone.Enabled = true
	end
end)
_2DPlayers.ChildRemoved:Connect(function(child)
	for _, child2 in pairs(_2DPlayers2:GetChildren()) do
		if child2.Name == child.Name then
			child2:Destroy()
		end
	end
end)
_2DPlayers2.ChildAdded:Connect(function(billboardGui)
	if billboardGui:IsA("BillboardGui") and billboardGui.Adornee.Parent ~= nil and billboardGui.Adornee.Parent:FindFirstChild("Humanoid") then
		chrClone(billboardGui.Adornee.Parent, billboardGui)
	end
end)

while _2DPlayers2 ~= nil do
	task.wait(0.2)

	for _, billboardGui in pairs(_2DPlayers2:GetChildren()) do
		if workspace:FindFirstChild(billboardGui.Name) and billboardGui:IsA("BillboardGui") then
			if #billboardGui:WaitForChild("ViewportFrame"):GetChildren() > 0 then
				billboardGui:WaitForChild("ViewportFrame"):ClearAllChildren()
			end

			chrClone(billboardGui.Adornee.Parent, billboardGui)
		else
			billboardGui:Destroy()
		end
	end
end