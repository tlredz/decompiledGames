local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ABRoslitOnlyController = {}

function ABRoslitOnlyController.Start(_)
	local flag = false

	local function onAttribute()
		if flag or not localPlayer:GetAttribute("NewUserOnlyRoslitPOIExperiment") then
			return
		end

		flag = true
		return ABRoslitOnlyController._Effect()
	end

	if localPlayer:GetAttribute("NewUserOnlyRoslitPOIExperiment") ~= nil then
		return onAttribute()
	end

	local newUserOnlyRoslitPOIExperimentChangedConnection = localPlayer:GetAttributeChangedSignal("NewUserOnlyRoslitPOIExperiment"):Once(onAttribute)

	local function onAnalyticsTimeoutCheck()
		if newUserOnlyRoslitPOIExperimentChangedConnection then
			newUserOnlyRoslitPOIExperimentChangedConnection:Disconnect()
			newUserOnlyRoslitPOIExperimentChangedConnection = nil
		end
	end

	task.delay(15, onAnalyticsTimeoutCheck)
end

function ABRoslitOnlyController._Effect()
	local active = Workspace:WaitForChild("active")
	local oceanPOIs = active and active:WaitForChild("OceanPOI's")

	if not oceanPOIs then
		return
	end

	local function onPOIStreamIn(folder)
		if not (game.PlaceId ~= 131716211654599 and folder.Name ~= "Roslit Bay") then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function handleDescendant(billboardGui)
			if billboardGui.Name == "POIHeader" and billboardGui:IsA("BillboardGui") then
				billboardGui:Destroy()
			end
		end

		for _, descendant in folder:GetDescendants() do
			handleDescendant(descendant) -- equivalent call inferred; original call site unknown
		end

		folder.DescendantAdded:Connect(handleDescendant)
	end

	for _, child in oceanPOIs:GetChildren() do
		onPOIStreamIn(child)
	end

	oceanPOIs.ChildAdded:Connect(onPOIStreamIn)
end

return ABRoslitOnlyController