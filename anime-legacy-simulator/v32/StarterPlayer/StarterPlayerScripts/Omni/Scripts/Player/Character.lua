local module = require("@game/ReplicatedStorage/Omni")
local v = nil
local v2 = {}
local currentCamera = workspace.CurrentCamera
local Character = {
	_Teleport = function(cFrame: CFrame, vector: Vector3?)
		local character = module:GetCharacter()

		if not character then
			return
		end

		character:SetAttribute("Anchored", true)
		local HRP = module:GetHRP()

		if HRP then
			HRP.CFrame = cFrame

			if vector then
				currentCamera.CFrame = HRP.CFrame * CFrame.Angles(vector.X, vector.Y, vector.Z)
			end
		end

		task.wait(0.5)

		if character then
			character:SetAttribute("Anchored", nil)
		end
	end
}

function Character.Teleport(cframe: CFrame, vector: Vector3?, flag: boolean?)
	if typeof(cframe) ~= "CFrame" then
		warn("Teleport Error: No Destination given!")
	elseif flag or module.Data.Settings["Hide Teleport Transition"] then
		Character._Teleport(cframe, vector)
	else
		module.Signal:FireSelf("Interface", "Transition", "Create", "Circular", "In", 2, 1, function()
			Character._Teleport(cframe, vector)
		end)
	end
end

function Character.UpdateAnchored()
	if not v then
		return
	end

	local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local anchored = v:GetAttribute("Anchored") or v:GetAttribute("VoidRecovering") or false

	if humanoidRootPart.Anchored ~= anchored then
		humanoidRootPart.Anchored = anchored
	end
end

module:OnCharacterAdded(function(object)
	if not object then
		return
	end

	for k, connection in v2 do
		connection:Disconnect()
		v2[k] = nil
	end

	table.clear(v2)
	v = object
	table.insert(v2, object:GetAttributeChangedSignal("Anchored"):Connect(Character.UpdateAnchored))
	table.insert(v2, object:GetAttributeChangedSignal("VoidRecovering"):Connect(Character.UpdateAnchored))
	Character.UpdateAnchored()
end)
return Character