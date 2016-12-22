//
// FlatCG - Polygon.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Simple polygon without hole, in Euclidean space.
public struct Polygon<T: Point> {

    fileprivate var _points: [T]

    /// Constructs a simple polygon.
    public init (points: [T] = []) {
        self._points = points
    }

    public init (_ points: T...) {
        self.init(points: points)
    }
}

extension Polygon {

    public var points: [T] { return _points }

    public var isEmpty: Bool { return _points.count == 0 }

    public var pointCount: Int { return _points.count }

    public var segments: [Segment<T>] {
        guard pointCount > 1 else { return [] }
        return (1 ..< _points.count).map { i in
            return Segment<T>(_points[i - 1], _points[i])
        }
    }
}
