local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
task.wait(0.2)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local coinCollected = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinCollected")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local coinsStarted = ReplicatedStorage3:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinsStarted")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.266, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function FadeCoinPart(p)
	TweenService:Create(p, tweenInfo, {
		Transparency = 1
	}):Play()
end

local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function spinCoin(p, p2)
	local v2 = 1.9201414298740815 * p2
	p.CFrame *= CFrame.Angles(0, v2, 0)
end

local function spinCollectedCoin(folder, p)
	if not folder:GetAttribute("IsSetup") then
		for _, descendant in pairs(folder:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
				continue
			end

			FadeCoinPart(descendant) -- equivalent call inferred; original call site unknown
		end

		FadeCoinPart(folder) -- equivalent call inferred; original call site unknown
		folder:SetAttribute("IsSetup", true)
	end

	local v2 = folder:GetAttribute("Collected") and not folder:GetAttribute("RoundEnd") and 14 or 0
	local v3 = 31.41592653589793 * p
	folder.CFrame = (folder.CFrame + Vector3.new(0, v2 * p, 0)) * CFrame.Angles(0, v3, 0)
end

local function UpdateCoins(p)
	local tagged = CollectionService:GetTagged("CoinVisual")

	for _, v2 in tagged do
		local coinID = v2:GetAttribute("CoinID")
		local v3 = v[coinID]
		local v4 = not (v2:GetAttribute("Collected") or v3)
		local rareEggID = v2:GetAttribute("RareEggID")

		if v2:GetAttribute("Delete") then
			v2:Destroy()
		else
			if rareEggID then
				if ProfileData.Easter2024.RareEggs[rareEggID] then
					v2.Transparency = 0.7
				end

				v2:SetAttribute("RareEggID", nil)
			end

			if v4 then
				spinCoin(v2, p) -- equivalent call inferred; original call site unknown
			else
				spinCollectedCoin(v2, p)
			end
		end
	end
end

local function onCoinVisualSpawned(folder)
	local coinID = folder:GetAttribute("CoinID")

	if v[coinID] then
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.Transparency = 1
			end
		end

		folder:SetAttribute("Delete", true)
	end
end

local function onCoinCollected(p: string, p2: number, p3: number, _: number)
	if p3 <= p2 then
		v[p] = true
		task.spawn(function()
			task.wait(0.5)
			local tagged = CollectionService:GetTagged("CoinVisual")

			for _, v2 in pairs(tagged) do
				if v2:GetAttribute("CoinID") == p then
					v2:SetAttribute("Delete", true)
				end
			end
		end)
	end
end

local function onCoinsStarted()
	v = {}
end

coinsStarted.OnClientEvent:Connect(onCoinsStarted)
coinCollected.OnClientEvent:Connect(onCoinCollected)
CollectionService:GetInstanceAddedSignal("CoinVisual"):Connect(onCoinVisualSpawned)
RunService.PreSimulation:Connect(UpdateCoins)