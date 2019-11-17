//
//  DatabaseManager.swift
//  EnglishAide
//
//  Created by guo yi on 11/5/19.
//  Copyright © 2019 guo yi. All rights reserved.
//

import Cocoa
import SQLite3

class DatabaseManager: NSObject {
    static let shared = DatabaseManager()
    var db: OpaquePointer!
    
    override init() {
        super.init()
        var needPrepareGeneralDictionary: Bool = false
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! + "/Dictionary.db";
        if !FileManager.default.fileExists(atPath: path) {
            //  文件不存在 从main bundle复制一份过去
            let emptyDBPath = Bundle.main.path(forResource: "Dictionary", ofType: "db")!
            try! FileManager.default.copyItem(atPath: emptyDBPath, toPath: path)
            needPrepareGeneralDictionary = true
        }
        let state = sqlite3_open(path, &db)
        if state != SQLITE_OK {
            print("open db failure path = \(path)")
        }
        print("db path = \(path)")
        if needPrepareGeneralDictionary {
            let path = Bundle.main.path(forResource: "allwords", ofType: "txt")!
            let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
            let jsonDic = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String:String]
            addWords(dictionary: jsonDic)
        }
    }
    
    func addWords(dictionary: [String: String]) {
        sqlite3_exec(db, "begin transaction", nil, nil, nil)
        for (word, content) in dictionary {
            sqlite3_exec(db, "insert into General (word, content, level) values ('\(word)', '\(content)', \(1))", nil, nil, nil)
        }
        sqlite3_exec(db, "commit transaction", nil, nil, nil)
    }
    
    func queryContent(withWord word: String) -> String {
        if word.count == 0 {
            return ""
        }
        var content = ""
        
        let sqlString = "select content from General where word = '\(word)'"
        var stmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sqlString, -1, &stmt, nil) != SQLITE_OK {
            print("prepare failute sql = \(sqlString)")
            return ""
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            //  有数据
            if let contentCString = sqlite3_column_text(stmt, 0) {
                content = String(cString: contentCString)
                break
            }
        }
        
        sqlite3_finalize(stmt)
        return content
    }
    
    func updateProficiency(withWord word: String, proficiency: Int) {
        let sqlString = "update User set proficiency = \(proficiency) where word = \(word)".cString(using: .utf8)
        if sqlite3_exec(db, sqlString, nil, nil, nil) != SQLITE_OK {
            print("sqlite exec failure")
        }
    }

}
