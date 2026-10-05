local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
return {
	Start = function()
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = 1
		local count = 0
		local flag = false
		local v6 = 0
		local v7 = 1
		local lastTime = os.clock()

		local function getTargetColor(part)
			if part:IsA("BasePart") then
			end

			return part.Color
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTargetColor(part, color: Color3)
			if part:IsA("BasePart") then
			end

			part.Color = color
		end

		local function getOriginalHsv(part)
			local originalColor = part:GetAttribute("OriginalColor")

			if typeof(originalColor) == "Vector3" then
				return originalColor
			end

			if part:IsA("BasePart") then
			end

			local v8, v9, v10 = Color3.toHSV(part.Color)
			local vector = Vector3.new(v8, v9, v10)
			part:SetAttribute("OriginalColor", vector)
			return vector
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addTarget(part)
			if v3[part] ~= nil then
				return
			end

			if typeof((part:GetAttribute("OriginalColor"))) ~= "Vector3" then
				if part:IsA("BasePart") then
				end

				local v8, v9, v10 = Color3.toHSV(part.Color)
				part:SetAttribute("OriginalColor", (Vector3.new(v8, v9, v10)))
			end

			table.insert(v2, part)
			v3[part] = #v2
		end

		local function removeTarget(target)
			local v8 = v3[target]

			if v8 == nil then
				v:AtWarning():Log((`Rainbow target {target:GetFullName()} not found in active targets.`))
				return
			end

			local originalColor = target:GetAttribute("OriginalColor")

			if typeof(originalColor) == "Vector3" then
				setTargetColor(target, Color3.fromHSV(originalColor.X, originalColor.Y, originalColor.Z)) -- equivalent call inferred; original call site unknown
			end

			local v10 = v2[#v2]
			v2[v8] = v10
			v3[v10] = v8
			table.remove(v2)
			v3[target] = nil

			if v7 > #v2 then
				v7 = 1
			end
		end

		local function drainQueue()
			while v5 <= count do
				local v8 = v4[v5]
				v5 += 1

				if v8.Add then
					addTarget(v8.Target) -- equivalent call inferred; original call site unknown
				else
					removeTarget(v8.Target)
				end
			end

			table.clear(v4)
			v5 = 1
			count = 0
			flag = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function enqueue(target, flag2: boolean)
			count += 1
			v4[count] = {
				Target = target,
				Add = flag2
			}

			if flag then
				return
			end

			flag = true
			task.defer(drainQueue)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requireRainbowTarget(instance)
			assert(
				instance:IsA("BasePart") or instance:IsA("SurfaceAppearance"),
				(`RainbowPart tag requires a BasePart or SurfaceAppearance, got {instance.ClassName}`)
			)
			return instance
		end

		local function preRender(p: number)
			v6 = math.min(v6 + math.min(p, 0.06666666666666667), 0.25)

			if v6 < 0.05 then
				return
			end

			v6 -= 0.05
			local count2 = #v2

			if count2 == 0 then
				return
			end

			debug.profilebegin("WorkspaceRainbowParts :: PreRender")
			local v8 = (os.clock() - lastTime) * 0.5 % 1
			local v9 = math.min(v7 + 50 - 1, count2)

			for i = v7, v9 do
				local part = v2[i]

				if part.Parent == nil then
					continue
				end

				local originalColor = part:GetAttribute("OriginalColor")

				if typeof(originalColor) ~= "Vector3" then
					if part:IsA("BasePart") then
					end

					local v10, v11, v12 = Color3.toHSV(part.Color)
					originalColor = Vector3.new(v10, v11, v12)
					part:SetAttribute("OriginalColor", originalColor)
				end

				local Y = originalColor.Y
				local Z = originalColor.Z

				if Y <= 0.05 then
					Y = 1

					if Z >= 0.9725490196078431 then
						Z = 1
					end
				end

				setTargetColor(part, Color3.fromHSV(v8, Y, Z)) -- equivalent call inferred; original call site unknown
			end

			v7 = v9 + 1

			if count2 < v7 then
				v7 = 1
			end

			debug.profileend()
		end

		CollectionService:GetInstanceAddedSignal("RainbowPart"):Connect(function(instance)
			if instance:IsDescendantOf(ReplicatedStorage) then
				return
			end

			enqueue(requireRainbowTarget(instance), true) -- equivalent call inferred; original call site unknown
		end)
		CollectionService:GetInstanceRemovedSignal("RainbowPart"):Connect(function(instance)
			if instance:IsDescendantOf(ReplicatedStorage) then
				return
			end

			enqueue(requireRainbowTarget(instance), false) -- equivalent call inferred; original call site unknown
		end)

		for _, part in CollectionService:GetTagged("RainbowPart") do
			if part:IsDescendantOf(ReplicatedStorage) or v3[requireRainbowTarget(part)] ~= nil then
				continue
			end

			if typeof((part:GetAttribute("OriginalColor"))) ~= "Vector3" then
				if part:IsA("BasePart") then
				end

				local v8, v9, v10 = Color3.toHSV(part.Color)
				part:SetAttribute("OriginalColor", (Vector3.new(v8, v9, v10)))
			end

			table.insert(v2, part)
			v3[part] = #v2
		end

		RunService.PreRender:Connect(preRender)
	end
}