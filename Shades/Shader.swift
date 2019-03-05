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
    
    public static let modFunctions: Shader =
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
    
    public static let snoise: Shader =
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
    
    public static let circle: Shader =
    """
    float circle(in vec2 _st, in float _radius) {
      vec2 dist = _st-vec2(0.5);
      return 1.-smoothstep(_radius-(_radius*0.01), _radius+(_radius*0.01), dot(dist,dist)*4.0);
    }
    """
    
    public static let pragmaBody: Shader = "\n#pragma body\n"
    
    public static let defaultFragementShader: Shader =
    """
    vec2 st = _surface.position.xy / u_boundingBox[1].xy;
    float brightness = 0.9;
    
    vec3 color = vec3(
    circle(st, snoise(st + u_time*0.15) *0.1 ) * brightness,
    circle(st, -snoise(st + u_time*0.025) *0.1 ) * brightness,
    circle(st, snoise(st + -1.*u_time*0.3) *0.15 ) * brightness);
    
    _output.color = vec4(color, 1.0);

    """
    
    public static var fragmentShader: Shader {
        get {
            guard let shader = UserDefaults.standard.string(forKey: userFragmentShaderKey) else {
                return .defaultFragementShader
            }
            return shader
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userFragmentShaderKey)
        }
    }
    
    private static let userFragmentShaderKey: String = "userFragmentShader"
    
}

