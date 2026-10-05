local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local v2 = {}

local function IsOpaque(guiObject)
	if guiObject.BackgroundTransparency < 0.85 or (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject.Image ~= "" and guiObject.ImageTransparency < 0.85 then
		return true
	end

	if (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox")) and guiObject.Text ~= "" and guiObject.TextTransparency < 0.85 then
		return true
	end

	if guiObject:IsA("ViewportFrame") then
		return true
	end

	return false
end

local function UnderScreenGui(guiObject)
	local parent = guiObject.Parent

	while parent and parent ~= playerGui do
		if parent:IsA("ScreenGui") then
			return parent.Name ~= "ProximityPrompts" and parent.Enabled
		elseif parent:IsA("BillboardGui") or parent:IsA("SurfaceGui") then
			return false
		else
			parent = parent.Parent
		end
	end

	return false
end

local function PromptWorldPosition(p)
	local parent = p.Parent

	if not parent then
		return nil
	end

	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	if parent:IsA("BasePart") then
		return parent.Position
	end

	if not parent:IsA("Model") then
		return nil
	end

	local primaryPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
	return primaryPart and primaryPart.Position or nil
end

local function IsCovered(k)
	local currentCamera = workspace.CurrentCamera
	local promptWorldPosition = PromptWorldPosition(k)

	if not (currentCamera and promptWorldPosition) then
		return false
	end

	local worldToViewportPoint, v4 = currentCamera:WorldToViewportPoint(promptWorldPosition)

	if not v4 then
		return false
	end

	for _, guiObject in playerGui:GetGuiObjectsAtPosition(
		worldToViewportPoint.X + k.UIOffset.X,
		worldToViewportPoint.Y + (k.Style == Enum.ProximityPromptStyle.Custom and -k.UIOffset.Y or k.UIOffset.Y)
	) do
		if guiObject:IsA("GuiObject") and guiObject.Visible and IsOpaque(guiObject) and UnderScreenGui(guiObject) then
			return true
		end
	end

	return false
end

ProximityPromptService.PromptShown:Connect(function(p)
	v[p] = true
end)
ProximityPromptService.PromptHidden:Connect(function(p)
	v[p] = nil
end)
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0

	for k in v do
		if k.Parent then
			if IsCovered(k) then
				k:SetAttribute("Occluded", true)
				v2[k] = true
				v[k] = nil
			end
		else
			v[k] = nil
		end
	end

	for k in v2 do
		if k.Parent then
			if not IsCovered(k) then
				k:SetAttribute("Occluded", false)
				v2[k] = nil
			end
		else
			v2[k] = nil
		end
	end
end)