// ios/Runner/ArMeasurementViewFactory.swift

import Flutter
import UIKit

class ArMeasurementViewFactory: NSObject, FlutterPlatformViewFactory {
    
    private let messenger: FlutterBinaryMessenger
    private let channel: FlutterMethodChannel
    
    var currentView: ArMeasurementView?
    
    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        currentView = ArMeasurementView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            channel: channel
        )
        return currentView!
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}