
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class SegmentTests: XCTestCase {

    func testConstructor() {
        let s = Point3D.origin
        let e = Point3D(1, 2, 3)
        let seg = Segment(startPoint: s, endPoint: e)!
        XCTAssertEqual(seg.start, s)
        XCTAssertEqual(seg.end, e)
        XCTAssertEqual(seg.direction, Normal(e.vector))
        XCTAssertEqual(seg.length, e.vector.length)
    }

    func testInvalidConstructor() {
        let s = Point3D.origin
        XCTAssertNil(Segment(startPoint: s, endPoint: s))
    }

    func testDistanceToPoint() {
        let s = Segment(startPoint: Point2D.origin, endPoint: Point2D(1, 0))!
        XCTAssertEqual(s.distance(to: Point2D(0.5, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(-0.5, 0)), 0.5)
        XCTAssertEqual(s.distance(to: Point2D(1, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(0, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(0, 1)), 1)
        XCTAssertEqual(s.distance(to: Point2D(0.5, 1)), 1)
    }
}

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
