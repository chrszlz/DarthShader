//
//  CodeTableView.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public struct Snippet {
    public var name: String
    public var code: Shader
    
    init(_ name: String, code: String) {
        self.name = name
        self.code = code
    }
}

public protocol CodeTableDelegate {
    func codeTable(_ table: CodeTableView, didUpdate shader: Shader)
    
//    func codeTableTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
//    func codeTableTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
//    func codeTableTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
//    func codeTableTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

open class CodeTableView: UITableViewController {
    
    /// String snippets of code that will be concatened, in-order
    /// to produce the final output shader.
//    public var snippets = [Snippet]()
    public var sections = [CodeSection]()
    
    public var currentTextView: UITextView?
    
    /// Complete shader of snippet set.
    public var shader: Shader {
        return sections
            .flatMap { $0.items }   // [Snippet]
            .map { $0.code }        // [Shader]
            .reduce("") { $0 + $1 } // Shader
    }
    
    private lazy var toolbar: InputToolbar = {
        let toolbar = InputToolbar()
        toolbar.delegate = self
        return toolbar
    }()
    
    public var delegate: CodeTableDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
        sharedInit()
    }
    
    private func sharedInit() {
        view.backgroundColor = .clear
        
        tableView.dataSource = self
        tableView.register(reusableCell: CodeCell.self)
        tableView.register(reusableHeaderFooter: SectionHeaderView.self)
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }
    
}

// MARK: - UITableViewDataSource

extension CodeTableView {
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isCollapsed ? 0 : sections[section].items.count
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusableCell: CodeCell.self, indexPath: indexPath)
        cell.code = sections[indexPath.section].items[indexPath.row].code
        cell.delegate = self
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeue(reusableHeaderFooterCell: SectionHeaderView.self)
        header.titleLabel.text = sections[section].name
        header.section = section
        header.isCollapsed = sections[section].isCollapsed
        header.delegate = self
        return header
    }
    
}

extension CodeTableView: CodeCellDelegate {
    
    public func codeCellDidUpdateText(cell: CodeCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        sections[indexPath.section].items[indexPath.row].code = cell.textView.text
        delegate?.codeTable(self, didUpdate: shader)
        
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    public func codeCell(cell: CodeCell, willBeginEditing textView: UITextView) {
        currentTextView = textView
        textView.inputAccessoryView = toolbar
    }
    
}

extension CodeTableView: ToolbarDelegate {
    
    public func toolbarKeyPressed(_ toolbar: InputToolbar, key: InputToolbarKey, value: String) {
        currentTextView?.insertText(value)
    }
    
}

extension CodeTableView: SectionHeaderViewDelegate {
    
    public func toggleSection(_ header: SectionHeaderView, section: Int) {
        TapticEngine.selection.feedback()
        
        let isCollapsed = !sections[section].isCollapsed
        
        // Toggle collapse
        header.isCollapsed = isCollapsed
        sections[section].isCollapsed = isCollapsed
//        header.setCollapsed(isCollapsed)
        
        // Reload the whole section
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        tableView.endUpdates()
    }
    
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        delegate?.codeTableTouchesBegan(touches, with: event)
//    }
//    
//    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        delegate?.codeTableTouchesMoved(touches, with: event)
//    }
//    
//    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        delegate?.codeTableTouchesEnded(touches, with: event)
//    }
//    
//    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        delegate?.codeTableTouchesCancelled(touches, with: event)
//    }
    
}
