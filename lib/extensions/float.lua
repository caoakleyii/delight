float = {}

function float.lerp_value(v0, v1, t)
    return (1 - t) * v0 + t * v1
end

return float