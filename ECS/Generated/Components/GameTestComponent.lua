    local _Base = require('ECS.Framework.Component')
    local TestComponent = class('TestComponent', _Base)

    function TestComponent:Init(list, id)
        self.id = id or "test"
        self.list = list or {}

    end

    return TestComponent
