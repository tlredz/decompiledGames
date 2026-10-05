local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = {
	{
		From = {
			-5120.274,
			291.673,
			-1095.559,
			0,
			1.076,
			0
		},
		To = {
			-5121.78,
			291.673,
			-1175.75,
			0,
			1.076,
			0
		},
		Time = 3
	},
	{
		From = {
			-4991.959,
			301.17,
			-1202.077,
			-25.165,
			1.153,
			-0.18
		},
		To = {
			-5037.275,
			301.299,
			-1201.226,
			-25.165,
			1.153,
			-0.18
		},
		Time = 2.5
	}
}
local v2 = {
	"LowerSkyBonusMomentSFX.Get_Treasure_01",
	"LowerSkyBonusMomentSFX.Get_Treasure_02",
	"LowerSkyBonusMomentSFX.Get_Treasure_03"
}
local v3 = nil
local flag = false
local v4 = false
local flag2 = false
local v5 = 0
local flag3 = false
local v6 = false
local flag4 = false
local flag5 = false
local heartbeatConnection = nil
local heartbeatConnection2 = nil
local v7 = nil
local total = 0
local v8 = false
local flag6 = false
local heartbeatConnection3 = nil
local v9 = nil
local triggeredConnection = nil
local v10 = nil
local triggeredConnection2 = nil
local transparencies = {}
local heartbeatConnection4 = nil
local v11 = nil
local v12 = nil
local v13 = 0
local v14 = false
local count = 0
local flag7 = false
local v15 = nil
local v16 = nil
local triggeredConnection3 = nil
local restoreVaultDoor
local setGuardArch
local pivot = nil
local cFrame = nil
local cframe = nil
local v17 = 0
local count2 = 0

local function getSecretDoor()
	local map = workspace:FindFirstChild("Map")
	local sky

	if map then
		sky = map:FindFirstChild("Sky")
	end

	local skyCastle

	if sky then
		skyCastle = sky:FindFirstChild("SkyCastle")
	end

	local secretDoor

	if skyCastle then
		secretDoor = skyCastle:FindFirstChild("SecretDoor")
	end

	if secretDoor and secretDoor:IsA("Model") then
		return secretDoor
	end

	return nil
end

local function rememberSkin(p)
	local transparency = transparencies[p]

	if transparency == nil then
		transparency = p.Transparency
		transparencies[p] = transparency
	end

	return transparency
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeDoorPrompt()
	if triggeredConnection2 then
		triggeredConnection2:Disconnect()
		triggeredConnection2 = nil
	end

	if v10 then
		v10:Destroy()
		v10 = nil
	end
end

local function doorPromptAnchor()
	local secretDoor = getSecretDoor()

	if not secretDoor then
		return nil
	end

	local v18 = 0
	local v19 = nil

	for _, part in secretDoor:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local size = part.Size
		local v20 = size.X * size.Y * size.Z

		if not (v18 < v20) then
			continue
		end

		v19 = part
		v18 = v20
	end

	return v19
end

local function addDoorPrompt()
	if v10 and v10.Parent then
		return
	end

	removeDoorPrompt() -- equivalent call inferred; original call site unknown
	local parent = doorPromptAnchor()

	if not parent then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Break"
	proximityPrompt.ObjectText = "Secret Door"
	proximityPrompt.HoldDuration = 0.6
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = parent
	v10 = proximityPrompt
	triggeredConnection2 = proximityPrompt.Triggered:Connect(function()
		local v19 = v3

		if v19 and not flag6 and v19.Active then
			v19:FireServer("BreakDoor")
		end
	end)
end

local function hideSecretDoor()
	local secretDoor = getSecretDoor()

	if not secretDoor or v8 then
		return
	end

	v8 = true
	flag6 = true
	removeDoorPrompt() -- equivalent call inferred; original call site unknown
	local descendants = {}
	local descendants2 = {}

	for _, descendant in secretDoor:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(descendants, descendant)
		elseif descendant:IsA("Decal") then
			if transparencies[descendant] == nil then
				transparencies[descendant] = descendant.Transparency
			end

			table.insert(descendants2, descendant)
		end
	end

	task.spawn(function()
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.45 do
			local localTransparencyModifier = (os.clock() - lastTime) / 0.45

			for _, v19 in descendants do
				if v19.Parent then
					v19.LocalTransparencyModifier = localTransparencyModifier
				end
			end

			for _, v19 in descendants2 do
				if not v19.Parent then
					continue
				end

				local v20 = transparencies[v19] or 0
				v19.Transparency = v20 + (1 - v20) * localTransparencyModifier
			end

			RunService.RenderStepped:Wait()
		end

		for _, v18 in descendants do
			if not v18.Parent then
				continue
			end

			v18.LocalTransparencyModifier = 1
			v18.CanCollide = false
			v18.CanQuery = false
			v18.CanTouch = false
		end

		for _, v18 in descendants2 do
			if v18.Parent then
				v18.Transparency = 1
			end
		end
	end)
end

local function enforceDoorHidden()
	if not v8 then
		return
	end

	local secretDoor = getSecretDoor()

	if not secretDoor then
		return
	end

	for _, descendant in secretDoor:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.LocalTransparencyModifier < 1 then
			descendant.LocalTransparencyModifier = 1
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
			descendant.Transparency = 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startDoorGuard()
	if heartbeatConnection3 then
		return
	end

	local v18 = 0
	heartbeatConnection3 = RunService.Heartbeat:Connect(function()
		if flag6 then
			local now = os.clock()

			if now < v18 then
				return
			end

			v18 = now + 0.5
			enforceDoorHidden()
		elseif heartbeatConnection3 then
			heartbeatConnection3:Disconnect()
			heartbeatConnection3 = nil
		end
	end)
end

local function restoreSecretDoor()
	if flag6 then
		return
	end

	v8 = false
	local secretDoor = getSecretDoor()

	if not secretDoor then
		return
	end

	for _, descendant in secretDoor:GetDescendants() do
		if descendant:IsA("Decal") then
			local transparency = transparencies[descendant]

			if transparency == nil then
				transparency = descendant.Transparency
				transparencies[descendant] = transparency
			end

			descendant.Transparency = transparency
		end

		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.LocalTransparencyModifier = 0
		descendant.CanCollide = true
		descendant.CanQuery = true
		descendant.CanTouch = true
	end
end

local function eventIdle()
	return v3 == nil or not v3.Active
end

local function underCastleRoof(position: Vector3)
	local map = workspace:FindFirstChild("Map")
	local sky

	if map then
		sky = map:FindFirstChild("Sky")
	end

	local skyCastle

	if sky then
		skyCastle = sky:FindFirstChild("SkyCastle")
	end

	if not skyCastle then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { skyCastle }
	return workspace:Raycast(position, createVector(0, 200, 0), raycastParams) ~= nil
end

local function playerClearOfSecretDoor()
	local secretDoor = getSecretDoor()

	if not secretDoor then
		return true
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return false
	end

	local position = secretDoor:GetPivot().Position
	local Y = position.Y

	for _, part in secretDoor:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local cFrame2 = part.CFrame
		local size = part.Size
		local v18 = 0.5 * (math.abs(cFrame2.RightVector.Y) * size.X + math.abs(cFrame2.UpVector.Y) * size.Y + math.abs(cFrame2.LookVector.Y) * size.Z)
		Y = math.min(Y, cFrame2.Position.Y - v18)
	end

	if humanoidRootPart.Position.Y < Y and underCastleRoof(humanoidRootPart.Position) then
		return false
	end

	return Vector3.new(humanoidRootPart.Position.X - position.X, 0, humanoidRootPart.Position.Z - position.Z).Magnitude > 10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopExitWatch()
	if heartbeatConnection4 then
		heartbeatConnection4:Disconnect()
		heartbeatConnection4 = nil
	end

	v11 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startExitWatch()
	stopExitWatch() -- equivalent call inferred; original call site unknown

	if not flag6 then
		return
	end

	local v18 = 0
	heartbeatConnection4 = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now < v18 then
			return
		end

		v18 = now + 0.35

		if flag6 then
			if v3 == nil or not v3.Active then
				v11 = nil
				return
			end

			if not playerClearOfSecretDoor() then
				v11 = nil
				return
			end

			v11 = v11 or now

			if now - v11 < 0.75 then
				return
			end

			stopExitWatch() -- equivalent call inferred; original call site unknown
			flag6 = false
			restoreSecretDoor()
			restoreVaultDoor()
			setGuardArch(false)
		else
			stopExitWatch() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function getVault()
	local map = workspace:FindFirstChild("Map")
	local sky

	if map then
		sky = map:FindFirstChild("Sky")
	end

	local skyCastle

	if sky then
		skyCastle = sky:FindFirstChild("SkyCastle")
	end

	local skyInterior

	if skyCastle then
		skyInterior = skyCastle:FindFirstChild("SkyInterior")
	end

	local vault

	if skyInterior then
		vault = skyInterior:FindFirstChild("Vault")
	end

	if vault and vault:IsA("Model") then
		return vault
	end

	return nil
end

local function getGuardDoor()
	if v12 and v12.Parent then
		return v12
	end

	v12 = nil

	if os.clock() < v13 then
		return nil
	end

	v13 = os.clock() + 3
	local map = workspace:FindFirstChild("Map")
	local sky

	if map then
		sky = map:FindFirstChild("Sky")
	end

	local skyCastle

	if sky then
		skyCastle = sky:FindFirstChild("SkyCastle")
	end

	if not skyCastle then
		return nil
	end

	local guardDoor = skyCastle:FindFirstChild("GuardDoor", true)

	if guardDoor and guardDoor:IsA("BasePart") then
		v12 = guardDoor
		return v12
	end

	for _, part in skyCastle:GetDescendants() do
		if not (part:IsA("BasePart") and (part.Position - createVector(-5178.867, 285.574, -1218.832)).Magnitude <= 2) then
			continue
		end

		v12 = part
		break
	end

	return v12
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyGuardArch(localTransparencyModifier: number)
	local guardDoor = getGuardDoor()

	if not guardDoor then
		return
	end

	guardDoor.LocalTransparencyModifier = localTransparencyModifier
	guardDoor.CanCollide = localTransparencyModifier < 1
	guardDoor.CanQuery = localTransparencyModifier < 1
end

setGuardArch = function(flag8: boolean, value: number?)
	v14 = flag8
	count += 1
	local localTransparencyModifier2 = flag8 and 1 or 0
	local v19 = value or 0

	if v19 <= 0 then
		flag7 = false
		applyGuardArch(localTransparencyModifier2) -- equivalent call inferred; original call site unknown
	else
		local guardDoor = getGuardDoor()
		local localTransparencyModifier

		if guardDoor then
			localTransparencyModifier = guardDoor.LocalTransparencyModifier
		else
			localTransparencyModifier = 1 - localTransparencyModifier2
		end

		local v20 = count
		local lastTime = os.clock()
		flag7 = true
		task.spawn(function()
			while count == v20 do
				local v21 = math.clamp((os.clock() - lastTime) / v19, 0, 1)
				applyGuardArch(localTransparencyModifier + (localTransparencyModifier2 - localTransparencyModifier) * v21) -- equivalent call inferred; original call site unknown

				if v21 >= 1 then
					break
				else
					RunService.RenderStepped:Wait()
				end
			end

			if count == v20 then
				flag7 = false
			end
		end)
	end
end

local function enforceGuardArch()
	if flag7 then
		return
	end

	local guardDoor = getGuardDoor()

	if not guardDoor then
		return
	end

	local localTransparencyModifier = v14 and 1 or 0

	if guardDoor.LocalTransparencyModifier ~= localTransparencyModifier or guardDoor.CanCollide ~= (localTransparencyModifier < 1) then
		applyGuardArch(localTransparencyModifier) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreGuardArch()
	local v18 = v12
	v14 = false
	count += 1
	flag7 = false
	v12 = nil
	v13 = 0

	if v18 and v18.Parent then
		v18.LocalTransparencyModifier = 0
		v18.CanCollide = true
		v18.CanQuery = true
	end
end

local function getVaultDoor()
	local vault = getVault()
	local skyVault

	if vault then
		skyVault = vault:FindFirstChild("SkyVault")
	end

	if skyVault and skyVault:IsA("Model") then
		return skyVault
	end

	return nil
end

local function vaultDoorPlate(folder)
	local v18 = -1
	local v19 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and v18 < part.Size.X * part.Size.Y) then
			continue
		end

		v18 = part.Size.X * part.Size.Y
		v19 = part
	end

	return v19
end

local function vaultDoorPivot(p: number)
	if pivot and cFrame and cframe then
		local v18 = CFrame.new(0, 0, p * 2.5) * cframe * CFrame.Angles(0, p * 1.7453292519943295, 0) * cframe:Inverse()
		return cFrame * v18 * cFrame:Inverse() * pivot
	else
		return nil
	end
end

local function swingVaultDoor(p: number, p2: number)
	local vault = getVault()
	local skyVault

	if vault then
		skyVault = vault:FindFirstChild("SkyVault")
	else
		skyVault = nil
	end

	if not (skyVault and skyVault:IsA("Model")) then
		skyVault = nil
	end

	local v18

	if skyVault then
		v18 = vaultDoorPlate(skyVault)
	end

	if not (skyVault and v18) then
		return
	end

	if not pivot then
		pivot = skyVault:GetPivot()
		cFrame = v18.CFrame
		cframe = CFrame.new(-v18.Size.X * 0.5 + 0, 0, 0)
	end

	count2 += 1
	local v19 = count2
	local v20 = v17
	local lastTime = os.clock()
	task.spawn(function()
		while count2 == v19 do
			local v21 = not (p2 > 0) and 1 or math.clamp((os.clock() - lastTime) / p2, 0, 1)
			v17 = v20 + (p - v20) * (1 - (1 - v21) ^ 3)
			local v22 = vaultDoorPivot(v17)

			if v22 and skyVault.Parent then
				skyVault:PivotTo(v22)
			end

			if v21 >= 1 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enforceVaultDoor()
	local v18 = vaultDoorPivot(v17)
	local skyVault

	if v18 then
		local vault = getVault()

		if vault then
			skyVault = vault:FindFirstChild("SkyVault")
		end

		if not (skyVault and skyVault:IsA("Model")) then
			skyVault = nil
		end
	end

	if skyVault and v18 and (skyVault:GetPivot().Position - v18.Position).Magnitude > 0.05 then
		skyVault:PivotTo(v18)
	end
end

restoreVaultDoor = function()
	if not pivot then
		return
	end

	count2 += 1
	v17 = 0
	enforceVaultDoor() -- equivalent call inferred; original call site unknown
end

local function getLetter()
	local map = workspace:FindFirstChild("Map")
	local sky

	if map then
		sky = map:FindFirstChild("Sky")
	end

	local skyCastle

	if sky then
		skyCastle = sky:FindFirstChild("SkyCastle")
	end

	local skyInterior

	if skyCastle then
		skyInterior = skyCastle:FindFirstChild("SkyInterior")
	end

	local letter

	if skyInterior then
		letter = skyInterior:FindFirstChild("Letter")
	end

	if letter and letter:IsA("BasePart") then
		return letter
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nearVault()
	local vault = getVault()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if vault and humanoidRootPart then
		return (humanoidRootPart.Position - vault:GetPivot().Position).Magnitude <= 45
	end

	return false
end

local function startLetterPrompt()
	local v18 = v3

	if not v18 or flag then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	local v19 = v18:InvokeServer("ReadLetter")

	if typeof(v19) ~= "string" then
		return
	end

	local v20 = DialogueController.new()
	v20:setTitle("Crumpled Letter")
	v20:addPage("Main", function(object)
		object:setTitle("Crumpled Letter")
		object:addText((`...and keep it away from the ledge this time. The vault code stays <Color=Green>{v19}<Color=/> until the Captain says otherwise.`))
	end)
	local v21 = v20:build()
	flag = true
	v21:getMaid():GiveTask(function()
		flag = false
	end)
	DialogueController.start(v21)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeLetterPrompt()
	if triggeredConnection then
		triggeredConnection:Disconnect()
		triggeredConnection = nil
	end

	if v9 then
		v9:Destroy()
		v9 = nil
	end
end

local function addLetterPrompt()
	if v9 and v9.Parent then
		return
	end

	removeLetterPrompt() -- equivalent call inferred; original call site unknown
	local letter = getLetter()

	if not letter then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Read"
	proximityPrompt.ObjectText = "Crumpled Letter"
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = letter
	v9 = proximityPrompt
	triggeredConnection = proximityPrompt.Triggered:Connect(function()
		startLetterPrompt()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shotCFrame(list)
	return CFrame.new(list[1], list[2], list[3]) * CFrame.fromOrientation(
		math.rad(list[4]),
		math.rad(list[5]),
		(math.rad(list[6]))
	)
end

local function torsoShot()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local v18 = -humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v19 = not (v18.Magnitude > 0.01) and createVector(0, 0, 1) or v18.Unit
	local v20 = humanoidRootPart.Position + createVector(0, 1, 0)
	return CFrame.lookAt(v20 + v19 * 8 + createVector(0, 3, 0), v20)
end

local function playIntro()
	local v18 = v3

	if not v18 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if flag or DialogueController.Active then
		v18:FireServer("CutsceneDone")
		return
	end

	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v19 = CameraController.new()
	local flag8 = false
	local v20 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function release()
		if flag8 and not v20 then
			v18:FireServer("CutsceneDone")
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		if flag8 then
			return
		end

		flag8 = true
		v19:FadeOut(0.6)
		release() -- equivalent call inferred; original call site unknown
	end

	task.spawn(function()
		local v21 = torsoShot()

		if v21 then
			v19:SetCFrame(v21)
			task.wait(1.2)
		end

		for _, v22 in v do
			if flag8 or v3 ~= v18 then
				break
			end

			local v23 = shotCFrame(v22.From) -- equivalent call inferred; original call site unknown
			local v24 = shotCFrame(v22.To) -- equivalent call inferred; original call site unknown
			v19:SetCFrame(v23)
			local total2 = 0

			while total2 < v22.Time and not flag8 and v3 == v18 do
				total2 += RunService.RenderStepped:Wait()
				v19:SetCFrame(v23:Lerp(v24, (math.clamp(total2 / v22.Time, 0, 1))))
			end
		end

		finish() -- equivalent call inferred; original call site unknown
	end)
	local displayName = Players.LocalPlayer.DisplayName
	local v21 = DialogueController.new()
	v21:setTitle(displayName)
	v21:addPage("Main", function(object)
		object:setTitle(displayName)
		object:noCancel()
		object:addText("Hm... looks like the invaders' whole crew is here...")
		object:addText("Guess I'm not getting to the bottom of this without making some noise.")
	end)
	local v22 = v21:build()
	flag = true
	v22:getMaid():GiveTask(function()
		flag = false
		v20 = false
		release() -- equivalent call inferred; original call site unknown
	end)
	DialogueController.start(v22)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropGuardCamera()
	if not v15 then
		return
	end

	local v18 = v15
	v15 = nil
	v18:FadeOut(0.6)
end

local function groundY(position: Vector3, p: number, p2)
	local filterDescendantsInstances = {}

	if p2 then
		table.insert(filterDescendantsInstances, p2)
	end

	for _, childName in { "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(position, Vector3.new(0, -p, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function archFloorY(instance)
	return groundY(instance.Position, instance.Size.Y * 0.5 + 12, instance) or instance.Position.Y - instance.Size.Y * 0.5
end

local function guardArchShot(guardDoor)
	local v18 = archFloorY(guardDoor) -- equivalent call inferred; original call site unknown
	local position = (guardDoor.CFrame * CFrame.new(5, 0, -22)).Position
	return CFrame.lookAt(
		Vector3.new(position.X, v18 + 6, position.Z),
		(Vector3.new(guardDoor.Position.X, v18 + 4, guardDoor.Position.Z))
	)
end

local function openGuardArchBeat()
	local v18 = v3

	if not v18 then
		return
	end

	local guardDoor = getGuardDoor()

	if guardDoor then
		local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
		v15 = CameraController.new()
		v15.Animations:AnimateTo(guardArchShot(guardDoor), 1, 1.4)
		task.delay(16, function()
			if not flag then
				dropGuardCamera() -- equivalent call inferred; original call site unknown
			end
		end)
		task.delay(1.75, function()
			if v3 ~= v18 then
				return
			end

			setGuardArch(true, 0.5)
			task.delay(0.5, function()
				if v3 == v18 then
					v18:FireServer("GuardsOut")
				end
			end)
		end)
	else
		setGuardArch(true)
		v18:FireServer("GuardsOut")
	end
end

local function guardsSpeakBeat()
	local v18 = v3

	if not v18 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		dropGuardCamera() -- equivalent call inferred; original call site unknown

		if v3 == v18 then
			v18:FireServer("CutsceneDone")
		end
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if flag or DialogueController.Active then
		finish() -- equivalent call inferred; original call site unknown
	else
		local v19 = DialogueController.new()
		v19:setTitle("Dark Master")
		v19:addPage("Main", function(object)
			object:setTitle("Dark Master")
			object:setSubtitle("Vault Guard")
			object:noCancel()
			object:addText("What's all that commotion?!")
			object:addText("If you're here for the treasure, you picked the wrong castle to rob.")
			object:addText("You'll have to get through us first!")
		end)
		local v20 = v19:build()
		flag = true
		v20:getMaid():GiveTask(function()
			flag = false
			finish() -- equivalent call inferred; original call site unknown
		end)
		DialogueController.start(v20)
	end
end

local function startCodeThought()
	if not v3 or flag or flag2 or v6 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	v6 = true
	flag4 = false
	flag3 = true
	local displayName = Players.LocalPlayer.DisplayName
	local v18 = DialogueController.new()
	v18:setTitle(displayName)
	v18:addPage("Main", function(object)
		object:setTitle(displayName)
		object:addText("That should be the last of them...")
		object:addText("Wait... did he say treasure?")
		object:addText("So that must be what they're keeping in this vault. Now I just need the code.")
	end)
	local v19 = v18:build()
	flag = true
	v19:getMaid():GiveTask(function()
		flag = false
		v5 = os.clock() + 3
	end)
	DialogueController.start(v19)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopKeypadWatcher()
	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeKeypad()
	stopKeypadWatcher() -- equivalent call inferred; original call site unknown

	if v7 then
		v7.close()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeVaultChest()
	if triggeredConnection3 then
		triggeredConnection3:Disconnect()
		triggeredConnection3 = nil
	end

	if v16 then
		v16:Destroy()
		v16 = nil
	end
end

local function spawnVaultChest()
	removeVaultChest() -- equivalent call inferred; original call site unknown
	local vaultChest = script:FindFirstChild("Vault Chest")
	local vault = getVault()
	local skyVault

	if vault then
		skyVault = vault:FindFirstChild("SkyVault")
	end

	if not (skyVault and skyVault:IsA("Model")) then
		skyVault = nil
	end

	local v18

	if skyVault then
		v18 = vaultDoorPlate(skyVault)
	end

	if not (vaultChest and vaultChest:IsA("Model") and v18) then
		return
	end

	local clone = vaultChest:Clone()
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		clone:Destroy()
		return
	end

	clone.PrimaryPart = primaryPart
	clone:ScaleTo(clone:GetScale() * 1)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local position = (v18.CFrame * CFrame.new(0, 0, 12)).Position
	clone:PivotTo(CFrame.lookAt(position, position + v18.CFrame.LookVector) * CFrame.Angles(0, 3.141592653589793, 0))
	local bottomMetal = clone:FindFirstChild("BottomMetal", true)
	local v19

	if bottomMetal and bottomMetal:IsA("BasePart") then
		v19 = bottomMetal.Position.Y - bottomMetal.Size.Y * 0.5
	else
		v19 = clone:GetPivot().Position.Y
	end

	clone:PivotTo(clone:GetPivot() + Vector3.new(0, v18.Position.Y - v18.Size.Y * 0.5 - v19, 0))
	clone.Name = "AngelicVaultChest"
	clone.Parent = workspace
	v16 = clone
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Take"
	proximityPrompt.ObjectText = "Vault Treasure"
	proximityPrompt.MaxActivationDistance = 18
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = primaryPart
	triggeredConnection3 = proximityPrompt.Triggered:Connect(function()
		local v20 = v3
		local position2 = primaryPart.Position

		if v20 and v20:InvokeServer("TakeChest") == true then
			pcall(function()
				Sound:Play(v2[math.random(#v2)], position2)
			end)
			removeVaultChest() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function startVaultResult()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local v18 = DialogueController.new()
	v18:setTitle("Angelic Vault")
	v18:addPage("Main", function(object)
		object:setTitle("Angelic Vault")
		object:noCancel()
		object:addText("The lock clicks, and the heavy door swings open. A chest sits inside, free for the taking.")
	end)
	local v19 = v18:build()
	flag = true
	v19:getMaid():GiveTask(function()
		flag = false
	end)
	DialogueController.start(v19)
end

local function openVaultKeypad(p)
	if not v7 then
		local VaultKeypad = require(script:WaitForChild("VaultKeypad"))
		v7 = VaultKeypad
	end

	if v7.isOpen() then
		return
	end

	flag = true
	v7.open(function(p2: string)
		return (v3 or p):InvokeServer("TryCode", p2) == true
	end, function()
		stopKeypadWatcher() -- equivalent call inferred; original call site unknown
		flag2 = true
		flag = false
	end, function()
		stopKeypadWatcher() -- equivalent call inferred; original call site unknown
		flag = false
		v5 = os.clock() + 3
	end)
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if v7.isOpen() then
			if v3 == p and not flag2 then
				-- equivalent call inferred; original call site unknown
				if not nearVault() then
					closeKeypad() -- equivalent call inferred; original call site unknown
				end
			else
				closeKeypad() -- equivalent call inferred; original call site unknown
			end
		else
			stopKeypadWatcher() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function startVaultPrompt()
	local v18 = v3

	if not v18 or flag or flag2 or v7 and v7.isOpen() then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	if v18:InvokeServer("VaultCodes") == nil then
		if v18:InvokeServer("InspectVault") == nil then
			return
		end

		v5 = os.clock() + 3
		startCodeThought()
	else
		local v19 = DialogueController.new()
		v19:setTitle("Angelic Vault")
		v19:addPage("Main", function(object)
			object:setTitle("Angelic Vault")
			object:addText("Four digits... This must be what that letter was referring to.")
			object:addOptionType("Accept", function(object2)
				object2:setText("Enter the code")
				object2:onSelected(function()
					task.defer(openVaultKeypad, v18)
				end)
			end)
		end)
		local v20 = v19:build()
		flag = true
		v20:getMaid():GiveTask(function()
			flag = false
			v5 = os.clock() + 3
		end)
		DialogueController.start(v20)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startWatching()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.4 then
			return
		end

		total = 0
		enforceDoorHidden()
		enforceVaultDoor() -- equivalent call inferred; original call site unknown
		local v18 = not flag7 and getGuardDoor()

		if v18 then
			local localTransparencyModifier = v14 and 1 or 0
			local v20 = (v18.LocalTransparencyModifier ~= localTransparencyModifier or v18.CanCollide ~= (localTransparencyModifier < 1)) and getGuardDoor()

			if v20 then
				v20.LocalTransparencyModifier = localTransparencyModifier
				v20.CanCollide = localTransparencyModifier < 1
				v20.CanQuery = localTransparencyModifier < 1
			end
		end

		if v3 and (v3 == nil or not v3.Active) and not flag6 then
			hideSecretDoor()
			startDoorGuard() -- equivalent call inferred; original call site unknown
			startExitWatch() -- equivalent call inferred; original call site unknown
		end

		if flag6 or v3 == nil or not v3.Active then
			removeDoorPrompt() -- equivalent call inferred; original call site unknown
		else
			addDoorPrompt()
		end

		if flag or not v4 then
			return
		end

		if flag2 then
			removeLetterPrompt() -- equivalent call inferred; original call site unknown
		elseif flag5 then
			removeLetterPrompt() -- equivalent call inferred; original call site unknown
		else
			if flag4 then
				startCodeThought()
				return
			end

			if flag3 then
				addLetterPrompt()
			end

			local now = os.clock()

			if v5 <= now then
				-- equivalent call inferred; original call site unknown
				if nearVault() then
					startVaultPrompt()
				end
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWatching()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local UnexpectedGuest = {}

function UnexpectedGuest.OnLoad(p)
	v3 = p
	v13 = 0
	flag = false
	v4 = false
	flag2 = false
	flag3 = false
	v6 = false
	flag4 = false
	flag5 = false
	v5 = 0
	removeLetterPrompt() -- equivalent call inferred; original call site unknown
	removeDoorPrompt() -- equivalent call inferred; original call site unknown
	removeVaultChest() -- equivalent call inferred; original call site unknown
	startExitWatch() -- equivalent call inferred; original call site unknown
	restoreSecretDoor()
	setGuardArch(false)
	startWatching() -- equivalent call inferred; original call site unknown
end

UnexpectedGuest.RemoteEvents = {
	Occupants = function(_, _)
		playIntro()
	end,
	Remaining = function(_, _) end,
	SecretDoor = function(_)
		hideSecretDoor()
		startDoorGuard() -- equivalent call inferred; original call site unknown
	end,
	Cleared = function(_)
		v4 = true
	end,
	VaultGuards = function(_)
		flag5 = true
		removeLetterPrompt() -- equivalent call inferred; original call site unknown
		openGuardArchBeat()
	end,
	ArchOpen = function(_)
		flag5 = true
		removeLetterPrompt() -- equivalent call inferred; original call site unknown
		setGuardArch(true, 0.5)
	end,
	GuardsSpeak = function(_)
		guardsSpeakBeat()
	end,
	AmbushCleared = function(_)
		flag5 = false
		flag4 = true
		startCodeThought()
	end,
	DoorSealed = function(_)
		v4 = false
		flag2 = false
		flag3 = false
		v6 = false
		flag4 = false
		flag5 = false
		v5 = 0
		closeKeypad() -- equivalent call inferred; original call site unknown
		removeLetterPrompt() -- equivalent call inferred; original call site unknown
		removeVaultChest() -- equivalent call inferred; original call site unknown
		startExitWatch() -- equivalent call inferred; original call site unknown
	end,
	VaultOpened = function(_, p)
		flag2 = true
		closeKeypad() -- equivalent call inferred; original call site unknown
		swingVaultDoor(1, p == true and 0 or 1.2)
		spawnVaultChest()

		if p ~= true then
			pcall(function()
				Sound:PlayUI("LowerSkyBonusMomentSFX.Correct_Code_Vault_Unlock_01")
			end)
			startVaultResult()
		end
	end
}

function UnexpectedGuest.OnComplete(_, _, _)
	stopWatching() -- equivalent call inferred; original call site unknown
	closeKeypad() -- equivalent call inferred; original call site unknown
	removeLetterPrompt() -- equivalent call inferred; original call site unknown
	removeDoorPrompt() -- equivalent call inferred; original call site unknown
	removeVaultChest() -- equivalent call inferred; original call site unknown
	startExitWatch() -- equivalent call inferred; original call site unknown
	dropGuardCamera() -- equivalent call inferred; original call site unknown
	restoreGuardArch() -- equivalent call inferred; original call site unknown
	v3 = nil
end

return UnexpectedGuest