local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Selection = {
		Category = {
			Type = "string"
		},
		PastUI = {
			Type = "GuiObject"
		},
		Callback = {
			Type = "function"
		},
		NeededProperties = {
			Type = "table",
			Optional = true
		},
		IsCategoryAvailable = {
			Type = "function",
			Optional = true
		}
	},
	Evolve = {
		Target = {
			Type = "string"
		}
	}
}
local Controller = {
	Categories = {},
	Category = nil,
	CategoryChanged = module.Libs.GoodSignal.new(),
	Mode = "Default",
	ModeLocked = false,
	ModeParams = {},
	ModeChanged = module.Libs.GoodSignal.new(),
	SelectedItens = {},
	SelectedItensChanged = module.Libs.GoodSignal.new()
}

function Controller.SetCategory(category: string)
	local category2 = Controller.Categories[category]

	if Controller.Category == category then
		if category2 and category2.Interface and not module.Frame:IsFrameOpened(category2.Interface) then
			module.Frame:Open(category2.Interface)
		end
	else
		table.clear(Controller.SelectedItens)
		Controller.Mode = "Default"
		Controller.ModeChanged:Fire(Controller.Mode)
		Controller.Category = category

		if category2 and category2.Interface and not module.Frame:IsFrameOpened(category2.Interface) then
			module.Frame:Open(category2.Interface)
		end

		Controller.CategoryChanged:Fire(category)
	end
end

function Controller.SetMode(mode: string, p)
	local modeParams = {}
	local v3 = v[mode]

	if v3 then
		if p then
			for k, v4 in v3 do
				local v5 = p[k]

				if type(v5) ~= v4.Type then
					p[k] = nil
				end

				local v6 = v5 or v4.Default or nil

				if v6 == nil and not v4.Optional then
					return
				else
					modeParams[k] = v6
				end
			end
		else
			for k, v4 in v3 do
				local default = v4.Default or nil

				if default == nil and not v4.Optional then
					return
				else
					modeParams[k] = default
				end
			end
		end
	end

	if modeParams.Category then
		Controller.SetCategory(modeParams.Category)
	end

	if modeParams.PastUI then
		module.Frame:SetPastUI(modeParams.PastUI)
	end

	if Controller.Mode == mode or Controller.ModeLocked then
		return
	end

	table.clear(Controller.SelectedItens)
	Controller.Mode = mode
	Controller.ModeParams = modeParams
	Controller.ModeChanged:Fire(mode)
end

function Controller.LockMode()
	Controller.ModeLocked = true
end

function Controller.UnlockMode()
	Controller.ModeLocked = false
end

function Controller.CloseInterface()
	local category = Controller.Categories[Controller.Category]

	if category and category.Interface then
		module.Frame:Close(category.Interface)
	end
end

function Controller.SelectItem(p: string)
	if Controller.SelectedItens[p] then
		Controller.SelectedItens[p] = nil
	else
		Controller.SelectedItens[p] = true
	end

	Controller.SelectedItensChanged:Fire(Controller.SelectedItens)
end

function Controller.BulkSelectItems(items)
	for k in items do
		if Controller.SelectedItens[k] then
			Controller.SelectedItens[k] = nil
		else
			Controller.SelectedItens[k] = true
		end
	end

	Controller.SelectedItensChanged:Fire(Controller.SelectedItens)
end

function Controller.DeselectAllItems()
	Controller.SelectedItens = {}
	Controller.SelectedItensChanged:Fire(Controller.SelectedItens)
end

return Controller