local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p)
	return p * p * (3 - 2 * p)
end

local function setupTwomp(instance)
	local triggerPart = instance:WaitForChild("TriggerPart", 10)
	local movement = instance:WaitForChild("Movement", 10)

	if not (triggerPart and movement) then
		warn("Twomp (Client): TriggerPart ou Movement introuvable dans", instance.Name)
		return
	end

	local _, v = movement:GetBoundingBox()
	local pivot = movement:GetPivot()
	local v2 = triggerPart.Position.Y - triggerPart.Size.Y / 2
	local v3 = pivot + Vector3.new(0, -(pivot.Position.Y - v2) + v.Y / 2, 0)
	local flag = false

	local function animateTo(pivot2, cframe, p, fn)
		local total = 0
		local v4 = math.abs((pivot2.Position - cframe.Position).Y) / p

		if v4 <= 0 then
			movement:PivotTo(cframe)
			fn()
		else
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += dt
				local v5 = math.min(total / v4, 1)
				movement:PivotTo(pivot2:Lerp(cframe, smoothstep(v5)))

				if v5 >= 1 then
					renderSteppedConnection:Disconnect()
					fn()
				end
			end)
		end
	end

	local touchedConnection = triggerPart.Touched:Connect(function(otherPart)
		if flag or not localPlayer.Character or not otherPart:IsDescendantOf(localPlayer.Character) then
			return
		end

		flag = true

		if triggerPart:FindFirstChild("Sound") then
			triggerPart.Sound:Play()
		end

		animateTo(movement:GetPivot(), v3, 88, function()
			movement:PivotTo(v3)
			task.wait(0.4)
			animateTo(movement:GetPivot(), pivot, 5, function()
				movement:PivotTo(pivot)
				flag = false
			end)
		end)
	end)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			touchedConnection:Disconnect()
			ancestryChangedConnection:Disconnect()
		end
	end)
end

for _, v in ipairs(CollectionService:GetTagged("Twomp")) do
	task.spawn(setupTwomp, v)
end

CollectionService:GetInstanceAddedSignal("Twomp"):Connect(function(p)
	task.spawn(setupTwomp, p)
end)