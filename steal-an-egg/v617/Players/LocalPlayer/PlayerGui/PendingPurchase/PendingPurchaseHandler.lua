local TweenService = game:GetService("TweenService")
local parent = script.Parent
local pendingPurchase = parent:WaitForChild("PendingPurchase")
local gift = pendingPurchase:WaitForChild("Gift")
local spinner = pendingPurchase:WaitForChild("Spinner")
local uIScale = gift:WaitForChild("UIScale")
local v = nil
local PendingPurchaseHandler = {}
parent.Enabled = false

function PendingPurchaseHandler.observePendingPurchase()
	if v then
		v()
	end

	parent.Enabled = true
	pendingPurchase.Visible = true
	pendingPurchase.BackgroundTransparency = 1
	gift.Size = UDim2.fromScale(0.2, 0.2)
	spinner.Size = UDim2.fromScale(0.5, 0.5)
	uIScale.Scale = 1
	spinner.Rotation = 0
	local v2 = { TweenService:Create(pendingPurchase, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.4
		}), TweenService:Create(
			uIScale,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Scale = 1.3
			}
		), TweenService:Create(spinner, TweenInfo.new(1.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
			Rotation = 360
		}) }
	local flag = false

	local function cleanup()
		if flag then
			return
		end

		flag = true

		for _, v3 in v2 do
			v3:Cancel()
			v3:Destroy()
		end

		parent.Enabled = false
		pendingPurchase.BackgroundTransparency = 1
		gift.Size = UDim2.fromScale(0, 0)
		spinner.Size = UDim2.fromScale(0, 0)
		uIScale.Scale = 1
		spinner.Rotation = 0
		v = nil
	end

	v = cleanup

	for _, v3 in v2 do
		v3:Play()
	end

	return cleanup
end

return PendingPurchaseHandler