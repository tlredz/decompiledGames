local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Audio"))
local TweenService = game:GetService("TweenService")
local replicatedStorage = game.ReplicatedStorage
local gameServices = replicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local Confetti = require(gameServices:WaitForChild("Confetti"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Effects = require(replicatedStorage:WaitForChild("Services"):WaitForChild("Effects"))
local CameraShaker = require(replicatedStorage:WaitForChild("Services"):WaitForChild("CameraShaker"))
local ForgeVFX = require(replicatedStorage:WaitForChild("Services"):WaitForChild("ForgeVFX"))
local PetRigService = require(gameServices:WaitForChild("PetRigService"))
local StringService = require(gameServices:WaitForChild("StringService"))
local Pets = require(replicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local hatch = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Hatch")
local assets = replicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")
local pets = assets:WaitForChild("Pets")
local effects = assets:WaitForChild("Effects")
local rarityGradients = assets:WaitForChild("RarityGradients")
local sampleSizeShower = assets:WaitForChild("Billboards"):WaitForChild("SampleSizeShower")
local smoke = effects:WaitForChild("Smoke")
local sparkles = effects:WaitForChild("Sparkles")
local SFX = game.SoundService:FindFirstChild("SFX")
ForgeVFX.init()
task.spawn(function()
	local v = { animations, effects }

	for _, child in pets:GetChildren() do
		local template = PetRigService.GetTemplate(child.Name)

		if not template then
			continue
		end

		for _, child2 in template:GetChildren() do
			if child2.Name ~= "Animations" then
				table.insert(v, child2)
			end
		end
	end

	local eggFragments = assets:FindFirstChild("EggFragments")

	if eggFragments then
		table.insert(v, eggFragments)
	end

	if SFX then
		for _, childName in { "Hatching", "RNGReveal" } do
			local child = SFX:FindFirstChild(childName)

			if child then
				table.insert(v, child)
			end
		end
	end

	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync(v)
	end)
end)
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(p)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CFrame *= p
	end
end)
v._renderName = "CameraShakerHatching"
v:Start()

local function AttachOddsBillboard(folder, p)
	local pet = Pets[p]

	if not (pet and pet.SampleSize and folder.PrimaryPart) then
		return nil
	end

	local clone = sampleSizeShower:Clone()
	local sampleSize = clone:FindFirstChild("SampleSize")

	if not sampleSize then
		clone:Destroy()
		return nil
	end

	sampleSize.Text = StringService.FormatOdds(pet.SampleSize)

	for _, uIGradient in sampleSize:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	local child = pet.Rarity and rarityGradients:FindFirstChild(pet.Rarity)

	if child then
		local clone_2 = child:Clone()
		clone_2.Parent = sampleSize
	end

	clone.Adornee = folder.PrimaryPart
	clone.Parent = folder
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ParkOddsBillboard(p, p2)
	PetRigService.PinBillboard(p, p2, sampleSizeShower, 2)
end

local function RevealPet(p, cframe, p2, p3, spawnMutation, p4)
	local folder = PetRigService.Build(p)

	if not folder then
		warn("[RevealPet] pet asset missing: " .. tostring(p))
		return
	end

	folder.Name = p .. "Reveal"

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
	end

	if not folder.PrimaryPart then
		folder.PrimaryPart = folder:FindFirstChildWhichIsA("BasePart", true)
	end

	folder.Parent = workspace
	folder:PivotTo(cframe)
	PetRigService.ApplyMutationAura(folder, p3)
	folder:SetAttribute("SpawnMutation", spawnMutation)
	folder:AddTag("PetReveal")
	pcall(function()
		local animations2 = folder:FindFirstChild("Animations")
		local idle = animations2 and animations2:FindFirstChild("Idle")
		local animationController = folder:FindFirstChildOfClass("AnimationController")

		if not (idle and animationController) then
			return
		end

		local v2 = animationController:FindFirstChildOfClass("Animator")

		if not v2 then
			v2 = Instance.new("Animator")
			v2.Parent = animationController
		end

		local track = v2:LoadAnimation(idle)
		track.Looped = true
		track:Play()
	end)
	local rNGReveal = SFX and SFX:FindFirstChild("RNGReveal")
	local reveal = rNGReveal and rNGReveal:FindFirstChild("Reveal")

	if reveal and folder.PrimaryPart then
		Audio:PlayOn(reveal, folder.PrimaryPart)
	end

	local clone = sparkles:Clone()
	clone.CFrame = clone.CFrame.Rotation + cframe.Position
	clone.Anchored = true
	clone.Parent = workspace
	ForgeVFX.emit(clone)
	task.delay(6, function()
		clone:Destroy()
	end)
	local scale = folder:GetScale()
	local visibleExtentsY = PetRigService.VisibleExtentsY(folder)
	local v2 = folder:GetPivot().Position.Y - visibleExtentsY
	local Players2 = game:GetService("Players")
	local characters = { folder }

	for _, v3 in Players2:GetPlayers() do
		if v3.Character then
			table.insert(characters, v3.Character)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(
		cframe.Position + createVector(0, 25, 0),
		createVector(0, -2048, 0),
		raycastParams
	)
	local Y = raycastResult and raycastResult.Position.Y or cframe.Position.Y - 4

	local function ScaleReveal(p5)
		folder:ScaleTo((math.max(p5, 0.01)))
		local v3 = v2 * (folder:GetScale() / scale)
		local v4 = math.max(cframe.Position.Y, Y + v3 + 0.1)
		folder:PivotTo(cframe.Rotation + Vector3.new(cframe.Position.X, v4, cframe.Position.Z))
	end

	local v3 = scale * ((tonumber(p2) or 10) / 10)
	local v4 = v3 * 0.05
	local attachOddsBillboard = AttachOddsBillboard(folder, p)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = v4
	numberValue.Changed:Connect(function(p5)
		if folder.Parent then
			ScaleReveal(p5)
			ParkOddsBillboard(attachOddsBillboard, folder) -- equivalent call inferred; original call site unknown
		end
	end)
	ScaleReveal(v4)
	ParkOddsBillboard(attachOddsBillboard, folder) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Value = v3
		}
	)
	tween:Play()

	if p4 then
		pcall(Confetti.Burst)
	end

	tween.Completed:Connect(function()
		numberValue:Destroy()

		if not folder.Parent or spawnMutation then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		highlight.Adornee = folder
		highlight.Parent = folder
		local tween2 = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			FillTransparency = 1
		})
		tween2:Play()
		tween2.Completed:Once(function()
			highlight:Destroy()
		end)
	end)
	task.delay(2.5, function()
		if not folder.Parent then
			return
		end

		local clone2 = smoke:Clone()
		clone2:PivotTo(folder:GetPivot() + createVector(0, 2, 0))
		clone2.Parent = workspace
		folder:Destroy()
		Effects:PlayVFX(clone2)
		Debris:AddItem(clone2, 3)
	end)
end

hatch.OnClientEvent:Connect(function(data)
	local owner = data.Owner
	local eggKey = data.EggKey
	local plot = General:GetPlot(owner)
	local eggs = plot and plot:FindFirstChild("Eggs")

	if not eggs then
		return
	end

	local v2 = nil

	for _, child in eggs:GetChildren() do
		if child:GetAttribute("EggKey") ~= eggKey then
			continue
		end

		v2 = child
		break
	end

	if not v2 then
		return
	end

	v2:AddTag("Hatching")
	local pivot = v2:GetPivot()
	local scale = v2:GetScale()

	local function ShakeEgg(speed)
		local pivot2 = v2:GetPivot()
		local numberValue = Instance.new("NumberValue")
		numberValue.Changed:Connect(function(p)
			if v2.Parent then
				local v4 = math.sin(p * 4 * 3.141592653589793 * 2) * 0.13962634015954636
				v2:PivotTo(pivot2 * CFrame.Angles(0, 0, v4))
			end
		end)
		local tween = TweenService:Create(numberValue, TweenInfo.new(0.6 / speed, Enum.EasingStyle.Linear), {
			Value = 1
		})
		tween:Play()
		tween.Completed:Wait()
		numberValue:Destroy()

		if v2.Parent then
			v2:PivotTo(pivot2)
		end
	end

	local hatching = SFX and SFX:FindFirstChild("Hatching")
	local shaking = hatching and hatching:FindFirstChild("Shaking")

	for _, v4 in {
		{
			Speed = 1,
			Wait = 0.6
		},
		{
			Speed = 1.2,
			Wait = 0.4
		},
		{
			Speed = 1.4,
			Wait = 0
		}
	} do
		if not v2.Parent then
			break
		end

		if shaking and v2.PrimaryPart then
			Audio:PlayOn(shaking, v2.PrimaryPart, {
				PlaybackSpeed = v4.Speed,
				Lifetime = 3
			})
		end

		ShakeEgg(v4.Speed)

		if v4.Wait > 0 then
			task.wait(v4.Wait)
		end
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = v2:GetScale()
	numberValue.Changed:Connect(function(p)
		if v2.Parent then
			v2:ScaleTo(p)
		end
	end)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Value = v2:GetScale() * 1.25
		}
	)
	tween:Play()
	tween.Completed:Wait()
	numberValue:Destroy()

	if SFX then
		local hatching2 = SFX:FindFirstChild("Hatching")
		local hatch2 = hatching2 and (hatching2:FindFirstChild("Hatch") or hatching2:FindFirstChildOfClass("Sound"))
		local primaryPart = v2.PrimaryPart or v2:FindFirstChildWhichIsA("BasePart", true)

		if hatch2 and primaryPart then
			Audio:PlayOn(hatch2, primaryPart, {
				Lifetime = 4
			})
		end
	end

	local eggFragments = assets:FindFirstChild("EggFragments")

	if eggFragments then
		local clone = eggFragments:Clone()
		clone:PivotTo(pivot)
		clone.Parent = workspace

		for _, part in clone:GetDescendants() do
			if not (part:IsA("BasePart") and part.Name ~= "Center") then
				continue
			end

			part.Anchored = false
			part.CanCollide = true
			part:ApplyImpulse(Vector3.new(
				(math.random() - 0.5) * 2 * 25,
				math.random() * 25,
				(math.random() - 0.5) * 2 * 25
			) * part.AssemblyMass)
			part:ApplyAngularImpulse(Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * part.AssemblyMass * 10)
		end

		Effects:PlayVFX(clone)
		Debris:AddItem(clone, 3)
		local currentCamera = workspace.CurrentCamera
		local magnitude = currentCamera and (pivot.Position - currentCamera.CFrame.Position).Magnitude

		if magnitude and magnitude <= 80 then
			v:Shake(CameraShaker.Presets.SmallShake)
		end
	end

	local luckyBurst

	if (tonumber(data.LuckEventMultiplier) or 1) > 1 then
		luckyBurst = effects:FindFirstChild("LuckyBurst")
	else
		luckyBurst = false
	end

	if luckyBurst and luckyBurst:IsA("Model") and v2.Parent then
		local boundingBox = v2:GetBoundingBox()
		local clone = luckyBurst:Clone()

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		clone:ScaleTo(scale * 1)
		clone:PivotTo(CFrame.new(boundingBox.Position))
		clone.Parent = workspace
		ForgeVFX.emit(clone)
		Debris:AddItem(clone, 6)
	end

	v2:Destroy()

	if data.PetName then
		local cframe = pivot + createVector(0, 4, 0)
		local humanoidRootPart = owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local position = cframe.Position
			local vector2 = Vector3.new(humanoidRootPart.Position.X, position.Y, humanoidRootPart.Position.Z)

			if (vector2 - position).Magnitude > 0.05 then
				cframe = CFrame.lookAt(position, vector2)
			end
		end

		RevealPet(
			data.PetName,
			cframe,
			data.Weight,
			data.Mutation,
			data.SpawnMutation,
			owner == localPlayer and data.TutorialFinalHatch == true
		)
	end
end)