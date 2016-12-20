//
// FlatCG - Transformable.swift
//
// Copyright (c) 2016 The FlatCG authors.
// Licensed under MIT License.

import simd
import GLMath

/// Types that can be transformed by certain `Transform` object.
public protocol Transformable {

    associatedtype PointType: Point

    associatedtype TransformType = Transform<PointType>

    /// Applies `transform` to `self` and produces an instance of same type
    /// as `self`.
    func apply(transform: TransformType) -> Self
}

// SWIFT EVOLUTION: We have to define the type constraint so concrete because 
//                  Swift's generic type system can't handle generic constraints
//                  that have indiretions.

extension Transformable where TransformType == Transform<Point2D> {

    public func translate(_ v: vec2) -> Self {
        var m = mat3.identity
        var minv = m
        m[2] = m[2] + vec3(v, 0)
        minv[2] = minv[2] + vec3(-v, 0)
        return self.apply(transform: Transform<Point2D>(matrix: m, invMatrix: minv))
    }

    public func translate(x: Float, y: Float) -> Self {
        return self.translate(vec2(x, y))
    }

    public func scale(_ v: vec2) -> Self {
        let vv = v.map { f in return f > 0 ? f : 1 }
        let vinv = v.recip
        var m = mat3.identity
        var minv = m
        m[0, 0] = vv.x
        m[1, 1] = vv.y
        minv[0, 0] = vinv.x
        minv[1, 1] = vinv.y
        return self.apply(transform: Transform<Point2D>(matrix: m, invMatrix: minv))
    }

    public func scale(x: Float, y: Float) -> Self {
        return self.scale(vec2(x, y))
    }

    public func scale(_ x: Float) -> Self {
        return self.scale(vec2(x))
    }

    public func rotate(around: Point2D, angle: Float) -> Self {
        let c = cos(angle)
        let s = sin(angle)
        let rc = 1 - c
        let tx = dot(vec2(rc, s), around.vector)
        let ty = dot(vec2(-s, rc), around.vector)
        let m = mat3(vec3(c, s, 0), vec3(-s, c, 0), vec3(tx, ty, 1))
        var minv = m
        minv[0, 1] = -s
        minv[1, 0] = s
        minv[2, 0] = dot(vec2(rc, -s), around.vector)
        minv[2, 1] = dot(vec2(s, rc), around.vector)
        return self.apply(transform: Transform<Point2D>(matrix: m, invMatrix: minv))
    }

    public func rotate(angle: Float) -> Self {
        return self.rotate(around: Point2D.origin, angle: angle)
    }
}

extension Transformable where TransformType == Transform<Point3D> {

    public func translate(_ v: vec3) -> Self {
        var m = mat4.identity
        var minv = m
        m[3] = m[3] + vec4(v, 0)
        minv[3] = minv[3] + vec4(-v, 0)
        return self.apply(transform: Transform<Point3D>(matrix: m, invMatrix: minv))
    }

    public func translate(x: Float, y: Float, z: Float) -> Self {
        return self.translate(vec3(x, y, z))
    }

    public func scale(_ v: vec3) -> Self {
        let vv = v.map { f in return f > 0 ? f : 1 }
        let vinv = vv.recip
        var m = mat4.identity
        var minv = m
        m[0][0] = vv.x
        m[1][1] = vv.y
        m[2][2] = vv.z
        minv[0][0] = vinv.x
        minv[1][1] = vinv.y
        minv[2][2] = vinv.z
        return self.apply(transform: Transform<Point3D>(matrix: m, invMatrix: minv))
    }

    public func scale(x: Float, y: Float, z: Float) -> Self {
        return self.scale(vec3(x, y, z))
    }

    public func scale(_ x: Float) -> Self {
        return self.scale(vec3(x))
    }

    public func rotate(around: Normal3D, angle: Float) -> Self {
        let q = Quaternion(axis: around, angle: angle)
        let qinv = q.inverse
        let tm = Transform<Point3D>(matrix: q.matrix, invMatrix: qinv.matrix)
        return self.apply(transform: tm)
    }
}

extension Transform {

    public func apply<S: Transformable>(_ x: S) -> S where S.TransformType == Transform {
        return x.apply(transform: self)
    }
}

extension Transform: Transformable {

    public func apply(transform: Transform) -> Transform {
        return self.compose(transform)
    }
}

extension vec2: Transformable {

    public typealias PointType = Point2D

    public func apply(transform: Transform2D) -> vec2 {
        return (transform.matrix * vec3(self, 0)).xy
    }
}

extension vec3: Transformable {

    public typealias PointType = Point3D

    public func apply(transform: Transform3D) -> vec3 {
        return (transform.matrix * vec4(self, 0)).xyz
    }
}

extension Point2D: Transformable {

    public typealias PointType = Point2D

    public func apply(transform: Transform2D) -> Point2D {
        var v = vec3(self.vector, 1)
        v = transform.matrix * v
        return Point2D(v.xy)
    }
}

extension Point3D: Transformable {

    public typealias PointType = Point3D

    public func apply(transform: Transform3D) -> Point3D {
        var v = vec4(self.vector, 1)
        v = transform.matrix * v
        return Point3D(v.xyz)
    }
}
