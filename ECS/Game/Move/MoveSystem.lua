local _Base = require("ECS.Framework.System")
local MoveSystem = class("MoveSystem", _Base)

function MoveSystem:ctor()
    self.group = Context:GetGroup(NewMatcher():AllOf(EMatcher.Move))
end

function MoveSystem:Execute(dt)
    for key, entity in pairs(self.group) do
        print(entity.HasTest())
    end
end

return MoveSystem
