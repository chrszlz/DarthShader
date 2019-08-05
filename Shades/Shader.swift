//
//  Shader.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Foundation

public typealias Shader = String
public extension Shader {
    
    static let megaTest: Shader =
    """
    float circle(vec2 st, vec2 pos, float radius, float edge) {
        st = pos-st;
        float r = length(st) * 4.0;
        float f = radius;
        return 1.0-smoothstep(f-edge, f+edge, r);
    }
    
    float circleb(vec2 st, vec2 pos, float radius, float edge, float w) {
        return circle(st,pos,radius,edge) - circle(st,pos,radius-w,edge);
    }
    
    vec3 mod289(vec3 x) {
        return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec2 mod289(vec2 x) {
        return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec3 permute(vec3 x){
        return mod289(((x*34.0)+1.0)*x);
    }
    
    float snoise(vec2 v) {
        // Precompute values for skewed triangular grid
        const vec4 C = vec4(0.211324865405187,
        // (3.0-sqrt(3.0))/6.0
        0.366025403784439,
        // 0.5*(sqrt(3.0)-1.0)
        -0.577350269189626,
        // -1.0 + 2.0 * C.x
        0.024390243902439);
        // 1.0 / 41.0
        
        // First corner (x0)
        vec2 i  = floor(v + dot(v, C.yy));
        vec2 x0 = v - i + dot(i, C.xx);
        
        // Other two corners (x1, x2)
        vec2 i1 = vec2(0.0);
        i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
        vec2 x1 = x0.xy + C.xx - i1;
        vec2 x2 = x0.xy + C.zz;
        
        // Do some permutations to avoid
        // truncation effects in permutation
        i = mod289(i);
        vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0 ));
        
        vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2) ), 0.0);
        
        m = m*m ;
        m = m*m ;
        
        // Gradients:
        //  41 pts uniformly over a line, mapped onto a diamond
        //  The ring size 17*17 = 289 is close to a multiple
        //      of 41 (41*7 = 287)
        
        vec3 x = 2.0 * fract(p * C.www) - 1.0;
        vec3 h = abs(x) - 0.5;
        vec3 ox = floor(x + 0.5);
        vec3 a0 = x - ox;
        
        // Normalise gradients implicitly by scaling m
        // Approximation of: m *= inversesqrt(a0*a0 + h*h);
        m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);
        
        // Compute final noise value at P
        vec3 g = vec3(0.0);
        g.x  = a0.x  * x0.x  + h.x  * x0.y;
        g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
        return 130.0 * dot(m, g);
    }
    
    // Colors

    
    vec3 pink() {
        return vec3(0.98, 0.76, 0.74);
    }
    
    vec3 green() {
        return vec3(0.07, 0.40, 0.40);
    }
    
    vec3 blue() {
        return vec3(0.12, 0.40, 0.67);
    }
    
    vec3 white() {
        return vec3(1.0);
    }
    
    // Shaping
    
    // Creates a circle centered in uv with a given radius and edge.
    float circleMask(vec2 uv, float radius, float edge) {
        return circle(uv, vec2(0.), radius, edge);
    }
    
    float rectangle(vec2 uv, float width, float height) {
        float hW = width / 2.0;
        float hH = height / 2.0;
        return (-hW < uv.x && uv.x < hW &&
        -hH < uv.y && uv.y < hH) ? 1.0 : 0.0;
    }
    
    float square(vec2 uv, float dimension) {
        return rectangle(uv, dimension, dimension);
    }
    
    // Grids
    
    // Creates a hexagonal tiling grid
    vec4 hexCoords(vec2 uv) {
        // Repeat rate for both axes - 1, sqrt(3)
        vec2 r = vec2(1, 1.73);
        vec2 h = r*.5; // normalize
        
        vec2 a = fmod(uv, r)-h;
        vec2 b = fmod(uv-h, r)-h;
        
        // Same as length(a) < length(b)
        vec2 gv = dot(a, a) < dot(b,b) ? a : b;
        vec2 id = uv-gv; // Unique ids
        return vec4(gv.x, gv.y, id.x, id.y);
    }
    
    vec4 hexGrid(vec2 uv, float repeat) {
        vec2 _uv = (uv / 2.0) + 0.5;
        return hexCoords(_uv * repeat);
    }
    
    // Add background color and foreground shape with color
    vec3 shapeMask(float shape, vec3 bgColor, vec3 fgColor) {
        float bgMask = 1. - shape;
        return bgMask * bgColor + shape * fgColor;
    }
    
    // Creates a single tile of 6 dots in a centered hexagon tiling pattern.
    vec3 dotGrid(vec2 uv, float repeat, float dotDimension, vec3 bgColor, vec3 fgColor, bool fading) {
        vec4 coords = hexGrid(uv, repeat);
        
        float normalizedY = coords.w / repeat; // now (0.0 to 1.0)
        float dimension = dotDimension;
        
        if (fading) {
        dimension = smoothstep(0.1 * dotDimension, dotDimension, normalizedY * dotDimension) + 0.1;
        dimension *= 1.7;
        }
        
        float dot = circle(coords.xy, vec2(0), dimension, .005 * repeat);
        return shapeMask(dot, bgColor, fgColor);
        }
        
        vec3 squareGrid(vec2 uv, float repeat, float dimension, vec3 bgColor, vec3 fgColor) {
        vec4 coords = hexGrid(uv, repeat);
        float shape = square(coords.xy, dimension);
        
        vec2 id = (coords.zw / repeat) * 10.;
        vec2 fid = vec2(floor(id.x), floor(id.y));
        // if (floor(id.x) == 2. && floor(id.y) == 4.) {
        //     shape = 0.;
        // }
        
        // if (fmod(fid.x, 1.) == 0.) {
        // shape = 0.;
        // }
        
        if (fmod(id.x, repeat) == 10./repeat) {
        shape = 0.;
        }
        
        return shapeMask(shape, bgColor, vec3(coords.w / repeat));
    }
    
    #pragma body
    
    vec2 st = _surface.diffuseTexcoord;
    vec2 bounds = u_boundingBox[1].xy;

    float _min = min(bounds.x, bounds.y);
    float _max = max(bounds.x, bounds.y);
    float ratio = _min / _max;
    
    if (_min == st.x) {
        st.x *= ratio;
        st.x += (1.0 - ratio) * 0.5;
    } else {
        st.y *= ratio;
        st.y += (1.0 - ratio) * 0.5;
    }
    
    // UV values goes from -1 to 1
    // So we need to remap st (0.0 to 1.0)

    st -= 0.5;  // becomes -0.5 to 0.5
    st *= 2.0;  // becomes -1.0 to 1.0
    
    vec3 color = vec3(0);
    
    float noise = snoise(st + scn_frame.time) * 0.395;
    
    float repeat = 12.;
    float dimension = .2;
    
    vec3 grid;
    
    grid = dotGrid(st, repeat, dimension, pink(), green(), false);
    //grid = squareGrid(st, repeat, dimension, blue(), white());
    
    // grid = vec3(hexGrid(st, repeat).x);
    
    color = grid;
    
    // Mask with the outer circle
    //color *= circleMask(st, 4., 0.02);
    
    _output.color = vec4(color,1.0);












    """
    
    static let megaTest2: Shader =
    """

    mat2 rotate2d(float _angle){
        return mat2(cos(_angle), -sin(_angle),
                    sin(_angle), cos(_angle));
    }

    vec3 mint() {
        return vec3(0.71, 0.86, 0.73);
    }

    vec3 pink() {
        return vec3(0.98, 0.76, 0.74);
    }

    vec3 rose() {
        return vec3(0.93, 0.35, 0.62);
    }

    vec3 green() {
        return vec3(0.07, 0.40, 0.40);
    }

    vec3 blue() {
        return vec3(0.12, 0.40, 0.67);
    }

    vec3 white() {
        return vec3(1.0);
    }

    vec3 purple() {
        return vec3(0.44, 0.28, 0.49);
    }

    vec3 yellowPale() {
        return vec3(1.00, 0.91, 0.77);
    }

    vec3 yellowEaster() {
        return vec3(0.99, 0.95, 0.65);
    }

    vec3 goldenrod() {
        return vec3(0.97, 0.73, 0.22);
    }

    vec3 mod289(vec3 x) {
        return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec2 mod289(vec2 x) {
        return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec3 permute(vec3 x){
        return mod289(((x*34.0)+1.0)*x);
    }

    float snoise(vec2 v) {
        // Precompute values for skewed triangular grid
        const vec4 C = vec4(0.211324865405187,
        // (3.0-sqrt(3.0))/6.0
        0.366025403784439,
        // 0.5*(sqrt(3.0)-1.0)
        -0.577350269189626,
        // -1.0 + 2.0 * C.x
        0.024390243902439);
        // 1.0 / 41.0

        // First corner (x0)
        vec2 i  = floor(v + dot(v, C.yy));
        vec2 x0 = v - i + dot(i, C.xx);

        // Other two corners (x1, x2)
        vec2 i1 = vec2(0.0);
        i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
        vec2 x1 = x0.xy + C.xx - i1;
        vec2 x2 = x0.xy + C.zz;

        // Do some permutations to avoid
        // truncation effects in permutation
        i = mod289(i);
        vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0 ));

        vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2) ), 0.0);

        m = m*m ;
        m = m*m ;

        // Gradients:
        //  41 pts uniformly over a line, mapped onto a diamond
        //  The ring size 17*17 = 289 is close to a multiple
        //      of 41 (41*7 = 287)

        vec3 x = 2.0 * fract(p * C.www) - 1.0;
        vec3 h = abs(x) - 0.5;
        vec3 ox = floor(x + 0.5);
        vec3 a0 = x - ox;

        // Normalise gradients implicitly by scaling m
        // Approximation of: m *= inversesqrt(a0*a0 + h*h);
        m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

        // Compute final noise value at P
        vec3 g = vec3(0.0);
        g.x  = a0.x  * x0.x  + h.x  * x0.y;
        g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
        return 130.0 * dot(m, g);
    }

    float circle(vec2 st, vec2 pos, float radius, float edge) {
        st = pos-st;
        float r = length(st) * 4.0;
        float f = radius;
        return 1.0-smoothstep(f-edge, f+edge, r);
    }

    float circleb(vec2 st, vec2 pos, float radius, float edge, float w) {
        return circle(st,pos,radius,edge) - circle(st,pos,radius-w,edge);
    }

    // Creates a circle centered in uv with a given radius and edge.
    float circleMask(vec2 uv, float radius, float edge) {
        return circle(uv, vec2(0.), radius, edge);
    }

    float rectangle(vec2 uv, float width, float height) {
        float hW = width / 2.0;
        float hH = height / 2.0;
        return (-hW < uv.x && uv.x < hW &&
        -hH < uv.y && uv.y < hH) ? 1.0 : 0.0;
    }

    float square(vec2 uv, float dimension) {
        return rectangle(uv, dimension, dimension);
    }

    float drawLine(vec2 uv, vec2 p1, vec2 p2, float width) {
      float a = abs(distance(p1, uv));
      float b = abs(distance(p2, uv));
      float c = abs(distance(p1, p2));

      if ( a >= c || b >=  c ) return 0.0;

      float p = (a + b + c) * 0.5;

      // median to (p1, p2) vector
      float h = 2. / c * sqrt( p * ( p - a) * ( p - b) * ( p - c));

      return mix(1.0, 0.0, smoothstep(0.5 * width, 1.5 * width, h));
    }

    float vShape(vec2 uv, float width) {
        vec2 _uv = (uv / 2.0) + 0.5;
        float hWidth = width / 8.;
        return max(drawLine(_uv, vec2(0.33, 0.68), vec2(0.5 + hWidth, 0.33), width),
                   drawLine(_uv, vec2(0.68, 0.68), vec2(0.5 - hWidth, 0.33), width));
    }

    // Creates a hexagonal tiling grid
    vec4 hexCoords(vec2 uv) {
        // Repeat rate for both axes - 1, sqrt(3)
        vec2 r = vec2(1, 1.73);
        vec2 h = r*.5; // normalize

        vec2 a = fmod(uv, r)-h;
        vec2 b = fmod(uv-h, r)-h;

        // Same as length(a) < length(b)
        vec2 gv = dot(a, a) < dot(b,b) ? a : b;
        vec2 id = uv-gv; // Unique ids
        return vec4(gv.x, gv.y, id.x, id.y);
    }

    vec4 hexGrid(vec2 uv, float repeat) {
        vec2 _uv = (uv / 2.0) + 0.5;
        return hexCoords(_uv * repeat);
    }

    // Add background color and foreground shape with color
    vec3 shapeMask(float shape, vec3 bgColor, vec3 fgColor) {
        float bgMask = 1. - shape;
        return bgMask * bgColor + shape * fgColor;
    }

    // Creates a single tile of 6 dots in a centered hexagon tiling pattern.
    vec3 dotGrid(vec2 uv, float repeat, float dotDimension, vec3 bgColor, vec3 fgColor, bool fading) {
        vec4 coords = hexGrid(uv, repeat);

        float normalizedY = coords.w / repeat; // now (0.0 to 1.0)
        float dimension = dotDimension;

        if (fading) {
        dimension = smoothstep(0.1 * dotDimension, dotDimension, normalizedY * dotDimension) + 0.1;
        dimension *= 1.7;
    }

    float dot = circle(coords.xy, vec2(0), dimension, .001 * repeat);
        return shapeMask(dot, bgColor, fgColor);
    }

    vec3 squareGrid(vec2 uv, float repeat, float dimension, vec3 bgColor, vec3 fgColor) {
        vec4 coords = hexGrid(uv, repeat);
        float shape = square(coords.xy, dimension);

        vec2 id = (coords.zw / repeat) * 10.;
        vec2 fid = vec2(floor(id.x), floor(id.y));
        // if (floor(id.x) == 2. && floor(id.y) == 4.) {
        //     shape = 0.;
        // }

        // if (fmod(fid.x, 1.) == 0.) {
        // shape = 0.;
        // }

        if (fmod(id.x, repeat) == 10./repeat) {
            shape = 0.;
        }

        return shapeMask(shape, bgColor, fgColor);
    }

    vec3 tripleDotGrid(vec2 uv, vec3 bgColor, vec3 fgColor) {
        vec3 color = bgColor;

        vec2 _uv = (uv / 2.0) + 0.5;
        _uv *= 90.;
        _uv = fmod(_uv, vec2(1.6, 1.0));
        
        color += vec3(circle(_uv, vec2(0.2, 0.2), 0.5, 0.02));
        color += vec3(circle(_uv, vec2(0.6, 0.2), 0.5, 0.02));
        color += vec3(circle(_uv, vec2(1.0, 0.2), 0.5, 0.02));
        
        return color * fgColor;
    }

    vec3 vGrid(vec2 uv, float repeat, vec3 bgColor, vec3 fgColor, float time) {
        vec3 color = bgColor;
        vec4 coords = hexGrid(uv, repeat);

        float pi = 3.1415926535897932384626433832795;
        float rotation = snoise(coords.zw + 0.2 * time) * pi;
        vec2 rotatedCoords = coords.xy * rotate2d(rotation);
        
        float shape = vShape(rotatedCoords, 0.02);
        return shapeMask(shape, bgColor, fgColor);
    }

    #pragma body

    vec2 st = _surface.diffuseTexcoord;
    vec2 bounds = u_boundingBox[1].xy;

    float _min = min(bounds.x, bounds.y);
    float _max = max(bounds.x, bounds.y);
    float ratio = _min / _max;

    if (_min == st.x) {
        st.x *= ratio;
        st.x += (1.0 - ratio) * 0.5;
    } else {
        st.y *= ratio;
        st.y += (1.0 - ratio) * 0.5;
    }

    // UV values goes from -1 to 1
    // So we need to remap st (0.0 to 1.0)

    st -= 0.5;  // becomes -0.5 to 0.5
    st *= 2.0;  // becomes -1.0 to 1.0

    vec3 color = mint();

    float repeat = 50.;
    
    float numCircles = 6.;
    
    float radius = 1.2;
    float radiusDelta = (radius - 0.2) / numCircles;
    
    float dimen = 2.;
    float dimenDelta = (dimen - 0.2) / numCircles;
    
    float circOffset = 0.02;
    
    vec2 pos = vec2(-1.5, 0.);
    
    for (int i = 0; i < 6; ++i) {
        
        pos += vec2(radius / 2.0, 0.0);
        dimen -= dimenDelta;
        radius -= radiusDelta;
    
        // Yellow solid circle
        float circ = circle(st, pos, radius, 0.0);
        color = shapeMask(circ, color, goldenrod());

        // Pink dot circle
        vec3 dots2 = dotGrid(st, repeat, dimen, color, rose(), false);
        float circ2 = circle(st, pos + vec2(circOffset, -circOffset), radius, 0.0);
        color = shapeMask(circ2, color, dots2);
        
    }

    _output.color = vec4(color,1.0);




    """
    
    static let testFunctions: Shader =
    """
    // Colors

    vec3 pink() {
    return vec3(0.98, 0.76, 0.74);
    }

    vec3 green() {
    return vec3(0.07, 0.40, 0.40);
    }

    vec3 blue() {
    return vec3(0.12, 0.40, 0.67);
    }

    vec3 white() {
    return vec3(1.0);
    }

    // Shaping

    // Creates a circle centered in uv with a given radius and edge.
    float circleMask(vec2 uv, float radius, float edge) {
    return circle(uv, vec2(0.), radius, edge);
    }

    float rectangle(vec2 uv, float width, float height) {
    float hW = width / 2.0;
    float hH = height / 2.0;
    return (-hW < uv.x && uv.x < hW &&
    -hH < uv.y && uv.y < hH) ? 1.0 : 0.0;
    }

    float square(vec2 uv, float dimension) {
    return rectangle(uv, dimension, dimension);
    }

    // Grids

    // Creates a hexagonal tiling grid
    vec4 hexCoords(vec2 uv) {
    // Repeat rate for both axes - 1, sqrt(3)
    vec2 r = vec2(1, 1.73);
    vec2 h = r*.5; // normalize

    vec2 a = fmod(uv, r)-h;
    vec2 b = fmod(uv-h, r)-h;

    // Same as length(a) < length(b)
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    vec2 id = uv-gv; // Unique ids
    return vec4(gv.x, gv.y, id.x, id.y);
    }

    vec4 hexGrid(vec2 uv, float repeat) {
    vec2 _uv = (uv / 2.0) + 0.5;
    return hexCoords(_uv * repeat);
    }

    // Add background color and foreground shape with color
    vec3 shapeMask(float shape, vec3 bgColor, vec3 fgColor) {
    float bgMask = 1. - shape;
    return bgMask * bgColor + shape * fgColor;
    }

    // Creates a single tile of 6 dots in a centered hexagon tiling pattern.
    vec3 dotGrid(vec2 uv, float repeat, float dotDimension, vec3 bgColor, vec3 fgColor, bool fading) {
    vec4 coords = hexGrid(uv, repeat);

    float normalizedY = coords.w / repeat; // now (0.0 to 1.0)
    float dimension = dotDimension;

    if (fading) {
    dimension = smoothstep(0.1 * dotDimension, dotDimension, normalizedY * dotDimension) + 0.1;
    dimension *= 1.7;
    }

    float dot = circle(coords.xy, vec2(0), dimension, .005 * repeat);
    return shapeMask(dot, bgColor, fgColor);
    }

    vec3 squareGrid(vec2 uv, float repeat, float dimension, vec3 bgColor, vec3 fgColor) {
    vec4 coords = hexGrid(uv, repeat);
    float shape = square(coords.xy, dimension);

    vec2 id = (coords.zw / repeat) * 10.;
    vec2 fid = vec2(floor(id.x), floor(id.y));
    // if (floor(id.x) == 2. && floor(id.y) == 4.) {
    //     shape = 0.;
    // }

    // if (fmod(fid.x, 1.) == 0.) {
    // shape = 0.;
    // }

    if (fmod(id.x, repeat) == 10./repeat) {
    shape = 0.;
    }

    return shapeMask(shape, bgColor, vec3(coords.w / repeat));
    }
    """
    
    static let modFunctions: Shader =
    """
    vec3 mod289(vec3 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec2 mod289(vec2 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    vec3 permute(vec3 x){
      return mod289(((x*34.0)+1.0)*x);
    }
    """
    
    static let snoise: Shader =
    """
    float snoise(vec2 v) {
    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
      // (3.0-sqrt(3.0))/6.0
      0.366025403784439,
      // 0.5*(sqrt(3.0)-1.0)
      -0.577350269189626,
      // -1.0 + 2.0 * C.x
      0.024390243902439);
      // 1.0 / 41.0

    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2) ), 0.0);

    m = m*m ;
    m = m*m ;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
    }
    """
    
    static let circle: Shader =
    """
    float circle(vec2 st, vec2 pos, float radius, float edge) {
      st = pos-st;
      float r = length(st) * 4.0;
      float f = radius;
      return 1.0-smoothstep(f-edge, f+edge, r);
    }

    float circleb(vec2 st, vec2 pos, float radius, float edge, float w) {
      return circle(st,pos,radius,edge) - circle(st,pos,radius-w,edge);
    }
    """
    
    static let pragmaBody: Shader = "\n#pragma body\n"
    
    /*
     vec2 coords = _surface.diffuseTexcoord;
     vec2 bounds = u_boundingBox[1].xy;
     float ratio = bounds.x / bounds.y;
     coords.x *= ratio;
     coords.x += (1.0 - ratio) * 0.5;
     
     vec2 pos = vec2(cos(u_time), sin(u_time));
     vec3 color = vec3(circle(coords + pos * 0.2, 0.5, 0, 0.6));
     
     _output.color = vec4(color, 1.0);
     */
    static let defaultFragementShader: Shader =
    """
    vec2 st = _surface.diffuseTexcoord;
    vec2 bounds = u_boundingBox[1].xy;
    float ratio = bounds.x / bounds.y;
    st.x *= ratio;
    st.x += (1.0 - ratio) * 0.5;

    vec3 color = vec3(0);

    // UV values goes from -1 to 1
    // So we need to remap st (0.0 to 1.0)
    st -= 0.5;  // becomes -0.5 to 0.5
    st *= 2.0;  // becomes -1.0 to 1.0

    float noise = snoise(st + scn_frame.time) * 0.395;


    float repeat = 12.;
    float dimension = .2;

    vec3 grid;

    grid = dotGrid(st, repeat, dimension, pink(), green(), false);
    //grid = squareGrid(st, repeat, dimension, blue(), white());

    // grid = vec3(hexGrid(st, repeat).x);

    color = grid;

    // Mask with the outer circle
    //color *= circleMask(st, 4., 0.02);

    _output.color = vec4(color,1.0);
    """
    
    public static var fragmentShader: Shader {
        get {
//            guard let shader = UserDefaults.standard.string(forKey: userFragmentShaderKey) && shader != "" else {
                return .defaultFragementShader
//            }
//            return shader
        }
        set {
//            UserDefaults.standard.set(newValue, forKey: userFragmentShaderKey)
        }
    }
    
    private static let userFragmentShaderKey: String = "userFragmentShader"
    
}

