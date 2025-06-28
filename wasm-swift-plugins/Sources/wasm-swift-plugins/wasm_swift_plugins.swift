// The Swift Programming Language
// https://docs.swift.org/swift-book

import WasmKit
import WasmKitWASI
import Foundation

@main
struct wasm_swift_plugins {
    static func main() throws {
        print("Hello, from normal Swift! I am about to load a web assembly plugin")
        // Parse a WASI-compliant WebAssembly module from a file.
        let module = try parseWasm(filePath: "HelloWorldScript/.build/debug/HelloWorldScript.wasm")

        // Create a WASI instance forwarding to the host environment.
        let wasi = try WASIBridgeToHost()
        // Create engine and store
        let engine = Engine()
        let store = Store(engine: engine)
        // Instantiate a parsed module importing WASI
        var imports = Imports()
        wasi.link(to: &imports, store: store)
        let instance = try module.instantiate(store: store, imports: imports)

        // Start the WASI command-line application.
        let exitCode = try wasi.start(instance)
        // Exit the Swift program with the WASI exit code.
        exit(Int32(exitCode))
    }
}
