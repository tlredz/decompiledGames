local RunService = game:GetService("RunService")
local tostring2 = tostring
local Util = require(script.Parent.Parent:WaitForChild("Util"))
local _ = math.deg
local currentCamera = workspace.CurrentCamera
return function(instance, data, p)
	if instance == nil then
		return
	end

	local v = p == nil and {} or p

	if data == nil then
		return
	end

	if v.Size_Mult == nil then
		v.Size_Mult = 1
	end

	if v.Part_Size_Z == nil then
		v.Part_Size_Z = 1
	end

	if v.ZOffset == nil then
		v.ZOffset = 0.15
	end

	local v2 = math.random(1, 9999)
	local v3 = instance.Name .. tostring2(v2)
	local v4 = false
	local connection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Delete()
		if v4 == false then
			v4 = true

			if instance ~= nil then
				instance:Destroy()
				instance = nil
			end

			RunService:UnbindFromRenderStep(v3)

			if connection ~= nil then
				connection:Disconnect()
				connection = nil
			end
		end
	end

	local absoluteSize = nil

	local function upd_part()
		if data == nil or not currentCamera:FindFirstChild("camera_part_anchor_ui") or instance == nil or not instance:IsDescendantOf(currentCamera.camera_part_anchor_ui) then
			Delete() -- equivalent call inferred; original call site unknown
		else
			math.rad(data.Rotation)
			local vector = Vector2.new(data.AbsoluteSize.X, data.AbsoluteSize.Y)
			local vector2 = Vector2.new(data.AbsolutePosition.X, data.AbsolutePosition.Y)
			local vector3 = Vector2.new(vector2.X + vector.X / 2, vector2.Y + vector.Y / 2)
			local v5 = vector3 - vector / 2
			local v6 = vector3 + Vector2.new(vector.X / 2, -vector.Y / 2)
			local v7 = vector3 + Vector2.new(-vector.X / 2, vector.Y / 2)
			local v8 = vector3 + vector / 2
			local convertTo3D = Util:ConvertTo3D(v5, v.ZOffset, data.Rotation)
			local convertTo3D2 = Util:ConvertTo3D(v6, v.ZOffset, data.Rotation)
			local convertTo3D3 = Util:ConvertTo3D(v7, v.ZOffset, data.Rotation)
			local convertTo3D4 = Util:ConvertTo3D(v8, v.ZOffset, data.Rotation)
			local magnitude = (convertTo3D2 - convertTo3D).Magnitude
			local magnitude2 = (convertTo3D - convertTo3D3).Magnitude
			instance.CFrame = CFrame.new(convertTo3D) * workspace.CurrentCamera.CFrame.Rotation * CFrame.new(
				magnitude / 2,
				-magnitude2 / 2,
				v.PositionZOffset or 0
			)

			if absoluteSize ~= data.AbsoluteSize then
				if v.CFOffset then
					instance.CFrame *= v.CFOffset
				end

				local vector4 = Vector3.new((convertTo3D3 - convertTo3D4).Magnitude, magnitude2, v.Part_Size_Z)
				local v9 = vector4 / instance.Size

				for _, attachment in pairs(instance:GetChildren()) do
					if attachment:IsA("Attachment") then
						attachment.Position *= v9
					end
				end

				instance.Size = vector4
				absoluteSize = data.AbsoluteSize
			end
		end
	end

	RunService:UnbindFromRenderStep(v3)
	connection = RunService:BindToRenderStep(v3, Enum.RenderPriority.Character.Value, upd_part)

	if v.Duration ~= nil then
		task.delay(v.Duration, function()
			Delete() -- equivalent call inferred; original call site unknown
		end)
	end

	instance.Parent = currentCamera.camera_part_anchor_ui
	return instance
end