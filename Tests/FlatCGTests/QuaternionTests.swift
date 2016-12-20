
import XCTest
import simd
import FlatUtil
import GLMath
@testable import FlatCG

class QuaternionTests: XCTestCase {

    func testConstruction() {
        let q = Quaternion(1, 2, 3, 4)
        let v4 = vec4(1, 2, 3, 4).normalize
        XCTAssert(q.imaginary ~== v4.xyz)
        XCTAssert(q.real ~== v4.w)
    }

    // func testFromMatrix() {}

    func testFromAxisAngle() {
        let q = Quaternion(axis: Normal3D(vec3.y), angle: .half_pi)
        let (axis, angle) = q.axisAngle
        XCTAssert(axis ~== vec3(0, 1, 0))
        XCTAssert(angle.isClose(to: .half_pi, tolerance: .epsilon * 10))

        let v = q.apply(vec3(1, 0, 0))
        XCTAssert(v ~== vec3(0, 0, -1))

        XCTAssert(quickCheck(Gen<vec3>(), Gen<Float>(), size: 100) { axis, angle in
            let q = Quaternion(axis: Normal3D(vector: axis), angle: angle * .tau)
            let (ax, ag) = q.axisAngle
            return ax.isClose(to: axis.normalize, tolerance: .epsilon * 1000) && ag.isClose(to: angle * .tau, tolerance: .epsilon * 1000)
        })
    }

    func testFromVectors() {
        XCTAssert(quickCheck(Gen<vec3>(), Gen<vec3>(), size: 100) { a, b in
            let na = Normal<Point3D>(vector: a)
            let nb = Normal<Point3D>(vector: b)
            let q = Quaternion(fromDirection: na, to: nb)
            return q.apply(na.vector).isClose(to: nb.vector, tolerance: .epsilon * 1000)
        })
    }

    func testIendity() {
        let i = Quaternion.identity
        XCTAssert(quickCheck(Gen<vec3>(), size: 100) { v in
            return i.apply(v) == v
        })
    }

    func testInverse() {
        XCTAssert(quickCheck(Gen<vec3>(), Gen<Float>(), size: 100) { i, r in
            let q = Quaternion(imaginary: i, real: r)
            return q.compose(q.inverse).isClose(to: .identity, tolerance: .epsilon * 100)
        })

        XCTAssert(quickCheck(Gen<vec3>(), Gen<Float>(), Gen<vec3>(), size: 100) { i, r, v in
            let q = Quaternion(imaginary: i, real: r)
            let iq = q.inverse
            return iq.apply(q.apply(v)).isClose(to: v, tolerance: .epsilon * 1000)
        })
    }

    func testCompose() {
        XCTAssert(quickCheck(Gen<vec4>(), Gen<vec4>(), Gen<vec3>(), size: 100) { a, b, v in
            let p = Quaternion(imaginary: a.xyz, real: a.w)
            let q = Quaternion(imaginary: b.xyz, real: b.w)
            return q.apply(p.apply(v)).isClose(to: (p.compose(q).apply(v)), tolerance: .epsilon * 1000)
        })
    }

    func testToMatrix() {
        XCTAssert(quickCheck(Gen<vec3>(), Gen<Float>(), Gen<vec3>(), size: 100) { i, r, v in
            let q = Quaternion(imaginary: i, real: r)
            let m = q.matrix
            return q.apply(v).isClose(to: (m * vec4(v, 0)).xyz, tolerance: .epsilon * 1000)
        })
    }

    func testApply() {
        XCTAssert(quickCheck(Gen<vec4>(), Gen<vec3>(), size: 100) { qv, v in
            let n = v.normalize
            let q = Quaternion(imaginary: qv.xyz, real: qv.w)
            let p = Quaternion(imaginary: n, real: 0)
            let a = q.apply(n)
            // q * p * q-1
            let b = q.inverse.compose(p).compose(q)
            return a.isClose(to: b.imaginary, tolerance: .epsilon * 1000)
        })
    }
}
