return {
	handleAttribute = function(instance, attributeName: string, callback)
		task.spawn(callback, instance:GetAttribute(attributeName))
		instance:GetAttributeChangedSignal(attributeName):Connect(function()
			callback(instance:GetAttribute(attributeName))
		end)
	end
}