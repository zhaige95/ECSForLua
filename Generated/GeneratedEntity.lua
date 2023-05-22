local GeneratedEntity = class("GeneratedEntity")

function GeneratedEntity:AddTest(id, list)
    self.test = Context:GetComponent("TestComponent")
    self.test:init(id, list)
    print("添加组件", self.test.id)
end

return GeneratedEntity
