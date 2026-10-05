Prop = {
	Add = function(p, p2, p3)
		p[p2] += p3
	end,
	Remove = function(p, p2, p3)
		p[p2] -= p3
	end
}
Attr = {
	Add = function(instance, attributeName, p)
		instance:SetAttribute(attributeName, instance:GetAttribute(attributeName) + p)
	end,
	Remove = function(instance, attributeName, p)
		instance:SetAttribute(attributeName, instance:GetAttribute(attributeName) - p)
	end
}
StringProp = {
	Add = function(p, p2, p3)
		p[p2] ..= p3
	end
}
StringAttribute = {
	Add = function(instance, attributeName, p)
		instance:SetAttribute(attributeName, instance:GetAttribute(attributeName) .. p)
	end
}
return {
	Attributes = {
		number = Attr,
		Vector3 = Attr,
		Vector2 = Attr,
		UDim2 = Attr,
		UDim = Attr,
		string = StringAttribute
	},
	Property = {
		number = Prop,
		Vector3 = Prop,
		Vector2 = Prop,
		UDim2 = Prop,
		UDim = Prop,
		string = StringProp
	}
}