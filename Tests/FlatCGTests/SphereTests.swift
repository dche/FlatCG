
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class CircleTests: XCTestCase {

    func testConstruction() {
        let c = Point2D.origin
        XCTAssertNil(Circle(center: c, radius: -1))
        XCTAssertNotNil(Circle(x: 0, y: 0, radius: 0))
    }

    func testConstainsPoint() {
        let c = Circle(x: 0, y: 0, radius: 2)!
        XCTAssert(c.contains(point: Point2D(0, 0)))
        XCTAssertFalse(c.contains(point: Point2D(0, 2)))
    }
}
