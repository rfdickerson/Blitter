/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import Dispatch

public class Pipe<OutcomeParm> {
    public typealias Me = Pipe<OutcomeParm>
    public typealias Outcome = OutcomeParm
    
    fileprivate let internalSynchronizationQueue = DispatchQueue(label: "Pipe internalSynchronizationQueue")
    
    fileprivate var outcomes: [Outcome] = []
    
    fileprivate var readFn: ( (Outcome?) -> Void)?
    fileprivate let readerQueue: DispatchQueue
    
    fileprivate var areWritesPossible = true
    
    public init(readerQueue: DispatchQueue) {
        self.readerQueue = readerQueue
    }
    public convenience init(qos: FutureQOS) {
        self.init(readerQueue: qos.queue)
    }
    
    public func readEach(_ fn: @escaping (Outcome?) -> Void )
    {
        let me = self
        
        internalSynchronizationQueue.sync {
            assert(me.areWritesPossible)
            me.readFn = fn
            for outcome in me.outcomes {
                me.dispatchARead { fn(outcome) }
            }
            me.outcomes.removeAll()
            if !me.areWritesPossible {
                me.dispatchARead { fn(nil) }
            }
        }
    }
    
    
    public func readForEach( eachFn: @escaping (Outcome) -> Void )  ->  Future<Outcome?>
    {
        var finalOutcome: Outcome?
        let output = Future<Outcome?>()
        
        readEach {
            switch $0 {
            case let outcome?:
                finalOutcome = outcome
                eachFn(outcome)
            case nil:
                output.write(finalOutcome)
            }
        }
        return output
    }
    
    
    @discardableResult
    public func write( _ outcome: Outcome )  ->  Me
    {
        let me = self
        internalSynchronizationQueue.sync {
            assert(me.areWritesPossible)
            if let fn = me.readFn  {
                me.dispatchARead { fn(outcome) }
            }
            else {
                me.outcomes.append(outcome)
            }
        }
        return self
    }
    
    public func close()
    {
        let me = self
        internalSynchronizationQueue.sync {
            me.areWritesPossible = false
            if let fn = me.readFn {
                me.dispatchARead { fn(nil) }
            }
        }
    }
    
    fileprivate func dispatchARead( _ fn: @escaping () -> Void ) {
        readerQueue.async(execute: fn)
    }
}

public func writeToPipe<T>( onQueue queue: DispatchQueue, outcome: T )  ->  Pipe<T>
{
    return Pipe<T>(readerQueue: queue).write(outcome)
}
