local _Base = require("ECS.Framework.Feature")
local FeatureUpdate = class("FeatureUpdate", _Base)

function FeatureUpdate:ctor()
    self.super:ctor()
    self:Add(require("ECS.Game.Move.MoveSystem"))
end

return FeatureUpdate