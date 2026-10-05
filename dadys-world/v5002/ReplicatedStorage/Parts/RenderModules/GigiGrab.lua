local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.SharedUtils.Signal)

local function runAction(folder, instance, fn, p, quad, p2, p3)
	local lastTime = tick()
	local renderSteppedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = (tick() - lastTime) / p
		local value = TweenService:GetValue(math.clamp(v, 0, 1), quad, p2)

		if folder and folder.Parent and instance and instance.Parent and not (v >= 1) then
			fn(value)
			return
		end

		disconnect() -- equivalent call inferred; original call site unknown
	end)

	if p3 then
		repeat
			RunService.RenderStepped:Wait()
		until renderSteppedConnection == nil
	end
end

local function boneStretchGrab(folder, instance)
	local v = nil
	local v2 = nil

	for _, bone in ipairs(folder:GetDescendants()) do
		if not bone:IsA("Bone") then
			continue
		end

		if bone.Name == "Hand.C" then
			v = bone
		elseif bone.Name == "Gachapon" then
			v2 = bone
		end
	end

	local parent = v and v.Parent

	if not (v and parent and parent:IsA("Bone")) then
		return false
	end

	local cFrame = v.CFrame
	local transformedWorldCFrame = v.TransformedWorldCFrame
	local cFrame2 = v2 and v2.CFrame
	local grabArm_Geo = folder:FindFirstChild("GrabArm_Geo")
	local transparency

	if grabArm_Geo then
		transparency = grabArm_Geo.Transparency or nil
	else
		transparency = nil
	end

	if grabArm_Geo then
		grabArm_Geo.Transparency = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reset()
		if v and v.Parent then
			v.CFrame = cFrame
		end

		if v2 and v2.Parent and cFrame2 then
			v2.CFrame = cFrame2
		end

		if grabArm_Geo and grabArm_Geo.Parent and transparency then
			grabArm_Geo.Transparency = transparency
		end
	end

	runAction(folder, instance, function(p)
		local position = instance:GetPivot().Position
		local unit = (position - transformedWorldCFrame.Position).Unit

		if unit ~= unit then
			return
		end

		local lerped = transformedWorldCFrame:Lerp(CFrame.new(position, position + unit), p)
		v.WorldCFrame = lerped * v.Transform:Inverse()

		if v2 then
			v2.WorldCFrame = lerped * v2.Transform:Inverse()
		end
	end, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, true)

	if folder and folder.Parent then
		local transformedWorldCFrame2 = v.TransformedWorldCFrame
		runAction(folder, instance, function(p)
			local lerped = transformedWorldCFrame2:Lerp(parent.TransformedWorldCFrame * cFrame, p)
			v.WorldCFrame = lerped * v.Transform:Inverse()

			if v2 then
				v2.WorldCFrame = lerped * v2.Transform:Inverse()
			end
		end, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, true)
		reset() -- equivalent call inferred; original call site unknown
		return true
	else
		reset() -- equivalent call inferred; original call site unknown
		return true
	end
end

local function legacyRopeGrab(instance, instance2)
	local clone = game.ReplicatedStorage.Parts.MonsterGigiGrab:Clone()
	local handSourceAttachment = instance:FindFirstChild("HandSourceAttachment")

	if not (handSourceAttachment and handSourceAttachment:IsA("ObjectValue") and handSourceAttachment.Value) then
		clone:Destroy()
		return
	end

	local attachment = handSourceAttachment.Value
	clone.Parent = workspace
	clone.PrimaryPart.CFrame = instance.PrimaryPart.CFrame
	clone.Base.RopeConstraint.Attachment0 = attachment
	Debris:AddItem(clone, 2)

	local function betterRenderLoop(primaryPart, clone2, primaryPart2, p, quad, out, p2, p3)
		local renderSteppedConnection = nil
		local v = Signal.new()
		local pivot = primaryPart:GetPivot()
		local v2 = primaryPart2

		if v2 then
			v2 = primaryPart2.Parent and CFrame.new(primaryPart2:GetPivot().Position, pivot.Position) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
		end

		if not v2 then
			return
		end

		local function update(p4)
			if p3 then
				p4 = 1 - p4
			end

			local value2 = TweenService:GetValue(p4, quad, out)

			if primaryPart2 and primaryPart2.Parent then
				v2 = CFrame.new(primaryPart2:GetPivot().Position, pivot.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			end

			if primaryPart and primaryPart.Parent then
				pivot = primaryPart:GetPivot()
			end

			if clone2 and clone2.Parent then
				clone2:PivotTo(pivot:Lerp(v2, value2))
			end
		end

		local lastTime = tick()
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v3 = math.clamp((tick() - lastTime) / p, 0, 1)

			if (v3 >= 1 or not (clone2 and clone2.Parent)) and renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil

				if v then
					v:Fire()
				end
			end

			if clone2 and clone2.Parent then
				update(v3)
			end
		end)
		v:Connect(function()
			v:Destroy()
			v = nil
		end)

		if p2 and v then
			v:Wait()
		else
			return v
		end
	end

	betterRenderLoop(
		instance.PrimaryPart,
		clone,
		instance2.PrimaryPart,
		0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		true,
		false
	)
	local v = betterRenderLoop(
		instance.PrimaryPart,
		clone,
		instance2.PrimaryPart,
		0.75,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		false,
		true
	)

	if v then
		v:Connect(function()
			if clone then
				clone:Destroy()
				clone = nil
			end
		end)
	else
		clone:Destroy()
	end
end

return {
	RenderObject = function(list)
		local v = list[1]
		local v2 = list[2]

		if not (v and v.Parent and v.PrimaryPart) then
			return
		end

		if v2 and v2.Parent and v2.PrimaryPart and not boneStretchGrab(v, v2) then
			legacyRopeGrab(v, v2)
		end
	end
}