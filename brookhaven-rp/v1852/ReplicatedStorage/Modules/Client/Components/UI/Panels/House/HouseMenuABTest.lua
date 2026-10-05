local HouseMenuABTest = {}

function HouseMenuABTest.Apply(p)
	HouseMenuABTest.ApplyQuadruple(p)
end

function HouseMenuABTest.ApplyTriple(p)
	p.Catalog.Header.CategoryTabs.Close.Modal = true
	local scrollGroup = p.Catalog.Container.ScrollGroup
	scrollGroup.FilterGroup.Filters.Visible = true
	scrollGroup.FilterGroup.ControlFilters.Visible = false
	scrollGroup.Size = UDim2.fromScale(1.2825, 1)
	scrollGroup.ScrollingFrame.UIGridLayout.CellSize = UDim2.fromScale(0.333, 1)
	scrollGroup.FilterGroup.UIAspectRatioConstraint.AspectRatio = 0.23
end

function HouseMenuABTest.ApplyQuadruple(p)
	p.Catalog.Header.CategoryTabs.Close.Modal = true
	local scrollGroup = p.Catalog.Container.ScrollGroup
	scrollGroup.FilterGroup.Filters.Visible = true
	scrollGroup.FilterGroup.ControlFilters.Visible = false
	scrollGroup.Size = UDim2.fromScale(1.71, 1)
	scrollGroup.ScrollingFrame.UIGridLayout.CellSize = UDim2.fromScale(0.25, 1)
	scrollGroup.FilterGroup.UIAspectRatioConstraint.AspectRatio = 0.23
end

function HouseMenuABTest.ApplyCentre(p)
	p.Catalog.AnchorPoint = Vector2.new(0.5, 0)
	p.Catalog.Position = UDim2.fromScale(0.55, p.Catalog.Position.Y.Scale)
	p.Menu.AnchorPoint = Vector2.new(0.5, 0)
	p.Menu.Position = UDim2.fromScale(0.5, p.Menu.Position.Y.Scale)
	p.Catalog.Header.CategoryTabs.QuickSurface:SetAttribute("NotifyCenter", true)
end

return HouseMenuABTest