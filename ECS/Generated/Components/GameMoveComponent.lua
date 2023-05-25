local _Base = require('ECS.Framework.Component')
local TestComponent = class('TestComponent', _Base)

function TestComponent:Init(id, list)
        self.id = id or "test"
        self.list = list

end

function TestComponent:SetData(id, list)
        self.id = id or self.id
        self.list = list or self.list

end

return TestComponent
