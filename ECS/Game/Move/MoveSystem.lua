local _Base = require("ECS.Framework.System")
local MoveSystem = class("MoveSystem", _Base)

function MoveSystem:ctor()
    self.group = Context:GetGroup(NewMatcher():AllOf(EMatcher.Test))
end

function MoveSystem:Execute(dt)
    for key, entity in pairs(self.group:GetEntities()) do
        print("move system execute ", entity:HasTest())
    end
end

return MoveSystem
