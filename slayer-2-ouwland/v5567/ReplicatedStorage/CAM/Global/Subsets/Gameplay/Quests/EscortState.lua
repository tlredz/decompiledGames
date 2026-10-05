local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function visibleToMe(escortInfo)
	local visibleTo = escortInfo:GetAttribute("VisibleTo")

	if visibleTo == nil then
		return true
	end

	if type(visibleTo) ~= "string" then
		return false
	end

	local userId = tostring(Players.LocalPlayer.UserId)

	for _, v in string.split(visibleTo, ",") do
		if v == userId then
			return true
		end
	end

	return false
end

local function findRunFolder(p: string)
	local humanoids = workspace:FindFirstChild("Humanoids")

	if humanoids == nil then
		return nil
	end

	for _, child in humanoids:GetChildren() do
		if child.Name ~= `Escort - {p}` then
			continue
		end

		local escortInfo = child:FindFirstChild("EscortInfo")

		if not (escortInfo ~= nil and visibleToMe(escortInfo)) then
			continue
		end

		local model = child:FindFirstChildOfClass("Model")

		if model ~= nil then
			return child, model
		end
	end

	return nil
end

return {
	forQuest = function(p: string)
		return {
			Do = function(_, _, maid)
				local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
				local formatted = `EscortMarker-{p}`
				local flag = true
				maid:Add(function()
					flag = false
					MarkerHandler.removeMarker(formatted)
				end)
				task.spawn(function()
					local v = nil
					local v2 = nil

					while flag do
						v, v2 = findRunFolder(p)

						if v ~= nil then
							break
						end

						task.wait(0.5)
					end

					if not flag or v == nil or v2 == nil then
						return
					end

					local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart == nil then
						return
					end

					MarkerHandler.addMarker(formatted, {
						markerType = MarkerHandler.markerType.Both,
						offScreenMode = MarkerHandler.offScreenMode.Compass,
						img = v:GetAttribute("Icon"),
						transparency = 0.25,
						position = humanoidRootPart,
						offset = createVector(0, 3, 0),
						minDistance = 8,
						margin = 15
					})
					maid:Add(v.Destroying:Connect(function()
						MarkerHandler.removeMarker(formatted)
					end))
				end)
			end
		}
	end
}