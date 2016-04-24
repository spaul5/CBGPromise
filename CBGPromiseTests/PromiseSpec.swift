import Quick
import Nimble
import CBGPromise

class PromiseSpec: QuickSpec {
    override func spec() {
        describe("Promise") {
            var subject: Promise<String>!

            beforeEach {
                subject = Promise<String>()
            }

            describe("calling the callback blocks") {
                var result: String!

                context("when the callbacks are registered before the promise is resolved") {
                    beforeEach {
                        subject.future.then { r in
                            result = r
                        }
                    }

                    it("should call the callback when it's resolved") {
                        subject.resolve("My Special Value")

                        expect(result).to(equal("My Special Value"))
                    }
                }

                context("when the callbacks are registered after the promise is resolved") {
                    it("should call the callback when it's resolved") {
                        subject.resolve("My Special Value")

                        subject.future.then { r in
                            result = r
                        }

                        expect(result).to(equal("My Special Value"))
                    }
                }
            }

            describe("accessing the value after the promise has been resolved") {
                it("should expose its value after it has been resolved") {
                    subject.resolve("My Special Value")

                    expect(subject.future.value).to(equal("My Special Value"))
                }
            }

            describe("waiting for the promise to resolve") {
                it("should wait for a value") {
                    let queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), queue) {
                        subject.resolve("My Special Value")
                    }

                    subject.future.wait()

                    expect(subject.future.value).to(equal("My Special Value"))
                }
            }
            
            describe("multiple callbacks") {
                it("calls each callback when the promise is resolved") {
                    var valA: String?
                    var valB: String?

                    subject.future.then { v in valA = v }
                    subject.future.then { v in valB = v }
                    
                    subject.resolve("My Special Value")
                    
                    expect(valA).to(equal("My Special Value"))
                    expect(valB).to(equal("My Special Value"))
                }
            }

            describe("multiple resolving") {
                context("resolving after having been resolved already") {
                    beforeEach {
                        subject.resolve("old")
                    }

                    it("raises an exception") {
                        expect { subject.resolve("new") }.to(raiseException())
                    }
                }
            }
        }
    }
}
