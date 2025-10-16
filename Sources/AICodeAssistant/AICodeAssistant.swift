//
//  AICodeAssistant.swift
//  AI Code Assistant
//
//  Created by Josh MacDonald on 10/16/25.
//

import Foundation
import FoundationModels

/// A command-line tool that interacts with Apple's on-device Foundation Models.
/// It acts as a specialized AI assistant for iOS development.
@available(macOS 26.0, *)
public struct AICodeAssistant {
    static public func main() async {
        print("""
                 AI Code Assistant initializing.
                 """)
        
        // Ensure on-device model is available
        switch SystemLanguageModel.default.availability {
        case .available:
            // This is logged from the instructions property now.
            break
        case .unavailable(let error):
            print("Error: Apple's on-device Foundation Model is not available. \(error)")
            return
        @unknown default:
            print("Error: Apple's on-device Foundation Model is not available. Unknown error")
            return
        }
        
        // Create persistent session, configured with instructions loaded from a file.
        let session = LanguageModelSession(instructions: instructions)
        
        print("I'm ready. How can I help?")
        
        while let userInput = readLine(strippingNewline: true) {
            guard userInput.lowercased() != "exit" else {
                print("10-4! I'm out. Catch you next time.")
                break
            }
            
            do {
                // Get stream model response
                let response = try await session.respond(to: userInput)
                print(response, terminator: "")
                
                // Add clear visual separation for the next user prompt
                print("\n")
                print("─" + String(repeating: "─", count: 60) + "─")
                print()
            } catch {
                print("\nAn error occurred: \(error.localizedDescription)")
                print("─" + String(repeating: "─", count: 60) + "─")
                print()
            }
        }
    }
    
    /// Loads the system instructions from a configuration file, creating it if necessary.
     /// This computed property centralizes the logic for finding, reading, and creating the prompt file.
    private static var instructions: Instructions {
         let configURL = FileManager.default.homeDirectoryForCurrentUser
             .appendingPathComponent(".aiCodeAssistant", isDirectory: true)
         let instructionsPath = configURL.appendingPathComponent("workingInstructions.md")

         do {
             // Ensure the directory exists first.
             try FileManager.default.createDirectory(at: configURL, withIntermediateDirectories: true, attributes: nil)
             
             let instructionsText = try String(contentsOf: instructionsPath, encoding: .utf8)
             print("Successfully loaded instructions from ~/.aiCodeAssistant/workingInstructions.md")
             return Instructions(instructionsText)

         } catch {
             // Check if the error is because the file doesn't exist.
             let nsError = error as NSError
             if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileReadNoSuchFileError {
                 print("Instructions file not found. Creating a default one...")
                 let defaultInstructionsText = """
                 ## GENERAL
                 - You are an expert-level senior iOS developer with years of experience.
                 - Your primary language is Swift, and you are a master of SwiftUI, UIKit, Combine, and Swift Concurrency.
                 - You always write clean, performant, maintainable, and idiomatic Swift code.
                 - You provide clear explanations for your code and follow Apple's API design guidelines meticulously.
                 - When asked to refactor, you prioritize simplicity and clarity.
                 
                 ## ARCHITECTURAL PREFERENCES
                 
                 ## OTHER
                 """
                 do {
                     // Attempt to write the default instructions to the file
                     try defaultInstructionsText.write(to: instructionsPath, atomically: true, encoding: .utf8)
                     print("Successfully created and loaded default instructions at ~/.aiCodeAssistant/workingInstructions.md")
                     return Instructions(defaultInstructionsText)
                 } catch let writeError {
                     // If creating the file fails, fall back to the generic prompt
                     print("Error: Could not create 'workingInstructions.md'.")
                     print("Details: \(writeError.localizedDescription)")
                     print("Using a default, generic prompt for now.")
                     return Instructions("You are a helpful AI assistant.")
                 }
             } else {
                 // The file exists, but there was another error reading it (e.g., permissions).
                 print("Warning: Could not load 'workingInstructions.md'.")
                 print("Details: \(error.localizedDescription)")
                 print("Using a default, generic prompt for now.")
                 return Instructions("You are a helpful AI assistant.")
             }
         }
     }
}

