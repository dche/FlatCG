
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class LineTests: XCTestCase {

    func testConstruction() {
        let l = Line(origin: Point2D.origin, direction: Normal(vec2(1, 0)))
        XCTAssert(l.origin.vector.isZero)
        XCTAssertEqual(l.direction.vector, vec2(1, 0))

        let ol = Line(origin: Point2D(-1, 2), to: Point2D(-1, 2))
        XCTAssertNil(ol)
    }

    func testPointAtT() {
        let l = Line(origin: Point2D(-1, 2), to: Point2D(2, 2))!
        XCTAssertEqual(l.point(at: 0), Point2D(-1, 2))
        XCTAssertEqual(l.point(at: 3), Point2D(2, 2))
    }
}
