//
//  BlueprintEnvironment.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/27/20.
//

import BlueprintUI


extension ListEnvironment {
    
    var blueprintEnvironment : BlueprintUI.Environment {
        get { self[BlueprintKey.self] }
        set { self[BlueprintKey.self] = newValue }
    }
    
    private enum BlueprintKey : ListEnvironmentKey {
        static let defaultValue : BlueprintUI.Environment = .empty
    }
}
