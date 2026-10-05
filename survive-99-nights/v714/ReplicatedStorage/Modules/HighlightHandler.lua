local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightHandler = {}
local v = {}
Highlightable = {
	HighlightWhiteEye = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Enabled = true,
		FillColor = Color3.fromRGB(255, 255, 255),
		FillTransparency = 0,
		OutlineTransparency = 1
	},
	HighlightBlackEye = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Enabled = true,
		FillColor = Color3.fromRGB(0, 0, 0),
		FillTransparency = 0,
		OutlineTransparency = 1
	},
	HighlightKeyOutline = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Enabled = true,
		OutlineColor = Color3.fromRGB(0, 0, 0),
		FillTransparency = 1,
		OutlineTransparency = 0
	},
	HighlightFlashlightCone = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Enabled = true,
		FillColor = Color3.fromRGB(255, 234, 0),
		FillTransparency = 0.75,
		OutlineTransparency = 1
	},
	HighlightHungryEyes = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Enabled = true,
		FillColor = Color3.fromRGB(255, 0, 0),
		FillTransparency = 0,
		OutlineTransparency = 1,
		HighPriority = true
	},
	HighlightAdminDiamond = {
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		Enabled = true,
		FillColor = Color3.fromRGB(101, 229, 255),
		FillTransparency = 1,
		OutlineColor = Color3.fromRGB(101, 229, 255),
		OutlineTransparency = 0
	}
}
local v2 = {
	DepthMode = Enum.HighlightDepthMode.Occluded,
	Enabled = false,
	FillColor = Color3.fromRGB(255, 0, 0),
	OutlineColor = Color3.fromRGB(255, 255, 255),
	FillTransparency = 0.5,
	OutlineTransparency = 0.8
}

function MakeHighlight(instance, name)
	if name == "HighlightFlashlightCone" and instance:IsDescendantOf(workspace.Items) then
		return
	end

	local v3 = Highlightable[name]

	if not v3 then
		print("NO HIGHLIGHT FOUND FOR " .. name)
		return
	end

	local function Create()
		if not instance:IsDescendantOf(workspace) then
			return
		end

		local highlight = instance:FindFirstChild(name)

		if highlight and highlight:IsA("Highlight") then
			return
		end

		if v3.HighPriority then
			for _, highlight2 in pairs(instance:GetChildren()) do
				if highlight2:IsA("Highlight") then
					highlight2:Destroy()
				end
			end
		end

		local highlight2 = Instance.new("Highlight")
		highlight2:AddTag("CountedHighlights")
		highlight2.Name = name
		highlight2.DepthMode = v3.DepthMode or v2.DepthMode
		highlight2.Enabled = v3.Enabled or v2.Enabled
		highlight2.FillColor = v3.FillColor or v2.FillColor
		highlight2.OutlineColor = v3.OutlineColor or v2.OutlineColor
		highlight2.FillTransparency = v3.FillTransparency or v2.FillTransparency
		highlight2.OutlineTransparency = v3.OutlineTransparency or v2.OutlineTransparency
		highlight2.Adornee = instance
		highlight2.Parent = instance
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Delete()
		if instance:IsDescendantOf(workspace) then
			return
		end

		local highlight = instance:FindFirstChild(name)

		if highlight and highlight:IsA("Highlight") then
			highlight.Adornee = nil
			highlight:Destroy()
		end
	end

	Create()

	if v[instance] then
		v[instance]:Disconnect()
	end

	v[instance] = instance.AncestryChanged:Connect(function()
		if instance:IsDescendantOf(workspace) then
			Create()
		else
			Delete() -- equivalent call inferred; original call site unknown
		end

		if not instance.Parent then
			v[instance]:Disconnect()
			v[instance] = nil
		end
	end)
end

function HighlightHandler.Init()
	local Utility = require(script.Parent.Utility)
	task.spawn(function()
		while wait(20) do
			for _, v3 in pairs(CollectionService:GetTagged("CountedHighlights")) do
				if v3.Parent and v3.Parent.Parent and v3:IsDescendantOf(workspace) then
					continue
				end

				v3.Adornee = nil
				v3:Destroy()
			end
		end
	end)
	task.spawn(function()
		wait(20)

		if not ReplicatedStorage:GetAttribute("UpdateParty") then
			local CollectionService2 = game:GetService("CollectionService")

			for _, v3 in pairs(CollectionService2:GetTagged("HighlightUpdateParty")) do
				v3.Adornee = nil
				v3:Destroy()
			end
		end
	end)

	for k, _ in pairs(Highlightable) do
		local v3 = k
		Utility.ForAllTagged(k, function(p)
			MakeHighlight(p, v3)
		end)
	end
end

return HighlightHandler