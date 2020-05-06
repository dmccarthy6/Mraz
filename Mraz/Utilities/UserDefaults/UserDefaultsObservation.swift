//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

//PROPERTY LIST VALUE PROTOCOL
//1
@propertyWrapper
struct UserDefault<T: PropertyListValue> {
    let key: Key
    var projectedValue: UserDefault<T> { return self }
    var wrappedValue: T? {
        get { UserDefaults.standard.value(forKey: key.rawValue) as? T}
        set {UserDefaults.standard.set(newValue, forKey: key.rawValue)}
    }
    
    func observe(change: @escaping (T?, T?) -> Void) -> NSObject {
        return DefaultsObservation(key: key) { (old, new) in
            change(old as? T, new as? T)
        }
    }
}

//2
class DefaultsObservation: NSObject {
    let key: Key
    private var onChange: (Any, Any) -> Void
    
    //1
    init(key: Key, onChange: @escaping (Any, Any) -> Void) {
        self.onChange = onChange
        self.key = key
        super.init()
        UserDefaults.standard.addObserver(self, forKeyPath: key.rawValue, options: [.old, .new], context: nil)
    }
}
/*
 Extend Key to add Keys
 */
