
import XCTest
import GLMath
@testable import FlatCG

import XCTest

class SegmentTests: XCTestCase {

    func testConstructor() {
        let s = Point3D.origin
        let e = Point3D(1, 2, 3)
        let seg = Segment(start: s, end: e)!
        XCTAssertEqual(seg.start, s)
        XCTAssertEqual(seg.end, e)
        XCTAssertEqual(seg.direction, Normal(vector: e.vector))
        XCTAssertEqual(seg.length, e.vector.length)
    }

    func testInvalidConstructor() {
        let s = Point3D.origin
        XCTAssertNil(Segment(start: s, end: s))
    }

    func testDistanceToPoint() {
        let s = Segment(start: Point2D.origin, end: Point2D(1, 0))!
        XCTAssertEqual(s.distance(to: Point2D(0.5, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(-0.5, 0)), 0.5)
        XCTAssertEqual(s.distance(to: Point2D(1, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(0, 0)), 0)
        XCTAssertEqual(s.distance(to: Point2D(0, 1)), 1)
        XCTAssertEqual(s.distance(to: Point2D(0.5, 1)), 1)
    }

    func testRightOfPoint() {

    }
}
