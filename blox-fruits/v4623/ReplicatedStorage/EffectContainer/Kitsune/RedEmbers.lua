local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage.FX)
local kitsuneStage = FX:WaitForChild("Kitsune").KitsuneStage
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin

function Weld(instance, part)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = instance
	motor6D.Part1 = part
	local cframe = CFrame.new(instance.Position)
	local C0 = instance.CFrame:inverse() * cframe
	local C1 = part.CFrame:inverse() * cframe
	motor6D.C0 = C0
	motor6D.C1 = C1
	motor6D.Parent = instance
end

function Get(part)
	if part:IsA("BasePart") then
		if part ~= part.Parent.PrimaryPart then
			Weld(part.Parent.PrimaryPart, part)
			part.Anchored = false
		end
	else
		local children = part:GetChildren()

		for i = 1, #children do
			Get(children[i])
		end
	end
end

local function makeProxyPartAtBone(kitsune, spine002, playerFromCharacter, cframe: CFrame?)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. spine002.Name
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	Util.SetParentOverrideWithColor(attachment, part, playerFromCharacter, "KitsuneFruitVFXColor")
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = spine002
	rigidConstraint.Attachment1 = attachment
	Util.SetParentOverrideWithColor(rigidConstraint, part, playerFromCharacter, "KitsuneFruitVFXColor")
	part.Transparency = 1
	Util.SetParentOverrideWithColor(part, kitsune.RootPart, playerFromCharacter, "KitsuneFruitVFXColor")
	return part
end

local Util2 = require(game.ReplicatedStorage.Util)

for _, child in pairs(kitsuneStage.FlameSpawn.Attachment:GetChildren()) do
	Util2.Misc.ScaleParticle(child, 0.575)
end

return function(data)
	local root = data.Root
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(root.Parent)
	local holding = data.Holding
	local cFrame = root.CFrame
	local folder = Instance.new("Folder")
	Util2.SetParentOverrideWithColor(folder, _WorldOrigin, playerFromCharacter, "KitsuneFruitVFXColor")

	if data.Special then
		if not root.Parent:WaitForChild("Kitsune", 3) then
			return
		end

		local clone = kitsuneStage.Flames:Clone()

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("BasePart") then
				descendant.Transparency = 1

				if data.Tool:FindFirstChild("IsRedMutant") and data.Tool and data.Tool:FindFirstChild("IsRedMutant") and data.Tool:FindFirstChild("IsRedMutant").Value == true then
					if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == false then
						descendant.Color = Color3.fromRGB(255, 86, 35)
					else
						descendant.Color = Color3.fromRGB(81, 0, 255)
					end
				end
			end
		end

		local value = holding.Value
		local descendants = clone:GetDescendants()
		local children = clone:GetChildren()
		local changedConnection = holding.Changed:Connect(function()
			if value == holding.Value then
				return
			end

			value = holding.Value

			if holding.Value then
				Util2.Sound:Play("Passives- Flame Ember", root)
			end

			for _, instance in pairs(descendants) do
				if instance:IsA("ParticleEmitter") then
					instance.Enabled = holding.Value
				elseif instance:IsA("BasePart") then
					instance.Transparency = holding.Value and 0 or 1
				end
			end

			for _, v in pairs(children) do
				local clone2 = kitsuneStage.FlameSpawn.Attachment:Clone()
				Util2.SetParentOverrideWithColor(clone2, v, playerFromCharacter, "KitsuneFruitVFXColor", true)

				for _, child in pairs(clone2:GetChildren()) do
					Util2.EmitFix(child, child:GetAttribute("EmitCount"))
				end

				Util2.Debris:AddItem(clone2, 2)
			end
		end)
		Util2.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "KitsuneFruitVFXColor", true)
		Util2.SyncColorsOnChange(clone, playerFromCharacter, "KitsuneFruitVFXColor")
		Get(clone)
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = clone.PrimaryPart
		motor6D.Part1 = root.Parent.Kitsune.Kitsune.Body
		Util2.SetParentOverrideWithColor(motor6D, clone.PrimaryPart, playerFromCharacter, "KitsuneFruitVFXColor")
		motor6D.Part1 = makeProxyPartAtBone(
			root.Parent.Kitsune.Kitsune,
			root.Parent.Kitsune.Kitsune.RootPart.Spine["Spine.001"]["Spine.002"],
			playerFromCharacter
		)
		motor6D.C1 = CFrame.new(0, -1.5, 9.5) * CFrame.Angles(1.5707963267948966, 0, 0)
		tick()

		repeat
			task.wait(0.05)
		until not (root:IsDescendantOf(workspace) and root.Parent and root.Parent:FindFirstChild("Kitsune"))

		changedConnection:Disconnect()
		folder:Destroy()
	else
		local v = {}

		for i = 1, 3 do
			local clone = kitsuneStage.Orb:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 0, -1)
			Util2.SetParentOverrideWithColor(clone, folder, playerFromCharacter, "KitsuneFruitVFXColor", true)
			Util2.SyncColorsOnChange(clone, playerFromCharacter, "KitsuneFruitVFXColor")
			local clone2 = kitsuneStage.OrbitPart:Clone()
			Util2.SetParentOverrideWithColor(clone2, clone, playerFromCharacter, "KitsuneFruitVFXColor", true)
			Util2.SetParentOverrideWithColor(
				clone2.Attachment0,
				clone,
				playerFromCharacter,
				"KitsuneFruitVFXColor",
				true
			)
			Util2.SyncColorsOnChange(clone2, playerFromCharacter, "KitsuneFruitVFXColor")
			clone2.AlignPosition.Enabled = true
			math.random(5, 8)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = math.random(-4, 4)
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = math.random(-1, 4)
			local numberValue3 = Instance.new("NumberValue")
			numberValue3.Value = math.random(-4, 4)
			local responsiveness = math.random(10, 100)
			clone2.AlignPosition.Responsiveness = responsiveness
			clone.Anchored = false
			v[i] = {
				X = numberValue,
				Y = numberValue2,
				Z = numberValue3,
				OrbitPart = clone2,
				Orb = clone,
				RandomSwapTime = math.random(5, 30) / 10,
				SwapTime = os.clock()
			}
		end

		Util2.Sound:Play("Passives- Flame Ember", root)
		local kitsuneTail3 = true

		while true do
			for _, v2 in pairs(v) do
				v2.OrbitPart.Position = root.Position

				if os.clock() - v2.SwapTime >= v2.RandomSwapTime then
					v2.SwapTime = os.clock()
					v2.RandomSwapTime = math.random(5, 30) / 10
					TweenService:Create(v2.X, TweenInfo.new(math.random(25, 100) / 100), {
						Value = math.random(-4, 4)
					}):Play()
					TweenService:Create(v2.Y, TweenInfo.new(math.random(25, 100) / 100), {
						Value = math.random(-1, 4)
					}):Play()
					TweenService:Create(v2.Z, TweenInfo.new(math.random(25, 100) / 100), {
						Value = math.random(-4, 4)
					}):Play()
				end

				v2.OrbitPart.AlignPosition.Position = v2.OrbitPart.CFrame * CFrame.new(
					v2.X.Value,
					v2.Y.Value,
					v2.Z.Value
				).Position
			end

			RunService.Heartbeat:Wait()

			if root.Parent then
				kitsuneTail3 = root.Parent:FindFirstChild("KitsuneTail1") and root.Parent:FindFirstChild("KitsuneTail2") and root.Parent:FindFirstChild("KitsuneTail3")
			end

			if root:IsDescendantOf(workspace) and root.Parent and kitsuneTail3 then
				continue
			end

			for _, v2 in pairs(v) do
				for _, descendant in pairs(v2.Orb:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false
					elseif descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end

			task.delay(3, function()
				folder:Destroy()
			end)
			return
		end
	end
end