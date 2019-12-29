import SQLite3
import Cocoa

let fileMan = FileManager()
var nm1 = ""
var nm2 = ""
var nm3 = ""
var nm4 = ""
var visitDate = ""
var histURL = ""
var cVisitDate = ""
var cUrl = ""
var cTitle = ""
var ffoxDate = ""
var ffoxURL = ""


var browserHistFile = "browser_and_quarantine_history.txt"
fileMan.createFile(atPath: "browser-history.txt", contents: nil, attributes: nil)
    
let browseHistCollectorURL = URL(fileURLWithPath: "browser-history.txt")
      
let browseHistFileHandle = try FileHandle(forWritingTo: browseHistCollectorURL)
var isDir = ObjCBool(true)
let username = NSUserName()

//quarantine history
if fileMan.fileExists(atPath: "/Users/\(username)/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2", isDirectory: &isDir){
    browseHistFileHandle.write("Results for user \(username)\r----------------------------\r".data(using: .utf8)!)
                var db : OpaquePointer?
                var dbURL = URL(fileURLWithPath: "/Users/\(username)/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2")
                if sqlite3_open(dbURL.path, &db) != SQLITE_OK{
                    browseHistFileHandle.write("[-] Could not open quarantive events database.".data(using: .utf8)!)
                }else {
                    
                    let queryString = "select datetime(LSQuarantineTimeStamp, 'unixepoch') as last_visited, LSQuarantineAgentBundleIdentifier, LSQuarantineDataURLString, LSQuarantineOriginURLString from LSQuarantineEvent where LSQuarantineDataURLString is not null order by last_visited;"

                    var queryStatement: OpaquePointer? = nil
                    
                    if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK{
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                            let col1 = sqlite3_column_text(queryStatement, 0)
                            if col1 != nil{
                                nm1 = String(cString: col1!)
                                
                            }

                            let col2 = sqlite3_column_text(queryStatement, 1)
                            if col2 != nil{
                                nm2 = String(cString: col2!)
                            }
                            
                            let col3 = sqlite3_column_text(queryStatement, 2)
                            if col3 != nil{
                                nm3 = String(cString:col3!)
                            }
                            
                            
                            let col4 = sqlite3_column_text(queryStatement, 3)
                            if col4 != nil{
                                nm4 = String(cString: col4!)
                            }
                            
                            
                            browseHistFileHandle.write("Date: \(nm1) | App: \(nm2) | File: \(nm3) | OriginURL: \(nm4)\r".data(using: .utf8)!)

                        }
    //
                        sqlite3_finalize(queryStatement)
                        print("[+] Quarantine history database parsed and written to \"browser-history.txt\" in current directory.")
                    }
                    
                    
                    
                }
    
}else {
    browseHistFileHandle.write("[-] QuarantineEventsV2 database not found for user \(username)\r".data(using: .utf8)!)
}

//safari history check
if fileMan.fileExists(atPath: "/Users/\(username)/Library/Safari/History.db", isDirectory: &isDir){
    browseHistFileHandle.write("\r[+] Safari history results for user \(username):\r----------------------------\r".data(using: .utf8)!)
    var db : OpaquePointer?
    var dbURL = URL(fileURLWithPath: "/Users/\(username)/Library/Safari/History.db")
    if sqlite3_open(dbURL.path, &db) != SQLITE_OK{
        browseHistFileHandle.write("[-] Could not open the Safari History.db file for user \(username)\r".data(using: .utf8)!)
    }else {
        //let queryString = "select history_visits.visit_time, history_items.url from history_visits, history_items where history_visits.history_item=history_items.id;"
        let queryString = "select datetime(history_visits.visit_time + 978307200, 'unixepoch') as last_visited, history_items.url from history_visits, history_items where history_visits.history_item=history_items.id order by last_visited;"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK{
            while sqlite3_step(queryStatement) == SQLITE_ROW{
                let col1 = sqlite3_column_text(queryStatement, 0)
                if col1 != nil{
                    visitDate = String(cString: col1!)
                    
                }
                let col2 = sqlite3_column_text(queryStatement, 1)
                if col2 != nil{
                    histURL = String(cString: col2!)
                    
                }
                
                browseHistFileHandle.write("Date: \(visitDate) | URL: \(histURL)\r".data(using: .utf8)!)
                
            }
            sqlite3_finalize(queryStatement)
            print("[+] Safari history database parsed and written to \"browser-history.txt\" in current directory.")
        }
        
    }
}
else {
    browseHistFileHandle.write("[-] Safari History.db database not found for user \(username)\r".data(using: .utf8)!)
}

//chrome history check
if fileMan.fileExists(atPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/History", isDirectory: &isDir){
    browseHistFileHandle.write("\r[+] Chrome history results for user \(username):\r----------------------------\r".data(using: .utf8)!)
    var db : OpaquePointer?
    var dbURL = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/History")
    
    if sqlite3_open(dbURL.path, &db) != SQLITE_OK{
        browseHistFileHandle.write("[-] Could not open the Chrome history database file for user \(username)".data(using: .utf8)!)
        
    } else{
        
        let queryString = "select datetime(last_visit_time/1000000-11644473600, \"unixepoch\") as last_visited, url, title from urls order by last_visited;"
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK{
            
            while sqlite3_step(queryStatement) == SQLITE_ROW{
                
                
                let col1 = sqlite3_column_text(queryStatement, 0)
                if col1 != nil{
                    cVisitDate = String(cString: col1!)
                    
                }
                
                let col2 = sqlite3_column_text(queryStatement, 1)
                if col2 != nil{
                    cUrl = String(cString: col2!)
                    
                }
                
                let col3 = sqlite3_column_text(queryStatement, 2)
                if col3 != nil{
                    cTitle = String(cString: col3!)
                    
                }
                
                
                 browseHistFileHandle.write("Date: \(cVisitDate) | URL: \(cUrl) | Title: \(cTitle)\r".data(using: .utf8)!)
                
            }
            
            sqlite3_finalize(queryStatement)
            print("[+] Chrome history database parsed and written to \"browser-history.txt\" in current directory.")
           
            
        }
        else {
            print("\r[-] Issue with preparing the Chrome History database...this may be because something is currently writing to it (i.e., an active Chrome browser)...kill the browser and try again")
        }
        
    }
}
else{
    browseHistFileHandle.write("[-] Chrome History database not found for user \(username)\r".data(using: .utf8)!)
}
    
//firefox history check
if fileMan.fileExists(atPath: "/Users/\(username)/Library/Application Support/Firefox/Profiles/"){
    let fileEnum = fileMan.enumerator(atPath: "/Users/\(username)/Library/Application Support/Firefox/Profiles/")
    browseHistFileHandle.write("\r[+] Firefox history results for user \(username):\r----------------------------\r".data(using: .utf8)!)
    
    while let each = fileEnum?.nextObject() as? String {
        if each.contains("places.sqlite"){
            let placesDBPath = "/Users/\(username)/Library/Application Support/Firefox/Profiles/\(each)"
            var db : OpaquePointer?
            var dbURL = URL(fileURLWithPath: placesDBPath)
            
            var printTest = sqlite3_open(dbURL.path, &db)
            
            if sqlite3_open(dbURL.path, &db) != SQLITE_OK{
                browseHistFileHandle.write("[-] Could not open the Firefox history database file for user \(username)".data(using: .utf8)!)
            } else {
                
                let queryString = "select datetime(visit_date/1000000,'unixepoch') as time, url FROM moz_places, moz_historyvisits where moz_places.id=moz_historyvisits.place_id order by time;"
                
                var queryStatement: OpaquePointer? = nil
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK{
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW{
                        let col1 = sqlite3_column_text(queryStatement, 0)
                        if col1 != nil{
                            ffoxDate = String(cString: col1!)
                        }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if col2 != nil{
                            ffoxURL = String(cString: col2!)
                        }
                                                            
                         browseHistFileHandle.write("Date: \(ffoxDate) | URL: \(ffoxURL)\r".data(using: .utf8)!)
                        
                    }
                    
                    sqlite3_finalize(queryStatement)
                    print("[+] Firefox history database parsed and written to \"browser-history.txt\" in current directory.")
                   
                }
                
                
            }
        }
    }
}
else {
    browseHistFileHandle.write("[-] Firefox places.sqlite database not found for user \(username)\r".data(using: .utf8)!)
}


print("DONE!")
    




