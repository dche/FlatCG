//
// FlatCG - Normal.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import simd
import GLMath

/// `Normal` is a `Vector` with restriction that its length must be `1`, i.e.,
/// it always be normalized.
public struct Normal<T: Point>: Equatable {

    public typealias PointType =  T

    public typealias VectorType = T.VectorType

    public typealias Component = VectorType.Component

    /// The vector representation of `self`. It is normalized.
    public let vector: VectorType

    init (_ vector: VectorType) {
        assert(vector.squareLength ~== 1)
        self.vector = vector
    }

    public init (vector: VectorType) {
        self.vector = normalize(vector)
    }

    public func dot(_ other: Normal) -> Component {
        return self.vector.dot(other.vector)
    }

    public static func == (lhs: Normal, rhs: Normal) -> Bool {
        return lhs.vector == rhs.vector
    }

    public static prefix func - (rhs: Normal) -> Normal {
        return Normal(-rhs.vector)
    }
}

extension Normal: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "\(vector)"
    }
}

extension Normal where T.VectorType: Vector2 {

    public init (_ x: Component, _ y: Component) {
        self.init(vector: VectorType(x, y))
    }
}

extension Normal where T.VectorType: Vector3 {

    public init (_ x: Component, _ y: Component, _ z: Component) {
        self.init(vector: VectorType(x, y, z))
    }
}

public typealias Normal2D = Normal<Point2D>
public typealias Normal3D = Normal<Point3D>

// extension Normal: Transformable {
//
// }
