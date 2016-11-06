
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class RotationTests: XCTestCase {

    func testConstruction() {
        XCTAssert(quickCheck(Gen<Float>(), size: 100) { a in
            let r = Rotation2D(angle: a * 10 - 5)
            return r.angle >= 0 &&
                r.angle < .tau &&
                sin(r.angle).isClose(to: sin(a * 10 - 5), tolerance: .epsilon * 100)
        })
    }

    func testRotate() {
        XCTAssert(quickCheck(Gen<Float>(), Gen<vec2>(), size: 100) { a, v in
            let r = Rotation2D(angle: a)
            let s = r.apply(v)
            return cos(v.angle(between: s)).isClose(to: cos(a), tolerance: .epsilon * 10) &&
                s.length.isClose(to: v.length, tolerance: .epsilon * 10)
        })
    }

    func testCompose() {
        let v = vec2(1, 0)
        XCTAssert(quickCheck(Gen<Float>(), Gen<Float>(), size: 100) { a, b in
            let r0 = Rotation2D(angle: a)
            let r1 = Rotation2D(angle: b)
            let r = r0.compose(r1)
            return r.apply(v).isClose(to: r1.apply(r0.apply(v)), tolerance: .epsilon * 1000)
        })
    }

    func testInverse() {
        XCTAssert(quickCheck(Gen<Float>(), Gen<vec2>(), size: 100) { a, v in
            let r = Rotation2D(angle: a)
            let s = r.inverse
            return s.apply(r.apply(v)).isClose(to: v, tolerance: .epsilon * 100)
        })
    }

    func testSetAngle() {
        XCTAssert(quickCheck(Gen<Float>(), Gen<Float>(), size: 100) { a, b in
            var r = Rotation2D(angle: a)
            r.angle = b
            return r.angle == b
        })
    }
}
