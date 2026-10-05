return function(object)
	local page = object:FindPage("Collection")
	object.styleController:Apply(page.Margin.Stickers.TextButton, "Shared.Journal.textButton")
	object.styleController:Apply(page, "Shared.Journal.collection")
	object:BindTab(page.Margin.Stickers.TextButton, "Stickers")
	object:BindTab(page.Margin.Stickers.Button, "Stickers")
end