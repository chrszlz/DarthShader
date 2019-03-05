//
//  GLSLLexer.swift
//  Shades
//
//  Created by Chris Zelazo on 2/19/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Foundation
import SavannaKit
import SourceEditor

public class GLSLLexer: SourceCodeRegexLexer {
    
    public init() {
        
    }
    
    lazy var generators: [TokenGenerator] = {
        
        var generators = [TokenGenerator?]()
        
        // UI/App Kit
        generators.append(regexGenerator("\\b(gl_)[A-Z][a-zA-Z]+\\b", tokenType: .identifier))
        
        // Functions
        
        generators.append(regexGenerator("\\b.(?=\\()", tokenType: .identifier))
        

        generators.append(regexGenerator("(?<=(\\s|\\[|,|:))(\\d|\\.|_)+", tokenType: .number))
        
        generators.append(regexGenerator("\\.[A-Za-z_]+\\w*", tokenType: .identifier))
        
        let keywords = "attribute centroid sample patch const flat in inout invariant noperspective out smooth uniform varying buffer shared lowp mediump highp break case continue default discard do else for if return switch while".components(separatedBy: " ")
        
        generators.append(keywordGenerator(keywords, tokenType: .keyword))
        
        let stdlibIdentifiers = "abs acos all any asin atan ceil clamp cos cross degrees dFdx dFdy distance dot equal exp exp2 faceforward floor fract ftransform fwidth greaterThan greaterThanEqual inversesqrt length lessThan lessThanEqual log log2 matrixCompMult max min mix mod noise1 noise2 noise3 noise4 normalize not notEqual outerProduct pow radians reflect refract shadow1D shadow1DLod shadow1DProj shadow1DProjLod shadow2D shadow2DLod shadow2DProj shadow2DProjLod sign sin smoothstep sqrt step tan texture1D texture1DLod texture1DProj texture1DProjLod texture2D texture2DLod texture2DProj texture2DProjLod texture3D texture3DLod texture3DProj texture3DProjLod textureCube textureCubeLod transpose void bool int uint float double vec2 vec3 vec4 dvec2 dvec3 dvec4 bvec2 bvec3 bvec4 ivec2 ivec3 ivec4 uvec2 uvec3 uvec4 mat2 mat3 mat4 mat2x2 mat3x2 mat4x2 mat2x3 mat3x3 mat4x3 mat2x4 mat3x4 mat4x4 dmat2 dmat3 dmat4 dmat2x2 dmat3x2 dmat4x2 dmat2x3 dmat3x3 dmat4x3 dmat2x4 dmat3x4 dmat4x4 sampler1 sampler2 sampler3 samplerCube sampler2DRect sampler2DRectShadow samplerBuffer sampler2DMS sampler2DMSArray struct isamplerCube isampler2DRect isamplerBuffer isampler2DMS isampler2DMSArray usamplerCube usampler2DRect usamplerBuffer usampler2DMS usampler2DMSArray".components(separatedBy: " ")
        
        generators.append(keywordGenerator(stdlibIdentifiers, tokenType: .identifier))
        
        // Line comment
        generators.append(regexGenerator("//(.*)", tokenType: .comment))
        
        // Block comment
        generators.append(regexGenerator("(/\\*)(.*)(\\*/)", options: [.dotMatchesLineSeparators], tokenType: .comment))
        
        // Single-line string literal
        generators.append(regexGenerator("(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .string))
        
        // Multi-line string literal
        generators.append(regexGenerator("(\"\"\")(.*?)(\"\"\")", options: [.dotMatchesLineSeparators], tokenType: .string))
        
        // Editor placeholder
        var editorPlaceholderPattern = "(<#)[^\"\\n]*"
        editorPlaceholderPattern += "(#>)"
        generators.append(regexGenerator(editorPlaceholderPattern, tokenType: .editorPlaceholder))
        
        return generators.compactMap( { $0 })
    }()
    
    public func generators(source: String) -> [TokenGenerator] {
        return generators
    }
    
}
