return {
	tweenModelCFrame = function(instance, cframe: CFrame, p, callback)
		local cFrameValue = Instance.new("CFrameValue")

		local function onChanged(cframe2: CFrame)
			instance:PivotTo(cframe2)
		end

		cFrameValue.Value = instance:GetPivot()
		cFrameValue.Changed:Connect(onChanged)
		local v = game.TweenService:Create(cFrameValue, p, {
			Value = cframe
		})
		local completedConnection = nil
		completedConnection = v.Completed:Connect(function()
			if callback then
				callback()
			end

			if completedConnection then
				completedConnection:Disconnect()
				completedConnection = nil
			end

			cFrameValue:Destroy()
			v:Destroy()
			v = nil
		end)
		v:Play()
	end
}