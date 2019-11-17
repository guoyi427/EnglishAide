//
//  DictionaryTableCellView.swift
//  EnglishAide
//
//  Created by guo yi on 11/17/19.
//  Copyright © 2019 guo yi. All rights reserved.
//

import Cocoa

class DictionaryTableCellView: NSTableCellView {

    @IBOutlet weak var rememberButton: NSButton!
    
    fileprivate var _wordString: String = ""
    fileprivate var _index: Int = 0
    
    func update(wordString: String, index: Int) {
        _wordString = wordString
        _index = index
    }
    
    @IBAction func rememberButtonAction(_ sender: NSButton) {
        print("word:\(_wordString) at index:\(_index)")
    }
}
