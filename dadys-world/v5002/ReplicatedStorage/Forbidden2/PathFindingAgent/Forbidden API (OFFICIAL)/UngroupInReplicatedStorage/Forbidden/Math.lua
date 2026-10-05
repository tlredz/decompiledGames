local createVector = vector.create
local parent = script.Parent
local _ = script.Parent
require(script.MathVisualization)
local Common = require(parent.Common)
local Tables = require(parent.Libraries.Tables)
local Math = {
	LineOfSight = function(p, instance, options)
		if p == nil then
			error("Object1 was nil!")
		end

		if instance == nil then
			error("Object2 was nil!")
		end

		local v = options or {}
		v.OriginPart = v.OriginPart or nil
		v.Range = v.Range or 100
		v.SeeThroughTransparentParts = v.SeeThroughTransparentParts or false
		v.SeeThroughNonCollidable = v.SeeThroughNonCollidable or false
		v.MinimumTransparency = v.MinimumTransparency or 0.001
		v.FilterTable = v.FilterTable or { p }
		v.FilterAttempts = v.FilterAttempts or 10
		v.OffsetFromOrigin = v.OffsetFromOrigin or createVector(0, 0, 0)
		v.OffsetFromTarget = v.OffsetFromTarget or createVector(0, 0, 0)
		v.OutputCollision = v.OutputCollision or false
		v.FilterFunction = v.FilterFunction or function()
			return false
		end
		local originPart = v.OriginPart

		if originPart == nil then
			originPart = Common.GetBasePart(p)
		end

		local character = Common.GetBasePart(instance)
		local v2 = originPart.CFrame.Position + v.OffsetFromOrigin
		local v3 = character.CFrame.Position + v.OffsetFromTarget

		if (v3 - v2).Magnitude > v.Range then
			if v.OutputCollision then
				print("Out of range!")
			end

			return false
		else
			local unit = (v3 - v2).Unit
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Tables.DeepCopy(v.FilterTable)
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.CollisionGroup = originPart.CollisionGroup

			-- equivalent calls inferred from this helper; original call sites unknown
			local function isFiltered(p2)
				if v.SeeThroughTransparentParts and p2.Transparency >= v.MinimumTransparency or v.SeeThroughNonCollidable and not p2.CanCollide or v.FilterFunction(p2) then
					return true
				end

				return false
			end

			local function isDescendantOfTarget(parent2, character2)
				if parent2 == character2 then
					return true
				end

				for _ = 1, 5 do
					if parent2.Parent == nil then
						return false
					end

					parent2 = parent2.Parent

					if parent2 == character2 then
						return true
					end
				end

				return false
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function doRaycast()
				return workspace:Raycast(v2, unit * v.Range, raycastParams)
			end

			if typeof(instance) == "Instance" then
				if instance:IsA("Model") or instance:IsA("BasePart") then
					character = instance
				end

				if instance:IsA("Player") then
					character = instance.Character
				end
			end

			for _ = 1, v.FilterAttempts do
				local v4 = doRaycast() -- equivalent call inferred; original call site unknown

				if v4 == nil or v4.Instance == nil then
					return false
				end

				if v.OutputCollision then
					print(v4.Instance)
				end

				if not (v4.Instance:IsA("BasePart") or v4.Instance:IsA("Model")) then
					return false
				end

				if isDescendantOfTarget(v4.Instance, character) then
					return true
				end

				if isFiltered(v4.Instance) then
					raycastParams:AddToFilter(v4.Instance)
				else
					return false
				end
			end

			return false
		end
	end
}

function Math.IsOnScreen(model, flag: boolean)
	if model == nil then
		error("[Forbidden.Math.InPlayerView] PartToCheck was nil!")
	end

	local v = true
	local localPlayer = game.Players.LocalPlayer
	local currentCamera = game.Workspace.CurrentCamera
	local v2

	if model:IsA("Model") and model.PrimaryPart ~= nil then
		v2 = model.PrimaryPart
	else
		v2 = model
	end

	local _, v3 = currentCamera:WorldToViewportPoint(v2.Position)

	if flag then
		local v4 = {
			Range = 100,
			SeeThroughTransparentParts = true,
			FilterTable = { localPlayer.Character }
		}
		v = Math.LineOfSight(localPlayer.Character, model, v4)
	end

	if v3 and v then
		return true
	end

	return false
end

function Math.IsInView(instance, p, p2: number, flag: boolean, p3)
	if instance == nil then
		error("[Forbidden.Math.InPlayerView] FromCharacter was nil!")
	end

	if p == nil then
		error("[Forbidden.Math.InPlayerView] TargetOther was nil!")
	end

	local v = p2 == nil and 70 or p2

	if flag == nil then
		flag = false
	end

	local v2 = v < 0 and 0 or v
	local v3 = v2 > 180 and 180 or v2
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local basePart = Common.GetBasePart(p)

	if humanoidRootPart == nil then
		error("[Forbidden.Math.InPlayerView] The NPC provided does not contain a HumanoidRootPart!")
	end

	if basePart == nil then
		error("[Forbidden.Math.InPlayerView] The Target provided does not contain a BasePart!")
	end

	local v4 = p3 == nil and {} or p3

	if v4.FilterTable == nil then
		v4.FilterTable = { instance }
	end

	if flag and not Math.LineOfSight(humanoidRootPart, p, v4) then
		return false
	end

	return math.acos((humanoidRootPart.CFrame.LookVector:Dot((basePart.CFrame.Position - humanoidRootPart.CFrame.Position).Unit))) < v3 * 0.017453292519943295
end

return Math