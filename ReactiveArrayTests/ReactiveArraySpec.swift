//
//  ReactiveArraySpec.swift
//  ReactiveArraySpec
//
//  Created by Guido Marucci Blas on 6/29/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveArray
import ReactiveCocoa

private func waitForOperation<T>(
    fromProducer producer: SignalProducer<Operation<T>, NoError>,
    when: () -> (),
    onInitiate: [T] -> () = {
        fail("Invalid operation type: .Initiate(\($0))")
    },
    onAppend: T -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onAppendContentsOf: [T] -> () = {
        fail("Invalid operation type: .AppendContentsOf(\($0))")
    },
    onInsert: (T, Int) -> () = {
        fail("Invalid operation type: .Insert(\($0), \($1))")
    },
    onReplace: (T, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: [T] -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        waitUntil { done in
            producer.startWithNext { operation in
                switch operation {
                case let .Initiate(values):
                    onInitiate(values)
                case let .Append(value):
                    onAppend(value)
                case let .AppendContentsOf(values):
                    onAppendContentsOf(values)
                case let .Insert(value, index):
                    onInsert(value, index)
                case let .Replace(value, index):
                    onReplace(value, index)
                case let .RemoveElement(index):
                    onDelete(index)
                case let .ReplaceAll(values):
                    onReplaceAll(values)
                case let .RemoveAll(keepCapacity):
                    onRemoveAll(keepCapacity)
                }
                done()
            }
            when()
        }
        
}

private func waitForOperation<T>(
    fromSignal signal: Signal<Operation<T>, NoError>,
    when: () -> (),
    onInitiate: [T] -> () = {
        fail("Invalid operation type: .Initiate(\($0))")
    },
    onAppend: T -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onAppendContentsOf: [T] -> () = {
        fail("Invalid operation type: .AppendContentsOf(\($0))")
    },
    onInsert: (T, Int) -> () = {
        fail("Invalid operation type: .Insert(\($0), \($1))")
    },
    onReplace: (T, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: [T] -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        let producer = SignalProducer<Operation<T>, NoError> { (observer, disposable) in signal.observe(observer) }
        waitForOperation(fromProducer: producer, when: when, onInitiate: onInitiate, onAppend: onAppend, onAppendContentsOf: onAppendContentsOf, onInsert: onInsert, onReplace: onReplace, onDelete: onDelete, onReplaceAll: onReplaceAll, onRemoveAll: onRemoveAll)
}

private func waitForOperation<T>(
    fromArray array: ReactiveArray<T>,
    when: () -> (),
    onInitiate: [T] -> () = {
        fail("Invalid operation type: .Initiate(\($0))")
    },
    onAppend: T -> () = {
        fail("Invalid operation type: .Append(\($0))")
    },
    onAppendContentsOf: [T] -> () = {
        fail("Invalid operation type: .AppendContentsOf(\($0))")
    },
    onInsert: (T, Int) -> () = {
        fail("Invalid operation type: .Insert(\($0), \($1))")
    },
    onReplace: (T, Int) -> () = {
        fail("Invalid operation type: .Replace(\($0), \($1))")
    },
    onDelete: Int -> () = {
        fail("Invalid operation type: .Delete(\($0))")
    },
    onReplaceAll: [T] -> () = {
        fail("Invalid operation type: .ReplaceAll(\($0))")
    },
    onRemoveAll: Bool -> () = {
        fail("Invalid operation type: .RemoveAll(\($0))")
    }
    ) {
        
        waitForOperation(fromSignal: array.signal, when: when, onInitiate: onInitiate, onAppend: onAppend, onAppendContentsOf: onAppendContentsOf, onInsert: onInsert, onReplace: onReplace, onDelete: onDelete, onReplaceAll: onReplaceAll, onRemoveAll: onRemoveAll)
}

class ReactiveArraySpec: QuickSpec {
    
    override func spec() {
        
        var originalData: [Int]!
        var reactiveArray: ReactiveArray<Int>!
        
        beforeEach {
            originalData = [1,2,3,4]
            reactiveArray = ReactiveArray(elements: originalData)
        }
        
        describe("#append") {
            
            it("appends the given element at the end of the array") {
                reactiveArray.append(5)
                
                expect(reactiveArray[reactiveArray.count - 1]).to(equal(5))
            }
            
            it("increments the amount of elements in the array by one") {
                let countBeforeAppend = reactiveArray.count
                
                reactiveArray.append(5)
                
                expect(reactiveArray.count).to(equal(countBeforeAppend + 1))
            }
            
            it("signals an append operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.append(5)
                    },
                    onAppend: { value in
                        expect(value).to(equal(5))
                    }
                )
            }
            
        }
        
        describe("#appendContentsOf") {
            
            var originalCount: Int!
            let additionalArray = [5,6,7,8]
            
            beforeEach {
                originalCount = reactiveArray.count
            }
            
            it("should appendContentsOf the array with an additional array of elements") {
                reactiveArray.appendContentsOf(additionalArray)
                
                var newArray = reactiveArray.array
                newArray.removeRange(0...(originalCount - 1))
                
                expect(newArray).to(equal(additionalArray))
            }
            
            it("should increment the number of elements in the array by the number of new elements") {
                reactiveArray.appendContentsOf(additionalArray)
                
                expect(reactiveArray.count).to(equal(originalCount + additionalArray.count))
            }
            
            it("should signal an `appendContentsOf` operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.appendContentsOf(additionalArray)
                    },
                    onAppendContentsOf: { values in
                        originalData.appendContentsOf(additionalArray)
                        
                        expect(values).to(equal(additionalArray))
                    }
                )
            }
        }
        
        describe("#insert") {
            
            let element = 10
            let index = 1
            
            it("should insert the new element at given index") {
                reactiveArray.insert(element, atIndex: index)
                
                expect(reactiveArray[index]).to(equal(element))
                
                originalData.insert(element, atIndex: index)
                expect(reactiveArray.array).to(equal(originalData))
            }
            
            it("should signal an `Insert` operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.insert(element, atIndex: index)
                    },
                    onInsert: { (value, i) in
                        expect(value).to(equal(element))
                        expect(i).to(equal(index))
                    }
                )
            }
        }
        
        describe("#replace") {
            
            context("when there is a value at the given position") {
                
                it("replaces the old value with the new one") {
                    reactiveArray.replace(5, atIndex: 1)
                    
                    expect(reactiveArray[1]).to(equal(5))
                }
                
                it("signals an `.Replace` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.replace(5, atIndex: 1)
                        },
                        onReplace: { (value, index) in
                            expect(value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
                it("should return the original element at the given index") {
                    let index = 2
                    let originalElement = reactiveArray.array[index]
                    let replacedElement = reactiveArray.replace(9, atIndex: index)
                    
                    expect(replacedElement).to(equal(originalElement))
                }
                
            }
            
            // TODO: Fix this case because this raises an exception that cannot
            // be caught
            //            context("when the index is out of bounds") {
            //
            //                it("raises an exception") {
            //                    expect {
            //                        array.replace(5, atIndex: array.count + 10)
            //                    }.to(raiseException(named: "NSInternalInconsistencyException"))
            //                }
            //
            //            }
            
        }
        
        describe("#removeAtIndex") {
            
            it("removes the element at the given position") {
                reactiveArray.removeAtIndex(1)
                
                expect(reactiveArray.array).to(equal([1,3,4]))
            }
            
            it("signals a delete operation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.removeAtIndex(1)
                    },
                    onDelete: { index in
                        expect(index).to(equal(1))
                    }
                )
            }
            
            it("should return the element that is being removed") {
                let index = 1
                let originalElement = reactiveArray.array[index]
                let removedElement = reactiveArray.removeAtIndex(index)
                
                expect(removedElement).to(equal(originalElement))
            }
        }
        
        describe("#replaceAll") {
            
            let data = [1,3,5,7,9]
            
            it("should replace the element with a new array of data") {
                reactiveArray.replaceAll(data)
                
                expect(reactiveArray.array).to(equal(data))
            }
            
            it("should signal a `ReplaceAll` opearation") {
                waitForOperation(
                    fromArray: reactiveArray,
                    when: {
                        reactiveArray.replaceAll(data)
                    },
                    onReplaceAll: { values in
                        expect(values).to(equal(data))
                        expect(values).toNot(equal(originalData))
                    }
                )
            }
        }
        
        describe("#removeAll") {
            
            let removeOp = { (keepCapacity: Bool) in
                waitUntil { done in
                    let countBeforeOperation = reactiveArray.count
                    
                    reactiveArray.observableCount.producer
                        .take(2)
                        .collect()
                        .startWithNext { counts in
                            expect(counts).to(equal([countBeforeOperation, 0]))
                            done()
                    }
                    
                    reactiveArray.removeAll(keepCapacity)
                }
            }
            
            context("when `keepCapacity` is set to `true`") {
                
                it("should remove all elements in the array") {
                    removeOp(true)
                }
                
                it("should signal a `RemoveAll` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.removeAll(true)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(true))
                        }
                    )
                }
            }
            
            context("when `keepCapacity` is set to `false`") {
                it("should remove all elements in the array") {
                    removeOp(false)
                }
                
                it("should signal a `RemoveAll` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray.removeAll(false)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(false))
                        }
                    )
                }
            }
        }
        
        describe("#[]") {
            
            it("returns the element at the given position") {
                expect(reactiveArray[2]).to(equal(3))
            }
        }
        
        describe("#[]=") {
            
            context("when there is a value at the given position") {
                
                it("replaces the old value with the new one") {
                    reactiveArray[1] = 5
                    
                    expect(reactiveArray[1]).to(equal(5))
                }
                
                it("signals an `.Replace` operation") {
                    waitForOperation(
                        fromArray: reactiveArray,
                        when: {
                            reactiveArray[1] = 5
                        },
                        onReplace: { (value, index) in
                            expect(value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
        }
        
        describe("#mirror") {
            
            var mirror: ReactiveArray<Int>!
            let newElements = [1,2,3,4,5]
            
            beforeEach {
                mirror = reactiveArray.mirror { $0 + 10 }
            }
            
            it("returns a new reactive array that maps the values of the original array") {
                expect(mirror.array).to(equal(originalData.map { $0 + 10 }))
            }
            
            context("when an `.Append` is executed on the original array") {
                
                it("signals a mapped `Append` operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.append(5)
                        },
                        onAppend: { value in
                            expect(value).to(equal(15))
                        }
                    )
                }
            }
            
            context("when an `.AppendContentsOf` is executed on the original array") {
                it("should signal a mapped `appendContentsOf` operation") {
                    let mappedNewElements = newElements.map { $0 + 10 }
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.appendContentsOf(newElements)
                        },
                        onAppendContentsOf: { values in
                            expect(values).to(equal(mappedNewElements))
                        }
                    )
                }
            }
            
            context("when an `.Insert` is executed on the original array") {
                it("should signal a mapped `Insert` operation") {
                    let newElement = 2
                    let index = 4
                    
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.insert(newElement, atIndex: index)
                        },
                        onInsert: { value, i in
                            expect(value).to(equal(newElement + 10))
                            expect(i).to(equal(index))
                        }
                    )
                }
            }
            
            context("when a `.Replace` is executed on the original array") {
                
                it("signals a mapped `.Replace` operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray[1] = 5
                        },
                        onReplace: { (value, index) in
                            expect(value).to(equal(15))
                            expect(index).to(equal(1))
                        }
                    )
                }
            }
            
            context("when a `.RemoveAtIndex` is executed on the original array") {
                
                it("signals a mapped `RemoveAtIndex` operation") {
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.removeAtIndex(1)
                        },
                        onDelete: { index in
                            expect(index).to(equal(1))
                        }
                    )
                }
            }
            
            context("when a `.ReplaceAll` is executed on the original array") {
                it("should signal a mapped `ReplaceAll` operation") {
                    let mappedNewElements = newElements.map { $0 + 10 }
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.replaceAll(newElements)
                        },
                        onReplaceAll: { values in
                            expect(values).to(equal(mappedNewElements))
                        }
                    )
                    
                }
            }
            
            context("when a `.RemoveAll` is executed on the original array") {
                it("should signal a mapped `RemoveAll` operation") {
                    let keep = true
                    waitForOperation(
                        fromArray: mirror,
                        when: {
                            reactiveArray.removeAll(keep)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(keep))
                        }
                    )
                    
                }
            }
        }
        
        describe("#producer") {
            
            var a: ReactiveArray<Int>!
            let orignalDataArray = [3,5,76,3,6,4,6]
            
            beforeEach {
                a = ReactiveArray(elements: orignalDataArray)
            }
            
            context("when the array has elements") {
                
                it("signals an `.Initiate` operation for each stored element") {
                    waitUntil { done in
                        
                        a.producer
                            .startWithNext { operation in
                                let result = operation == Operation.Initiate(values: orignalDataArray)
                                expect(result).to(beTrue())
                                done()
                        }
                    }
                }
                
            }
            
            context("when an `.Append` operation is executed in the original array") {
                
                it("forwards the operation") {
                    
                    waitForOperation(
                        fromProducer: a.producer.skip(1),
                        when: {
                            a.append(5)
                        },
                        onAppend: { value in
                            expect(value).to(equal(5))
                        }
                    )
                }
                
            }
            
            context("when an `.AppendContentsOf` operation is executed in the original array") {
                
                it("forwards the operation") {
                    let newElements = [1,2,3,4,5]
                    
                    waitForOperation(
                        fromProducer: a.producer.skip(1),  // skip the `Initiate` operations happened when the array is initialized.
                        when: {
                            a.appendContentsOf(newElements)
                        },
                        onAppendContentsOf: { values in
                            expect(values).to(equal(newElements))
                        }
                    )
                }
            }
            
            context("when an `.Insert` operation is executed in the original array") {
                
                it("forwards the operation") {
                    let newElement = 2
                    let index = 4
                    
                    waitForOperation(
                        fromProducer: a.producer.skip(1),  // skip the `Initiate` operations happened when the array is initialized.
                        when: {
                            a.insert(newElement, atIndex: index)
                        },
                        onInsert: { value, i in
                            expect(value).to(equal(newElement))
                            expect(i).to(equal(index))
                        }
                    )
                }
            }
            
            context("when an `.Replace` operation is executed in the original array") {
                
                it("forwards the operation") {
                    waitForOperation(
                        fromProducer: a.producer.skip(1), // Skips the operation triggered due to the array not being empty
                        when: {
                            a.replace(5, atIndex: 0)
                        },
                        onReplace: { (value, index) in
                            expect(value).to(equal(5))
                            expect(index).to(equal(0))
                        }
                    )
                }
                
            }
            
            context("when a `.RemoveAtIndex` operation is executed in the original array") {
                
                it("forwards the operation") {
                    waitForOperation(
                        fromProducer: a.producer.skip(1), // Skips the operation triggered due to the array not being empty
                        when: {
                            a.removeAtIndex(0)
                        },
                        onDelete: { index in
                            expect(index).to(equal(0))
                        }
                    )
                }
                
            }
            
            context("when a `.ReplaceAll` operation is executed in the original array") {
                
                it("forwards the operation") {
                    let newElements = [1,2,3,4,5]
                    
                    waitForOperation(
                        fromProducer: a.producer.skip(1),
                        when: {
                            a.replaceAll(newElements)
                        },
                        onReplaceAll: { values in
                            expect(values).to(equal(newElements))
                        }
                    )
                }
            }
            
            context("when a `.RemoveAll` operation is exeucte in the original array") {
                
                it("forwards the operation") {
                    let keep = true
                    waitForOperation(
                        fromProducer: a.producer.skip(1),
                        when: {
                            a.removeAll(keep)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(keep))
                        }
                    )
                }
            }
        }
        
        describe("#signal") {
            
            context("when an `.Append` operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.append(5)
                        },
                        onAppend: { value in
                            expect(value).to(equal(5))
                        }
                    )
                }
            }
            
            context("when an `.AppendContentsOf` operation is executed") {
                let newElements = [1,2,3,4,5,6,7,8]
                
                it("should signal the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.appendContentsOf(newElements)
                        },
                        onAppendContentsOf: { values in
                            expect(values).to(equal(newElements))
                        }
                    )
                }
            }
            
            context("when an `.Insert` opeartion is exeucted") {
                it("should signal the operation") {
                    let newElement = 5
                    let index = 2
                    
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.insert(newElement, atIndex: index)
                        },
                        onInsert: { value, i in
                            expect(value).to(equal(newElement))
                            expect(i).to(equal(index))
                        }
                    )
                }
            }
            
            context("when an `.Replace` operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.replace(5, atIndex: 1)
                        },
                        onReplace: { (value, index) in
                            expect(value).to(equal(5))
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
            context("when a `.RemoveAtIndex` operation is executed") {
                
                it("signals the operations") {
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.removeAtIndex(1)
                        },
                        onDelete: { index in
                            expect(index).to(equal(1))
                        }
                    )
                }
                
            }
            
            context("when a `.ReplaceAll` operation is executed in the original array") {
                
                it("forwards the operation") {
                    let newElements = [1,2,3,4,5]
                    
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.replaceAll(newElements)
                        },
                        onReplaceAll: { values in
                            expect(values).to(equal(newElements))
                        }
                    )
                }
            }
            
            context("when a `.RemoveAll` operation is exeucte in the original array") {
                
                it("forwards the operation") {
                    let keep = true
                    waitForOperation(
                        fromSignal: reactiveArray.signal,
                        when: {
                            reactiveArray.removeAll(keep)
                        },
                        onRemoveAll: { keepCapacity in
                            expect(keepCapacity).to(equal(keep))
                        }
                    )
                }
            }
        }
        
        describe("observableCount") {
            
            var countBeforeOperation: Int!
            var producer: SignalProducer<Int, NoError>!
            let newElements = [1,2,3,4,5,6,7,8]
            
            beforeEach {
                countBeforeOperation = reactiveArray.count
                producer = reactiveArray.observableCount.producer
            }
            
            it("returns the initial amount of elements in the array") {
                producer.startWithNext { count in
                    expect(count).to(equal(countBeforeOperation))
                }
            }
            
            context("when an `.Append` operation is executed") {
                
                it("updates the count") {
                    waitUntil { done in
                        producer
                            .skip(1)
                            .startWithNext { count in
                                expect(count).to(equal(countBeforeOperation + 1))
                                done()
                        }
                        
                        reactiveArray.append(656)
                    }
                }
                
            }
            
            context("when an `.AppendContentsOf` operation is executed") {
                
                it("should update the count by the number of new elements") {
                    waitUntil { done in
                        producer
                            .take(2)
                            .collect()
                            .startWithNext { counts in
                                expect(counts).to(equal([countBeforeOperation, countBeforeOperation + newElements.count]))
                                done()
                        }
                        
                        reactiveArray.appendContentsOf(newElements)
                    }
                }
            }
            
            context("when an `.Insert` operation is executed") {
                it("should update the count by an increment of 1") {
                    waitUntil { done in
                        producer
                            .take(2)
                            .collect()
                            .startWithNext { counts in
                                expect(counts).to(equal([countBeforeOperation, countBeforeOperation + 1]))
                                done()
                        }
                        
                        reactiveArray.insert(5, atIndex: 2)
                    }
                }
            }
            
            context("when an `.Replace` operation is executed") {
                
                it("does not update the count") {
                    waitUntil { done in
                        producer
                            .take(2)
                            .collect()
                            .startWithNext { counts in
                                expect(counts).to(equal([countBeforeOperation, countBeforeOperation]))
                                done()
                        }
                        
                        reactiveArray.replace(657, atIndex: 1)
                        reactiveArray.append(656)
                    }
                }
                
            }
            
            context("when a `.RemoveAtIndex` operation is executed") {
                
                it("updates the count") {
                    waitUntil { done in
                        producer
                            .skip(1)
                            .startWithNext { count in
                                expect(count).to(equal(countBeforeOperation - 1))
                                done()
                        }
                        
                        reactiveArray.removeAtIndex(1)
                    }
                }
                
            }
            
            context("when a `.ReplaceAll` operation is executed") {
                it("updates the count") {
                    
                    waitUntil { done in
                        producer
                            .take(2)
                            .collect()
                            .startWithNext { counts in
                                expect(counts).to(equal([countBeforeOperation, newElements.count]))
                                done()
                        }
                        
                        reactiveArray.replaceAll(newElements)
                    }
                }
            }
            
            context("when a `RemoveAll` operation is executed") {
                it("updates the count") {
                    waitUntil { done in
                        producer
                            .take(2)
                            .collect()
                            .startWithNext { counts in
                                expect(counts).to(equal([countBeforeOperation, 0]))
                                done()
                        }
                        
                        reactiveArray.removeAll(true)
                    }
                }
            }
        }
        
        describe("isEmpty") {
            
            context("when the array is empty") {
                
                it("returns true") {
                    expect(ReactiveArray<Int>().isEmpty).to(beTrue())
                }
                
            }
            
            context("when the array is not empty") {
                
                it("returns false") {
                    expect(reactiveArray.isEmpty).to(beFalse())
                }
                
            }
            
        }
        
        describe("count") {
            
            it("returns the amount of elements in the array") {
                expect(reactiveArray.count).to(equal(originalData.count))
            }
            
        }
        
        describe("startIndex") {
            
            context("when the array is not empty") {
                
                it("returns the index of the first element") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
            context("when the array is empty") {
                
                beforeEach {
                    reactiveArray = ReactiveArray<Int>()
                }
                
                it("returns the index of the first element") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
        }
        
        describe("endIndex") {
            
            context("when the array is not empty") {
                
                it("returns the index of the last element plus one") {
                    expect(reactiveArray.endIndex).to(equal(reactiveArray.count))
                }
                
            }
            
            context("when the array is empty") {
                
                beforeEach {
                    reactiveArray = ReactiveArray<Int>()
                }
                
                it("returns zero") {
                    expect(reactiveArray.startIndex).to(equal(0))
                }
                
            }
            
        }
        
        describe("first") {
            
            it("returns the first element in the array") {
                expect(reactiveArray.first).to(equal(originalData[0]))
            }
            
            context("when the array is empty") {
                it("should return nil") {
                    reactiveArray = ReactiveArray()
                    expect(reactiveArray.first).to(beNil())
                }
            }
        }
        
        describe("last") {
            
            it("returns the last element in the array") {
                expect(reactiveArray.last).to(equal(4))
            }
            
            context("when the array is empty") {
                it("should return nil") {
                    reactiveArray = ReactiveArray()
                    expect(reactiveArray.last).to(beNil())
                }
            }
        }
        
    }
    
}
