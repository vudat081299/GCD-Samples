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



// MARK: - Group, Semaphores
PlaygroundPage.current.needsIndefiniteExecution = true


let gsGroup = DispatchGroup()
let gsQueue = DispatchQueue.global(qos: .userInteractive)
let semaphore = DispatchSemaphore(value: 2)

let base = "https://wolverine.raywenderlich.com/books/con/image-from-rawpixel-id-"
let ids = [466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052]

var images: [UIImage] = []

// Example 1
for id in ids {
    guard let url = URL(string: "\(base)\(id)-jpeg.jpg") else { continue }
    
    semaphore.wait()
    gsGroup.enter()
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        defer {
            gsGroup.leave()
            semaphore.signal()
        }
        
        if error == nil,
           let data = data,
           let image = UIImage(data: data) {
            images.append(image)
        }
    }
    
    task.resume()
}

gsGroup.notify(queue: gsQueue) {
    images[0]
    
    //: Make sure to tell the playground you're done so it stops.
    PlaygroundPage.current.finishExecution()
}

// Example 2
for i in 1...100 {
    semaphore.wait()
    gsGroup.enter()
    
    gsQueue.async(group: gsGroup) {
        defer {
            gsGroup.leave()
            semaphore.signal()
        }
        
        print("Downloading image \(i)")
        Thread.sleep(forTimeInterval: 3)
        print("Downloaded image \(i)")
    }
}

// MARK: - Priority inversion
// Appear when use semaphore
let high = DispatchQueue.global(qos: .userInteractive)
let medium = DispatchQueue.global(qos: .userInitiated)
let low = DispatchQueue.global(qos: .background)
let piSemaphore = DispatchSemaphore(value: 1)
high.async {
    piSemaphore.wait()
    print("high")
    Thread.sleep(forTimeInterval: 1)
    defer {
        piSemaphore.signal()
        print("High priority task is now running")
    }
}

for i in 1...10 {
    medium.async {
        let waitTime = Double(exactly: arc4random_uniform(7))!
        print("Running medium task \(i)")
        Thread.sleep(forTimeInterval: waitTime)
    }
}

low.async {
    piSemaphore.wait()
    print("low")
    defer {
        piSemaphore.signal()
        print("Running long, lowest priority task")
    }
//    Thread.sleep(forTimeInterval: 5)
}

//high.async {
//    Thread.sleep(forTimeInterval: 1)
//    piSemaphore.wait()
//    print("high")
//    defer {
//        piSemaphore.signal()
//        print("High priority task is now running")
//    }
//}
//
//for i in 1...10 {
//    medium.async {
//        let waitTime = Double(exactly: arc4random_uniform(7))!
//        print("Running medium task \(i)")
//        Thread.sleep(forTimeInterval: waitTime)
//    }
//}
//
//low.async {
//    piSemaphore.wait()
//    print("low")
//    defer {
//        piSemaphore.signal()
//        print("Running long, lowest priority task")
//    }
//    Thread.sleep(forTimeInterval: 5)
//}



// Mark: - Incorrect semephore samples
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInteractive)
let semaphore = DispatchSemaphore(value: 5)
for i in 1...10 {
    queue.async(group: group) {
        semaphore.wait()
//        defer { semaphore.signal() }
        print("start task \(i)")
        Thread.sleep(forTimeInterval: 0.1)
        print("end task \(i)")
    }
}
/* Result - using semaphore without .signal()
 start task 1
 start task 2
 start task 3
 start task 4
 start task 5
 end task 3
 end task 1
 end task 4
 end task 2
 end task 5
 */

let group2 = DispatchGroup()
let queue2 = DispatchQueue.global(qos: .userInteractive)
let semaphore2 = DispatchSemaphore(value: 5)
for i in 1...10 {
    queue2.async(group: group2) {
//        semaphore2.wait()
        defer { semaphore2.signal() }
        print("start task \(i)")
        Thread.sleep(forTimeInterval: 0.1)
        print("end task \(i)")
    }
}
/* Result - using semaphore without .wait()
 start task 1
 start task 2
 start task 3
 start task 4
 start task 5
 start task 6
 start task 7
 start task 8
 start task 9
 start task 10
 end task 4
 end task 3
 end task 8
 end task 9
 end task 2
 end task 1
 end task 6
 end task 5
 end task 7
 end task 10
 */

let group3 = DispatchGroup()
let queue3 = DispatchQueue.global(qos: .userInteractive)
let semaphore3 = DispatchSemaphore(value: 5)
for i in 1...10 {
    queue3.async(group: group3) {
        semaphore3.wait()
        defer { semaphore3.signal() }
        print("start task \(i)")
        Thread.sleep(forTimeInterval: 0.1)
        print("end task \(i)")
    }
}
/* Result - correct method
 start task 1
 start task 2
 start task 3
 start task 4
 start task 5
 end task 2
 end task 3
 end task 1
 end task 5
 end task 4
 start task 6
 start task 8
 start task 7
 start task 9
 start task 10
 end task 8
 end task 6
 end task 10
 end task 7
 end task 9
 */

PlaygroundPage.current.finishExecution()
