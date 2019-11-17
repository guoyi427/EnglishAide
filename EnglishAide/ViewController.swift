//
//  ViewController.swift
//  EnglishAide
//
//  Created by guo yi on 11/5/19.
//  Copyright © 2019 guo yi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    //  View
    @IBOutlet var inputTextView: NSTextView!
    @IBOutlet weak var inputButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var recommendButton: NSButton!
    
    @IBOutlet weak var tableViewScrollView: NSScrollView!
    @IBOutlet weak var inputScrollView: NSScrollView!
    
    //  Data
    var wordsDictionary: [String: String] = [:]
    var wordsFromInput: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewScrollView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func inputButtonAction(_ sender: NSButton) {
        if inputTextView.string.count == 0 {
            return
        }
        
        inputScrollView.isHidden = true
        tableViewScrollView.isHidden = false
        
        let originString = inputTextView.string
        
        let pattern = "[A-z]{1,}"
        let expression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let results = expression.matches(in: originString, options: [], range: NSMakeRange(0, originString.count))
        for result in results {
            let word = (originString as NSString).substring(with: result.range)
            wordsFromInput.append(word)
        }
                
        for word in wordsFromInput {
            let content = DatabaseManager.shared.queryContent(withWord: word)
            wordsDictionary[word] = content
        }
        tableView.reloadData()
    }
    
    @IBAction func recommendButtonAction(_ sender: NSButton) {
        
    }
    
    
    @IBAction func rememberButtonAction(_ sender: NSButton) {
        print(sender)
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    enum CellIdentifiers {
        static let TextCell = "TextCell"
        static let ContentCell = "ContentCell"
        static let CheckBoxCell = "CheckBoxCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        var contentString: String = ""
        
        var cell:NSTableCellView?
        
        var wordString = ""
        if row < wordsFromInput.count {
            wordString = wordsFromInput[row]
        }
        
        if tableView.tableColumns.first == tableColumn {
            //  第一列
            cellIdentifier = CellIdentifiers.TextCell
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = wordString
        } else if tableView.tableColumns[1] == tableColumn {
            //  第二列
            cellIdentifier = CellIdentifiers.ContentCell
            contentString = wordsDictionary[wordString] ?? "暂无翻译"
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = contentString
        } else {
            //  第三列
            cellIdentifier = CellIdentifiers.CheckBoxCell
            let dicCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? DictionaryTableCellView
            dicCell?.update(wordString: wordString, index: row)
            cell = dicCell
        }
        
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return wordsFromInput.count;
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        if tableColumn != tableView.tableColumns[2] {
            return
        }
    }
}
