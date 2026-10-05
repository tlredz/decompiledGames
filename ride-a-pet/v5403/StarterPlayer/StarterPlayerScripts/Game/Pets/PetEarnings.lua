local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PetRenderer = require(script.Parent:WaitForChild("PetRenderer"))
local Effects = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Effects"))
local cashCollect = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("CashCollect")
local petCollect = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PetCollect")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local AutoCollect = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("AutoCollect"))

-- equivalent calls inferred from this helper; original call sites unknown
local function AutoCollectMode()
	return AutoCollect.Enabled()
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Linear)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.2)

local function SetEarnedText(state, p, p2)
	local billboard = state.Billboard

	if not billboard then
		return
	end

	local earnedLabel = state.EarnedLabel

	if not earnedLabel or earnedLabel.Parent ~= billboard then
		earnedLabel = billboard:FindFirstChild("CashEarned")
		state.EarnedLabel = earnedLabel
		state.EarnedText = nil
	end

	if not earnedLabel then
		return
	end

	if p2 == nil then
		p2 = AutoCollect.Enabled()
	end

	if p2 then
		if earnedLabel.Visible then
			earnedLabel.Visible = false
		end
	else
		if not earnedLabel.Visible then
			earnedLabel.Visible = true
		end

		local v = "$" .. PetRenderer.FormatCash(p)

		if state.EarnedText ~= v then
			state.EarnedText = v
			earnedLabel.Text = v
		end
	end
end

local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = {
	RidePrompt = true,
	Ride = true,
	Feed = true
}
local v3 = {}
ProximityPromptService.PromptShown:Connect(function(p)
	if v2[p.Name] then
		v3[p] = true
	end
end)
ProximityPromptService.PromptHidden:Connect(function(p)
	v3[p] = nil
end)
task.spawn(function()
	if not v then
		return
	end

	while true do
		task.wait(0.1)
		local v4 = {}

		for k in v3 do
			if k.Parent then
				for _, v6 in pairs(PetRenderer.GetAll()) do
					if not (v6.Model and k:IsDescendantOf(v6.Model)) then
						continue
					end

					v4[v6] = true
					break
				end
			else
				v3[k] = nil
			end
		end

		for _, v5 in pairs(PetRenderer.GetAll()) do
			local billboard = v5.Billboard

			if not billboard then
				continue
			end

			local enabled = AutoCollect.Enabled() or not (v and v4[v5])

			if billboard.Enabled ~= enabled then
				billboard.Enabled = enabled
			end
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function DistanceToCamera(p)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and p.Model.Parent then
		return (p.Model:GetPivot().Position - currentCamera.CFrame.Position).Magnitude
	end

	return 1e999
end

local function FloatEarned(state, displayedCash)
	local billboard = state.Billboard
	local model = state.Model

	if not billboard or not model or not model.Parent or displayedCash <= 0 then
		return
	end

	if DistanceToCamera(state) > 150 then
		return
	end

	local clone = billboard:Clone()
	clone.Name = "CashPopup"
	local income = clone:FindFirstChild("Income")

	if income then
		income:Destroy()
	end

	local income_Shadow = clone:FindFirstChild("Income_Shadow")

	if income_Shadow then
		income_Shadow:Destroy()
	end

	for _, tag in clone:GetTags() do
		clone:RemoveTag(tag)
	end

	for _, descendant in clone:GetDescendants() do
		for _, tag in descendant:GetTags() do
			descendant:RemoveTag(tag)
		end
	end

	local cashEarned = clone:FindFirstChild("CashEarned")

	if not cashEarned then
		clone:Destroy()
		return
	end

	cashEarned.Visible = true
	cashEarned.Text = "+$" .. PetRenderer.FormatCash(displayedCash)
	local shadow = cashEarned:FindFirstChild("Shadow") or cashEarned:FindFirstChild("TextShadow")
	local uIStroke = cashEarned:FindFirstChildOfClass("UIStroke")
	local _, v4 = model:GetBoundingBox()
	clone.StudsOffsetWorldSpace = Vector3.new((math.random() - 0.5) * v4.X, v4.Y * 0.5, (math.random() - 0.5) * v4.Z)
	clone.Adornee = billboard.Adornee
	clone.Enabled = true
	clone.Parent = billboard.Parent
	local tween = TweenService:Create(clone, tweenInfo, {
		StudsOffsetWorldSpace = clone.StudsOffsetWorldSpace + createVector(0, 3, 0)
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function FadeOut(p, p2)
		TweenService:Create(p, tweenInfo2, p2):Play()
	end

	FadeOut(cashEarned, cashEarned.TextStrokeTransparency < 1 and {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	} or {
		TextTransparency = 1
	}) -- equivalent call inferred; original call site unknown

	if uIStroke then
		FadeOut(uIStroke, {
			Transparency = 1
		}) -- equivalent call inferred; original call site unknown
	end

	if shadow then
		if shadow:IsA("TextLabel") then
			FadeOut(shadow, shadow.TextStrokeTransparency < 1 and {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			} or {
				TextTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		elseif shadow:IsA("ImageLabel") then
			FadeOut(shadow, {
				ImageTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end
	end

	tween.Completed:Once(function()
		clone:Destroy()
	end)
	tween:Play()
end

local v4 = {}
local total = 0
RunService.Heartbeat:Connect(function(dt)
	if next(v4) == nil then
		return
	end

	total += dt

	if total < 0.05 then
		return
	end

	total = 0
	local now = os.clock()
	local autoCollectMode = AutoCollectMode() -- equivalent call inferred; original call site unknown

	for k, v6 in v4 do
		if v6.Token == k.RollToken then
			local v7 = (now - v6.Start) / 0.5

			if v7 >= 1 or not k.Model.Parent then
				v4[k] = nil
				k.DisplayedCash = v6.To
				SetEarnedText(k, v6.To, autoCollectMode)
			else
				local v8 = 1 - (1 - v7) ^ 3
				local displayedCash = math.lerp(v6.From, v6.To, v8)
				k.DisplayedCash = displayedCash
				SetEarnedText(k, math.floor(displayedCash + 0.5), autoCollectMode)
			end
		else
			v4[k] = nil
		end
	end
end)

local function RollEntryTo(state, displayedCash)
	state.RollToken = (state.RollToken or 0) + 1
	local displayedCash2 = state.DisplayedCash or 0

	if displayedCash2 ~= displayedCash and not (DistanceToCamera(state) > 60) then
		v4[state] = {
			From = displayedCash2,
			To = displayedCash,
			Start = os.clock(),
			Token = state.RollToken
		}
		return
	end

	v4[state] = nil
	state.DisplayedCash = displayedCash
	SetEarnedText(state, displayedCash)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PendingFor(p)
	local income = tonumber(p.Income) or 0

	if income <= 0 then
		return 0
	end

	return (math.max(
		math.floor(income * (workspace:GetServerTimeNow() - (p.CollectTime or workspace:GetServerTimeNow()))),
		0
	))
end

task.spawn(function()
	while true do
		for _, v5 in pairs(PetRenderer.GetAll()) do
			if not (v5.Billboard and v5.Model.Parent) then
				continue
			end

			local income = tonumber(v5.Income) or 0
			local shownSeconds = math.max(
				math.floor(workspace:GetServerTimeNow() - (v5.CollectTime or workspace:GetServerTimeNow())),
				0
			)

			if v5.ShownSeconds == shownSeconds then
				continue
			end

			v5.ShownSeconds = shownSeconds
			RollEntryTo(v5, math.max(math.floor(income * shownSeconds), 0))
		end

		task.wait(0.1)
	end
end)
local object = setmetatable({}, {
	__mode = "k"
})
task.spawn(function()
	while true do
		task.wait(0.15)
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			continue
		end

		local now = os.clock()

		for _, v5 in pairs(PetRenderer.GetAll()) do
			if not (v5.OwnerUserId == localPlayer.UserId and v5.Model.Parent) then
				continue
			end

			local vector2 = v5.Model:GetPivot().Position - humanoidRootPart.Position

			if v5.IsFlying then
				vector2 = Vector3.new(vector2.X, 0, vector2.Z)
			end

			if not (vector2.Magnitude <= (v5.TouchRadius or 6) and (not object[v5] or now - object[v5] >= 1.5)) then
				continue
			end

			if not (PendingFor(v5) >= math.max(v5.Income or 1, 1)) then
				continue
			end

			object[v5] = now
			petCollect:FireServer(v5.PetKey)
		end
	end
end)

local function ResetEntry(state, collectTime, p)
	local income = tonumber(state.Income) or 0
	local collectTime2 = tonumber(state.CollectTime)
	local displayedCash = math.floor(income * (not (collectTime2 and collectTime and collectTime2 < collectTime) and 0 or collectTime - collectTime2 or 0))

	if displayedCash <= 0 then
		displayedCash = math.floor(state.DisplayedCash or 0)
	end

	state.CollectTime = collectTime
	state.RollToken = (state.RollToken or 0) + 1
	state.DisplayedCash = 0
	state.ShownSeconds = 0
	SetEarnedText(state, 0)

	if AutoCollect.Enabled() then
		FloatEarned(state, displayedCash)
	end

	if p and state.Model.Parent and DistanceToCamera(state) <= 150 then
		local clone = cashCollect:Clone()
		clone:PivotTo(state.Model:GetPivot())
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Transparency = 1
		clone.Parent = workspace
		Effects:PlayVFX(clone)
		Debris:AddItem(clone, 4)
	end
end

petCollect.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end

	local owner = tonumber(data.Owner)
	local collectTime = tonumber(data.CollectTime) or workspace:GetServerTimeNow()
	local v5 = not data.Auto or false

	for _, v6 in data.PetKeys or { data.PetKey } do
		local v7 = PetRenderer.Get(owner, v6)

		if v7 then
			ResetEntry(v7, collectTime, v5)
		end
	end
end)