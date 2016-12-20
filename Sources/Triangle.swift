//
// FlatCG - Triangle.swift
//
// Copyright (c) 2016 The FlagCG authors.
// Licensed under MIT License.

import simd
import GLMath

public protocol Triangle {

    associatedtype PointType: Point

    var a: PointType { get }

    var b: PointType { get }

    var c: PointType { get }

    /// Constructs a `Triangle`.
    ///
    /// - returns: `nil` if `a`, `b` and `c` are colinear.
    init? (_ a: PointType, _ b: PointType, _ c: PointType)

    /// Returns double of area of the triangle.
    ///
    /// - note: The return value is positive if edges `b - a`, `c - b` and
    /// `a - c` are in count clock-wise (CCW) order.
    var area2: PointType.VectorType.Component { get }

    // var barycenter: PointType { get }

    // func constains(point: PointType) -> Bool
}

extension Triangle {

    /// Returns the area of the triangle.
    public var area: PointType.VectorType.Component {
        return area2 * 0.5
    }
}

/// Triangle in 2D Euclidean space.
public struct Triangle2<T: Point> where T.VectorType: Vector2 {

    public typealias PointType = T

    public let a, b, c: T

   public init? (_ a: T, _ b: T, _ c: T) {
       self.a = a
       self.b = b
       self.c = c
       guard self.area2 > 0 else { return nil }
   }

    public var area2: T.VectorType.Component {
        let e0 = (b.x - a.x) * (c.y - a.y)
        let e1 = (b.y - a.y) * (c.x - a.x)
        return e0 - e1
    }

    // TODO: in circle.
}

/// Triangle in 2D Euclidean space.
public struct Triangle3<T: Point>: Triangle where T.VectorType: FloatVector3 {

    public typealias PointType = T

    public let a, b, c: T

    public init? (_ a: T, _ b: T, _ c: T) {
        self.a = a
        self.b = b
        self.c = c
        guard self.area2 > 0 else { return nil }
    }

    public var area2: T.VectorType.Component {
        let ba = b - a
        let ca = c - a
        return ba.cross(ca).length
    }

    /// The surface normal of the triangle.
    public var normal: Normal<T> {
        let ba = b - a
        let ca = c - a
        return Normal<T>(ba.cross(ca))
    }
}

public typealias Triangle2D = Triangle2<Point2D>
public typealias Triangle3D = Triangle3<Point3D>
