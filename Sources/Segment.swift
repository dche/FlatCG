//
// FlatCG - Segment.swift
//
// Copyright (c) 2016 The GLMath authors.
// Licensed under MIT License.

import simd
import GLMath

/// Line `Segment` in Euclidean space.
public struct Segment<T: Point> {

    public typealias DirectionType = Normal<T>

    /// Start point.
    public let start: T

    /// End point.
    public let end: T

    /// Direction from start point to end point.
    public var direction: DirectionType {
        return DirectionType(vector: end - start)
    }

    /// Length of the segment.
    public var length: T.VectorType.Component {
        return start.distance(to: end)
    }

    init (_ s: T, _ e: T) {
        self.start = s
        self.end = e
    }

    /// Constructs a line segment.
    ///
    /// Returns `nil` if the `startPoint` and `endPoint` are too close.
    public init? (start: T, end: T) {
        guard !((end - start).squareLength ~== 0) else { return nil }

        self.start = start
        self.end = end
    }
}

extension Segment: Equatable {

    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

extension Segment {

    public static prefix func - (rhs: Segment) -> Segment {
        return Segment(start: rhs.end, end: rhs.start)!
    }
}

extension Segment: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Segment(start: \(start), end: \(end))"
    }
}

// MARK: Segment point relationship.

extension Segment {

    /// Minimal distance from a `point` to the line segment.
    public func distance(to point: T) -> T.VectorType.Component {
        let vp = point - self.start
        let vl = self.end - self.start
        let v = vp.projection(on: vl)
        // `v` is perpendicular to `vl`.
        guard !v.isZero else {
            return vp.length
        }
        if v.squareLength < vl.squareLength && (vl - v).squareLength < vl.squareLength {
            let ln = Line<T>(origin: start, direction: DirectionType(vector: vl))
            return ln.distance(to: point)
        }
        if v.dot(vl) <= 0 {
            return point.distance(to: self.start)
        }
        return point.distance(to: self.end)
    }
}

// SWIFT REVOLUTION: DRY after Swift's generic type is barely useful.

extension Segment where T.VectorType: Vector2 {

    /// Returns `true` if the segment is at the right side of `point`.
    public func right(of point: T) -> Bool {
        guard let tr = Triangle2<T>(start, end, point) else { return false }
        return tr.area2 > 0
    }
}

extension Segment where T.VectorType: FloatVector3 {

    /// Returns `true` if the segment is at the right side of `point`.
    public func right(of point: T) -> Bool {
        guard let tr = Triangle3<T>(start, end, point) else { return false }
        return tr.area2 > 0
    }
}
