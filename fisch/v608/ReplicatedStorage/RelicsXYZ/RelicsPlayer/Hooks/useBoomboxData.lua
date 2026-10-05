local parent = script.Parent
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
require(shared.Promise)
local Boombox = require(shared.Boombox)
local Ownership = require(shared.Ownership)
local useSignal = require(parent.useSignal)

local function useBoomboxData()
	local state, setState = React.useState(Boombox.GetBoomboxConfigs)
	useSignal(Boombox.BoomboxConfigAdded, function()
		setState(Boombox.GetBoomboxConfigs())
	end, {})
	useSignal(Boombox.BoomboxConfigRemoved, function()
		setState(Boombox.GetBoomboxConfigs())
	end, {})
	local source, ownership = React.useMemo(function()
		local v3 = -1
		local v4 = {}
		local v5 = nil

		for _, v6 in state do
			local priority = v6.Priority or 0

			if v3 < priority then
				v5 = v6
				v3 = priority
			end

			Ownership.Get(v6, v4)
		end

		return v5, v4
	end, { state })
	local state2, setState2 = React.useState(nil)
	React.useEffect(function()
		if source then
			Boombox.PromiseBoombox({
				Priority = source.Priority or 1000000,
				AccessoryType = source.AccessoryType,
				ProductType = source.ProductType,
				ProductId = source.ProductId,
				Source = source
			}):andThen(function(instance)
				if instance:IsA("Accessory") then
					local handle = instance:FindFirstChild("Handle")

					if handle and handle:IsA("BasePart") then
						local model = Instance.new("Model")
						model.Name = "Boombox"
						local clone = handle:Clone()
						clone.Parent = model
						model.PrimaryPart = clone
						setState2(model)
					end
				elseif instance:IsA("Model") then
					setState2(instance)
				else
					warn("Boombox model is not an Accessory or Model:", instance)
					setState2(nil)
				end
			end):catch(function(p)
				warn("Failed to load boombox model:", p)
				setState2(nil)
			end)
		else
			setState2(nil)
		end
	end, { source })
	local renderAmbient = source and source.RenderAmbient
	local renderZoomScale = source and source.RenderZoomScale
	local renderOffset = source and source.RenderOffset or CFrame.identity
	local productId = source and source.ProductId
	local accessoryType = source and source.AccessoryType
	local productType = source and source.ProductType
	local legacyIds = source and source.LegacyIds
	React.useEffect(function()
		if productId then
			Boombox.PromiseBoombox({
				Priority = 1000000,
				ProductId = productId,
				ProductType = productType or Enum.InfoType.Asset,
				AccessoryType = accessoryType or Enum.AccessoryType.Back
			}):andThen(function(instance)
				local handle = instance:FindFirstChild("Handle")
				local model = Instance.new("Model")
				model.Name = "Boombox"

				if handle and handle:IsA("BasePart") then
					local clone = handle:Clone()
					clone.Parent = model
					model.PrimaryPart = clone
				end

				model:SetAttribute("Ambient", renderAmbient)
				model:SetAttribute("ZoomScale", renderZoomScale)
				setState2(model)
			end)
		end
	end, {
		renderAmbient,
		renderZoomScale,
		productId,
		accessoryType
	})
	React.useEffect(function()
		local primaryPart = state2 and state2.PrimaryPart

		if primaryPart then
			primaryPart.PivotOffset = renderOffset
		end
	end, { state2, renderOffset })
	return React.useMemo(function()
		return {
			Ownership = ownership,
			ProductId = productId or 0,
			AssetId = productId or 0,
			ProductType = productType or Enum.InfoType.Asset,
			AccessoryType = accessoryType or Enum.AccessoryType.Back,
			LegacyIds = legacyIds,
			Priority = 1000000,
			Model = state2,
			Source = source
		}
	end, {
		ownership,
		productId,
		accessoryType,
		state2,
		source
	})
end

return useBoomboxData