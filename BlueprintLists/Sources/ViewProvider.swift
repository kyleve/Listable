//
//  ViewProvider.swift
//  Pods
//
//  Created by Kyle Van Essen on 6/2/20.
//

import Listable
import BlueprintUI


public extension ViewProvider
{
    init(_ element : @escaping () -> Element)
    {
        self.init(BlueprintView.self) {
            $0.create = {
                BlueprintView()
            }
            
            $0.update = {
                $0.element = element()
            }
        }
    }
}
