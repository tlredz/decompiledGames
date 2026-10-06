local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("@game/ReplicatedStorage/Omni/Shared/Fighters")
local Players = require(script.Parent.Players)
local v = {
	"Idle",
	"CombatIdle",
	"Walk",
	"Run",
	"Jump",
	"Fall",
	"Hits"
}
local assets = ReplicatedStorage:WaitForChild("Assets")
local characters = assets:WaitForChild("Characters")
local characters2 = assets:WaitForChild("Animations"):WaitForChild("Characters")
local others = characters2:WaitForChild("Others")
local default = others:WaitForChild("Default")
local v2 = {}

local function GetAnimationFolder(childName: string)
	if not childName or type(childName) ~= "string" then
		return
	end

	for _, configuration in characters2:GetChildren() do
		if not configuration:IsA("Configuration") then
			continue
		end

		local folder = configuration:FindFirstChild(childName)

		if folder and folder:IsA("Folder") then
			return folder
		end
	end

	return nil
end

local GetCharacter

GetCharacter = function(folder, value: string)
	if not (folder and folder:IsA("Folder")) or (not value or type(value) ~= "string") then
		return
	end

	local children = {}
	local v3 = nil

	for _, child in folder:GetChildren() do
		if child:IsA("Folder") then
			table.insert(children, child)
		elseif child:IsA("Model") and child.Name == value then
			v3 = child
			break
		end
	end

	if not v3 then
		for _, v6 in children do
			v3 = GetCharacter(v6, value)

			if v3 then
				break
			end
		end
	end

	if not v3 then
		return v3
	end

	local humanoid = v3:FindFirstChild("Humanoid")

	if not (humanoid and v3:FindFirstChild("HumanoidRootPart") and v3:FindFirstChild("Head")) then
		return
	end

	if not humanoid:FindFirstChild("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return v3
end

function v2.Get(data)
	if not data or typeof(data) ~= "table" or (not data.Name or type(data.Name) ~= "string") then
		return
	end

	local v3 = module.List[data.Name] or module.Exclusives[data.Name]
	local playerAvatar = v3 and v3.PlayerAvatar
	local v4 = nil
	local folder = nil

	if playerAvatar then
		local Players2 = game:GetService("Players")
		local owner = data.Owner or Players2.LocalPlayer

		if not owner then
			return
		end

		if typeof(owner) ~= "number" then
			owner = owner.UserId
		end

		folder = Players.GetHumanoidModel(owner)

		if not folder then
			return
		end

		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("Tool") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Sound")) then
				continue
			end

			descendant:Destroy()
		end

		folder.Name = data.Name
		folder:SetAttribute("AvatarOwnerId", owner)
	elseif data.Shiny then
		v4 = GetCharacter(characters, data.Name .. " Shiny")
	end

	if not (playerAvatar or v4) then
		v4 = GetCharacter(characters, data.Name)
	end

	if not (folder or v4) then
		return
	end

	local v5 = folder or v4:Clone()
	local humanoid = v5:FindFirstChild("Humanoid")
	local humanoidRootPart = v5:FindFirstChild("HumanoidRootPart")
	local head = v5:FindFirstChild("Head")
	local v6 = humanoid and humanoid:FindFirstChild("Animator")

	if humanoid and not v6 then
		v6 = Instance.new("Animator")
		v6.Parent = humanoid
	end

	if playerAvatar and humanoid then
		humanoid.Health = humanoid.MaxHealth
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		for _, v7 in v6:GetPlayingAnimationTracks() do
			v7:Stop(0)
		end
	end

	local leftLowerLeg = v5:FindFirstChild("LeftLowerLeg") or v5:FindFirstChild("RightLowerLeg")
	local leftUpperLeg = v5:FindFirstChild("LeftUpperLeg") or v5:FindFirstChild("RightUpperLeg")
	local v7 = (leftLowerLeg and leftLowerLeg.Size.Y or 0) + (leftUpperLeg and leftUpperLeg.Size.Y or 0)

	if data.RemoveHumanoidStates and humanoid then
		for _, v8 in Enum.HumanoidStateType:GetEnumItems() do
			if v8 ~= Enum.HumanoidStateType.None then
				humanoid:SetStateEnabled(v8, false)
			end
		end

		humanoid.EvaluateStateMachine = false
	end

	return v5, humanoid, humanoidRootPart, head, v6, v7
end

function v2.Check(value: string)
	if not value or type(value) ~= "string" then
		return false
	end

	local v3 = module.List[value] or module.Exclusives[value]

	if v3 and v3.PlayerAvatar then
		return true
	end

	return GetCharacter(characters, value) ~= nil
end

function v2.GetAllCharacterAnimations(value: string)
	if not value or type(value) ~= "string" then
		return
	end

	local result = {}
	local v3 = GetAnimationFolder(value) or default
	local animationSet = v3:GetAttribute("AnimationSet")
	local folder

	if type(animationSet) == "string" then
		folder = others:FindFirstChild(animationSet)
	end

	if folder and not folder:IsA("Folder") then
		folder = nil
	end

	for _, childName in v do
		local v4 = v3:FindFirstChild(childName) or folder and folder:FindFirstChild(childName) or default:FindFirstChild(childName)

		if v4 then
			result[childName] = v4
		end
	end

	return result, v3
end

function v2.GetCharacterAnimation(value: string, childName: string)
	if not value or type(value) ~= "string" or (not childName or type(childName) ~= "string") then
		return
	end

	local allCharacterAnimations, v3 = v2.GetAllCharacterAnimations(value)

	if allCharacterAnimations and v3 then
		return allCharacterAnimations[childName] or v3:FindFirstChild(childName)
	end
end

return table.freeze(v2)