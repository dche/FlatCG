
import XCTest
import GLMath
@testable import FlatCG

class TransformTests: XCTestCase {

    func testIdentity() {
        let tm = Transform2D.identity
        XCTAssertEqual(tm.matrix, tm.invMatrix)
        XCTAssertEqual(vec2.y.apply(transform: tm), vec2.y)
    }

    func testInverse() {
        let m = mat3(1, 2, 3, 3, 1, 2, 2, 3, 1)
        let minv = m.inverse
        let tm = Transform2D(matrix: m, invMatrix: minv)
        let tminv = tm.inverse
        XCTAssertEqual(tminv.matrix, minv)
        XCTAssertEqual(tminv.invMatrix, m)
    }

    func testCompose() {
        let m0 = Transform2D.identity.translate(x: 1, y: 2)
        let m1 = Transform2D.identity.translate(x: 3, y: 4)
        let m = m0.compose(m1)
        XCTAssertEqual(m, m0.translate(vec2(3, 4)))
        XCTAssertEqual(m, Transform2D.identity.translate(x: 4, y: 6))
    }
}

class TransformableTets: XCTestCase {

    func testTransformIsTransformable() {
        var tm = Transform3D.identity.translate(vec3.x * 10)
        tm = tm.apply(transform: tm)
        let p = Point3D.origin.apply(transform: tm)
        XCTAssertEqual(p, Point3D(20, 0, 0))
    }

    func testTranslate() {
        let tm = Transform3D.identity.translate(x: 1, y: 2, z: 3)
        let p = Point3D(1, 2, 3)
        let v = p.vector
        XCTAssertEqual(p.translate(x: 1, y: 2, z: 3), Point3D(2, 4, 6))
        XCTAssertEqual(v.apply(transform: tm), v)
    }

    func testScale() {
        let p = Point3D(1, 1, 1)
        XCTAssertEqual(p.scale(2), Point3D(2, 2, 2))
        XCTAssertEqual(p.scale(x: 2, y: 0, z: 0.5), Point3D(2, 1, 0.5))
    }

    func testRotation() {
        let p2 = Point2D(vec2.x)
        XCTAssert(p2.rotate(angle: .half_pi) ~== Point2D(vec2.y))

        let v3 = -vec3.z
        XCTAssert(v3.rotate(around: Normal3D(vec3.z), angle: .pi) ~== v3)
        let tm = Transform3D.identity.rotate(around: Normal3D(vec3.x), angle: .pi)
        XCTAssert(v3.apply(transform: tm).isClose(to: -v3, tolerance: .epsilon * 10))
        XCTAssert((-v3.apply(transform: tm.inverse)).isClose(to: v3, tolerance: .epsilon * 10))
    }
}
