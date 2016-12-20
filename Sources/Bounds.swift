//
// FlatCG - Circle.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Axis-aligned bounding box.
public protocol Bounds: Equatable, CustomDebugStringConvertible, Transformable {

    associatedtype PointType: Point

    var pmin: PointType { get }

    var pmax: PointType { get }

    init (_ a: PointType, _ b: PointType)

    /// A degenerate bounding box that can be contained in any boxes.
    static var empty: Self { get }

    var surfaceArea: PointType.VectorType.Component { get }

    func contains(point: PointType) -> Bool
}

extension Bounds {

    public init (_ point: PointType) {
        self.init(point, point)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pmin == rhs.pmin && lhs.pmax == rhs.pmax
    }

    public var debugDescription: String {
        return "Bounds(min: \(pmin), max: \(pmax))"
    }
}

extension Bounds {

    /// Returns `true` if the receiver is the empty bounding box.
    public var isEmpty: Bool { return self == .empty }

    /// Merges the receiver with `other` `Bounds`.
    ///
    /// - returns: The new `Bounds`.
    public func merge(_ other: Self) -> Self {
        guard !self.isEmpty else { return other }
        let mn = min(self.pmin.vector, other.pmin.vector)
        let mx = max(self.pmax.vector, other.pmax.vector)
        return Self(PointType(mn), PointType(mx))
    }

    public func merge(point: PointType) -> Self {
        let v = point.vector
        let mn = min(self.pmin.vector, v)
        let mx = max(self.pmax.vector, v)
        return Self(PointType(mn), PointType(mx))
    }

    /// Constructs a `Bounds` that contains all the `points`.
    public init (of points: [PointType]) {
        if points.count < 1 {
            self = .empty
        } else {
            var mn = points[0].vector
            var mx = points[0].vector
            for p in points.dropFirst() {
                mn = min(mn, p.vector)
                mx = max(mx, p.vector)
            }
            self = Self(PointType(mn), PointType(mx))
        }
    }

    /// Expands the bounding box by the amound `delta` in all dimensions.
    public func expand(_ delta: PointType.VectorType.Component) -> Self {
        let d = PointType.VectorType(max(delta, 0))
        let mn = pmin.vector - d
        let mx = pmax.vector + d
        return Self(PointType(mn), PointType(mx))
    }
}

extension Bounds {

    /// Center of the bounding box.
    public var center: PointType {
        if self.isEmpty { return PointType.origin }
        return PointType((self.pmax.vector + self.pmin.vector) * 0.5)
    }

    /// The vector from the minimal point of the `Bounds` to its maximal
    /// point.
    public var diagnal: PointType.VectorType {
        if self.isEmpty { return .zero }
        return self.pmax.vector - self.pmin.vector
    }

    public var extent: PointType.VectorType { return self.diagnal * 0.5 }
}

/// 2D axis-aligned bounding box.
public struct Bounds2<T: Point>: Bounds where T: Transformable, T.TransformType == Transform<T>, T.VectorType: Vector2 {

    public typealias PointType = T

    public let pmin, pmax: T

    private init (_ mn: T.VectorType, _ mx: T.VectorType) {
        self.pmin = PointType(mn)
        self.pmax = PointType(mx)
    }

    public init(_ a: PointType, _ b: PointType) {
        self.init(min(a.vector, b.vector), max(a.vector, b.vector))
    }

    public static var empty: Bounds2<T> {
        return Bounds2<T>(.infinity, -.infinity)
    }

    public var surfaceArea: T.VectorType.Component {
        let d = diagnal
        return d.x * d.y
    }

    public func contains(point: T) -> Bool {
        let v = point.vector
        let vmn = pmin.vector
        let vmx = pmax.vector
        return v.x >= vmn.x && v.x <= vmx.x && v.y >= vmn.y && v.y <= vmx.y
    }

    public func apply(transform: Transform<T>) -> Bounds2<T> {
        let pts = [
            pmin,
            pmax,
            T(T.VectorType(pmin.vector.x, pmax.vector.y)),
            T(T.VectorType(pmax.vector.x, pmin.vector.y))
        ]
        return Bounds2<T>(of: pts.map { $0.apply(transform: transform) })
    }
}

/// 3D axis-aligned bounding box.
public struct Bounds3D: Bounds {

    public typealias PointType = Point3D

    public let pmin, pmax: Point3D

    private init (_ mn: vec3, _ mx: vec3) {
        self.pmin = PointType(mn)
        self.pmax = PointType(mx)
    }

    public init(_ a: Point3D, _ b: Point3D) {
        self.init(min(a.vector, b.vector), max(a.vector, b.vector))
    }

    public static var empty: Bounds3D {
        return Bounds3D(.infinity, -.infinity)
    }

    public var surfaceArea: Float {
        let d: vec3 = self.diagnal
        let a0 = d.x * d.y
        let a1 = d.y * d.z
        let a2 = d.z * d.x
        return (a0 + a1 + a2) * 2
    }

    public var volume: Float {
        let d = diagnal
        return d.x * d.y * d.z
    }

    public func contains(point: Point3D) -> Bool {
        let v = point.vector
        let vmn = pmin.vector
        let vmx = pmax.vector
        return v.x >= vmn.x && v.x <= vmx.x &&
            v.y >= vmn.y && v.y <= vmx.y &&
            v.z >= vmn.z && v.z <= vmx.z
    }

    public func apply(transform: Transform3D) -> Bounds3D {
        let m = transform.matrix
        var nmin = m[3].xyz
        var nmax = nmin
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                let x = m[j, i] * self.pmin.vector[j]
                let y = m[j, i] * self.pmax.vector[j]
                if x < y {
                    nmin[i] += x
                    nmax[i] += y
                } else {
                    nmin[i] += y
                    nmax[i] += x
                }
            }
        }
        return Bounds3D(Point3D(nmin), Point3D(nmax))
    }
}

public typealias Bounds2D = Bounds2<Point2D>
