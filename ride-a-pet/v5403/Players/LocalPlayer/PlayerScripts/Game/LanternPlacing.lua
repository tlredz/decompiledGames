local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local replicatedStorage = game.ReplicatedStorage
local services = replicatedStorage:WaitForChild("Services")
local gameServices = replicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local Audio = require(services:WaitForChild("Audio"))
local Lanterns = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("Lanterns"))
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
local confirmation = localPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Confirmation")
local question = confirmation:WaitForChild("Question")
local confirm = confirmation:WaitForChild("Confirm")
local cancel = confirmation:WaitForChild("Cancel")
local placeLantern = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PlaceLantern")
local lanterns = replicatedStorage:WaitForChild("Assets"):WaitForChild("Lanterns")
local SFX = game.SoundService:WaitForChild("SFX")
local click = SFX:WaitForChild("Click")
local game2 = SFX:WaitForChild("Game")
local eggPlacing = game2:FindFirstChild("EggPlacing")
local growing = game2:FindFirstChild("Growing")
local flag = false
local v = false
local v2 = nil
local v3 = nil
local vector2 = Vector2.new()
local now = 0
local activatedConnection = nil
local activatedConnection2 = nil
local placementPreview = script:WaitForChild("PlacementPreview")
local cylinder = placementPreview:WaitForChild("Cylinder")
TweenService:Create(
	cylinder:WaitForChild("SurfaceGui"):WaitForChild("ImageLabel"),
	TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{
		Rotation = 360
	}
):Play()
local model = nil
local v4 = {
	ParticleEmitter = true,
	Beam = true,
	Trail = true,
	Fire = true,
	Smoke = true,
	Sparkles = true
}

local function SetSoundPlaying(folder, flag2: boolean)
	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		if flag2 then
			sound.Looped = true
			sound:Play()
		else
			sound:Stop()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetVFXEnabled(folder, enabled: boolean)
	for _, descendant in folder:GetDescendants() do
		if v4[descendant.ClassName] then
			descendant.Enabled = enabled
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateRayFilter()
	local tagged = CollectionService:GetTagged("Pet")
	table.insert(tagged, placementPreview)
	local character = localPlayer.Character

	if character then
		table.insert(tagged, character)
	end

	raycastParams.FilterDescendantsInstances = tagged
end

CollectionService:GetInstanceAddedSignal("Pet"):Connect(UpdateRayFilter)
CollectionService:GetInstanceRemovedSignal("Pet"):Connect(UpdateRayFilter)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnPlot()
	return General:GetPlot(localPlayer)
end

local function HitIsOwnPlot(instance)
	if not instance then
		return false
	end

	local ownPlot = GetOwnPlot() -- equivalent call inferred; original call site unknown
	return ownPlot ~= nil and instance:IsDescendantOf(ownPlot)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CloseConfirmation()
	confirmation.Visible = false
	v = false
	v3 = nil

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	if activatedConnection2 then
		activatedConnection2:Disconnect()
		activatedConnection2 = nil
	end
end

local function BuildGhost(folder)
	if model then
		model:Destroy()
	end

	model = Instance.new("Model")
	model.Name = "GhostLantern"

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()

		for _, descendant in clone:GetDescendants() do
			if not (descendant:IsA("JointInstance") or descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound")) then
				continue
			end

			descendant:Destroy()
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false

		if clone.Transparency < 0.6 then
			clone.Transparency = 0.6
		end

		clone.Parent = model
	end

	for _, descendant in model:GetDescendants() do
		if v4[descendant.ClassName] then
			descendant.Enabled = false
		end
	end

	for _, sound in model:GetDescendants() do
		if sound:IsA("Sound") then
			sound:Stop()
		end
	end

	local handle = model:FindFirstChild("Handle") or model:FindFirstChildWhichIsA("BasePart")
	model.PrimaryPart = handle
	model.Parent = placementPreview
end

local function CheckForLantern()
	local character = localPlayer.Character

	if not character then
		return
	end

	UpdateRayFilter() -- equivalent call inferred; original call site unknown
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and CollectionService:HasTag(tool, "Lantern") and Lanterns[tool.Name] then
		if v2 ~= tool then
			CloseConfirmation() -- equivalent call inferred; original call site unknown
			flag = true
			v2 = tool
			BuildGhost(tool)
			local range = Lanterns[tool.Name].Range
			cylinder.Size = Vector3.new(range, cylinder.Size.Y, range)

			if UserInputService.MouseEnabled and not UserInputService.TouchEnabled then
				v = true
			end
		end
	elseif flag then
		flag = false
		v2 = nil
		CloseConfirmation() -- equivalent call inferred; original call site unknown

		if model then
			model:Destroy()
			model = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchCharacter(character)
	character.ChildAdded:Connect(CheckForLantern)
	character.ChildRemoved:Connect(CheckForLantern)
	CheckForLantern()
end

localPlayer.CharacterAdded:Connect(WatchCharacter)

if localPlayer.Character then
	WatchCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local function PlaceLantern()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not (humanoid and v2) then
		return
	end

	local v5 = nil

	if v3 then
		v5 = v3
	else
		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if raycastResult then
			local instance = raycastResult.Instance
			local v6

			if instance then
				local ownPlot = GetOwnPlot() -- equivalent call inferred; original call site unknown

				if ownPlot == nil then
					v6 = false
				else
					v6 = instance:IsDescendantOf(ownPlot)
				end
			else
				v6 = false
			end

			if v6 then
				v5 = raycastResult.Position + createVector(0, 0.1, 0)
			end
		end
	end

	if not v5 then
		return
	end

	if eggPlacing then
		Audio:PlayAtPosition(eggPlacing, v5)
	end

	placeLantern:FireServer(v2.Name, v5)
	humanoid:UnequipTools()
end

local parent = workspace:FindFirstChild("RenderedLanterns")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "RenderedLanterns"
	parent.Parent = workspace
end

local v6 = {}

local function BoostEgg(child, p)
	local eggData = child:FindFirstChild("EggData")
	local sizeMultiplier = eggData and eggData:FindFirstChild("SizeMultiplier")

	if not sizeMultiplier then
		return
	end

	local value = sizeMultiplier.Value

	if p <= value then
		sizeMultiplier.Value = p
		return
	end

	local scale = child:GetScale()
	local v7 = scale / (1 + value) * (1 + p)
	sizeMultiplier.Value = p

	if growing and not growing.IsPlaying then
		growing:Play()
	end

	child:AddTag("LanternBoosting")
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = scale
	local valueChangedConnection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		if child.Parent then
			pcall(function()
				child:ScaleTo(numberValue.Value)
			end)
		end
	end)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = v7
		}
	)
	tween.Completed:Connect(function()
		valueChangedConnection:Disconnect()
		numberValue:Destroy()

		if child.Parent then
			child:RemoveTag("LanternBoosting")
		end
	end)
	tween:Play()
end

local function ApplyBoosts(p, items)
	if not items or next(items) == nil then
		return
	end

	task.spawn(function()
		local v7 = os.clock() + 5
		local v8 = {}

		for k, item in items do
			v8[k] = item
		end

		while next(v8) and os.clock() < v7 do
			local plot = General:GetPlot(p)
			local eggs = plot and plot:FindFirstChild("Eggs")

			if eggs then
				for _, child in eggs:GetChildren() do
					local eggKey = child:GetAttribute("EggKey")

					if not (eggKey and v8[eggKey] ~= nil) then
						continue
					end

					BoostEgg(child, v8[eggKey])
					v8[eggKey] = nil
				end
			end

			if next(v8) then
				task.wait(0.3)
			end
		end
	end)
end

local function SetupLantern(data)
	local owner = data.Owner
	local name = data.Name
	local position = data.Position
	local placeTime = data.PlaceTime
	local key = data.Key
	local lantern = Lanterns[name]

	if not (lantern and position) then
		return
	end

	local v7 = lantern.Lifetime - (workspace:GetServerTimeNow() - (placeTime or 0))

	if not (v7 <= 0) and key and not (v6[key] and v6[key].Parent) then
		local folder = lanterns:FindFirstChild(name)

		if folder then
			local model2 = Instance.new("Model")
			model2.Name = name

			if key then
				model2:SetAttribute("LanternKey", key)
			end

			model2:SetAttribute("OwnerUserId", owner.UserId)

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = part:Clone()

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("JointInstance") or descendant:IsA("LuaSourceContainer") then
						descendant:Destroy()
					end
				end

				clone.Anchored = true
				clone.CanCollide = false
				clone.Parent = model2
			end

			if model2:FindFirstChildWhichIsA("BasePart") then
				model2.PrimaryPart = model2:FindFirstChild("Handle") or model2:FindFirstChildWhichIsA("BasePart")
				model2:PivotTo(CFrame.new(position))
				local boundingBox, v8 = model2:GetBoundingBox()
				local v9 = position.Y - (boundingBox.Position.Y - v8.Y / 2)
				model2:PivotTo(CFrame.new(position + Vector3.new(0, v9, 0)))
				model2.Parent = parent
				SetVFXEnabled(model2, true) -- equivalent call inferred; original call site unknown
				SetSoundPlaying(model2, true)
				v6[key] = model2
				Debris:AddItem(model2, v7)
			else
				model2:Destroy()
			end
		end
	end

	local boostedEggs = data.BoostedEggs

	if boostedEggs then
		if next(boostedEggs) == nil then
			return
		else
			task.spawn(function()
				local v8 = os.clock() + 5
				local v9 = {}

				for k, boostedEgg in boostedEggs do
					v9[k] = boostedEgg
				end

				while next(v9) and os.clock() < v8 do
					local plot = General:GetPlot(owner)
					local eggs = plot and plot:FindFirstChild("Eggs")

					if eggs then
						for _, child in eggs:GetChildren() do
							local eggKey = child:GetAttribute("EggKey")

							if not (eggKey and v9[eggKey] ~= nil) then
								continue
							end

							BoostEgg(child, v9[eggKey])
							v9[eggKey] = nil
						end
					end

					if next(v9) then
						task.wait(0.3)
					end
				end
			end)
		end
	end
end

placeLantern.OnClientEvent:Connect(SetupLantern)
Players.PlayerRemoving:Connect(function(player)
	for _, child in parent:GetChildren() do
		if child:GetAttribute("OwnerUserId") ~= player.UserId then
			continue
		end

		local lanternKey = child:GetAttribute("LanternKey")

		if lanternKey then
			v6[lanternKey] = nil
		end

		child:Destroy()
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not flag then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch then
		now = os.clock()
		vector2 = Vector2.new(input.Position.X, input.Position.Y)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if v and not UserInputService.TouchEnabled then
			PlaceLantern()
		end
	elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
		if GamepadUI.GameplayBlocked() then
			return
		else
			PlaceLantern()
		end
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not flag then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		v = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if not (flag and input.UserInputType == Enum.UserInputType.Touch and confirmation.Visible ~= true) then
		return
	end

	local v7 = os.clock() - now
	local vector3 = Vector2.new(input.Position.X, input.Position.Y)

	if v7 < 0.3 and (vector3 - vector2).Magnitude < 15 then
		local screenPointToRay = currentCamera:ScreenPointToRay(vector3.X, vector3.Y)
		local raycastResult = workspace:Raycast(
			screenPointToRay.Origin,
			screenPointToRay.Direction * 1000,
			raycastParams
		)

		if raycastResult then
			local instance = raycastResult.Instance
			local v8

			if instance then
				local ownPlot = GetOwnPlot() -- equivalent call inferred; original call site unknown

				if ownPlot == nil then
					v8 = false
				else
					v8 = instance:IsDescendantOf(ownPlot)
				end
			else
				v8 = false
			end

			if v8 then
				v3 = raycastResult.Position + createVector(0, 0.1, 0)
				v = true
				confirmation.Visible = true

				if activatedConnection then
					activatedConnection:Disconnect()
				end

				if activatedConnection2 then
					activatedConnection2:Disconnect()
				end

				question.Text = string.format("Place %s x1?", v2.Name)
				activatedConnection = confirm.Activated:Connect(function()
					click:Play()
					PlaceLantern()
					CloseConfirmation() -- equivalent call inferred; original call site unknown
				end)
				activatedConnection2 = cancel.Activated:Connect(function()
					click:Play()
					CloseConfirmation() -- equivalent call inferred; original call site unknown
				end)
			end
		end
	end
end)
GamepadUI.Watch(confirmation, CloseConfirmation, cancel, 20)
RunService.RenderStepped:Connect(function()
	if not (v and flag) then
		placementPreview.Parent = script
		return
	end

	local v7 = nil

	if v3 then
		v7 = v3
	else
		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if raycastResult then
			local instance = raycastResult.Instance
			local v8

			if instance then
				local ownPlot = GetOwnPlot() -- equivalent call inferred; original call site unknown

				if ownPlot == nil then
					v8 = false
				else
					v8 = instance:IsDescendantOf(ownPlot)
				end
			else
				v8 = false
			end

			if v8 then
				v7 = raycastResult.Position + createVector(0, 0.1, 0)
			end
		end
	end

	if not v7 then
		placementPreview.Parent = script
		return
	end

	cylinder.CFrame = CFrame.new(v7 + createVector(0, 0.15, 0))

	if model and model.PrimaryPart then
		model:PivotTo(CFrame.new(v7))
		local boundingBox, v8 = model:GetBoundingBox()
		local v9 = v7.Y - (boundingBox.Position.Y - v8.Y / 2)
		model:PivotTo(CFrame.new(v7 + Vector3.new(0, v9, 0)))
	end

	placementPreview.Parent = workspace
end)