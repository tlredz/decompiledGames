local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}

local function waitForDescendant(instance, childName)
	local child = instance:FindFirstChild(childName, true)

	while not child and instance.Parent do
		task.wait(0.1)
		child = instance:FindFirstChild(childName, true)
	end

	return child
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p)
	return p * p * (3 - 2 * p)
end

local function setupTwomp(instance)
	if v[instance] or v2[instance] then
		return
	end

	v2[instance] = true
	local part = waitForDescendant(instance, "TriggerPart")
	local model = waitForDescendant(instance, "Movement")

	if part and part:IsA("BasePart") and model and model:IsA("Model") then
		v[instance] = true
		v2[instance] = nil
		local _, v3 = model:GetBoundingBox()
		local pivot = model:GetPivot()
		local v4 = part.Position.Y - part.Size.Y / 2
		local v5 = pivot + Vector3.new(0, -(pivot.Position.Y - v4) + v3.Y / 2, 0)
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function killLocalPlayer()
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end

		local function isLocalPlayerInsideTrigger()
			local character = localPlayer.Character

			if not character then
				return false
			end

			for _, v6 in workspace:GetPartsInPart(part) do
				if v6:IsDescendantOf(character) then
					return true
				end
			end

			return false
		end

		local function animateTo(pivot2, cframe, p, fn)
			local total = 0
			local v6 = math.abs((pivot2.Position - cframe.Position).Y) / p

			if v6 <= 0 then
				model:PivotTo(cframe)
				fn()
			else
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					total += dt
					local v7 = math.min(total / v6, 1)
					model:PivotTo(pivot2:Lerp(cframe, smoothstep(v7)))

					if v7 >= 1 then
						renderSteppedConnection:Disconnect()
						fn()
					end
				end)
			end
		end

		local touchedConnection = part.Touched:Connect(function(otherPart)
			if flag or not localPlayer.Character or not otherPart:IsDescendantOf(localPlayer.Character) then
				return
			end

			flag = true
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.WalkSpeed < 50 then
				killLocalPlayer() -- equivalent call inferred; original call site unknown
			end

			if part:FindFirstChild("Sound") then
				part.Sound:Play()
			end

			animateTo(model:GetPivot(), v5, 75, function()
				model:PivotTo(v5)

				if isLocalPlayerInsideTrigger() then
					killLocalPlayer() -- equivalent call inferred; original call site unknown
				end

				task.wait(0.4)
				animateTo(model:GetPivot(), pivot, 25, function()
					model:PivotTo(pivot)
					flag = false
				end)
			end)
		end)
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				touchedConnection:Disconnect()
				ancestryChangedConnection:Disconnect()
				v[instance] = nil
				v2[instance] = nil
			end
		end)
	else
		v2[instance] = nil
		warn("Twomp (Client): TriggerPart ou Movement introuvable dans", instance.Name)
	end
end

for _, v3 in ipairs(CollectionService:GetTagged("W4Twomp")) do
	task.spawn(setupTwomp, v3)
end

CollectionService:GetInstanceAddedSignal("W4Twomp"):Connect(function(p)
	task.spawn(setupTwomp, p)
end)