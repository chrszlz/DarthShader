//
//  CodeCell.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit
import SavannaKit
import SourceEditor

public protocol CodeCellDelegate {
    func codeCellDidUpdateText(cell: CodeCell)
    func codeCell(cell: CodeCell, willBeginEditing textView: TextView)
}

public class CodeCell: UITableViewCell {
    
    public var delegate: CodeCellDelegate?
    
    lazy var lexer = SwiftLexer()
    
    public var code: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    public lazy var textView = SyntaxTextView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .clear
        
        textView.backgroundColor = .clear
        textView.contentTextView.isScrollEnabled = false
        textView.theme = DefaultSourceCodeTheme()
        textView.contentInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom:  8.0, right: 0.0);
        textView.delegate = self
        
        addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
    }

}

extension CodeCell: SyntaxTextViewDelegate {
    
    public func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
    
    public func didChangeText(_ syntaxTextView: SyntaxTextView) {
        delegate?.codeCellDidUpdateText(cell: self)
    }
    
    public func textViewWillBeginEditing(_ textView: TextView) {
        delegate?.codeCell(cell: self, willBeginEditing: textView)
    }
    
}
