-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 实体基类
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local _Base = require("ECS.Generated.GameEntity")

local Entity = class("Entity", _Base)

function Entity:ctor()
    self.__component_indexer = {}
    self.mUID = 0
end

function Entity:OnDispose()

end

---销毁实体
function Entity:Destroy()
    Context:_OnDestroyEntity(self)
end

---添加组件事件
---@param comp Component 组件实例
function Entity:_OnAddComponent(comp)
    if not self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = comp
    end
end

---移除组件事件
---@param comp Component 组件实例
function Entity:_OnRemoveComponent(comp)
    if self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = nil
    end
end

---检查实体是否有指定id的组件
---@param id integer
---@return boolean
function Entity:HasComponent(id)
    if self.__component_indexer[id] then
        return true
    end
    return false
end

return Entity
