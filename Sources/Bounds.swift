//
// FlatCG - Circle.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Axis-aligned bounding box.
public struct Bounds<T: Point> {

    public typealias PointType = T

    fileprivate let pmin: T

    fileprivate let pmax: T

    /// Constructs a `Bounds` with given 2 points.
    public init (_ a: T, _ b: T) {
        self.pmin = T(min(a.vector, b.vector))
        self.pmax = T(max(a.vector, b.vector))
    }
}

extension Bounds: Equatable {

    public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
        return lhs.pmin == rhs.pmin && lhs.pmax == rhs.pmax
    }
}

extension Bounds: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Bounds(min: \(pmin), max: \(pmax))"
    }
}

extension Bounds {

    /// Returns `true` if the receiver is empty. 
    ///
    /// An empty `Bounds` has identical maximal and minimal points.
    public var isEmpty: Bool { return pmin == pmax }

    /// Merges the receiver with `other` `Bounds`.
    ///
    /// - returns The new `Bounds`.
    public func merge(_ other: Bounds) -> Bounds {
        let mn = min(self.pmin.vector, other.pmin.vector)
        let mx = max(self.pmax.vector, other.pmax.vector)
        return Bounds(T(mn), T(mx))
    }

    /// Tests if the receiver contains a `point`.
    public func contains(point: T) -> Bool {
        let v = point.vector
        let mn = pmin.vector
        let mx = pmax.vector
        for i in 0 ..< T.VectorType.dimension {
            guard v[i] >= mn[i] && v[i] <= mx[i] else { return false }
        }
        return true
    }

    /// Constructs a `Bounds` that contains all the `points`.
    ///
    /// Returns `nil` if `points` is empty.
    public init? (of points: [T]) {
        guard points.count > 0 else { return nil }

        var mn = points[0].vector
        var mx = points[0].vector
        for p in points.dropFirst() {
            mn = min(mn, p.vector)
            mx = max(mx, p.vector)
        }
        self = Bounds(T(mn), T(mx))
    }
}

extension Bounds {

    /// Center of the `Bounds`.
    public var center: T { return T((self.pmax.vector + self.pmin.vector) * 0.5) }

    /// The vector from the minimal point of the `Bounds` to its maximal
    /// point.
    public var diagnal: T.VectorType { return self.pmax.vector - self.pmin.vector }

    public var extent: T.VectorType { return self.diagnal * 0.5 }
}

public typealias Bounds2D = Bounds<Point2D>

// TODO: boundingCircle, area

public typealias Bounds3D = Bounds<Point3D>

// TODO: boundingSphere, volume
