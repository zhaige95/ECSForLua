local _Base = require("Generated.GeneratedEntity")

local Entity = class("Entity", _Base)

function Entity:ctor()
    self.mCompIndex = {}
    self.mUID = 0
end


return Entity