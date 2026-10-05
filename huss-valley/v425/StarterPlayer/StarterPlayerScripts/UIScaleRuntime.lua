local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local v = {
	Resolution = {
		is = "Vector2",
		default = Vector2.new(1280, 720)
	},
	ScaleRange = {
		is = "NumberRange",
		default = NumberRange.new(0, 1e999)
	}
}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function removeFromList(list, p)
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

local update

update = function(uIScale)
	if not uIScale:IsA("UIScale") or uIScale:IsDescendantOf(StarterGui) then
		return
	end

	local attributesByAttributeName = {}

	for attributeName, v4 in pairs(v) do
		local attribute = uIScale:GetAttribute(attributeName)

		if typeof(attribute) ~= v4.is then
			attribute = v4.default
			warn((`no '{attributeName}' attribute found for {uIScale:GetFullName()}, using '{v4.default}' instead`))
		end

		attributesByAttributeName[attributeName] = attribute
	end

	if not uIScale.Parent then
		return
	end

	local guiBase2d = uIScale.Parent:FindFirstAncestorWhichIsA("GuiBase2d")
	local absoluteSize, currentCamera

	if guiBase2d and (not guiBase2d:IsA("ScreenGui") or not guiBase2d.IgnoreGuiInset and guiBase2d.ScreenInsets ~= Enum.ScreenInsets.None) then
		absoluteSize = guiBase2d.AbsoluteSize
		currentCamera = guiBase2d
	else
		absoluteSize = workspace.CurrentCamera.ViewportSize
		currentCamera = workspace.CurrentCamera
	end

	local listener = v2[currentCamera]

	if not listener then
		local v5 = nil
		v5 = {
			source = currentCamera,
			scales = {},
			signal = currentCamera:GetPropertyChangedSignal(currentCamera:IsA("Camera") and "ViewportSize" or "AbsoluteSize"):Connect(function()
				for k in v5.scales do
					update(k)
				end
			end)
		}
		listener = v5
		v2[currentCamera] = listener
	end

	local scale = listener.scales[uIScale]

	if not scale then
		scale = {
			listener = listener,
			signals = {},
			text_constraints = {}
		}
		listener.scales[uIScale] = scale
		v3[uIScale] = scale

		if guiBase2d then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function setupCleanup(uITextSizeConstraint)
				local ancestryChangedConnection = nil
				ancestryChangedConnection = uITextSizeConstraint.AncestryChanged:Connect(function()
					if uITextSizeConstraint:IsDescendantOf(guiBase2d) then
						return
					end

					removeFromList(scale.signals, ancestryChangedConnection) -- equivalent call inferred; original call site unknown
					removeFromList(scale.text_constraints, uITextSizeConstraint) -- equivalent call inferred; original call site unknown
				end)
				table.insert(scale.signals, ancestryChangedConnection)
			end

			for _, uITextSizeConstraint in guiBase2d:GetDescendants() do
				if not uITextSizeConstraint:IsA("UITextSizeConstraint") then
					continue
				end

				table.insert(scale.text_constraints, uITextSizeConstraint)
				uITextSizeConstraint:SetAttribute(
					"__uitools_reference_range",
					NumberRange.new(uITextSizeConstraint.MinTextSize, uITextSizeConstraint.MaxTextSize)
				)
				local ancestryChangedConnection = nil
				local v5 = uITextSizeConstraint
				ancestryChangedConnection = uITextSizeConstraint.AncestryChanged:Connect(function()
					if v5:IsDescendantOf(guiBase2d) then
						return
					end

					removeFromList(scale.signals, ancestryChangedConnection) -- equivalent call inferred; original call site unknown
					removeFromList(scale.text_constraints, v5) -- equivalent call inferred; original call site unknown
				end)
				table.insert(scale.signals, ancestryChangedConnection)
			end

			table.insert(scale.signals, guiBase2d.DescendantAdded:Connect(function(uITextSizeConstraint)
				if not uITextSizeConstraint:IsA("UITextSizeConstraint") then
					return
				end

				table.insert(scale.text_constraints, uITextSizeConstraint)
				local __uitools_reference_range = uITextSizeConstraint:GetAttribute("__uitools_reference_range")

				if typeof(__uitools_reference_range) == "NumberRange" then
					uITextSizeConstraint.MinTextSize = __uitools_reference_range.Min * uIScale.Scale
					uITextSizeConstraint.MaxTextSize = __uitools_reference_range.Max * uIScale.Scale
				end

				setupCleanup(uITextSizeConstraint) -- equivalent call inferred; original call site unknown
			end))
		end
	end

	local Y = absoluteSize.Y < absoluteSize.X and absoluteSize.Y or absoluteSize.X
	uIScale.Scale = math.clamp(
		1 / attributesByAttributeName.Resolution.Y * math.clamp(
			1 / attributesByAttributeName.Resolution.X * absoluteSize.X / (1 / attributesByAttributeName.Resolution.Y * Y),
			0,
			1
		) * Y,
		attributesByAttributeName.ScaleRange.Min,
		attributesByAttributeName.ScaleRange.Max
	)

	if not plugin then
		for _, text_constraint in scale.text_constraints do
			local __uitools_reference_range = text_constraint:GetAttribute("__uitools_reference_range")

			if typeof(__uitools_reference_range) ~= "NumberRange" then
				continue
			end

			text_constraint.MinTextSize = __uitools_reference_range.Min * uIScale.Scale
			text_constraint.MaxTextSize = __uitools_reference_range.Max * uIScale.Scale
		end
	end
end

local function updateAll()
	for _, uIScale in CollectionService:GetTagged("UIScaleRuntimeObject") do
		if uIScale:IsA("UIScale") then
			update(uIScale)
		end
	end
end

updateAll()

local function cleanupScale(uIScale)
	if not uIScale:IsA("UIScale") then
		return
	end

	local v4 = v3[uIScale]

	if not v4 then
		return
	end

	uIScale.Scale = 1
	v3[uIScale] = nil

	if v4.signals then
		for _, signal in v4.signals do
			signal:Disconnect()
		end
	end

	v4.listener.scales[uIScale] = nil

	if next(v4.listener.scales) == nil then
		v4.listener.signal:Disconnect()
		v2[v4.listener.source] = nil
	end
end

CollectionService:GetInstanceAddedSignal("UIScaleRuntimeObject"):Connect(update)
CollectionService:GetInstanceRemovedSignal("UIScaleRuntimeObject"):Connect(cleanupScale)