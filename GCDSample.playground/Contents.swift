//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

var str = "Hello, playground"
PlaygroundPage.current.needsIndefiniteExecution = true


func simpleQueues() {
    let serialQueue = DispatchQueue(label: "com.bigZero.GCDSamples")
    serialQueue.sync {
        for i in 0..<5 {
            print("🔵 \(i) -\( Thread.current))")
        }
    }
    
    serialQueue.async {
        for i in 0..<5 {
            print("⚾️ \(i) - \(Thread.current))")
        }
    }
    
    for i in 0..<10 {
        print("❤️ \(i) - \(Thread.current)")
    }
}

//simpleQueues()



//    var inactiveQueue: DispatchQueue!
func concurrentQueues() {
    let concurrentQueue = DispatchQueue.global()
    concurrentQueue.async {
        for i in 0..<10 {
            print("🔵 \(i) - \(Thread.current)")
        }
    }
    
    concurrentQueue.sync {
        for i in 0..<10 {
            print("❤️ \(i)- \(Thread.current)")
        }
    }
    
    concurrentQueue.async {
        for i in 0..<10 {
            print("⚾️ \(i)- \(Thread.current)")
        }
    }
}

concurrentQueues()

func queueWithDelay() {
    
}


func fetchImage() {
    
}


func useWorkItem() {
    
}


// MARK: - Important example
/// 1
let queueA = DispatchQueue(label: "queueA", qos: .background, attributes: .concurrent)
let queueB = DispatchQueue(label: "queueB", attributes: .concurrent)
queueA.async {
    print("assign task")
    queueB.async {
        for i in 0...100 {
            print("🎃🎃🎃🎃🎃 \(i)")
        }
    }
//    queueB.sync {
//        for i in 0...100 {
//            print("🎃🎃🎃🎃🎃 \(i)")
//        }
//    }
    queueA.async {
        for i in 0...100 {
            print("------- \(i)")
        }
    }
    print("done")
}
for i in 100...200 {
    print("♪♪♪♪♪ \(i)")
}


/// 2
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

queue.async(group: group) {
    print("Start job 1")
    Thread.sleep(until: Date().addingTimeInterval(10))
    print("End job 1")
}
queue.async(group: group) {
    print("Start job 2")
    Thread.sleep(until: Date().addingTimeInterval(2))
    print("End job 2")
}

if group.wait(timeout: .now() + 5) == .timedOut {
    print("I got tired of waiting")
} else {
    print("All the jobs have completed")
}

print("Passing group wait")
/*
 Start job 1
 Start job 2
 End job 2
 I got tired of waiting
 Passing group wait
 End job 1
 */




PlaygroundPage.current.finishExecution()
