local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Janitor = require(ReplicatedStorage.UserGenerated.Lang.Janitor)
local FlashShared = require(ReplicatedStorage.Shared.FlashShared)
local WCall = require(ReplicatedStorage.UserGenerated.Lang.WCall)
local parent = script.Parent
local playerFromCharacter

if parent.Parent:IsA("Model") then
	playerFromCharacter = Players:GetPlayerFromCharacter(parent.Parent)
else
	playerFromCharacter = parent.Parent.Parent
end

if playerFromCharacter ~= Players.LocalPlayer then
	return
end

assert(playerFromCharacter and playerFromCharacter:IsA("Player"))
local character = playerFromCharacter.Character and playerFromCharacter.Character.Parent == workspace and playerFromCharacter.Character or playerFromCharacter.CharacterAdded:Wait()
local v = assert(character:WaitForChild("HumanoidRootPart", 5))
local v2 = assert(character:WaitForChild("Humanoid", 5))
assert(v2:WaitForChild("Animator", 5))
local remoteFunction = Net:RemoteFunction("Tools/Flash/Activate")
local ghost = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Flash Teleport"):WaitForChild("Ghost")
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function IsOnCooldown()
	local cooldownUntil = parent:GetAttribute("CooldownUntil")

	if cooldownUntil and workspace:GetServerTimeNow() < cooldownUntil then
		return true
	end

	return false
end

local flag = false
parent.Activated:Connect(function()
	if not v.Parent or v2.Health <= 0 or playerFromCharacter:GetAttribute("Stealing") then
		return
	end

	if v.Anchored then
		return "Anchored"
	end

	if not v.Parent then
		return
	end

	local ragdollEndTime = playerFromCharacter:GetAttribute("RagdollEndTime")

	if ragdollEndTime and workspace:GetServerTimeNow() < ragdollEndTime or not FlashShared.Enabled:Get() or IsOnCooldown() or flag then
		return
	end

	flag = true

	if v3 and v3.Result.Valid then
		WCall(function()
			local v4, v5 = remoteFunction:InvokeServer(v3.Params, v3.Result)

			if not v4 then
				warn("Tools/Flash/Activate", v5)
			end
		end)
	else
		parent.Handle.ErrorSound:Play()
	end

	flag = false
end)
local color = Color3.fromRGB(0, 200, 255)
local color2 = Color3.fromRGB(255, 0, 0)
local flag2 = false
local maid = Janitor.new()
parent.Equipped:Connect(function()
	if flag2 then
		return
	end

	flag2 = true
	maid = Janitor.new()
	local folder = maid:Add(ghost:Clone())
	maid:Add(RunService.RenderStepped:Connect(function(_)
		if IsOnCooldown() then
			folder.Parent = nil
		else
			folder.Parent = workspace
		end

		local valid = false
		local computeParams = FlashShared.BuildComputeParams(playerFromCharacter, workspace.CurrentCamera.CFrame)

		if computeParams then
			local computed = FlashShared.Compute(computeParams)
			valid = computed.Valid
			folder:PivotTo(computed.CFrame)
			v3 = {
				Params = computeParams,
				Result = computed
			}
		else
			v3 = nil
		end

		local color3 = valid and color or color2

		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Color = color3
			end
		end
	end))
end)
parent.Unequipped:Connect(function()
	if not flag2 then
		return
	end

	flag2 = false
	maid:Destroy()
end)