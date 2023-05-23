local GameEntity = class("GameEntity")


function GameEntity:AddTest(list, id)
    self.Test = Context:_GetComponent(GameComponentLookUp.TestComponent)
    self.Test:Init(list, id)
    self:_OnAddComponent(self.Test)
    Context:_OnAddComponent(self, self.Test)
end

function GameEntity:RemoveTest()
    self:_OnRemoveComponent(self.Test)
    Context:_OnRemoveComponent(self, self.Test)
    self.Test = nil
end

return GameEntity