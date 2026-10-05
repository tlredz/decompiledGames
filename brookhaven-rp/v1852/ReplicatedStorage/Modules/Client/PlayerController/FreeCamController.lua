local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreeCamController = {}
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function syncBackActionBinding(isFreecamEnabled: boolean)
	if isFreecamEnabled then
		if not v2 then
			v2 = BackActionRouter.Bind(function()
				if FreeCamController.IsFreecamEnabled() then
					FreeCamController.ToggleFreeCam()
				end
			end)
		end
	elseif v2 then
		v2()
		v2 = nil
	end
end

function FreeCamController.FrameworkInit() end

function FreeCamController.FrameworkStart()
	local localPlayer = Players.LocalPlayer
	localPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(function(child)
		if child.Name ~= "Freecam" then
			return
		end

		local freecamModule = child:WaitForChild("FreecamModule", 120)

		if freecamModule and freecamModule:IsA("ModuleScript") then
			require(freecamModule)
		end
	end)
	local freecam = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Freecam", 120)

	if not freecam then
		return
	end

	local freecamModule = freecam:WaitForChild("FreecamModule", 120)

	if freecam and freecamModule then
		require(freecam.FreecamModule)
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	if humanoid then
		humanoid.Died:Connect(function()
			if FreeCamController.IsFreecamEnabled() then
				FreeCamController.ToggleFreeCam()
			end
		end)
	end

	if FreeCamController.IsFreecamEnabled() then
		syncBackActionBinding(true) -- equivalent call inferred; original call site unknown
	elseif v2 then
		v2()
		v2 = nil
	end
end

function FreeCamController.HasValidFreecamModule()
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return false
	end

	local freecam = playerGui:FindFirstChild("Freecam")
	return freecam and freecam:FindFirstChild("FreecamModule")
end

function FreeCamController.IsFreecamEnabled()
	local freeCamScript = FreeCamController.GetFreeCamScript()

	if freeCamScript then
		return freeCamScript.IsFreecamEnabled()
	end

	return false
end

function FreeCamController.GetFreeCamScript()
	if v then
		return v
	end

	local hasValidFreecamModule = FreeCamController.HasValidFreecamModule()

	if not hasValidFreecamModule then
		return nil
	end

	local module = require(hasValidFreecamModule)
	v = module
	return v
end

function FreeCamController.ToggleFreeCam()
	local freeCamScript = FreeCamController.GetFreeCamScript()

	if freeCamScript then
		freeCamScript.ToggleFreecam()
		local isFreecamEnabled = freeCamScript.IsFreecamEnabled()
		syncBackActionBinding(isFreecamEnabled) -- equivalent call inferred; original call site unknown
		return isFreecamEnabled
	else
		if v2 then
			v2()
			v2 = nil
		end

		return false
	end
end

return FreeCamController