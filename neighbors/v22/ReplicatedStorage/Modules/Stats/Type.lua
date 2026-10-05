local Type = {}

function Type.GetPropertyChangedSignal(_, _: string) end

function Type.UpdateProperty(_, _: string) end

function Type.Dump(_) end

Type.OnUpdate = nil
return Type