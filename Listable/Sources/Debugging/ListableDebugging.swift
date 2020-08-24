//
//  ListableDebugging.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/2/20.
//

import Foundation


public struct ListableDebugging
{
    public var isEnabled : Bool
    
    public var options : Options = .init()
    
    public struct Options
    {
        public var validatesCollectionViewDiff = true
        public var logsCollectionViewDiffOperations = true
    }
    
    func perform(if keyPath : KeyPath<Options, Bool>, _ action : () -> Void)
    {
        if self.isEnabled && self.options[keyPath: keyPath]
        {
            action()
        }
    }
    
    func measure<Output>(if keyPath : KeyPath<Options, Bool>, max : TimeInterval, action : () -> Output, log : (MeasureLogInfo) -> String) -> Output
    {
        if self.isEnabled && self.options[keyPath: keyPath] {
            let start = Date()
            let output = action()
            let end = Date()
            
            let duration = end.timeIntervalSince(start)
            
            if duration > max {
                Self.log(log(MeasureLogInfo(
                    max: max,
                    duration: duration
                )))
            }
            
            return output
        } else {
            return action()
        }
    }
    
    struct MeasureLogInfo
    {
        var max : TimeInterval
        var duration : TimeInterval
    }
        
    static func log(_ string : String)
    {
        self.logInitialInfoIfNeeded()
        
        print("[Listable Debugging]:", string)
    }
    
    private static var hasLoggedDebuggingInfo : Bool = false
    
    private static func logInitialInfoIfNeeded()
    {
        guard self.hasLoggedDebuggingInfo == false else {
            return
        }
        
        self.hasLoggedDebuggingInfo = true
        
        print(
            """
            -------------
            NOTE: Listable Debug is enabled. To enabled or disable:
            -----
            1) Call `ListDebugging.debugging.isEnabled = {true,false}` in your application code.
            2) Provide `ListableDebuggingEnabled` in your scheme's environment variables with a value of YES/true.
            -------------
            """
        )
    }
}


public extension ListableDebugging
{
    static var debugging : ListableDebugging = ListableDebugging(
        isEnabled: {
            if let enabled = ProcessInfo.processInfo.environment["ListableDebuggingEnabled"] {
                /// Casting to `NSString` allows access to its `boolValue` implementation,
                /// which is smart around booleans for `YES`, `Y`, `true`, etc.
                return (enabled as NSString).boolValue
            } else {
                return false
            }
        }()
    )
}
