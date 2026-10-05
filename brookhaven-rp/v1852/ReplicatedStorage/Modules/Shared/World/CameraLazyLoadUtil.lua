local CameraLazyLoadUtil = {
	BUFFER_RADIUS = 3,
	OBJECT_VALUE_NAME = "LazyLoadRegion",
	LAZY_LOAD_MODEL_TAG = "LazyLoadModel",
	SET_FORCED_CAMERA_LAZY_LOAD = "SetForcedCameraLazyLoad",
	SET_FREECAM_LAZY_LOAD = "SetFreecamLazyLoadPosition",
	FREECAM_SEND_INTERVAL = 0.5,
	FREECAM_DEBOUNCE_SECONDS = 0.5,
	SOURCE_CITY = "city",
	SOURCE_HOUSE = "house",
	SOURCE_NONE = "none",
	CITY_CAMS_SEAT_TAG = "CityCamsSeat",
	DEFAULT_CITY_CAMS_FOLDER_NAME = "001_SecurityCamsCriminalPolice",
	getMinCityCamIndex = function(instance)
		if instance:GetAttribute("SkipCrimCams") == true or instance:GetAttribute("SkipFirstCam") == true then
			return 2
		end

		return 1
	end,
	collectSortedCityCamParts = function(instance)
		local parts = {}

		for _, part in instance:GetChildren() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end

		table.sort(parts, function(a, b)
			local v = tonumber(a.Name:match("%d+"))
			local v2 = tonumber(b.Name:match("%d+"))

			if v == nil or v2 == nil or v == v2 then
				return a.Name < b.Name
			end

			return v < v2
		end)
		return parts
	end
}

function CameraLazyLoadUtil.getCityCamsFolderFromSeat(instance)
	local camerasFolder = instance:FindFirstChild("CamerasFolder")

	if camerasFolder ~= nil and camerasFolder:IsA("ObjectValue") then
		local value = camerasFolder.Value

		if value ~= nil and value:IsA("Folder") then
			return value
		end
	end

	local workspaceCom = workspace:FindFirstChild("WorkspaceCom")

	if workspaceCom == nil then
		return nil
	end

	local folder = workspaceCom:FindFirstChild(CameraLazyLoadUtil.DEFAULT_CITY_CAMS_FOLDER_NAME)

	if folder == nil or folder:IsA("Folder") ~= true then
		return nil
	end

	return folder
end

function CameraLazyLoadUtil.getWindowIndices(p: number, p2: number, p3: number, p4: number)
	local v = p3 - p2 + 1

	if v <= 0 or p4 < 0 then
		return {}
	end

	local v2 = {}
	local result = {}

	for i = -p4, p4 do
		local v3 = (p - p2 + i) % v

		if v3 < 0 then
			v3 += v
		end

		local v4 = p2 + v3

		if v2[v4] == true then
			continue
		end

		v2[v4] = true
		table.insert(result, v4)
	end

	return result
end

function CameraLazyLoadUtil.getCameraPartsInWindow(p, p2: number, p3: number, p4: number, p5: number)
	local result = {}

	for _, v in CameraLazyLoadUtil.getWindowIndices(p2, p3, p4, p5) do
		local v2 = p[v]

		if v2 ~= nil then
			table.insert(result, v2)
		end
	end

	return result
end

function CameraLazyLoadUtil.getModelsFromCamera(instance)
	local result = {}

	for _, objectValue in instance:GetChildren() do
		if not (objectValue.Name == CameraLazyLoadUtil.OBJECT_VALUE_NAME and objectValue:IsA("ObjectValue")) then
			continue
		end

		local value = objectValue.Value

		if value ~= nil and value:HasTag(CameraLazyLoadUtil.LAZY_LOAD_MODEL_TAG) then
			table.insert(result, value)
		end
	end

	return result
end

return CameraLazyLoadUtil