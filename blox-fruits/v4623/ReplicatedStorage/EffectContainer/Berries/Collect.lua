local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local debris = Util.Debris
local maid = Util.Maid
local berries = ReplicatedStorage:WaitForChild("Assets").Models.Berries
local BerryVisualData = require(script.BerryVisualData)
local variants = BerryVisualData.Variants
local animations = BerryVisualData.Animations
return function(data)
	local index = data.Index
	local berryName = data.BerryName
	local travelTime = data.TravelTime or 1
	local startPosition = data.StartPosition
	local goal = data.Goal

	if (workspace.CurrentCamera.CFrame.Position - startPosition).Magnitude > 1000 then
		return
	end

	local v

	if berryName then
		v = BerryVisualData.indexFromName(berryName)
	else
		v = index or 1
	end

	local animationIndex = data.AnimationIndex or variants[v].AnimationIndex

	if goal ~= nil then
		local variant = variants[v]
		local maid2 = maid.new()
		local v2 = { variant.Colors.Primary, variant.Colors.Secondary, variant.Colors.Tertiary }
		local clone = script.Models._Base:Clone()
		debris:AddItem(clone, travelTime + 5)
		clone.Color = v2[1]
		local v3 = berries:FindFirstChild(variant.Name .. " Berry") or variant.Model
		local parent

		if v3 == nil then
			parent = Instance.new("Model")
		else
			parent = v3:Clone()
		end

		debris:AddItem(parent, travelTime + 5)
		clone.Parent = parent

		if parent.PrimaryPart == nil then
			parent.PrimaryPart = clone
		else
			clone.Transparency = 1
			clone.CFrame = parent.PrimaryPart.CFrame
		end

		for _, v5 in ipairs({ "Pick", "Idle", "Touch" }) do
			local children = (variant[v5] or script.BerryVisualData[v5].Default):GetChildren()

			for _, v6 in ipairs(children) do
				local clone_2 = v6:Clone()
				clone_2.Parent = clone[v5]
			end
		end

		local descendants = parent:GetDescendants()

		for _, effect in ipairs(descendants) do
			if not effect:GetAttribute("_Recolorable") then
				continue
			end

			local _Recolorable = effect:GetAttribute("_Recolorable")

			if effect:IsA("ParticleEmitter") then
				effect.Color = ColorSequence.new(v2[_Recolorable])
			elseif effect:IsA("Trail") then
				effect.Color = ColorSequence.new(v2[1], v2[3])
			end
		end

		maid2:GiveTask(parent)
		parent:PivotTo(CFrame.new(startPosition))
		parent.Parent = _WorldOrigin
		local children = clone.Pick:GetChildren()
		sound:Play("Berries.Collect." .. variant.Name, parent.PrimaryPart)

		for _, v5 in ipairs(children) do
			v5:Emit(v5:GetAttribute("EmitCount") or 1)
		end

		(typeof(animations[animationIndex]) == "function" and animations[animationIndex] or animations[1])(
			parent,
			startPosition,
			goal,
			travelTime
		)
		sound:Play("Berries.Collect.Default", goal)

		if parent then
			local children2 = clone.Touch:GetChildren()

			for _, v5 in ipairs(children2) do
				v5:Emit(v5:GetAttribute("EmitCount") or 1)
			end

			for _, instance in ipairs(descendants) do
				if instance:IsA("BasePart") then
					instance.Transparency = 1
				elseif instance:IsA("ParticleEmitter") or instance:IsA("Light") or instance:IsA("Beam") then
					instance.Enabled = false
				end
			end
		end

		task.wait(2)
		maid2:DoCleaning()
	end
end