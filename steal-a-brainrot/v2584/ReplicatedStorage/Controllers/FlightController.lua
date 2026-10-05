local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local FlightSimulation = require(ReplicatedStorage.Shared.ServerAuthority.FlightSimulation)
local gearAttribute = FlightSimulation.GearAttribute
local v = {
	["Santa's Sleigh"] = "SantasSleighPresent",
	["Cupid's Wings"] = "CupidsWingsInvisibility",
	Waverider = "WaveriderBoost",
	["Flying Bee"] = "FlyingBeeAttack"
}

local function dprint(...) end

local function localFlightTool()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil
	end

	local tool = character:FindFirstChildWhichIsA("Tool")

	if tool and tool:GetAttribute(gearAttribute) then
		return tool
	end

	return nil
end

local v2 = {}

local function bindActionFrameVisibility(tool)
	if not tool:IsA("Tool") or v2[tool] then
		return
	end

	local v3 = v[tool.Name]

	if not v3 then
		return
	end

	v2[tool] = true
	task.spawn(function()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
		local toolsFrames = playerGui and playerGui:WaitForChild("ToolsFrames", 30)
		local guiObject = toolsFrames and toolsFrames:WaitForChild(v3, 30)

		if not (guiObject and guiObject:IsA("GuiObject") and tool.Parent) then
			v2[tool] = nil
			return
		end

		local function update()
			local parent = tool.Parent
			local v4

			if parent == nil then
				v4 = false
			else
				v4 = parent:IsA("Model")
			end

			guiObject.Visible = (tool.Name ~= "Flying Bee" or not ServerData.IsTradePlaza()) and v4 and tool:GetAttribute("IsActive") == true
		end

		tool:GetAttributeChangedSignal("IsActive"):Connect(update)
		tool:GetPropertyChangedSignal("Parent"):Connect(update)
		tool.Destroying:Once(function()
			v2[tool] = nil
		end)
		local parent = tool.Parent
		local v4

		if parent == nil then
			v4 = false
		else
			v4 = parent:IsA("Model")
		end

		guiObject.Visible = (tool.Name ~= "Flying Bee" or not ServerData.IsTradePlaza()) and v4 and tool:GetAttribute("IsActive") == true
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchActionTools(instance)
	if not instance then
		return
	end

	for _, child in instance:GetChildren() do
		bindActionFrameVisibility(child)
	end

	instance.ChildAdded:Connect(bindActionFrameVisibility)
end

local function watchCharacterAndBackpack()
	local localPlayer = Players.LocalPlayer
	watchActionTools(localPlayer:FindFirstChildOfClass("Backpack")) -- equivalent call inferred; original call site unknown
	localPlayer.ChildAdded:Connect(function(backpack2)
		if backpack2:IsA("Backpack") then
			watchActionTools(backpack2) -- equivalent call inferred; original call site unknown
		end
	end)

	if localPlayer.Character then
		watchActionTools(localPlayer.Character) -- equivalent call inferred; original call site unknown
	end

	localPlayer.CharacterAdded:Connect(watchActionTools)
end

local v3 = false

local function updateFov()
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local character = Players.LocalPlayer.Character
	local tool

	if character then
		tool = character:FindFirstChildWhichIsA("Tool")

		if not (tool and tool:GetAttribute(gearAttribute)) then
			tool = nil
		end
	end

	local character2 = Players.LocalPlayer.Character
	local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
	local v4

	if humanoidRootPart == nil then
		v4 = false
	else
		v4 = humanoidRootPart:IsA("BasePart") and humanoidRootPart:GetAttribute(FlightSimulation.FlyingAttribute) == true
	end

	local v5

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		v5 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude > 3
	else
		v5 = false
	end

	local v6

	if tool and tool.Name == "Waverider" and v4 and v5 then
		local v7 = (tool:GetAttribute("SpeedMultiplier") or 1.65) / 1.65
		local v8 = tool:GetAttribute("Boosting") ~= true and 0 or math.sin(os.clock() * 3) * 1.5 + 15
		v6 = 70 + 6 * v7 + v8
		v3 = true
	else
		v6 = 70
	end

	if not v3 then
		return
	end

	currentCamera.FieldOfView += (v6 - currentCamera.FieldOfView) * 0.15

	if v6 == 70 and math.abs(currentCamera.FieldOfView - 70) < 0.1 then
		currentCamera.FieldOfView = 70
		v3 = false
	end
end

return {
	Start = function(_)
		if not ServerAuthority.isEnabled() then
			dprint("SA disabled -- FlightController inactive (legacy mode)")
			return
		end

		dprint("started; rendering flight cosmetics")
		RunService:BindToRenderStep("FlightFovEffect", Enum.RenderPriority.Camera.Value + 2, updateFov)
		watchCharacterAndBackpack()
	end
}