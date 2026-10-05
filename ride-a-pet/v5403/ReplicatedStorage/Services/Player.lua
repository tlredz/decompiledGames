local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local BadgeService = game:GetService("BadgeService")
local MarketplaceService = game:GetService("MarketplaceService")
local Player = {
	LookAtCharacterDirection = function(_)
		local localPlayer = game.Players.LocalPlayer
		local v = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame * CFrame.new(
			0,
			0,
			-5
		)
		local _ = workspace.CurrentCamera
		local serverTimeNow = workspace:GetServerTimeNow()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if workspace:GetServerTimeNow() - serverTimeNow > 0.1 then
				renderSteppedConnection:Disconnect()
			end

			local currentCamera = workspace.CurrentCamera
			local position = currentCamera.CFrame.Position
			local vector2 = Vector3.new(v.Position.X, v.Position.Y, v.Position.Z)
			currentCamera.CFrame = CFrame.lookAt(position, vector2)
		end)
	end,
	GetFloor = function(_, player)
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		local raycastResult = workspace:Raycast(
			humanoidRootPart.CFrame.Position,
			createVector(0, -3000, 0),
			raycastParams
		)
		return raycastResult and raycastResult.Instance
	end,
	R6ToR15 = function(_, model)
		local r15Rig = script:WaitForChild("R15Rig")

		if not (model and model:IsA("Model")) then
			warn("Invalid character model")
			return
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			warn("Character model has no Humanoid")
			return
		end

		local clone = r15Rig:Clone()

		if not clone then
			warn("Failed to clone R15 rig template")
			return
		end

		clone.Name = model.Name
		clone:PivotTo(model.PrimaryPart.CFrame)
		clone.Parent = model.Parent
		local appliedDescription = humanoid:GetAppliedDescription()
		local humanoid2 = clone:FindFirstChildOfClass("Humanoid")

		if humanoid2 and appliedDescription then
			humanoid2:ApplyDescription(appliedDescription)
		end

		for _, child in ipairs(model:GetChildren()) do
			if not (child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors")) then
				continue
			end

			child.Parent = clone
		end

		model:Destroy()
		return clone
	end,
	ToggleControls = function(_, instance, p)
		if RunService:IsServer() then
			return script.DisableControls:FireClient(instance, p)
		end

		local PlayerModule = require(instance:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		local controls = PlayerModule:GetControls()

		if p == true then
			controls:Enable()
		else
			controls:Disable()
		end
	end,
	HasGamepass = function(_, p, p2)
		local v = false
		local _, _ = pcall(function()
			v = MarketplaceService:UserOwnsGamePassAsync(p, p2)
		end)
		return v
	end,
	HasBadge = function(self, p, p2)
		local v = nil
		local _, _ = pcall(function()
			if BadgeService:UserHasBadgeAsync(p, p2) then
				v = true
			end
		end)
		return v
	end
}

function Player:AwardBadge(p, p2)
	if not (Player:HasBadge(p, p2) ~= true and game.Players:GetPlayerByUserId(p)) then
		return
	end

	local success, _ = pcall(function()
		BadgeService:AwardBadge(p, p2)
	end)

	if success and not game.Players:GetPlayerByUserId(p) then
	end
end

function Player.SpawnRig(_, p, parent)
	local r6Rig = script:WaitForChild("R6Rig")
	local idle = script:WaitForChild("Idle")
	local model = parent:FindFirstChildOfClass("Model")

	if model then
		model:Destroy()
	end

	local clone = r6Rig:Clone()
	local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
	clone:PivotTo(parent.CFrame)
	humanoidRootPart.Anchored = false
	clone.Parent = parent
	task.delay(3, function()
		humanoidRootPart.Anchored = true
	end)
	task.wait(0.1)
	Player:LoadCharacterIntoRig(clone, p)
	clone:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(idle):Play()
	return clone
end

function Player:LoadCharacterIntoRig(instance, p)
	if p < 0 then
		return
	end

	local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(p)
	task.delay(0.1, function()
		instance:WaitForChild("Humanoid"):ApplyDescription(humanoidDescriptionFromUserId)
	end)
end

function Player.CreateHitbox(_, player, size, items)
	local character = player.Character or player.CharacterAdded:Wait()
	local part = Instance.new("Part")
	part.Size = size
	part.CanCollide = false
	part.Color = Color3.fromRGB(0, 255, 0)
	part.Massless = true
	part.Material = Enum.Material.Neon
	part.CanQuery = false
	part.Transparency = 1

	if RunService:IsStudio() then
		part.Transparency = 1
	end

	part.Parent = character
	part.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -size.Z / 2)

	if items then
		part.Anchored = true

		for k, item in items do
			part[k] = item
		end

		return part
	else
		part.Anchored = false
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		return part
	end
end

function Player.GiveAndEquipTool(_, player, p)
	p.Parent = player.Character or player.CharacterAdded:Wait()
end

function Player.RemoveTool(_, player, childName)
	local character = player.Character or player.CharacterAdded:Wait()
	local v = player.Backpack:FindFirstChild(childName) or character:FindFirstChild(childName)

	if v then
		v:Destroy()
	end
end

function Player.ToggleCollission(_, player, p)
	for _, part in (player.Character or player.CharacterAdded:Wait()):GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if p == true then
			part.CollisionGroup = "Default"
		else
			part.CollisionGroup = "NoCollision"
		end
	end
end

function Player.FetchPlayerPFP(_, p)
	local userThumbnailAsync, _ = Players:GetUserThumbnailAsync(
		p,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	return userThumbnailAsync
end

function Player.GenerateRandomPlayerAvatar(_)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetRandomUserId()
		return math.random(1, 1000000)
	end

	local function GenerateAvatarFromUserId(userId)
		local success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(userId)
		end)

		if not (success and result) then
			warn("Failed to fetch avatar for User ID:", userId)
			return nil
		end

		local clone = script.R6Rig:Clone()
		clone.Name = "GeneratedAvatar"
		clone.Parent = workspace
		local humanoid = clone:WaitForChild("Humanoid")
		humanoid:ApplyDescription(result)
		humanoid:Destroy()
		clone.Name = "Player_" .. tostring(userId)
		clone:SetAttribute("UserId", userId)
		return clone
	end

	local randomUserId = GetRandomUserId() -- equivalent call inferred; original call site unknown
	print("Fetching avatar for User ID:", randomUserId)
	local generateAvatarFromUserId = GenerateAvatarFromUserId(randomUserId)

	if generateAvatarFromUserId then
		generateAvatarFromUserId.Parent = workspace
		return generateAvatarFromUserId
	end

	warn("Failed to generate avatar for User ID:", randomUserId)
	return nil
end

return Player