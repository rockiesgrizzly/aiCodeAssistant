//
//  main.swift
//  aic
//
//  Created by Josh MacDonald on 10/16/25.
//

import AICodeAssistant

// Entry point for the command-line tool
if #available(macOS 26.0, *) {
    await AICodeAssistant.main()
} else {
    // Fallback on earlier versions
}
