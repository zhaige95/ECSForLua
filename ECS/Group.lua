local Group = class("Group")

function Group:ctor()
    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mOnAdded = false
    self.mOnRemoved = false
end

function Group:AllOf(...)
    
end

function Group:NoneOf(...)
    
end

function Group:Added()
    
end

function Group:Removed()
    
end

function Group:AddedOrRemoved()
    
end




return Group