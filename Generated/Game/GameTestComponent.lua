local _Base = require("ECS.Component")
local TestComponent = class("TestComponent", _Base)

function TestComponent:init(id, list)
    self.id = id or 1
    self.list = list or {13,156,785}
end


return TestComponent