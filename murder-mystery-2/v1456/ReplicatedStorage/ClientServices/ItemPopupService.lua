local ItemPopupService = {
	AnimationTargetLocation = nil,
	ItemReceived = Instance.new("BindableEvent"),
	ItemClaimsComplete = Instance.new("BindableEvent")
}

function ItemPopupService.AddNewItem(_, p: string, p2: string, p3: number)
	ItemPopupService.ItemReceived:Fire(p, p2, p3)
end

return ItemPopupService