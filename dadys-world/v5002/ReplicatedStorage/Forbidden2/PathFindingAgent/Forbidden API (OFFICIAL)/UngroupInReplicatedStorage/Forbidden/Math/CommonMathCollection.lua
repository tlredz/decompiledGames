local createVector = vector.create
require(script.Parent)
local parent = script.Parent.Parent
local Common = require(parent.Common)
local Tables = require(parent.Libraries.Tables)
local CommonMathCollection = {
	CheckLoSByProvidedLimits = function(p, p2, list, options)
		if p == nil then
			error("FromCharacter was nil!")
		end

		if p2 == nil then
			error("TargetParent was nil!")
		end

		if list == nil then
			error("TargetParts was nil!")
		end

		if typeof(list) ~= "table" then
			error("TargetParts is not a table.")
		end

		if #list < 1 then
			error("No target parts!")
		end

		local v = options or {}
		v.OriginPart = options.OriginPart or nil
		v.Range = options.Range or 100
		v.SeeThroughTransparentParts = options.SeeThroughTransparentParts or false
		v.SeeThroughNonCollidable = options.SeeThroughNonCollidable or false
		v.MinimumTransparency = options.MinimumTransparency or 0.001
		v.FilterTable = options.FilterTable or { p }
		v.FilterAttempts = options.FilterAttempts or 10
		v.OffsetFromOrigin = options.OffsetFromOrigin or createVector(0, 0, 0)
		v.OffsetFromTarget = options.OffsetFromTarget or createVector(0, 0, 0)
		v.OutputCollision = options.OutputCollision or false
		v.FilterFunction = options.FilterFunction or function()
			return false
		end

		local function RaycastForTargetPart(p3)
			local originPart = v.OriginPart

			if originPart == nil then
				originPart = Common.GetBasePart(p)
			end

			local v2 = originPart.CFrame.Position + v.OffsetFromOrigin
			local v3 = p3.CFrame.Position + v.OffsetFromTarget

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
				local function isFiltered(p4)
					if v.SeeThroughTransparentParts and p4.Transparency >= v.MinimumTransparency or v.SeeThroughNonCollidable and not p4.CanCollide or v.FilterFunction(p4) then
						return true
					end

					return false
				end

				local function isDescendantOfTarget(parent2, p4)
					if parent2 == p4 then
						return true
					end

					for _ = 1, 5 do
						if parent2.Parent == nil then
							return false
						end

						parent2 = parent2.Parent

						if parent2 == p4 then
							return true
						end
					end

					return false
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function doRaycast()
					return workspace:Raycast(v2, unit * v.Range, raycastParams)
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

					if isDescendantOfTarget(v4.Instance, p2) then
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

		for _, v2 in pairs(list) do
			if RaycastForTargetPart(v2) then
				return true
			end
		end

		return false
	end
}

function CommonMathCollection.CheckLoSByAutomaticLimits(p, instance, p2)
	local children = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SearchAndAdd(childName: string)
		local child = instance:FindFirstChild(childName)

		if not child then
			return
		end

		table.insert(children, child)
	end

	SearchAndAdd("RightLowerArm") -- equivalent call inferred; original call site unknown
	SearchAndAdd("LeftLowerArm") -- equivalent call inferred; original call site unknown
	SearchAndAdd("Head") -- equivalent call inferred; original call site unknown
	SearchAndAdd("HumanoidRootPart") -- equivalent call inferred; original call site unknown
	SearchAndAdd("Right Arm") -- equivalent call inferred; original call site unknown
	SearchAndAdd("Left Arm") -- equivalent call inferred; original call site unknown
	return CommonMathCollection.CheckLoSByProvidedLimits(p, instance, children, p2)
end

return CommonMathCollection