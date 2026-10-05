local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local handle = parent:WaitForChild("Handle")
local equip = handle:FindFirstChild("Equip")
local lockon = handle:FindFirstChild("lockon")
local holdlock = handle:FindFirstChild("holdlock")
local player = parent:FindFirstAncestorOfClass("Player") or Players:GetPlayerFromCharacter(parent:FindFirstAncestorOfClass("Model"))
local aimUI = script.Parent:WaitForChild("AimUI")
local lockon2 = aimUI.lockon
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CleanUp()
	aimUI.Adornee = script
	lockon2.Visible = false
	v = nil
end

local function GetNearestPlayer()
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = 1e999
	local v3 = nil

	for _, v4 in Players:GetPlayers() do
		if v4 == player then
			continue
		end

		local character2 = v4.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			continue
		end

		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

		if not (magnitude <= 40 and magnitude < v2) then
			continue
		end

		v3 = character2
		v2 = magnitude
	end

	return v3, Players:GetPlayerFromCharacter(v3)
end

parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer(v)
end)
parent.Equipped:Connect(function()
	if equip and not holdlock.IsPlaying then
		equip:Play()
	end

	RunService:UnbindFromRenderStep("Heatseeker")
	CleanUp() -- equivalent call inferred; original call site unknown
	RunService:BindToRenderStep("Heatseeker", Enum.RenderPriority.Character.Value + 1, function()
		if parent:GetAttribute("CooldownTime") then
			CleanUp() -- equivalent call inferred; original call site unknown
		else
			local adornee, v3 = GetNearestPlayer()

			if adornee and adornee ~= v then
				aimUI.Adornee = adornee
				lockon2.Visible = true
				v = v3

				if holdlock and not holdlock.IsPlaying then
					holdlock:Play()
				end
			else
				CleanUp() -- equivalent call inferred; original call site unknown

				if lockon and not lockon.IsPlaying then
					lockon:Play()
				end
			end
		end
	end)
end)
parent.Unequipped:Connect(function()
	RunService:UnbindFromRenderStep("Heatseeker")
	CleanUp() -- equivalent call inferred; original call site unknown

	if lockon then
		lockon:Stop()
	end

	if holdlock then
		holdlock:Stop()
	end

	if equip then
		equip:Stop()
	end
end)