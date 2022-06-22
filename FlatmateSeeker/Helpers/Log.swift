//
//  Log.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 23/10/2021.
//

import Foundation

class Log: TextOutputStream {

    func write(_ string: String) {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
    static var log: Log = Log()
    private init() {}
}
