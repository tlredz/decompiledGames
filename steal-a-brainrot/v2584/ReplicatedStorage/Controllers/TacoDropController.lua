local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Net = require(ReplicatedStorage.Packages.Net)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local remoteEvent = Net:RemoteEvent("TacoMerchantService/SpawnTacoDrop")
local remoteEvent2 = Net:RemoteEvent("TacoMerchantService/ClaimTacoDrop")
local remoteEvent3 = Net:RemoteEvent("TacoMerchantService/DestroyTacoDrop")
local remoteFunction = Net:RemoteFunction("TacoMerchantService/GetTacoDrops")
local reward = ReplicatedStorage.Controllers.EventController.Events.Bee:WaitForChild("Reward")
local tacoPickup = script:WaitForChild("TacoPickup")
local v = {}
local flag = false

local function createTacoModel()
	local model = Instance.new("Model")
	model.Name = "Taco"
	local clone = script.Taco:Clone()
	clone.Name = "Taco"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Massless = true
	clone.Parent = model
	model.PrimaryPart = clone
	model:ScaleTo(model:GetScale() * 2)
	return model
end

local function createTacoDrop(id: string, spawnPosition: Vector3, position: Vector3, spawnTime: number, fallTime: number)
	if v[id] then
		return
	end

	local tacoModel = createTacoModel()
	tacoModel:PivotTo(CFrame.new(spawnPosition))
	tacoModel.Parent = workspace
	local v2 = tonumber(string.sub(id, 1, 8), 16) or 0
	local random = Random.new(v2)
	v[id] = {
		Model = tacoModel,
		SpawnPosition = spawnPosition,
		Position = position,
		SpawnTime = spawnTime,
		FallTime = fallTime,
		LastClaimRequest = 0,
		Claimed = false,
		ClaimPlayer = nil,
		ClaimStartedAt = nil,
		ClaimFrom = nil,
		ClaimAmount = nil,
		FloatPhase = random:NextNumber(0, 6.283185307179586),
		FloatSpeed = random:NextNumber(3.3, 4.7),
		SpinSpeed = 0.7853981633974483 * random:NextNumber(0.8, 1.2)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyTacoDrop(k: string)
	local v2 = v[k]

	if not v2 then
		return
	end

	v2.Model:Destroy()
	v[k] = nil
end

local function playReward(claimPlayer, claimAmount: number)
	local character = claimPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = reward:Clone()
	local currencyHoney = clone:FindFirstChild("CurrencyHoney")
	local imageLabel = clone:FindFirstChild("ImageLabel")
	local imageLabel2 = imageLabel and imageLabel:FindFirstChild("ImageLabel")

	if not (currencyHoney and imageLabel2 and imageLabel2:IsA("ImageLabel")) then
		clone:Destroy()
		return
	end

	currencyHoney.Text = `+{claimAmount}`
	imageLabel2.Image = "rbxassetid://89041930759464"
	clone.Parent = humanoidRootPart
	TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		StudsOffset = createVector(0, 2.5, 2.2)
	}):Play()
	TweenService:Create(
		imageLabel2,
		TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
		{
			ImageTransparency = 1
		}
	):Play()
	TweenService:Create(
		currencyHoney,
		TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
		{
			TextTransparency = 1
		}
	):Play()
	local uIStroke = currencyHoney:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		TweenService:Create(
			uIStroke,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				Transparency = 1
			}
		):Play()
	end

	task.delay(5, clone.Destroy, clone)
end

local function updateTacoDrops()
	local serverTimeNow = workspace:GetServerTimeNow()
	local character = Players.LocalPlayer.Character
	local position = character and character:GetPivot().Position

	for k, v2 in v do
		if v2.Model.Parent then
			if v2.Claimed then
				local claimPlayer = v2.ClaimPlayer
				local character2 = claimPlayer and claimPlayer.Character
				local position2 = character2 and character2:GetPivot().Position

				if claimPlayer and position2 and v2.ClaimStartedAt and v2.ClaimFrom then
					local v3 = math.clamp((serverTimeNow - v2.ClaimStartedAt) / 0.4, 0, 1)
					local v4 = (v2.ClaimFrom + position2) * 0.5 + createVector(0, 10, 0)
					v2.Model:PivotTo(CFrame.new(MathUtils.quadBezier(v3, v2.ClaimFrom, v4, position2)) * CFrame.Angles(
						0,
						serverTimeNow * v2.SpinSpeed,
						0
					))

					if v3 >= 1 then
						playReward(claimPlayer, v2.ClaimAmount or 1)

						if claimPlayer == Players.LocalPlayer then
							SoundController:PlaySound(tacoPickup, nil, false)
						end

						destroyTacoDrop(k) -- equivalent call inferred; original call site unknown
					end
				end
			else
				local value = TweenService:GetValue(
					math.clamp((serverTimeNow - v2.SpawnTime) / v2.FallTime, 0, 1),
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				)
				local v4 = v2.SpawnPosition + createVector(0, 8, 0)
				local v5 = MathUtils.quadBezier(value, v2.SpawnPosition, v4, v2.Position) + Vector3.new(
					0,
					math.sin(serverTimeNow * v2.FloatSpeed + v2.FloatPhase) * 0.35 + 3,
					0
				)
				v2.Model:PivotTo(CFrame.new(v5) * CFrame.Angles(0, serverTimeNow * v2.SpinSpeed, 0))

				if value >= 1 and position and (v2.Position - position).Magnitude <= 12 and serverTimeNow - v2.LastClaimRequest > 0.1 then
					v2.LastClaimRequest = serverTimeNow
					remoteEvent2:FireServer(k)
				end
			end
		else
			v[k] = nil
		end
	end
end

return {
	Start = function(_)
		if flag then
			return
		end

		flag = true
		remoteEvent.OnClientEvent:Connect(createTacoDrop)
		remoteEvent2.OnClientEvent:Connect(function(p: string, claimPlayer, claimAmount: number)
			local v2 = v[p]

			if not v2 or v2.Claimed then
				return
			end

			v2.Claimed = true
			v2.ClaimPlayer = claimPlayer
			v2.ClaimStartedAt = workspace:GetServerTimeNow()
			v2.ClaimFrom = v2.Model:GetPivot().Position
			v2.ClaimAmount = claimAmount
		end)
		remoteEvent3.OnClientEvent:Connect(destroyTacoDrop)
		RunService.RenderStepped:Connect(updateTacoDrops)
		task.spawn(function()
			local success, result = pcall(remoteFunction.InvokeServer, remoteFunction)

			if not success or typeof(result) ~= "table" then
				return
			end

			for _, v2 in result do
				if not (typeof(v2) == "table" and typeof(v2.Id) == "string" and typeof(v2.SpawnPosition) == "Vector3") then
					continue
				end

				if not (typeof(v2.Position) == "Vector3" and typeof(v2.SpawnTime) == "number" and typeof(v2.FallTime) == "number") then
					continue
				end

				createTacoDrop(v2.Id, v2.SpawnPosition, v2.Position, v2.SpawnTime, v2.FallTime)
			end
		end)
	end
}