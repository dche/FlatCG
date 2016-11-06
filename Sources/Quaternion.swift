//
// FlatCG - Quaternion.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

public struct Quaternion: Rotation {

    public typealias PointType = Point3D

    fileprivate let _rep: vec4

    public var x: Float { return _rep.x }

    public var y: Float { return _rep.y }

    public var z: Float { return _rep.z }

    public var w: Float { return _rep.w }

    public func compose(_ other: Quaternion) -> Quaternion {
        return other * self
    }

    public static let identity =  Quaternion(vec4(0, 0, 0, 1))

    public var inverse: Quaternion {
        // NOTE: `self` is normalized.
        return Quaternion(vec4(-_rep.xyz, _rep.w))
    }

    public func apply(_ vector: vec3) -> vec3 {
        return self * vector
    }

    public var conjugate: Quaternion { return self.inverse }

    public var real: Float { return _rep.w }

    public var imaginary: vec3 { return _rep.xyz }

    fileprivate init (_ v: vec4) {
        if v.isZero {
            self._rep = vec4(0, 0, 0, 1)
        } else {
            self._rep = v.normalize
        }
    }

    public init (_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.init(vec4(x, y, z, w))
    }

    public init (imaginary: vec3, real: Float) {
        self.init(vec4(imaginary, real))
    }
}

extension Quaternion: One {

    public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        let m = mat4(
            vec4(lhs.w, lhs.z, -lhs.y, -lhs.x),
            vec4(-lhs.z, lhs.w, lhs.x, -lhs.y),
            vec4(lhs.y, -lhs.x, lhs.w, -lhs.z),
            lhs._rep
        )
        return Quaternion(m * rhs._rep)
    }

    public static var one: Quaternion {
        return self.identity
    }
}

extension Quaternion {

    public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
        return lhs._rep == rhs._rep
    }

    /// Constructs a Quaternion from axis-angle representation.
    public init (axis: vec3, angle: Float) {
        let v = axis.normalize

        let ha = angle * 0.5
        let a = v * sin(ha)
        let w = cos(ha)
        self.init(imaginary: a, real: w)
    }

    /// Constructs a Quaternion that represents a rotation from direction
    /// `from` to direciton `to`.
    ///
    /// - note: `from` and `to` need _NOT_ be normalized.
    public init (fromDirection from: Normal3D, to: Normal3D) {
        // http://lolengine.net/blog/2013/09/18/beautiful-maths-quaternion-from-vectors
        let w = cross(from.vector, to.vector)
        self.init(imaginary: w, real: 1 + from.dot(to))
    }

    // TODO: Constructs a `Quaternion` from a rotation matrix.

    /// Constructs a `Quaternion` that represents a rotation around x axis.
    ///
    /// - parameter angle: Angle to be rotated.
    ///
    /// - note: Right-hand rule is used.
    public static func pitch(_ angle: Float) -> Quaternion {
        return self.init(axis: vec3(1, 0, 0), angle: angle)
    }

    /// Constructs a `Quaternion` that represents a rotation around y axis.
    ///
    /// - parameter angle: Angle to be rotated.
    ///
    /// - note: Right-hand rule is used.
    public static func yaw(_ angle: Float) -> Quaternion {
        return self.init(axis: vec3(0, 1, 0), angle: angle)
    }

    /// Constructs a `Quaternion` that represents a rotation around z axis.
    ///
    /// - parameter angle: Angle to be rotated.
    ///
    /// - note: Right-hand rule is used.
    public static func roll(_ angle: Float) -> Quaternion {
        return self.init(axis: vec3(0, 0, 1), angle: angle)
    }
}

extension Quaternion {

    /// The axis-angle representation of `self`.
    public var axisAngle: (axis: vec3, angle: Float) {
        let a = acos(self.w) * 2
        if a.isZero {
            // `self.w == 1`.
            return (vec3.zero, 0)
        } else {
            return (normalize(self.imaginary), a)
        }
    }

    public func pitch(_ angle: Float) -> Quaternion {
        return Quaternion.pitch(angle) * self
    }

    public func yaw(_ angle: Float) -> Quaternion {
        return Quaternion.yaw(angle) * self
    }

    public func roll(_ angle: Float) -> Quaternion {
        return Quaternion.roll(angle) * self
    }

    /// Returns the corresponding transform matrix of `self`.
    public var matrix: mat4 {
        let q = _rep
        let c1 = vec4(-(q.y * q.y + q.z * q.z) * 2 + 1, (q.x * q.y + q.w * q.z) * 2, (q.x * q.z - q.w * q.y) * 2, 0)
        let c2 = vec4((q.x * q.y - q.w * q.z) * 2, -(q.x * q.x + q.z * q.z) * 2 + 1, (q.y * q.z + q.w * q.x) * 2, 0)
        let c3 = vec4((q.x * q.z + q.w * q.y) * 2, (q.y * q.z - q.w * q.x) * 2, -(q.x * q.x + q.y * q.y) * 2 + 1, 0)
        return mat4(c1, c2, c3, vec4(0, 0, 0, 1))
    }

    public static func * (lhs: Quaternion, rhs: vec3) -> vec3 {
        let r = lhs.real
        let q = lhs.imaginary
        let c = cross(q, rhs)
        return rhs + c * r * 2 + cross(q * 2, c)
    }
}

extension Quaternion: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Quaternion(x: \(x), y: \(y), z: \(z), w: \(w))"
    }
}

extension Quaternion {

    public typealias NumberType = Float

    public func isClose(to other: Quaternion, tolerance: Float) -> Bool {
        return self._rep.isClose(to: other._rep, tolerance: tolerance)
    }
}
