//
//  OperationSpec.swift
//  ReactiveArray
//
//  Created by Guido Marucci Blas on 7/2/15.
//  Copyright (c) 2015 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveArray
import ReactiveCocoa

class OperationSpec: QuickSpec {
    
    override func spec() {
        
        var operation: Operation<Int>!
        
        describe("#map") {
            
            context("when the operation is an `.Initiate` operation") {
                let data = [10, 20, 30]
                beforeEach {
                    operation = Operation.Initiate(values: data)
                }
                
                it("maps the value to be initiated") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.Initiate(values: data.map { $0 * 2})
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is an `.Append` operation") {
                
                beforeEach {
                    operation = Operation.Append(value: 10)
                }
                
                it("maps the value to be appended") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.Append(value: 20)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is an `.AppendContentsOf` operation") {
                let array = [1,2,3,4]
                beforeEach {
                    operation = Operation.AppendContentsOf(values: array)
                }
                it("should map the value to be extended") {
                    let mappedOperation = operation.map { $0 * 3 }
                    
                    let areEqual = mappedOperation == Operation.AppendContentsOf(values: array.map { $0 * 3 })
                    expect(areEqual).to(beTrue())
                }
            }
            
            context("when the operation is an `.Insert` operation") {
                let original = 11
                let index = 3
                
                beforeEach {
                    operation = Operation.Insert(value: 11, atIndex: index)
                }
                
                it("should map the value to be inserted") {
                    let mappedOperation = operation.map { $0 * 4 }
                    
                    let areEqual = mappedOperation == Operation.Insert(value: original * 4, atIndex: index)
                    expect(areEqual).to(beTrue())
                }
            }
            
            context("when the operation is an `.Replace` operation") {
                
                beforeEach {
                    operation = Operation.Replace(value: 10, atIndex: 5)
                }
                
                it("maps the value to be replaced") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.Replace(value: 20, atIndex: 5)
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the operation is a `RemoveElement` operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("does nothing") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == operation
                    expect(areEqual).to(beTrue())
                }
                
            }
            
            context("when the opearation is a `ReplaceAll` operation") {
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: [1,2,3,4])
                }
                
                it("replaces the original data with a new array") {
                    let mappedOperation = operation.map { $0 * 2 }
                    
                    let areEqual = mappedOperation == Operation.ReplaceAll(values: [2,4,6,8])
                    expect(areEqual).to(beTrue())
                }
            }
        }
        
        describe("#value") {
            
            context("when the operation is an `Initiate` operation") {
                let array = [1,2,3,4,5]
                beforeEach {
                    operation = Operation.Initiate(values: array)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
            }
            
            context("when the operation is an `Append` operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Append(value: data)
                }
                
                it("returns the appended value") {
                    expect(operation.value).to(equal(data))
                }
                
            }
            
            context("when the operation is an `AppendContentsOf` operation") {
                let array = [1,2,3,4,5]
                beforeEach {
                    operation = Operation.AppendContentsOf(values: array)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
            }
            
            context("when the operation is an `Insert` operation") {
                let data = 12
                let index = 1
                
                beforeEach {
                    operation = Operation.Insert(value: data, atIndex: index)
                }
                
                it("should return the inserted value") {
                    expect(operation.value).to(equal(data))
                }
            }
            
            context("when the operation is an `Replace` operation") {
                let data = 10
                
                beforeEach {
                    operation = Operation.Replace(value: data, atIndex: 5)
                }
                
                it("returns the replaced value") {
                    expect(operation.value).to(equal(data))
                }
            }
            
            context("when the operation is an `RemoveElement` operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
            context("when the operation is an `ReplaceAll` operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: array)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
            context("when the operation is an `RemoveAll` operation") {
                
                beforeEach {
                    operation = Operation.RemoveAll(keepCapacity: true)
                }
                
                it("returns .None") {
                    expect(operation.value).to(beNil())
                }
                
            }
            
        }
        
        describe("#arrayValue") {
            
            context("when the operation is an `Initiate` operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.Initiate(values: array)
                }
                
                it("returns the value that's going to replace all") {
                    expect(operation.arrayValue).to(equal(array))
                }
            }
            
            context("when the operation is an `Append` operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Append(value: data)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an `AppendContentsOf` operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.AppendContentsOf(values: array)
                }
                
                it("returns the value that's going to replace all") {
                    expect(operation.arrayValue).to(equal(array))
                }
            }
            
            context("when the operation is an `Insert` operation") {
                
                let data = 12
                let index = 1
                
                beforeEach {
                    operation = Operation.Insert(value: data, atIndex: index)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
            }
            
            context("when the operation is an `Replace` operation") {
                
                let data = 10
                
                beforeEach {
                    operation = Operation.Replace(value: data, atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an `RemoveElement` operation") {
                
                beforeEach {
                    operation = Operation.RemoveElement(atIndex: 5)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
            
            context("when the operation is an `ReplaceAll` operation") {
                
                let array = [1,2,3,4,5]
                
                beforeEach {
                    operation = Operation.ReplaceAll(values: array)
                }
                
                it("returns the value that's going to replace all") {
                    expect(operation.arrayValue).to(equal(array))
                }
            }
            
            context("when the operation is an `RemoveAll` operation") {
                
                beforeEach {
                    operation = Operation.RemoveAll(keepCapacity: true)
                }
                
                it("returns .None") {
                    expect(operation.arrayValue).to(beNil())
                }
                
            }
        }
        
    }
    
}