//
// FlatCG - Rotation.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Generic representation of a rotation, eighther in 2D or 3D space.
public protocol Rotation: Equatable, ApproxEquatable, CustomDebugStringConvertible {

    associatedtype PointType: Point

    /// The type of vectors to which `Self` can be applied.
    typealias VectorType = PointType.VectorType

    /// Composes the effects of two rotations. The effect of the result is like
    /// apply `self` first, and then apply the `other`.
    func compose(_ other: Self) -> Self

    /// The identity rotation.
    static var identity: Self { get }

    /// The inverse rotation.
    ///
    /// - invariant: `self.compose(self.inverse) == .identity`.
    var inverse: Self { get }

    /// Rotates a vector.
    ///
    /// - parameter vector: The vector to be rotated.
    func apply(_ vector: VectorType) -> VectorType
}

fileprivate func clamp(_ angle: Float) -> Float {
    var a = mod(angle, .tau)
    if a < 0 { a = .tau + a }
    return a
}

/// 2D rotation.
public struct Rotation2D: Rotation {

    public typealias PointType = Point2D

    public var angle: Float {
        didSet {
            angle = clamp(angle)
            _cos = cos(angle)
            _sin = sin(angle)
        }
    }

    private var _cos: Float
    private var _sin: Float

    public init (angle: Float) {
        self.angle = clamp(angle)
        _cos = cos(angle)
        _sin = sin(angle)
    }

    public func compose(_ other: Rotation2D) -> Rotation2D {
        return Rotation2D(angle: self.angle + other.angle)
    }

    public static let identity = Rotation2D(angle: 0)

    public var inverse: Rotation2D {
        return Rotation2D(angle: -angle)
    }

    public func apply(_ vector: vec2) -> vec2 {
        return vec2(dot(vec2(_cos, -_sin), vector), dot(vec2(_sin, _cos), vector))
    }

    public static func ==(lhs: Rotation2D, rhs: Rotation2D) -> Bool {
        return lhs.angle == rhs.angle
    }
}

extension Rotation2D: Zero {

    public static var zero: Rotation2D { return self.identity }

    public static func +(lhs: Rotation2D, rhs: Rotation2D) -> Rotation2D {
        return lhs.compose(rhs)
    }
}

extension Rotation2D: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Rotation2D(angle: \(self.angle))"
    }
}

extension Rotation2D {

    public typealias NumberType = Float

    public func isClose(to other: Rotation2D, tolerance: Float) -> Bool {
        return self.angle.isClose(to: other.angle, tolerance: tolerance)
    }
}
